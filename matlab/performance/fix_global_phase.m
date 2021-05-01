function x_est =fix_global_phase(x_ref, x_est)
 
    phase_diff = angle(sum(conj(x_est).*x_ref));
    x_est = x_est.*exp(1i*phase_diff);
    %x_est =x_est(:);
end




