function [pns] = par_tests_pn_pdf()
% PN definition file for the CI/CD pipeline (PARALLEL TESTS version).
%
% Flow (one token = one commit):
%   Dev -> Build -> [Unit tests | Security scan | Integration tests]
%       -> Staging + smoke tests -> Performance tests -> Production deployment
%
% After Build, the three tests run in parallel, each with its own queue.
% Staging only starts when all three tests of the commit are done.
%
% global_info.nIntegrationTest must be set in the main file before pnstruct.
% Durations are set in the main simulation file (dyn.ft).
global global_info

pns.PN_name = 'CI/CD pipeline';

% ---------- Places ----------
pns.set_of_Ps = {'pBuildQueue', ...
    'pUnitTestQueue', 'pSecurityScanQueue', 'pIntegrationQueue', ...
    'pUnitTestDone', 'pSecurityScanDone', 'pIntegrationDone', ...
    'pPerformanceQueue', 'pProductionQueue', 'pDeployed'};

% ---------- Transitions ----------
pns.set_of_Ts = {'tDev', 'tBuild', 'tUnitTest', 'tSecurityScan', ...
    'tDeployStaging', 'tPerformanceTest', 'tDeployProd'};

for i = 1:global_info.nIntegrationTest
    name = ['tIntegrationTest', num2str(i)];
    pns.set_of_Ts{end+1} = name;
end

% ---------- Arcs: source, destination, weight ----------
pns.set_of_As = {'tDev', 'pBuildQueue', 1, ...
    'pBuildQueue', 'tBuild', 1, ...
    ...
    'tBuild', 'pUnitTestQueue', 1, ...        % fork
    'tBuild', 'pSecurityScanQueue', 1, ...    % fork
    'tBuild', 'pIntegrationQueue', 1, ...     % fork
    ...
    'pUnitTestQueue', 'tUnitTest', 1, ...
    'tUnitTest', 'pUnitTestDone', 1, ...
    ...
    'pSecurityScanQueue', 'tSecurityScan', 1, ...
    'tSecurityScan', 'pSecurityScanDone', 1, ...
    ...
    'pUnitTestDone', 'tDeployStaging', 1, ...       % join
    'pSecurityScanDone', 'tDeployStaging', 1, ...   % join
    'pIntegrationDone', 'tDeployStaging', 1, ...    % join
    ...
    'tDeployStaging', 'pPerformanceQueue', 1, ...
    'pPerformanceQueue', 'tPerformanceTest', 1, ...
    'tPerformanceTest', 'pProductionQueue', 1, ...
    'pProductionQueue', 'tDeployProd', 1, ...
    'tDeployProd', 'pDeployed', 1};

for i = 1:global_info.nIntegrationTest
    name = ['tIntegrationTest', num2str(i)];

    % pIntegrationQueue -> tIntegrationTest_i
    pns.set_of_As{end+1} = 'pIntegrationQueue';
    pns.set_of_As{end+1} = name;
    pns.set_of_As{end+1} = 1;

    % tIntegrationTest_i -> pIntegrationDone
    pns.set_of_As{end+1} = name;
    pns.set_of_As{end+1} = 'pIntegrationDone';
    pns.set_of_As{end+1} = 1;
end
end