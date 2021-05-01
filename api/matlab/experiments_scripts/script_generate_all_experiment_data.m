clc; clear;close all;
%% This script is used to generate a dataset composed of 40 realizations
% that differ from the masks

%%
warning('off', 'MATLAB:MKDIR:DirectoryExists');
%%
sig_len = 128;
fs = 500;
flim1 = [0, 200];
flim2 = [200, 150];
snr = 10;

signal_params=  generate_signal_parameters(sig_len, fs,flim1,...,
    flim2, snr);

x_ref = generate_chirp_dirac_noise(sig_len,signal_params);
fprintf("The signal length is :%.f\n\n",sig_len)

%% Generate stft parameters

win_type='hann';
approx_win_len = 16;
hop = approx_win_len/2;
nbins = approx_win_len*2;

dgt_params = generate_stft_parameters(win_type, approx_win_len, hop,...,
    nbins, sig_len);

[dgt, idgt,pseudoinv] = get_stft_operators(dgt_params, sig_len);

x_tf = dgt(x_ref);

fprintf("The DGT parameters are :\n -win_type : %s\n -hop : %.f\n -nbins: %.f\n,", win_type, hop, nbins)

%% mask generations

path_random_mask = 'exp_data_random_mask';
mkdir(path_random_mask);

width=1;
nb_realisations = 40;
missing_ratios = 0:0.1:1;
%%
for i_realisation = 1: nb_realisations
    fig_dir = fullfile(fullfile(path_random_mask,['realisation_',int2str(i_realisation)]),'random_holes');
    mkdir(fig_dir)
    
    for i_ratio = 1:length(missing_ratios)
        
        missing_ratio = missing_ratios(i_ratio);
        [b, mask] = generate_random_missing_phases(x_tf, missing_ratio, width);
        
        saveName = ['random_mask_',num2str(missing_ratio),'.mat'];
        save(fullfile(fig_dir,saveName),'mask','b','missing_ratio',...,
            'x_ref','dgt_params','signal_params', 'dgt','idgt', 'width');
    end
end

%%  generate with large width
path_large_mask = 'exp_data_large_mask';
mkdir(path_large_mask);

widths=1:9;

missing_ratio = 0.3;

for i_realisation = 1:nb_realisations
    fig_dir = fullfile(fullfile(path_large_mask,['realisation_',num2str(i_realisation)]),'large_holes');
    mkdir(fig_dir)
    for i_width = 1:length(widths)
        
        width = widths(i_width);
        [b, mask] = generate_random_missing_phases(x_tf, missing_ratio, width);
        
        saveName = ['large_mask_width_',num2str(width),'.mat'];
        save(fullfile(fig_dir,saveName),'mask','b','missing_ratio',...,
            'x_ref','dgt_params','signal_params', 'dgt','idgt', 'widths');
    end
end
%%
