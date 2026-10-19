% Main simulation file (MSF) - CI/CD pipeline, sequential version
% Time unit (TU) = 1 minute of simulated time.
clear all; clc;
global global_info

%% Scenario parameters (baseline)
commitInterval = 30;     % time between two commits [min]
nRunners       = 10;      % runners available (used by PRE/POST files)

%% Simulation parameters
global_info.STOP_AT = 1440;   % simulate 24 h
global_info.nIntegrationTest = 2;

% Don't modify these
global_info.COMMIT_COUNT = 0;
global_info.LEAD_TIMES = [];

%% Petri net definition
pns = pnstruct('par_tests_pn_pdf');

%% Initial marking (empty: tDev is a source transition)
dyn.m0 = {};

%% Firing times (stage durations)
dyn.ft = {
    'tDev',              commitInterval, ...
    'tBuild',            15, ...
    'tUnitTest',         25, ...
    'tSecurityScan',     15, ...
    'tDeployStaging',    10, ...
    'tPerformanceTest',  15, ...
    'tDeployProd',        5 ...
};

for i = 1:global_info.nIntegrationTest
    name = ['tIntegrationTest', num2str(i)];
    dyn.ft{end+1} = name;
    dyn.ft{end+1} = 35;
end

%% Resources: shared pool of runners
% Format: name, number of instances, number of uses (inf = unlimited)
% NOTE: the pool is only enforced if the PRE files call requestSR({'runners',1})
% and the POST files call release().
dyn.re = {'runners', nRunners, inf};

%% Initialize and run
pni = initialdynamics(pns, dyn);
Sim_Results = gpensim(pni);

%% Results
disp('===== GENERAL SIMULATION RESULTS =====');
prnss(Sim_Results);

disp('===== RUNNER RESOURCE USAGE =====');
prnschedule(Sim_Results);

plotp(Sim_Results, {
    'pBuildQueue', ...
    'pUnitTestQueue', ...
    'pSecurityScanQueue', ...
    'pIntegrationQueue', ...
    'pUnitTestDone', ...
    'pSecurityScanDone', ...
    'pIntegrationDone', ...
    'pPerformanceQueue', ...
    'pProductionQueue', ...
    'pDeployed'
});

prnfinalcolors(Sim_Results);

n = ntokens('pDeployed');
fprintf('Commits deployed in 24h: %d\n', n);
fprintf('Mean lead time: %.1f min\n', mean(global_info.LEAD_TIMES));