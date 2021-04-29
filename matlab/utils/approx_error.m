function err = approx_error(X,x)
err = norm(X-x*x','fro')./norm(X,'fro');
end