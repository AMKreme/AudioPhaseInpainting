# AudioPhaseInpainting
Toolbox for phase inpainting in time frequency plane (Code available both in matlab and python). It allows to reconstruct the missing phases of some complex 
coefficients from a short-time Fourier transform (STFT). More precisely, it is about the implementations of the algorithms from the paper 
*Phase reconstruction for time-frequency inpainting,by A.Marina Krémé, Valentin Emiya and Caroline Chaux, 2018.*

For more information please contact ama-marina.kreme@univ-amu.fr/valentin.emiya@lis-lab.fr

#Instruction for Matlab user

## Installation

Download the folder "AudioPhaseInpainting" into the directory of your choice. 
Then within MATLAB go to file >> Set path... and add the directory containing
 "AudioPhaseInpainting/matlab" to the list (if it isn't already). 


## Dependencies

This toolbox requires *The Large Time Frequency Analysis Toolbox (LTFAT)* 
which can be downloaded  at  https://ltfat.github.io   

## About AudioPhaseInpainting
It contains several directories described below:
- algorithms: contains the functions and classes of the GLI, PLI and PCI algorithms
- performances : contains the functions that are used in this thesis to estimate the reconstruction error of our algorithms
- utils : contains all the annex functions necessary to the implementation of our algorithms
- problem_generation : contains the creation of the synthetic signal which was used in our experiments
- experiments_scripts : contains the scripts allowing to perform all the experiments described for each algorithm
- results_scripts : contains the scripts to collect and display the results of all the experiments described for each algorithm
- script_run_all_experiment.m: runs all experiments
- script_plot_all_exp_results.m: displays the results of all experiments

## Usage

See the documentation. 

To reproduce the results of the above mentioned paper, simply run the **script_run_all_experiment.m** and **script_plot_all_exp_results.m**
file located in your current directory. 



## Copyright © 2018-2019

- [Laboratoire d'Informatique et Systèmes](https://www.lis-lab.fr) 
- [Institut de Mathématiques de Marseille](https://www.i2m.univ-amu.fr)
- [Université d'Aix-Marseille](https://www.univ-amu.fr)


## Contributors

- [A. Marina Krémé](ama-marina.kreme@univ-amu.fr)
- [Valentin Emiya](valentin.emiya@lis-lab.fr)



