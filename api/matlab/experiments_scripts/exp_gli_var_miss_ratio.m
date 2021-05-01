clc; clear; close all;

%% GLI en faisant varier le pourcentage de données manquantes
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%%

missing_ratios =0:0.1:1; % pourcentage de donnees manquantes
n_iter=2000; %nombre d'iterations


% parcours des sous-repertoires et excetution de gli

folder_name = 'exp_data_random_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for k_subfold= 1 : numel(sub_folders)
    f1 = dir(fullfile(folder_name,sub_folders{k_subfold},'*'));
    
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    l = numel(files);
    F  = fullfile(folder_name, sub_folders{k_subfold},files{l});
    
    gli_dir =  fullfile(F,'gli_results');
    mkdir(gli_dir)
    
    fprintf("coucou, je suis à la réalisation numero: %.f\n\n",k_subfold)
    
    for i_ratio =1:length(missing_ratios)
        ratio =missing_ratios(i_ratio);
        fprintf("le pourcentage de phases manquantes est : %f\n",ratio)
        
        data = load([F,'/random_mask_',num2str(ratio),'.mat']); % charger les donnees
        
        tracker = GLTracker(data.x_ref, data.idgt); % tracker l'erreur en fonction des iterations
        
        mask = data.mask;
        b = data.b;
        x_ref = data.x_ref;
        
        t0=  cputime;
        verbose_it=100;
        x_gli= griffin_lim_inpainting(mask, data.b,data.dgt,data.idgt, ...,
            n_iter,verbose_it,tracker);
        runtime = cputime - t0;
              
        saveName = ['gli_',num2str(ratio),'.mat'];
        save(fullfile(gli_dir, saveName),'x_gli','n_iter',...,
            'runtime','mask','b','x_ref',...,
            'missing_ratios','tracker');
        
    end
end



