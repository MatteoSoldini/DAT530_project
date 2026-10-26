function [] = COMMON_POST(transition)
global global_info

% ---------- tDev: no runner to give back ----------
if strcmp(transition.name, 'tDev')
    return
end

% ---------- Every other transition gives its runner back ----------
release();

% ---------- Lead time: a commit has just arrived in pDeployed ----------
if strncmp(transition.name, 'tDeployProd', 11)
    [tok, ~] = tokenArrivedLate('pDeployed', 1);
    color = get_color('pDeployed', tok);

    % 'C360' -> 360
    creationTime = str2double(color{1}(2:end));

    leadTime = current_time() - creationTime;
    global_info.LEAD_TIMES(end+1) = leadTime;
end
end