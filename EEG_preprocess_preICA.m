% EEGLAB history file generated on the 03-May-2023
% ------------------------------------------------

dp = '/home/anna/Documents/Uni/Thesis/EEG_RAW/';
savedir = '/home/anna/Documents/Thesis/Pre_ICA_Data/';

S = cell(1, 1);

for j = 18:18
        S{j-17} = ['0', num2str(j)];
end

numS = length(S);
highp = 0.5; % in Hz
lowp = 45;
triggers = {'S111'  'S112'  'S121'  'S122'  'S200'  'S211'  'S212'  'S221'  'S222'};
% description of triggers
% 
%
%
%

for s = 1: numS
    % load brain vision recorder data
    str = S{s};
    filename = sprintf('LHREV1_00%s_N.vhdr', str);
    EEG = pop_loadbv(dp, filename,[],[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129]);

    EEG = eeg_checkset( EEG );

    % providing location information
    lkup = '/home/anna/Documents/MATLAB/eeglab_current/eeglab2021.1/plugins/dipfit/standard_BEM/elec/standard_1005.elc';
    EEG = pop_chanedit(EEG, 'lookup',lkup);
    EEG = pop_chanedit(EEG, 'append',129,'changefield',{130,'labels','FCz'},'lookup',lkup);
    EEG = pop_chanedit(EEG, 'setref',{'1:127','FCz'});
    EEG = eeg_checkset( EEG );

    % re-referencing to average reference
    EEG = pop_reref( EEG, [1:127] ,'refloc',struct('labels',{'FCz'},'type',{''},'theta',{0.7867},'radius',{0.095376},'X',{27.39},'Y',{-0.3761},'Z',{88.668},'sph_theta',{-0.7867},'sph_phi',{72.8323},'sph_radius',{92.8028},'urchan',{130},'ref',{''},'datachan',{0}),'exclude',[128 129] ,'keepref','on');
    EEG = eeg_checkset( EEG );

    % resampling
    EEG = pop_resample( EEG, 100);

    % filtering between 0.5 and 45Hz
    EEG = pop_eegfiltnew(EEG, 'locutoff',highp,'hicutoff',lowp,'channels',{'Fp1','Fz','F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1','Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz','C4','T8','FT10','FC6','FC2','F4','F8','Fp2','AF7','AF3','AFz','F1','F5','FT7','FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2','CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','F9','AFF1h','FFC1h','FFC5h','FTT7h','FCC3h','CCP1h','CCP5h','TPP7h','P9','PPO9h','PO9','O9','OI1h','PPO1h','CPP3h','CPP4h','PPO2h','OI2h','O10','PO10','PPO10h','P10','TPP8h','CCP6h','CCP2h','FCC4h','FTT8h','FFC6h','FFC2h','AFF2h','F10','AFp1','AFF5h','FFT9h','FFT7h','FFC3h','FCC1h','FCC5h','FTT9h','TTP7h','CCP3h','CPP1h','CPP5h','TPP9h','POO9h','PPO5h','POO1','POO2','PPO6h','POO10h','TPP10h','CPP6h','CPP2h','CCP4h','TTP8h','FTT10h','FCC6h','FCC2h','FFC4h','FFT8h','FFT10h','AFF6h','AFp2','FCz'});
    EEG = eeg_checkset( EEG );

    % epoching
    EEG = pop_epoch( EEG, {  'S111'  'S112'  'S121'  'S122'  'S200'  'S211'  'S212'  'S221'  'S222'  }, [-1  60], 'newname', 'Sub1_reref resampled filter epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    str
    EEG = pop_rmbase( EEG, [-1000 0] ,[]);
    EEG = eeg_checkset( EEG );

    % save file
    EEG = pop_saveset( EEG, 'filename',sprintf('S%s_preICA.set', str),'filepath',savedir);
end
