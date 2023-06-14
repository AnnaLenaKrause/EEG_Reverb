%% set parameters, folders, ...
% dir = 'Randomizations'; % directory with randomisation sequences
ghdir = 'C:\Users\Lars.Hausfeld\Documents\GitHub\EEG_Reverb';
stim_dir_f = 'D:\EEG_ASA_BCI\Stories\Story2_norm'; % directory of female sound files
stim_dir_m = 'D:\EEG_ASA_BCI\Stories\Story1_norm'; % directory of male sound files
savedir = 'D:\EEG_Reverb\StimuliNew_RWTH'; % save directory
nrand = 3;
randN = {'A','B','C'};
fs = 48000;
rms = .08;
brir_type = 'rwth'; % 'rwth' or 'ari'
load('distr_parts.mat');

%% create the stimuli
for r = 1:nrand

    letter = char(randN(r));
    % load randomisation sequence
    seq = load(fullfile(ghdir,'Randomizations',['STIMULUS_SEQUENCE_' letter '.mat']));
    seq = seq.SEQUENCE;
    part_f = 0;
    part_m = 0;

    for block = 1 : length(seq)

        % generate balanced left and right shifts for mask
        plus_minus = [seq{block}(1,1:4) double(~seq{block}(1,5:8))];
        shiftd = logical(plus_minus);

        part_f = part_f+1;

        % generate the first stimulus of the block (only female voice)
        [stim, stim_f_orig] = make_stimulus(2, 100, '', 10,  part_f, rms, stim_dir_f,brir_type);
        stim = fade_in(stim, 48000, 0, 0.5);
        filename = sprintf('B%d_S%d_%s.mat', block, 0, letter);
        save(fullfile(savedir, 'MAT', filename), 'stim', 'stim_f_orig');
        filenamewav = sprintf('B%d_S%d_%s.wav', block, 0, letter);
        audiowrite(fullfile(savedir, 'WAV', filenamewav), stim, fs, 'BitsPerSample',16);

        for stix = 1:  size(seq{block},2)

            part_f = part_f+1;
            part_m = part_m+1;

            currCol = seq{block}(:,stix);
            cond = logical(currCol);
            diff_pitch = cond(1);
            diff_loc = cond(2);
            reverb = cond(3);
            pitch_plmin = shiftd(stix);

            [stim, stim_f_orig, stim_m_orig] = make_condition(diff_pitch, diff_loc, reverb, part_f, used_parts(part_m),...
                pitch_plmin, rms, stim_dir_f, stim_dir_m, brir_type);

            filename = sprintf('B%d_S%d_%s.mat', block, stix, letter);
            save(fullfile(savedir, 'MAT', filename), 'stim', 'stim_f_orig', 'stim_m_orig');

            filenamewav = sprintf('B%d_S%d_%s.wav', block, stix, letter);
            audiowrite(fullfile(savedir, 'WAV', filenamewav), stim, fs,'BitsPerSample',16);

        end
    end
end
