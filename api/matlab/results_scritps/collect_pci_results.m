clc; clear;close all;
%%
missing_ratios = 0.0:0.1:1;
n_iter_pci = 60000;
%%

path_results = 'results_var_miss_ratio';
mkdir(path_results)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

%% resulats pour les masques aléatoires

folder_name = 'exp_data_random_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

collects_time_pci = zeros(40, length(missing_ratios));

for ii= 2: length(missing_ratios)
    ii_ratio = missing_ratios(ii);
    
    collects_error_pci  = zeros(40, n_iter_pci); 
    
    
    rep_name = fullfile(fullfile(path_results,['results_',num2str(ii_ratio)]));
    mkdir(rep_name);
    
    for k= 1 : 5%numel(sub_folders)
    
    f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
    f1 = f1(~startsWith({f1.name}, '.'));
    files = {f1.name};
    l=numel(files); 
    F  = fullfile(folder_name, sub_folders{k}, files{l},'pci_results');
    data = load([F,'/pci_',num2str(ii_ratio),'.mat']);
    
   
    collects_error_pci(k,:) = data.tracker.error;
    collects_time_pci(k,ii) = data.runtime;
    
    end
    save(fullfile(rep_name, 'collect_pci_results.mat'),...,
    'collects_error_pci','collects_time_pci');

end


%% Calcule des moyennes et des ecart-types pour chaque pourcentage en 
% fonction du nombre d'itérattions au cours des 40 rélaisations.

mean_pci_var_miss_ratio = zeros(length(missing_ratios),n_iter_pci);
std_pci_var_miss_ratio = zeros(length(missing_ratios),n_iter_pci);

for i_ratio = 2:length(missing_ratios)
    miss = missing_ratios(i_ratio);
    data_c= load([path_results,'/results_', num2str(miss),'/collect_pci_results.mat']);
    mean_pci_var_miss_ratio(i_ratio,:) = mean(data_c.collects_error_pci,1);
    std_pci_var_miss_ratio(i_ratio,:) = std(data_c.collects_error_pci,0,1);
end

%% calcul des temps de calcul et sauvegarde de tous les résulats

data1 = load([path_results,'/results_1/collect_pci_results.mat']);
runtime_pci_var_miss_ratio = mean(data1.collects_time_pci,1);

rep_res = 'resulats_final_var_miss_ratio';
mkdir(rep_res);

resulats_final = 'average_results_pci.mat';
save(fullfile(rep_res,resulats_final), 'mean_pci_var_miss_ratio',...,
    'std_pci_var_miss_ratio','runtime_pci_var_miss_ratio');

%% resulats pour les masques large

%
path_results_large = 'results_var_width';

widths = 1:9;
collects_time_pci_large = zeros(40,length(widths));

folder_name = 'exp_data_large_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for i_width = 1 :length(widths)
    width = widths(i_width);
    
    collects_error_pci_large  = zeros(40, n_iter_pci);
    
    rep_name_large = fullfile(fullfile(path_results_large,['results_',num2str(width)]));
    mkdir(rep_name_large);
    for kk= 1 : numel(sub_folders)
        f1 = dir(fullfile(folder_name,sub_folders{kk},'*'));
        
        f1 = f1(~startsWith({f1.name}, '.'));
        files = {f1.name};
        ll= numel(files);
        F  = fullfile(folder_name, sub_folders{kk}, files{ll},'pci_results');
        
        data_large = load([F,'/pci_width_', num2str(width),'.mat']);
        
        collects_error_pci_large(kk,:) = data_large.tracker.error;
        collects_time_pci_large(kk,i_width) = data_large.runtime;
    end
    save(fullfile(rep_name_large, 'collect_pci_large_results.mat'),...,
        'collects_error_pci_large','collects_time_pci_large');
     
    
end



%% calculer les moyennes et les ecart-types et les stocker :large trous
% chaque point est une moyennes de 40 realisations


mean_pci_var_width = zeros(length(widths),n_iter_pci);
std_pci_var_width = zeros(length(widths),n_iter_pci);

for k_width = 1:length(widths)
    wd = widths(k_width);
    data_l= load([path_results_large,'/results_', num2str(wd),'/collect_pci_large_results.mat']);
    mean_pci_var_width(k_width,:) = mean(data_l.collects_error_pci_large,1);
    std_pci_var_width(k_width,:) = std(data_l.collects_error_pci_large,0,1);
end

%%

%% calcul des temps de calcul
data2 = load([path_results_large,'/results_9/collect_pci_large_results.mat']);
runtime_pci_var_width = mean(data2.collects_time_pci_large,1);

rep_res = 'resulats_final_var_width';
mkdir(rep_res);

resulats_f = 'average_results_pci.mat';
save(fullfile(rep_res,resulats_f), 'mean_pci_var_width',...,
    'std_pci_var_width','runtime_pci_var_width');


%%
