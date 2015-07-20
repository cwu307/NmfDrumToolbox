%% Detect Onsets from Drum Activation Matrix
% [drumOnsetTime, drumOnsetNum] = OnsetDetection(HD, fs, windowSize, hopSize, lamdaAll, orderAll)
% input:
%        HD           = float, rd*numFrames matrix, drum activation matrix
%        fs           = int, sampling frequency (Hz)
%        windowSize   = int, window size (samples)
%        hopSize      = int, hop size (samples)
%        lambda       = float, 3*1 vector, offset coefficient for adaptive
%                       median filter ex. 0.1 = DC offset by 10% of the maximum value
%        order        = float, 3*1 vector, window length for adaptive
%                       median filter (sec)
% output:
%        drumOnsetTime = float, 1*numOnsets vector, transcribed onset time (sec)
%        drumOnsetNum  = int, 1*numOnsets vector, transcribed drum name 
%                        1 = HH, 2 = BD, 3 = SD
%
% CW @ GTCMT 2015

function [drumOnsetTime, drumOnsetNum] = OnsetDetection(HD, fs, windowSize, hopSize, lambda, order)

[numDrum, numFrames] = size(HD);

myTmpResults = [];
myTmpTrans   = [];
order = fix(order./(hopSize/fs)); %sec to blocks

for i = 1:numDrum
    nvt = HD(i, :);   
    order_current = order(i);
    lambda_current = lambda(i);
    
    %//adaptive thresholding
    [threshold] = MedianThres(nvt, order_current, lambda_current);
    
    %//peak picking
    [onsetTimeInSec, ~] = PeakPicking(nvt, threshold, fs, windowSize, hopSize);
    
    [~, numOnsets] = size(onsetTimeInSec);
    myTmpTrans = i * ones(1, numOnsets);
    myTmpResults = [myTmpResults, [onsetTimeInSec; myTmpTrans]];
end
tmp = sortrows(myTmpResults', 1);
myTmpResults = tmp';


drumOnsetTime  = myTmpResults(1,:);
drumOnsetNum = myTmpResults(2,:);
