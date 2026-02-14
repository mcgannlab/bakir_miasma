function [ output_args ] = batch_trace_extracter_v3( input_args )
%BATCH_TRACE_EXTRACTER_V3 call without argument opens excel file listing procvs 
%%script for batch loading of preprocessed _procv1 files based on excel
%spreadsheet and extracting traces based on regions of interest specified
%in a Neuroplex compatible pixel-list (.det file)

[rdfile, pathname]=uigetfile({'*.xls','Excel File (*.xls)'}, 'Choose Excel input file');
if isequal(rdfile,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(pathname,rdfile)]);
end
[numericaldata, stringdata]= xlsread([pathname,rdfile]);        %Reads excel file data
 s_num = size(numericaldata,1);
 s_string=size(stringdata,1);

 m=msgbox('Trace extraction in progress...');

for i=1:(s_string(1)-1)
    input_filenames(i) = strcat(stringdata(i+1,2),'.mat');  %iteratively make filenames for each row in spreadsheet - use plus1 to skip header
    input_filepaths(i) = stringdata(i+1,1);
    output_filepaths(i) = stringdata(i+1,3);
    detfilepaths(i) = stringdata(i+1,4);
    detfilenames(i) = strcat(stringdata(i+1,5), '.det');
    output_filenames(i) = strcat(stringdata(i+1,6), '_traces.mat');
end

for j=1:(s_string-1)  %FOR each line in the excel spreadsheet except the header
    extract_ROI_traces_from_procv1_v2(input_filenames(j), input_filepaths(j), detfilenames(j), detfilepaths(j), output_filepaths(j), output_filenames(j));
               
end
status=fclose('all');
delete(m);
m= msgbox('Trace extraction complete.');
end

