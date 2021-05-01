clc; clear; close all;
%% Probleme a resoudre : PLI
% min trace(X)
% tq \|A(X) -b\| <=epsilon
% X >=0
% epsilon = 1e-12
warning('off', 'MATLAB:MKDIR:DirectoryExists');
%% On charge la matrice des atomes de Gabor
% generate_gabor_atom_matrix(); % pour la generer si elle n'est pas deja en memoire

gab_mat = load('matrix_gabor_atom.mat');
A = gab_mat.A;

dgt = gab_mat.data.dgt; % operateur DGT
idgt = gab_mat.data.idgt; % operateur IDGT

%% Initialisations
widths = 1:9; % largeur des zones
epsilon = 1e-12; % 1e-12% precision dans cvx


%%

folder_name = 'exp_data_large_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for k= 21 : numel(sub_folders)
    
    error_pli_cvx = zeros(1,length(widths));
    err_approx = zeros(1,length(widths));
    
    f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    
    l= numel(files);
    F  = fullfile(folder_name, sub_folders{k},files{l});
    pli_dir =  fullfile(F,'pli_results');
    mkdir(pli_dir)
    
    fprintf("coucou, je suis à la réalisation numero: %.f\n\n",k)
    for i_width =1:length(widths)
        
        width =widths(i_width);
        data = load([F,'/large_mask_width_',num2str(width),'.mat']); % charger les donnees
        
        fprintf("coucou, donnees avec largeur de trous = %.f :\n\n",width)
        
        
        mask = data.mask;
        b = data.b;
        x_ref = data.x_ref;
        
        obs = observations(b, mask);
        
        tracker = PhaseLiftTracker(x_ref);
        
        fprintf("c'est cvx qui tourne\n");
        
        t0 = cputime;
        [X_pli_cvx, x_pli_cvx]= phaselift_inpainting_cvx(A, mask, obs, epsilon, tracker);
        runtime = cputime - t0;
        
        error_pli_cvx(:,i_width)=tracker.error;
        err_approx(:,i_width) = approx_error(X_pli_cvx, x_pli_cvx);
        
        fprintf("pas mal, j'ai tourné en %f secondes\n\n", runtime)
        
        saveName = ['pli_width_', num2str(width),'.mat'];
        save(fullfile(pli_dir, saveName),'x_pli_cvx','X_pli_cvx',...,
            'runtime', 'error_pli_cvx','mask','b','obs','x_ref',...,
            'width','err_approx','tracker','epsilon');
        
        
        
    end
    
end