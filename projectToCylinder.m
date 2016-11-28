%https://github.com/msyamkumar/vision-panorama/blob/master/warpToCylindrical.m
function projectedImg = projectToCylinder(img, f)
% http://www.csie.ntu.edu.tw/~cyy/courses/vfx/10spring/lectures/handouts/lec07_stitching_4up.pdf

% Cylindrical projection
% – Map 3D point (X,Y,Z) onto  cylinder (Xhat, Yhat, Zhat)
% Convert to cylindrical coordinates   (sin(theta), h, cos(theta))
%
% – Convert to cylindrical image coordiantes
% (xTilde, yTilde) = (f theta, f h) + (xTilde_C, yTilde_C)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%warpToCylindrical: Computes the inverse map to warp the image
%into the cylindrical coordinates
%   Arguments:
%       image - given input image pixels
%       f - focal length estimate in pixels
%   Return value:
%       newImg - inverse map to cylindrical coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% zzz
% do I need k1, k2?
% can I estimate f?

[rows, cols, depth] = size(img);

%Center values
xc = cols / 2;
yc = rows / 2;

projectedImg = zeros(rows, cols, depth);

% Centered coordinates on image plane
col = 1:cols;
row = 1:rows;

x = col - xc;
y = row - yc;

[X,Y] = meshgrid(x, y);

% Calculating theta and h
theta = atan(x / f);
h = Y ./ sqrt(X.^2 + f^2);

% Calculating cylindrical image co-ordinates
xcap = round(f * theta + xc);
ycap = round(f * h + yc);

for col = 1:cols
    projectedImg(ycap(:,col)', xcap(col), :) = img(row, col, :);
end

projectedImg = uint8(projectedImg);

end


%{
[rows, cols, depth] = size(img);

%Center values
xc = cols / 2;
yc = rows / 2;

projectedImg = zeros(rows, cols, depth);

for row = 1:rows
    for col = 1:cols
        % Centered coordinates on image plane
        x = col - xc;
        y = row - yc;

        % Calculating theta and h
        theta = atan(x / f);
        h = y / sqrt(x^2 + f^2);
        
        % Calculating cylindrical image co-ordinates
        xcap = round(f * theta + xc);
        ycap = round(f * h + yc);
        
        projectedImg(ycap, xcap, :) = img(row, col, :);
    end
end

projectedImg = uint8(projectedImg);

% Cropping unwanted black pixels
%cylindricalImg = cropImage(newImg);

end
%}

%{
%% second code example
% http://pages.cs.wisc.edu/~vmathew/cs766-proj2/cylinder_projection.html
function out = cylinder_projection(image, f, k1, k2)

ydim=size(image, 1);
xdim=size(image, 2);

xc=xdim/2;
yc=ydim/2;

for y=1:ydim
    for x=1:xdim
        theta = (x - xc)/f;
        h = (y - yc)/f;
        xcap = sin(theta);
        ycap = h;
        zcap = cos(theta);
        xn = xcap / zcap;
        yn = ycap / zcap;
        r = xn^2 + yn^2;
        
        xd = xn * (1 + k1 * r + k2 * r^2);
        yd = yn * (1 + k1 * r + k2 * r^2);
        
        ximg = floor(f * xd + xc);
        yimg = floor(f * yd + yc);
        
        if (ximg > 0 && ximg <= xdim && yimg > 0 && yimg <= ydim)
            out(y, x, :) = [image(yimg, ximg, 1) image(yimg, ximg, 2) image(yimg, ximg, 3)];
        end
                               
    end
end

%}