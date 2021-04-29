clc; clear; close all;

%% PCI en faisant varier le pourcentage de données manquantes
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%% PCI parameters
%%
gab_mat = load('matrix_gabor_atom.mat');
A = gab_mat.A;
dgt= gab_mat.data.dgt;
idgt = gab_mat.data.idgt;
x_ref = gab_mat.data.x_ref;
G = A*pinv(A,1e-10);

missing_ratios = 0:0.1:1;
n_iter = 60000 ;

nu=1e-14;

verbose_it=1000;

%%

folder_name = 'exp_data_random_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for k= 1 : numel(sub_folders)
    f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
    
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    l= numel(files);
    F  = fullfile(folder_name, sub_folders{k},files{l});
    gli_dir =  fullfile(F,'pci_results');
    mkdir(gli_dir)
    
    fprintf("coucou, je suis à la réalisation numero: %.f\n\n",k)
    for i_ratio =1:length(missing_ratios)
        
        ratio =missing_ratios(i_ratio);
        data = load([F,'/random_mask_',num2str(ratio),'.mat']);
         fprintf("le pourcentage de phases manquantes est : %f\n",ratio)
        
        mask = data.mask;
        b = data.b;
        x_ref = data.x_ref;
        
        tracker = PhasecutTracker(x_ref,b, idgt);
        
        
        t0 = cputime;
        %verbose_it=100;
        x_pci = phasecut_inpainting(mask,b,G,idgt, n_iter,nu, verbose_it, tracker);
        runtime = cputime-t0;
        
        
        saveName = ['pci_', num2str(ratio),'.mat'];
        save(fullfile(gli_dir, saveName),'x_pci', 'nu',...,
            'runtime','mask','b','x_ref','n_iter',...,
            'tracker');
        
    end
end

%%


