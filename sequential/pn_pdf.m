function [pns] = pn_pdf()
% PN definition file for the CI/CD pipeline.
% global_info.nIntegrationTest must be set in the main file before pnstruct.

global global_info

pns.PN_name = 'CI/CD pipeline';

% ---------- Places ----------
pns.set_of_Ps = {'pBuildQueue', 'pUnitTestQueue', 'pSecurityScanQueue', ...
                 'pIntegrationQueue', 'pStagingQueue', 'pPerformanceQueue', ...
                 'pProductionQueue', 'pDeployed'};

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
                 'tBuild', 'pUnitTestQueue', 1, ...
                 'pUnitTestQueue', 'tUnitTest', 1, ...
                 'tUnitTest', 'pSecurityScanQueue', 1, ...
                 'pSecurityScanQueue', 'tSecurityScan', 1, ...
                 'tSecurityScan', 'pIntegrationQueue', 1, ...
                 'pStagingQueue', 'tDeployStaging', 1, ...
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

    % tIntegrationTest_i -> pStagingQueue
    pns.set_of_As{end+1} = name;
    pns.set_of_As{end+1} = 'pStagingQueue';
    pns.set_of_As{end+1} = 1;
end
end