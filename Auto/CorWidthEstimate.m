function [widthVert, widthHorz] = CorWidthEstimate(m,i,j,cor )
%fits a Gaussian curve to the cross-correlation hotspot - uses the width of
%the Gaussian as an uncertainty on the offset measurement.

%i and j are the positions of the maximum of the cross-correlation matrix,
%as determined by the cross-correlate function, or by the user if multiple
%maxima are found. cor is the input cross-correlation matrix. m is the
%maximum value of the cross-correlation matrix.

Sz = size(cor);
length = Sz(1);

x = [1:length];

%p(1) is the height of the Gaussian
%p(2) is the mean (the x value at the centre of the Gaussian)
%p(3) is the standard deviation. It is equal to FWHM/2*(sqrt(2ln2)) 

modelFun =  @(p,x) p(1)*exp(-((x-p(2))/p(3)).^2);  %sets up the Gaussian model
startingValsVert = [m i 50];                     %Parameter estimates for column containing max
[coefEstsVert,r1,J1,cov1,mse1] = nlinfit(x, cor(:,j)', modelFun, startingValsVert);

startingValsHorz = [m j 50];  %parameter estimates for row containing max
[coefEstsHorz,r2,J2,cov2,mse2]  = nlinfit(x, cor(i,:), modelFun, startingValsHorz);

%coefEstsVert and coefEstsHorz are the parameters p(1), p(2) and p(3) of
%the gaussian fit. p(3) of these arrays is the standard deviation of the
%two fits - can use this as a correlation plot width estimate in pixels

widthVert = coefEstsVert(3);
widthHorz = coefEstsHorz(3);

end