%https://www.mathworks.com/help/vision/examples/feature-based-panoramic-image-stitching.html

%% Mosaic Settings

showAllStiches = 0;
warpToCenter = 0;

useMaxResolution = 1;
if useMaxResolution
    maxResolution = 640;
end
useCylindricalProjection = 1;
if useCylindricalProjection
    focalLength = 650; % pixels
    
    % info.Width * info.DigitalCamera.FocalLength / [ccd width or sensor width in mm]
    % info.Width * info.DigitalCamera.FocalLength / 6.17 (for nexus 6p)
    % maxResolution * info.DigitalCamera.FocalLength / 6.17 (for nexus 6p)
end

%buildingDir = fullfile(toolboxdir('vision'), 'visiondata', 'building');
buildingDir = './SequenceData/flower';
%buildingDir = './SequenceData/bridge_close';
%buildingDir = './SequenceData/living_room';
%buildingDir = './SequenceData/Helicopter_poor';
buildingDir = './SequenceData/taipei_maple2';
%buildingDir = './test';

%% Load Images

imds = imageDatastore(buildingDir);

% populate GUI with image info
info = imfinfo(imds.Files{1})

% Display images to be stitched
figure();
montage(imds.Files)

numFrames = numel(imds.Files);
imgFrames = cell(numFrames, 1);

for i = 1:numel(imds.Files)
    img = readimage(imds, i);
    
    [rows, cols, depth] = size(img);  % all the images don't have to be same size
    
    if useMaxResolution && max(rows, cols) > maxResolution
        % fix to scale the larger resolution
        img = imresize(img, maxResolution / max(rows, cols));
    end
    
    % match exposures here?
    
    if useCylindricalProjection
        img = projectToCylinder(img, focalLength);
        img = cropImageAfterProjection(img);
    end
    
    imgFrames{i} = img;
end

figure();
imaqmontage(imgFrames)

%% Feature Detection

% Read the first image from the image set.
img = imgFrames{1};

% can use grayscale for feature det
grayImg = rgb2gray(img);

%{
feature = 'SURF'
switch feature
    case 'SURF'
        detectSURFFeatures
    case 'HARRIS'
        detectHarrisFeatures
    otherwise
        error('feature unknown');
end
%}
%detectFASTFeatures
%detectMinEigenFeatures
%detectBRISKFeatures
%detectMSERFeatures
%points = detectHarrisFeatures(grayImage);
points = detectSURFFeatures(grayImg);
[features, points] = extractFeatures(grayImg, points);

% initialize struct array of transforms
tforms(1:numFrames) = projective2d();

% Iterate over remaining image pairs
for n = 2:numFrames
    
    % save previous image's points and features
    pointsPrevious = points;
    featuresPrevious = features;
    prevImg = img;
    
    % get next image, convert to grayscale for feature detection
    img = imgFrames{n};
    grayImg = rgb2gray(img);
    
    % Detect and extract SURF features for I(n).
    %points = detectHarrisFeatures(grayImage);
    points = detectSURFFeatures(grayImg);
    
    [features, points] = extractFeatures(grayImg, points);
    
    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    % zzz - change metric, change metric threshold, unique?
    
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    
    %ZZZ
    if n == 2
        figure()
        showMatchedFeatures(img, prevImg, matchedPoints, matchedPointsPrev, 'montage');
        legend('unique matched points 1','unique matched points 2');
    end
    
    % Estimate the transformation between I(n) and I(n-1).
    %[tform,inlierPoints1,inlierPoints2,status] = estimateGeometricTransform(...) additionally returns a status code:
    %	0: No error, 1: matchedPoints1 and matchedPoints2 do not contain
    %   enough points,  2: Not enough inliers have been found.
    try
        tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
            'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    catch e
        errordlg(e.message, 'Homography Error!')
        error(e.message);
    end
    
    % since we want to project to the same frame, we want the transform to
    % get from the original image (the reference frame) to the current one,
    % not just the previous image to the current image.
    % Compute T(1) * ... * T(n-1) * T(n)
    
    tforms(n).T = tforms(n-1).T * tforms(n).T;
end

%%

% Compute the output limits  for each transform
for i = 1:numFrames
    imageSize = size(imgFrames{i});  % all the images are the same size??
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end



if warpToCenter
    avgXLim = mean(xlim, 2);
    
    [~, idx] = sort(avgXLim);
    centerIdx = floor((numel(tforms)+1)/2);
    
    centerImageIdx = idx(centerIdx);
    Tinv = invert(tforms(centerImageIdx));
    
    for i = 1:numel(tforms)
        tforms(i).T = Tinv.T * tforms(i).T;
    end
end

%%
for i = 1:numFrames
    imageSize = size(imgFrames{i});  % all the images are the same size??
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', img);
panoramaMask = logical(rgb2gray(panorama));

%%

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numFrames
    
    img = imgFrames{i};
    
    % Transform I into the panorama.
    warpedImg = imwarp(img, tforms(i), 'OutputView', panoramaView);
    
    % Generate a binary mask.
    % zzz - need to change this
    mask = imwarp(true(size(img,1),size(img,2)), tforms(i), 'OutputView', panoramaView);
    
    % Overlay the warpedImage onto the panorama.
    if i < 200
    panorama = step(blender, panorama, warpedImg, mask);
    else
    panorama = blendAlpha(panorama, warpedImg, panoramaMask, mask);
    end
    % blendPyramid;
    
    % keep a mask of filled out pixels in the panorama for blending
    panoramaMask = or(mask, panoramaMask);
    
    if showAllStiches
        figure
        imshow(panorama)
    end
end

figure
%panorama = cropImageAfterProjection(panorama);
imshow(panorama)