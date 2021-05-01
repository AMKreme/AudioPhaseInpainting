function x= phasecut_signal_reconstruction(U, b, istft)
%% x= phasecut_signal_reconstruction(U, b, istft)
% see thesis 


%%
[eig_vec, eig_val] = eigs(U,1);
u = sqrt(eig_val).* eig_vec;
u = exp(1i*angle(u));
x= istft(abs(b).*reshape(u,size(b)));


end

