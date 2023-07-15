% Define the number of features, time lags, and electrodes
nPart = 17; 

load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/ChannelLocation.mat')
load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/electrode_groups.mat')

elecGroups = {frontalElecs, centralElecs, parietalElecs, leftTempElecs, rightTempElecs, frontoCentralElecs};
elecNames = {'frontal', 'central', 'parietal/occipital', 'left temporal', 'right temporal', 'fronto-central'};
featureNames = {'target dry', 'distractor dry', 'target', 'distractor'};
elecLabels = {CL.labels};

elecIndices = cell(size(elecGroups));

% initialize array to sum weights over participants
sum_wL = zeros(4,41);
sum_wH = zeros(4,41);

sum_dryL = zeros(2,41);
sum_dryH = zeros(2,41);

% for each electrode group, find corresponding indices in CL
for i = 1:numel(elecGroups)
    elecList = elecGroups{i};
    elecIndices{i} = zeros(1, numel(elecList));
    
    for j = 1:numel(elecList)
        elec = elecList{j};
        elecIndices{i}(j) = find(strcmp(elecLabels, elec));
    end
end

for s = 1:nPart
    
    % set model paths
    model_file_high = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i1.mat', s);
    model_file_low = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i2.mat', s);
    
    % check whether model files exist, if not skip participant
    if exist(model_file_high, 'file') == 2 && exist(model_file_low, 'file') == 2
        mHigh = load(model_file_high); % load high reverb model
        mLow = load(model_file_low); % load low reverb model
    else
        disp(['Model mat file not found for subject ', num2str(s)]);
        figure(s);
        continue;
    end
    
    % extract time lags
    time_lags = mHigh.model_dry.t;

    % extract weights of fronto-central electrodes
    w_subH = mHigh.model_all.w(:, :, elecIndices{6});
    w_subL = mLow.model_all.w(:, :, elecIndices{6});

    w_dryL = mLow.model_dry.w(:, :, elecIndices{6});
    w_dryH = mHigh.model_dry.w(:, :, elecIndices{6});

    % Normalize weights using z-score within each channel
    % for ch = 1:size(w_subH, 3)
    %     w_subH(:, :, ch) = zscore(w_subH(:, :, ch), 0, 'all');
    % end
    % for ch = 1:size(w_subL, 3)
    %     w_subL(:, :, ch) = zscore(w_subL(:, :, ch), 0, 'all');
    % end
    
    % take mean of all channels for each feature and time lag
    w_subH = mean(w_subH, 3);
    w_subL = mean(w_subL, 3);

    w_dryL = mean(w_dryL,3);
    w_dryH = mean(w_dryH,3);
    
    % sum the weights over participants
    sum_wL = sum_wL+w_subL;
    sum_wH = sum_wH+w_subH;

    sum_dryL = sum_dryL + w_dryL;
    sum_dryH = sum_dryH + w_dryH;

    figure(s);
    t = tiledlayout(2, 1);
    title(t, sprintf('Weights of Fronto-Central Electrodes Participant %d', s));

    % top panel, low reverb
    ax1 = nexttile;
    for f = 1:size(w_subL, 1)
        plot(ax1, time_lags, w_subL(f, :), 'DisplayName', featureNames{f});
        hold on;
    end

    title(ax1, 'Low Reverb');
    xlabel(ax1, 'Time Lags');
    ylabel(ax1, 'Weights');
    legend(ax1);

    % bottom panel, high reverb
    ax2 = nexttile;
    for f = 1:size(w_subH, 1)
        plot(ax2, time_lags, w_subH(f, :), 'DisplayName', featureNames{f});
        hold on;
    end
    title(ax2, 'High Reverb');
    xlabel(ax2, 'Time Lags');
    ylabel(ax2, 'Weights');
    legend(ax2);

    saveas(gcf, sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/figures/Weights/fig%i.fig', s), 'fig');
end

figure(nPart+1);

title('Weights of Fronto-Central Electrodes Sum');

ax1 = nexttile;

for f = 1:size(sum_wL, 1)
    plot(ax1, time_lags, sum_wL(f, :), 'DisplayName', featureNames{f});
    hold on;
end

title(ax1, 'Low Reverb');
xlabel(ax1, 'Time Lags');
ylabel(ax1, 'Weights');
legend(ax1);

ax2 = nexttile;

for f = 1:size(sum_wH, 1)
    plot(ax2, time_lags, sum_wH(f, :), 'DisplayName', featureNames{f});
    hold on;
end

title(ax2, 'High Reverb');
xlabel(ax2, 'Time Lags');
ylabel(ax2, 'Weights');
legend(ax2);

saveas(gcf, '/home/anna/Documents/Uni/Thesis/EEGanalysis/figures/Weights/figAll.fig', 'fig');