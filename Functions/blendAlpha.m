function newPanorama = blendAlpha(panorama, newImg, panoramaMask, newMask)

% depth?
[panoramaRows, panoramaCols, depth] = size(panorama);

% index or multiplication for masks? multiplication -> doubles/uint8s
newMask = uint8(newMask);
panoramaMask = uint8(panoramaMask);

% panorama is already filled in in the panoramaMask region

% what is the overlap region?
overlapMask = double(and(panoramaMask, newMask));
overlapStartCol = ceil(find(overlapMask > 0, 1, 'first') / panoramaRows);
overlapEndCol =  ceil(find(overlapMask > 0, 1, 'last') / panoramaRows);
overlapMidCol = floor((overlapStartCol + overlapEndCol) / 2);

% create an alpha matrix, same size as panorama
% zeros everywhere except for overlap
alpha = zeros(panoramaRows, panoramaCols);

% windowLength must be a factor of 2
windowLength = 64;
if windowLength/2 >= overlapMidCol - overlapStartCol
    windowLength = floor(2*(overlapMidCol - overlapStartCol));
end

% fill in the alpha values in the middle of the overlap section, with a width of
% windowLength. alpha values are a linear ramp from 0, increasing with each col
value = 0;
for col = overlapMidCol - windowLength/2 : overlapMidCol + windowLength/2
   
   if any(overlapMask(:, col) > 0)
       value = value + 1;
       alpha(:, col) = overlapMask(:,col) * value;     
   end
end

% scale alpha to [0, 1]
alpha = alpha/max(alpha(:));

% need to get alpha into rgb matrix. stupid, but simple way.
alpha3(:,:,1) = alpha;
alpha3(:,:,2) = alpha;
alpha3(:,:,3) = alpha;

% inside the blend window, the alpha value linearly increases from 0 to 1, by column
panorama = im2double(panorama);
newImg = im2double(newImg);

% first, the panorama is the old panorama that isn't overlapping with the new image
newPanorama = panorama.*(~overlapMask);

% add in the blended overlap portion
newPanorama = newPanorama + (panorama.*overlapMask.*alpha3 + newImg.*overlapMask.*(1-alpha3));

% add in the portion of the newImg that wasn't overlapped with the old panorama
newPanorama = newPanorama + newImg.*(~overlapMask);
