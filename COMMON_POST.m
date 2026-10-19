function [] = COMMON_POST(transition)

switch transition.name

    case {'tUnitTest', 'tSecurityScan', 'tIntegrationTest'}

        % Release the resources held by this transition
        release(transition.name);

end

end