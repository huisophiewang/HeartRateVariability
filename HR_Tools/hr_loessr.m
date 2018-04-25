function [yhat, to] = hr_loessr(t,y,alpha,deg)
% Robust  smoothing, for the detection and rectification of artifacts 
%
%   YHAT = LOESSR_M(X,Y,XO,ALPHA,DEG)
%
%   This function performs the robust loess smoothing for univariate data.
%   YHAT is the value of the smooth.  Y are the observed data at point given by X.
%   XO is the domain over which to evaluate the smooth YHAT. ALPHA is the 
%   smoothing parameter, and DEG is the degree of the local fit (1 or 2).
%   If ALPHA <= 1 the number of points is determined by ALPHA*length(X)
%   If ALPHA > 1  then it represents the number of points to be included

%
%   W. L. and A. R. Martinez, 3-4-04
%   Misha Pavel  6-2012
%   Modified to  replace the vander matrix (out of memory error)
%   Modified to use alpha also to represent the number of points in the
%   window if alpha > 1
%   EDA Toolbox
%   Misha Pavel  6-2012
%   Modified to  replace the vander matrix (out of memory error)
%   Modified to use alpha also to represent the number of points in the
%   window if alpha > 1
%   Cleveland, W. S., & Devlin, S. J. (1988). Locally weighted regression:
%   an approach to regression analysis by local fitting. Journal of the
%   American Statistical Association, 83(403), 596-610. 
%   Cleveland, W. S. (1979). Robust locally weighted regression and
%   smoothing scatterplots. Journal of the American Statistical
%   Association, 74(368), 829-836.


if deg ~= 1 & deg ~= 2
	error('Degree of local fit must be 1 or 2')
end
if alpha <= 0 
	error('Alpha must be positive')
end
if length(t) ~= length(y)
	error('Input vectors do not have the same length.')
end

% get constants needed
n = length(y);
if alpha <= 1
    k = floor(alpha*n);
else
    k = alpha;
end

mt2sec = 24*3600;   % Convert from Matlab time to seconds
t = t*mt2sec;



toler = 0.003;	% convergence tolerance for robust procedure
maxiter = 50;	% maximum allowed number of iterations

t = t(:);           % Time values will be orrected at the end 
y = y(:);           % Input values of RR
x = 1:n;    % Artificial independent variable assuming periodc sampling

%% First eliminate short RR<0.30 secs and add that RR(ix) to the next RR(ix+1)
RRmin = 0.30;      % Low limit on RR < 30 msec coresponding to 200 bps
j = 0;
for i=1:(length(y)-1)
    if y(i) >= RRmin    %Good data point
        j = j+1;
        igood(j) = i;
    else
        y(i+1) = y(i) + y(i+1);
    end
end

y = y(igood);  
t = t(igood); 
n = length(y);
x = 1:n;    % Artificial independent variable assuming periodc sampling


%% Detect and impute outliers
yhat = zeros(size(y)); % Allocate memory

% First find the initial loess fit.
for i = 1:length(y)     % for each y, find the k points that are closest
	dist = abs(t(i) - t);
	[sdist,ind] = sort(dist);
	Nxo = x(ind(1:k));	% get the points in the neighborhood
	Nyo = y(ind(1:k));
	delxo = sdist(k);  %  Max distance from the point of interest
	sdist((k+1):n) = [];
	u = sdist/delxo;
	w = (1 - u.^3).^3;
	p = wfit(Nxo,Nyo,w,deg);
	yhat(i) = polyval(p,x(i));
	niter = 1;
	test = 1;
	ynew = yhat(i);	% get a temp variable for iterations
	while test > toler & niter <= maxiter
		% do the robust fitting procedure
        niter = niter + 1;
		yold = ynew;
		resid = Nyo - polyval(p,Nxo)';	% calc residuals for all Nxo points	
		s = median(abs(resid));
		u = min(abs(resid/(6*s)),1);	% scale so all are between 0 and 1
		r = (1-u.^2).^2;	
		nw = r.*w;
		p = wfit(Nxo,Nyo,nw,deg);	% get the fit with new weights
		ynew = polyval(p,x(i));	% what is the value at x
		test = abs(ynew - yold);
	end
	% converged - set the value to ynew
	yhat(i) = ynew;
    
    % Store the leverage of the original value r(i)
    if (i < n )&& (y(i) > yhat(i) +  yhat(i+1))
        %must impute values
    end
end

function p = wfit(x,y,w,deg)
% This will perform the weighted least squares
n = length(x);
x = x(:);
y = y(:);
w = w(:);
% get matrices
W = spdiags(w,0,n,n);
% MP: Replace the following by a simple power as the Vabdermode matrix is too
% large  % A = vander(x); % A(:,1:length(x)-deg-1) = [];
if deg == 1
    A = [x ones(length(x), 1)];
else
    A = [x.^2 x ones(length(x), 1)];
end
V = A'*W*A;
Y = A'*W*y;
[Q,R] = qr(V,0); 
p = R\(Q'*Y); 
p = p';		% to fit MATLAB convention
