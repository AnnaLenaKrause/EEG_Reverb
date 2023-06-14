function array = fade_in(sound, fs, fade_start, fade_end)

% function that makes a sound fade in
% GIT TEST
%
%      SOUND: array with sound, 1-dim
%         FS: sampling frequency
% FADE_START: start of fade in in s
%   FADE_END: end of fade in in s

    startpoint = round(fade_start*fs)+1;
    endpoint = round(fade_end*fs);
    fade = zeros(size(sound,1),1);
    fade((endpoint+1):end) = 1;
    fade(startpoint:endpoint) = linspace(0,1,endpoint-startpoint+1);
    array= sound.*repmat(fade,1,2);
end