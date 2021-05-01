classdef GLTracker <handle
    %Class for tracking convergence of Griffin and Lim for Phase
    %Inpainting (GLI) algorithm
    
    properties
        error
        iter
        x_ref
        istft
        
    end
    
    methods
        %constructor
        function obj = GLTracker(x_ref, istft)
            obj.iter = [];
            obj.error = [];
            obj.x_ref = x_ref;
            obj.istft = istft;
            
        end
        %update function
        function update(obj,X,k)
            obj.iter = [obj.iter,k];
            x_est = obj.istft(X);
            err = compute_error(obj.x_ref, x_est);
            obj.error =[obj.error, err];
            
        end
    end
end


