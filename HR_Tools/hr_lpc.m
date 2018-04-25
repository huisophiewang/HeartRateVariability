function [frqs, coef] = lpc_alpha(x,fs,Fsmin)
% compute fft and plot it
% x   input sequence
% fs    Sampling frequency 1/sec
% win    Length of window in seconds (default length(x)/fs
% Fmax  Minimum sampling frequency in the signal  Fmax = 24 for alpha band 
verbose = 0;
N = length(x);
if nargin < 3
    Fs = fs;
    Axd = x;
else
    % Decimate sampling frequency by factor decif to reduce noise
    % Both decif and the new sampling frequency must be integers
    xx = divisors(fs);
    decif =  max(xx(find(xx <= (Fsmin)))); clearvars xx;
    Fs = fs/decif;
    Axd = decimate(x,decif);
end

Axd1 = Axd.*hamming(length(Axd));
% Preemahasis  is not used here because of the narrow bw
% preemph = [1 0.63]; bpremph = 1; filter(bpremph,preemph,x)
% preemph = [1 0.63];
% x1 = filter(1,preemph,x1);
[coef, errvar] = lpc(Axd1,8); % Model order should be  # of poles +2
rts = roots(coef);      % Computer the roots of the polynomials with coef
rts = rts(imag(rts)>=0); % Keep only one of each of the complex conjugate pairs of poles
angs = atan2(imag(rts),real(rts));
[frqs,ix] = sort(angs.*(Fs/(2*pi)));  % sort by frequency
magz = abs(rts(ix));
ix = find(frqs>=8 & frqs<=12);
frqs = frqs(ix);
%bw = -1/2*(Fs/(2*pi))*log(magz(ix));
if verbose
[H1,ws]=freqz(1,coef,Fs);
plot(ws*Fs/(2*pi),abs(H1));
end
