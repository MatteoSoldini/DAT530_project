function [fire, transition] = COMMON_PRE(transition)

if strcmp(transition.name, 'tDev')
    % Color = time the commit was started, e.g. 'C360'
    transition.new_color = ['C', num2str(current_time())];
    fire = 1;
    return
end

% ---------- Every other transition needs one runner ----------
fire = requestSR({'runners', 1});

% ---------- Take the oldest commit from the input queue (FIFO) ----------
name = strtok(transition.name, '_');
switch name
case {'tBuild'}
        [set_of_tokID, ~] = tokenArrivedEarly('pBuildQueue', 1);
        transition.selected_tokens = set_of_tokID;
        transition.new_color = ['C', num2str(current_time())];
case {'tUnitTest'}
        [set_of_tokID, ~] = tokenArrivedEarly('pUnitTestQueue', 1);
        transition.selected_tokens = set_of_tokID;
case {'tSecurityScan'}
        [set_of_tokID, ~] = tokenArrivedEarly('pSecurityScanQueue', 1);
        transition.selected_tokens = set_of_tokID;
case {'tIntegrationTest'}
        [set_of_tokID, ~] = tokenArrivedEarly('pIntegrationQueue', 1);
        transition.selected_tokens = set_of_tokID;
case {'tDeployStaging'}
        [set_of_tokID, ~] = tokenArrivedEarly('pStagingQueue', 1);
        transition.selected_tokens = set_of_tokID;
case {'tPerformanceTest'}
        [set_of_tokID, ~] = tokenArrivedEarly('pPerformanceQueue', 1);
        transition.selected_tokens = set_of_tokID;
case {'tDeployProd'}
        [set_of_tokID, ~] = tokenArrivedEarly('pProductionQueue', 1);
        transition.selected_tokens = set_of_tokID;
end
end