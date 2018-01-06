function [ CFnum ] = CaptureFileSearchFunc( Newest, hmsg, Capture_folder  )
%Function continually scans the Capture directory until a new Capture file has been
%added to the folder. When a new capture file has been found, the loop is
%broken and the function returns the Capture file number.


    Previous = Newest;  %stores most recent file from previous loop before commencing new search
    while Newest <= Previous && ishandle(hmsg)      

        dirData = dir(Capture_folder);      
        fileList = {dirData.name}';

        FileMatch = regexp(fileList,'CaptureFile.\d+','match');  %looks for files named as CaptureFile.$$$

        emptyIndex = cellfun(@isempty,FileMatch);       %Find indices of empty strings                 
        FileMatch(emptyIndex) = {'0'};                   %replaces these with a zero string

        files = size(FileMatch);
        Nfiles = files(1);          %calculates number of files in the directory
       


        for i = 1:Nfiles
            FileNumbers(i) = regexp(FileMatch{i,1},'\d+','match');  
        end                         %non-zero elements in this cell are the capture files. Numbers are the .$$$ extensions of the capture files present
                            

        ArrayNum=[FileNumbers{:}];

        for i = 1:Nfiles
            NumFiles(i) = str2num(ArrayNum{1,i});  %#ok<ST2NM>
        end                         %converts capture file numbers to type double for finding the most recent


        Newest = max(NumFiles);   %Highest .$$$ and therefore most recent capture file
    

        CFnum = Newest;
       
        
        if Newest <= Previous
            pause(2);   %pauses for 2 seconds if no new capture file is found before repeating search
        end   
    end      
end

