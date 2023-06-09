function y_adj_final = adjust_rms(y,fs,adjl,ov)

winl = round(fs*adjl);
jumpl = winl*(1-ov); % ov between 0 and 1, jump = 1-overlap
startix = 1:jumpl:length(y);
rmswin = [];
orig_rms = std(y-mean(y));

for w = 1:(length(startix)-1)
    if (startix(w)+winl-1)<length(y)% (startix(w) < startix(w)
        hy = y(startix(w):(startix(w)+winl-1));
    else
        hy = y(startix(w):end);
    end
    hy = hy-mean(hy);
    rmswin = [rmswin std(hy)];
end

% rmswin_sm = smooth(rmswin,sml);
rmswin_t = ((startix-1)/fs)+adjl/2;
Xrmswin_t = (1:length(y))/fs;
Xrmswin = interp1([0 rmswin_t],[orig_rms rmswin orig_rms],Xrmswin_t,'spline');
% Xrmswin = interp1(rmswin_t(1:(end-1)),rmswin,Xrmswin_t,'spline',orig_rms);
rms_fac = orig_rms./Xrmswin';%(Xrmswin-min(Xrmswin))./range(Xrmswin);
y_adj = (y.*rms_fac);
% should be ~original rms; to be precise -> normalize and multiply with
% orig_rms
y_adj_m = y_adj-mean(y_adj);
y_adj_final = (y_adj_m./std(y_adj_m))*orig_rms;
