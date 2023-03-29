äßfunction condition = make_condition(diff_pitch, diff_loc, reverb, part_f, part_m, pl_min, dir_f, dir_m)
    
    % function that makes a complete stimulus, consisting of female and
    % male voice
    %
    %   DIFF_PITCH: true for easy condition, false for hard condition
    %     DIFF_LOC: true for easy condition, false for hard condition
    %       REVERB: true for easy condition, false for hard condition
    %       PART_M: part of female story
    %       PART_F: part of male story
    %       PL_MIN: true for 15° to the right, false for 15° to the left
    %        DIR_F: directory of female story
    %        DIR_M: directory of male story

    % set parameters for make_stimuus function dependent on condition
    if (diff_pitch == false)

        pitch_f = -1;
        cepstral_f = 150;
        pitch_m = 1;
        cepstral_m = 100;

    else

        pitch_f = 2;
        cepstral_f = 100;
        pitch_m = -1;
        cepstral_m = 150;   

    end
        
    if (diff_loc == true)

        if (pl_min == true)

            shift = '_shifted15';

        else 

            shift = '_shifted-15';

        end

    else

        shift= '';

    end

    if (reverb == true)
        
        reverb = 10;

    else

        reverb = 4;
    end

    fem = make_stimulus(pitch_f, cepstral_f, '', reverb, part_f, dir_f);

    male = make_stimulus(pitch_m, cepstral_m, shift, reverb, part_m, dir_m);

    male_final = fade_in(male, 48000, 3, 4);

    condition = fem + male_final;

end