function U = fast_phasecut_bcd(mask, b,G, n_iter, nu, verbose_it, tracker)    
%% phasecut_bcd(mask, b, stft, istft, n_iter, nu, verbose_it, tracker)  
% Block Coordinate Descent algorithm for phasecut. See [Waldburger et al. 2015 (PhaseCut)]
%    Inputs : 
%    G = A*pinv(A)
%     - mask : boolean nd-array [F,T]
%     - b : complex nd-array [F,T]
%     - stft : DGT operator (handle function)
%     - istft : inverse DGT operator (handle function)
%     - niter : integer
%     - nu : real
% 
%     Outputs
%     
%     - U : complex nd-array [FT, FT]
%%    
% 
if nargin==4
    nu=1e-4;
    verbose_it=1000;
    tracker=[];
end


    mvec = mask(:);
    nbmeas = length(mvec);
    C = abs(b);
    U = complex(eye(nbmeas));
    um = exp(1i*angle(b(mask)));
   
    U(mvec,mvec) =um.*um';
  
    [ind_unknown,~] = find(~mvec);
    
    %%
    
    if isempty(ind_unknown)
        n_iter = 0;
    end
    
    ic = boolean(ones(nbmeas,1));
    for i_iter =1: n_iter
        if mod(i_iter, verbose_it)==0
            fprintf('Iteration %.f\n', i_iter);
        end
        i = randsample(ind_unknown,1); 
        
        ic(:) = 1;
        ic(i) = 0;
       x= fast_applyM_ic_i(U,C,G,i);
        %x = applyM_ic_i(U, C, stft, istft, i);
      
        gamma = fast_applyM_ic_i(transpose(conj(x)), C,G, i);
       
        x = x(ic);

        if gamma > 0
            U(ic, i) = -sqrt((1-nu)/gamma)*x;
            U(i, ic) = conj(U(ic, i));
        else
            U(ic, i) = 0;
            U(i, ic) = 0;
        end
        if ~isempty(tracker) 
            tracker.update(U, i_iter)
        end
    end
end
  
