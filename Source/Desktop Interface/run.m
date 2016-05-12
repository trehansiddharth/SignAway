while 1
    % Get motion data over serial
    motion;
    
    if (strcmp(mode, 'verify'))
        % Run matching algorithm
        match_simple;

        % Debugging!
        visualize;

        % Report whether they're the same or not
        report;
    elseif (strcmp(mode, 'forge'))
        % Forge signature in real-time
        forge;
    end
end
