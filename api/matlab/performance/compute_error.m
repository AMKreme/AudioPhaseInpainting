function err = compute_error(x_ref, x_est)

    x_est = fix_global_phase(x_ref, x_est);
  
    err= 20*log10(norm(x_ref-x_est,2)./norm(x_ref,2));
    
end


