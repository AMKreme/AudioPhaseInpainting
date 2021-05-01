function Z_i= fast_applyM_ic_i(Y,c,G,i)
% G = A*pinv(A);
% Used in phasecut_bcd algorithm
 if  ~isreal(c)  
       error('Not implemented with complex values for C %s', upper(mfilename));
 end
    %dbstack;
    %Z = conj(Y);
    Z = conj(Y);
    Z(:, i) = 0 ; % warning: do not modify the original Y[i, i] inplace!
    %G = A*pinv(A);

    for j=1:size(Z,1) 

        
        Z(j, :) = Z(j, :) - reshape(G*(reshape((c.*reshape(Z(j, :),size(c))),numel(Z(j,:)),1)),1,numel(Z(j,:)));
       
    end
    Z = conj(Z).* reshape(c, 1,numel(c));
    Z_i = Z(:, i);
    
end
