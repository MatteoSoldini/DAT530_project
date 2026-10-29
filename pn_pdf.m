function [pns] = pn_pdf()
% PN definition file for the CI/CD pipeline (SEQUENTIAL version).
% Every stage gets nRunners transition copies (tBuild_1, tBuild_2, ...),
% so up to nRunners commits can be in the same stage at the same time.
% global_info.nRunners must be set in the main file before pnstruct.
global global_info

pns.PN_name = 'CI/CD pipeline';

% ---------- Places ----------
pns.set_of_Ps = {'pBuildQueue', 'pUnitTestQueue', 'pSecurityScanQueue', ...
                 'pIntegrationQueue', 'pStagingQueue', 'pPerformanceQueue', ...
                 'pProductionQueue', 'pDeployed'};

% ---------- Pipeline: task, input place, output place ----------
stages = {
'tBuild',           'pBuildQueue',        'pUnitTestQueue';
'tUnitTest',        'pUnitTestQueue',     'pSecurityScanQueue';
'tSecurityScan',    'pSecurityScanQueue', 'pIntegrationQueue';
'tIntegrationTest', 'pIntegrationQueue',  'pStagingQueue';
'tDeployStaging',   'pStagingQueue',      'pPerformanceQueue';
'tPerformanceTest', 'pPerformanceQueue',  'pProductionQueue';
'tDeployProd',      'pProductionQueue',   'pDeployed'
};

% ---------- tDev: creates commits ----------
pns.set_of_Ts = {'tDev'};
pns.set_of_As = {'tDev', 'pBuildQueue', 1};

% ---------- nRunners copies of every stage ----------
for s = 1:size(stages, 1)
    for k = 1:global_info.nRunners
        name = [stages{s, 1}, '_', num2str(k)];
        pns.set_of_Ts{end+1} = name;

        % input place -> transition
        pns.set_of_As{end+1} = stages{s, 2};
        pns.set_of_As{end+1} = name;
        pns.set_of_As{end+1} = 1;

        % transition -> output place
        pns.set_of_As{end+1} = name;
        pns.set_of_As{end+1} = stages{s, 3};
        pns.set_of_As{end+1} = 1;
    end
end
end