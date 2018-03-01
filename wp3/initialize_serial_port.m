function ard = initialize_serial_port(port_number)
%initialize_serial_port function declares and opens
%the USB port used for serial communication to the 
%arduino
%   create serial port object
%     port_number='/dev/ttyACM0'; %linux port
%     port_number='COM3'; %windows port
    baud_rate=9600;
    ard=serial(port_number,'BaudRate',baud_rate);
    %Change the Terminator property of the serial port to make it faster
    set(ard,'Terminator','LF'); % define the terminator for println
    set(ard,'Databits',8);
    set(ard,'Stopbits',1);
    set(ard,'Parity','none');

    
    
    
%   open serial port for communications
    fopen(ard);
    start='/A01'; %start command
    fprintf(ard,start) %print start command to arduino
    tline = fgetl(ard); %read data from arduino, which waited until start command
    disp(tline)
end

