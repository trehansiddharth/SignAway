s = serial(defInput('Serial Port', 'COM1'));
set(s, 'BaudRate', 9600);
fopen(s);
