function [TurboSM_dataset]= load_TurboSM_data(varargin)
%LOAD_TURBOSM_DATA [Data Structure]
%returned, receives no arguments or filename, path

switch nargin
    case 0
        [filename_tsm, pathname]=uigetfile({'*.tsm','TurboSM TSM File (*.tsm)'}, 'Choose data file');
        base_filename = filename_tsm(1:end-4);
        filename_tbn = strcat(base_filename, '.tbn');
        cd(char(pathname));
    case 2
        filename_tsm = char(varargin{1});
        pathname = char(varargin{2});
        base_filename = filename_tsm(1:end-4);
        filename_tbn = strcat(base_filename, '.tbn');
    otherwise
        display('This function takes filename,path as arguments or no argument.');
        return
end

warning('off', 'MATLAB:imagesci:fitsinfo:unknownFormat'); %suppress parse warning - something isn't quite right in the TSM header structure
cd(char(pathname));
fileInfo = fitsinfo(filename_tsm);
Num_Rows = fileInfo.PrimaryData.Size(1);
Num_Columns = fileInfo.PrimaryData.Size(2);
Num_Frames = fileInfo.PrimaryData.Size(3);
data_offset_bytes = fileInfo.PrimaryData.Offset;
Sampling_Rate = 1/fileInfo.PrimaryData.Keywords{11,2};
comments = '';
warning('on', 'MATLAB:imagesci:fitsinfo:unknownFormat'); %turn parse warning back on

%% LOAD DATA FROM TSM FILE
fid = fopen(char(filename_tsm));
try
    fseek(fid,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
catch
    st = ['Selected TSM File Was Not Found']
    msgbox(st)
    return
end

fseek(fid,data_offset_bytes,'bof');      %Seeks OFFSET number of bytes from beginning of file to start loading data
[Data,count] = fread(fid,(Num_Frames*Num_Columns*Num_Rows),'int16'); %the number of integers to read
[Dark_Frame,count] = fread(fid,(1*Num_Columns*Num_Rows),'int16'); %the number of integers to read
%in would be the number of frames x number of columns x number of rows.
Data = Data';   %Transposes data from 1 row to 1 column
Data = reshape(Data, Num_Frames, Num_Columns* Num_Rows); %reshapes data into a 2D matrix [number of frames x number of data points in each frame] ,
%so each row is the data for each frame


%Subtract the dark frame from each image to correct for subtle offset
%differences across the camera sensor
% Dark_Frame = Dark_Frame';
% for i=1:Num_Frames;  %then subtract dark frame from each
%     Data(i, :)=Data(i,:)-Dark_Frame;
% end

%Rearrange to final matrix format
Data_3D = reshape(Data, Num_Columns, Num_Rows, Num_Frames);
Data_3D = (permute(Data_3D,[2 1 3])); %rotates frames for correct orientation
Dark_Frame = reshape(Dark_Frame, Num_Rows, Num_Columns);

clear Data; %free up this memory
fclose('all');

RLI = (Data_3D(:,:,1)+Data_3D(:,:,2)+Data_3D(:,:,3)+Data_3D(:,:,4)+Data_3D(:,:,5))/5;

%% LOAD A-TO-D INPUT DATA (BNC DATA) FROM TBN FILE
fid = fopen(char(filename_tbn));
try
    fseek(fid,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
catch
    st = ['Selected TBN File Was Not Found']
    msgbox(st)
    return
end

fseek(fid,0,'bof');      %Seeks OFFSET number of bytes from beginning of file to start loading data
header = fread(fid,2,'short'); %the number of integers to read
%in would be the number of frames x number of columns x number of rows.
Num_BNC_Channels = abs(header(1));
BNC_frame_ratio = header(2);
[BNC_Data,count] = fread(fid,Num_Frames*Num_BNC_Channels*BNC_frame_ratio,'int16'); %the number of integers to read
BNC_Data = BNC_Data';   %Transposes data from 1 row to 1 column
BNC_Data = reshape(BNC_Data, Num_Frames*BNC_frame_ratio, Num_BNC_Channels); %reshapes data into a 2D matrix (Number of frames x Num Channels)
%BNC_Data = BNC_Data';
if Num_BNC_Channels == 4
    BNC_copy = BNC_Data;
    BNC_Data(:,5:8) = BNC_copy; %duplicate channels 1:4 onto 5:8 for compatibility with NP-derived data
end
%% SET UP FOR RETURN
TurboSM_dataset.Optical_Data = Data_3D;
TurboSM_dataset.Analog_Data = BNC_Data;
TurboSM_dataset.Sampling_Rate = Sampling_Rate;
TurboSM_dataset.Dark_Frame = Dark_Frame;
TurboSM_dataset.Comments = comments;
TurboSM_dataset.RLI = RLI;
TurboSM_dataset.fileInfo = fileInfo;

fclose('all');
end


