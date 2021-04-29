function plot_spectrogram(x, dgt_params, signal_params, dgt, dynrange, clim)
%% plot_spectrogram(x, dgt_params, signal_params, dgt, dynrange, clim)
% Function that displays the spectrogram of a signal
%
%  Inputs:
%     - x: signal
%     - dgt_params: dgt parameters
%     - signal_params: signal parameters
%     - dgt :  Gabor transform  operator
%     - dynrange : optional
%     - clim: optional
%
% Author : A. Marina KREME
%%

if size(x,2)==1
    x = compute_dgt(x,dgt);
end


if nargin==4
    dynrange=100;
    c_max = max(db(x(:)));
    clim = [c_max - dynrange, c_max];
    
plotdgtreal(x, dgt_params.hop, dgt_params.nbins, signal_params.fs,...,
    'dynrange', dynrange,'clim',clim)
else
    
plotdgtreal(x, dgt_params.hop, dgt_params.nbins, signal_params.fs,...,
    'dynrange', dynrange,'clim',clim)
end



end
