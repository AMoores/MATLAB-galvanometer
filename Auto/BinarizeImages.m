function [j] = BinarizeImages( Count, Alt )

%This function takes the two filtered images (Count and the chosen image
%for correlation). It uses the Otsu and Edge detection methods of
%binarisation on both images and asks which method has given the most
%similar results across the two images. The chosen method will be used for
%the remainder of the iterations, in conjunction with the cross-correlation
%function.


 [Otsu_Count,a] = OtsuThreshold(Count,50);
 [Otsu_Alt,b] = OtsuThreshold(Alt,50);
 
 
 Edge_Count = EdgeDetect(Count);
 Edge_Alt = EdgeDetect(Alt);

 
 
  figure
  subplot(2,2,1)
  imagesc(Otsu_Count);
  title('Otsu Count');
  subplot(2,2,2)
  imagesc(Otsu_Alt);
  title('Otsu Other');
  subplot(2,2,3)
  imagesc(Edge_Count);
  title('Edge Count');
  subplot(2,2,4)
  imagesc(Edge_Alt);
  title('Edge Other');
 

     sprintf('Which method has produced most similar results across the Count and Other images?')
     j = input('Press 1 for Otsu. Press 2 for Edge: ');
 
 
end