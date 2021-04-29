clc; clear; close all;
%%
path_results = 'results';

gab_mat = load('matrix_gabor_atom.mat');
A = gab_mat.A;

dgt = gab_mat.data.dgt; % operateur DGT
idgt = gab_mat.data.idgt; % operateur IDGT

missing_ratios = 0:0.1:1; % phases manquantes
error_rpi = zeros(length(missing_ratios),1);
%%
for i_ratio = 1 : length(missing_ratios)
    missing_ratio = missing_ratios(i_ratio);
    
    data = load(['random_mask_',num2str(missing_ratio),'.mat']);
    
    
    mask =  data.mask;
    b = data.b;
    x_ref = data.x_ref;
    
    x_rpi = random_phase_inpainting(mask,b,idgt);
    
    
    error_rpi(i_ratio) = compute_error(x_ref, x_rpi);
    
end
save(fullfile(path_results, 'collects_rpi_results.mat'),...,
    'error_rpi');
