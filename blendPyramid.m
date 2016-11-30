function newPanorama = blendPyramid(panorama, newImg, panoramaMask, newMask)
%%
% http://vision.cse.psu.edu/courses/CompPhoto/pyramidblending.pdf

buildingDir = './SequenceData/living_room';
imds = imageDatastore(buildingDir);

% Read the first image from the image set.
%img1 = readimage(imds, 1);
%img2 = readimage(imds, 2);
img1 = panorama;
img2 = newImg;

newMask = uint8(newMask);
panoramaMask = uint8(panoramaMask);

% panorama is already filled in in the panoramaMask region

% what is the overlap region?
overlapMask = double(and(panoramaMask, newMask));

% pyramid levels
N = 3;

GA = cell(1, N+1);
GB = cell(1, N+1);

GA{1} = im2double(img1);
GB{1} = im2double(img2);

% gaussian pyramids
for i = 2:N+1
    % each level is a gaussian pyramid reduction of one level higher
    GA{i} = impyramid(GA{i-1}, 'reduce');
    GB{i} = impyramid(GB{i-1}, 'reduce');
end


for i = N:-1:1
    osz = size(GA{i+1}) * 2 - 1;
    GA{i} = imresize(GA{i}, [osz(1) osz(2)]);
    GB{i} = imresize(GB{i}, [osz(1) osz(2)]);
end


% laplacian pyramids
LA = cell(1, N+1);
LB = cell(1, N+1);
for i = 1:N
	LA{i} = GA{i} - impyramid(GA{i+1}, 'expand');
    LB{i} = GB{i} - impyramid(GB{i+1}, 'expand');
	%LA{i} = GA{i} - imresize(GA{i+1}, 2);
    %LB{i} = GB{i} - imresize(GB{i+1}, 2);
end
LA{N+1} = GA{N+1};
LB{N+1} = GB{N+1};

%% collapse pyramids to blend 

LS = cell(1, N+1);
for l = 1:N+1
    centerLine = round((size(LA{l}, 2) + 1) / 2);
    endLine = size(LA{l}, 2);
    
    LS{l}(:,1:centerLine,:) = LA{l}(:,1:centerLine,:);
    LS{l}(:,centerLine,:) = (LA{l}(:,centerLine,:) + LB{l}(:,centerLine,:)) ./ 2;
    LS{l}(:,centerLine+1:endLine,:) = LB{l}(:,centerLine+1:end,:);
end

newOverlap = LS{N+1};
for i = N:-1:1
    newOverlap = LS{i} + impyramid(newOverlap, 'expand');
    %newOverlap = LS{i} + imresize(newOverlap, 2');
end
%newOverlap = imresize(newOverlap, [height width]);
newOverlap = im2uint8(newOverlap);

end

%{
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
%}