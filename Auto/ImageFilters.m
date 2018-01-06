function [lpfilt1, lpfilt2] = ImageFilters(Image1, Image2)
%Cleans up the raw data from the capture files (removes banding and
%gradients)

dimension1 = size(Image1);
rows1 = dimension1(1);
columns1 = dimension1(2);

dimension2 = size(Image2);
rows2 = dimension2(1);
columns2 = dimension2(2);

for i = 1:rows1
    Image1Median(i) = median(Image1(i,:));   %produces an array of the median values of each row for image 1
    Filtered1(i,:) = Image1(i,:) - Image1Median(i);  %removes the median for each row
end

for i = 1:rows2
    Image2Median(i) = median(Image2(i,:));    %produces an array of the median values of each row for image 2
    Filtered2(i,:) = Image2(i,:) - Image2Median(i);   %removes the median for each row
end

%Horizontal banding (characteristic for height images) is now removed


sig = 0.1;

spfilt1 = imgaussfilt(Filtered1,sig*rows1);     %removes all the high frequency information (details) from the images, leaving the slow-changing gradient
lpfilt1 = Filtered1-spfilt1;                    %subtracts the gradient from the background

spfilt2 = imgaussfilt(Filtered2,sig*rows2);
lpfilt2 = Filtered2 - spfilt2;


%Slope of the image (also usually present in height) is now removed 

end