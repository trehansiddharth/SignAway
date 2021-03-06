% Normalize the vectors
% By subtracting the mean
templatePoints = templatePoints - repmat(mean(templatePoints), size(templatePoints, 1), 1);
testPoints = testPoints - repmat(mean(testPoints), size(testPoints, 1), 1);
% And by normalizing the variance
templatePoints = templatePoints ./ repmat(std(templatePoints), size(templatePoints, 1), 1);
testPoints = testPoints ./ repmat(std(testPoints), size(testPoints, 1), 1);

% Find nearest neighbors of all points
nearestIndexes = dsearchn(templatePoints, testPoints);

% Find displacement between each point and its nearest point and add up
totalDisplacement = 0;
numRows = size(testPoints, 1);
for i = 1:numRows
    % Get the closest point
    currentPoint = testPoints(i,:);
    closestPointIndex = nearestIndexes(i);
    closestPoint = templatePoints(closestPointIndex,:);
    
    % Find the distance to it
    displacement = norm(currentPoint - closestPoint);
    
    % Update totalDisplacement
    totalDisplacement = totalDisplacement + displacement;
end

% Find the average displacement
normDisplacement = totalDisplacement / numRows;

% Debugging!
normDisplacement

% Check if signatures match
signatures_match = normDisplacement < 0.25;