function [OffsetMagnitude,TotalUnc,Offsetx,Offsety,UncX,UncY, AllCounts, AllChosen, Unit, pixelX, pixelY] = OffsetMain()
%Executes the offset calculation continuously until STOP is pressed in
%pop-up window

%New capture files in the directory are found, opened and formatted. User
%can select which of the images in the capture file to cross-correlate with
%the count image. Offset calculation is performed on the new capture file,
%and the voltages needed by the Galvo to obtain/maintain alignment are
%written to a .mat file. This is then read by the
%'ReadingMatFileWithDriver.vi' which should be set to continually run in
%the background, always sending the most up-to-date value to the Galvo via
%a USB-DAQ.


Newest = 0;   %initialises the capturefile number ready to detect new files
a = 0; %initialises the imageindex parameter ready for user to choose image
b = '';
loops = 0;
Capture_folder = 'C:\Users\Amy\Desktop\Capture'; %set as the path to the folder to where capture files are being written


Current_Matlab_Folder = pwd;
MAT_file_str = '\voltages.mat';
Path_to_MAT_file = strcat(Current_Matlab_Folder,MAT_file_str);
%Creates a pathway to the current MATLAB folder for saving the calculated
%voltages


Quest = 'Enter the current Galvo voltage values for X and Y (for alignment with detector device)\n';
XvolCurrent = input('Enter current X-axis voltage: ');
YvolCurrent = input('Enter current Y-axis voltage: ');  

VoltageX = XvolCurrent;
VoltageY = YvolCurrent;

save(Path_to_MAT_file, 'VoltageX', 'VoltageY', '-v7.3');

hmsg=msgbox('Press STOP to terminate program.','Terminate');
hbut = findobj(hmsg, 'style', 'pushbutton');
set(hbut, 'String', 'STOP')   %Program termination window


while ishandle(hmsg)
    
    loops = loops+1;

    Newest = CaptureFileSearchFunc(Newest,hmsg,Capture_folder);       %finds most up to date capture file
    
    if ishandle(hmsg) == 0
        break
    end        %breaks the loop before cross-correlation calculation if stop has been pressed
    
    [Counts,Alt,Altunit,AllData,AllUnits,RLlength,ImageIndex,Image2name] = CaptureFileFormatFunction(Newest,loops,a,b,Capture_folder);    %formats the file and outputs desired images as ASCII matrices
    a = ImageIndex;
    b = Image2name;     %stores current values for next loop
    
    [Counts,Alt] = ImageFilters(Counts,Alt);
    
    [Realoffsetx,Realoffsety,calcUncX,calcUncY,A, pixelX, pixelY] = InteractEdit(Counts,Alt,Image2name,RLlength);


    [VoltageX,VoltageY] = VoltageCalc(Realoffsetx,Realoffsety, XvolCurrent, YvolCurrent);   %calculates the new voltages required for apprx (0,0) offset

   save(Path_to_MAT_file, 'VoltageX', 'VoltageY', '-v7.3'); %input and send alignment voltages to Galvo      
    %saves values as a .mat file ready to be read by the LabVIEW ReadingMatFile VI 

    XvolCurrent = VoltageX;
    YvolCurrent = VoltageY;        %stores the current (x,y) voltages for the next loop
    
    OffsetMagnitude(loops) = sqrt(((Realoffsetx).^2)+((Realoffsety).^2));     %returns the magnitude of the offset (in microns)
    
    
    calcxfactor = 2*Realoffsetx.*calcUncX;
    calcyfactor = 2*Realoffsety.*calcUncY;
    factor = sqrt((calcxfactor.*calcxfactor)+(calcyfactor.*calcyfactor));
    offsetfactor = OffsetMagnitude(loops).^(-0.5);
    totalunc = 0.5*offsetfactor.*factor;
                                             %uncertainty calculation for offset magnitude                                            
    
    sizeA = size(A);
    sizeZ = 2*size(Counts);
    Z = zeros(sizeZ(1),sizeZ(1),3);
    
    Z(1:sizeA(1),1:sizeA(2),:) = A(1:sizeA(1),1:sizeA(2),:);
    
    if loops == 1
        AllCounts = Counts;
        AllChosen = Alt;
        Unit = Altunit;
        Offsetx = Realoffsetx;
        Offsety = Realoffsety;
        UncX = calcUncX;
        UncY = calcUncY;
        TotalUnc = totalunc;
        
        figure
        tracker = errorbar(OffsetMagnitude,TotalUnc);
        title 'Offset tracker'
        xlabel({'Frame number'});
        ylabel({'Offset/microns'});
       
    else
        AllCounts = cat(3,AllCounts,Counts);
        AllChosen = cat(3,AllChosen,Alt);
        Unit = cat(2,Unit,Altunit);
        Offsetx = cat(2,Offsetx,Realoffsetx);
        Offsety = cat(2,Offsety,Realoffsety);
        UncX = cat(2,UncX,calcUncX);
        UncY = cat(2,UncY,calcUncY);
        TotalUnc = cat(2,TotalUnc,totalunc);
        
        set(tracker,'YData',OffsetMagnitude,'UData',TotalUnc,'LData',TotalUnc);
        
    end                   %Creates a variable AllOverlays which stores one 
                           %RGB overlay per loop into a 4D matrix in the form (r,g,b,loops)
                     %Creates a variable AllCounts which stores all
                     %count plots into a 3D matrix in the form (:,:,loops)
                %Creates a variable AllChosen which stores all of the
                %images that have been cross-correlated with counts into a
                %3D matrix in the form (:,:,loops)
  
    
end
    
end