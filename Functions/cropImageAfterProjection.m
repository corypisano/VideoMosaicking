function croppedImg = cropImageAfterProjection(img)

grayImg = rgb2gray(img);
[rows, cols] = size(grayImg);

keepRows = false(1, rows);
keepCols = false(1, cols);

for row = 1:rows
    if all(grayImg(row,:) == 0)
        keepRows(row) = false;
    else
        keepRows(row) = true;
    end
end

for col = 1:cols
    if all(grayImg(:,col,:) == 0)
        keepCols(col) = false;
    else
        keepCols(col) = true;
    end
end

croppedImg = img(keepRows,keepCols, :);

end
