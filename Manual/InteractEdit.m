function [REALoffsetx,REALoffsety,UncertaintyXm,UncertaintyYm,A,EstOffX,EstOffY] = InteractEdit(Count,Height,Image2name,RLlength)

A=size(Count);           
L1 = A(:,1);     %calculates the length and width of the images
H1 = A(:,2);

B=size(Height);
L2 = B(:,1);
H2 = B(:,2);

normcounts = Count-min(Count(:));   %normalises the two images from zero to one
normcounts = normcounts./max(normcounts(:));

normheight = Height-min(Height(:));
normheight = normheight./max(normheight(:));

%finds coordinates of clicked points in a graph
figure
h = subplot(1,2,1);
imagesc(Count)
colorbar
i = subplot(1,2,2);
imagesc(Height)
colorbar

m = msgbox('Stretch colorbars as necessary to easily view key features. Right click the colorbar and select "interactive colourshift". When finished, DESELECT THE COLORMAP EDITOR AND PRESS OK.');
waitfor(m);

colorbar(h,'off');
colorbar(i,'off');

[x1,y1] = ginputAMedit(3, 'ShowPoints',true,'ConnectPoints',false,'Axis',h,'FirstCall',true);

[x2,y2] = ginputAMedit(3, 'ShowPoints',true,'ConnectPoints',false,'Axis',i,'FirstCall',false);

Xoffsets = x2 - x1;    %positive offset means that coordinate in second image is set right compared to first image. Negative means coorindate is set left compared to first
Yoffsets = y2 - y1;    %positive offset means that coorindate is set down in second image compared to first image. Negative means coorindate is set up in second compared to first image.

offxDec = mean(Xoffsets);
offyDec = mean(Yoffsets);

EstOffX = round(offxDec);
EstOffY = round(offyDec);

uncertaintyXp = std(Xoffsets);
uncertaintyYp = std(Yoffsets);

onepixelx = RLlength/L1;   %achieves size of one pixel in microns
onepixely = RLlength/H1;

REALoffsetx = EstOffX*onepixelx;
REALoffsety = EstOffY*onepixely;   %achieves real offsets in microns, for later to use with Galvos

UncertaintyXm = uncertaintyXp*onepixelx;
UncertaintyYm = uncertaintyYp*onepixely;





A = zeros(H1+abs(EstOffY),L1+abs(EstOffX),3); %creates a matrix of zeros into which both images can fit overlaid, taking into account their offset
modx = abs(EstOffX)+1;    %calculates the position at which to start plotting the image data (creates the "column/row number" from the offset value)
mody = abs(EstOffY)+1;

if (EstOffX >= 0) && (EstOffY >= 0)    
    A(1:H1,1:L1,1)= normheight;
    A(mody:(H2+EstOffY),modx:(L2+EstOffX),2) = normcounts;
elseif (EstOffX >= 0) && (EstOffY<0)
    A(mody:(H1+abs(EstOffY)), 1:L1,1)=normheight;
    A(1:H2,modx:(L2+EstOffX),2) = normcounts;
elseif (EstOffX < 0) && (EstOffY < 0)
    A(mody:(abs(EstOffY)+H1),modx:(abs(EstOffX)+L1),1)=normheight;
    A(1:H2,1:L2,2) = normcounts;
else
    A(1:H1,modx:(abs(EstOffX)+L1),1)=normheight;
    A(mody:(abs(EstOffY)+H2),1:L2,2)=normcounts;
end



string4plot = strcat(Image2name,' plot'); 

figure
subplot(1,3,1)       %plots the original count data
imagesc(Count)
colormap(hot)
title('Count plot')

subplot(1,3,2)       %plots the original height data
imagesc(Height)        
title(string4plot)

subplot(1,3,3)  %plots the overaid images, offset by the correct amount
imagesc(A)
title('Overlay')   


end