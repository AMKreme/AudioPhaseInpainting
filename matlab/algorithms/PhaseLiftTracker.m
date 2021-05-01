classdef PhaseLiftTracker <handle
    % Class for tracking PhaseLift for phase inpainting (PLI) convergence
    
    properties
        error 
        x_ref 
       
    end
    
    methods
        function obj = PhaseLiftTracker(x_ref)
            obj.x_ref = x_ref;
            %obj.istft = istft;
            obj.error =[];
            %obj.iter =[];
        end
        
        function update(obj,X)
            %obj.iter = [obj.iter,k];
            x_est=phaselift_signal_reconstruction(X);
            err = compute_error(obj.x_ref, x_est);
            obj.error =[obj.error, err];
            
        end
    end
end

