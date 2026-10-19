function [fire, transition] = tCheckTests_pre(transition)
fire = 0;

[tokE2E, nr_token_av] = tokenArrivedEarly('pE2ETestResults', 1);
if nr_token_av == 0
    return
end

color = get_color('pE2ETestResults', tokE2E(1));

[tokUT, nrUT] = tokenEXColor('pUnitTestResults', 1, color);
[tokSS, nrSS] = tokenEXColor('pSecurityScanResults', 1, color);

if nrUT >= 1 && nrSS >= 1
    transition.selected_tokens = [tokE2E, tokUT, tokSS];
    %transition.new_color = ['C', color];
    fire = 1; 
end

end