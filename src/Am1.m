%% Adaptive Partially Fixed Nonnegative Matrix Factorization method 1
% Using cross correlation based template adaptation
% [WD, HD, WH, HH, itererr] = Am1(X, WD, rh, sparsity)
% input:
%        X    = float, numFreqX*numFrames matrix, input magnitude spectrogram
%        WD   = float, numFreqD*rd matrix, drum dictionary
%        rhoTrhes = float, scalar, threshold for selecting WH templates
%        maxIter  = int, scalar, max iteration number for adaptation 
%        rh   = int, rank of harmonic matrix
%        sparsity = float, sparsity coefficient
% output: 
%        WD   = float, numFreqD*rd matrix, updated drum dictionary matrix
%        HD   = float, rd*numFrames matrix, updated drum activation matrix
%        WH   = float, numFreqH*rh matrix, updated harmonic dictionary matrix
%        HH   = float, rh*numFrames matrix, updated harmonic activation matrix
%        iterErr  = float, maxIter*1 vector, approximation errors 
%
% CW @ GTCMT 2015

function [WD, HD, WH, HH, iterErr] = Am1(X, WD, rh, rhoThres, maxIter, sparsity)

iterErr = zeros(maxIter, 1);

for i = 1:maxIter
    %fprintf('%g iteration of template adaptation\n', i);
    
    %//NMF decomposition
    [WD, HD, WH, HH, err] = PfNmf(X, WD, [], [], [], rh, sparsity);
       
    %//keep track on error
    iterErr(i) = err(end); 
    
    %//stop criteria
    if i >= 2
        if abs(iterErr(i - 1) - iterErr(i)) / (iterErr(1) - iterErr(i) + realmin) <= 10e-3
            iterErr(i) = 0;
            break;
        end
    end
    
    %//dictionary extraction
    adaptCoef = 1/(2^i); %start from 0.2
    [WD_new, WH_new] = TemplateAdaptation(WD, HD, WH, HH, rhoThres, adaptCoef);
    
    %//NMF decomposition
    [~, ~, ~, ~, err] = PfNmf(X, WD_new, [], WH_new, [], rh, sparsity);
      
    %//keep track on error
    iterErr(i) = err(end); 
    
    %//stop criteria
    if i >= 2
        if abs(iterErr(i - 1) - iterErr(i)) / (iterErr(1) - iterErr(i) + realmin) <= 10e-3
            iterErr(i) = 0;
            break;
        end
    end
    
    %//adaptation
    WD = WD_new;
    WH = WH_new;  
end