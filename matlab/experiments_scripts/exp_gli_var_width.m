clc; clear; close all;

%% GLI large trous
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%%

missing_ratio =0.3; % pourcentage de donnees manquantes
n_iter=2000; %nombre d'iterations
widths = 1:9;

%parcours des repertoires

folder_name = 'exp_data_large_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for k= 1 : numel(sub_folders)
    f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
    
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    l= numel(files);
    F  = fullfile(folder_name, sub_folders{k},files{l});
    
    gli_dir =  fullfile(F,'gli_results');
    mkdir(gli_dir)
    
    fprintf("coucou, je suis à la réalisation numero: %.f\n\n",k)
    
    for i_width =1:length(widths)
        
        width =widths(i_width);
        fprintf("la largeur du masque est : %.f\n",width)
        
        data = load([F,'/large_mask_width_',num2str(width),'.mat']); % charger les donnees
        tracker = GLTracker(data.x_ref, data.idgt); % tracker l'erreur au files des itérations
        
        mask = data.mask;
        b = data.b;
        x_ref = data.x_ref;
        
        t0 = cputime;
        verbose_it=100;
        x_gli= griffin_lim_inpainting(mask, data.b,data.dgt,data.idgt, ...,
            n_iter,verbose_it,tracker);
        runtime= cputime-t0;
        
        
        saveName = ['gli_width_', num2str(width),'.mat'];
        save(fullfile(gli_dir, saveName),'x_gli','n_iter',...,
            'runtime', 'tracker','mask','b','x_ref',...,
            'widths');
        
    end
end
%%


