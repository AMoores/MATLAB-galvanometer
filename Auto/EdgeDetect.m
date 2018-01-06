function [thresholded] = EdgeDetect(image)

%This function takes an image and outputs a binarised image using the Canny
%edge detection method and a hole filling function, to pick out key
%features in the images. 

normimage = image-min(image(:));
normimage = normimage./max(normimage(:));


Edge_detect = edge(normimage,'Canny');

DilationHorz = strel('line',3,0);
DilationVert = strel('line',3,90);

dilate_Test = imdilate(Edge_detect,[DilationHorz DilationVert]);

thresholded = imfill(dilate_Test,'holes');


 
end