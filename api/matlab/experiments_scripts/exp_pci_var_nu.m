clc; clear; close all;
%%
% Etude numerique de la performance de PCI en fonction de nu
%%
gab_mat = load('matrix_gabor_atom.mat');
A = gab_mat.A;
dgt= gab_mat.data.dgt;
idgt = gab_mat.data.idgt;
x_ref = gab_mat.data.x_ref;
G = A*pinv(A,1e-10);

%% les donnees
missing_ratio_list = [0.1, 0.4, 0.8];
n_iter_list = [10000,60000, 60000];

nus=[1e-14, 1e-12, 1e-6] ;
%[1e-18, 1e-16, 1e-6] ;


verbose_it=1000;

pci_nu_rep= 'exp_pci_var_nu';
mkdir(pci_nu_rep);

%%
for i_ratio = 2:length(missing_ratio_list)
    missing_ratio = missing_ratio_list(i_ratio);
    
    rep_name = fullfile(pci_nu_rep,['pci_var_miss_',num2str(missing_ratio)]);
    mkdir(rep_name);
    
    data = load(['exp_data_random_mask/realisation_31/random_holes/random_mask_',num2str(missing_ratio),'.mat']);
    
    fprintf("coucou,je viens de prendre les donnees avec %.f pourcents de phase manquantes :\n\n",missing_ratio*100)
    
    mask =  data.mask;
    mask_vec = mask(:);
    b = data.b;
    
    n_iter = n_iter_list(i_ratio);
    
    for i_nu  = 1 : length(nus)
        
       
        nu = nus(i_nu);
        fprintf("nu = %e\n\n",nu)
        
        
        %%
        tracker = PhasecutTracker(x_ref,b, idgt);
      
        t0 = cputime;
        x_pci = phasecut_inpainting(mask, b, G, idgt, n_iter, nu, verbose_it, tracker);
        runtime = cputime-t0;
        
        
        %%
        error_pci= compute_error(x_ref, x_pci);
        disp(error_pci)
        
        
        saveName = ['pci_miss_ratio_', num2str(missing_ratio),'_nu_',num2str(nu),'.mat'];
        save(fullfile(rep_name, saveName),'x_pci', 'nu','n_iter',...,
            'runtime', 'error_pci','tracker');
    end
    
end
