clear all
close all
clc
sca

%%
Ntrials = 60;
period = 2;
iti = 8;
jitter_max = 1;
%% Initialise Parallel Port
address = hex2dec('C050');
ioObj = io64;
% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
io64(ioObj,address,0);
%% Initialise PTB
PsychDefaultSetup(2);
hz=Screen('NominalFrameRate',0);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
HideCursor();
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white/2);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 72);
[xCenter, yCenter] = RectCenter(windowRect);
fixCrossDimPix = 100;
vertLineXCoords = [0 0];
vertLineYCoords = [-fixCrossDimPix 0];
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
fixationCoords = [xCoords; yCoords];


lineWidthPix = 6;
%% Now for the experiment itself

DrawFormattedText(window, 'Ready' , 'center', 'center', white);
Screen('Flip',window);
KbWait();

t = GetSecs;
Screen('DrawLines', window, fixationCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);

% escape loop, can be used to pause before drawing cue circle
[~, keyCode] = KbWait(0,2,t+600);
key = KbName(find(keyCode));
if ~isempty(key)
    switch key
        case 'q'
            sca
            error('Test aborted by operator')
    end
end


%% Task finished :)
DrawFormattedText(window, 'Task Complete' , 'center', 'center', white);
Screen('Flip',window,t+610);
KbWait();
sca