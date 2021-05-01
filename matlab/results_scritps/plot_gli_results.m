%%  
clc; clear; %close all;
%% Resultats obtenus par GLI
%% Resultats : situation 1
missing_ratios = 0.0:0.1:1;
%charger les resultats moyennes sur 40 realisations pour chaque pourcentage
%de phases manquantes (11 \times 2001)
data_gli_var_miss = load('resulats_final_var_miss_ratio/average_results_gli.mat'); 
rep_name = 'moyenne_resultats';
mkdir(rep_name);
%%

mean_error_gli_var_miss_ratio = data_gli_var_miss.mean_gli_var_miss_ratio;
std_error_gli_var_miss_ratio = data_gli_var_miss.std_gli_var_miss_ratio;
mean_runtime_gli_var_miss_ratio = data_gli_var_miss.runtime_gli_var_miss_ratio;

%%  erreur moyenne :  recuperation de la dernière colonne

m_error_gli_var_miss_ratio = mean_error_gli_var_miss_ratio(:,end);
s_error_gli_var_miss_ratio  = std_error_gli_var_miss_ratio(:,end);

%% Affichage des resultats

% erreur moyenne
figure;

%plot(missing_ratios*100,m_error_gli_var_miss_ratio,'LineWidth',3)
%hold on;

errorbar(missing_ratios*100,m_error_gli_var_miss_ratio, s_error_gli_var_miss_ratio,'LineWidth',3)
grid on;

xlabel('Pourcentage de phases manquantes (%)');
ylabel('Erreur\_{dB}')
set(gca, 'FontSize', 20, 'fontName','Times');


%% convergence
figure;

track_iter = 1:2001;
for k =1:length(missing_ratios)
    m_ratio = missing_ratios(k);
    txt = [num2str(m_ratio*100),'% PM'];
    plot(track_iter, mean_error_gli_var_miss_ratio(k,:),'LineWidth',2,'DisplayName',txt)
    hold on;
end

legend show;

grid;
xlabel("Nombre d'itérations");
ylabel('Erreur\_{dB}')
set(gca, 'FontSize', 20, 'fontName','Times');

%% Resultats pour 30 pourcents de phases manquantes avec des trous large 
%% situation 2
% Lz
widths =1:9;

data_gli_var_width = load('resulats_final_var_width/average_results_gli.mat');
mean_error_gli_var_width = data_gli_var_width.mean_gli_var_width;
std_error_gli_var_width = data_gli_var_width.std_gli_var_width;
mean_runtime_gli_var_width = data_gli_var_width.runtime_gli_var_width;

%%  erreur moyenne a la convergence :recuperation de la dernière colonne
m_error_gli_var_width = mean_error_gli_var_width(:,end);
s_error_gli_var_width  = std_error_gli_var_width (:, end);


%% Affichage des resultats

% erreur moyenne
figure;

%plot(missing_ratios*100,m_error_gli_var_miss_ratio,'LineWidth',3)
%hold on;

errorbar(widths,m_error_gli_var_width, s_error_gli_var_width,'LineWidth',3)
grid on;

xlabel('Largeur des zones masquées');
ylabel('Erreur\_{dB}')
set(gca, 'FontSize', 20, 'fontName','Times');

%% convergence
figure;
for l =1:length(widths)
  i_width = widths(l);
    txt = ['largeur = ' num2str(i_width)];
    plot(track_iter, mean_error_gli_var_width(l,:),'LineWidth',2,'DisplayName',txt)
    hold on;
end
ylim([-350, 50])
legend show;
grid;
xlabel("Nombre d'itérations");
ylabel('Erreur\_{dB}')
set(gca, 'FontSize', 20, 'fontName','Times');


%% Affichage des temps de cacluls

figure; 
plot(mean_runtime_gli_var_miss_ratio);
hold on;
plot(mean_runtime_gli_var_width)
legend('time-var-miss','time-var-width');

%%
figure
histogram(mean_runtime_gli_var_miss_ratio);
hold on;
histogram(mean_runtime_gli_var_width)


save(fullfile(rep_name,'gli_res_final_moy.mat'), 'm_error_gli_var_miss_ratio','s_error_gli_var_miss_ratio',...,
    'm_error_gli_var_width','s_error_gli_var_width',...,
    'mean_runtime_gli_var_width','mean_runtime_gli_var_miss_ratio');
