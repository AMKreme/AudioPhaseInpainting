 function x = phasecut_inpainting(mask, b, G,istft, n_iter,nu, verbose_it, tracker)
%% x = phasecut_inpainting(mask, b, stft, istft, n_iter,nu, verbose_it, tracker)
% Apply phasecut for phase inpainting (PCI) from observations. 
% See [1]
% Reference
% [1] Phase reconstruction for time-frequency inpainting, 2018.
%%



if nargin==5
    nu=1e-4;
    verbose_it = 1000;
    tracker =[];
end
%U =  phasecut_bcd(mask, b, stft, istft, n_iter, nu, verbose_it, tracker);
U = fast_phasecut_bcd(mask, b,G, n_iter, nu, verbose_it, tracker);    
x = phasecut_signal_reconstruction(U, b, istft);
end


