function [] = COMMON_POST(transition)
global global_info

% ---------- tDev: no runner to give back ----------
if strcmp(transition.name, 'tDev')
    global_info.CREATION_TIME(global_info.COMMIT_COUNT) = current_time();
    return
end


% ---------- Every other transition gives its runner back ----------
release();

% ---------- Lead time: a commit has just arrived in pDeployed ----------
if strncmp(transition.name, 'tDeployProd', 11)
    [tok, ~] = tokenArrivedLate('pDeployed', 1);
    color = get_color('pDeployed', tok);
    id = str2double(color{1}(2:end));               % 'C12' -> 12
    global_info.LEAD_TIMES(end+1)     = current_time() - global_info.CREATION_TIME(id);
    global_info.PIPELINE_TIMES(end+1) = current_time() - global_info.BUILD_START(id);
end
end