%% compute normalized cross correlation between HH & HD without 
% substracting the means
% rho = CrossCorrNormalized(HH, HD)
% input:
%        HH  = float, rh*numFrames matrix, harmonic activation matrix
%        HD  = float, rd*numFrames matrix, drum activation matrix
% output:
%        rho = float, rd*rh matrix, normalized cross correlation between HH&HD
%
% CW @ GTCMT 2015


function rho = CrossCorrNormalized(HH, HD)

% normalization 
[rh, hLen] = size(HH);
[rd, dLen] = size(HD);
HH_N = zeros(rh, hLen);
HD_N = zeros(rd, dLen);

for i = 1:rh
    HH_N(i, :) = HH(i, :)/ norm(HH(i, :), 2);
end
for i = 1:rd
    HD_N(i, :) = HD(i, :)/ norm(HD(i, :), 2);
end

% compute rho 
for i = 1:rh
    for j = 1:rd
        rho(j, i) = sum( HH(i, :).* HD(j, :))/(norm(HH(i, :), 2) * norm(HD(j, :), 2)); 
    end
end