classdef PhasecutTracker <handle
    % Class for tracking PhaseCut for phase inpainting (PCI) convergence
     properties
        error 
        iter 
        x_ref 
        istft;
        b 
     end
    
        
     methods
        
        function obj = PhasecutTracker(x_ref, b, istft)
            obj.x_ref = x_ref;
            obj.istft = istft;
            obj.b=b;
            obj.error =[];
            obj.iter =[];
        end
        
        function update(obj,U,i)
            obj.iter = [obj.iter,i];
            x_est = phasecut_signal_reconstruction(U, obj.b, obj.istft);
            err = compute_error(obj.x_ref, x_est);
            obj.error = [obj.error,err];
            
        end
    end

end