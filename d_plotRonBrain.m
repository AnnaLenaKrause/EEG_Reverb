nPart = 17;


load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/ChannelLocation.mat')

sumRallhigh = zeros(128, 1);
sumRdryhigh = zeros(128, 1);
sumRalllow = zeros(128, 1);
sumRdrylow = zeros(128, 1);

% make figure for each participant/ reverb level
for m = 1:nPart
    
    figure(m);
    sgtitle(sprintf('Model Results - Subject %i', m));
    
    % load model for each reverb level
    model_file_high = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i1.mat', m);
    model_file_low = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i2.mat', m);

    % check whether the model exists
    if exist(model_file_high, 'file') == 2
        load(model_file_high);
    else
        disp(['Model mat file not found for subject ', num2str(m), ' (High Reverb)']);
        continue;
    end

    subplot(231);
    topoplot(R_all, CL, 'maplimits', [-0.1 0.1]);
    colorbar;
    title('High Reverb - r_{all}');

    subplot(232);
    topoplot(R_dry, CL, 'maplimits', [-0.1 0.1]);
    colorbar;
    title('High Reverb - r_{dry}');

    subplot(233);
    topoplot(R_all - R_dry, CL, 'maplimits', [-0.025 0.025]);
    colorbar;
    title('High Reverb - r_{all} - r_{dry}');

    % sum r over participants for high reverb model
    sumRallhigh = sumRallhigh + R_all;
    sumRdryhigh = sumRdryhigh + R_dry;
    
    % check whether model exists
    if exist(model_file_low, 'file') == 2
        load(model_file_low);
    else
        disp(['Model mat file not found for subject ', num2str(m), ' (Low Reverb)']);
        continue;
    end

    subplot(234);
    topoplot(R_all, CL, 'maplimits', [-0.1 0.1]);
    colorbar;
    title('Low Reverb - r_{all}');

    subplot(235);
    topoplot(R_dry, CL, 'maplimits', [-0.1 0.1]);
    colorbar;
    title('Low Reverb - r_{dry}');

    subplot(236);
    topoplot(R_all - R_dry, CL, 'maplimits', [-0.025 0.025]);
    colorbar;
    title('Low Reverb - r_{all} - r_{dry}');

    savefig(sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/figures/RBar/fig%i.fig', m));
    
    % sum r over participants for low reverb model
    sumRalllow = sumRalllow + R_all;
    sumRdrylow = sumRdrylow + R_dry;
end

% make plot for sum of all participants
R_alllow = sumRalllow ./ nPart;
R_drylow = sumRdrylow ./ nPart;
R_allhigh = sumRallhigh ./ nPart;
R_dryhigh = sumRdryhigh ./ nPart;

figure(m+1);
sgtitle('Model Results - Sum');

subplot(231);
topoplot(R_allhigh, CL, 'maplimits', [-0.1 0.1], 'electrodes', 'on');
colorbar;
title('High Reverb - r_{all}');

subplot(232);
topoplot(R_dryhigh, CL, 'maplimits', [-0.1 0.1],'electrodes', 'on');
colorbar;
title('High Reverb - r_{dry}');

subplot(233);
topoplot(R_allhigh - R_dryhigh, CL, 'maplimits', [-0.025 0.025],'electrodes', 'on');
colorbar;
title('High Reverb - r_{all} - r_{dry}');

subplot(234);
topoplot(R_alllow, CL, 'maplimits', [-0.1 0.1],'electrodes', 'on');
colorbar;
title('Low Reverb - r_{all}');

subplot(235);
topoplot(R_drylow, CL, 'maplimits', [-0.1 0.1],'electrodes', 'on');
colorbar;
title('Low Reverb - r_{dry}');

subplot(236);
topoplot(R_alllow - R_drylow, CL, 'maplimits', [-0.025 0.025],'electrodes', 'on');
colorbar;
title('Low Reverb - r_{all} - r_{dry}');

savefig('/home/anna/Documents/Uni/Thesis/EEGanalysis/figures/RBar/figAll.fig');
