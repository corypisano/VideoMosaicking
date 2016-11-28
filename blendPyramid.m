function newPanorama = blendPyramid(panorama, newImg, panoramaMask, newMask)
%%

buildingDir = './SequenceData/living_room';
imds = imageDatastore(buildingDir);

% Display images to be stitched

% Read the first image from the image set.
img1 = readimage(imds, 1);
img2 = readimage(imds, 2);

% http://vision.cse.psu.edu/courses/CompPhoto/pyramidblending.pdf
A = img1;
G0 = A;
G1 = impyramid(G0, 'reduce');
G2 = impyramid(G1, 'reduce');
G3 = impyramid(G2, 'reduce');

L0 = G0 - imresize(G1, 2);
L1 = G1 - imresize(G2, 2);
L2 = G2 - imresize(G3, 2);

subplot(3,1,1);
imshow(L0, []);

subplot(3,1,2);
imshow(L1, []);

subplot(3,1,3);
imshow(L2, []);

end

%% https://github.com/msyamkumar/vision-panorama/blob/master/blendPyramid.m
function [ out ] = blendPyramid( I1, I2 )
% executes pyramid blending of images A and B
% images must be of the same size
% blending is done at the midpoint

I1 = im2double(I1);
I2 = im2double(I2);

levels = 5;
mask_size = 20;

% compute image pyramids
L1 = makePyramids(I1, levels);
L2 = makePyramids(I2, levels);

% weight matrices
[m,n,~] = size(I1);
midpoint = floor(n/2);
offset = 0;
if mod(n,2) == 1
    offset = 1;
end

W1 = zeros(m,n,3);
W1(:,1:midpoint - mask_size/2,:) = ones(m,midpoint - mask_size/2,3);
W1(:,midpoint - mask_size/2 + ~offset:midpoint + mask_size/2,:) = 0.5 * ones(m,mask_size + offset,3);
W2 = ones(m,n,3) - W1;

L = {};
for j=1:levels
    L{j} = L1{j} .* imresize(W1,[size(L1{j},1) size(L1{j},2)]) ...
        + L2{j} .* imresize(W2,[size(L1{j},1) size(L1{j},2)]);
end
G{levels} = L{levels};
for j=levels:-1:2
    g = impyramid(G{j}, 'expand');
    G{j-1} = g + imresize(L{j-1},[size(g,1) size(g,2)]);
end
out = G{1};

end

%%

% from github, need to modify
function laplacians = makePyramids(X, n)
% computes image laplacians
% X: image
% n: number of levels
gaussians{1} = X;
laplacians = {};
for i=2:n
    % compute next Gaussian
    gaussians{i} = impyramid(gaussians{i-1}, 'reduce');
    % compute Laplacian
    % size adjustment to deal with expand
    sizes = 2*size(gaussians{i}) - 1;
    G = gaussians{i-1}(1:sizes(1),1:sizes(2),:);
    laplacians{i-1} = G - impyramid(gaussians{i}, 'expand');
end
laplacians{n} = gaussians{n};
end