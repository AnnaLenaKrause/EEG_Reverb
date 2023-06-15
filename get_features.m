dp = 'D:\EEG_Reverb\StimuliNew_RWTH_symm\MAT';
stim_dir_m = 'D:\EEG_ASA_BCI\Stories\Story1_norm';
stim_dir_f = 'D:\EEG_ASA_BCI\Stories\Story2_norm';
savep = 'W:\DM1949_LH_ReverbEff\09_Data_after_cleaning';
% distractors
load('C:\Users\Lars.Hausfeld\Documents\GitHub\EEG_Reverb\distr_parts.mat');
% load low-pass filter
load('C:\Users\Lars.Hausfeld\Documents\GitHub\EEG_Reverb\LP_filter.mat');

nblocks = 8;
nstimuli = 8;
randN = {'A','B','C'};
sr = 100;
sr_mat = 48000;
% sr_wav = 44100;

for r = 1:length(randN)
    ix = 1;
    for b = 1:nblocks
        for stim = 1:nstimuli
            if stim == 1
                % compute stuff for target only
                % wet/reverberat sound
                MAT = load(fullfile(dp,sprintf(['B%i_S%i_' randN{r} '.mat'],b,0)));
                % compute envelopes + derivative for each ear and sum
                [htarget1] = get_envelope(MAT.stim(:,1),sr_mat,sr,0,Hd);
                [htarget2] = get_envelope(MAT.stim(:,2),sr_mat,sr,0,Hd);
                henv = htarget1+htarget2;
                ENVRV_target(ix,:) = henv;
                henvd = diff([0 henv']');
                henvd(henvd<0) = 0;
                ENVDRV_target(ix,:) = henvd;

                % dry sound
                targetix = (b-1)*(nstimuli+1)+1;
                [y_target,fs] = audioread(fullfile(stim_dir_f,sprintf('Part%i_mono_norm.wav',targetix)));
                % target: compute the envelope and its rectified derivative
                henv = get_envelope(y_target,fs,sr,0,Hd);
                ENV_target(ix,:) = henv;
                henvd = diff([0 henv']');
                henvd(henvd<0) = 0;
                ENVD_target(ix,:) = henvd;
                ix = ix+1;
            end

            % wet/reverberat sound
            MAT = load(fullfile(dp,sprintf(['B%i_S%i_' randN{r} '.mat'],b, ...
                stim)));
            % compute envelopes + derivative for each ear and sum
            % target
            [htarget1] = get_envelope(MAT.stim_f_orig(:,1),sr_mat,sr,0,Hd);
            [htarget2] = get_envelope(MAT.stim_f_orig(:,2),sr_mat,sr,0,Hd);
            henv = htarget1+htarget2;
            ENVRV_target(ix,:) = henv;
            henvd = diff([0 henv']');
            henvd(henvd<0) = 0;
            ENVDRV_target(ix,:) = henvd;
            % distractor
            [hdistr1] = get_envelope(MAT.stim_m_orig(:,1),sr_mat,sr,0,Hd);
            [hdistr2] = get_envelope(MAT.stim_m_orig(:,2),sr_mat,sr,0,Hd);
            henv = hdistr1+hdistr2;
            ENVRV_distr(ix,:) = henv;
            henvd = diff([0 henv']');
            henvd(henvd<0) = 0;
            ENVDRV_distr(ix,:) = henv;

            % dry sound
            targetix = (b-1)*(nstimuli+1)+stim+1;
            [y_target] = audioread(fullfile(stim_dir_f,sprintf('Part%i_mono_norm.wav',targetix)));
            distrix = (b-1)*nstimuli+stim;
            [y_distr,fs] = audioread(fullfile(stim_dir_m,sprintf('Part%i_mono_norm.wav',used_parts(distrix))));
            % target: compute the envelope and its rectified derivative
            henv = get_envelope(y_target,fs,sr,0,Hd);
            ENV_target(ix,:) = henv;
            henvd = diff([0 henv']');
            henvd(henvd<0) = 0;
            ENVD_target(ix,:) = henvd;

            % distractor: compute the envelope and its rectified derivative
            henv = get_envelope(y_distr,fs,sr,0,Hd);
            ENV_distr(ix,:) = henv;
            henvd = diff([0 henv']');
            henvd(henvd<0) = 0;
            ENVD_distr(ix,:) = henvd;

            ix = ix+1;
        end        
    end
    save(fullfile(savep,['FEATURES_' randN{r} '.mat']),...
        'ENV_target','ENV_distr','ENVD_target','ENVD_distr',...
        'ENVRV_target','ENVRV_distr','ENVDRV_target','ENVDRV_distr','sr');
end
