% Clear the previous serial connection if it exists
if (exist('s'))
    fclose(s);
    delete(s);
    clear s;
    delete(instrfindall);
end

% Create a serial port object
s = serial('COM4');

% Settings for UART communication
set(s, 'BaudRate', 9600);
set(s, 'Parity', 'none');
set(s, 'DataBits', 8);
set(s, 'StopBit', 1);

fopen(s);

points = [];

while 1
    d = fgetl(s);
    if (~isempty(d))
        disp(d);
        if (strncmpi(d, ':', 1))
            if (strncmpi(d, ':R', 2))
                templatePoints = points;
                points = [];
            elseif (strncmpi(d, ':V', 2))
                testPoints = points;
                mode = 'verify';
                points = [];
            elseif (strncmpi(d, ':F', 2))
                testPoints = points;
                mode = 'forge';
                points = [];
                break;
            elseif (strncmpi(d, ':E', 2))
                break;
            end
        else
            dxy = str2num(char(strsplit(d)));
            points = [points; dxy(1) dxy(2)];
        end
    end
end