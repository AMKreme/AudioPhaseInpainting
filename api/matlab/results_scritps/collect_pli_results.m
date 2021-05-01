clc; clear;close all;
%% collextions des resultats obtenus sur les 40 realisations dans la
% situation 1 et 2


%%  Resulats : situation 1
missing_ratios = 0:0.1:1;
path_results = 'results_var_miss_ratio';

warning('off', 'MATLAB:MKDIR:DirectoryExists');
%%  resulats pour les masques aléatoires

collects_time_pli = zeros(40,length(missing_ratios)); % 40 tps de calcul pour chaque pourcentage
collects_approx_err_var_miss = zeros(40,length(missing_ratios));
collects_error_pli_var_miss = zeros(40,length(missing_ratios));

folder_name = 'exp_data_random_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for ii = 1:length(missing_ratios)
    
    ii_ratio = missing_ratios(ii);
    
    rep_name = fullfile(fullfile(path_results,['results_',num2str(ii_ratio)]));
    mkdir(rep_name);
    
    for k= 1 : numel(sub_folders)
        f1 = dir(fullfile(folder_name,sub_folders{k},'*'));
        
        f1 = f1(~startsWith({f1.name}, '.'));
        files = {f1.name};
        l= numel(files);
        F  = fullfile(folder_name, sub_folders{k}, files{l},'pli_results');
       
        data = load([F,'/pli_', num2str(ii_ratio),'.mat']);
        
        %collects_error_pli(k,:) = data.tracker.error;
        collects_time_pli(k,ii) = data.runtime;
       
        % collecttions des  erreurs de reconstrcutions
        collects_error_pli_var_miss(k,ii) =data.error_pli_cvx(ii); 
        
        % collections des erreurs de projections : ecart-young
        collects_approx_err_var_miss(k,ii) = data.err_approx(ii);
        
    end
    save(fullfile(rep_name, 'collect_pli_results.mat'),...,
        'collects_error_pli_var_miss','collects_time_pli',...,
        'collects_approx_err_var_miss');
end

%% Calcule des moyennes, des ecart-types, temps de calcul pour chaque pourcentage  
% 
data_c = load([path_results,'/results_1/collect_pli_results.mat']);
all_realisation_error_per_ratio = data_c.collects_error_pli_var_miss;

mean_pli_var_miss_ratio = mean(all_realisation_error_per_ratio,1); %moyenne
std_pli_var_miss_ratio = std(all_realisation_error_per_ratio,0,1);%std
runtime_pli_var_miss_ratio = mean(data_c.collects_time_pli); %runtime
mean_pli_approx_var_miss_ratio = mean(data_c.collects_approx_err_var_miss,1);%moyenne EY


rep_res = 'resulats_final_var_miss_ratio';
mkdir(rep_res);

resulats_final = 'average_results_pli.mat';
save(fullfile(rep_res,resulats_final), 'all_realisation_error_per_ratio',...,
    'mean_pli_var_miss_ratio', 'std_pli_var_miss_ratio',...,
    'runtime_pli_var_miss_ratio','mean_pli_approx_var_miss_ratio');
    
%% resulats pour les masques large

%
path_results_large = 'results_var_width';

widths = 1:9;
collects_time_pli_large = zeros(40,length(widths));
collects_approx_err_var_width = zeros(40,length(widths));
collects_error_pli_large  = zeros(40, length(widths));
%%
folder_name = 'exp_data_large_mask';
all_dir = dir(fullfile(folder_name,'*'));
sub_folders = setdiff({all_dir([all_dir.isdir]).name},{'.','..'});

for i_width = 1 : length(widths)
    width = widths(i_width);
       
    rep_name_large = fullfile(fullfile(path_results_large,['results_',num2str(width)]));
    mkdir(rep_name_large);
    
    for kk= 1 : numel(sub_folders)
        f1 = dir(fullfile(folder_name,sub_folders{kk},'*'));
        
        f1 = f1(~startsWith({f1.name}, '.'));
        files = {f1.name};
        ll= numel(files);
        F  = fullfile(folder_name, sub_folders{kk}, files{ll},'pli_results');
        
        data_large = load([F,'/pli_width_', num2str(width),'.mat']);
        
        collects_error_pli_large(kk,i_width) = data_large.error_pli_cvx(i_width);
        collects_time_pli_large(kk,i_width) = data_large.runtime;
        
        collects_approx_err_var_width(kk,i_width) = data_large.err_approx(i_width);
        
    end
    save(fullfile(rep_name_large, 'collect_pli_large_results.mat'),...,
        'collects_error_pli_large','collects_time_pli_large',...,
        'collects_approx_err_var_width');
         
end

%% calculer les moyennes et les ecart-types, temps de calculs:large trous

data_l= load([path_results_large,'/results_9/collect_pli_large_results.mat']);
all_realisation_error_var_width = data_l.collects_error_pli_large;

mean_pli_var_width = mean(all_realisation_error_var_width,1);
std_pli_var_width= std(all_realisation_error_var_width,0,1);
runtime_pli_var_width = mean(data_l.collects_time_pli_large,1);
mean_pli_approx_var_width = mean(data_l.collects_approx_err_var_width,1);%moyenne EY


rep_res = 'resulats_final_var_width';
mkdir(rep_res);

resulats_f = 'average_results_pli.mat';
save(fullfile(rep_res,resulats_f), 'all_realisation_error_var_width',...,
    'mean_pli_var_width','std_pli_var_width','runtime_pli_var_width',...,
    'mean_pli_approx_var_width');


%%

