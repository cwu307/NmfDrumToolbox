%% Nonnegative Matrix Factor Deconvolution
% [P, G, err] = NmfD(X, B, maxIter, tFrames)
% input:
%        X       = float, numFreqX*numFrames matrix, input magnitude spectrogram
%        B       = float, numFreqD*nmfRank matrix, drum dictionary
%        maxIter = fixed number of iterations
%        tFrames = int, number of template frames
% output:
%        P   = float, numFreqD*nmfRank*tFrames tensor, updated drum dictionary
%        G   = float, nmfRank*numFrames matrix, updated drum activation matrix
%        err  = error vector (numIter * 1)
% usage:
%        To randomly initialize the input matrices, please provide [] as input.
%
% This implementation is based on the papers:
% [1] P. Smaragdis, “Non-negative matrix factor deconvolution; extraction of
% multiple sound sources from monophonic inputs,” in Proc. Intl. Conf. on
% Independent Component Analysis and Blind Signal Separation (ICA),
% Grenada, Spain, 2004, pp. 494–499.
%
% [2] H. Lindsay-Smith, S. McDonald, and M. Sandler, “Drumkit transcription
% via convolutive NMF,” in Proc. Intl. Conf. on Digital Audio Effects
% (DAFx), York, UK, September 2012.
%
% [3] C. Dittmar and M. Müller, “Reverse Engineering the Amen Break –
% Score-informed Separation and Restoration applied to Drum Recordings,”
% IEEE/ACM Transactions on Audio, Speech, and Language Processing,
% vol. 24, no. 9, pp. 1531–1543, 2016.
%
% CW @ GTCMT 2017

function [P, G, err] = NmfD(X, B, maxIter, tFrames)

X = X + realmin; %make sure there's no zero frame
[numFreqX, numFrames] = size(X);

if isempty(B)
  B = rand(numFreqX, nmfRank);
end

% get dimensions
[numFreqD, nmfRank] = size(B);

if (numFreqD ~= numFreqX)
  error('Dimensionality of the dictionary does not match X');
end

if isempty(maxIter)
  maxIter = 30; %% default value from [2]
end

if isempty(tFrames)
  tFrames = 10; %% default value from [2]
end

% initialize the activations
G = ones(nmfRank,numFrames);

% blow up the dictionary to spectrogram pattern tensor
P = [];
for r = 1:nmfRank
  P_r = B(:,r)*linspace(1,0.1,tFrames);
  P_r = P_r / (eps+sum(P_r(:)));
  P(:,r,:) = P_r;
end

% initialize replication matrix
rep   = ones(numFreqX, numFrames);

%start iteration
for k = 1:maxIter
  
  % compute first approximation
  X_tilde = convApprox(P,G);
  
  %% compute the ratio of the target to the approximation
  Q = X./(X_tilde+eps);
  shiftQ = [Q, zeros(numFreqD,tFrames-1)];
  shiftG = [zeros(nmfRank,tFrames-1), G]; 
  
  % contributions to the activiations will be accumulated here
  multG = zeros(nmfRank,numFrames);
  
  % go through all template frames
  for m = 1:tFrames
    
    % update patterns, pre-compute intermedaite activations
    transpG = shiftG(:,tFrames-m+1:end-m+1)';
    % update rule for templates
    multW = (Q*transpG)./(rep*transpG+eps);
    P(:,:,m) = P(:,:,m) .* multW;
    
    % update activations, pre-compute intermediate templates
    transpP = P(:,:,m)';
    % update rule for activations
    addP = transpP*shiftQ(:,m:m+numFrames-1) ./ (transpP*rep+eps);
    % accumulate contributions
    multG = multG + addP;
    
  end
  
  % apply normalization to activations
  G = G .* multG./tFrames;
  
  % apply L1 normalization to pattern tensor
  normTensor(1,:,1) = sum(sum(P,1),3);
  P = P ./ repmat(normTensor+eps,[numFreqD 1 tFrames]);
  
  % calculate variation between iterations
  err(k) = KlDivergence(X, X_tilde);
  
end

% model approximation via convolution
function X_tilde = convApprox(P, G)
[numFreqBins, nmfRank, tFrames] = size(P);
[nmfRank, numFrames] = size(G);

% initialize as zeros
X_tilde = zeros(numFreqBins,numFrames);

% apply zero padding
G = [zeros(nmfRank,tFrames-1), G];

% and reconstruct components one by one
for r = 1:nmfRank
  
  patternSlice = squeeze(P(:,r,:));
  convResult = conv2(G(r,:),patternSlice,'full');
  convResult = convResult(:,tFrames:tFrames+numFrames-1);
  
  % accumulate into approximation
  X_tilde = X_tilde+convResult;
  
end




