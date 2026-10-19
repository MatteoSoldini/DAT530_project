function [fire, transition] = COMMON_PRE(transition)

% All integration test transitions (tIntegrationTest1, tIntegrationTest2, ...)
% are treated the same way, so give them one common name here
name = transition.name;
if strncmp(name, 'tIntegrationTest', 16)
    name = 'tIntegrationTest';
end

% By default, the transition may fire
fire = 1;

switch name
    case {'tDev'}
        transition.new_color = ['C', num2str(current_time())];

    case {'tBuild'}
        [set_of_tokID, ~] = tokenArrivedEarly('pBuildQueue', 1);
        transition.selected_tokens = set_of_tokID;

    case {'tUnitTest'}
        fire = requestSR({'runners', 1});   % needs a runner
        [set_of_tokID, ~] = tokenArrivedEarly('pUnitTestQueue', 1);
        transition.selected_tokens = set_of_tokID;

    case {'tSecurityScan'}
        fire = requestSR({'runners', 1});   % needs a runner
        [set_of_tokID, ~] = tokenArrivedEarly('pSecurityScanQueue', 1);
        transition.selected_tokens = set_of_tokID;

    case {'tIntegrationTest'}
        fire = requestSR({'runners', 1});   % needs a runner
        [set_of_tokID, ~] = tokenArrivedEarly('pIntegrationQueue', 1);
        transition.selected_tokens = set_of_tokID;

    case {'tDeployStaging'}
        % Join: only fire if all three tests of the SAME commit are done
        fire = 0;

        % Take the earliest finished integration test
        [tokIT, nrIT] = tokenArrivedEarly('pIntegrationDone', 1);
        if nrIT == 0
            return
        end

        % Its color is the commit ID
        color = get_color('pIntegrationDone', tokIT(1));

        % Look for the unit test and security scan of the same commit
        [tokUT, nrUT] = tokenEXColor('pUnitTestDone', 1, color);
        [tokSS, nrSS] = tokenEXColor('pSecurityScanDone', 1, color);

        if nrUT >= 1 && nrSS >= 1
            transition.selected_tokens = [tokIT, tokUT, tokSS];
            fire = 1;
        end
end
end