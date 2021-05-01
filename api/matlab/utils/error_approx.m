function err =  error_approx(X_est, X_ref)
err = 20*log10((norm(X_est-X_ref, 'fro'))./(norm(X_ref)));
end