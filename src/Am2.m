%% Adaptive Partially Fixed Nonnegative Matrix Factorization method 2
% Using cross-update based template adaptation
% [WD, HD, WH, HH, itererr] = Am2(X, WD, rh, sparsity)
% input:
%        X    = float, numFreqX*numFrames matrix, input magnitude spectrogram
%        WD   = float, numFreqD*rd matrix, drum dictionary
%        maxIter  = int, scalar, max iteration number for adaptation 
%        rh   = int, rank of harmonic matrix
%        sparsity = float, sparsity coefficient
% output: 
%        WD   = float, numFreqD*rd matrix, updated drum dictionary
%        HD   = float, rd*numFrames matrix, updated drum activation matrix
%        WH   = float, numFreqH*rh matrix, updated harmonic dictionary
%        HH   = float, rh*numFrames matrix, updated harmonic activation matrix
%        iterErr  = float, maxIter*1 vector, approximation errors 
%
% CW @ GTCMT 2015

function [WD, HD, WH, HH, iterErr] = Am2(X, WD, maxIter, rh, sparsity)

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
    
    %//dictionary adaptation
    [WD_new, ~, WH_new, ~, err] = PfNmf(X, WD, HD, [], [], rh, sparsity);
    
    %//keep track on error
    iterErr(i) = err(end); 
    
    %//stop criteria
    if i >= 2
        if abs(iterErr(i - 1) - iterErr(i)) / (iterErr(1) - iterErr(i) + realmin) <= 10e-3
            iterErr(i) = 0;
            break;
        end
    end
    
    WD = WD_new;
    WH = WH_new;
end