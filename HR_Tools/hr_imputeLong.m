function [xout, tout] = hr_imputeLong(x,t,iout,dmax)
% Inputs
% x    - input sequence
% t    - sample times for x
% iout - index to outliers 
% dmax = upper limit on the length of acceptable rr interval, 
% typically dmax = 2*stdx + mu; but in the future it should be related to
% the robust SD estimate in a short window preceeding the interval of
% analysis
idone = [];
xout = x;
for i=1:length(iout)   % i = iout(
    k = 0;
    if isempty(find(iout(i)==idone))   % iout(i) has not yet been imputed
        ii = (iout(i)-k):(iout(i)+k);  % ii = iout(i)
        % Increase range of events (i-k : i+k) so that the average is acceptable, 
        % i.e. sum x(ii)/length(ii) <= dmax
        while(sum(x(ii)) > dmax*length(ii)) 
            k = k + 1;
            ii = (iout(i)-k):(iout(i)+k);
        end
        ip = find(x(ii) > dmax); % Find those x that exceed dmax 
        dp = sum(x(ii(ip)) - dmax)/length(ip);  % dp is the avg of the excess 
        xout(ii(ip)) = x(ii(ip)) - dp;   % Subtract the avg eccess from them
    
        ip = find(x(ii) <= dmax);  % Find those x that are smaller than dmax 
        dp = sum(x(ii(ip)) - dmax)/length(ip); % dp is the NEGATIVE avg of the deficiency
        xout(ii(ip)) = x(ii(ip)) - dp;  % add this (-(-abs(dp))
        
        % figure, plot(xout), hold on, plot(iout, xout(iout),'*r')
        % plot(xout)
        % Add to the list of imputed outliers
        idone = [idone ii];
    end
end
% pdate tout
tout = cumsum(xout)/(1000*24*3600) + t(1);

% To test
% sig = 1;
% mu = 1;
% x = normrnd(mu,sig,1,10)
% x(x < .5) = 0.5;
% t = cumsum(x);
% plot(t,x), hold on
% dmax = mu + 2*sig;
% t = cumsum(x);
% iout = find(x > 3);
%  Run the imputation
% tout = cumsum(xout);
% plot(xout)
 