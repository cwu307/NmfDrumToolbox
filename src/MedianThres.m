%% Adaptive Median Filter Threshold Curve
% [threshold] = MedianThres(nvt, order, lambda)
% input:
%        nvt    = float, m*numPoints matrix, m novelty functions
%        order  = int, window length for adaptive median filter (samples)
%        lambda = float, offset coefficient for adaptive
%                 median filter ex. 0.1 = DC offset by 10% of the maximum value
% output:
%        threshold = float, m*numPoints matrix, m adaptive threshold 
%
% CW @ GTCMT 2015

function [threshold] = MedianThres(nvt, order, lambda)

[m, numPoints] = size(nvt);
threshold = zeros(m, numPoints);
maxVal = max(nvt, [], 2);

for i = 1:numPoints     
    med = median(nvt(: , max(1, (i-order)):i), 2);
    threshold(:,i) = lambda*maxVal + med;
end

%compensate the delay of the threshold 
shiftSize = round(0.5 * order); %1/2 order size
threshold(:, 1:(end-shiftSize)) = threshold(:, (shiftSize+1):end);