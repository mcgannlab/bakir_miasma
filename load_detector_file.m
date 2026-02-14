function [ det_mask, det_mask_stack] = load_detector_file( detfilepath, detfilename, Num_Rows, Num_Columns )
%load_detector_file(detfilepath, detfilename);
%   Detailed explanation goes here


show_detectors = 1;

%LOAD DETECTOR FILE
cd(char(detfilepath));
    disp(char(detfilename));
    fid_detfile = fopen(char(detfilename));
        try
        fseek(fid_detfile,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
        catch
            st = ['Selected Detector File Was Not Found']
            msgbox(st)
            return
        end
        
finished = 0;
linenumber = 1;
totallines = 1;
totaldetectors = 1;
detectornumber = 1;
while finished ~= 1;
    nextline=fgetl(fid_detfile);
    if nextline == -1
        finished = 1;
        totaldetectors = totaldetectors-1;
        totalpixels = totallines - totaldetectors;
        %sprintf('%d detectors and %d total pixels', totaldetectors, totalpixels)
        break
    end

    if nextline ~= ',' 
        detectorpixels(detectornumber, linenumber) = str2num(nextline);
        detectorpixels;
    else
        numpixels_per_detector(detectornumber) = linenumber-1;
        detectornumber = detectornumber +1;
        linenumber = 0;
        totaldetectors = totaldetectors + 1;
    end
    linenumber = linenumber + 1;
    totallines = totallines + 1;
end

%MAKE MASK BASED ON ROIs
    det_mask = zeros(Num_Rows, Num_Columns);
    for k = 1:totaldetectors %for each detector
        for l= 1:numpixels_per_detector(k) %for each pixel in the detector list find coordinates
            detectorpixels(k,l);
            pixelrow = ceil(detectorpixels(k,l)/Num_Columns);
            %pixelcolumn = mod(int32(detectorpixels(k,l)), int32(Num_Columns))
            pixelcolumn = detectorpixels(k,l)-((pixelrow-1)*Num_Columns);  %this is a more intuitive way to calculate
            det_mask(pixelrow, pixelcolumn) = 1; %color it white
        end
        det_mask = logical(det_mask);
        det_mask_stack(:,:,k) = det_mask;
    end 
    
    if show_detectors == 1
        figure_handle=figure();
        set(figure_handle,'Numbertitle','off','Name','ROI Masks')
        for k = 1:totaldetectors
            imshow(det_mask_stack(:,:,k));
            drawnow;
            pause(1);
        end
    end
    display('ROI detector file loaded, ROI image mask made');
end

