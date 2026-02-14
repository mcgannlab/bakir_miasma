function [ output_args ] = batch_map_extracter_v2( input_args )
%BATCH_MAP_EXTRACTER_V2 call without argument takes excel file listing
%procv files and windows for averaging
% function for batch loading of preprocessed _procv1 files based on excel
%spreadsheet and extracting difference maps averaging over the frames
%specified in the spreadsheet

[rdfile, pathname]=uigetfile({'*.xls','Excel File (*.xls)'}, 'Choose Excel input file');
if isequal(rdfile,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(pathname,rdfile)]);
end

[numericaldata, stringdata]= xlsread([pathname,rdfile]);        %Reads excel file data
 s_num = size(numericaldata, 1)
 s_string=size(stringdata, 1)

m=msgbox('Extracting maps...'); 
 
output_filepath = stringdata(2, 1);
output_filename = stringdata(2, 2);
output_filename = strcat(output_filename, '_maps.mat');

for i=1:s_num
    input_filenames(i) = strcat(stringdata(i+7,2),'.mat');  %iteratively make filenames for each row in spreadsheet - use plus1 to skip header
    input_filepaths(i) = stringdata(i+7,1);
    Map_Labels_List(i) = stringdata(i+7,5); %load user provided descriptions for each map
    firstframe(i) = numericaldata(i, 1);
    if firstframe(i) ~= -1
        lastframe(i) = numericaldata(i, 2);
    end
end

for j=1:s_num  %FOR each line in the excel spreadsheet except the header
    disp(strcat('Processing: ',input_filenames(j)))
    %first, go get all six difference maps over the averaging window, plus
    %the RLI (the 99 code means return all 7 images) and store in All Maps
    if firstframe(j) == -1
        try
            cd(char(input_filepaths(j)));
        catch
            disp(strcat('Could not find this directory:', input_filepaths(j)));
            delete(m);
            return
        end
        try
            load(char(input_filenames(j)), 'max_projection', 'RLI_Frame');
        catch
            disp(strcat('Could not load max projection from this file:', input_filenames(j)));
            delete(m);            
            return
        end
        %assemble projection into maps format
        current_maps(:,:,1) = max_projection.DF;
        current_maps(:,:,2) = max_projection.DF_sHP;
        current_maps(:,:,3) = max_projection.DF_sLP;
        current_maps(:,:,4) = max_projection.DFperF;
        current_maps(:,:,5) = max_projection.DFperF_sHP;
        current_maps(:,:,6) = max_projection.DFperF_sLP;
        current_maps(:,:,7) = RLI_Frame;
    else
        try
            current_maps = load_avg_frame_from_procv1(input_filenames(j), input_filepaths(j), firstframe(j), lastframe(j), 99);
        catch
            display(strcat('Could not load from this file:',input_filenames(j), ' or this path:', input_filepaths(j)));
            delete(m);
            return
        end
    end
    All_Maps(:,:,:,j) = current_maps(:,:,:); %this is a 4 dimensional array, it normally holds seven 256x256 images for each file
        
    %now go get the misc meta-data from the procv1 files
    cd(char(input_filepaths(j)));
    load(char(input_filenames{j}), 'History', 'Sampling_Rate', 'Stimulus', 'Mag_Factor', 'Optics', 'Experimenter', 'Notes', 'Base_Filename');
    load(char(input_filenames{j}), 'Day', 'Month', 'Year', 'Hour', 'Minute', 'Second');
    Sampling_Rate_List(j) = Sampling_Rate;
    Stimulus_List{j} = Stimulus;
    Mag_Factor_List{j} = Mag_Factor;
    Optics_List{j} = Optics;
    Experimenter_List{j} = Experimenter;
    Notes_List{j} = Notes;
    Base_Filename_List{j} = Base_Filename;
    Day_List{j} = Day;
    Month_List{j} = Month;
    Year_List{j} = Year;
    Hour_List{j} = Hour;
    Minute_List{j} = Minute;
    Second_List{j} = Second;
    if firstframe(j) == -1
        History{size(History,2)+1}={char(strcat('Extracted maximum projection.'))};
    else
        History{size(History,2)+1}={char(strcat('Averaged frames between ',num2str(firstframe(j)), ' and ', num2str(lastframe(j))))};
    end
    History_List{:,j} = History;
    
    clear('History', 'Sampling_Rate', 'Stimulus', 'Mag_Factor', 'Optics', 'Experimenter', 'Notes', 'Base_Filename');
    clear('Day', 'Month', 'Year', 'Hour', 'Minute', 'Second');
    clear 'current_maps';
end

%now calculate average maps
total_DF_map = zeros(size(All_Maps,1),size(All_Maps,2));
total_DF_sHP_map = zeros(size(All_Maps,1),size(All_Maps,2));
total_DF_sLP_map = zeros(size(All_Maps,1),size(All_Maps,2));
total_DFperF_map = zeros(size(All_Maps,1),size(All_Maps,2));
total_DFperF_sHP_map = zeros(size(All_Maps,1),size(All_Maps,2));
total_DFperF_sLP_map = zeros(size(All_Maps,1),size(All_Maps,2));
total_RLI_map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_DF_Map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_DF_sHP_Map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_DF_sLP_Map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_DFperF_Map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_DFperF_sHP_Map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_DFperF_sLP_Map = zeros(size(All_Maps,1),size(All_Maps,2));
Avg_RLI_Map = zeros(size(All_Maps,1),size(All_Maps,2));

num_files = size(All_Maps,4);
for x=1:num_files
   total_DF_map = total_DF_map + All_Maps(:,:,1,x);
   total_DF_sHP_map = total_DF_sHP_map + All_Maps(:,:,2,x);
   total_DF_sLP_map = total_DF_sLP_map + All_Maps(:,:,3,x);
   total_DFperF_map = total_DFperF_map + All_Maps(:,:,4,x);
   total_DFperF_sHP_map = total_DFperF_sHP_map + All_Maps(:,:,5,x);
   total_DFperF_sLP_map = total_DFperF_sLP_map + All_Maps(:,:,6,x);
   total_RLI_map = total_RLI_map + All_Maps(:,:,7,x);
end

Avg_DF_Map = total_DF_map/num_files;
Avg_DF_sHP_Map = total_DF_sHP_map/num_files;
Avg_DF_sLP_Map = total_DF_sLP_map/num_files;
Avg_DFperF_Map = total_DFperF_map/num_files;
Avg_DFperF_sHP_Map = total_DFperF_sHP_map/num_files;
Avg_DFperF_sLP_Map = total_DFperF_sLP_map/num_files;
Avg_RLI_Map = total_RLI_map/num_files;

%combine into a 3D array for later extraction by Maps Browser
%store individual frames too for convenience?
Avg_Maps = zeros(size(Avg_DF_Map, 1), size(Avg_DF_Map, 2),7);
Avg_Maps(:,:,1) = Avg_DF_Map;
Avg_Maps(:,:,2) = Avg_DF_sHP_Map;
Avg_Maps(:,:,3) = Avg_DF_sLP_Map;
Avg_Maps(:,:,4) = Avg_DFperF_Map;
Avg_Maps(:,:,5) = Avg_DFperF_sHP_Map;
Avg_Maps(:,:,6) = Avg_DFperF_sLP_Map;
Avg_Maps(:,:,7) = Avg_RLI_Map;

cd(char(output_filepath));
save(char(output_filename), 'All_Maps', 'History_List', 'Sampling_Rate_List', 'Stimulus_List', 'Mag_Factor_List', 'Optics_List', 'Experimenter_List', 'Notes_List');
save(char(output_filename), 'Base_Filename_List', 'Day_List', 'Month_List', 'Year_List', 'Hour_List', 'Minute_List', 'Second_List','-append');
save(char(output_filename), 'Avg_DF_Map', 'Avg_DF_sHP_Map', 'Avg_DF_sLP_Map', 'Avg_DFperF_Map', 'Avg_DFperF_sHP_Map', 'Avg_DFperF_sLP_Map', 'Avg_RLI_Map', '-append');
save(char(output_filename), 'Avg_Maps', 'Map_Labels_List','-append');
status=fclose('all');

delete(m);
m=msgbox('Map Extraction Complete');
end

