function  A = generate_gabor_atom_matrix()
%This function generates the matrix of Gabor atoms for the experiments 
% described in chapter 4

data = load(['random_mask_',num2str(0),'.mat']);  % load data without missing phases

dgt = data.dgt;
x_tf = dgt(data.x_ref);

sig_len = data.signal_params.sig_len;

x_ref = data.x_ref;
b = data.b;
b_vec = b(:);
%%

vec = @(x) x(:);

nb_atoms_gabor = numel(x_tf);
A = zeros(nb_atoms_gabor,sig_len);
I = eye(sig_len);
for ii=1:sig_len
    
    A(:,ii) =vec(dgt(I(ii,:)));
end


%% 
diff = norm(A*x_ref - b_vec);
fprintf("On verifie que l'on a la bonne matrice \n")
fprintf("norm(A*x_ref - b): %e \n",diff);

save('matrix_gabor_atom.mat','A','data')

end