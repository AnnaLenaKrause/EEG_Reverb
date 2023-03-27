function array = fade_in(sound, fs, fade_start, fade_end)

% function that makes a sound fade in
%
%      SOUND: array with sound, 1-dim
%         FS: sampling frequency
% FADE_START: start of fade in in s
%   FADE_END: end of fade in in s

    startpoint = fade_start*fs;
    endpoint = fade_end*fs;
    beginning = zeros(startpoint-1, 1);
    n_middle = endpoint-startpoint;
    middle = linspace(0, 1, n_middle)';
    end_ = ones(length(sound)-endpoint+1,1);
    mult = vertcat(beginning, middle, end_);
    array= sound.*mult;

end