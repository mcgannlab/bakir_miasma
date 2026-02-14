function [Xdeviations, Ydeviations] = motion_correct_TSM_file_v2(varargin)
%MOTION_CORRECT_TSM_FILE_V2 Arguments can be none or
%inputfilename, inputpath, outputpath, reference frame

% this function takes a TurboSM file and performs an automated pixel registration, 
%then writes a new TurboSM file with _mcv1 appended to the filename
% the deviations are animated and graphed, which is saved to PDF

%this is an overloaded function - look to see what arguments you got, if
%any
switch nargin
    case 0 %if no arguments prompt for file and write to same directory
        [rdfile, pathname]=uigetfile({'*.tsm','TurboSM File (*.tsm)'}, 'Choose data file');
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
        display('This function requires 4 arguments or none')
        return
end
        
base_rdfile = rdfile(1:(length(rdfile)-3)); %strip off the original '.tsm' for future use in filenames

%PREFERENCES SECTION
show_uncorrected_movie = 0; %set to 0 to suppress initial raw movie or to 1 to play it
do_motion_correction = 1; %set to 0 to suppress motion correction process
show_comparison_movies = 0; %set to 0 to suppress movies or 1 to play
enable_TSM_output = 1; %set to 0 to suppress the writing of a new Neuroplex file or 1 to allow it
enable_PDF_output = 0; %set to 0 to suppress writing a PDF of the graph or 1 to allow it - requires movies be ON
debug_mode = 0; %set to 0 to clear memory after run or to 1 to preserve memory

% OPEN THE FILE AND EXTRACT THE IMAGE DATA
cd(char(pathname));
Data=load_TurboSM_data(rdfile, pathname);
Num_Frames = size(Data.Optical_Data, 3);
Data_3D=Data.Optical_Data;
disp('Data Loaded Successfully.');
FileInfo = dir(char(rdfile));
[Year, Month, Day, Hour, Minute, Second] = datevec(FileInfo.datenum);

% Sequentially display each frame of the original, uncorrected data
if show_uncorrected_movie == 1
    for x = 1:Data.Frames
            displayframe = Data.Optical_Data(:,:,x);
            imshow(displayframe, [min(min(displayframe)) max(max(displayframe))]);
            title(['Frame ',num2str(x)]);
            drawnow;
    end 
end


%make new Data block to store motion corrected images
if do_motion_correction == 1
    disp('Beginning Motion Correction - This could take a while!')
    Data_corrected = Data.Optical_Data; %pre-allocate

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
if enable_TSM_output == 1
    %clear Data_3D; %free up memory!
    base_rdfile = rdfile(1:(length(rdfile)-4)); %strip off the original '.tsm'
    outputfilename = strcat(base_rdfile, '_mcv1.da');
    XYdev_outputfilename = strcat(base_rdfile, '_mcv1_XYdev.mat');
%    display(char(outputfilename));
    

    output_fullpath = strcat(char(output_pathname), '\',char(outputfilename));
    cd(char(output_pathname));    
    Data.Optical_Data=Data_corrected;
    write_NP_file(Data, char(outputfilename),char(output_pathname));
        
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
