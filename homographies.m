
im1 = imread('pepsi_l.b.png');
theta = 0;
tform = projective2d([cosd(theta) -sind(theta) 0.001; sind(theta) cosd(theta) 0; 0.01 0.01 1]);
im2 = imwarp(im1, tform);

subplot(2,1,1)
imshow(im1)

subplot(2,1,2)
imshow(im2)


%%
im1 = imread('pepsi_l.b.png');
im2 = imread('pepsi_r.r.png');
new_im = sift_mosaic(im1, im2);