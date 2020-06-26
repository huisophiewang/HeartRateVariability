function [rout,tout,res,vr,eigf] =hr_ssa(xin,tin,L,grp,plotflag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -----------------------------------------------------------------
%    Authors:
%    Misha Pavel
%    modified the original from
%    Francisco Javier Alonso Sanchez    e-mail:fjas@unex.es
%    Departament of Electronics and Electromecanical Engineering
%    Industrial Engineering School, University of Extremadura, Badajoz, Spain
% -----------------------------------------------------------------L
%
% xin Input time series (column vector form)
% L   Window length
% grp = [i1,i2:ik,...,iL]  the components be used to reconstruct the series
%     isanum < 1   is the proportion of variance in xhat (1.0 complete)
% Output
% xhat  Reconstructed time series
% res  Residual time series r = x1-xhat
% vr Relative value of the norm of the approximated trajectory matrix with respect
%	  to the original trajectory matrix
% eigf Eigenfunctions used in the reconstruction of yhat
%
% The program output is the Singular Spectrum of x1 (must be a column vector),
% using a window length L. You must choose the components be used to reconstruct
%the series in the form [i1,i2:ik,...,iL], based on the Singular Spectrum appearance.
% Approach
% SSA -Singular-spectrum analysis -  generates a trajectory matrix X from
% the original series xin by sliding a window of length L.
% The first step removes the average value of xin that is added back after
% recoonstruction.
% The trajectory matrix is aproximated using Singular Value Decomposition.
% The last step reconstructs the series from the aproximated trajectory
% matrix. The SSA applications include smoothing, filtering, and trend
% extraction. The algorithm used is described in detail in: Golyandina, N.,
% Nekrutkin, V., Zhigljavsky, A., 2001. Analysis of Time Series Structure -
% SSA and Related Techniques. Chapman & Hall/CR.

% Future work should focus on the tradeoff between the dimensionality of
% the group and the threshold on errror between ussing the original and
% smoothed version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('plotflag','var')    plotflag = 0;    end    % To plot 1
% Step1 : Build trajectory matrix

xavg = mean(xin);
xi = xin(:)- xavg;   % enforce xin to be a column vector

N=length(xi);
if L>N/2;L=N-L;end
K=N-L+1;
X=zeros(L,K);
for i=1:K
    X(1:L,i)=xi(i:L+i-1);
end

% Step 2: SVD

S = X*X';
[U,autoval]= eig(S);
[lam,i]= sort(diag(autoval),'descend');
U=U(:,i);   % Sorted eigenfunctions
sev=sum(lam);  % Sum of eig^2
cumev = cumsum(lam)/sev;
if plotflag
    figure; plot((lam./sev)*100), hold on, plot((lam./sev)*100,'rx','LineWidth',3);
    plot(cumsum((lam./sev)*100),'LineWidth',3);
    title('Singular Spectrum');xlabel('Eigenvalue Number');ylabel('% Variance')
end
V=(X')*U;   % projection of X onto the orthogonal eigenfunctions
rc=U*V';   % complete representation of the input

% Step 3: Grouping
% Need to check if grouping is defined
if nargin < 3
    I=input('Choose the agrupation of components to reconstruct the series in the form I=[i1,i2:ik,...,iL]  ')
elseif (length(grp) == 1) & grp < 1   % Grp is proportion of variance
    I = find(cumev <= grp);
else
    I = grp;
end
Vt  = V';
rca = U(:,I)*Vt(I,:);
eigf = U(:,I);  % Eigenfunctions sellected

% Step 4: Reconstruction

xhat  = zeros(N,1);
Lp = min(L,K);
Kp = max(L,K);

for k=0:Lp-2
    for m=1:k+1;
        xhat(k+1) = xhat(k+1)+(1/(k+1))*rca(m,k-m+2);
    end
end

for k=Lp-1:Kp-1
    for m=1:Lp;
        xhat(k+1) = xhat(k+1) + (1/(Lp))*rca(m,k-m+2);
    end
end

for k=Kp:N
    for m=k-Kp+2:N-Kp+1;
        xhat(k+1) = xhat(k+1) + (1/(N-k))*rca(m,k-m+2);
    end
end
if plotflag
    figure;subplot(2,1,1);hold on;xlabel('Samples');ylabel('Amplitude')
    plot(xi);grid on;plot(xhat,'r')
    legend('Original','Reconstructed')
end

res = xi - xhat;

if plotflag
    subplot(2,1,2);plot(res,'g');xlabel('Samples');ylabel('Residual Amplitude');grid on
end

vr =(sum(lam(I))/sev)*100;
xhat = xhat + xavg;
% 
sdr = movstd(xhat,L);
ix = find(abs(abs(res./sdr))> 1.0);   %Find  errors that exceed moving SD/2 - This should be a parameter of the function
rout = xin;
rout(ix) = xhat(ix);
if plotflag
    figure; plot(xin); hold on;  plot(xhat); legend('RR','RR-Smooth');
end
%tout = cumsum(rout);
tout = tin(1) + cumsum(rout)/(24*3600);



