% Example-01: A Simple Ordinary Petri Net 
% the main simulation file (MSF) to run simulation 

clear all; clc; 
global global_info
global_info.STOP_AT = 50;   % stop at time = 50 TU

pns = pnstruct('pn_pdf');

dyn.m0 = {};
dyn.ft = {
    'tDev1',  'normrnd(1, 0.5)', ...
    'tDev2',  'normrnd(1, 0.5)', ...
    'tBuild', 1  ...
};  % firing time
pni = initialdynamics(pns, dyn); 

Sim_Results = gpensim(pni); % perform simulation runs
prnss(Sim_Results);  % print the simulation results 
plotp(Sim_Results, {'pBuildQueue', 'pDeploy'}); % plot the results
