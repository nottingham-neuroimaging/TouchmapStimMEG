clear all; close all; clc; sca

amp = 100;

Ntrials = 20;
Nblocks = 4;

stim_length = [1 3];
ITI = 8; %8 seconds (minimum) off
jitter_max = 0.5;
freq = 60;
PortAddress = hex2dec('C050');

D2 = {'0300'};

%% Initialise Arduino
delete(instrfindall)
try
    [~, port] = find_serial_object('Arduino');
    ard = initialize_serial_port(port);
catch
    warning('Arduino not found, entering dummy mode')
    ard = [];
end
%% Initialise Parallel Port IO
ioObj = io64;
% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
io64(ioObj,PortAddress,0);
%% Initialise PTB
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
HideCursor(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white/2);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 72);
[xCenter, yCenter] = RectCenter(windowRect);
fixCrossDimPix = 20;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 6;
%% Stimulus Bit
DrawFormattedText(window, 'Ready' , 'center', 'center', white);
Screen('Flip',window);
KbWait();

Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);

time = stim_length(Shuffle(1+rem(1:Ntrials*Nblocks,2))); % Shuffle the 1s/3s Conditions
time = reshape(time,Ntrials,Nblocks);

for ii = 1:Nblocks
    % PTB uses time relative to a generated timecode to start trials, to
    % generated the deltas (and accommodate the 2 second jitter in trial
    % lengths)
    del = [cumsum(time(1:(Ntrials-1),ii)+ITI)];
    jitter = jitter_max*rand(1,length(del));
    del_jittered = [0 del'+cumsum(jitter)];
    
    t = GetSecs();
    
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window, t);
    %     sca
    %     keyboard
    for jj = 1:Ntrials
        
        % escape loop
        [~, keyCode] = KbWait(0,2,t+del_jittered(jj)+5);
        key = KbName(find(keyCode));
        if ~isempty(key)
            switch key
                case 'q'
                    sca
                    error('Test aborted by operator')
            end
        end
        
        % Stimulation
        switch time(jj,ii)
            case stim_length(1)
                io64(ioObj,PortAddress,1);
                activate_stimulators(ard, freq, time(jj,ii));
            case stim_length(2)
                io64(ioObj,PortAddress,2);
                activate_stimulators(ard, freq, time(jj,ii));
        end
        WaitSecs('UntilTime',t+del_jittered(jj)+time(jj,ii)+5);
        io64(ioObj,PortAddress,0);
    end

    if ii < Nblocks
        WaitSecs(10);
        io64(ioObj,PortAddress,4);
        t = GetSecs();
        for kk = 20:-1:1
            DrawFormattedText(window, sprintf('Short Break: %i seconds left',kk) , 'center', 'center', white);
            Screen('Flip',window,t+(20-kk))
        end;
        WaitSecs('UntilTime',t+20);
        io64(ioObj,PortAddress,0);
    else
        WaitSecs(10);
    end
    
end


%% Close and clean up
DrawFormattedText(window, 'Task Complete!' , 'center', 'center', white);
Screen('Flip',window);
KbWait();
sca
delete(instrfindall)