%file:///C:/Users/cory/Downloads/Video%20Mosaicking-Matlab%20(3).pdf

[w, h] = deal(680, 400); % Size of the mosaic
[x0, y0] = deal(-5, -60); % Upper-left corner of the mosaic
xLim = [0.5, w+0.5] + x0;
yLim = [0.5, h+0.5] + y0;
outputView = imref2d([h,w], xLim, yLim);

hsrc = vision.VideoFileReader('vipmosaicking.avi');

halphablender = vision.AlphaBlender( ...
    'Operation', 'Binary mask', 'MaskSource', 'Input port');


hVideo1 = vision.VideoPlayer('Name', 'Corners');
hVideo1.Position(1) = hVideo1.Position(1) - 350;
hVideo2 = vision.VideoPlayer('Name', 'Mosaic');
hVideo2.Position(1) = hVideo1.Position(1) + 400;
hVideo2.Position([3 4]) = [750 500];


points = cornerPoints(zeros(0, 2));
features = binaryFeatures(zeros([0 64], 'uint8'));
failedToMatchPoints = true; % A new mosaic will be created if
% failedToMatchPoints is true

while ~isDone(hsrc)
    % Save the points and features computed from the previous image
    pointsPrev = points;
    featuresPrev = features;
    % To speed up mosaicking, select and process every 5th image
    for i = 1:5
        rgb = step(hsrc);
        if isDone(hsrc)
            break;
        end
    end
    % Convert the image from RGB to intensity.
    I = rgb2gray(rgb);
    % Detect corners in the image
    corners = detectFASTFeatures(I);
    % Extract FREAK feature vectors for the corners
    [features, points] = extractFeatures(I, corners);
    % Match features computed from the current and the previous images
    indexPairs = matchFeatures(features, featuresPrev);
    % Check if there are enough corresponding points in the current and the
    % previous images
    if size(indexPairs, 1) > 2
        matchedPoints = points(indexPairs(:, 1), :);
        matchedPointsPrev = pointsPrev(indexPairs(:, 2), :);
        % Find corresponding locations in the current and the previous
        % images, and compute a geometric transformation from the
        % corresponding locations
        [tform, ~, ~, failedToMatchPoints] = estimateGeometricTransform(...
            matchedPoints, matchedPointsPrev, 'affine');
    end
    if failedToMatchPoints
        % If the current image does not match the previous one, reset the
        % transformation and the mosaic image
        xtform = eye(3);
        mosaic = zeros(h, w, 3, 'single');
    else
        % If the current image matches with the previous one, compute the
        % transformation for mapping the current image onto the mosaic
        % image
        xtform = xtform * tform.T;
    end
    % Display the current image and the corner points
    cornerImage = insertMarker(rgb, corners.Location, 'Color', 'red');
    step(hVideo1, cornerImage);
    % Creat a mask which specifies the region of the transformed image.
    mask = imwarp(ones(size(I)), affine2d(xtform), 'OutputView', outputView) >= 1;
    % Warp the current image onto the mosaic image
    transformedImage = imwarp(rgb, affine2d(xtform), 'OutputView', outputView);
    mosaic = step(halphablender, mosaic, transformedImage, mask);
    step(hVideo2, mosaic);
end
release(hsrc);