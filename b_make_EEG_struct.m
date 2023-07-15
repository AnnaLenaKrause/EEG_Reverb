dir = '/home/anna/Documents/Uni/Thesis/EEGanalysis/EEG_postICA/postICAsetfiles';
nSubj = 17;
seq = dictionary(1, 'A', 2, 'B', 0, 'C');

for p = 11: nSubj
    setFilePath = fullfile(dir, sprintf('S%02i_ICAcleaned.set', p));

    % check if the set file exists
    if ~exist(setFilePath, 'file')
        warning('Set file not found for subject %d.', p);
        continue;
    end
    
    set = pop_loadset(setFilePath);
    dat = set.data;

    conditions = [load(sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/randomizations/STIMULUS_SEQUENCE_%s.mat', seq(mod(p,3)))).SEQUENCE{:}];
    newArr = NaN(3, 72);
    cnt = 0;

    for n = 1:72
        if mod(n, 9) ~= 1
            cnt = cnt + 1;
            newArr(1, n) = conditions(1, cnt);
            newArr(2, n) = conditions(2, cnt);
            newArr(3, n) = conditions(3, cnt);
        end
    end
    
    EEG_clean = struct('data', dat, 'pitch', newArr(1, :), 'location', newArr(2, :), 'reverb', newArr(3, :));
    saveFilePath = sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/EEG_postICA/postICAmatfiles/EEG_cleaned_S%i.mat', p);
    save(saveFilePath, 'EEG_clean');
end
