function sig_params=  generate_signal_parameters(sig_len, fs,flim1,...,
    flim2, snr)

%% sig_params=  generate_signal_parameters(sig_len, fs,flim1,...,
%    flim2, snr). 
%
%
% Inputs : 
%       - sig_len :signal length
%       - fs : sampling frequency
%       - flim1:frequency intervals
%       - flim2 : frequency intervals
% outputs :
%       - sig_params (struct)
%
%
%%


if nargin==0
    sig_params.sig_len = 128;
    sig_params.fs=500;
    sig_params.flim1 = [0, 200];
    sig_params.flim2= [200, 150];
    sig_params.snr = 10;
    
else
    
    sig_params.sig_len = sig_len;
    sig_params.fs=fs;
    sig_params.flim1 =flim1;
    sig_params.flim2=flim2;
    sig_params.snr = snr;
    
end

end