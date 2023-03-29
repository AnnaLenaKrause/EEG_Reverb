function y_adj = adjust_rms(y,fs,adjl,sml)

winl = round(fs*adjl);
startix = 1:winl:length(y);
rmswin = [];
orig_rms = std((y-mean(y)));

for w = 1:(length(startix)-1)
    if w < startix(w+1)
        hy = y(startix(w):startix(w+1));
    else
        hy = y(startix(w):end);
    end
    hy = hy-mean(hy);
    rmswin = [rmswin std(hy)];
end

rmswin_sm = smooth(rmswin,sml);
rmswin_t = ((startix-1)/fs)+adjl/2;
Xrmswin_t = (1:length(y))/fs;
% Xrmswin = interp1(rmswin_t(1:(end-1)),rmswin,Xrmswin_t,'linear',orig_rms);
Xrmswin_sm = interp1(rmswin_t(1:(end-1)),rmswin_sm,Xrmswin_t,'spline',orig_rms);
rms_fac_sm = 1./Xrmswin_sm';
y_adj = (y.*rms_fac_sm);
y_adj = y_adj./(std(y_adj-mean(y_adj))).*orig_rms;
