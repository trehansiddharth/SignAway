% Create a serial port object
s = serial(defInput('Serial Port', 'COM4'));

% Settings for UART communication
set(s, 'BaudRate', 9600);
set(s, 'Parity', 'none');
set(s, 'DataBits', 8);
set(s, 'StopBit', 1);

fopen(s);

while 1
    d = fgetl(s);
    disp(d);
end
