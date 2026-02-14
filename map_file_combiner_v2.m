function [ output_args ] = map_file_combiner( input_args )
%MAPFILECOMBINER Extracts and recombines individual maps from maps file
%into new maps file based on Excel template
%   Detailed explanation goes here

[rdfile, pathname]=uigetfile({'*.xls','Excel File (*.xls)'}, 'Choose data file');
[numericaldata, stringdata]= xlsread([pathname,rdfile]);        %Reads excel file data
% numericaldata(1:4,:) = [];
 s_num = size(numericaldata);
 s_string=size(stringdata);
 
m=msgbox('Compiling maps...');

 output_filepath = stringdata(2,1);
 output_filename = strcat(stringdata(2,2), '_maps.mat');
 
 for i=1:(s_string(1)-4) %take off the 4 lines before the main list
    input_filenames(i) = strcat(stringdata(i+4,2),'.mat');  %iteratively make filenames for each row in spreadsheet - use plus1 to skip header
    input_filepaths(i) = stringdata(i+4,1);
    Map_Labels_List(i) = stringdata(i+4,4); %load user provided descriptions for each map
    map_number(i) = numericaldata(i); %load the number of the map to be grabbed from each maps input file
 end
 
Filename_List = input_filenames; %store for later writing to output file


for j=1:(s_string-4)  %FOR each line in the excel spreadsheet except the header
    cd(char(input_filepaths(j)));
    load(char(input_filenames(j)), 'All_Maps', 'Avg_Maps');
    load(char(input_filenames(j)), 'Base_Filename_List', 'Sampling_Rate_List', 'History_List');
    load(char(input_filenames(j)), 'Experimenter_List', 'Mag_Factor_List', 'Notes_List', 'Optics_List', 'Stimulus_List');
    load(char(input_filenames(j)), 'Day_List', 'Month_List', 'Year_List', 'Hour_List', 'Minute_List', 'Second_List');
    
    if j ==1
    %initialize output data structures, rows x columns in image x 7 maps
    %types x #map sets to be included
    Output_All_Maps = zeros(size(All_Maps,1), size(All_Maps,2), 7, size(s_string,1)-4);
    end
    
    switch map_number(j)
        case 999
            Output_All_Maps(:,:,:,j)=Avg_Maps;
            Output_Map_Labels_List{j} = Map_Labels_List(j); %loaded above from spreadsheet          

            Output_History_List{j}=History_List; %loaded from existing maps file 
            Output_Base_Filename_List{j} = Base_Filename_List;
            Output_Sampling_Rate_List{j} = Sampling_Rate_List; 
            Output_Experimenter_List{j} = Experimenter_List;
            Output_Optics_List{j} = Optics_List;
            Output_Stimulus_List{j} = strcat('Avg:', char(input_filenames(j))); %label stimulus as filename instead
            Output_Notes_List{j} = Notes_List;
            Output_Mag_Factor_List{j} = Mag_Factor_List;
            Output_Day_List{j} = Day_List;
            Output_Month_List{j} = Month_List;
            Output_Year_List{j} = Year_List;
            Output_Hour_List{j} = Hour_List;
            Output_Minute_List{j} = Minute_List;
            Output_Second_List{j} = Second_List;
        otherwise
            Output_All_Maps(:,:,:,j) = All_Maps(:,:,:,map_number(j));
            Output_Map_Labels_List{j} = Map_Labels_List(j);
            
            Output_History_List{j}=History_List{map_number(j)};
            Output_Base_Filename_List{j} = Base_Filename_List{map_number(j)};
            Output_Sampling_Rate_List{j} = num2cell(Sampling_Rate_List(j)); %not a cell array, no curly braces
            Output_Experimenter_List{j} = Experimenter_List{map_number(j)};
            Output_Optics_List{j} = Optics_List{map_number(j)};
            Output_Stimulus_List{j} = Stimulus_List{map_number(j)};
            Output_Notes_List{j} = Notes_List{map_number(j)};
            Output_Mag_Factor_List{j} = Mag_Factor_List{map_number(j)};
            Output_Day_List{j} = Day_List{map_number(j)};
            Output_Month_List{j} = Month_List{map_number(j)};
            Output_Year_List{j} = Year_List{map_number(j)};
            Output_Hour_List{j} = Hour_List{map_number(j)};
            Output_Minute_List{j} = Minute_List{map_number(j)};
            Output_Second_List{j} = Second_List{map_number(j)};
    end
    varlist1 = {'All_Maps', 'Experimenter_List', 'Optics_List', 'Stimulus_List', 'Notes_List', 'Mag_Factor_List', 'Base_Filename_List', 'Sampling_Rate_List'};
    varlist2 = {'History_List', 'Day_List', 'Month_List', 'Year_List', 'Hour_List', 'Minute_List', 'Second_List'};
    clear(varlist1{:});
    clear(varlist2{:});
    status=fclose('all');
end

%switch into final variable names
All_Maps = Output_All_Maps;
History_List = Output_History_List;
Base_Filename_List = Output_Base_Filename_List;
Sampling_Rate_List = Output_Sampling_Rate_List;
Experimenter_List=Output_Experimenter_List;
Optics_List=Output_Optics_List;
Stimulus_List=Output_Stimulus_List;
Notes_List=Output_Notes_List;
Mag_Factor_List=Output_Mag_Factor_List;
Day_List=Output_Day_List;
Month_List=Output_Month_List;
Year_List=Output_Year_List;
Hour_List=Output_Hour_List;
Minute_List=Output_Minute_List;
Second_List=Output_Second_List;


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


%now output data
cd(char(output_filepath)); 
save(char(output_filename), 'All_Maps', 'Experimenter_List', 'Optics_List', 'Stimulus_List', 'Notes_List', 'Mag_Factor_List', 'Base_Filename_List', 'Sampling_Rate_List');
save(char(output_filename), 'Day_List', 'Month_List', 'Year_List', 'Hour_List', 'Minute_List', 'Second_List', '-append');
save(char(output_filename), 'Avg_DF_Map', 'Avg_DF_sHP_Map', 'Avg_DF_sLP_Map', 'Avg_DFperF_Map', 'Avg_DFperF_sHP_Map', 'Avg_DFperF_sLP_Map', 'Avg_RLI_Map', '-append');
save(char(output_filename), 'Avg_Maps', 'History_List', 'Map_Labels_List','-append');
status=fclose('all');

delete(m);
m=msgbox('Map compiilation complete.');
end

