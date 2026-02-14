function [Xdeviations, Ydeviations] = motion_correct_raw_Neuroplex_file_v2(varargin)
%MOTION_CORRECT_RAW_NEUROPLEX_FILE_V2 Arguments can be none or
%inputfilename, inputpath, outputpath

% this function takes an Neuroplex file and performs an automated pixel registration, 
%then writes a new Neuroplex file with _mcv1 appended to the filename
% the deviations are animated and graphed, which is saved to PDF

%this is an overloaded function - look to see what arguments you got, if
%any
switch nargin
    case 0 %if no arguments prompt for file and write to same directory
        [rdfile, pathname]=uigetfile({'*.da','Neuroplex File (*.da)'}, 'Choose data file');
        if isequal(rdfile,0)
           disp('User selected Cancel');
            return
        else
            disp(['User selected ', fullfile(pathname,rdfile)]);
        end
        output_pathname = pathname; 
    case 4 %if arguments passed, set up variables
        rdfile = char(varargin{1});
        pathname = char(varargin{2});
        output_pathname = char(varargin{3});
        reference_frame = varargin{4};
    otherwise
        display('This function requires 3 arguments or none')
end
        
base_rdfile = rdfile(1:(length(rdfile)-3)); %strip off the original '.da' for future use in filenames

%PREFERENCES SECTION
show_uncorrected_movie = 0; %set to 0 to suppress initial raw movie or to 1 to play it
do_motion_correction = 1; %set to 0 to suppress motion correction process
show_comparison_movies = 0; %set to 0 to suppress movies or 1 to play
enable_Neuroplex_output = 1; %set to 0 to suppress the writing of a new Neuroplex file or 1 to allow it
enable_PDF_output = 0; %set to 0 to suppress writing a PDF of the graph or 1 to allow it - requires movies be ON
debug_mode = 0; %set to 0 to clear memory after run or to 1 to preserve memory

% OPEN THE FILE AND EXTRACT THE IMAGE DATA
cd(char(pathname));
    fid = fopen(char(rdfile));
        try
        fseek(fid,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
        catch
            st = ['Selected Data File Was Not Found']
            msgbox(st)
            return
        end

        % Get individual components of date & time in 1 Sec resolution
        FileInfo = dir(char(rdfile));
        [Year, Month, Day, Hour, Minute, Second] = datevec(FileInfo.datenum);
        
        A = fread(fid,2560,'uint16');                   %Reads 2560 16-bit unsigned integer into variable A
        Num_Trials=A(2);    %>1 if avgd file
        Num_Frames = A(5);  %5th Integer
        Num_Rows = A(386);  %385th Integer
        Num_Columns = A(385); %386th Integer
        Num_Pixels = A(97); %97th Integer
        
        
        Frame_Interval = A(389); %100Hz:'10000', 50Hz: '20000', 25Hz:'4000'
        Dividing_Factor = A(391); %DivFactor=1 if FrameInt=>10000, else 10
        Sampling_Rate = 1000/((Frame_Interval/1000)*Dividing_Factor); 
        disp(sprintf('Number of Frames %d',Num_Frames)) ;

        BNCfactor = A(392);
        if BNCfactor == 0
        BNCfactor = 1;
        end
        
        size1 = -2*(Num_Rows)*(Num_Columns)-16; %is a negative number 'cause reads from end of file in next line
        
        %%%%%%%%%%%%
        %read comment
        fseek(fid,256,'bof');               %The static header text is 243 bytes long
        list_of_comments{1} = char((fread(fid,159,'char',1))');%Added text can be as long as 257 bytes
        
        %%%%%%%%%%%%
        
        fseek(fid,size1,'eof');    %seeks 25616 bytes from end of file, due to file structure in reading in dark frame?
        [Dark_Frame,count] = fread(fid,Num_Columns*Num_Rows,'int16');   %Reads in Dark Frame
        
        fseek(fid,5120,'bof');      %Seeks 5120 bytes from beginning of file to start loading data
        [Data,count] = fread(fid,Num_Frames*Num_Columns*Num_Rows,'int16'); %the number of integers to read
        %in would be the number of frames x number of columns x number of rows.
        [BNC, count] = fread(fid,Num_Frames*BNCfactor*8, 'int16');
        BNC = BNC'; %Transposes data from 1 row to 1 column
        BNC = reshape (BNC, Num_Frames*BNCfactor,8);
        
        
        Data = Data';   %Transposes data from 1 row to 1 column
        Data = reshape(Data, Num_Frames, Num_Columns* Num_Rows); %reshapes data into a 2D
        %matrix [number of frames x number of data points in each frame] ,
        %so each row is the data for each frame
        
        
        Data = Data'; %transpose data temporarily so that each column is a frame
        %for i=1:Num_Frames;  %then subtract dark frame from each
        %    Data(:,i)=Data(:,i)-Dark_Frame;
        %end

        Data_3D = reshape(Data, Num_Columns, Num_Rows, Num_Frames);
        Data_3D = (permute(Data_3D,[2 1 3])); %rotates frames for correct orientation
     clear Data; %free up this memory
        firstframe = Data_3D(:, :, 1);
        %imshow(firstframe, [min(min(firstframe)) max(max(firstframe))])        
               
        display('Data Loaded Successfully.');
        
% Sequentially display each frame of the original, uncorrected data
if show_uncorrected_movie == 1
    for x = 1:Num_Frames
            displayframe = Data_3D(:,:,x);
            imshow(displayframe, [min(min(displayframe)) max(max(displayframe))]);
            title(['Frame ',num2str(x)]);
            drawnow;
    end 
end


%make new Data block to store motion corrected images
if do_motion_correction == 1
    display('Beginning Motion Correction - This could take a while!')
    Data_corrected = Data_3D;

    % Compare each frame to next frame and adjust
    %remember, firstframe was created earlier...
    %This 2D rigid body motion correction algorithm adjusts each frame to match the original frame - more
    %complex algorithms are possible
    Xdeviations(1:Num_Frames) = 0;
    Ydeviations(1:Num_Frames) = 0;
    Frame_number(1:Num_Frames) = 0;
    error(1:Num_Frames)=0;
    waitbar_string = strcat('Motion Correcting ', strrep(base_rdfile, '_', '\_'));
    h = waitbar(0, char(waitbar_string));
    for x = 1:Num_Frames
        current_frame = Data_3D(:,:,x);
        [output, newimage_fft] = dftregistration(fft2(reference_frame),fft2(current_frame),10);
        Xdeviations(x) = output(4);
        Ydeviations(x) = output(3);
        error(x) = output(1);
        Frame_number(x) = x;
        new_image = ifft2(newimage_fft);
        Data_corrected(:,:,x) = new_image;
     %update waitbar every Frame
     waitbar(x/Num_Frames);
    end
    mean_error=mean(error);
    disp(strcat('Average error across frames: ', num2str(mean_error)));
    close(h); %close waitbar
end
    
% Display a movie showing original frames next to motion corrected frames
if show_comparison_movies == 1;
    scrsz = get(0,'ScreenSize');
    figurehandle = figure('Position', [scrsz(3)/6 scrsz(4)/5 scrsz(3)/1.5 scrsz(4)/1.5]);
    figuretitle = strcat(base_rdfile, ' Motion Correction');
    set(figurehandle,'Name', char(figuretitle), 'NumberTitle', 'off');
    
    for x = 1:Num_Frames
        h=gcf();
        figure(h);
        imagemin = min(min(abs(firstframe)));
        imagemax = max(max(abs(firstframe)));    
        subplot(2,3,1);
        imshow(abs(firstframe), [imagemin imagemax]);
        image_title = strcat(strrep(base_rdfile, '_', '\_'), ' First frame');
        title(image_title);

        original_frame = Data_3D(:,:,x);
        imagemin = min(min(abs(original_frame)));
        imagemax = max(max(abs(original_frame))); 
        subplot(2,3,2);
        imshow(abs(original_frame), [imagemin imagemax]);
        title(['Original frame',num2str(x)]);

        corrected_frame = Data_corrected(:,:,x);
        imagemin = min(min(abs(corrected_frame)));
        imagemax = max(max(abs(corrected_frame))); 
        subplot(2,3,3);
        imshow(abs(corrected_frame), [imagemin imagemax]);
        title(['Corrected frame',num2str(x)])

        drawnow;
    end
    s4 = subplot(2,3,[4 6]);
    plot(Frame_number, Xdeviations, Frame_number, Ydeviations);
    title(s4, 'Deviations by Frame');
    xlabel(s4, 'Frames');
    ylabel(s4, 'Pixels');
    legend(s4, 'X-deviations', 'Y-deviations');    
    drawnow;
    
    if enable_PDF_output == 1
        %save the output pictures as a PDF
        graph_filename = strcat(base_rdfile, '_mcv1.pdf');
        graph_fullpath = strcat(char(output_pathname), '\',char(graph_filename));
        print (figurehandle, '-dpdf',char(graph_fullpath));
    end
end 

%Now write the data to a new NeuroPlex file
if enable_Neuroplex_output == 1;
    %clear Data_3D; %free up memory!
    base_rdfile = rdfile(1:(length(rdfile)-3)); %strip off the original '.da'
    outputfilename = strcat(base_rdfile, '_mcv1.da');
    XYdev_outputfilename = strcat(base_rdfile, '_mcv1_XYdev.mat');
    display(char(outputfilename))
    

    %begin by duplicating the original file so we don't screw up headers,
    %etc
    output_fullpath = strcat(char(output_pathname), '\',char(outputfilename));
    copyfile(char(rdfile), char(output_fullpath));
    cd(char(output_pathname));    
     fid_output = fopen(char(outputfilename), 'r+');
         try
         fseek(fid_output,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
         catch
             st = ['Could not open file to write to']
             msgbox(st)
             return
         end
       
         %now rearrange the Data_corrected to be int16 (not complex) and
         %one long row listed one trace at a time
         %Data_3D = abs(Data_3D);
         %global Data_linear_output_oneTrace startingpoint endingpoint Data_corrected;
         Data_corrected = int16(abs(Data_corrected));
         Data_swap = permute(Data_corrected, [3 2 1]); %rearrange indices so colon operator references traces in sequence
         Data_linear = Data_swap(:); 
         fseek(fid_output,5120,'bof');      %Seeks 5120 bytes from beginning of file to start replacing data
         count = fwrite(fid_output,Data_linear,'int16');
         
          % would be the number of frames x number of columns x number of rows.
%     display('Data points written to file', num2str(count));
    save(XYdev_outputfilename, 'Xdeviations', 'Ydeviations', 'error', 'base_rdfile'); %save the XYdeviations as a matlab file for future use
    save(XYdev_outputfilename, 'Year', 'Month', 'Day', 'Hour', 'Minute', 'Second', '-append'); %save the original file creation time
end    

% Close files and clear memory
status = fclose('all');  %close all open files
if debug_mode == 0
    clear all
end


%end function
end
