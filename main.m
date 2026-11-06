% Main simulation file (MSF) - CI/CD pipeline
% Time unit (TU) = 1 minute of simulated time
clear all; clc;
close all;
global global_info

%% Global initializations
global_info.COMMIT_COUNT   = 0;
global_info.CREATION_TIME  = [];
global_info.BUILD_START    = [];
global_info.WAIT_TIMES     = [];
global_info.LEAD_TIMES     = [];
global_info.PIPELINE_TIMES = [];

%% Simulation parameters
global_info.STOP_AT = 1440;         % (minutes) simulate 24 h

nRunners = 9;                       % runners available
nRuns    = 10;                      % number of simulation runs

global_info.PRIORITY_SCHEDULING = true;
global_info.PARALLEL  = true;

mode = 'RATE';
mode = validatestring(mode, {'SATURATED', 'LOAD', 'RATE'});   % catches typos

loadFactor  = 0.75;     % used in 'LOAD' mode (1.0 = capacity)
arrivalRate = 3;        % used in 'RATE' mode [commits/h]

W     = 120;                        % runner-minutes per commit
T_seq = 120;                        % critical path length sequential pipeline
T_par = 80;                         % critical path length parallel pipeline

%% Don't modify these

global_info.SATURATED = strcmp(mode, 'SATURATED');

switch mode
    case 'SATURATED'
        commitInterval = global_info.STOP_AT;   % tDev does practically nothing
        dyn.m0 = {'pBuildQueue', 1000};         % more than the pipeline can process
    case 'LOAD'
        maxThroughput  = nRunners / W;          % capacity [commits/min]
        commitInterval = 1 / (loadFactor * maxThroughput);
        dyn.m0 = {};
    case 'RATE'
        commitInterval = 60 / arrivalRate;      % [min]
        dyn.m0 = {};
end

global_info.nRunners = nRunners;            % used by the PDF file

%% Firing times: every copy of a stage gets the stage's duration
durations = {
'tBuild',           15;
'tUnitTest',        25;
'tSecurityScan',    15;
'tIntegrationTest', 35;
'tDeployStaging',   10;
'tPerformanceTest', 15;
'tDeployProd',       5
};

dyn.ft = {'tDev', sprintf('exprnd(%g)', commitInterval)};
dyn.ip = {};                                % initial priorities
for s = 1:size(durations, 1)
    for k = 1:nRunners
        name = [durations{s, 1}, '_', num2str(k)];
        dyn.ft{end+1} = name;
        dyn.ft{end+1} = durations{s, 2};

        % Later stages (lower in the table) get a higher priority
        if global_info.PRIORITY_SCHEDULING
            dyn.ip{end+1} = name;
            dyn.ip{end+1} = s;
        end
    end
end

%% Resources: shared pool of runners
% Format: name, number of instances, number of uses
dyn.re = {'runners', nRunners, inf};

%% Run the simulation nRuns times
simMin   = global_info.STOP_AT;
simHours = simMin / 60;

% One entry per run
allDeployed   = zeros(1, nRuns);
allThroughput = zeros(1, nRuns);
allLeadTime   = zeros(1, nRuns);
allPipeTime   = zeros(1, nRuns);
allRU         = zeros(1, nRuns);

for run = 1:nRuns
    rng(run);                         % different, reproducible seed per run
    global_info.COMMIT_COUNT   = 0;
    global_info.CREATION_TIME  = [];
    global_info.BUILD_START    = [];
    global_info.WAIT_TIMES     = [];
    global_info.LEAD_TIMES     = [];
    global_info.PIPELINE_TIMES = [];
    
    pdfFile = 'pn_pdf';
    if global_info.PARALLEL
        pdfFile = 'par_tests_pn_pdf';
    end

    pns = pnstruct(pdfFile);         % rebuild the net from scratch
    pni = initialdynamics(pns, dyn);
    Sim_Results = gpensim(pni);

    % Metrics of this run
    nDeployed = ntokens('pDeployed');
    meanLeadTime = mean(global_info.LEAD_TIMES);
    meanPipeTime = mean(global_info.PIPELINE_TIMES);
    %if ~global_info.SATURATED
        % The commit color stores the start time of tDev, so subtract commitInterval
    %    meanLeadTime = meanLeadTime - commitInterval;
    %end
    [LE] = prnschedule(Sim_Results);

    allDeployed(run)   = nDeployed;
    if global_info.PARALLEL
        allThroughput(run) = nDeployed / (simHours - T_par/60);
    else
        allThroughput(run) = nDeployed / (simHours - T_seq/60);
    end
    allLeadTime(run)   = meanLeadTime;
    allPipeTime(run)   = meanPipeTime;
    allRU(run)         = LE;

    fprintf('Run %2d: %d commits deployed, mean lead time %.1f min\n', ...
            run, nDeployed, meanLeadTime);
end

%% Results: mean over all runs
disp('===== MEAN OVER ALL RUNS =====');
fprintf('Runs: %d\n', nRuns);
fprintf('Commits deployed:     %.1f C   (std %.1f)\n', mean(allDeployed), std(allDeployed));
fprintf('Throughput (SS):      %.3f C/h (std %.3f)\n', mean(allThroughput), std(allThroughput));
fprintf('Pipeline time:        %.1f min (std %.1f)\n', mean(allPipeTime), std(allPipeTime));
if ~global_info.SATURATED
    fprintf('Lead time:            %.1f min (std %.1f)\n', mean(allLeadTime), std(allLeadTime));

    allWaitTime = allLeadTime - allPipeTime;
    fprintf('Wait time:            %.1f min (std %.1f)\n', mean(allWaitTime), std(allWaitTime));
end
fprintf('Resource Utilization: %.2f %% (std %.2f)\n', mean(allRU), std(allRU));

%% Results: graphs of the LAST run
% Transitions that use a runner = all transitions except tDev
resourceTransitions = {pns.global_transitions.name};
resourceTransitions(strcmp(resourceTransitions, 'tDev')) = [];
%occupancy(Sim_Results, resourceTransitions);

places = {pns.global_places.name};

figure;
plotp(Sim_Results, places);
title('Places (last run)');