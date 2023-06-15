function [ENV,t_ds,Hd] = get_envelope_new(Y,sr,nsr,recal,v)

% 1. extract envelope
[Yh] = abs(hilbert(Y));

% 2. low-pass filtering 
if recal
  lp = v;
  Hd = envelope_lp(sr,lp,lp+1);
else
  if nargin==4    
    load('D:\EEG_ASA_BCI\LP_filter.mat');
  else
    Hd = v;
  end
end
Y_lp = filtfilt(Hd.numerator,1,Y);

% 3. downsample to nsr
Y_dslp = resample(Y_lp,nsr,sr);
t_ds = (0:length(Y_ds)-1)'./nsr;



% clean up 
Z = Y_dslp<.001;
Y_dslp(Z) = 0;

ENV = Y_dslp;