function x = random_phase_inpainting(mask,b,istft)
%% x = random_phase_inpainting(mask,b,istft)
% Random phase inpainting (RPI) algorithm. This algorithm replace missing 
% phase by zeros in time-frequency representation and
% reconstruct time domain signal
% 
% Inputs :
%     - mask: binary time-frequency mask  
%     - b: observations in which all amplitudes are known and some phases 
%                are missing.
%
%     - istft:  inverse of discrete gabor transform 
%
% Output:
%     - x : the reconstructed signal
%
% Author : A. Marina KREME
% e-mail :amamarinak@gmail.com/ama-marina.kreme@univ-amu.fr

mask = boolean(mask);

if ~islogical(mask)
    error('Error. \nInput must be a boolean, not a %s.',class(mask))
end

X = b;
X(~mask)=X(~mask).*exp(1j*2*pi*rand(sum(~mask(:)),1));
x = istft(X);

end


