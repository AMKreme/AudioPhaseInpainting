function plot_mask(mask, hop, nbins, fs)

%% plot_mask(mask, hop, nbins, fs)
% % This function displays the mask
%
% Inputs:
%    - mask: binary mask
%    - hop : length of time shift (int)
%    - nbins: numbers of channels (int)
%    - fs : sampling frequency

% Author : A. Marina KREME
%%

%L = hop*size(mask,2);

plotdgtreal(mask, hop, nbins, fs,'lin');
%title(['Signal length = ' num2str(L)]);
