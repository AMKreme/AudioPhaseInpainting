function Z_i= applyM_ic_i(Y, c, stft, istft, i)
% Used in phasecut_bcd algorithm

    if  ~isreal(c)  
       error('Not implemented with complex values for C %s', upper(mfilename));
    end

    Z = conj(Y);
    Z(:, i) = 0 ; % warning: do not modify the original Y[i, i] inplace!
    for j=1:size(Z,1) 
        
        Z(j, :) = Z(j, :) - reshape(stft(istft(c.*reshape(Z(j, :),size(c)))),[], numel(Z(j,:)));
        
    end
    Z = conj(Z).* reshape(c, 1,numel(c));
    Z_i = Z(:, i);
    
end
