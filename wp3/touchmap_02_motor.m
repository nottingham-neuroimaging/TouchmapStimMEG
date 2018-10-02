clear all
close all
clc
sca

%%
hand = 'l';
Ntrials = 40; %% 40
period = 2;
iti = 12;
jitter_max = 1;
%% Initialise Parallel Port
address = hex2dec('C050');
address2 = hex2dec('C030');
ioObj = io64;
% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
io64(ioObj,address,0);
%% Initialise PTBq
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

t = linspace(0,1,period*hz);
ang = 1*sin(4*pi*t/period);
rotLineXCoords = vertLineXCoords;
rotLineYCoords = vertLineYCoords;
shim_L = [-fixCrossDimPix/5 -fixCrossDimPix/5; fixCrossDimPix/2 fixCrossDimPix/2];
shim_R = [fixCrossDimPix/5 fixCrossDimPix/5; fixCrossDimPix/2 fixCrossDimPix/2];
rotCoords = [rotLineXCoords ; rotLineYCoords];
staticCoords = [rotLineXCoords ; rotLineYCoords];
lineWidthPix = 6;
%% Now for the experiment itself

t = GetSecs;
DrawFormattedText(window, 'Ready' , 'center', 'center', white);
Screen('Flip',window,t);
KbWait();


Screen('DrawLines', window, fixationCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);

% Get timings
jit = jitter_max*rand(1,Ntrials-1);
jit_drift = [0 cumsum(jit)];        % Accounts for the drift in trial onset time due to jitter of ITI.
trial_tot = period+iti;
trial_onset = 0:trial_tot:(trial_tot*(Ntrials-1));
trial_onset = trial_onset + jit_drift+10;
t = GetSecs;

for jj = 1:Ntrials
    
    % escape loop, can be used to pause before drawing cue circle
    [~, keyCode] = KbWait(0,2,t+trial_onset(jj)-1);
    key = KbName(find(keyCode));
    if ~isempty(key)
        switch key
            case {'q';'ESCAPE'}
                sca
                error('Test aborted by operator')
        end
    end
    
    % Draw the green circle to cue t=-1s
    Screen('FrameOval',window,[0 1 0],[[xCenter yCenter]-75 [xCenter yCenter]+75],lineWidthPix);
    rotmat = [cosd(0) -sind(0); sind(0) cosd(0)];
    rotCoords = (rotCoords'*rotmat)';
    switch hand
        case 'r'
            handCoords = [rotCoords + shim_L staticCoords + shim_R];
        case 'l'
            handCoords = [rotCoords + shim_R staticCoords + shim_L];
    end
    Screen('DrawLines', window, handCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window,t+trial_onset(jj)-1);
    WaitSecs('UntilTime', t+trial_onset(jj));
    
    % Motor animation
    io64(ioObj,address,1)
    io64(ioObj,address2,255)
    for ii = 1:length(ang)
        
        switch hand
            case 'r'
                rotmat = [cosd(ang(ii)) -sind(ang(ii)); sind(ang(ii)) cosd(ang(ii))];
                rotCoords = (rotCoords'*rotmat)';
                handCoords = [rotCoords + shim_L staticCoords + shim_R];
            case 'l'
                rotmat = [cosd(-ang(ii)) -sind(-ang(ii)); sind(-ang(ii)) cosd(-ang(ii))];
                rotCoords = (rotCoords'*rotmat)';
                handCoords = [rotCoords + shim_R staticCoords + shim_L];
        end
        
        Screen('DrawLines', window, handCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        Screen('Flip', window);
        
    end
    
    WaitSecs('UntilTime', t+period+trial_onset(jj));
    io64(ioObj,address,0);
    io64(ioObj,address2,0);
    
    % Redraw fixation cross
    Screen('DrawLines', window, fixationCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    
    
end

%% Task finished :)
DrawFormattedText(window, 'Task Complete' , 'center', 'center', white);
Screen('Flip',window,t+1);
KbWait();
sca