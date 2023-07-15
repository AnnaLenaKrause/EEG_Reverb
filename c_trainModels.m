fs = 100;
nSubj = 17;
dir = '/home/anna/Documents/Uni/Thesis/EEGanalysis/EEG_postICA/postICAmatfiles';
feat_dir = '/home/anna/Documents/Uni/Thesis/EEGanalysis/features';
seq = dictionary(1, 'A', 2, 'B', 0, 'C');
load("//home/anna/Documents/Uni/Thesis/EEGanalysis/ElecLoc/ChannelLocation.mat")

for n = 1:nSubj % loop over subjects

    key = seq(mod(n, 3));

    eeg_file = fullfile(dir, sprintf('EEG_cleaned_S%i.mat', n));
    
    if exist(eeg_file, 'file') == 2
        load(eeg_file);
    else
        disp(['EEG mat file not found for subject ', num2str(n)]);
        continue;
    end

    load(fullfile(feat_dir, sprintf('FEATURES_%s.mat', key)))

    ntrials = size(EEG_clean.data, 3);

    offsetX = fs * 6; % 1 second baseline + 5s fade-in distractor
    offsetY = fs * 5;

    for r = 1:2 % loop over reverb conditions

        % prepare X
        rev = EEG_clean.reverb == r-1;
        trials_cond = rev(1:ntrials);
        X = squeeze(EEG_clean.data(:, (offsetX + 1):end, trials_cond));

        LAMBDA = -5:0.5:5;

        % prepare Y
        Y(1, :, :) = ENV_target(trials_cond, (offsetY + 1):end)';
        Y(2, :, :) = ENV_distr(trials_cond, (offsetY + 1):end)';
        Y(3, :, :) = ENVRV_target(trials_cond, (offsetY + 1):end)';
        Y(4, :, :) = ENVRV_distr(trials_cond, (offsetY + 1):end)';

        for k = 1:sum(trials_cond)
            STIM{k} = squeeze(Y(:, :, k))';
            RESP{k} = squeeze(X(:, :, k))';
        end

        S_all = mTRFcrossval(STIM, RESP, fs, 1, 0, 400, 10 .^ LAMBDA);

        [R_all, idx] = max(mean(S_all.r, 1), [], 2);

        idx

        R_all = squeeze(R_all);

        lambda = mean(LAMBDA(idx));

        model_all = mTRFtrain(STIM, RESP, fs, 1, 0, 400, 10^lambda);

        for k = 1:sum(trials_cond)
            STIM{k} = squeeze(Y(1:2, :, k))';
        end

        S_dry = mTRFcrossval(STIM, RESP, fs, 1, 0, 400, 10 .^ LAMBDA);

        [R_dry, idx] = max(mean(S_dry.r, 1), [], 2);

        R_dry = squeeze(R_dry);

        lambda = mean(LAMBDA(idx));

        model_dry = mTRFtrain(STIM, RESP, fs, 1, 0, 400, 10^lambda);

        save(sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/model_S%i%i.mat', n, r), ...
            "S_dry", "R_dry", "S_all", "R_all", 'model_dry', "model_all");
        
        clear Y;
        clear STIM;
        clear RESP;
    end

end