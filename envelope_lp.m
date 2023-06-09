function Hd = envelope_lp(h1,h2,h3)
%ENVELOPE_LP Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.14 and the Signal Processing Toolbox 6.17.
%
% Generated on: 30-Apr-2014 12:33:24
%

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are in Hz.
Fs = h1;  % Sampling Frequency

Fpass = h2;               % Passband Frequency (Hz)
Fstop = h3;               % Stopband Frequency (Hz)
Dpass = .01;               % Passband Ripple (db)
Dstop = 100;               % Stopband Attenuation (db)
dens  = 20;               % Density Factor
dev = [(10^(Dpass/20)-1)/(10^(Dpass/20)+1)  10^(-Dstop/20)];

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], dev);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);
