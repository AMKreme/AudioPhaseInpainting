clc; clear; close all;

%%
 disp("generate all data set")
 
 script_generate_all_experiment_data;
%%
disp("all experiments - situation 1")
%disp("\n\n")

disp("GLI experiment")
exp_gli_var_miss_ratio;
disp("PCI experiment")
exp_pci_var_miss_ratio;
disp("PLI experiment")
exp_pli_var_miss_ratio;

disp("all experiments - situation 2")
disp()
disp("GLI experiment")
exp_gli_var_width;
disp("PCI experiment")
exp_pci_var_width;
disp("PLI experiment")
exp_pci_var_width;