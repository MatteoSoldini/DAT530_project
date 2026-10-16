function [fire, transition] = tDev_pre(transition)
global global_info;
global_info.COMMIT_COUNT = global_info.COMMIT_COUNT+1;
transition.new_color = ['C', num2str(global_info.COMMIT_COUNT)];
fire = 1;
end