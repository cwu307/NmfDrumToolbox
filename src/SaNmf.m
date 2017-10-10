%% Semi-Adaptive Nonnegative Matrix Factorization
% [B, G, err] = SaNmf(X, B, maxIter, beta)
% input:
%        X       = float, numFreqX*numFrames matrix, input magnitude spectrogram
%        B       = float, numFreqD*rd matrix, drum dictionary
%        maxIter = fixed number of iterations
%        beta    = float, non-linearity applied to the blending parameter
% output:
%        B   = float, numFreqD*rd matrix, updated drum dictionary
%        G   = float, rd*numFrames matrix, updated drum activation matrix
%        err  = error vector (numIter * 1)
% usage:
%        To randomly initialize the input matrices, please provide [] as input.
%
% This implementation is based on the paper:
% [1] Christian Dittmar and Daniel Gärtner: Real-time transcription and
% separation of drum recordings based on NMF decomposition, DAFx 2014
%
% CW @ GTCMT 2017

function [B, G, err] = SaNmf(X, B, maxIter, beta)

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
  maxIter = 25; %% default value from [1]
end

if isempty(beta)
  beta = 4; %% default value from [1]
end

% initialize the activations
G = rand(nmfRank,numFrames);

% normalize the dictionary
normB = eps+sum(B); %% equals L1 norm
B = bsxfun(@times,B,1./(normB));

% store initial version
B_p = B;

% initialize replication matrix
rep   = ones(numFreqX, numFrames);

%start iteration
for k = 1:maxIter
  
  % compute blending parameter
  alpha = (k/maxIter).^beta;
  
  % update model
  BG = eps + (B*G);
  
  % update dictionary
  B = B.*((X./BG)*G')./(rep*G');
  
  % blend updated dictionary with initial one
  B = (1-alpha)*B_p + (alpha)*B;
  
  % normalize the dictionary
  normB = eps+sum(B); %% equals L1 norm
  B = bsxfun(@times,B,1./(normB));
  
  % update model
  BG = eps + (B*G);
  
  %% update activations
  G = G.*(B'*(X./BG))./(B'*rep);
  
  %calculate variation between iterations
  err(k) = KlDivergence(X, BG);
  
end

end


