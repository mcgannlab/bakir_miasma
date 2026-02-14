function [ output_args ] = make_timedefined_measurements_v1( input_args )
%MAKE_TIMEDEFINED_MEASUREMENTS_V1 Measure all traces in _comptraces file at
%user-defined time window
%   Detailed explanation goes here

%ask user if using spreadsheet or manual spec of all the same times
prompt = {'Do you want to provide a spreadsheet of times and trials? Enter 1 for yes or 2 for manual window specification.'};
dlg_title = strcat('Spreadsheet or manual entry:');
num_lines=1;
def = {'1'};
spreadsheet_answer = inputdlg(prompt, dlg_title, num_lines, def);
spreadsheet_flag = str2num(spreadsheet_answer{1});

if spreadsheet_flag == 2
    %prompt user for datafile - _comptraces file from MIASMA
    [rdfile, pathname]=uigetfile({'*_comptraces.mat','single comptraces file (*.mat)'}, 'Choose comptraces data file');

    cd(char(pathname));    % prompt useer to choose time windows for measurements
    prompt = {'First frame of response averaging window', 'Last frame of response averaging window', 'Enter 1 for average over window, enter 2 for sum'};
    dlg_title = strcat('Choose your time window:');
    num_lines = 1;
    def = {'1','2','1'};
    answer = inputdlg(prompt, dlg_title, num_lines, def);
    response_firstframe = str2num(answer{1});
    response_lastframe = str2num(answer{2});
    sum_or_avg_flag = str2num(answer{3});



    %load comptraces data file    
    m=msgbox('Loading data...please be patient');
    try
        load(rdfile);
        [Num_ROIs, Num_Frames, Num_Files] = size(DF_ROI_Waveforms_3D);
    catch
        msgbox('Comptraces file cannot be opened or is not correct format');
        return
    end
    delete(m);


    %initialize matrices
    DF_measurements = zeros(Num_ROIs, Num_Files);
    DF_sHP_measurements = zeros(Num_ROIs, Num_Files);
    DF_sLP_measurements = zeros(Num_ROIs, Num_Files);
    DFperF_measurements = zeros(Num_ROIs, Num_Files);
    DFperF_sHP_measurements = zeros(Num_ROIs, Num_Files);
    DFperF_sLP_measurements = zeros(Num_ROIs, Num_Files);
    max_DF_measurements = zeros(Num_ROIs, Num_Files);
    max_DF_sHP_measurements = zeros(Num_ROIs, Num_Files);
    max_DF_sLP_measurements = zeros(Num_ROIs, Num_Files);
    max_DFperF_measurements = zeros(Num_ROIs, Num_Files);
    max_DFperF_sHP_measurements = zeros(Num_ROIs, Num_Files);
    max_DFperF_sLP_measurements = zeros(Num_ROIs, Num_Files);
    max_DF_times = zeros(Num_ROIs, Num_Files);
    max_DF_sHP_times = zeros(Num_ROIs, Num_Files);
    max_DF_sLP_times = zeros(Num_ROIs, Num_Files);
    max_DFperF_times = zeros(Num_ROIs, Num_Files);
    max_DFperF_sHP_times = zeros(Num_ROIs, Num_Files);
    max_DFperF_sLP_times = zeros(Num_ROIs, Num_Files);

    %for each file and ROI, average each of the measurements over the specified
    %frame window
    for x=1:Num_Files
        for y=1:Num_ROIs
            if sum_or_avg_flag == 1
                DF_measurements(y,x) = mean(DF_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
                DF_sHP_measurements(y,x) = mean(DF_sHP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x)); 
                DF_sLP_measurements(y,x) = mean(DF_sLP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe,x));        
                DFperF_measurements(y,x) = mean(DFperF_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
                DFperF_sHP_measurements(y,x) = mean(DFperF_sHP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x)); 
                DFperF_sLP_measurements(y,x) = mean(DFperF_sLP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
            elseif sum_or_avg_flag == 2
                DF_measurements(y,x) = sum(DF_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
                DF_sHP_measurements(y,x) = sum(DF_sHP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x)); 
                DF_sLP_measurements(y,x) = sum(DF_sLP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe,x));        
                DFperF_measurements(y,x) = sum(DFperF_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
                DFperF_sHP_measurements(y,x) = sum(DFperF_sHP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x)); 
                DFperF_sLP_measurements(y,x) = sum(DFperF_sLP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
            else
                msgbox('Avg or Sum choice must be 1 or 2');
                return;
            end
            [max_DF_measurements(y,x), max_DF_times(y,x)] = max(DF_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
            [max_DF_sHP_measurements(y,x), max_DF_sHP_times(y,x)] = max(DF_sHP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x)); 
            [max_DF_sLP_measurements(y,x), max_DF_sLP_times(y,x)] = max(DF_sLP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe,x));        
            [max_DFperF_measurements(y,x), max_DFperF_times(y,x)] = max(DFperF_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
            [max_DFperF_sHP_measurements(y,x), max_DFperF_sHP_times(y,x)] = max(DFperF_sHP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x)); 
            [max_DFperF_sLP_measurements(y,x), max_DFperF_sLP_times(y,x)] = max(DFperF_sLP_ROI_Waveforms_3D(y, response_firstframe:response_lastframe, x));
        end
    end
    
    %convert peak latencies from frame numbers to msec
    msec_per_sample = 1/Sampling_Rate; %Sampling Rate came from loading the comptraces file
    max_DF_times = max_DF_times * msec_per_sample;
    max_DF_sHP_times = max_DF_sHP_times * msec_per_sample;
    max_DF_sLP_times = max_DF_sLP_times * msec_per_sample;
    max_DFperF_times = max_DFperF_times * msec_per_sample;
    max_DFperF_sHP_times = max_DFperF_sHP_times * msec_per_sample;
    max_DFperF_sLP_times = max_DFperF_sLP_times * msec_per_sample;
        
    %prompt for filename and location
    if sum_or_avg_flag == 1
        output_filename = strcat(rdfile(1:end-4), '_avg_measurements.xls');
    elseif sum_or_avg_flag == 2
        output_filename = strcat(rdfile(1:end-4), '_sum_measurements.xls');
    end
    [outfile, pathname] = uiputfile('Where would you like to save the file?', '*.xls', char(output_filename));
    cd(char(pathname));
    outfile = strcat(outfile, '.xls');

    %set up labels
    for z=1:size(Stimulus_List, 2)
        stim_output(z) = Stimulus_List{z};
        file_output{z} = Filename_List{z};
    end
    for a=1:Num_ROIs
        ROI_output{a} = strcat('ROI ', num2str(a));
    end
    if sum_or_avg_flag == 1
        type_label = {'AVERAGE over frame window'};
    elseif sum_or_avg_flag == 2
        type_label = {'SUM over frame window'};
    end
    stim_label = {'Stimulus'};


    %% Now write the measurements to different worksheets in an Excel file, with headers
    m=msgbox('Writing to Excel file...please be patient');

    xlswrite(outfile, DF_measurements', 'DF', 'C2');
    xlswrite(outfile, stim_output', 'DF', 'B2');
    xlswrite(outfile, file_output', 'DF', 'A2');
    xlswrite(outfile, ROI_output, 'DF', 'C1');
    xlswrite(outfile, type_label, 'DF', 'A1');
    xlswrite(outfile, stim_label, 'DF', 'B1');

    xlswrite(outfile, DF_sHP_measurements', 'DF_sHP', 'C2');
    xlswrite(outfile, stim_output', 'DF_sHP', 'B2');
    xlswrite(outfile, file_output', 'DF_sHP', 'A2');
    xlswrite(outfile, ROI_output, 'DF_sHP', 'C1');
    xlswrite(outfile, type_label, 'DF_sHP', 'A1');
    xlswrite(outfile, stim_label, 'DF_sHP', 'B1');

    xlswrite(outfile, DF_sLP_measurements', 'DF_sLP', 'C2');
    xlswrite(outfile, stim_output', 'DF_sLP', 'B2');
    xlswrite(outfile, file_output', 'DF_sLP', 'A2');
    xlswrite(outfile, ROI_output, 'DF_sLP', 'C1');
    xlswrite(outfile, type_label, 'DF_sLP', 'A1');
    xlswrite(outfile, stim_label, 'DF_sLP', 'B1');

    xlswrite(outfile, DFperF_measurements', 'DFperF', 'C2');
    xlswrite(outfile, stim_output', 'DFperF', 'B2');
    xlswrite(outfile, file_output', 'DFperF', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF', 'C1');
    xlswrite(outfile, type_label, 'DFperF', 'A1');
    xlswrite(outfile, stim_label, 'DFperF', 'B1');

    xlswrite(outfile, DFperF_sHP_measurements', 'DFperF_sHP', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_sHP', 'B2');
    xlswrite(outfile, file_output', 'DFperF_sHP', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_sHP', 'C1');
    xlswrite(outfile, type_label, 'DFperF_sHP', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_sHP', 'B1');

    xlswrite(outfile, DFperF_sLP_measurements', 'DFperF_sLP', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_sLP', 'B2');
    xlswrite(outfile, file_output', 'DFperF_sLP', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_sLP', 'C1');
    xlswrite(outfile, type_label, 'DFperF_sLP', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_sLP', 'B1');


    % now write the maximums
    xlswrite(outfile, max_DF_measurements', 'DF_max', 'C2');  
    xlswrite(outfile, stim_output', 'DF_max', 'B2');
    xlswrite(outfile, file_output', 'DF_max', 'A2');
    xlswrite(outfile, ROI_output, 'DF_max', 'C1');
    xlswrite(outfile, type_label, 'DF_max', 'A1');
    xlswrite(outfile, stim_label, 'DF_max', 'B1');    
    
    xlswrite(outfile, max_DF_sHP_measurements', 'DF_sHP_max', 'C2');
    xlswrite(outfile, stim_output', 'DF_sHP_max', 'B2');
    xlswrite(outfile, file_output', 'DF_sHP_max', 'A2');
    xlswrite(outfile, ROI_output, 'DF_sHP_max', 'C1');
    xlswrite(outfile, type_label, 'DF_sHP_max', 'A1');
    xlswrite(outfile, stim_label, 'DF_sHP_max', 'B1');

    xlswrite(outfile, max_DF_sLP_measurements', 'DF_sLP_max', 'C2');
    xlswrite(outfile, stim_output', 'DF_sLP_max', 'B2');
    xlswrite(outfile, file_output', 'DF_sLP_max', 'A2');
    xlswrite(outfile, ROI_output, 'DF_sLP_max', 'C1');
    xlswrite(outfile, type_label, 'DF_sLP_max', 'A1');
    xlswrite(outfile, stim_label, 'DF_sLP_max', 'B1');

    xlswrite(outfile, max_DFperF_measurements', 'DFperF_max', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_max', 'B2');
    xlswrite(outfile, file_output', 'DFperF_max', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_max', 'C1');
    xlswrite(outfile, type_label, 'DFperF_max', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_max', 'B1');

    xlswrite(outfile, max_DFperF_sHP_measurements', 'DFperF_sHP_max', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_sHP_max', 'B2');
    xlswrite(outfile, file_output', 'DFperF_sHP_max', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_sHP_max', 'C1');
    xlswrite(outfile, type_label, 'DFperF_sHP_max', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_sHP_max', 'B1');

    xlswrite(outfile, max_DFperF_sLP_measurements', 'DFperF_sLP_max', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_sLP_max', 'B2');
    xlswrite(outfile, file_output', 'DFperF_sLP_max', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_sLP_max', 'C1');
    xlswrite(outfile, type_label, 'DFperF_sLP_max', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_sLP_max', 'B1');
    
    
    % now write the latencies of the maximums
    xlswrite(outfile, max_DF_times', 'DF_max_times', 'C2');  
    xlswrite(outfile, stim_output', 'DF_max_times', 'B2');
    xlswrite(outfile, file_output', 'DF_max_times', 'A2');
    xlswrite(outfile, ROI_output, 'DF_max_times', 'C1');
    xlswrite(outfile, type_label, 'DF_max_times', 'A1');
    xlswrite(outfile, stim_label, 'DF_max_times', 'B1');    
    
    xlswrite(outfile, max_DF_sHP_times', 'DF_sHP_max_times', 'C2');
    xlswrite(outfile, stim_output', 'DF_sHP_max_times', 'B2');
    xlswrite(outfile, file_output', 'DF_sHP_max_times', 'A2');
    xlswrite(outfile, ROI_output, 'DF_sHP_max_times', 'C1');
    xlswrite(outfile, type_label, 'DF_sHP_max_times', 'A1');
    xlswrite(outfile, stim_label, 'DF_sHP_max_times', 'B1');

    xlswrite(outfile, max_DF_sLP_times', 'DF_sLP_max_times', 'C2');
    xlswrite(outfile, stim_output', 'DF_sLP_max_times', 'B2');
    xlswrite(outfile, file_output', 'DF_sLP_max_times', 'A2');
    xlswrite(outfile, ROI_output, 'DF_sLP_max_times', 'C1');
    xlswrite(outfile, type_label, 'DF_sLP_max_times', 'A1');
    xlswrite(outfile, stim_label, 'DF_sLP_max_times', 'B1');

    xlswrite(outfile, max_DFperF_times', 'DFperF_max_times', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_max_times', 'B2');
    xlswrite(outfile, file_output', 'DFperF_max_times', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_max_times', 'C1');
    xlswrite(outfile, type_label, 'DFperF_max_times', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_max_times', 'B1');

    xlswrite(outfile, max_DFperF_sHP_times', 'DFperF_sHP_max_times', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_sHP_max_times', 'B2');
    xlswrite(outfile, file_output', 'DFperF_sHP_max_times', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_sHP_max_times', 'C1');
    xlswrite(outfile, type_label, 'DFperF_sHP_max_times', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_sHP_max_times', 'B1');

    xlswrite(outfile, max_DFperF_sLP_times', 'DFperF_sLP_max_times', 'C2');
    xlswrite(outfile, stim_output', 'DFperF_sLP_max_times', 'B2');
    xlswrite(outfile, file_output', 'DFperF_sLP_max_times', 'A2');
    xlswrite(outfile, ROI_output, 'DFperF_sLP_max_times', 'C1');
    xlswrite(outfile, type_label, 'DFperF_sLP_max_times', 'A1');
    xlswrite(outfile, stim_label, 'DFperF_sLP_max_times', 'B1');    
    
        
    %The following section opens the Excel spreadsheet using ActiveX and
    %removes the 3 default worksheets if they are in there
    sheetName = 'Sheet';
    % Open Excel file.
    objExcel = actxserver('Excel.Application');
    objExcel.Workbooks.Open(fullfile(pathname, outfile)); % Full path is necessary!
    % Delete sheets.
    try
          % Throws an error if the sheets do not exist.
          objExcel.ActiveWorkbook.Worksheets.Item([sheetName '1']).Delete;
          objExcel.ActiveWorkbook.Worksheets.Item([sheetName '2']).Delete;
          objExcel.ActiveWorkbook.Worksheets.Item([sheetName '3']).Delete;
    catch
          ; % Do nothing.
    end
    % Save, close and clean up.
    objExcel.ActiveWorkbook.Save;
    objExcel.ActiveWorkbook.Close;
    objExcel.Quit;
    objExcel.delete;

    %close messagebox 
    delete(m);
end %end of original measurement codeblock for making manually entered time-defined measurements one per trial


%% if a spreadshee was selected, load it and take measurements
if spreadsheet_flag == 1
    %prompt user for spreadsheet with times
    [spreadsheet_file, spreadsheet_pathname]=uigetfile({'*.xls',' Excel times spreadsheet (*.xls)'}, 'Choose spreadsheet with times.');
    cd(char(spreadsheet_pathname));
    [numericaldata, stringdata]= xlsread([spreadsheet_pathname,spreadsheet_file]);        %Reads excel file data
    s_num = size(numericaldata);
    s_string = size(stringdata);

    %set up matrix of measurement parameters
    num_measurements = s_num(1);
    for i=1:num_measurements;
        trial_number(i) = numericaldata(i,1);
        sniff_number(i) = numericaldata(i,2);
        firstframe(i) = numericaldata(i,3);
        lastframe(i) = numericaldata(i,4);
    end

    %set up filenames
    comptraces_filepath = stringdata(2,1);
    comptraces_filename = strcat(stringdata(2,2), '.mat');
    
    output_filepath = stringdata(5,1);
    output_filename = char(strcat(stringdata(5,2), '_measurements.xls'));
    
    
    %load comptraces data file and simple error check  
    m=msgbox('Loading data...please be patient');
    try
        cd(char(comptraces_filepath));
        load(char(comptraces_filename));
        [Num_ROIs, Num_Frames, Num_Trials] = size(DF_ROI_Waveforms_3D);
        BNC_Num_Frames = size(BNC_3D, 2);
        BNC_sampling_ratio = round(BNC_Num_Frames/Num_Frames);
    catch
        msgbox('Comptraces file cannot be opened or is not correct format');
        return
    end
    delete(m);  
    if Num_Trials < max(max(trial_number))
     display('Error: Number of Trials in comptraces file and highest trial # in Excel file DO NOT MATCH!');
     return
    end
    
    %initialize matrices to hold measured values
    DF_measurements = zeros(Num_ROIs, num_measurements);
    DF_sHP_measurements = zeros(Num_ROIs, num_measurements);
    DF_sLP_measurements = zeros(Num_ROIs, num_measurements);
    DFperF_measurements = zeros(Num_ROIs, num_measurements);
    DFperF_sHP_measurements = zeros(Num_ROIs, num_measurements);
    DFperF_sLP_measurements = zeros(Num_ROIs, num_measurements);    
    All_Data_Labels = cell(num_measurements, 5);
    BNC_measurements = zeros(8,num_measurements);
    
    %for each ROI on each specified trial, average each of the measurements over the specified
    %frame window
    for x=1:num_measurements
        BNC_firstframe = firstframe(x)*BNC_sampling_ratio;
        BNC_lastframe = lastframe(x)*BNC_sampling_ratio;
        BNC_measurements(1,x) = mean(BNC_3D(1,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(2,x) = mean(BNC_3D(2,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(3,x) = mean(BNC_3D(3,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(4,x) = mean(BNC_3D(4,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(5,x) = mean(BNC_3D(5,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(6,x) = mean(BNC_3D(6,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(7,x) = mean(BNC_3D(7,BNC_firstframe:BNC_lastframe, trial_number(x)));
        BNC_measurements(8,x) = mean(BNC_3D(8,BNC_firstframe:BNC_lastframe, trial_number(x)));

        for y=1:Num_ROIs
            DF_measurements(y,x) = mean(DF_ROI_Waveforms_3D(y, firstframe(x):lastframe(x), trial_number(x)));
            DF_sHP_measurements(y,x) = mean(DF_sHP_ROI_Waveforms_3D(y, firstframe(x):lastframe(x), trial_number(x))); 
            DF_sLP_measurements(y,x) = mean(DF_sLP_ROI_Waveforms_3D(y, firstframe(x):lastframe(x), trial_number(x)));        
            DFperF_measurements(y,x) = mean(DFperF_ROI_Waveforms_3D(y, firstframe(x):lastframe(x), trial_number(x)));
            DFperF_sHP_measurements(y,x) = mean(DFperF_sHP_ROI_Waveforms_3D(y, firstframe(x):lastframe(x), trial_number(x)));
            DFperF_sLP_measurements(y,x) = mean(DFperF_sLP_ROI_Waveforms_3D(y, firstframe(x):lastframe(x), trial_number(x)));
            All_Data_Labels(x,:) = [Filename_List{trial_number(x)}; Stimulus_List{trial_number(x)}; num2str(sniff_number(x)); num2str(firstframe(x)); num2str(lastframe(x))];
        end
    end

    %%Format measurements for data output
    
    %figure out the biggest number of measurements from any one trial
    for x=1:Num_Trials
        num_measurements_on_trialx(x) = size(find(trial_number==x),2);
    end
    max_measurements_per_trial =  max(num_measurements_on_trialx);

    %lay out each ROI as a row of measurements, appending trials left to
    %right remember measurements(ROI, #measures)
    for x=1:Num_Trials
        first_index = (x-1)*max_measurements_per_trial+1;
        last_index = x * max_measurements_per_trial;
        stimulus = Stimulus_List{x};
        filename = Filename_List{x};
        for y = first_index:last_index
            stimulus_labels{y} = stimulus{1};
            trial_labels{y} = filename;
        end
        sniff_number_labels(first_index:last_index)=linspace(1,max_measurements_per_trial, max_measurements_per_trial);
    end

    for x=1:Num_ROIs
        ROI_labels{x} = strcat('ROI', num2str(x));
    end
    
    stim_label = {'Stimulus'};
    file_label = {'File'};
    sniff_label = {'Sniff #'};
    BNC1_label = {'BNC1'};
    BNC2_label = {'BNC2'};
    BNC3_label = {'BNC3'};
    BNC4_label = {'BNC4'};
    BNC5_label = {'BNC5'};
    BNC6_label = {'BNC6'};
    BNC7_label = {'BNC7'};
    BNC8_label = {'BNC8'};
    firstframe_label = {'1st Frame'};
    lastframe_label = {'Last Frame'};

    
    %% Now write the measurements to different worksheets in an Excel file, with headers
    m=msgbox('Writing to Excel file...please be patient');
    cd(char(output_filepath));

    xlswrite(output_filename, DF_measurements', 'DF', 'N3');
    xlswrite(output_filename, All_Data_Labels, 'DF', 'A3');
    xlswrite(output_filename, BNC_measurements', 'DF', 'F3');
    xlswrite(output_filename, ROI_labels, 'DF', 'N2');
    xlswrite(output_filename, sniff_label, 'DF', 'C2');
    xlswrite(output_filename, stim_label, 'DF', 'B2');
    xlswrite(output_filename, file_label, 'DF', 'A2');
    xlswrite(output_filename, BNC1_label, 'DF', 'F2');
    xlswrite(output_filename, BNC2_label, 'DF', 'G2');
    xlswrite(output_filename, BNC3_label, 'DF', 'H2');
    xlswrite(output_filename, BNC4_label, 'DF', 'I2');
    xlswrite(output_filename, BNC5_label, 'DF', 'J2');
    xlswrite(output_filename, BNC6_label, 'DF', 'K2');
    xlswrite(output_filename, BNC7_label, 'DF', 'L2');
    xlswrite(output_filename, BNC8_label, 'DF', 'M2');
    xlswrite(output_filename, firstframe_label, 'DF', 'D2');
    xlswrite(output_filename, lastframe_label, 'DF', 'E2');
    
    xlswrite(output_filename, DF_sHP_measurements', 'DF_sHP', 'N3');
    xlswrite(output_filename, All_Data_Labels, 'DF_sHP', 'A3');
    xlswrite(output_filename, BNC_measurements', 'DF_sHP', 'F3');
    xlswrite(output_filename, ROI_labels, 'DF_sHP', 'N2');
    xlswrite(output_filename, sniff_label, 'DF_sHP', 'C2');
    xlswrite(output_filename, stim_label, 'DF_sHP', 'B2');
    xlswrite(output_filename, file_label, 'DF_sHP', 'A2');
    xlswrite(output_filename, BNC1_label, 'DF_sHP', 'F2');
    xlswrite(output_filename, BNC2_label, 'DF_sHP', 'G2');
    xlswrite(output_filename, BNC3_label, 'DF_sHP', 'H2');
    xlswrite(output_filename, BNC4_label, 'DF_sHP', 'I2');
    xlswrite(output_filename, BNC5_label, 'DF_sHP', 'J2');
    xlswrite(output_filename, BNC6_label, 'DF_sHP', 'K2');
    xlswrite(output_filename, BNC7_label, 'DF_sHP', 'L2');
    xlswrite(output_filename, BNC8_label, 'DF_sHP', 'M2');
    xlswrite(output_filename, firstframe_label, 'DF_sHP', 'D2');
    xlswrite(output_filename, lastframe_label, 'DF_sHP', 'E2');
    
    xlswrite(output_filename, DF_sLP_measurements', 'DF_sLP', 'N3');
    xlswrite(output_filename, All_Data_Labels, 'DF_sLP', 'A3');
    xlswrite(output_filename, BNC_measurements', 'DF_sLP', 'F3');
    xlswrite(output_filename, ROI_labels, 'DF_sLP', 'N2');
    xlswrite(output_filename, sniff_label, 'DF_sLP', 'C2');
    xlswrite(output_filename, stim_label, 'DF_sLP', 'B2');
    xlswrite(output_filename, file_label, 'DF_sLP', 'A2');
    xlswrite(output_filename, BNC1_label, 'DF_sLP', 'F2');
    xlswrite(output_filename, BNC2_label, 'DF_sLP', 'G2');
    xlswrite(output_filename, BNC3_label, 'DF_sLP', 'H2');
    xlswrite(output_filename, BNC4_label, 'DF_sLP', 'I2');
    xlswrite(output_filename, BNC5_label, 'DF_sLP', 'J2');
    xlswrite(output_filename, BNC6_label, 'DF_sLP', 'K2');
    xlswrite(output_filename, BNC7_label, 'DF_sLP', 'L2');
    xlswrite(output_filename, BNC8_label, 'DF_sLP', 'M2');
    xlswrite(output_filename, firstframe_label, 'DF_sLP', 'D2');
    xlswrite(output_filename, lastframe_label, 'DF_sLP', 'E2');
    
    xlswrite(output_filename, DFperF_measurements', 'DFperF', 'N3');
    xlswrite(output_filename, All_Data_Labels, 'DFperF', 'A3');
    xlswrite(output_filename, BNC_measurements', 'DFperF', 'F3');
    xlswrite(output_filename, ROI_labels, 'DFperF', 'N2');
    xlswrite(output_filename, sniff_label, 'DFperF', 'C2');
    xlswrite(output_filename, stim_label, 'DFperF', 'B2');
    xlswrite(output_filename, file_label, 'DFperF', 'A2');
    xlswrite(output_filename, BNC1_label, 'DFperF', 'F2');
    xlswrite(output_filename, BNC2_label, 'DFperF', 'G2');
    xlswrite(output_filename, BNC3_label, 'DFperF', 'H2');
    xlswrite(output_filename, BNC4_label, 'DFperF', 'I2');
    xlswrite(output_filename, BNC5_label, 'DFperF', 'J2');
    xlswrite(output_filename, BNC6_label, 'DFperF', 'K2');
    xlswrite(output_filename, BNC7_label, 'DFperF', 'L2');
    xlswrite(output_filename, BNC8_label, 'DFperF', 'M2');
    xlswrite(output_filename, firstframe_label, 'DFperF', 'D2');
    xlswrite(output_filename, lastframe_label, 'DFperF', 'E2');
    
    xlswrite(output_filename, DFperF_sHP_measurements', 'DFperF_sHP', 'N3');
    xlswrite(output_filename, All_Data_Labels, 'DFperF_sHP', 'A3');
    xlswrite(output_filename, BNC_measurements', 'DFperF_sHP', 'F3');
    xlswrite(output_filename, ROI_labels, 'DFperF_sHP', 'N2');
    xlswrite(output_filename, sniff_label, 'DFperF_sHP', 'C2');
    xlswrite(output_filename, stim_label, 'DFperF_sHP', 'B2');
    xlswrite(output_filename, file_label, 'DFperF_sHP', 'A2');
    xlswrite(output_filename, BNC1_label, 'DFperF_sHP', 'F2');
    xlswrite(output_filename, BNC2_label, 'DFperF_sHP', 'G2');
    xlswrite(output_filename, BNC3_label, 'DFperF_sHP', 'H2');
    xlswrite(output_filename, BNC4_label, 'DFperF_sHP', 'I2');
    xlswrite(output_filename, BNC5_label, 'DFperF_sHP', 'J2');
    xlswrite(output_filename, BNC6_label, 'DFperF_sHP', 'K2');
    xlswrite(output_filename, BNC7_label, 'DFperF_sHP', 'L2');
    xlswrite(output_filename, BNC8_label, 'DFperF_sHP', 'M2');
    xlswrite(output_filename, firstframe_label, 'DFperF_sHP', 'D2');
    xlswrite(output_filename, lastframe_label, 'DFperF_sHP', 'E2');
    
    xlswrite(output_filename, DFperF_sLP_measurements', 'DFperF_sLP', 'N3');
    xlswrite(output_filename, All_Data_Labels, 'DFperF_sLP', 'A3');
    xlswrite(output_filename, BNC_measurements', 'DFperF_sLP', 'F3');
    xlswrite(output_filename, ROI_labels, 'DFperF_sLP', 'N2');
    xlswrite(output_filename, sniff_label, 'DFperF_sLP', 'C2');
    xlswrite(output_filename, stim_label, 'DFperF_sLP', 'B2');
    xlswrite(output_filename, file_label, 'DFperF_sLP', 'A2');
    xlswrite(output_filename, BNC1_label, 'DFperF_sLP', 'F2');
    xlswrite(output_filename, BNC2_label, 'DFperF_sLP', 'G2');
    xlswrite(output_filename, BNC3_label, 'DFperF_sLP', 'H2');
    xlswrite(output_filename, BNC4_label, 'DFperF_sLP', 'I2');
    xlswrite(output_filename, BNC5_label, 'DFperF_sLP', 'J2');
    xlswrite(output_filename, BNC6_label, 'DFperF_sLP', 'K2');
    xlswrite(output_filename, BNC7_label, 'DFperF_sLP', 'L2');
    xlswrite(output_filename, BNC8_label, 'DFperF_sLP', 'M2');
    xlswrite(output_filename, firstframe_label, 'DFperF_sLP', 'D2');
    xlswrite(output_filename, lastframe_label, 'DFperF_sLP', 'E2');    
    
%     Commented out because it doesn't like the pathname for some reason
%     and I don't have time to debug that right now. It works if user is
%     prompted for path but not reading from Excel.
%The following section opens the Excel spreadsheet using ActiveX and
%     %removes the 3 default worksheets if they are in there
%     sheetName = 'Sheet';
%     % Open Excel file.
%     objExcel = actxserver('Excel.Application');
%     objExcel.Workbooks.Open(fullfile(output_filepath, output_filename)); % Full path is necessary!
%     % Delete sheets.
%     try
%           % Throws an error if the sheets do not exist.
%           objExcel.ActiveWorkbook.Worksheets.Item([sheetName '1']).Delete;
%           objExcel.ActiveWorkbook.Worksheets.Item([sheetName '2']).Delete;
%           objExcel.ActiveWorkbook.Worksheets.Item([sheetName '3']).Delete;
%     catch
%           ; % Do nothing.
%     end
%     % Save, close and clean up.
%     objExcel.ActiveWorkbook.Save;
%     objExcel.ActiveWorkbook.Close;
%     objExcel.Quit;
%     objExcel.delete;

    
    %close messagebox
    delete(m);
    
end



status = fclose('all');
clear('all');
end

