function [ output_args ] = batch_NP_filter_preprocessing_v3( Preferences )
%BATCH_NP_FILTER_PREPROCESSING_V2 Batch load Neuroplex files for filtering and
%calculation of difference maps based on Excel spreadsheet info
%Function for batch loading of Neuroplex data files based on excel
%spreadsheet and de-noising and spatial filtering them, with the output a 
%Matlab _procv1 file. Will include XYdeviations from motion correction if .mat file is in same
%directory as .da file.

%% begin by reading in excel file and parsing paths, filenames, and
%% parameters
[rdfile, pathname]=uigetfile({'*.xls','Excel File (*.xls)'}, 'Choose excel file');
if isequal(rdfile,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(pathname,rdfile)]);
end

[numericaldata, stringdata]= xlsread([pathname,rdfile]);        %Reads excel file data
 s_num = size(numericaldata,1);
 s_string=size(stringdata);
 
 m=msgbox('Batch preprocessing of data is underway...');
 
for i=1:s_num
    inputfilename(i) = stringdata(i+7,2);  %iteratively make filenames for each row in spreadsheet - use plus7 to skip header
    inputfilepath(i) = stringdata(i+7,1);
    baselinefirstframe(i) = numericaldata(i, 1);
    baselinelastframe(i) = numericaldata(i, 2);
    Gaussian_sigma(i) = numericaldata(i,3);
    Nyquist_fraction(i) = numericaldata(i,4);
    outputfilepath(i) = stringdata(i+7,7);
    stimulus(i) = stringdata(i+7,8);
    mag_factor(i) = stringdata(i+7,9);
    optics(i) = stringdata(i+7,10);
    experimenter(i) = stringdata(i+7,11);
    notes(i) = stringdata(i+7,12); 
end

   
parfor j=1:(s_num)  %FOR each line in the excel spreadsheet with numbers on it
    disp('parallel processing starting');
    NP_filter_preprocessing_v3(inputfilename(j), inputfilepath(j), outputfilepath(j), baselinefirstframe(j), baselinelastframe(j), Gaussian_sigma(j), Nyquist_fraction(j), stimulus(j), mag_factor(j), optics(j), experimenter(j), notes(j), Preferences)
               
end
status=fclose('all');
delete(m);
m=msgbox('Preprocessing Complete.');
end

