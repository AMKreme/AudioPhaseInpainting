function  [direct_stft, adjoint_stft, ...,
    pseudoinverse_stft]=get_stft_operators(stft_params, sig_len)
%%  DGT operators 
%
%
%%
if nargin==0
    sig_len=128;
    win_type='hann';
    win_len=16;
    hop=8;
    nb_bins=32;
    phase_conv= 'freqinv';
    %w= gabwin({'tight',{win_type, win_len}}, hop, nb_bins, sig_len);
    
else
    
    win_type=stft_params.win_type;
    win_len= stft_params.win_len;
    hop=stft_params.hop;
    nb_bins=stft_params.nb_bins;
    phase_conv= stft_params.phase_conv;
    %w = stft_params.win;
    
end

wd = gabwin({'tight',{win_type, win_len}}, hop, nb_bins, sig_len);
w = gabdual(wd, hop, nb_bins, sig_len);

direct_stft =  @(x)dgt(x, w, hop, nb_bins, sig_len, phase_conv);
adjoint_stft =  @(x)idgt(x, w, hop, sig_len, phase_conv);
pseudoinverse_stft = @(x)idgt(x, wd, hop, sig_len, phase_conv);


end