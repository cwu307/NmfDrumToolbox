%% Partially Fixed Nonnegative Matrix Factorization 
% [WD, HD, WH, HH, err] = PfNmf(X, WD, HD, WH, HH, rh, sparsity)
% input:
%        X    = float, numFreqX*numFrames matrix, input magnitude spectrogram
%        WD   = float, numFreqD*rd matrix, drum dictionary
%        HD   = float, rd*numFrames matrix, drum activation matrix
%        WH   = float, numFreqH*rh matrix, harmonic dictionary
%        HH   = float, rh*numFrames matrix, harmonic activation matrix
%        rh   = int, rank of harmonic matrix
%        sparsity = float, sparsity coefficient
% output: 
%        WD   = float, numFreqD*rd matrix, updated drum dictionary
%        HD   = float, rd*numFrames matrix, updated drum activation matrix
%        WH   = float, numFreqH*rh matrix, updated harmonic dictionary
%        HH   = float, rh*numFrames matrix, updated harmonic activation matrix
%        err  = error vector (numIter * 1)
% usage:
%        To randomly initialized different matrix, please give [] as input.
%        For example, [WD,HD,WH,HH,err] = PfNmf(X, WD, [], [], [], 0, 0)
%        is the basic NMF approach given only the drum template.
%        [WD,HD,WH,HH,err] = PfNmf(X, WD, [], [], [], 50, 0) is the
%        partially fixed NMF with 50 random intialized entries
% 
% CW @ GTCMT 2015


function [WD, HD, WH, HH, err] = PfNmf(X, WD, HD, WH, HH, rh, sparsity)

X = X + realmin; %make sure there's no zero frame
[numFreqX, numFrames] = size(X);
[numFreqD, rd] = size(WD);

%initilization
WD_update = 0;
HD_update = 0;
WH_update = 0;
HH_update = 0;

if ~isempty(WH)
    [numFreqH, rh] = size(WH);
else
    WH = rand(numFreqD, rh);
    [numFreqH, ~] = size(WH);
    WH_update = 1;
end

if (numFreqD ~= numFreqX)
    error('Dimensionality of the WD does not match X');
elseif (numFreqH ~= numFreqX)
    error('Dimensionality of the WH does not match X');
end

if ~isempty(HD)
    WD_update = 1;
else
    HD = rand(rd, numFrames);
    HD_update = 1;
end

if ~isempty(HH)
else
    HH = rand(rh, numFrames);
    HH_update = 1;
end

alpha = (rh + rd)/rd;
beta  = rh/(rh + rd);

%normalize W / H matrix
for i = 1:rd
    WD(:,i) = WD(:,i)./(norm(WD(:,i),1)); 
end

for i = 1:rh
    WH(:,i) = WH(:,i)./(norm(WH(:,i),1));
end

count = 0;
rep   = ones(numFreqX, numFrames);

%start iteration
while (count < 300)  
    
    approx = alpha*WD*HD + beta*WH*HH; 
    
    %update
    if HD_update
        HD = HD .* ((alpha * WD)'* (X./approx))./((alpha * WD)'*rep + sparsity);
    else
    end
    if HH_update
        HH = HH .* ((beta * WH)'* (X./approx))./((beta * WH)'*rep);
    else
    end
    if WD_update
        WD = WD .* ((X./approx)*(alpha * HD)')./(rep*(alpha * HD)');
    else
    end
    if WH_update
        WH = WH .* ((X./approx)*(beta * HH)')./(rep*(beta * HH)');
    else
    end
    
    %normalize W matrix
    for i = 1:(rh)
        WH(:,i) = WH(:,i)./(norm(WH(:,i),1));
    end
    for i = 1:(rd)
        WD(:,i) = WD(:,i)./(norm(WD(:,i),1));
    end
       
    %calculate variation between iterations
    count = count + 1;
    err(count) = KlDivergence(X, (alpha * WD*HD + beta * WH*HH)) + sparsity * norm(HD, 1);
    
    if (count >=2)               
        if (abs(err(count) - err(count -1 )) / (err(1) - err(count) + realmin)) < 0.001
            break;
        end
    end   
end

end


