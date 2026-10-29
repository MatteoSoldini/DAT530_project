% Main simulation file (MSF) - CI/CD pipeline, sequential version
% Time unit (TU) = 1 minute of simulated time.
clear all; clc;
close all;
global global_info

%% Simulation parameters
global_info.STOP_AT = 1440;         % (minutes) simulate 24 h
nRunners = 8;                       % runners available
nRuns    = 10;                      % number of simulation runs
global_info.PRIORITY_SCHEDULING = true;
global_info.SATURATED = false;
global_info.PARALLEL  = false;

% Arrival mode:
%   true  = saturated: build queue starts full, no new commits (measures capacity)
%   false = open: tDev creates a commit every commitInterval minutes
if global_info.SATURATED
    commitInterval = global_info.STOP_AT;   % tDev does practically nothing
    dyn.m0 = {'pBuildQueue', 1000};         % more than the pipeline can process
else
    perc = 0.25;
    W = 120;                                % runner-minutes per commit
    maxThroughput = nRunners / W;           % capacity [commits/min]
    commitInterval = 1/maxThroughput/perc;  % time between two commits [min]
    dyn.m0 = {};                            % tDev is the only source
end

% Don't modify these
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
allRU         = zeros(1, nRuns);

for run = 1:nRuns
    rng(run);                         % different, reproducible seed per run
    global_info.LEAD_TIMES = [];      % reset the metrics of the previous run
    

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
    if ~global_info.SATURATED
        % The commit color stores the start time of tDev, so subtract commitInterval
        meanLeadTime = meanLeadTime - commitInterval;
    end
    [LE] = prnschedule(Sim_Results);

    allDeployed(run)   = nDeployed;
    allThroughput(run) = nDeployed / simHours;
    allLeadTime(run)   = meanLeadTime;
    allRU(run)         = LE;

    fprintf('Run %2d: %d commits deployed, mean lead time %.1f min\n', ...
            run, nDeployed, meanLeadTime);
end

%% Results: mean over all runs
disp('===== MEAN OVER ALL RUNS =====');
fprintf('Runs: %d\n', nRuns);
fprintf('Commits deployed: %.1f C   (std %.1f)\n', mean(allDeployed), std(allDeployed));
fprintf('Throughput:       %.3f C/h (std %.3f)\n', mean(allThroughput), std(allThroughput));
if global_info.SATURATED
    fprintf('Mean time build start -> deployed: %.1f min (std %.1f)\n', ...
            mean(allLeadTime), std(allLeadTime));
else
    fprintf('Mean lead time: %.1f min (std %.1f)\n', ...
            mean(allLeadTime), std(allLeadTime));
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