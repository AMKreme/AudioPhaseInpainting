function [X,x_pli] = phaselift_inpainting_cvx(A, mask, obs, epsilon, tracker)

%% [X,x_pli] = phaselift_inpainting_cvx(A, mask, obs, epsilon, tracker)
%function which solves phaselift for phase inpaintng (PLI).
% The resolution is done based on the cvx toolbox available http://cvxr.com/cvx/
%
% Inputs :
%     - A: matrix of Gabor atoms
%     - mask: binary time-frequency mask  
%     - obs: observations in which all amplitudes are known and some phases 
%                are missing.
%     - epsilon : threshold on the approximation error
%     - tracker:  control parameter
%
% Outputs:
%     - X : time frequency matrix in which the missing phases have 
%                been estimated
%     - x_pli : the reconstructed signal
%
% Author : A. Marina KREME
% e-mail :amamarinak@gmail.com/ama-marina.kreme@univ-amu.fr


%%
n = size(A,2);
%%
cvx_begin SDP

%cvx_precision best
cvx_quiet true
variable X(n,n) hermitian complex

minimize(trace(X))
    subject to
    norm(linear_operator_cvx(X,A,mask)-obs,2)<= epsilon;
    X >= 0;
cvx_end


if ~isempty(tracker)
    tracker.update(X)
end

%%

if any(isnan(X))
    x_pli=NaN(size(X,1),1);
    disp('NaN returned')
else
    x_pli=phaselift_signal_reconstruction(X);
end
end