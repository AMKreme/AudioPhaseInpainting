clc; clear; close all;
%% Generate signal parameters and signal
sig_len = 128;
fs = 500;
flim1 = [0, 200];
flim2 = [200, 150];
snr = 10;

signal_params=  generate_signal_parameters(sig_len, fs,flim1,...,
    flim2, snr);


x_ref = generate_chirp_dirac_noise(sig_len,signal_params);


%% Generate stft parameters

win_type='hann';
approx_win_len = 16;
hop = approx_win_len/2;
nbins = approx_win_len*2;

dgt_params = generate_stft_parameters(win_type, approx_win_len, hop,...,
    nbins, sig_len);

[dgt, idgt] = get_stft_operators(dgt_params, sig_len);

x_tf = dgt(x_ref);

%% Representation graphique
%temporel

figure;
plot(x_ref,'LineWidth',1.7)
xlabel('Temps (échantillons)')
ylabel('Amplitude')
grid on;
set(gca, 'FontSize', 20, 'fontName','Times');

% temps-fréquence

figure;

%plot_spectrogram(x_tf, dgt_params, signal_params, dgt);
plotdgt(x_tf, dgt_params.hop);
%plotdgt(x_tf, dgt_params.hop, dgt_params.nbins,'dynrange',100);
xlabel('Temps (échantillons)');
ylabel('Fréquence (normalisée)')
set(gca, 'FontSize', 20, 'fontName','Times');

%% versions lissée du spectrogramme

figure;
sgram(x_ref);
xlabel('Temps(échantillons)');
ylabel('Fréquence (normalisée)')
set(gca, 'FontSize', 17, 'fontName','Times');
%% generer le masque
missing_ratio=0.09;
width=1;
[B, M] = generate_random_missing_phases(x_tf, missing_ratio, width);


%% affichage du masque
% 10 pourcent de donnees manquates
mask = ~M;
figure;
plotdgt(mask, dgt_params.hop);
xlabel('Temps(échantillons)');
ylabel('Fréquence(Hz)')
set(gca, 'FontSize', 17, 'fontName','Times');

%%
% 60 pourcent de donnees manquantes
missing_ratio=0.6;
width=1;
[B1, M1] = generate_random_missing_phases(x_tf, missing_ratio, width);
mask1 = ~M1;

figure;
plotdgt(mask1, dgt_params.hop);
xlabel('Temps (échantillons)');
ylabel('Fréquence (normalisée)')
set(gca, 'FontSize', 17, 'fontName','Times');


%%

missing_ratio=0.3;
width=8;
[B2, M2] = generate_random_missing_phases(x_tf, missing_ratio, width);
mask2 = ~M2;

figure;
plotdgt(mask2, dgt_params.hop);
xlabel('Temps(échantillons)');
ylabel('Fréquence (Hz)')
set(gca, 'FontSize', 17, 'fontName','Times');


