function mesures = linear_operator_cvx(X, A, mask)

mask_vec = mask(:);
mask_vec = ~ mask_vec;
ind_m = find(mask_vec);
ind_mb = find(~mask_vec);
nb_mesures = length(ind_m) + length(ind_mb)*length(ind_mb);


%%
mesures = cvx(zeros(nb_mesures,1));
%mesures = zeros(nb_mesures,1);

A_om = A(mask_vec,:);
A_ombar = A(~mask_vec,:);


Q1 = cvx(zeros(size(A_om,1),1));
Q2 = cvx(zeros(size(A_ombar,1),size(A_ombar,1)));

%Q1 = zeros(size(A_om,1),1);
%Q2 = zeros(size(A_ombar,1),size(A_ombar,1));

for k = 1:size(A_om,1)
    Q1(k) = trace(A_om(k,:)'*A_om(k,:)*X);
end

for l =1:size(A_ombar,1)-1
    m = l+1;
    Q2(l,m) = trace(A_ombar(l,:)'*A_ombar(m,:)*X);
    Q2(m,l) = trace(A_ombar(m,:)'*A_ombar(l,:)*X);
end

mesures(1:length(Q1),1) = Q1;
mesures(length(Q1)+1:end,1)=Q2(:);


end