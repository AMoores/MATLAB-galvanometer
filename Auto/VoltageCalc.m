function [VoltageX, VoltageY, UncertaintyX, UncertaintyY] = VoltageCalc(offsetx, offsety, currentxvoltage, currentyvoltage)

%This code uses the offset values of X and Y (from the cross correlation
%code) and calculates the voltage to send to each Galvo axis
%to get the offset back to zero.

Ylaser = [1 0.026]';   %sets the vectors representing the Galvo x and y axes (using the gradients as calibrated)
Xlaser = [-1 9.809]';    

NormY = norm(Ylaser);   %normalises the vectors ready for unit vectors to be calculated
NormX = norm(Xlaser);

UnitY = Ylaser/NormY;   %calculates the unit vectors of the galvo axes relative to the AFM axes
UnitX = Xlaser/NormX;

OffsetVec = [offsetx offsety]';  %sets up the offset from cross correlation in the form of a vector with respect to AFM axes

MicronsX = dot(OffsetVec, UnitX);
MicronsY = dot(OffsetVec, UnitY);
              %Calculates the magnitude of the offset which is in the
              %direction of the Galvo X and Y axis - this is how much each
              %axis needs to move in microns
              

VoltageXshift = MicronsX/13.8;
VoltageYshift = MicronsY/16.4; 

             %converts the value in microns to a voltage value to be given
             %to the Galvo. 0.1V was found to move the offset by 1.38 and
             %1.64 microns for X and Y respectively - these have been
             %normalised to unity to calculate the final voltages.
           
             
VoltageX = currentxvoltage - VoltageXshift;
VoltageY = currentyvoltage + VoltageYshift;

             
             
UncertaintyX = MicronsX*0.18;
UncertaintyY = MicronsY*0.27;

             %finally calculates how far away perfect alignment between laser and tip could actually be
             %in microns.
             %The values of 0.18 and 0.27 are percentage errors derived
             %from standard deviation in measurement of distance moved with
             %voltage.

end

