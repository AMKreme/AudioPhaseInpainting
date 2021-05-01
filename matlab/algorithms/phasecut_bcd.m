function U = phasecut_bcd(mask, b, stft, istft, n_iter, nu, verbose_it, tracker)    
%% phasecut_bcd(mask, b, stft, istft, n_iter, nu, verbose_it, tracker)  
% Block Coordinate Descent algorithm for phasecut. See [Waldburger et al. 2015 (PhaseCut)]
%    Inputs : 
%    
%     - mask : boolean nd-array [F,T]
%     - b : complex nd-array [F,T]
%     - stft :  discrete Gabor transform (handle function)
%     - istft : inverse discrete Gabor transform (handle function)
%     - niter : integer
%     - nu : real
% 
%     Outputs
%     
%     - U : complex nd-array [FT, FT]
%%    

if nargin==5
    nu=1e-4;
    verbose_it=1000;
    tracker=[];
end


    mvec = mask(:);
    nbmeas = length(mvec);
    C = abs(b);
    p = 1+2i;
    U = eye(nbmeas,'like',p);
    %U = complex(eye(nbmeas));
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
       disp(i)
        ic(:) = 1;
        ic(i) = 0;

        x = applyM_ic_i(U, C, stft, istft, i);
      
        gamma = applyM_ic_i(transpose(conj(x)), C, stft, istft, i);
       
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
  
