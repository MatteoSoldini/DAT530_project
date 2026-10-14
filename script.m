clear all;
clc;

global global_info

global_info.STOP_AT = 50;

% Define the Petri net
% The function in your provided definition file is simple_pn_pdf()
pns = pnstruct('pn_pdf');

% Initial marking
dyn.m0 = {};

% Firing times (time units)
dyn.ft = {
    'tDev',             2, ...
    'tStaticAnalysis',  3, ...
    'tBuild',           5, ...
    'tUnitTest',        3, ...
    'tSecurityScan',    7, ...
    'tE2ETest',        10, ...
    'tCheckTests',      1 ...
    };

% Declare a shared pool of 2 runners
% Format: resource name, number of instances, availability
dyn.re = {'runners', 1, inf};

% Initialize the Petri net
pni = initialdynamics(pns, dyn);

% Run simulation
Sim_Results = gpensim(pni);

% Print general simulation results
disp('===== GENERAL SIMULATION RESULTS =====');
prnss(Sim_Results);

% Print resource usage schedule
disp('===== RUNNER RESOURCE USAGE =====');
prnschedule(Sim_Results);

% Plot the number of tokens in each place
plotp(Sim_Results, {
    'pSAQueue', ...
    'pBuildQueue', ...
    'pUnitTestQueue', ...
    'pSecurityScanQueue', ...
    'pE2ETestQueue', ...
    'pUnitTestResults', ...
    'pSecurityScanResults', ...
    'pE2ETestResults', ...
    'pDeploy'
    });