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
missing_ratios = 0:0.1:1; % phases manquantes
epsilon = 1e-12; % 1e-12% precision dans cvx

%%

folder_name = 'exp_data_random_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for k= 1:numel(sub_folders)
    
    error_pli_cvx = zeros(1,length(missing_ratios));
    err_approx = zeros(1,length(missing_ratios));
    
    f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
    
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    l=numel(files);
    
    F  = fullfile(folder_name, sub_folders{k},files{l});
    pli_dir =  fullfile(F,'pli_results');
    mkdir(pli_dir)
    
    fprintf("coucou, je suis à la réalisation numero: %.f\n\n",k)
    
    for i_ratio = 1:length(missing_ratios)
        
        missing_ratio = missing_ratios(i_ratio);
        
        data = load([F,'/random_mask_',num2str(missing_ratio),'.mat']);
        
        fprintf("coucou,je viens de prendre les donnees avec %.f pourcents de phase manquantes :\n\n",missing_ratio*100)
        
        mask =  data.mask;
        b = data.b;
        n = data.signal_params.sig_len;
        x_ref = data.x_ref;
        
        % Les observations
        
        obs = observations(b, mask);
        
        %% resolution de PLI avec cvx
        fprintf("c'est cvx qui tourne\n");
        
        tracker = PhaseLiftTracker(x_ref);
        t0=  cputime;
        [X_pli_cvx,x_pli_cvx] = phaselift_inpainting_cvx(A, mask, obs, epsilon, tracker);
        runtime = cputime - t0;
        error_pli_cvx(:,i_ratio)=tracker.error;
        err_approx(:,i_ratio) = approx_error(X_pli_cvx, x_pli_cvx);
        
        fprintf("pas mal, j'ai tourné en %f secondes\n\n",runtime)
        %%
        
        save_name = ['pli_',num2str(missing_ratio),'.mat'];
        save(fullfile(pli_dir,save_name),'x_pli_cvx',...,
            'data','x_ref','runtime','epsilon','missing_ratios',...,
            'tracker','obs','error_pli_cvx','X_pli_cvx','err_approx');
        
    end
end

