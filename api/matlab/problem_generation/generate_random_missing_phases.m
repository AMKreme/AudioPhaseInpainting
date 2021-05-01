function [B, M] = generate_random_missing_phases(X, missing_ratio, width)


%     Parameters
%     ----------
%     X : nd-array, complex
%         Array to be masked
%     missing_ratio : float
%         Ratio of missing phases, in [0, 1]
%     width : int
%         width of the holes
%
%     Returns
%     -------
%     B : nd-array
%         Modified array, with same shape as X, with B[M]=X[M] unchanged and
%         B[~M] = abs(X[~M])
%     M : nd-array, bool
%         Mask, as an array with same shape as X, with False values for masked
%         phases and True values for unchanged coefficients

if nargin==2
    width=2;
end

nb_miss = round(missing_ratio*numel(X));
M0 = zeros(size(X));
ind_miss = randperm(numel(M0),nb_miss);

M0_flat =reshape(M0,1,numel(M0));
M0_flat(ind_miss) = (1:nb_miss)+nb_miss;
M0 = reshape(M0_flat,size(X));

for i = 1: (width - 1)/2
    se = [[0, 1, 0]; [1, 1, 1]; [0, 1, 0]];
    M0 = imdilate(M0, se);
end

M0_flat = reshape(M0,1,numel(M0));
[~,ind_sort] = sort(M0_flat);

M0_flat(ind_sort(1:end-nb_miss)) = 0;
M0 = reshape(M0_flat,size(X));
M = boolean(ones(size(X)));
M(M0~=0) = false;

B = X;
B(~M) = abs(B(~M));

end