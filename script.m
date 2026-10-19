% Main simulation file (MSF) - CI/CD pipeline, sequential version
% Time unit (TU) = 1 minute of simulated time.
clear all; clc;
global global_info

%% Scenario parameters (baseline)
commitInterval = 30;     % time between two commits [min]
nRunners       = 10;      % runners available (used by PRE/POST files)

%% Simulation parameters
global_info.STOP_AT = 1440;   % simulate 24 h
global_info.COMMIT_COUNT = 0;

%% Petri net definition
pns = pnstruct('pn_pdf');

%% Initial marking (empty: tDev is a source transition)
dyn.m0 = {};

%% Firing times (stage durations)
dyn.ft = {
    'tDev',              commitInterval, ...
    'tBuild',            15, ...
    'tUnitTest',         25, ...
    'tSecurityScan',     15, ...
    'tIntegrationTest',  35, ...
    'tDeployStaging',    10, ...
    'tPerformanceTest',  15, ...
    'tDeployProd',        5 ...
    };

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
    'pStagingQueue', ...
    'pPerformanceQueue', ...
    'pProductionQueue', ...
    'pDeployed'
    });

prnfinalcolors(Sim_Results);