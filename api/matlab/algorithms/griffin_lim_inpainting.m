function  x= griffin_lim_inpainting(mask, b,stft,istft, n_iter, verbose_it,tracker)
%% x= griffin_lim_inpainting(mask, b,stft,istft, n_iter, verbose_it,tracker)
% Griffin and Lim for phase inpainting algorithm proposed in [1].
%
%   Inputs
%       - mask : boolean nd-array [F,T]
%       - b : complex nd-array [F,T]
%       - stft :  discrete Gabor transform (handle function)
%       - istft : inverse discrete Gabor transform (handle function)
%       - n_iter : number of iterations
%       - tracker: used  for checking convergence
% Output
%      - x : reconstructed signal
%
% Reference
%   [1] Phase reconstruction for time-frequency inpainting, 2018.
%%
if nargin <=5
    
    tracker=[];
end


X = b;
X(~mask)=X(~mask).*exp(1j*2*pi*rand(sum(~mask(:)),1));
C = abs(b(~mask));

for k =1:n_iter
    if ~isempty(tracker)
        tracker.update(X,k);
    end
    X(:,:) = stft(istft(X));
    X(mask) = b(mask);
    X(~mask) = C.*exp(1j*angle(X(~mask)));
end

if ~isempty(tracker)
    tracker.update(X, n_iter)
end
x = istft(X);

end


%% version 1
% X = b;
% X(~mask)=X(~mask).*exp(1j*2*pi*rand(sum(~mask(:)),1));
% C = abs(b(~mask));
% 
% for k =1:n_iter
%     if ~isempty(tracker)
%         tracker.update(X,k);
%     end
%     X(:,:) = stft(istft(X));
%     X(mask) = b(mask);
%     X(~mask) = C.*exp(1j*angle(X(~mask)));
% end
% 
% if ~isempty(tracker)
%     tracker.update(X, n_iter)
% end
% x = istft(X);

