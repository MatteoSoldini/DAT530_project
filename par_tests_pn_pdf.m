function [pns] = par_tests_pn_pdf()
% PN definition file for the CI/CD pipeline (PARALLEL TESTS version).
%
% Flow (one token = one commit):
%   Dev -> Build -> [Unit tests | Security scan | Integration tests]
%       -> Staging + smoke tests -> Performance tests -> Production deployment
%
% After Build, the three tests run in parallel, each with its own queue.
% Staging only starts when all three tests of the SAME commit are done
% (checked in COMMON_PRE).
%
% Every stage gets nRunners transition copies (tBuild_1, tBuild_2, ...),
% so up to nRunners commits can be in the same stage at the same time.
% global_info.nRunners must be set in the main file before pnstruct.
global global_info

pns.PN_name = 'CI/CD pipeline';

% ---------- Places ----------
pns.set_of_Ps = {'pBuildQueue', ...
                 'pUnitTestQueue', 'pSecurityScanQueue', 'pIntegrationQueue', ...
                 'pUnitTestDone', 'pSecurityScanDone', 'pIntegrationDone', ...
                 'pPerformanceQueue', 'pProductionQueue', 'pDeployed'};

% ---------- Pipeline: task, input places, output places ----------
stages = {
'tBuild',           {'pBuildQueue'},        {'pUnitTestQueue', 'pSecurityScanQueue', 'pIntegrationQueue'};  % fork
'tUnitTest',        {'pUnitTestQueue'},     {'pUnitTestDone'};
'tSecurityScan',    {'pSecurityScanQueue'}, {'pSecurityScanDone'};
'tIntegrationTest', {'pIntegrationQueue'},  {'pIntegrationDone'};
'tDeployStaging',   {'pUnitTestDone', 'pSecurityScanDone', 'pIntegrationDone'}, {'pPerformanceQueue'};  % join
'tPerformanceTest', {'pPerformanceQueue'},  {'pProductionQueue'};
'tDeployProd',      {'pProductionQueue'},   {'pDeployed'}
};

% ---------- tDev: creates commits ----------
pns.set_of_Ts = {'tDev'};
pns.set_of_As = {'tDev', 'pBuildQueue', 1};

% ---------- nRunners copies of every stage ----------
for s = 1:size(stages, 1)
    for k = 1:global_info.nRunners
        name = [stages{s, 1}, '_', num2str(k)];
        pns.set_of_Ts{end+1} = name;

        % input places -> transition
        inputs = stages{s, 2};
        for p = 1:length(inputs)
            pns.set_of_As{end+1} = inputs{p};
            pns.set_of_As{end+1} = name;
            pns.set_of_As{end+1} = 1;
        end

        % transition -> output places
        outputs = stages{s, 3};
        for p = 1:length(outputs)
            pns.set_of_As{end+1} = name;
            pns.set_of_As{end+1} = outputs{p};
            pns.set_of_As{end+1} = 1;
        end
    end
end
end