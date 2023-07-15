mask = ismember({CL.labels}, frontoCentralElecs);
fCL = CL(mask);

figure;
ax = axes;
topoplot([], fCL, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', ax);

elecHandles = findobj(ax, 'Type', 'text');

% adjust the plot limits to prevent the head from being cut off
axis(ax, 'tight');
padding = 0.1; 
axis(ax, [ax.XLim(1)-padding, ax.XLim(2)+padding, ax.YLim(1)-padding, ax.YLim(2)+padding])


% % figure(2);
% % 
% % story2Dir = '/home/anna/Documents/Uni/Thesis/Pitch estimation/Story1_norm';
% % femNorm1 = audioread(fullfile(story2Dir, "Part1_mono_norm.wav"));
% % plot(ENV_target(1,:));