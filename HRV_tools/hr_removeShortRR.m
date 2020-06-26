function [xin, tin] = hr_removeShortRR(xin, tin, iout)
% hr_remove_shortRR removes all data points that are identified in iout and
% adds the value to the subsequent beat
% xin, tin 
irm = zeros(1,length(xin));         %  Indicator for data to be removed
k = 0;
while k < length(iout)
    k = k + 1;                      %disp(k)
    if iout(k) == length(xin)    % At the end of the array
        irm(iout(k)) = 1;           % Mark data points to be removed
        %xinclean = xinclean(1:(end-1));  % Remove the last short sample
    else                          % Combining short intervals with the subsequent one
        xin(iout(k)+ 1) =  xin(iout(k)+ 1) + xin(iout(k));
        irm(iout(k)) = 1;   % If only a single short
    end
end
xin = xin(not(irm));  % figure; plot(xinclean)
tin = tin(not(irm));  