function [ENV,t_ds,Hd] = get_envelope(Y,sr,nsr,recal,v)

% 1. extract envelope
[Yh] = abs(hilbert(Y));

% 2. downsample to nsr
Y_ds = resample(Yh,nsr,sr);
t_ds = (0:length(Y_ds)-1)'./nsr;

% 2. low-pass filtering 
if recal
  lp = v;
  Hd = envelope_lp(nsr,lp,lp+1);
else
  if nargin==4    
    load('D:\EEG_ASA_BCI\LP_filter.mat');
  else
    Hd = v;
  end
end
Y_dslp = filtfilt(Hd.numerator,1,Y_ds);

% clean up 
Z = Y_dslp<.001;
Y_dslp(Z) = 0;

ENV = Y_dslp;