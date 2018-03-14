clear all
close all
clc
sca

%%
Nblocks = 2;
Ntrials = 20;
cue = 0.75;
iti = 1.5;
jitter_max = 0.5;
lo = 10;
hi = 150;

if rem(Nblocks*Ntrials,4)
    error('Number of (trials x blocks) needs to be a multiple of four!')
end
%% Initialise Parallel Port
address = hex2dec('C050');
ioObj = io64;
% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
io64(ioObj,address,0);
%% Initialise Arduino
delete(instrfindall)
try
    [~, port] = find_serial_object('Arduino');
    ard = initialize_serial_port(port);
catch
    warning('Arduino not found, entering dummy mode')
    ard = [];
end
%% Initialise PTB
PsychDefaultSetup(2);
hz=Screen('NominalFrameRate',0);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white/2);
HideCursor;
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 72);
[xCenter, yCenter] = RectCenter(windowRect);
fixCrossDimPix = 100;
lineWidthPix = 6;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
fixationCoords = [xCoords; yCoords];
%% Now for the experiment itself

t = GetSecs;
DrawFormattedText(window, 'Press any key to begin' , 'center', 'center', white);
Screen('Flip',window,t);
KbWait();
Screen('DrawLines', window, fixationCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);

% Set condition order
% CONDITION ID as follows:
% 0: LR short
% 1: LR long
% 2: RL short
% 3: RL long

dummy = rem(1:Nblocks,4);
order = randperm(Nblocks);
dummy = dummy(order);

con = rem(1:Nblocks*Ntrials,4);
order = randperm(Nblocks*Ntrials);
con = con(order);
con_mat = reshape(con,Ntrials,Nblocks);

for ii = 1:Nblocks
    
    con_block = con_mat(:,ii);
    for jj = 1:length(con_block)
        switch con_block(jj)
            case 0
                stim(jj) = lo;
            case 1
                stim(jj) = hi;
            case 2
                stim(jj) = -lo;
            case 3
                stim(jj) = -hi;
        end
    end
    
    
    % Get timings
    trial_tot = 2*cue+iti;
    trial_onset = 0:trial_tot:(trial_tot*(Ntrials-1));
    
    jit = jitter_max*rand(1,Ntrials-1);
    jit_drift = [0 cumsum(jit)];        % Accounts for the drift in trial onset time due to jitter of ITI.
    
    stim_drift = [0 cumsum(abs(stim(1:(end-1))))]/1000; % Accounts for the drift in trial onset time due stimulus.
    trial_onset = trial_onset + jit_drift + stim_drift;
    
    
    Screen('DrawLines', window, fixationCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    
    
    WaitSecs(5);
    t = GetSecs;
    
    for jj = 1:Ntrials
        
        % escape loop
        [~, keyCode] = KbWait(0,2, t+trial_onset(jj));
        key = KbName(find(keyCode));
        if ~isempty(key)
            switch key
                case 'q'
                    sca
                    error('Test aborted by operator')
            end
        end
        
        % Draw cue circle
        Screen('FrameOval',window,[0 1 0],[[xCenter yCenter]-50 [xCenter yCenter]+50],lineWidthPix);
        Screen('Flip', window);
        io64(ioObj,address,2^con_block(jj));
        
        % Stimulate
        WaitSecs('UntilTime', t+cue+trial_onset(jj));
        if ~isempty(ard)
            fprintf(ard,num2str(stim(jj)));
        end
        WaitSecs('UntilTime', t+2*cue+trial_onset(jj));
        io64(ioObj,address,0);
        
        %    WaitSecs('UntilTime', t+3*cue+trial_onset(jj));
        
        
        
        % Draw fixation cross
        Screen('DrawLines', window, fixationCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        Screen('Flip', window);
        
    end
    
    % We now probe with a dummy trial just to see if they have been paying
    % attention to the task.
    
    switch dummy(ii)
        case 0
            stim_dummy(ii) = lo;
        case 1
            stim_dummy(ii) = hi;
        case 2
            stim_dummy(ii) = -lo;
        case 3
            stim_dummy(ii) = -hi;
    end
    
    WaitSecs(2);
    t = GetSecs;
    % Draw cue circle
    WaitSecs('UntilTime', t+cue);
    Screen('FrameOval',window,[0 1 0],[[xCenter yCenter]-50 [xCenter yCenter]+50],lineWidthPix);
    Screen('Flip', window);
    if ~isempty(ard)
        fprintf(ard,num2str(stim_dummy));
    end
    WaitSecs('UntilTime', t+2*cue);
    
    
    DrawFormattedText(window, 'Which digit buzzed first?' , 'center', 'center', white);
    DrawFormattedText(window, 'Middle' , xCenter-200, yCenter+100, [1 1 0]);
    DrawFormattedText(window, 'Index' , xCenter+100, yCenter+100, [0 0 1]);
    Screen('Flip', window);
    
    [~, keyCode] = KbWait(0,2,t+2*cue+4);
    key = KbName(find(keyCode));
    correct(ii) = 0;
    if ~isempty(key)
        switch key
            case '6^'
                if stim_dummy(ii) < 2
                    correct(ii) = 1;
                end
            case '7&'
                if stim_dummy(ii) >= 2
                    correct(ii) = 1;
                end
        end
    end
    t = GetSecs;
    for kk = 10:-1:1
        DrawFormattedText(window, sprintf('Short Break: %i seconds left',kk) , 'center', 'center', white);
        Screen('Flip',window,t+5+(10-kk))
    end;
    WaitSecs('UntilTime',t+10);
    
end


%% Task finished :)
WaitSecs(3);
DrawFormattedText(window, 'Task Complete' , 'center', 'center', white);
Screen('Flip',window,t+1);
KbWait();
sca