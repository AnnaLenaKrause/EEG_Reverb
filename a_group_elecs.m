% load channel location data
load('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/ChannelLocation.mat')
labels = {CL.labels};

% remove indices of two electrodes that don't have coordinate data
rmvIdx = strcmp(labels, 'O9') | strcmp(labels, 'O10');
labels(rmvIdx) = [];

% make fronto-central cluster:
frontoCentralElecs = {'F1', 'F2', 'Fz','FFC1h', 'FFC2h', 'FCz', 'FC1', 'FC2', 'FCC1h', 'FCC2h', ...
    'Cz', 'C1', 'C2'};

for j = 1:length(frontoCentralElecs)
    frontoCentralIdx(j) = find(strcmp(labels, frontoCentralElecs{j}));
end

x = [CL.X];
y = [CL.Y];

% find labels of frontal electrodes
frontalIdx = find(startsWith(labels, 'F')| startsWith(labels, 'A'));
frontalElecs = labels(frontalIdx);

% find labels of central electrodes
centralIdx = find(startsWith(labels, 'C'));
centralElecs = labels(centralIdx);

% find labels of occipital and parietal electrodes
parietalIdx = find(startsWith(labels, 'O') | startsWith(labels, 'P'));
parietalElecs = labels(parietalIdx);

% find labels of left temporal electrodes
leftTempIdx = find(startsWith(labels, 'T') & ~cellfun(@isempty, regexp(labels, ...
    '^T.*[13579]')));
leftTempElecs = labels(leftTempIdx);

% find labels of right temporal electrodes
rightTempIdx = find(startsWith(labels, 'T') & ~cellfun(@isempty, regexp(labels, ...
    '^T.*[02468]')));
rightTempElecs = labels(rightTempIdx);

% plot electrodes color-coded by group
figure(1);
scatter(x, y, 'filled');
hold on;

scatter(x(frontalIdx), y(frontalIdx), 'r', 'filled');
scatter(x(centralIdx), y(centralIdx), 'g', 'filled');
scatter(x(parietalIdx), y(parietalIdx), 'b', 'filled');
scatter(x(leftTempIdx), y(leftTempIdx), 'm', 'filled');
scatter(x(rightTempIdx), y(rightTempIdx), 'c', 'filled');

% add labels to the electrodes
for i = 1:numel(labels)
    text(x(i), y(i), labels{i}, 'FontSize', 10);
end

xlabel('X');
ylabel('Y');
title('EEG Electrode Groups');
legend('All Electrodes', 'Frontal', 'Central', 'Parietal/Occipital', ...
    'Left Temporal', 'Right Temporal');

savefig('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/electrode_groups.fig');

% make another figure for fronto-central electrodes
figure(2);
scatter(x, y, 'filled');
hold on;

scatter(x(frontoCentralIdx), y(frontoCentralIdx), 'r', 'filled');
for i = 1:numel(labels)
    text(x(i), y(i), labels{i}, 'FontSize', 10);
end

xlabel('X');
ylabel('Y');
title('Fronto-Central Electrode Group');
legend('All Electrodes', 'Fronto-Central');

% Save the figure
savefig('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/frontoCentralGroup.fig');

% Save all variables in one MAT file
save('/home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/electrode_groups.mat',...
    'frontalElecs', 'centralElecs', 'parietalElecs', 'leftTempElecs', 'rightTempElecs',...
    'frontoCentralElecs'); 
