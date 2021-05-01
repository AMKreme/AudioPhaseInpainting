clc; clear; close all

%% PCI large trous
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%%
gab_mat = load('matrix_gabor_atom.mat');
A = gab_mat.A;
dgt= gab_mat.data.dgt;
idgt = gab_mat.data.idgt;
x_ref = gab_mat.data.x_ref;
G = A*pinv(A,1e-10);


nu=1e-14;

verbose_it=1000;


%%
missing_ratio =0.3; % pourcentage de donnees manquantes
n_iter=60000; %nombre d'iterations
widths = 1:9;


%%

%parcours des repertoires

folder_name = 'exp_data_large_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});
for k= 2 : numel(sub_folders)
    f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
    
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    l=1:numel(files);
    F  = fullfile(folder_name, sub_folders{k},files{l});
    pci_dir =  fullfile(F,'pci_results');
    mkdir(pci_dir)
    
    fprintf("coucou, je suis à la réalisation numero: %.f\n\n",k)
    for i_width =1:length(widths)
        
        width =widths(i_width);
        data = load([F,'/large_mask_width_',num2str(width),'.mat']); % charger les donnees
        fprintf("la largeur de la zone masquée est : %f\n",width)
        
        mask = data.mask;
        b = data.b;
        x_ref = data.x_ref;
        
        tracker = PhasecutTracker(x_ref,b, data.idgt);
        
        t0 = cputime;
        x_pci = phasecut_inpainting(mask,b,G,idgt, n_iter,nu, verbose_it, tracker);
        runtime = cputime-t0;
        
              
        saveName = ['pci_width_', num2str(width),'.mat'];
        save(fullfile(pci_dir, saveName),'x_pci','n_iter',...,
            'runtime','mask','b','x_ref','widths','tracker');
        
        
        
    end
end



