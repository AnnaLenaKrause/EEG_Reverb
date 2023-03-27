function audioOut = make_stimulus(pitch, cepstral, shift, reverb, part, dir)

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
    [audio_temp, fs_temp] = audioread(fullfile(dir, filename));
    
    % resample to match brir's sampling frequency
    fs = 48000;
    audio = resample(audio_temp, fs, fs_temp);
    
    % shift pitch
    audio_pitch = shiftPitch(audio(1:60*fs,1),pitch ...
    ,'LockPhase',1,'PreserveFormants',1,'CepstralOrder',cepstral);
    
    % equalize loudness
    audio_eq = adjust_rms(audio_pitch, fs, 4, 1);
    
    % load brir
    brir_name = sprintf('BRIRs/test_ari_%d%s.mat', reverb, shift);
    brir_mat = load(brir_name);
    brir = brir_mat.brir;
    
    % apply brir to sound
    left_test_main = filter(brir(:,1),1,audio_eq);
    right_test_main = filter(brir(:,2),1,audio_eq);
    audioOut = 0.05*[left_test_main right_test_main];

end 