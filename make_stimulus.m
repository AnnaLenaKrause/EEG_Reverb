function [audioOut, audio_orig] = make_stimulus(pitch, cepstral, shift, reverb, part, rms, dir, type)

% function that generates a stimulus
%
%    PITCH: pitch change (integer)
% CEPSTRAL: cepstral (integer)
%    SHIFT: '' for 0°, '_shifted15' for 15°, '_shifted-15' for 15°
%   REVERB: int between 1 and 15
%     PART: part of story (integer between 1 and 74)
%      DIR: directory of sounds

% Validate the input arguments
validStrings = {'_shifted15', '_shifted-15', ''};
shift = validatestring(shift, validStrings);

assert(isnumeric(reverb) && isscalar(reverb) && reverb >= 1 && ...
    reverb <= 15, 'Input argument reverb must be a scalar between 1 and 15.');

assert(isnumeric(part) && isscalar(part) && part >= 1 && ...
    part <= 74, 'Input argument part must be a scalar between 1 and 74.');

% load relevant part of story
filename = sprintf('Part%d_mono_norm.wav', part);
[audio_orig, fs_temp] = audioread(fullfile(dir, filename));

% resample to match brir's sampling frequency
fs = 48000; 
max_filt = 1e5;
audio = resample(audio_orig, fs, fs_temp);

% shift pitch
audio_pitch = shiftPitch(audio,pitch,...
    'LockPhase',1,'PreserveFormants',1,'CepstralOrder',cepstral);

% equalize loudness within stimulus
audio_eq = adjust_rms(audio_pitch, fs, 3, 0.50);

% set RMS to pre-specified value
haudio = audio_eq-mean(audio_eq);
audio_rms = rms*(haudio./std(haudio));

% load brir
brir_name = sprintf(['BRIRs/' type '_%d%s_rm_symm.mat'], reverb, shift);
brir_mat = load(brir_name);
brir_l = min(max_filt,size(brir_mat.brir,1));
brir = brir_mat.brir(1:brir_l,:);

% apply brir to sound
% audio_left = highpass(filter(brir(:,1),1,audio_rms),.75,fs);
% audio_right = highpass(filter(brir(:,2),1,audio_rms),0.75,fs);
audio_left = filter(brir(:,1),1,audio_rms);
audio_right = filter(brir(:,2),1,audio_rms);
audioOut = 1.2*[audio_left audio_right];
if isequal(type,'rwth')
    audioOut = audioOut/100;
end
% warning for clipping
if max(abs(audioOut))>0.95, sprintf('pay attention: clipping in file'), end