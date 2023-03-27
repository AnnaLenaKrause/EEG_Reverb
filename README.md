# Reverb_EEG

This repository documents a study that explores the impact of reverberation on the brain's ability to differentiate and focus on a target voice that is masked by another speaker, and the effectiveness of pitch and location differences between two voices as cues for speech separation in reverberant conditions. The repository contains the methods used for creating stimuli, which consist of one-minute excerpts from audiobooks narrated by a female voice, along with different excerpts spoken by a male voice as masks. The primary goal of the code is to establish the necessary experimental conditions by incorporating reverberation through the image source method, adjusting the pitches of the voices, and utilizing head-related transfer functions to produce the perception of spatial effects.

## Installation

- In your terminal, navigate into the folder in which you would like to install the repository. Type:

    $ git clone https://github.com/AnnaLenaKrause/Reverb_EEG.git

- Open Matlab and navigate to the folder into which you have cloned the repository.

## What you can find here

### Randomizations

- 'randomization.mlx' was used to create three different randomizations of our experimental conditions, the configuration of variables is given by 0's and 1's
    - each randomization consists of eight blocks, each block consists of nine trials
    - each trial has a stimulus which consists of a female target voice and a male distractor voice. Trials differ in our three variables
        - pitch difference: difference in pitch between female and male voice (0: close, 1: distant)
        - location difference: difference in locations between speakers (0: same location, 1: male voice shifted 15° in azimuth)
        - reverberation: 0: high, 1: low

### Stimulus creation

- stimuli are created in 'main.mlx'
    - 'make_stimulus.m' creates a single voice for given pitch, perceived location and reverberation condition
        - this function requires pre-generated head-related transfer functions (HRTFs), given in the BRIRs folder
        - this function also requires the raw audiofiles (ATTENTION: not currently available in this repository)
        - the function 'adjust_rms.m' is used to equalize the sound's loudness
    - 'make_condition.m' takes a trial confiduration (pitch difference, location difference, reverb) and creates a ready stimulus consisting of target and mask
        - 'fade_in.m' is used to create a fade in effect for the male voice
        
 ### Generating head related transfer functions for adding reverb and spatialization
 
 -
# Reverb_EEG
