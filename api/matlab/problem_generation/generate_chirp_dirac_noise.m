function x = generate_chirp_dirac_noise(sig_len, sig_params)


%     Parameters
%     ----------
%     sig_len : int
%         signal length, in samples
%     fs : float
%         sampling frequency in Hz
%     flim1 : array-like
%         chirp 1's initial and final frequency (vector with length 2)
%     flim2 : array-like
%         chirp 2's initial and final frequency (vector with length 2)
%     snr : float
%         signal to noise ratio
%
%     Returns
%     -------
%     nd-array
%         generated signal

%sig_len = sig_params.sig_len;
fs = sig_params.fs;
flim1 = sig_params.flim1;
flim2 = sig_params.flim2;
snr = sig_params.snr;


t = ((1:sig_len).')./ fs;
t1 = (sig_len-1)/ fs;

% Build components
x_chirp = chirp(t, flim1(1), t1, flim1(2)) + chirp(t, flim2(1), t1, flim2(2));

x_chirp = x_chirp./ max(abs(x_chirp));

x_dirac = zeros(sig_len,1);
x_dirac(sig_len/2) = 1;


x_noise = randn(sig_len,1);

x = x_chirp + x_dirac;

%Adjust noise level
x_noise =  x_noise.* (10^(-snr/20)*norm(x)/norm(x_noise));

%Add noise
x =x+ x_noise;

%normalize final signal
x = x ./max(abs(x));
end