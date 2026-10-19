function [] = COMMON_POST(transition)

global global_info

name = transition.name;
if strncmp(name, 'tIntegrationTest', 16)
    name = 'tIntegrationTest';
end

switch name

    case {'tUnitTest', 'tSecurityScan', 'tIntegrationTest'}

        % Release the resources held by this transition
        release(transition.name);
    
    case {'tDeployProd'}
        % A commit has just arrived in pDeployed: read its color
        [tok, ~] = tokenArrivedLate('pDeployed', 1);
        color = get_color('pDeployed', tok);

        % 'C360' -> 360
        creationTime = str2double(color{1}(2:end));

        % Time from creation to deployment
        leadTime = current_time() - creationTime;
        global_info.LEAD_TIMES(end+1) = leadTime;

end

end