% Normalize the vectors
% By subtracting the mean
templatePoints = templatePoints - repmat(mean(templatePoints), size(templatePoints, 1), 1);
testPoints = testPoints - repmat(mean(testPoints), size(testPoints, 1), 1);
% And by normalizing the variance
templatePoints = templatePoints ./ repmat(std(templatePoints), size(templatePoints, 1), 1);
testPoints = testPoints ./ repmat(std(testPoints), size(testPoints, 1), 1);

% Initialize matchPoints as testPoints (we will modify it to find best
% matching of test points to template points)
matchPoints = testPoints;

% Initialize matching algorithm
numRows = size(testPoints, 1);
totalDelta = 0;
finalDisplacement = 0;

for i = 1:(numRows-1)
    % Take each row of matchPoints
    currentPoint = matchPoints(i,:);
    
    % Find the closest point to it in the set of templatePoints
    closestPointIndex = dsearchn(templatePoints, currentPoint);
    closestPoint = templatePoints(closestPointIndex,:);
    
    % Find the angle that brings the point ahead of the current point as
    % close as possible to closestPoint, preserving edge length
    nextPoint = matchPoints(i+1,:);
    u = nextPoint - currentPoint;
    v = closestPoint - currentPoint;
    newNextPoint = currentPoint + (v * norm(u) / norm(v));
    delta = newNextPoint - nextPoint;
    
    % Get statistics
    totalDelta = totalDelta + norm(delta);
    finalDisplacement = finalDisplacement + norm(newNextPoint - closestPoint);
    
    % Shift every point from that point forward by that same amount delta
    matchPoints(i+1:end,:) = matchPoints(i+1:end,:) + repmat(delta, numRows - i, 1);
end

% Calculate some more statistics
normedDelta = totalDelta / numRows;
normedDisplacement = finalDisplacement / numRows;

% Debugging!
totalDelta
finalDisplacement
normedDelta
normedDisplacement

% Check if the signatures match
signatures_match = 1;
