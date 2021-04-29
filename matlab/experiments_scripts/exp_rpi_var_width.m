clc; clear; close all;
%%
path_results = 'results';

gab_mat = load('matrix_gabor_atom.mat');
A = gab_mat.A;

dgt = gab_mat.data.dgt; % operateur DGT
idgt = gab_mat.data.idgt; % operateur IDGT

widths = 1:9; % phases manquantes
error_rpi_large = zeros(length(widths),1);
%%
for i_width = 1 : length(widths)
    width = widths(i_width);
    
    data = load(['large_mask_width_',num2str(width),'.mat']);
    
    
    mask =  data.mask;
    b = data.b;
    x_ref = data.x_ref;
    
    x_rpi_large = random_phase_inpainting(mask,b,idgt);
    
    
    error_rpi_large(i_width) = compute_error(x_ref, x_rpi_large);
    
end
save(fullfile(path_results, 'collects_rpi_large_results.mat'),...,
    'error_rpi_large');
