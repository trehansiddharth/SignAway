% Let the user copy/paste the image data
imgData = char(input('Enter image data to visualize: '));

% Get the dimensions of the image based on the amount of data transferred
numPixels = length(imgData) / 2
dimension = sqrt(numPixels)

% Check if the data is of the right length
if mod(dimension, 1) == 0
    % Create a matrix to store pixel data
    imageMatrix = zeros(dimension, dimension);
    
    % Loop over image data to construct matrix
    i = 1;
    j = 1;
    while ~isempty(imgData)
        % Pop off the first two elements of the image data
        digit1 = imgData(1);
        imgData(1) = [];
        
        digit0 = imgData(1);
        imgData(1) = [];
        
        % Combine them to get a pixel value
        pixelHex = strcat(digit1, digit0);
        pixelDec = hex2dec(pixelHex);
        
        % Store it in the current position of the matrix
        imageMatrix(i, j) = pixelDec;
        
        % Increment the current position in the matrix
        i = i + 1;
        if i == dimension + 1
            i = 1;
            j = j + 1;
        end
    end
    
    % Show the image
    imshow(imageMatrix, [0 255]);
else
    sprintf('Invalid data length.')
end
