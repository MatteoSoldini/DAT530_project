function [fire, transition] = COMMON_PRE(transition)

% By default, no runner is required
granted = 1;

switch transition.name

    case {'tUnitTest', 'tSecurityScan', 'tE2ETest'}

        % Request one runner from the shared pool
        granted = requestSR({'runners', 1});

end

% The transition may fire only if the request is granted
fire = granted;

end