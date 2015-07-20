%% cost function: KL divergence
% [D] = myKLDivergence(p, q)
% input: 
%       p = float, n*n matrix
%       q = float, n*n matrix
% output:
%       D = float, scalar, computed KL diverence
% CW @ GTCMT 2015

function [D] = KlDivergence(p, q)

D = sum(sum( p.*( log(p + realmin) - log(q + realmin)) - p + q ));