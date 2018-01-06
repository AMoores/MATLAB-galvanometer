function [REALoffsetx, REALoffsety, A, cor, UncertaintyX, UncertaintyY, offsetx, offsety] = CrossCorrelateTest( counts, height, bin_counts, bin_alt, Image2name, RLlength)
%counts and height are 512x512 (or however large the image is) matrices of intensity
%values. This can be saved in Gwyddion as an ASCII file and imported to
%Matlab. Both matrices must be square for this function to work.

%RLlength should be the size of the AFM images in microns



A=size(counts);           
L1 = A(:,1);     %calculates the length and width of the images
H1 = A(:,2);

B=size(height);
L2 = B(:,1);
H2 = B(:,2);

normcounts = counts-min(counts(:));   %normalises the two images from zero to one
normcounts = normcounts./max(normcounts(:));

normheight = height-min(height(:));
normheight = normheight./max(normheight(:));

%------------------


cor = normxcorr2( bin_counts, bin_alt); %cross-correlates the two thresholded images and creates a matrix of values which are proportional to the overlap of the two images
B = abs(cor);

m = max((B(:)));           %finds the maximum value of the correlation matrix
[i,j] = find(B == m);    %finds the position of this maximum value: the most likely position of the centre of the second image with respect to the first

NOoffs=size(i);

if (NOoffs(1) > 1)
     figure
     imagesc(cor)
     colormap(hot)
     title('Cross Correlation plot')

     sprintf('There are multiple choices for offset. Please select most likely position from the Cross Correlation plot and then check the final result from the overlay.')
     j = input('Enter offset x:');
     i = input('Enter offset y:');
else
    j=j;
    i=i;
end


[hotspotheight,hotspotwidth] = CorWidthEstimate(m,i,j,cor);  %estimates the uncertainty on the offset by calculating the width of the hotspot on the cross-correlation matrix


offsetx=j-L1;     %subtracts the number of pixels in the image from the most likely centre, to find the offset of the second image with respect to the first
offsety=i-H1;     %positive value = second image is offset left and up from the first; negative value = second image is offset right and down from the first


onepixelx = RLlength/L1;   %achieves size of one pixel in microns
onepixely = RLlength/H1;

REALoffsetx = offsetx*onepixelx;
REALoffsety = offsety*onepixely;   %achieves real offsets in microns, for later to use with Galvos

UncertaintyXtotal = hotspotwidth*onepixelx;
UncertaintyYtotal = hotspotheight*onepixely;    %achieves the uncertainty in the cross-correlation calculation

UncertaintyX = UncertaintyXtotal/2;   %divides the uncertainty by 2 to obtain an error in the form of a +/- value
UncertaintyY = UncertaintyYtotal/2;

A = zeros(H1+abs(offsety),L1+abs(offsetx),3); %creates a matrix of zeros into which both images can fit overlaid, taking into account their offset
modx = abs(offsetx)+1;    %calculates the position at which to start plotting the image data (creates the "column/row number" from the offset value)
mody = abs(offsety)+1;

if (offsetx >= 0) && (offsety >= 0)    
    A(1:H1,1:L1,1)= normheight;
    A(mody:(H2+offsety),modx:(L2+offsetx),2) = normcounts;
elseif (offsetx >= 0) && (offsety<0)
    A(mody:(H1+abs(offsety)), 1:L1,1)=normheight;
    A(1:H2,modx:(L2+offsetx),2) = normcounts;
elseif (offsetx < 0) && (offsety < 0)
    A(mody:(abs(offsety)+H1),modx:(abs(offsetx)+L1),1)=normheight;
    A(1:H2,1:L2,2) = normcounts;
else
    A(1:H1,modx:(abs(offsetx)+L1),1)=normheight;
    A(mody:(abs(offsety)+H2),1:L2,2)=normcounts;
end
    
   %this is a series of if statements to determine in which corner to plot the two images, depending on whether the offset is positive or negative. 
   %plots the two normalised images, not the thresholded images

string4plot = strcat(Image2name,' plot'); 
   
figure
subplot(2,2,1)       %plots the original count data
imagesc(counts)
colormap(hot)
title('Count plot')

subplot(2,2,2)       %plots the original height data
imagesc(height)        
title(string4plot)

subplot(2,2,3)       %plots the cross-correltation matrix - if perfect, should have one clear value of high intensity
imagesc(B)          
title('Cross correlation plot')

subplot(2,2,4)  %plots the overaid images, offset by the correct amount
imagesc(A)
title('Overlay')   

end

