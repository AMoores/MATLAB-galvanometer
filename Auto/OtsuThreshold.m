function [thresholded,a] = OtsuThreshold( image, bitscale )

%See webpage:
%http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html for
%notes on how this function works. Corresponding details can also be found
%in my lab book. 

%This function takes an image and outputs a thresholded image, assuming
%that the image can be split into two definite areas of intensity,
%representing a background and a foreground. The function calculates the
%optimum position for thresholding and outputs data at this
%threshold. The "bitscale" is the number of bits used to represent the image intensity scale.
%A higher bitscale value would give a more accurate threshold for the image, but
%also increases the processing time drastically.

%The function also outputs a value "a", which corresponds to the position
%of the threshold. Although a bitscale value of 10 is usually sufficient, 
%care should be taken to make sure that the final value of a is greater than 1. 
%A value of 1 would imply that the number of bits
%used to represent the intensity scale of the image needs to be increased
%to obtain a more accurate thresholding value. 

normimage = image-min(image(:));
normimage = normimage./max(normimage(:));


S=size(image);           
M = zeros(S(:,1),S(:,2),bitscale);   %creates a matrix of zeros the same size as the original image with a third dimension representing the number of bits to separate the image into


dI = 1/bitscale;

B = zeros(1,bitscale);

  for i = 1:bitscale          %creates an array of values required to threshold the image into "bitscale" intensity regions
      B(:,i) = i*dI;
  end
  
  
  M(:,:,1) = normimage <= B(:,1);
  
  for i = 2:bitscale
      for j = 1:(S(:,1))
          for k = 1:(S(:,2))
              if (normimage(j,k) > B(:,i-1)) && (normimage(j,k) <= B(:,i)) 
                  M(j,k,i) = 1;
              end
          end
      end
  end
  
  %this creates "bitscale" different matrices, each with pixels
  %corresponding to the threshold limits given in array B.
  
  
 
 C = zeros(1,bitscale);     
 
 for i = 1:bitscale
     C(:,i)=sum(sum(M(:,:,i)));
 end
  
 %this gives me the number of pixels that match the condition in the thresholding array
 %equal to the histogram of pixels at http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html
 

 TotalPix = sum(C); %total number of pixels in image
 

for i = 1:(bitscale-1)    %creates two matrices 1=background, 2 = foreground. Each row represents a different threshold point
    for j = 1:bitscale
        if j > i
            T(i,j,2)=C(1,j);
        else
            T(i,j,1)=C(1,j);
        end
    end
end
  

%now need to calculate the weight, mean and variance for each row of the
%matrix

W = sum(T,2);
Weight = W/TotalPix;    %two arrays corresponding to the weight of the background and foreground for all threshold positions (one per row)
                              %NB threshold positions are T=1, T=2 etc for
                              %the example on the website

for i=1:(bitscale-1)
    for j = 1:bitscale
        for k = 1:2
        Meanfirst(i,j,k)= B(1,j).*T(i,j,k);
        end
    end
end

Meansecond = sum(Meanfirst,2);

for i =1:(bitscale-1)
        for k = 1:2
            Mean(i,:,k)=Meansecond(1,1,k)./W(i,1,k);    %two arrays corresponding to the means of the background and foreground for all threshold positions (one per row)
        end
end


%Now need to calculate the variance of all possible threshold positions

for k = 1:2
    for i = 1:(bitscale-1)
        for j = 1:bitscale
            varterm1(i,j,k) = B(1,j)-Mean(i,1,k);
        end
    end
end     %this is the threshold value - mean value... now needs to be squared.


vartermsq = varterm1.^2;    %these terms now need to be multiplied by the number of pixels at each value (W)

for k = 1:2
    for i = 1:(bitscale-1)
        for j = 1:bitscale
            varterm2(i,j,k) = vartermsq(i,j,k).*T(i,j,k);
        end
    end
end    %these now need to be summed along each row


variancenumerator = sum(varterm2,2);   %the denominator is W (number of pixels for each threshold condition)

variance = variancenumerator./W;

SWV1 = variance.*Weight;   

swv=SWV1(:,:,1)+SWV1(:,:,2); %this is the sum of weighted variance. The threshold position with the lowest value of swv should give the best image


minSWV = min(swv(:));
[a] = find(swv == minSWV); %finds the position of the minimum value of the sum of weight variance, corresponding to the best position to threshold


thresholded = zeros(S(:,1),S(:,2));


for i = 1:(S(:,2))
    for j = 1:(S(:,1))
        for k = 1:a
            thresholded(i,j) = thresholded(i,j)+M(i,j,k);
        end
    end
end

 
end

