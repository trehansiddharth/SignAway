currentPosition = [0 0];
currentPoint = 2;
numTemplatePoints = size(templatePoints, 1);
while currentPoint < numTemplatePoints
    % Get the target position from currentPoint
    targetPosition = templatePoints(currentPoint,:);
    
    % Get the angle to get to the next point
    v = targetPosition - currentPosition;
    theta = vector_angle(v);

    % Tell the user how to get there
    turning = round(4 * theta / pi);
    direction = 'NONE';
    if (turning == 0)
        direction = 'RIGHT';
    elseif (turning == 1)
        direction = 'TOP RIGHT';
    elseif (turning == 2)
        direction = 'UP';
    elseif (turning == 3)
        direction = 'TOP LEFT';
    elseif (turning == 4)
        direction = 'LEFT';
    elseif (turning == -1)
        direction = 'BOTTOM RIGHT';
    elseif (turning == -2)
        direction = 'DOWN';
    elseif (turning == -3)
        direction = 'BOTTOM LEFT';
    elseif (turning == -4)
        direction = 'LEFT';
    end
    disp(['MOVE ' direction]);
    
    % Listen to what the PSoC says
    d = fgetl(s);
    if (~isempty(d))
        % If the read button has been lifted, break out of the loop
        if (strncmpi(d, ':', 1))
            if (strncmpi(d, ':E', 2))
                break;
            end
        else
            % Grab the delta
            dxy = str2num(char(strsplit(d)));
            
            % Update the current position
            currentPosition = [dxy(1) dxy(2)];
            
            % Find the next template point that is outside a 50 count
            % radius
            while currentPoint < numTemplatePoints
                templatePoint = templatePoints(currentPoint);
                distance = norm(currentPosition - templatePoint);
                if (distance > 50)
                    break;
                end
                currentPoint = currentPoint + 1;
            end
        end
    end
end