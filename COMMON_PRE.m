function [fire, transition] = COMMON_PRE(transition)
global global_info

% ---------- tDev: no runner, just create the commit ----------
if strcmp(transition.name, 'tDev')
    transition.new_color = ['C', num2str(current_time())];
    fire = 1;
    return
end

fire = 0;

% tBuild_1 -> tBuild
name = strtok(transition.name, '_');

% ---------- Choose the tokens this job will use ----------
switch name
case {'tBuild'}
        [tokens, ~] = tokenArrivedEarly('pBuildQueue', 1);
        if global_info.SATURATED
            transition.new_color = ['C', num2str(current_time())];
        end
case {'tUnitTest'}
        [tokens, ~] = tokenArrivedEarly('pUnitTestQueue', 1);
case {'tSecurityScan'}
        [tokens, ~] = tokenArrivedEarly('pSecurityScanQueue', 1);
case {'tIntegrationTest'}
        [tokens, ~] = tokenArrivedEarly('pIntegrationQueue', 1);
case {'tDeployStaging'}
        if global_info.PARALLEL
            % Join: the earliest finished integration test ...
            [tokIT, nrIT] = tokenArrivedEarly('pIntegrationDone', 1);
            if nrIT == 0
                return
            end
            color = get_color('pIntegrationDone', tokIT(1));
            % ... and the unit test and security scan of the SAME commit
            [tokUT, nrUT] = tokenEXColor('pUnitTestDone', 1, color);
            [tokSS, nrSS] = tokenEXColor('pSecurityScanDone', 1, color);
            if nrUT == 0 || nrSS == 0
                return      % not all tests of this commit are done yet
            end
            tokens = [tokIT, tokUT, tokSS];
        else
            [tokens, ~] = tokenArrivedEarly('pStagingQueue', 1);
        end
case {'tPerformanceTest'}
        [tokens, ~] = tokenArrivedEarly('pPerformanceQueue', 1);
case {'tDeployProd'}
        [tokens, ~] = tokenArrivedEarly('pProductionQueue', 1);
end

% ---------- Take a runner only if the job can actually start ----------
if ~requestSR({'runners', 1})
    return
end
transition.selected_tokens = tokens;
fire = 1;
end