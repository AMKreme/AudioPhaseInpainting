%%  
clc; clear; %close all;
%% Resultats obtenus par PLI
%% Resultats : situation 1
missing_ratios = 0.0:0.1:1;
rep_name = 'moyenne_resultats';
%charger les resultats moyenns sur 40 realisations pour chaque pourcentage
%
data_pli_var_miss = load('resulats_final_var_miss_ratio/average_results_pli.mat'); 

%% erreur, ecart type et temps moyens sur les 40 realisations

mean_error_pli_var_miss_ratio = data_pli_var_miss.mean_pli_var_miss_ratio;
std_error_pli_var_miss_ratio = data_pli_var_miss.std_pli_var_miss_ratio;
mean_runtime_pli_var_miss_ratio = data_pli_var_miss.runtime_pli_var_miss_ratio;
mean_pli_approx_var_miss_ratio  = data_pli_var_miss.mean_pli_approx_var_miss_ratio;


%% Affichage des resultats

% erreur moyenne de reconstruction
figure;

%plot(missing_ratios*100,mean_error_pli_var_miss_ratio,'LineWidth',2)
hold on;

errorbar(missing_ratios*100,mean_error_pli_var_miss_ratio, std_error_pli_var_miss_ratio,'LineWidth',3)
grid on;

xlabel('Pourcentage de phases manquantes (%)');
ylabel('Erreur\_{dB}')
set(gca, 'FontSize', 20, 'fontName','Times');

%% erruer de projection
figure; 
semilogy(missing_ratios*100,20*log10(mean_pli_approx_var_miss_ratio),'LineWidth',3)
grid on;

xlabel('Pourcentage de phases manquantes (%)');
ylabel('Erreur\_{app} (dB)','interpreter','latex')
set(gca, 'FontSize', 20, 'fontName','Times');


%% Resultats pour 30 pourcents de phases manquantes avec des trous large 
%% situation 2
%
widths = 1:9;
data_pli_var_width = load('resulats_final_var_width/average_results_pli.mat');
mean_error_pli_var_width = data_pli_var_width.mean_pli_var_width;
std_error_pli_var_width = data_pli_var_width.std_pli_var_width;% pas bon
mean_runtime_pli_var_width = data_pli_var_width.runtime_pli_var_width;
mean_pli_approx_var_width = data_pli_var_width.mean_pli_approx_var_width;


%% Affichage des resultats

% erreur moyenne
figure;

%plot(widths,mean_error_pli_var_width,'LineWidth',2)
%hold on;

errorbar(widths,mean_error_pli_var_width, std_error_pli_var_width,'LineWidth',3)
grid on;

xlabel('Largeur des zones masquées');
ylabel('Erreur\_{dB}')
set(gca, 'FontSize', 20, 'fontName','Times');


%% Erreur  projection 

figure; 
semilogy(widths ,mean_pli_approx_var_width)
grid on;

xlabel('Pourcentage de phases manquantes (%)');
ylabel('$\frac{\|X - xx^{\ast}\|_F}{\|X\|_F}$','interpreter','latex')
set(gca, 'FontSize', 20, 'fontName','Times');



%% Affichage des temps de cacluls

figure; 
plot(missing_ratios*100, mean_runtime_pli_var_miss_ratio);
figure;
plot(widths,mean_runtime_pli_var_width)
%legend('time-var-miss','time-var-width');

%%
figure
histogram(mean_runtime_pli_var_miss_ratio,5);

figure; 
histogram(mean_runtime_pli_var_width,5)
%%
save(fullfile(rep_name,'pli_res_final_moy.mat'), 'mean_error_pli_var_miss_ratio','std_error_pli_var_miss_ratio',...,
    'mean_error_pli_var_width','std_error_pli_var_width',...,
    'mean_runtime_pli_var_width','mean_runtime_pli_var_miss_ratio');


