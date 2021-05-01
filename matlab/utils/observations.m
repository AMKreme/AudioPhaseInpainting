function [obs,varargout] = observations(b, mask)

%generates the observations corresponding to the experiments described 
%in chapter 4

%%

mask_vec = mask(:);
mask_vec = ~mask_vec;
ind_m = find(mask_vec);
ind_mb = find(~mask_vec);
nb_mesures = length(ind_m) + length(ind_mb)*length(ind_mb);


obs = zeros(nb_mesures,1);
b_vec = b(:);
B = b_vec*b_vec';

b_om =diag(B(mask_vec, mask_vec));
b_ombar = B(~mask_vec, ~mask_vec);

Q1 = zeros(size(b_om,1),1);
Q2 = zeros(size(b_ombar,1),size(b_ombar,1));



for k = 1:size(b_om,1)
    Q1(k) = b_om(k);
end

for l =1:size(b_ombar,1)-1
    m = l+1;
    Q2(l,m) = conj(b_ombar(l,m));
    Q2(m,l) = conj(b_ombar(m,l));
end


obs(1:length(Q1),1) = Q1;

obs(length(Q1)+1:end,1)=Q2(:);
varargout{1} = b_om;
varargout{2} = b_ombar;
end