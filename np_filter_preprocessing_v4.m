function [ output_args ] = NP_filter_preprocessing_v2(varargin)
%NP_FILTER_PREPROCESSING Takes filename, filepath, outputpath,
%baselinestart, baselineend, GaussianSigma, Nyquist_fraction, stimulus, mag_factor, optics, experimenter, notes, Preferences)
%
%Reads raw Neuroplex or TurboSM file, creates a movie of differences relative
%to user-defined baseline. Then median filters that movie, and applies spatial filtering to 
%create three parallel versions - unfiltered, high pass filtered, and low-pass filtered.
%These are displayed and also saved in a rich matlab file that will be much
%bigger than the original Neuroplex file.
% 

%PREFERENCES SECTION
if nargin == 13 %if passed arguments including preferences set them up
    Preferences = varargin{13};
    denoise_with_median_filter_on_difference_movie=Preferences.preprocessing.medianfilter_setting;
    temporally_filter_difference_movies = Preferences.preprocessing.temporalfilter_setting; 
    crop_rawdata = Preferences.preprocessing.cropframes_setting;
    cropping_firstframetoinclude = Preferences.preprocessing.crop_firstframe_setting; 
    cropping_lastframetoinclude= Preferences.preprocessing.crop_lastframe_setting;
    enable_PDF_output =Preferences.preprocessing.save_map_PDF_setting;
else %use hard-coded parameters 
    denoise_with_median_filter_on_difference_movie = 1; %set to 0 to suppress median filtering or 1 to allow it
    temporally_filter_difference_movies = 1; %set to 1 to somewhat gently apply temporal filtering to all movies, 0 to suppress
    enable_PDF_output = 0; %set to 1 to save the final frames of the movie as a PDF (useful for spH), or 0 to turn this off 
    crop_rawdata = 0; %set to 1 to temporally crop the data based on the following parameters
    cropping_firstframetoinclude = 253;
    cropping_lastframetoinclude = 325;
end

%set up local parameters used for debugging or unusual tweaks
enable_output = 1; %set to 0 to suppress the writing of a new output file or 1 to allow it
debug_mode = 0; %set to 0 to clear memory after run or to 1 to preserve memory
save_single_precision = 1; %save output data as single precision floating point instead of double to save space
show_comparison_movies = 0; %set to 0 to suppress movies or 1 to play
scale_movies_by_individual_frames = 0; %set to 1 to set movie max/min for each frame, or 0 to scale off global max across frames
blackout_threshold = 100; %Threshold RLI value to black out. Set to larger numbers to blackout larger parts of image. Low number helps with vignetting -> infinite DF/F

%display warnings if unusual settings detected
if temporally_filter_difference_movies == 0
    display('Warning: NO TEMPORAL FILTERING WILL BE APPLIED');
end
if crop_rawdata == 1
    display('Warning:Raw Data will be cropped as specified in the preferences.')
    display(strcat('first frame included is #',num2str(cropping_firstframetoinclude)));
    display(strcat('last frame included is #',num2str(cropping_lastframetoinclude)));
end
if denoise_with_median_filter_on_difference_movie == 0
    display('WARNING: Denoising median filter is turned off.');
end
if enable_output == 0
    display('Warning: NO OUTPUT FILES WILL BE WRITTEN!');
end


%PARSE THE INPUT ARGUMENTS, IF ANY
switch nargin
%     case 0  %if no arguments passed, prompt for filename
%         [rdfile, pathname]=uigetfile({'*.da','Neuroplex File (*.da)'}, 'Choose data file');
%         output_pathname = pathname;
%         Baseline_startframe_string = inputdlg('What is the first frame for the baseline measurement?');
%         Baseline_startframe = str2num(Baseline_startframe_string{1});
%         Baseline_endframe_string = inputdlg('What is the final frame for the baseline measurement?');
%         Baseline_endframe = str2num(Baseline_endframe_string{1});
%         Gaussian_sigma_string = inputdlg('What standard deviation for the Gaussian spatial filter in pixels?');
%         Gaussian_sigma = str2num(Gaussian_sigma_string{1});
%         Nyquist_fraction_string = inputdlg('What fraction of the Nyquist frequency for temporal filtering (0-1)?'); 
%         Nyquist_fraction = str2num(Nyquist_fraction_string{1});
%         Stimulus = inputdlg('What stimulus was presented?');
%         Mag_Factor = inputdlg('What was the magnifaction factor in pixels/100 microns?');
%         Optics = inputdlg('What optics were used (objective, coupler, etc)');
%         Experimenter = inputdlg('Who did the experiment?');
%         Notes = inputdlg('Any other notes?');
    case 13  %if full set of arguments passed, fill in the variables
        rdfile = char(varargin{1});
        pathname = char(varargin{2});
        output_pathname = char(varargin{3});
        Baseline_startframe = varargin{4};
        Baseline_endframe = varargin{5};
        Gaussian_sigma = varargin{6};
        Nyquist_fraction = varargin{7};
        Stimulus = varargin{8};
        Mag_Factor = varargin{9};
        Optics = varargin{10};
        Experimenter = varargin{11};
        Notes = varargin{12};
    otherwise
        display('This function takes 13 arguments including Preferences struct. Direct calls are deprecated as of Miasma v1.2.');
        return
end

%set up filenames and types
switch rdfile(end-2:end)
    case '.da'
        base_rdfile = rdfile(1:(length(rdfile)-3)); %strip off the original '.da' for future use in filename
        filetype = 1; %this is a Neuroplex file
        filetype_label = 'Neuroplex';
    case 'tsm'
        base_rdfile = rdfile(1:(length(rdfile)-4)); %strip off the original '.tsm' for future use in filenames
        filetype = 2; %this is a TurboSM file
        filetype_label = 'TurboSM';
    otherwise
        display(strcat('Could not find file ', rdfile));
        display('Filetype extension must be included in spreadsheet or input arguments. Add the .da or .tsm!');
        return
end
        
devs_filename = strcat(base_rdfile, '_XYdev.mat');        
History{1} = {base_rdfile};


% OPEN THE DATA FILE AND EXTRACT THE OPTICAL AND A-TO-D DATA
try
    cd(char(pathname));
catch
    display(strcat('Could not find directory: ', char(pathname)));
    return
end

switch filetype
    case 1
        try
            [Data_3D, BNC, Sampling_Rate, Dark_Frame, comments_field] = load_NP_data(rdfile, pathname);
        catch
            display(strcat('Could not load Neuroplex file:', rdfile));
            return
        end
    case 2
        try
            TurboSM_dataset = load_TurboSM_data(rdfile, pathname);
        catch
            display(strcat('Could not load TurboSM file:', rdfile));
            return
        end
        Data_3D = TurboSM_dataset.Optical_Data;
        BNC = TurboSM_dataset.Analog_Data;
        Sampling_Rate = TurboSM_dataset.Sampling_Rate;
        Dark_Frame = TurboSM_dataset.Dark_Frame;
        comments_field = TurboSM_dataset.Comments;
        clear TurboSM_dataset;
end
[Num_Rows, Num_Columns, Num_Frames] = size(Data_3D);
[Num_BNC_Frames, Num_BNC_Channels] = size(BNC);      


firstframe = Data_3D(:, :, 1);
display('---------------------------------------------------------');
status_string = strcat('Data Loaded:', rdfile);   
display(char(status_string));

try
    load(devs_filename, 'Xdeviations', 'Ydeviations');
    %if it's a motion corrected file, then load the original file's
    %time and date info from the XY devs file
    load(devs_filename, 'Day', 'Month', 'Year', 'Hour', 'Minute', 'Second');
    XYdevs_loaded = 1;
    display('Motion Correction Records Found and Included');
catch
    XYdevs_loaded = 0;
    %if not a motion corrected file, then get the time and date
    %info from the current file and add zeroed out motion
    %correction reords

    % Get individual components of date & time in 1 Sec resolution
    FileInfo = dir(char(rdfile));
    [Year, Month, Day, Hour, Minute, Second] = datevec(FileInfo.datenum);

    Xdeviations = zeros(1,Num_Frames);
    Ydeviations = zeros(1,Num_Frames);
    display('No Motion Correction Records Found, Zero motion correction record entered.');
end

if crop_rawdata == 1
    Data_3D = Data_3D(:,:,cropping_firstframetoinclude:cropping_lastframetoinclude);
    Xdeviations = Xdeviations(cropping_firstframetoinclude:cropping_lastframetoinclude);
    Ydeviations = Ydeviations(cropping_firstframetoinclude:cropping_lastframetoinclude);
    
    BNC_frame_ratio = Num_BNC_Frames / Num_Frames; %figure out BNC sampling freq
    first_BNC_frame = cropping_firstframetoinclude * BNC_frame_ratio;
    last_BNC_frame = cropping_lastframetoinclude * BNC_frame_ratio;
    BNC = BNC(first_BNC_frame:last_BNC_frame,:);
       
    Num_Frames = cropping_lastframetoinclude - cropping_firstframetoinclude+1;
    [Num_BNC_Channels, Num_BNC_Frames] = size(BNC);
    display('Cropped data to include only specified frames');
end
        
% Create RAW DIFFERENCE MOVIES based on DF-F and (DF-F)/F
    baselineimage = zeros(Num_Rows, Num_Columns);
    measurement_image = zeros(Num_Rows, Num_Columns);
    Data_3D_DF = Data_3D; %copy initial dataset - note, should really preallocate size instead
    Data_3D_DFperF = Data_3D; %copy initial dataset - note, should really preallocate size instead

    for q = 1:Num_Rows; %calculate average frame for baseline 
      for p = 1:Num_Columns;
         baselineimage(q,p) = mean(Data_3D(q,p,Baseline_startframe:Baseline_endframe));
      end
    end
   RLI_Frame = baselineimage;        
   for i= 1:Num_Frames %overwrite each frame with difference image
       Data_3D_DF(:,:,i) = Data_3D(:,:,i) - baselineimage; 
       Data_3D_DFperF(:,:,i) = Data_3D_DF(:,:,i)./baselineimage;
   end

   %now blank out any NaNs produced by division by zero
   NANindex = isnan(Data_3D_DFperF);
   Data_3D_DFperF(NANindex)= 0;
   
   history_string1 = strcat('Made Difference Maps Based on Frames ', num2str(Baseline_startframe), ' to ', num2str(Baseline_endframe));
   History(size(History,2)+1)={history_string1};

   if denoise_with_median_filter_on_difference_movie == 1;
       for i= 1:Num_Frames %overwrite each frame with 3x3 median filtered image
           Data_3D_DF(:,:,i) = medfilt2(Data_3D_DF(:,:,i));
           Data_3D_DFperF(:,:,i) = medfilt2(Data_3D_DFperF(:,:,i));
       end
       history_string5 = 'median filtered 3x3';
       History(size(History,2)+1)={history_string5};
   end
       
%Create SPATIALLY FILTERED DIFFERENCE MOVIES
       %construct Gaussian filter - stdev should be the number of pixels that equal about 200 um
       %the kernel size should be about 5 times the stdev to ensure enough
       %of the function gets used
       Data_3D_DF_sHP = Data_3D_DF; %copy initial dataset - note, should really preallocate size instead
       Data_3D_DF_sLP = Data_3D_DF; %copy initial dataset - note, should really preallocate size instead
       Data_3D_DFperF_sHP = Data_3D_DFperF; %copy initial dataset - note, should really preallocate size instead
       Data_3D_DFperF_sLP = Data_3D_DFperF; %copy initial dataset - note, should really preallocate size instead
       filter_kernel_width = round(Gaussian_sigma*5); %round to nearest whole number
       if rem(filter_kernel_width,2) == 0; %if it's an even number, add one to make it odd (so kernel centers on pixel)
           filter_kernel_width = filter_kernel_width +1;
       end
       Gaussianfilter = fspecial('gaussian', [filter_kernel_width, filter_kernel_width], Gaussian_sigma);
       %original settings: fspecial('gaussian', [33, 33], 11.2);
       
       for i = 1:Num_Frames
           Data_3D_DF_sLP(:,:,i) = filter2(Gaussianfilter, Data_3D_DF(:,:,i));
           Data_3D_DFperF_sLP(:,:,i) = filter2(Gaussianfilter, Data_3D_DFperF(:,:,i));
           Data_3D_DF_sHP(:,:,i) = Data_3D_DF(:,:,i) - Data_3D_DF_sLP(:,:,i);
           Data_3D_DFperF_sHP(:,:,i) = Data_3D_DFperF(:,:,i) - Data_3D_DFperF_sLP(:,:,i);
       end
             
       %compute maximum projections for each movie and store as struct
       max_projection.DF = max(Data_3D_DF,[],3);
       max_projection.DF_sHP = max(Data_3D_DF_sHP,[],3);
       max_projection.DF_sLP = max(Data_3D_DF_sLP,[],3);
       max_projection.DFperF = max(Data_3D_DFperF,[],3);
       max_projection.DFperF_sHP = max(Data_3D_DFperF_sHP,[],3);
       max_projection.DFperF_sLP = max(Data_3D_DFperF_sLP,[],3);
       blackout_indices = find(RLI_Frame<blackout_threshold);
       max_projection.DF(blackout_indices)=0;
       max_projection.blackout_threshold = blackout_threshold;
       max_projection.blackout_indices = blackout_indices;
       max_projection.num_pixels_blackedout = size(blackout_indices,1);
       
       history_string2 = strcat('Spatial filtered, Gaussian sigma ',num2str(Gaussian_sigma),' pixels');
       History(size(History,2)+1)={history_string2};
display('Done making spatially filtered movies');
       
% TEMPORALLY FILTER ALL OPTICAL DATA SETS - remember the Nyquist-Shannon Theorem!
if temporally_filter_difference_movies == 1
    h = waitbar(0, 'Temporal Filtering pixel by pixel');
    
    nyquist_limit = Sampling_Rate/2;
    cutoff_frequency = nyquist_limit * Nyquist_fraction; %Filter at up to the Nyquist limit
    [z,p,k] = butter(4, cutoff_frequency/nyquist_limit, 'low');
    [sos, g] = zp2sos(z,p,k);
    Hd = dfilt.df2tsos(sos, g);
    %h=fvtool(Hd); %this is an automated visualization of the filter properties
    %set(h, 'Analysis','freq'); 

    for x=1:Num_Rows
        parfor y=1:Num_Columns
            %for each pixel, filter the traces to eliminate aliased frequencies
            
            Data_3D_DF(x,y,:) = filter(Hd, Data_3D_DF(x,y,:));
            Data_3D_DF_sHP(x,y,:) = filter(Hd, Data_3D_DF_sHP(x,y,:));
            Data_3D_DF_sLP(x,y,:) = filter(Hd, Data_3D_DF_sLP(x,y,:));
            Data_3D_DFperF(x,y,:) = filter(Hd, Data_3D_DFperF(x,y,:));
            Data_3D_DFperF_sHP(x,y,:) = filter(Hd, Data_3D_DFperF_sHP(x,y,:));
            Data_3D_DFperF_sLP(x,y,:) = filter(Hd, Data_3D_DFperF_sLP(x,y,:));
        end
        %update waitbar every column
        waitbar(x/Num_Rows);
    end
    close(h);
    disp('Done temporally filtering optical data');
    history_string3 = strcat('LP Temporally filtered, 4th order Butterworth w/cutoff freq ',num2str(cutoff_frequency));
    History(size(History,2)+1)={history_string3};
end

%SHOW A MOVIE OF THE ANALYZED DATA
% Display a movie showing original frames next to motion corrected frames
if show_comparison_movies == 1;
    scrsz = get(0,'ScreenSize');
    figurehandle = figure('Position', [scrsz(3)/6 scrsz(4)/5 scrsz(3)/1.5 scrsz(4)/1.5]);
    figuretitle = strcat(base_rdfile, ' Spatial Freq Comparison');
    set(figurehandle,'Name', char(figuretitle), 'NumberTitle', 'off');
    
    %calculate the max and min across all frames of each movie
    DF_sHP_max = max(max(max(Data_3D_DF_sHP)));
    DF_sHP_min = min(min(min(Data_3D_DF_sHP)));    
    DF_sLP_max = max(max(max(Data_3D_DF_sLP)));
    DF_sLP_min = min(min(min(Data_3D_DF_sLP)));
    DF_max = max(max(max(Data_3D_DF)));
    DF_min = min(min(min(Data_3D_DF)));
    DFperF_sHP_max = max(max(max(Data_3D_DFperF_sHP)));
    DFperF_sHP_min = min(min(min(Data_3D_DFperF_sHP)));    
    DFperF_sLP_max = max(max(max(Data_3D_DFperF_sLP)));
    DFperF_sLP_min = min(min(min(Data_3D_DFperF_sLP)));
    DFperF_max = max(max(max(Data_3D_DFperF)));
    DFperF_min = min(min(min(Data_3D_DFperF)));   

    for x = 1:Num_Frames
        h=gcf();
        figure(h); 

        if scale_movies_by_individual_frames == 1
            %find max/min each frame, but exclude 15 pixel border
            DF_sHP_max = max(max(Data_3D_DF_sHP(15:241,15:241,x)));
            DF_sHP_min = min(min(Data_3D_DF_sHP(15:241,15:241,x)));    
            DF_sLP_max = max(max(Data_3D_DF_sLP(15:241,15:241,x)));
            DF_sLP_min = min(min(Data_3D_DF_sLP(15:241,15:241,x)));
            DF_max = max(max(Data_3D_DF(15:241,15:241,x)));
            DF_min = min(min(Data_3D_DF(15:241,15:241,x)));
            DFperF_sHP_max = max(max(Data_3D_DFperF_sHP(15:241,15:241,x)));
            DFperF_sHP_min = min(min(Data_3D_DFperF_sHP(15:241,15:241,x)));    
            DFperF_sLP_max = max(max(Data_3D_DFperF_sLP(15:241,15:241,x)));
            DFperF_sLP_min = min(min(Data_3D_DFperF_sLP(15:241,15:241,x)));
            DFperF_max = max(max(Data_3D_DFperF(15:241,15:241,x)));
            DFperF_min = min(min(Data_3D_DFperF(15:241,15:241,x))); 
        end

        %Display one frame at a time from each movie, update all at once
        rawDF_frame = Data_3D_DF(:,:,x);
        subplot(2,3,1);
        imshow(rawDF_frame, [DF_min DF_max]);
        image_title = strcat(strrep(base_rdfile, '_', '\_'), ' DeltaF frame ',num2str(x));
        title(image_title);

        DF_sHP_frame = Data_3D_DF_sHP(:,:,x);
        subplot(2,3,2);
        imshow(DF_sHP_frame, [DF_sHP_min DF_sHP_max]);
        title(['HP Spatial Filtered DeltaF frame ',num2str(x)]);

        DF_sLP_frame = Data_3D_DF_sLP(:,:,x);
        subplot(2,3,3);
        imshow(DF_sLP_frame, [DF_sLP_min DF_sLP_max]);
        title(['LP Spatial Filtered DeltaF frame ',num2str(x)])

        rawDFperF_frame = Data_3D_DFperF(:,:,x);
        subplot(2,3,4);
        imshow(rawDFperF_frame, [DFperF_min DFperF_max]);
        image_title = strcat(base_rdfile, ' DeltaF/F frame ',num2str(x));
        title(image_title);

        DFperF_sHP_frame = Data_3D_DFperF_sHP(:,:,x);
        subplot(2,3,5);
        imshow(DFperF_sHP_frame, [DFperF_sHP_min DFperF_sHP_max]);
        title(['HP Spatial Filtered DeltaF/F frame ',num2str(x)]);

        DFperF_sLP_frame = Data_3D_DFperF_sLP(:,:,x);
        subplot(2,3,6);
        imshow(DFperF_sLP_frame, [DFperF_sLP_min DFperF_sLP_max]);
        title(['LP Spatial Filtered DeltaF/F frame ',num2str(x)])  
        
        drawnow;
    end
    
    if enable_PDF_output == 1
        %save the output pictures as a PDF
        graph_filename = strcat(base_rdfile, '_procv1.pdf');
        graph_fullpath = strcat(char(output_pathname), '/',char(graph_filename));
        print ('-dpdf',char(graph_fullpath));
    end

end

% SAVE DATA IN MATLAB DATA FORMAT
if enable_output == 1
    if save_single_precision == 1
        Data_3D_DF = single(Data_3D_DF);
        Data_3D_DF_sHP = single(Data_3D_DF_sHP);
        Data_3D_DF_sLP = single(Data_3D_DF_sLP);
        Data_3D_DFperF = single(Data_3D_DFperF);
        Data_3D_DFperF_sHP = single(Data_3D_DFperF_sHP);
        Data_3D_DFperF_sLP = single(Data_3D_DFperF_sLP);
    end
    
    if crop_rawdata == 0
        outputfilename = strcat(base_rdfile, '_procv1.mat');
    else
        outputfilename = strcat(base_rdfile, '_cropped_procv1.mat');
    end
    output_fullpath = strcat(char(output_pathname), '/',char(outputfilename));
    display(char(output_fullpath));
    Base_Filename = base_rdfile;
    try
        save(output_fullpath, 'Data_3D_DF', 'Data_3D_DF_sHP', 'Data_3D_DF_sLP', 'Data_3D_DFperF', 'Data_3D_DFperF_sHP', 'Data_3D_DFperF_sLP', 'BNC', 'RLI_Frame', 'Data_3D');
        save(output_fullpath, 'Base_Filename', 'Num_Frames', 'Num_Columns', 'Num_Rows', 'Sampling_Rate','comments_field', 'History','Dark_Frame','-append');
        save(output_fullpath, 'Stimulus', 'Mag_Factor', 'Optics', 'Experimenter', 'Notes', 'filetype_label', '-append');        
        save(output_fullpath, 'Xdeviations', 'Ydeviations', 'max_projection', '-append');
        save(output_fullpath, 'Day', 'Month', 'Year', 'Hour', 'Minute', 'Second', '-append');
    catch
        display(strcat('Could not save:', output_fullpath));
        return
    end
end


% Close files and clear memory unless in debug mode
status = fclose('all');  %close all open files
if debug_mode == 0
    clear all
end

%end of function
end

