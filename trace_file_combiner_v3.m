function [ output_args ] = trace_file_combiner_v3( input_args )
%TRACE_FILE_COMBINER_V3 Call without argument opens Excel file listing traces files
%   Detailed explanation goes here
[rdfile, pathname]=uigetfile({'*.xls','Excel File (*.xls)'}, 'Choose data file');
if isequal(rdfile,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(pathname,rdfile)]);
end

[numericaldata, stringdata]= xlsread([pathname,rdfile]);        %Reads excel file data
 s_num = size(numericaldata,1);
 s_string=size(stringdata,1);
 m=msgbox('Combining trace files...');


for i=1:(s_string(1)-4)
    input_filenames(i) = strcat(stringdata(i+4,2),'.mat');  %iteratively make filenames for each row in spreadsheet - use plus1 to skip header
    input_filepaths(i) = stringdata(i+4,1);
%    Comments_List(i) = stringdata(i+1,2); %initially load filenames into comment field
end
    output_filepath = stringdata(2,1);
    output_filename = stringdata(2,2);
    output_filename = strcat(output_filename, '_comptraces.mat');
    Filename_List = input_filenames;

for j=1:(s_string-4)  %FOR each line in the excel spreadsheet except the header

    cd(char(input_filepaths(j)));
    load(char(input_filenames(j)), 'DF_ROI_Waveforms', 'DF_sHP_ROI_Waveforms', 'DF_sLP_ROI_Waveforms');
    load(char(input_filenames(j)), 'DFperF_ROI_Waveforms', 'DFperF_sHP_ROI_Waveforms', 'DFperF_sLP_ROI_Waveforms');
    load(char(input_filenames(j)), 'BNC', 'Base_Filename', 'Sampling_Rate', 'comments_field', 'History', 'det_mask');
    load(char(input_filenames(j)), 'Experimenter', 'Mag_Factor', 'Notes', 'Optics', 'Stimulus');
    try
        load(char(input_filenames(j)), 'Xdeviations', 'Ydeviations');
        load(char(input_filenames(j)), 'Day', 'Month', 'Year', 'Hour', 'Minute', 'Second');
        XYdevs_loaded = 1;
    catch
        XYdevs_loaded = 0;
    end

    if j ==1
        %initialize 3D arrays of traces, where each row is an ROI, each
        %column is a frame and each z dimension is a trial (e.g. one traces file
        %per trial - or at least per initial Neuroplex file)
        DF_ROI_Waveforms_3D = zeros(size(DF_ROI_Waveforms,1), size(DF_ROI_Waveforms,2), size(s_string,1)-1);
        DF_sHP_ROI_Waveforms_3D = zeros(size(DF_ROI_Waveforms,1), size(DF_ROI_Waveforms,2), size(s_string,1)-1);
        DF_sLP_ROI_Waveforms_3D = zeros(size(DF_ROI_Waveforms,1), size(DF_ROI_Waveforms,2), size(s_string,1)-1);
        DFperF_ROI_Waveforms_3D = zeros(size(DFperF_ROI_Waveforms,1), size(DFperF_ROI_Waveforms,2), size(s_string,1)-1);
        DFperF_sHP_ROI_Waveforms_3D = zeros(size(DFperF_ROI_Waveforms,1), size(DFperF_ROI_Waveforms,2), size(s_string,1)-1);
        DFperF_sLP_ROI_Waveforms_3D = zeros(size(DFperF_ROI_Waveforms,1), size(DFperF_ROI_Waveforms,2), size(s_string,1)-1);
        BNC_3D = zeros(size(BNC, 1), (size(BNC,2)), size(s_string,1)-1);
        if XYdevs_loaded == 1
            Xdeviations_3D = zeros(size(Xdeviations,1), size(Xdeviations,2), size(s_string,1)-1);
            Ydeviations_3D = zeros(size(Ydeviations,1), size(Ydeviations,2), size(s_string,1)-1);
        end
    end

    DF_ROI_Waveforms_3D(:,:,j) = DF_ROI_Waveforms;
    DF_sHP_ROI_Waveforms_3D(:,:,j) = DF_sHP_ROI_Waveforms;
    DF_sLP_ROI_Waveforms_3D(:,:,j) = DF_sLP_ROI_Waveforms;    
    DFperF_ROI_Waveforms_3D(:,:,j) = DFperF_ROI_Waveforms;
    DFperF_sHP_ROI_Waveforms_3D(:,:,j) = DFperF_sHP_ROI_Waveforms;
    DFperF_sLP_ROI_Waveforms_3D(:,:,j) = DFperF_sLP_ROI_Waveforms; 
    BNC_3D(:,:,j) = BNC;
    
    if XYdevs_loaded == 1
        Xdeviations_3D(:,:,j) = Xdeviations;
        Ydeviations_3D(:,:,j) = Ydeviations;
    end
    Comments_List{j}=comments_field;
    History_List_2D{:,j}=History;
    Experimenter_List{j} = Experimenter;
    Optics_List{j} = Optics;
    Stimulus_List{j} = Stimulus;
    Notes_List{j} = Notes;
    Mag_Factor_List{j} = Mag_Factor;
    Day_List{j} = Day;
    Month_List{j} = Month;
    Year_List{j} = Year;
    Hour_List{j} = Hour;
    Minute_List{j} = Minute;
    Second_List{j} = Second;
    det_mask_3D(:,:,j) = det_mask;
    
    status=fclose('all');
end

%NOW EXPORT TO A NEW COMPILED TRACES FILE
cd(char(output_filepath));
save(char(output_filename), 'DF_ROI_Waveforms_3D', 'DF_sHP_ROI_Waveforms_3D', 'DF_sLP_ROI_Waveforms_3D');
save(char(output_filename), 'DFperF_ROI_Waveforms_3D', 'DFperF_sHP_ROI_Waveforms_3D', 'DFperF_sLP_ROI_Waveforms_3D', '-append');
save(char(output_filename), 'BNC_3D', 'Base_Filename', 'Sampling_Rate', 'Filename_List', 'Comments_List', 'det_mask_3D', 'History_List_2D', '-append');
save(char(output_filename), 'Experimenter_List', 'Mag_Factor_List', 'Notes_List', 'Optics_List', 'Stimulus_List', '-append');
if XYdevs_loaded == 1
    save(char(output_filename), 'Xdeviations_3D', 'Ydeviations_3D', '-append');
    save(char(output_filename), 'Day_List', 'Month_List', 'Year_List', 'Hour_List', 'Minute_List', 'Second_List', '-append');

end

status=fclose('all');
delete(m);
m=msgbox('Trace compilation complete.');
end

