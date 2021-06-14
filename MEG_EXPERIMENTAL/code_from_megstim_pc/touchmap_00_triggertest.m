clear all
close all
clc
sca

%% 

address = hex2dec('C050');
ioObj = io64;
% initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
io64(ioObj,address,0);

for ii = 1:4
for jj = 0:7
    io64(ioObj,address,2^jj);
    pause(0.4)
end
end

io64(ioObj,address,0);