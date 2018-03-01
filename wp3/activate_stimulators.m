function [activation_code] = activate_stimulators(serial_port, frequency, duration)
% Generates the activation bytecode.
% Tactile stimulators are ON for the specified duration.

freq=sprintf('%03d',frequency);
dur = sprintf('%04d',duration*1000);

activation_code='';
activation_code=strcat(activation_code, freq, dur);

if ~isempty(serial_port)
    fprintf(serial_port, '%s', activation_code);
end
pause(duration)
end

