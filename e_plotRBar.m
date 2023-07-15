load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/ChannelLocation.mat')
load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/electrode_groups.mat')

nPart = 17;

elecGroups = {frontalElecs, centralElecs, parietalElecs, leftTempElecs, rightTempElecs, frontoCentralElecs};
elecNames = {'frontal', 'central', 'parietal/occipital', 'left temporal', 'right temporal', 'fronto-central'};
elecLabels = {CL.labels};

elecIndices = cell(size(elecGroups));

sum_r = zeros(4, numel(elecGroups));

r_collect = zeros(4, nPart, numel(elecGroups));

    
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

    model_file_high = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i1.mat', s);
    model_file_low = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i2.mat', s);
    
    % check whether the model exists
    if exist(model_file_high, 'file') == 2 && exist(model_file_low, 'file') == 2
        mHigh = load(model_file_high);
        mLow = load(model_file_low);
    else
        disp(['Model mat file not found for subject ', num2str(s)]);
        continue;
    end
    
    r_values = zeros(4, numel(elecGroups)); 
    
    % get r mean for each electrode group
    for g = 1:numel(elecGroups)

        idx = elecIndices{g};

        rAllMeanH = mean(mHigh.R_all(idx)); 
        rDryMeanH = mean(mHigh.R_dry(idx));
        rAllMeanL = mean(mLow.R_all(idx));
        rDryMeanL = mean(mLow.R_dry(idx));

        r_collect(1, s, g) = mean(mHigh.R_all(idx));
        r_collect(2, s, g) = mean(mHigh.R_dry(idx));
        r_collect(3, s, g) = mean(mLow.R_all(idx));
        r_collect(4, s, g) = mean(mLow.R_dry(idx));
        
        r_values(1,g) = rDryMeanH;
        r_values(2,g) = rAllMeanH;
        r_values(3,g) = rDryMeanL;
        r_values(4,g) = rAllMeanL;

        sum_r(1, g) = sum_r(1,g) + rDryMeanH;
        sum_r(2, g) = sum_r(2,g) + rAllMeanH;
        sum_r(3, g) = sum_r(3,g) + rDryMeanL;
        sum_r(4, g) = sum_r(4,g) + rAllMeanL;

    end

    
   % make bar plots with two panels: low (top), high(bottom)
    figure(s);
    t = tiledlayout(2, 1);
    title(t, sprintf('Comparison of r between "dry" model and "all" model per electrode group, subject %i',s));
    
    % plot the top panel (low reverb)
    ax1 = nexttile;
    bar(ax1, r_values([3 4], :)');
    ylabel('r Value');
    xticks(ax1, 1:numel(elecGroups));
    xticklabels(ax1, elecNames);
    legend('r_{dry}', 'r_{all}');
    title('Low Reverb');
    
    % plot the bottom panel (high reverb)
    ax2 = nexttile;
    bar(ax2, r_values([1 2], :)');
    ylabel('r Value');
    xticks(ax2, 1:numel(elecGroups));
    xticklabels(ax2, elecNames);
    legend('r_{dry}', 'r_{all}');
    title('High Reverb');
    
    xlabel(t, 'Electrode Group');
 
    saveas(gcf, sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/figures/RBar/fig%i.fig', s), 'fig');
end 

sum_r = sum_r./nPart;
% make bar plots with two panels: low (top), high(bottom)
figure(nPart+1);
t = tiledlayout(2, 1);
title(t, 'Comparison of r between "dry" model and "all" model per electrode group, sum' );

% Plot the top panel (low reverb)
ax1 = nexttile;
bar(ax1, sum_r([3 4], :)');
ylabel('r Value');
xticks(ax1, 1:numel(elecGroups));
xticklabels(ax1, elecNames);
legend('r_{dry}', 'r_{all}');
title('Low Reverb');

% Plot the bottom panel (high reverb)
ax2 = nexttile;
bar(ax2, sum_r([1 2], :)');
ylabel('r Value');
xticks(ax2, 1:numel(elecGroups));
xticklabels(ax2, elecNames);
legend('r_{dry}', 'r_{all}');
title('High Reverb');

xlabel(t, 'Electrode Group');

saveas(gcf, '/home/anna/Documents/Uni/Thesis/EEGanalysis/figures/RBar/figAll.fig', 'fig');
