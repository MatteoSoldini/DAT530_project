function [fire, transition] = COMMON_PRE(transition)

% By default, no runner is required
granted = 1;

switch transition.name
    case {'tUnitTest', 'tSecurityScan', 'tIntegrationTest'}

        % Request one runner from the shared pool
        granted = requestSR({'runners', 1});
end

switch transition.name
    case {'tStaticAnalysis'}
        [set_of_tokID, ~] = tokenArrivedEarly('pStaticAnalysisQueue', 1);
        transition.selected_tokens = set_of_tokID;
    case {'tBuild'}
        [set_of_tokID, ~] = tokenArrivedEarly('pBuildQueue', 1);
        transition.selected_tokens = set_of_tokID;
    case {'tUnitTest'}
        [set_of_tokID, ~] = tokenArrivedEarly('pUnitTestQueue', 1);
        transition.selected_tokens = set_of_tokID;
    case {'tSecurityScan'}
        [set_of_tokID, ~] = tokenArrivedEarly('pSecurityScanQueue', 1);
        transition.selected_tokens = set_of_tokID;
    case {'tIntegrationTest'}
        [set_of_tokID, ~] = tokenArrivedEarly('pIntegrationQueue', 1);
        transition.selected_tokens = set_of_tokID;
end

% The transition may fire only if the request is granted
fire = granted;

end