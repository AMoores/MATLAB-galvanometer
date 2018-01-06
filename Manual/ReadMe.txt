MATLAB Galvo manual correlation program - readme

The program is operated by running the OffsetMain.m function.

The pathway to the folder into which AFM CaptureFiles are being written should be entered into line 19 of OffsetMain.m (see example pathway in the example code).

Prior to running this program, the focussed excitation spot should be aligned with the photon counting module - this may not occur at a (0,0) position of the galvanometer. Therefore, the voltages which have determined the current orientation of the galvanometer should be input when the MATLAB program asks "Enter current X-axis voltage:" or "Enter current Y-axis voltage".

MATLAB program will first create a STOP button. This should only be pressed when the user wants to terminate the program, after all iterations have been completed. 

The program will search the Capture file directory for the most recent capture file. Capture files should be named in the format: CaptureFile.000, CaptureFile.001 etc. This is the default for Bruker software.

On the first iteration of the program, when the most recent CaptureFile has been found, the program outputs all of the channels contained within the file. Channels are different parameters which have been acquired as part of the PeakForce QNM mode, e.g. Height, DMT modulus, dissipation etc.
The user is asked to select the image which they wish to correlate with the fluorescence image, also contained within the CaptureFile. The chosen image will be used for all subsequent iterations of the program.

The chosen image, along with the fluorescence image, is then presented to the user in an interactive interface. The aim of this interface is for the user to select three coordinates on each image which correspond to the same features. Prior to doing this, it might be useful to stretch the colourbar on the images, allowing some features to be more clearly seen. To do this, right-click on the colourbar of the image, and then select "interactive colourmap shift". Parts of the colourbar can then be dragged to stretch over a particular range of values. When the features can be clearly seen, the OK button on the pop-up window can be pressed. NOTE: the user must ensure that the interactive colourmap shift is deselected before pressing OK, otherwise an error will occur. 
	After pressing OK, the cursor will change to a crosshair. Three key features on the left hand image should be selected. Each coordinate will be labelled in order of selection. When three coordinates have been selected on the left hand image, the user should select three coordinates on the right hand image which correspond to the same features selected in the first. These coordinates should be selected in the same order as for the first image. The difference in position of the same features gives the offset between the fields-of-view of the two images. 

The offset between the fields-of-view in the x- and y-directions is converted from pixels to microns using data about the scan area and number of pixels from the CaptureFile. The offset in microns is then passed to a function containing calibration data for the galvanometer, to calculate the voltages for the galvanometer to move the excitation laser towards zero offset with the AFM tip. 
	To calibrate the galvanometer, the change in offset in the x- and y- directions between the two images is measured per change in voltage delivered to the galvanometer. We found that for every voltage delivered along the x-axis (with no change in the y-axis voltage), the change in the y-offset between the two images was on average -9.809 times that of the change in the x-offset. Our vector for the galvo x-axis therefore became [-1 9.809]. For every voltage delivered along the y-axis (with no change in the x-axis), the change in the y-offset between the two images was (on average) only 0.02605 that of the change in the x-offset. Our vector for the galvo y-axis therefore became [1 0.02605]. We found that on average, a change of 1V along the x-axis of the galvanometer would change the offset between the two images along both the x- and y-directions by 13.8 microns in magnitude. A change of 1V along the y-axis of the galvanometer would change the offset between the two images along both the x- and y-directions by 16.4 microns in magnitude (on average). These values will be different for every set-up - the calculated values for the particular set-up should be inserted into the correct locations (lines 7, 8, 25, 26 in VoltageCalc.m function). The standard deviation of the change in the measured offset values for each axis was calculated, and in our case, is provided as an estimation of the uncertainty on the offset. 

OffsetMain presents the user with a figure containing the two images, along with an overlay at their calculated offset. For the overlay, the fluorescence image is plotted in green and the chosen parameter for correlation is plotted in red. Another figure labelled "Offset tracker" is presented to the user. This is a graph of the offset with an uncertainty estimation shown as an errorbar. This plot will update with every iteration of the MATLAB program, allowing the offset to be tracked overtime as the galvanometer is re-orientated according to the images obtained in new CaptureFiles.

After calculating the first offset, the MATLAB program will check the Capture directory every 2 seconds for new CaptureFiles. When a new CaptureFile is written to the directory, the interactive correlation window will be presented to the user for the new images. The offset between the two images should be reduced towards zero with every iteration of the program. To terminate the program, the STOP button on the original pop-up window (labelled terminate) should be pressed.

The outputs of the OffsetMain function are:
OffsetMagnitude: an array of values representing the magnitude of the offset (in microns) between the two images for each iteration of the program
TotalUnc: an array of corresponding uncertainty values for the magnitude of the offset for each iteration of the program
Offsetx: an array of values representing the offset in x (in microns) between the two images for each iteration of the program
Offsety: an array of values representing the offset in y (in microns) between the two images for each iteration of the program
UncX: an array of corresponding uncertainty values for the offset in the x-direction between the two images for each iteration of the program
UncY: an array of corresponding uncertainty values for the offset in the y-direction between the two images for each iteration of the program
AllCounts: An (x,y,n) dimensional matrix containing all of the fluorescence images acquired in the CaptureFiles. The image is contained in the x and y dimensions, and n is the number of iterations that have taken place. For instance, (:,:,1) is the first fluorescence image acquired.
AllChosen: See AllCounts, but AllChosen is a matrix containing all of the images which have been correlated with the fluorescence images (e.g. height, adhesion etc.)
Unit: the units of the values in the chosen image (e.g. nm for height)
pixelX: an array of values representing the offset in x (in pixels) between the two images for each iteration of the program
pixelY: an array of values representing the offset in y (in pixels) between the two images for each iteration of the program



---------LabVIEW program----------
The LabVIEW VI "ReadingMatFile" is designed to run continuously alongside the MATLAB program. It constantly reads the .mat file created in the current MATLAB folder, containing the current voltages to send to the galvanometer. The pathway to the user's current MATLAB folder should be edited in this VI prior to running. The values read from the .mat file can then be used with a DAQ output for delivery to the galvanometer (program not provided for writing values to a DAQ card).