function [ CountMatrix, OtherMatrix, ChosenImageUnits, ScaledData, Units, RLlength, ImageIndex, Image2] = CaptureFileFormatFunction(CFnum,loops,a,b,Capture_folder )
%Opens the newest capture file given by the search function, and formats
%the file ready for the cross-correlation measurement. 

numID = num2str(CFnum);
CapFile = '\CaptureFile.';
CF = strcat(Capture_folder,CapFile);
filename = strcat(CF,numID);

fileID = fopen(filename);

% see http://www.nanophys.kth.se/nanophys/facilities/nfl/afm/fast-scan/bruker-help/Content/SoftwareGuide/FileFormats/HeaderFiles.htm
% for format of capture files (will be dependent upon Nanoscope version)

for i = 1:5
    tline = fgets(fileID);
end    %obtains the fifth line of the capture file - value indicates number of bytes until raw image data (length of the header information)

matchStr = regexp(tline,'\d+','match');   %obtains the number of bytes described above from the string and converts to double
StartVal = str2double(matchStr);

frewind(fileID);
HeaderInfo = fread(fileID,StartVal,'*char')';    %obtains all of the "pre-amble" in the capture file
                                                 %This contains the starting positions and lengths of all the image data


Datapos = regexp(HeaderInfo,'\\Data offset: (\d+)','tokens');   

N = size(Datapos);
Noffsets = N(2);

for i = 1:Noffsets
    offsets(i) = str2double(Datapos{1,i});     %uses an expression search to find the starting points (in bytes) of all images in the capture file
end                                              %converts these values to doubles ready for use with the fread command
                                                 %also obtains the number of images in the file using the size function
                                             

                                                
Datalengths = regexp(HeaderInfo,'\\Data length: (\d+)','tokens');

M = size(Datalengths);
Nlengths = M(2);

for i = 1:Nlengths
    lengths(i) = str2double(Datalengths{1,i});     %as before, but now looking for the lengths in bytes of each image data set, converting values to doubles for use with fread
end     

lengths(1) = [];                                 %the first elements in the lengths array will be the data from the fifth line of the capture file (length of the header, not the image) - remove this element
 

%--------------------------------------
%now have the positions and lengths of all the image data within the
%capture file stored as "offsets" and "lengths" arrays

if all(lengths == lengths(1))
    NOPixels = sqrt(lengths(1)/2);
else
    sprintf('Warning: images are not same size or are not square')
end

ImageData = zeros(NOPixels,NOPixels,Noffsets);

for j = 1:Noffsets
    fseek(fileID,offsets(j),'bof');
    ImageData(:,:,j) = fread(fileID,[NOPixels,NOPixels],'int16');
    ImageData(:,:,j) = rot90(ImageData(:,:,j));
end

%ImageData is a 3D matrix where each third dimension is a different image
%(eg, height, count, peak force error etc). The units up to here are still
%in volts - each image now needs to be scaled using parameters from the
%capture file header back to meaningful units.

%----------------------------Scaling from this point ---------------


ScalingInfo = regexp(HeaderInfo,'@2:Z scale: V \[(.*?)\] \((\d*\.?\d*) .*?\) (\d*.\d*)','tokens');

for i = 1:Noffsets
    ZScales(i) = str2double(ScalingInfo{1,i}{1,2});    
end              %Hardware scale factors


string1 = '\\@';
for i = 1:Noffsets
    string2{1,i} = ScalingInfo{1,i}{1,1};
end
string3 = ':.*?(\d+.?\d+) (\w*.?\w*.?)';

sensString = strcat(string1,string2,string3);    %Expressions to search for software scale factors in regexp

SensScales = regexp(HeaderInfo,sensString,'tokens');

for i = 1:Noffsets
softscale(i) = str2double(SensScales{1,i}{1,1}{1,1});     %software scale factors
end

%%The data can be converted back to real units from volts by multiplying
%%each pixel value by its hardware scale factor, followed by its software
%%scale factor.

for i = 1:Noffsets 
    ScaledData(:,:,i) = ImageData(:,:,i)*ZScales(i)*softscale(i); %This is the data scaled to real units
end


for i = 1:Noffsets
    fullunits{1,i} = SensScales{1,i}{1,1}{1,2};
end

remove = strrep(fullunits,'/V','');
remove2 = strrep(remove,'/Arb','');
remove3 = strrep(remove2,'/log(Arb)','');
Units = strrep(remove3,'/m*Arb','');


%%------ Plot all images and ask user which for cross-correlation below

labels = regexp(HeaderInfo,'Image Data: \w \[.*?\] "(.*?)"','tokens');    %creates an array of all image labels

ImageLabels=[labels{:}];

ImageCols = round(Noffsets/2);

if loops == 1
    

    figure
    for i = 1:Noffsets
        subplot(2,ImageCols,i)
        imagesc(ScaledData(:,:,i))
        title (ImageLabels(i))
    end
    

    prompt = 'Enter name of image to be cross-correlated with Count 1 \n';
    Image2 = input(prompt,'s');                     %asks the user which image they would like to cross-correlate with the count image

    ImageIndex = find(cellfun('length',regexpi(ImageLabels,Image2)) == 1);   %finds the position of the desired image within the ImageData matrix
    ErrorTest = isempty(ImageIndex);

    while ErrorTest == 1  
        prompt2 = 'Error: image could not be found. Make sure that title has been spelt correctly ';
        Image2 = input(prompt,'s'); 
        ImageIndex = find(cellfun('length',regexpi(ImageLabels,Image2)) == 1);
        ErrorTest = isempty(ImageIndex);
    end
    
else
    ImageIndex = a;
    Image2 = b;
end


CountIndex = find(cellfun('length',regexpi(ImageLabels,'count')) == 1);

CountMatrix = ScaledData(:,:,CountIndex);
OtherMatrix = ScaledData(:,:,ImageIndex);             %These are the two images chosen by the user to cross-correlate

ChosenImageUnits = Units(ImageIndex);  %these are the units of the chosen image


%below is the code to get image sizes in microns and test for size equality

SizeTest1 = regexp(HeaderInfo,'Scan Size: (\d+.?\d+) \d+.?\d+ .?m','tokens');
SizeTest2 = regexp(HeaderInfo,'Scan Size: \d+.?\d+ (\d+.?\d+) .?m','tokens');

tf = isequal(SizeTest1,SizeTest2);  %If this result is equal to 1 then all of the image sizes are the same


scansize = SizeTest1{1,1}{1,1};
RealLength = str2num(scansize);     %This is the real-life length to be supplied to the cross-correlation function
                                   %(provided that all images are the same
                                   %size)

RLunits = regexp(HeaderInfo,'Scan Size: \d+.?\d+ \d+.?\d+ (.?m)','tokens');
AUnits = [RLunits{1,:}];
test2 = numel(unique(AUnits)) == 1;      %Checks to see if all units are the same

RLunit = AUnits{1,1};

if tf == 0 & test2 == 0 
    sprintf('Warning: images are not the same size or are not square. Please repeat acquisition')
end


if RLunit == 'nm'
    RLlength = RealLength/1000;
else
    RLlength = RealLength;
end                               %converts the length to microns for the cross-correlate program if value is not already in microns

fclose(fileID);