function x=phaselift_signal_reconstruction(X)
%% x=phaselift_signal_reconstruction(X)
%Estimation of the solution of the phase inpainting problem from the 
%solution X of the lifted and relaxed problem: PhaseLift. The method used 
%is the one proposed by Eckart Young's theorem, i.e. $x = sqrt(\lambda)z$,
%where z is an eigenvector associated to the largest eigenvalue 
% $\lambda$ a solution X
 
% Input :
%     - X: matrix with complex coefficients

% Output:
%     - x : the reconstructed signal
%
% Author : A. Marina KREME
% e-mail :amamarinak@gmail.com/ama-marina.kreme@univ-amu.fr





   [eig_vec, eig_val] = eigs(X, 1);
    x = sqrt(eig_val(1)).* eig_vec(:, 1);

end

