%% Peak Picking based on Given Adaptive Threshold
% [onsetTimeInSec, onsetTimeInFrame] = PeakPicking(nvt, threshold, fs, windowSize, hopSize)
% input: 
%        nvt        = float, 1*numPoints vector, novelty functions
%        threshold  = float, 1*numPoints vector, adaptive threshold 
%        fs         = float, sampling frequency (Hz)
%        windowSize = int, window size (samples)
%        hopSize    = int, hop size (samples)
% output: 
%        onsetTimeInSec   = float, 1*numOnsets vector, onset time (sec)
%        onsetTimeInFrame = float, 1*numOnsets vector, onset time (frame)
%
% CW @ GTCMT 2015

function [onsetTimeInSec, onsetTimeInFrame] = PeakPicking(nvt, threshold, fs, windowSize, hopSize)

%find peaks row by row
[~,numBlocks] = size(nvt);

%initialization
hopTime = hopSize/fs; %hop time
winTime = windowSize/fs; %window time
t = (0:numBlocks)*hopTime;

tmp = nvt;
tmp( tmp <= threshold ) = 0;
[~, onsetTimeInFrame] = findpeaks(tmp);
onsetTimeInSec = t(onsetTimeInFrame);






