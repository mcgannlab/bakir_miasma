function [ output_args ] = batch_motion_correction_v3( input_args )
%BATCH_MOTION_CORRECTION_V2 batch process Neuroplex files through the
%motion correction algorithm, output is NP-compatible files ending in _mcv
%Function for batch loading of Neuroplex data files based on excel
%spreadsheet and motion correcting them

reference_frame_number = 10;

% CHOOSE THE FILE THAT WILL SUPPLY THE REFERENCE FRAME
[rdfile, pathname]=uigetfile({'*.da','Neuroplex File (*.da)'; '*.tsm', 'TSM File (*.tsm)'}, 'Choose reference file');
if isequal(rdfile,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected reference:', rdfile]);
end
cd(char(pathname));
fid = fopen(char(rdfile));
try
fseek(fid,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
catch
    st = ['Selected Baseline File Was Not Found']
    msgbox(st)
    return
end  
if isequal(rdfile(end-2:end),'.da')
    [Data_3D, ~] = load_NP_data(rdfile, pathname);
    reference_frame = Data_3D(:,:,reference_frame_number);
else
    Data = load_TurboSM_data(rdfile, pathname);
    reference_frame = Data.Optical_Data(:,:,reference_frame_number);
end
h=figure('Name', 'Reference Frame');
displayimage(reference_frame);


%now choose directory in which to motion correct all files
target_directory = uigetdir; %gets directory
if isequal(target_directory,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', target_directory]);
end
selected_TSM_files = dir(fullfile(target_directory,'*.tsm')); %gets all tsm files in struct
selected_DA_files = dir(fullfile(target_directory,'*.da')); %gets all NP files in struct
cd(target_directory);

%setup output directory
backslash_indices=strfind(target_directory, '\');
current_dir=target_directory(backslash_indices(end)+1:end);
output_dir=strcat(target_directory,'\',current_dir, '_mcv_files');
mkdir(output_dir);


%% Now do the motion correction for each group of files
m=msgbox('Motion correction batch processing underway...');
for x = 1:length(selected_DA_files)
  basefilename = selected_DA_files(x).name;
  fullfilename = fullfile(target_directory, basefilename);
  motion_correct_raw_Neuroplex_file_v2(basefilename, target_directory, output_dir, reference_frame)
end
 
for x = 1:length(selected_TSM_files)
  basefilename = selected_TSM_files(x).name;
  fullfilename = fullfile(target_directory, basefilename);
  motion_correct_TSM_file_v2(basefilename, target_directory, output_dir, reference_frame)
end

status=fclose('all');
delete(m);
m=msgbox('Motion Correction complete.');
end

