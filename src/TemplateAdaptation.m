%% Template adatation using cross-correlation 
% [WD_new, WH_new] = TemplateAdaptation(WD, WH, HD, HH, rhoThres, adaptCoef)
% input:
%        WD   = float, numFreqD*rd matrix, drum dictionary
%        HD   = float, rd*numFrames matrix, drum activation matrix
%        WH   = float, numFreqH*rh matrix, harmonic dictionary
%        HH   = float, rh*numFrames matrix, harmonic activation matrix
%        rhoTrhes = float, scalar, threshold for selecting WH dictionary
%        adaptCoef = float, scalar, weighting coefficient for adaptation
% output:
%        WD_new = float, numFreqD*rd matrix, updated drum dictionary
%        WH_new = float, numFreqH*rh matrix, updated harmonic dictionary
% 
% CW @ GTCMT 2015

function [WD_new, WH_new] = TemplateAdaptation(WD, HD, WH, HH, rhoThres, adaptCoef)

%initialization
[rd, numFrames] = size(HD);
rho = CrossCorrNormalized(HH, HD);
WH_new = WH;
WD_new = WD;

for i = 1:rd
    
    target = find(rho(i, :) >= rhoThres);
    if target
        % adaptation
        WD_new(:, i) = (1-adaptCoef)*WD(:, i) + ...
            adaptCoef*(WH(:,target)*transpose(rho(i, target))/length(target));

        % fill target entries in WH with random numbers
        WH_new(:, target) = rand(size(WH, 1), length(target));  
    end 
end



