function [pns] = simple_pn_pdf()

pns.PN_name = 'A Simple Classic Petri Net';
pns.set_of_Ps = {'pBuildQueue', 'pDeploy'};
pns.set_of_Ts = {'tDev1', 'tDev2', 'tBuild'}; 
pns.set_of_As = {
    'tDev1', 'pBuildQueue',  1, ...
    'tDev2', 'pBuildQueue',  1, ...
    'pBuildQueue', 'tBuild', 1, ...
    'tBuild', 'pDeploy',     1
};
