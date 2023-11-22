fs = 100;
offsetX = fs * 6; % 1 second baseline + 5s fade-in distractor
offsetY = fs * 5;
nSubj = 17;
seq = dictionary(1, 'A', 2, 'B', 0, 'C');
LAMBDA = -5:.5:5;
eeg_dir = '/home/anna/Documents/Uni/Thesis/EEGanalysis/EEG_postICA/postICAmatfiles';
feat_dir = '/home/anna/Documents/Uni/Thesis/EEGanalysis/features';
load("/home/anna/Documents/Uni/Thesis/EEGanalysis/features/ElecLoc/ChannelLocation.mat")

nanmask = zeros(nSubj, 2);

for n = 1:nSubj % loop over subjects
    
    % load correct features of participant
    key = seq(mod(n, 3));
    load(fullfile(feat_dir, sprintf('FEATURES_%s.mat', key)))
    
    % directory participant EEG data
    eeg_file = fullfile(eeg_dir, sprintf('EEG_cleaned_S%i.mat', n));
    
    % check whether file exists
    if exist(eeg_file, 'file') == 2
        load(eeg_file);
    else
        disp(['EEG mat file not found for subject ', num2str(n)]);
        continue;
    end
    
    % find number of trials participant has completed
    ntrials = size(EEG_clean.data, 3);

    for r = 1:2 % loop over reverb conditions

        % prepare X
        % make mask of which trials are correct reverb condition
        rev = EEG_clean.reverb == r-1;
        % cut the mask to correct number of trials
        trials_cond = rev(1:ntrials);
        % extract trials from data, using the data from offset to end
        X = squeeze(EEG_clean.data(:, (offsetX + 1):end, trials_cond));

        % prepare Y
        % dry
        Y(1, :, :) = ENV_target(trials_cond, (offsetY + 1):end)';
        Y(2, :, :) = ENV_distr(trials_cond, (offsetY + 1):end)';
        % with reverb
        Y(3, :, :) = ENVRV_target(trials_cond, (offsetY + 1):end)';
        Y(4, :, :) = ENVRV_distr(trials_cond, (offsetY + 1):end)';
        
        % format
        for k = 1:sum(trials_cond)
            STIM{k} = squeeze(Y(:, :, k))';
            RESP{k} = squeeze(X(:, :, k))';
        end
        
        % perform cross validation, get r for each trial, lambda, electrode 
        S_mixed = mTRFcrossval(STIM, RESP, fs, 1, 0, 400, 10 .^ LAMBDA, 'verbose', false);

        if any(isnan(S_mixed.r))
            nanmask(n,r) =1;
        end

        S_mixed.r = atanh(S_mixed.r);
        
        % INDIVIDUAL

        % find Lambda that maximizes r for each electrode individually
        [r_individual_mixed, idx_individual_mixed] = max(mean(S_mixed.r, 1), [], 2);

        r_individual_mixed = squeeze(r_individual_mixed);

        w_mixed = zeros(4, 41, 128); % Initialize array to store w
        b_mixed = zeros(1, 128); % Initialize array to store b

        lambda_individual_mixed = LAMBDA(idx_individual_mixed);

        % for each electrode, train a model using the individual lambda
        for i = 1:128

            for k = 1:sum(trials_cond)
                RESP_ind{k} = squeeze(X(i, :, k))';
            end
            model_mixed = mTRFtrain(STIM, RESP_ind, fs, 1, 0, 400, 10^LAMBDA(idx_individual_mixed(i)),  'verbose', false);
            
            % Extract the 'w' and 'b' fields and store them
            w_mixed(:, :, i) = model_mixed.w;
            b_mixed(i) = model_mixed.b;
         
        end
        
        % Create a structure with fields 'w' and 'b' that contain all the 'w' and 'b' arrays
        model_individual_mixed.w = w_mixed;
        model_individual_mixed.b = b_mixed;

        % AVERAGED
        lambda_averaged_mixed = mean(LAMBDA(idx_individual_mixed));
        model_averaged_mixed = mTRFtrain(STIM, RESP, fs, 1, 0, 400, 10^lambda_averaged_mixed, 'verbose', false);

        S_av_mixed = mTRFcrossval(STIM, RESP, fs, 1, 0, 400, 10^lambda_averaged_mixed, 'verbose', false);
        r_averaged_mixed = squeeze(mean(S_av_mixed.r, 1));

        % POOLED

        % find Lambda that maximizes r across electrodes
        [R, idx_common_mixed] = max(mean(mean(S_mixed.r, 1), 3));

        r_common_mixed = squeeze(mean(S_mixed.r, 1));
        r_common_mixed = r_common_mixed(idx_common_mixed, :)';

        lambda_common_mixed = LAMBDA(idx_common_mixed);

        model_common_mixed = mTRFtrain(STIM, RESP, fs, 1, 0, 400, 10^lambda_common_mixed,  'verbose', false);
        
        % DRY MODELS
        for k = 1:sum(trials_cond)
            STIM_dry{k} = squeeze(Y(1:2, :, k))';
        end

        S_dry = mTRFcrossval(STIM_dry, RESP, fs, 1, 0, 400, 10 .^ LAMBDA,  'verbose', false);

        if any(isnan(S_mixed.r))
            nanmask(n,r) =1;
        end
        
        S_dry.r = atanh(S_dry.r);

        % INDIVIDUAL

        [r_individual_dry, idx_individual_dry] = max(mean(S_dry.r, 1), [], 2);

        r_individual_dry = squeeze(r_individual_dry);

        w_dry = zeros(2, 41, 128); % Initialize the array to store w
        b_dry = zeros(1, 128); % Initialize the array to store b

        lambda_individual_dry = LAMBDA(idx_individual_dry);

        for i = 1:128

            for k = 1:sum(trials_cond)
                RESP_ind{k} = squeeze(X(i, :, k))';
            end
            model = mTRFtrain(STIM_dry, RESP_ind, fs, 1, 0, 400, 10^LAMBDA(idx_individual_dry(i)), 'verbose', false);
            
            % Extract the 'w' and 'b' fields and store them
            w_dry(:, :, i) = model.w;
            b_dry(i) = model.b;
        
        end
        
        % Create a structure with fields 'w' and 'b' that contain all the 'w' and 'b' arrays
        model_individual_dry.w = w_dry;
        model_individual_dry.b = b_dry;

        % AVERAGED
        lambda_averaged_dry = mean(LAMBDA(idx_individual_dry));
        model_averaged_dry = mTRFtrain(STIM_dry, RESP, fs, 1, 0, 400, 10^lambda_averaged_dry, 'verbose', false);

        S_av_dry = mTRFcrossval(STIM_dry, RESP, fs, 1, 0, 400, 10^lambda_averaged_dry, 'verbose', false);
        r_averaged_dry = squeeze(mean(S_av_dry.r, 1));

        % POOLED

        % for each lambda, sum performance over all electrodes and
        % select lambda that maximizes r over all electrodes
        % then use that lambda to collect r at each channel
        
        [R, idx_common_dry] = max(mean(mean(S_dry.r, 1), 3));

        r_common_dry = squeeze(mean(S_dry.r, 1));
        r_common_dry = r_common_dry(idx_common_dry, :)';

        lambda_common_dry = LAMBDA(idx_common_dry);

        model_common_dry = mTRFtrain(STIM_dry, RESP, fs, 1, 0, 400, 10^lambda_common_dry, 'verbose', false);

        % WET MODELS
        for k = 1:sum(trials_cond)
            STIM_wet{k} = squeeze(Y(3:4, :, k))';
        end
        
        S_wet = mTRFcrossval(STIM_wet, RESP, fs, 1, 0, 400, 10 .^ LAMBDA, 'verbose', false);

        if any(isnan(S_mixed.r))
            nanmask(n,r) =1;
        end
        
        S_wet.r = atanh(S_wet.r);
        
        % INDIVIDUAL
        [r_individual_wet, idx_individual_wet] = max(mean(S_wet.r, 1), [], 2);
        r_individual_wet= squeeze(r_individual_wet);
        
        w_wet = zeros(2, 41, 128); % Initialize the array to store w
        b_wet = zeros(1, 128); % Initialize the array to store b

        lambda_individual_wet = LAMBDA(idx_individual_wet);
        
        % Train a model using the lambda we found
        for i = 1:128

            for k = 1:sum(trials_cond)
                RESP_ind{k} = squeeze(X(i, :, k))';
            end
            model = mTRFtrain(STIM_wet, RESP_ind, fs, 1, 0, 400, 10^LAMBDA(idx_individual_wet(i)), 'verbose', false);
            
            % Extract the 'w' and 'b' fields and store them
            w_wet(:, :, i) = model.w;
            b_wet(i) = model.b;
        
        end
        
        % Create a structure with fields 'w' and 'b' that contain all the 'w' and 'b' arrays
        model_individual_wet.w = w_wet;
        model_individual_wet.b = b_wet;

        % AVERAGED
        lambda_averaged_wet = mean(LAMBDA(idx_individual_wet));
        model_averaged_wet = mTRFtrain(STIM_wet, RESP, fs, 1, 0, 400, 10^lambda_averaged_wet, 'verbose', false);

        S_av_wet = mTRFcrossval(STIM_wet, RESP, fs, 1, 0, 400, 10^lambda_averaged_wet, 'verbose', false);
        r_averaged_wet = squeeze(mean(S_av_wet.r, 1));
        
        % POOLED
        [R, idx_pooled_wet] = max(mean(mean(S_wet.r, 1), 3));
        r_common_wet = squeeze(mean(S_wet.r, 1));
        r_common_wet = r_common_wet(idx_pooled_wet, :)';

        lambda_common_wet = LAMBDA(idx_pooled_wet);
        
        model_common_wet = mTRFtrain(STIM_wet, RESP, fs, 1, 0, 400, 10^lambda_common_wet, 'verbose', false);


        save(sprintf('/home/anna/Documents/Uni/Thesis/EEGanalysis/models/modelDiffLambda_S%i_%i.mat', n, r), ...
            "model_individual_mixed", "model_individual_dry", "model_individual_wet", ...
            "model_common_mixed", "model_common_dry", "model_common_wet", ...
            "r_individual_mixed", "r_individual_dry", "r_individual_wet", ...
            "r_common_mixed", "r_common_dry", "r_common_wet", 'lambda_common_mixed', ...
            "r_averaged_mixed", "r_averaged_dry", "r_averaged_wet", ...
            'lambda_common_dry', 'lambda_common_wet', 'lambda_individual_mixed', ...
            'lambda_individual_dry','lambda_individual_wet', 'model_averaged_mixed', 'model_averaged_dry', ...
            "model_averaged_wet", "lambda_averaged_mixed", "lambda_averaged_dry", "lambda_averaged_wet");
        
        clear Y;
        clear STIM;
        clear RESP;
        clear STIM_wet;
        clear STIM_dry;
        clear RESP_ind;
    end

end