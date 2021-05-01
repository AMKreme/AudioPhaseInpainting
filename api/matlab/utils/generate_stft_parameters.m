function dgt_params = generate_stft_parameters(win_type, approx_win_len,...,
    hop, nb_bins, varargin)

%% dgt_params = generate_dgt_parameters(win_type, approx_win_len,hop, nbins, varargin)
% 
% function that generates the dgt parameters.The functions used for
% the DGT are those of ltfat and not those of Matlab

%     Inputs:
%      - win_type : str. It can be either a hanning (hann) or gauss window.
%      - approx_win_len :  window length
%      - hop :  length of time shift.
%      - nb_bins: number of channels.
%      - phase_conv: can be frequency-invariant phase 
%      -sig_len: length of input signal.
%
%   Outputs: dgt_params -  struct containing dgt parameters
%
%
% Author : A. Marina KREME
% e-mail : ama-marina.kreme@lis-lab.fr/ama-marina.kreme@univ-amu.fr
% Created: 2020-28-01
%%

phase_conv = 'freqinv';

win_type = lower(win_type);

wins = arg_firwin();
supported_wins = wins.flags.wintype;
supported_wins{end+1} = 'gauss';

indx= find(strcmp(supported_wins, win_type), 1);

if isempty(indx)
    fprintf("%s not supported, try: \n",win_type);
    fprintf("%s\n",supported_wins{:});
end
    

if  strcmp(win_type,'gauss') && nargin==4
    fprintf('Signal length should be given if win_type is "gauss" \n')
    
end



input_win_len = 2^(round(log2(approx_win_len)));

if input_win_len ~= approx_win_len
    warning('Input window length %.2f has been changed to %.2f.',approx_win_len, input_win_len);
end


%%

sig_len = varargin{1};
L = sig_len;

switch win_type
    case 'hann'
        [win, info]= gabwin({'tight',{win_type, input_win_len}}, hop, nb_bins, L);
        
    case  'gauss'
        tfr = (pi*input_win_len^2)/(4*sig_len*log(2));
        [win, info]= gabwin({'tight',{'gauss', tfr}}, hop, nb_bins,L);
               
end


%%

dgt_params.win_len = input_win_len;
dgt_params.hop = hop;
dgt_params.nb_bins= nb_bins;
dgt_params.win_type = win_type;
dgt_params.win = win;
dgt_params.info = info;
dgt_params.phase_conv = phase_conv;

%%



end

