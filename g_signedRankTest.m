nPart = 17;

rS = zeros(nPart, 128);
nA = zeros(nPart,1);

for s = 1: nPart

    model_file_high = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i1.mat', s);
    model_file_low = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i2.mat', s);

    if exist(model_file_high, 'file') == 2 && exist(model_file_low, 'file') == 2

        mHigh = load(model_file_high); % load high reverb model
        mLow = load(model_file_low); % load low reverb model

    else

        disp(['Model mat file not found for subject ', num2str(s)]);
        nA(s,1)= 1;
        continue;


    end

    r_allH = mHigh.R_all;
    r_dryH = mHigh.R_dry;
    r_allL = mLow.R_all;
    r_dryL = mLow.R_dry;

    diffHigh = r_allH-r_dryH;
    diffLow = r_allL- r_dryL;

    diff = diffHigh-diffLow;

    rS(s,:) = diff;
    
    
end

signrank_results = struct();

for chan = 1:128
    signrank_results(chan).channel = chan;
    signrank_results(chan).p_value = signrank(rS(:, chan));
    signrank_results(chan).diff = sum(rS(:,chan));
    signrank_results(chan).bin = signrank(rS(:, chan)) < 0.05;
end

alpha = 0.05;
significant_indices = [];

% Iterate over channels and collect the indices of significant electrodes
for chan = 1:128
    if signrank_results(chan).p_value < alpha
        significant_indices = [significant_indices, chan];
    end
end

load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/ChannelLocation.mat');

figure;
topoplot(mean(rS,1), CL, 'maplimits', [-0.025 0.025]);
colorbar;
hold on;

topoplot([],CL(significant_indices),'style','blank','electrodes','labelpoint', 'maplimits', [-0.1 0.1]);
