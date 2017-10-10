%% NMF Drum Toolbox v1.0
% [hh, bd, sd] = NmfDrum(filePath, method, param)
% input:
%        filePath   = string, the path of the file to be transcribed
%        method = string, options: 'Nmf', 'PfNmf', 'Am1', 'Am2'
%        param = struct, it contains the following parameters:
%        param.WD = float, (windowSize/2 + 1)*3 matrix
%                         drum dictionary for hh, bd, sd respectively
%        param.windowSize = int, window size for spectrogram
%        param.hopSize = int, hop size for spectrogram
%        param.lambda = float, 1*3 vector, offset coefficients 
%                       for onset detection (0.0 ~ 1.0)
%        param.order  = float, 1*3 vector, window length for
%                       adaptive median filter threshold (sec)
%        param.maxIter = int, max iteration for template adaptation
%        param.sparsity = float, sparsity coefficient
%        param.rhoThreshold = float, rho threshold for template
%                             adaptation (method 1)
%        param.rh = int, rank of the harmonic matrix
%                                           
% output: 
%        hh = float, n1*1 vector, hihat onset time (sec)
%        bd = float, n2*1 vector, bass drum onset time (sec)
%        sd = float, n3*1 vector, snare drum onset time (sec)
% usage:
%        [hh, bd, sd] = NmfDrum(filePath)
%        [hh, bd, sd] = NmfDrum(filePath, method)
%        [hh, bd, sd] = NmfDrum(filePath, method, param)
%
% CW @ GTCMT 2015


function [hh, bd, sd] = NmfDrum(filePath, method, param)

if nargin == 2
    load DefaultSetting.mat
elseif nargin == 1
    load DefaultSetting.mat
    method = 'PfNmf'; %by default, use PfNmf
end

fprintf('Selected method is %s\n', method);

%//load file
[x, fs] = audioread(filePath); 
x = mean(x,2); %down-mixing   
x = resample(x, 44100, fs); %sample rate consistency
fs = 44100;

%//compute spectrogram
overlap = param.windowSize - param.hopSize;
X = spectrogram(x, param.windowSize, overlap, param.windowSize, fs);    
X = abs(X);

if strcmp(method, 'Nmf')
    param.rh = 0;
    [~, HD, ~, ~, ~] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'PfNmf')
    [~, HD, ~, ~, ~] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'Am1')
    [~, HD, ~, ~, ~] = Am1(X, param.WD, param.rh, param.rhoThreshold...
        , param.maxIter, param.sparsity);
    
elseif strcmp(method, 'Am2')
    [~, HD, ~, ~, ~] = Am2(X, param.WD, param.maxIter, param.rh,...
        param.sparsity);
      
elseif strcmp(method, 'SaNmf')
    [~, HD, ~] = SaNmf(X, param.WD, param.maxIter, 4);      
    
elseif strcmp(method, 'NmfD')
    [PD, HD, ~] = NmfD(X, param.WD, param.maxIter, 10);         

end

[drumOnsetTime, drumOnsetNum] = OnsetDetection(HD, fs, param.windowSize, ...
    param.hopSize, param.lambda, param.order);


hh = transpose(drumOnsetTime(drumOnsetNum == 1));
bd = transpose(drumOnsetTime(drumOnsetNum == 2));
sd = transpose(drumOnsetTime(drumOnsetNum == 3));

