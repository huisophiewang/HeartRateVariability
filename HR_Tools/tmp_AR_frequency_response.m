clear all
b = fir1(1024, .5);
[d,p0] = lpc(b,7); 

rng(0,'twister'); % Allow reproduction of exact experiment
u = sqrt(p0)*randn(8192,1); % White gaussian noise with variance p0

% white noise signal 
x = filter(1,d,u);
figure, plot(x)

% ar parameters
[d1,p1] = aryule(x,7);


freqz(sqrt(p1),d1)

