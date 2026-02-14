function [ Data_3D, BNC, Sampling_Rate, Dark_Frame, comments_field, A ] = load_NP_data( varargin )
%LOAD_NP_DATA Loads Neuroplex Data from .da file and returns Optical_Data, AtoD_Data, SamplingRate, Dark_Frame, comment_string
%   Detailed explanation goes here

switch nargin
    case 0
        [rdfile, pathname]=uigetfile({'*.da','Neuroplex File (*.da)'}, 'Choose data file');
    case 2
        rdfile = char(varargin{1});
        pathname = char(varargin{2});
    otherwise
        display('This function takes filename,path as arguments or no argument.');
        return
end


cd(char(pathname));

fid = fopen(char(rdfile));
try
fseek(fid,0,'bof');                             %Starts at the 0th byted and the begining of file 'bof'
catch
    st = ['Selected Neuroplex Data File Was Not Found']
    msgbox(st)
    return
end

A = fread(fid,2560,'int16');                   %Reads 2560 16-bit unsigned integer into variable A
Num_Trials=A(2);    %>1 if avgd file
Num_Frames = A(5);  %5th Integer
Num_Rows = A(386);  %385th Integer
Num_Columns = A(385); %386th Integer
Num_Pixels = A(97); %97th Integer

Frame_Interval = A(389); %100Hz:'10000', 50Hz: '20000', 25Hz:'4000'
Dividing_Factor = A(391); %DivFactor=1 if FrameInt=>10000, else 10
Sampling_Rate = 1000/((Frame_Interval/1000)*Dividing_Factor); 
%disp(sprintf('Number of Frames %d',Num_Frames)) ;

BNCfactor = A(392);
if BNCfactor == 0
BNCfactor = 1;
end

size1 = -2*(Num_Rows)*(Num_Columns)-16; %is a negative number 'cause reads from end of file in next line

%%%%%%%%%%%%
%read comment
fseek(fid,256,'bof');               %The static header text is 243 bytes long
comments_field = char((fread(fid,159,'char',1))');%Added text can be as long as 257 bytes

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
% for i=1:Num_Frames;  %then subtract dark frame from each
%     Data(:,i)=Data(:,i)-Dark_Frame;
% end

Data_3D = reshape(Data, Num_Columns, Num_Rows, Num_Frames);
Data_3D = (permute(Data_3D,[2 1 3])); %rotates frames for correct orientation
Dark_Frame = reshape(Dark_Frame, Num_Rows, Num_Columns);


%% Explanation of NP data transform
%starts with one long COLUMN of datapoints (200 x 1) (imagine 2 frames of
%10x10 for comparison)
%Data = Data';   %Transposes data from 1 column to one row (now it's 1 x200) b 
%Data = reshape(Data, Num_Frames, Num_Columns* Num_Rows); %yields 2 x 100 
%Each row is a frame. c
%Data = Data'; %transpose data now each column is a frame; d 100x2
%Data_3D = reshape(Data, Num_Columns, Num_Rows, Num_Frames); % e 10x10x2
%Data_3D = (permute(Data_3D,[2 1 3])); %rotates frames for correct orientation f 10x10x2

%to reverse it linear data should go: 
%(row1, column1, frames 1), r1, c1, f2, to f110 
% then
%row1, column2, frame 1; r1,c2,f2...to f110
%code like this:
% linear_data=zeros(1,Num_Rows*Num_Columns*Num_Frames); %pre-allocate space or die waiting
% next_index=0;
% for x=1:Num_Rows
%     for y=1:Num_Columns
%         for z=1:Num_Frames
%             next_index=next_index+1;
%             linear_data(next_index)=Data(x,y,z);
%         end
%     end
% end



fclose('all');

end

