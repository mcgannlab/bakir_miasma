function varargout = trace_browser(varargin)
% TRACE_BROWSER MATLAB code for trace_browser.fig
%      TRACE_BROWSER, by itself, creates a new TRACE_BROWSER or raises the existing
%      singleton*.
%
%      H = TRACE_BROWSER returns the handle to a new TRACE_BROWSER or the handle to
%      the existing singleton*.
%
%      TRACE_BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACE_BROWSER.M with the given input arguments.
%
%      TRACE_BROWSER('Property','Value',...) creates a new TRACE_BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trace_browser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trace_browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trace_browser

% Last Modified by GUIDE v2.5 02-Jul-2014 17:37:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trace_browser_OpeningFcn, ...
                   'gui_OutputFcn',  @trace_browser_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trace_browser is made visible.
function trace_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trace_browser (see VARARGIN)

% Choose default command line output for trace_browser

handles.output = hObject;
%set flag that there's no data yet
handles.dataloaded = 0;
handles.peakfile_loaded = 0;
handles.filetype = 0; %0 for traces originally from spatial data or 1 for 2photon realtime
handles.spatially_filtered_data_exists = 0; 

%set up the handles to make sure we don't get the graphs confused
handles.devsaxes_handle = findobj(hObject, 'Tag', 'devs_axis');
handles.mainaxes_handle = findobj(hObject, 'Tag', 'axes1');
handles.table_handle = findobj(hObject, 'Tag', 'results_table');
handles.peaks_filename_textbox = findobj(hObject, 'Tag', 'peaks_filename_textbox');
handles.stimulus_text = findobj(hObject, 'Tag', 'stimulus_text');
handles.warning_text = findobj(hObject, 'Tag', 'warning_text');

%get the datatype radio button handles so we can disable later if necessary
handles.DF_radiobutton_handle = findobj(hObject, 'Tag', 'DF_radiobutton');
handles.DF_sHP_radiobutton_handle = findobj(hObject, 'Tag', 'DF_sHP_radiobutton');
handles.DF_sLP_radiobutton_handle = findobj(hObject, 'Tag', 'DF_sLP_radiobutton');
handles.DFperF_radiobutton_handle = findobj(hObject, 'Tag', 'DFperF_radiobutton');
handles.DFperF_sHP_radiobutton_handle = findobj(hObject, 'Tag', 'DFperF_sHP_radiobutton');
handles.DFperF_sLP_radiobutton_handle = findobj(hObject, 'Tag', 'DFperF_sLP_radiobutton');

%set up editable table for peaks and troughs
set(handles.table_handle, 'ColumnName', {'Trough Time','Peak Time', 'Trial#', 'ROI#', 'Index', 'PeakNum', 'DF', 'DF_sHP', 'DF_sLP', 'DF/F', 'DF/F_sHP', 'DF/F_sLP', 'DF_vs_base', 'DF_sHP_vs_base', 'DF_sLP_vs_base', 'DF/F_vs_base', 'DF/F_sHP_vs_base', 'DF/F_sLP_vs_base', 'BNC1', 'BNC2', 'BNC3', 'BNC4', 'BNC5', 'BNC6', 'BNC7', 'BNC8', 'Category', 'Baseline_Latency'});
column_editability = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
column_editability = logical(column_editability);
set(handles.table_handle, 'ColumnEditable', column_editability);
handles.selected_row_index = 0;
handles.selected_cell_indices = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trace_browser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trace_browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_comptraces_file_button.
function load_comptraces_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_comptraces_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%prompt user to find a compiled trace file
[rdfile, pathname]=uigetfile({'*_comptraces.mat','_comptraces File (*_comptraces.mat)'}, 'Choose compiled traces file');
if isequal(rdfile,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(pathname,rdfile)]);
end

m=msgbox('Loading data...please be patient.');
cd(char(pathname));
load(rdfile);
delete(m);
handles.dataloaded = 1;
handles.filetype = 0; %reset to zero before checking
set(hObject, 'BackgroundColor', [0.94 0.94 0.94]); %turn load maps button gray

%rest, then set warning text appropriately
set(handles.warning_text, 'String', '');
if strfind(rdfile, '_PCA') > 0
    set(handles.warning_text, 'String', 'Warning: Plotted ROIs are Whitened Principal Component Values based on the selected datatype, NOT ROI Measures!');
end
if strfind(rdfile, '_pearson') > 0
    set(handles.warning_text, 'String', 'Warning: Plotted ROI 1 is Pearson r vs user-set frames based on the selected datatype, NOT ROI Measures! ROI2 is corresponding p-values!');
end
if strfind(rdfile, '_2photon') > 0
    handles.filetype = 1;
    set(handles.warning_text, 'String', 'Imported 2photon real-time traces! Interpret cautiously');
end

%assemble variables into handles structure so other functions can access it
switch handles.filetype
    case 0
        handles.DF_ROI_Waveforms_3D = DF_ROI_Waveforms_3D;
        handles.DFperF_ROI_Waveforms_3D = DFperF_ROI_Waveforms_3D;
        if exist('DF_sHP_ROI_Waveforms_3D', 'var')
            handles.DF_sHP_ROI_Waveforms_3D = DF_sHP_ROI_Waveforms_3D;
            handles.DF_sLP_ROI_Waveforms_3D = DF_sLP_ROI_Waveforms_3D;
            handles.DFperF_sHP_ROI_Waveforms_3D = DFperF_sHP_ROI_Waveforms_3D;
            handles.DFperF_sLP_ROI_Waveforms_3D = DFperF_sLP_ROI_Waveforms_3D;
            handles.spatially_filtered_data_exists = 1;
        end
        handles.BNC_3D = BNC_3D;
        handles.raw_BNC_3D = BNC_3D;
        handles.Xdeviations_3D = Xdeviations_3D;
        handles.Ydeviations_3D = Ydeviations_3D;
        handles.Comments_List = Comments_List;
    case 1
        %load fluorescence data
        handles.DF_ROI_Waveforms_3D = DF_ROI_Waveforms_3D;
        handles.DFperF_ROI_Waveforms_3D = DFperF_ROI_Waveforms_3D;
        %check for analog "BNC" data and set up zeros if not found
        existflag = exist('analog_data_3D', 'var');
        if existflag == 1
            handles.BNC_3D = analog_data_3D;
            handles.raw_BNC_3D = analog_data_3D;
        else %set up blank analog data
            handles.BNC_3D = zeros(8, size(DF_ROI_Waveforms_3D, 2), size(DF_ROI_Waveforms_3D, 3));
            display('analog data not found, zeros used instead.');
        end
        handles.spatially_filtered_data_exists = 0;
        %disable irrelevant radiobuttons

        %set up option for Xdeviations & Ydeviations to men soemthing
        handles.Xdeviations_3D = Xdeviations_3D;
        handles.Ydeviations_3D = Ydeviations_3D;
    otherwise
        m=msgbox('Data not loaded properly');
        
end

if handles.spatially_filtered_data_exists == 0;
    set(handles.DF_sHP_radiobutton_handle, 'Enable', 'off');
    set(handles.DF_sLP_radiobutton_handle, 'Enable', 'off');
    set(handles.DFperF_sHP_radiobutton_handle, 'Enable', 'off');
    set(handles.DFperF_sLP_radiobutton_handle, 'Enable', 'off');
else
    set(handles.DF_sHP_radiobutton_handle, 'Enable', 'on');
    set(handles.DF_sLP_radiobutton_handle, 'Enable', 'on');
    set(handles.DFperF_sHP_radiobutton_handle, 'Enable', 'on');
    set(handles.DFperF_sLP_radiobutton_handle, 'Enable', 'on');
end
    
%load meta-data
handles.Base_Filename = Base_Filename;
handles.Filename_List = Filename_List;
handles.Sampling_Rate = Sampling_Rate;
handles.Stimulus_List = Stimulus_List;


% set up parameters for future use
switch handles.filetype
    case 0
        handles.Num_ROIs = size(DF_ROI_Waveforms_3D, 1);
        handles.Num_Datafiles = size(DF_ROI_Waveforms_3D, 3);
        handles.Num_Frames = size(DF_ROI_Waveforms_3D, 2);
        handles.msec_to_frames_factor = 1000/handles.Sampling_Rate;
    case 1 %This is actually the same, but coded just in case
        handles.Num_ROIs = size(DF_ROI_Waveforms_3D, 1);
        handles.Num_Datafiles = size(DF_ROI_Waveforms_3D, 3);
        handles.Num_Frames = size(DF_ROI_Waveforms_3D, 2);
        handles.msec_to_frames_factor = 1000/handles.Sampling_Rate;
end

%really ought to read these off UI not specify
handles.min_peak_height = 0;
handles.min_peak_interval = 1;
handles.peak_threshold = 0;
handles.max_peak_number = 30;


handles.datatype = 1; %default to DF data 
handles.BNC1 = 0; %default to BNCs off
handles.BNC2 = 0; %default to BNCs off
handles.BNC3 = 0; %default to BNCs off
handles.BNC4 = 0; %default to BNCs off
handles.BNC5 = 0; %default to BNCs off
handles.BNC6 = 0; %default to BNCs off
handles.BNC7 = 0; %default to BNCs off
handles.BNC8 = 0; %default to BNCs off

%reset GUI flags
handles.current_ROI = 1; %Reset to display the first ROI in the comptraces 3D array
handles.current_datafile = 1; %Reset to display the first trial in the comptraces 3D array

%calculate abscissa for plotting based on Sampling Rate and number of data
%points
handles.abscissa = linspace(1, handles.Num_Frames*(1000/Sampling_Rate), handles.Num_Frames);
handles.BNC_sampling_ratio = size(BNC_3D, 2)/size(DF_ROI_Waveforms_3D, 2);
handles.BNC_Sampling_Rate = Sampling_Rate * handles.BNC_sampling_ratio;

%leave raw BNC for measurements, but downsample the main BNC record to
%speed up graphing performance
if handles.BNC_Sampling_Rate > 500
    BNC_flipped = permute(handles.BNC_3D, [2 1 3]);
    BNC_flipped = downsample(BNC_flipped, 10);
    handles.BNC_3D = permute(BNC_flipped, [2 1 3]); %if there's many BNC samples, downsample to improve performance  
    handles.BNC_Sampling_Rate = handles.BNC_Sampling_Rate/10;
end
handles.BNC_Num_Frames = size(handles.BNC_3D, 2);
handles.BNC_abscissa = linspace(1, handles.BNC_Num_Frames*(1000/handles.BNC_Sampling_Rate), handles.BNC_Num_Frames);

%calculate the initial values of everything
handles.current_trace_data = DF_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);

current_BNC1 = handles.BNC_3D(1, 1:handles.BNC_Num_Frames, handles.current_datafile); %grab raw data
for x = 1:handles.BNC_Num_Frames %scale to overlay the DF data
    handles.current_BNC1_scaled(x) = (current_BNC1(x)-min(current_BNC1))/(max(current_BNC1)-min(current_BNC1)); %create normalized BNC signals
end
handles.current_BNC1_scaled = handles.current_BNC1_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC1_scaled = handles.current_BNC1_scaled + min(handles.current_trace_data); %add the F data's offset

current_BNC2 = handles.BNC_3D(2, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC2_scaled(x) = (current_BNC2(x)-min(current_BNC2))/(max(current_BNC2)-min(current_BNC2)); %create normalized BNC signals
end
handles.current_BNC2_scaled = handles.current_BNC2_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC2_scaled = handles.current_BNC2_scaled + min(handles.current_trace_data); %add the F data's offset

current_BNC3 = handles.BNC_3D(3, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC3_scaled(x) = (current_BNC3(x)-min(current_BNC3))/(max(current_BNC3)-min(current_BNC3)); %create normalized BNC signals
end
handles.current_BNC3_scaled = handles.current_BNC3_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC3_scaled = handles.current_BNC3_scaled + min(handles.current_trace_data); %add the F data's offset

current_BNC4 = handles.BNC_3D(4, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC4_scaled(x) = (current_BNC4(x)-min(current_BNC4))/(max(current_BNC4)-min(current_BNC4)); %create normalized BNC signals
end
handles.current_BNC4_scaled = handles.current_BNC4_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC4_scaled = handles.current_BNC4_scaled + min(handles.current_trace_data); %add the F data's offset

current_BNC5 = handles.BNC_3D(5, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC5_scaled(x) = (current_BNC5(x)-min(current_BNC5))/(max(current_BNC5)-min(current_BNC5)); %create normalized BNC signals
end
handles.current_BNC5_scaled = handles.current_BNC5_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC5_scaled = handles.current_BNC5_scaled + min(handles.current_trace_data); %add the F data's offset

current_BNC6 = handles.BNC_3D(6, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC6_scaled(x) = (current_BNC6(x)-min(current_BNC6))/(max(current_BNC6)-min(current_BNC6)); %create normalized BNC signals
end
handles.current_BNC6_scaled = handles.current_BNC6_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC6_scaled = handles.current_BNC6_scaled + min(handles.current_trace_data); %add the F data's offset

current_BNC7 = handles.BNC_3D(7, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC7_scaled(x) = (current_BNC7(x)-min(current_BNC7))/(max(current_BNC7)-min(current_BNC7)); %create normalized BNC signals
end
handles.current_BNC7_scaled = handles.current_BNC7_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC7_scaled = handles.current_BNC7_scaled + min(handles.current_trace_data); %add the F data's offset
  
current_BNC8 = handles.BNC_3D(8, 1:handles.BNC_Num_Frames, handles.current_datafile);
for x = 1:handles.BNC_Num_Frames
    handles.current_BNC8_scaled(x) = (current_BNC8(x)-min(current_BNC8))/(max(current_BNC8)-min(current_BNC8)); %create normalized BNC signals
end
handles.current_BNC8_scaled = handles.current_BNC8_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
handles.current_BNC8_scaled = handles.current_BNC8_scaled + min(handles.current_trace_data); %add the F data's offset

%SET UP THE PEAKS TRACE AND TROUGHS TRACE AS Zeros to start
handles.current_peaks_trace = zeros(1,handles.Num_Frames);
handles.current_troughs_trace = zeros(1,handles.Num_Frames);

%NOW PLOT THE INITIAL VALUES AS A NINE-LINE PLOT
handles.mainplot_handles = plot(handles.mainaxes_handle, handles.abscissa, handles.current_trace_data, handles.BNC_abscissa, handles.current_BNC1_scaled, handles.BNC_abscissa, handles.current_BNC2_scaled, handles.BNC_abscissa, handles.current_BNC3_scaled, handles.BNC_abscissa, handles.current_BNC4_scaled, handles.BNC_abscissa, handles.current_BNC5_scaled, handles.BNC_abscissa, handles.current_BNC6_scaled, handles.BNC_abscissa, handles.current_BNC7_scaled, handles.BNC_abscissa, handles.current_BNC8_scaled, handles.abscissa, handles.current_peaks_trace, handles.abscissa, handles.current_troughs_trace);

%make BNC & peaks/troughs traces invisible by default - note the reference to mainplot, not
%main axes handles
 set(handles.mainplot_handles(2), 'Visible', 'off');
 set(handles.mainplot_handles(3), 'Visible', 'off');
 set(handles.mainplot_handles(4), 'Visible', 'off');
 set(handles.mainplot_handles(5), 'Visible', 'off');
 set(handles.mainplot_handles(6), 'Visible', 'off');
 set(handles.mainplot_handles(7), 'Visible', 'off');
 set(handles.mainplot_handles(8), 'Visible', 'off');
 set(handles.mainplot_handles(9), 'Visible', 'off');
 set(handles.mainplot_handles(10), 'Visible', 'off'); %this is the peaks trace
 set(handles.mainplot_handles(11), 'Visible', 'off'); %this is the troughs trace

xlabel(handles.mainaxes_handle, 'Time (msec)');
ylabel(handles.mainaxes_handle, 'DeltaF');
grid(handles.mainaxes_handle);


%REPEAT FOR THE MOTION CORRECTION GRAPH
%extract the relevant Motion Correction deviation records 
current_Xdeviations = handles.Xdeviations_3D(1, 1:handles.Num_Frames, handles.current_datafile);
current_Ydeviations = handles.Ydeviations_3D(1, 1:handles.Num_Frames, handles.current_datafile);

%now plot the data 
 axes(handles.devsaxes_handle);
 handles.devsplot_handles = plot(handles.devsaxes_handle, handles.abscissa, current_Xdeviations, handles.abscissa, current_Ydeviations);
 legend(handles.devsaxes_handle, 'Xdevs', 'Ydevs', 'Location', 'Eastoutside');
 xlabel(handles.devsaxes_handle, 'Time (msec)');
 ylabel(handles.devsaxes_handle, {'Corr. Motion';'(Pixels)'});
 grid(handles.devsaxes_handle);

%UPDATE ALL LABELS AND AXES
ROI_label = strcat('ROI #', num2str(handles.current_ROI), {' out of '}, num2str(handles.Num_ROIs));
datafiles_label = strcat('Trial #', num2str(handles.current_datafile), {' out of '}, num2str(handles.Num_Datafiles));
set(handles.ROI_number_text, 'String', ROI_label);
set(handles.Data_filename_text, 'String', datafiles_label);
set(handles.comptraces_filename_text, 'String', char(handles.Filename_List{handles.current_datafile}));
drawnow;
%END OF THE LOADING DATA FUNCTION
Update_Peaks_Table(handles);
handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
Update_Plot(handles);
guidata(hObject, handles); %store this data in the handles structure




function Update_Plot(handles)
% handles    structure with handles and user data (see GUIDATA)
if handles.dataloaded == 0
    return %if no data has been loaded, don't try to update the plots
else   
    %first figure out which data we're supposed to be graphing and load it
    selected_data_type_button_handle = get(handles.data_type_radio_panel, 'SelectedObject');
    data_type_button_selected = get(selected_data_type_button_handle, 'Tag');
    switch data_type_button_selected
        case 'DF_radiobutton'   % IMPORTANT NOTE - this handles.current_trace_data is not available outside this function without a guidata call at the end of this function AND after the call to Update_Plot in the calling function
            handles.current_trace_data = handles.DF_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);
            ylabel_string = 'DeltaF';
        case 'DF_sHP_radiobutton'
            handles.current_trace_data = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);
            ylabel_string = 'DeltaF';
        case 'DF_sLP_radiobutton'
            handles.current_trace_data = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);
            ylabel_string = 'DeltaF';
        case 'DFperF_radiobutton'
            handles.current_trace_data = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);
            ylabel_string = 'DeltaF/F';
        case 'DFperF_sHP_radiobutton'
            handles.current_trace_data = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);
            ylabel_string = 'DeltaF/F';
        case 'DFperF_sLP_radiobutton'
            handles.current_trace_data = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, 1:handles.Num_Frames, handles.current_datafile);
            ylabel_string = 'DeltaF/F';
    end

    %extract the relevant Motion Correction deviation records 
    current_Xdeviations = handles.Xdeviations_3D(1, 1:handles.Num_Frames, handles.current_datafile);
    current_Ydeviations = handles.Ydeviations_3D(1, 1:handles.Num_Frames, handles.current_datafile);

    %Update the BNC data, but to save time only update the ones that are visible
    if handles.BNC1 == 1
        current_BNC1 = handles.BNC_3D(1, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC1_scaled(x) = (current_BNC1(x)-min(current_BNC1))/(max(current_BNC1)-min(current_BNC1)); %create normalized BNC signals
        end
        handles.current_BNC1_scaled = handles.current_BNC1_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC1_scaled = handles.current_BNC1_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC2 == 1
        current_BNC2 = handles.BNC_3D(2, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC2_scaled(x) = (current_BNC2(x)-min(current_BNC2))/(max(current_BNC2)-min(current_BNC2)); %create normalized BNC signals
        end
        handles.current_BNC2_scaled = handles.current_BNC2_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC2_scaled = handles.current_BNC2_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC3 == 1
        current_BNC3 = handles.BNC_3D(3, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC3_scaled(x) = (current_BNC3(x)-min(current_BNC3))/(max(current_BNC3)-min(current_BNC3)); %create normalized BNC signals
        end
        handles.current_BNC3_scaled = handles.current_BNC3_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC3_scaled = handles.current_BNC3_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC4 == 1
        current_BNC4 = handles.BNC_3D(4, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC4_scaled(x) = (current_BNC4(x)-min(current_BNC4))/(max(current_BNC4)-min(current_BNC4)); %create normalized BNC signals
        end
        handles.current_BNC4_scaled = handles.current_BNC4_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC4_scaled = handles.current_BNC4_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC5 == 1
        current_BNC5 = handles.BNC_3D(5, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC5_scaled(x) = (current_BNC5(x)-min(current_BNC5))/(max(current_BNC5)-min(current_BNC5)); %create normalized BNC signals
        end
        handles.current_BNC5_scaled = handles.current_BNC5_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC5_scaled = handles.current_BNC5_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC6 == 1
        current_BNC6 = handles.BNC_3D(6, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC6_scaled(x) = (current_BNC6(x)-min(current_BNC6))/(max(current_BNC6)-min(current_BNC6)); %create normalized BNC signals
        end
        handles.current_BNC6_scaled = handles.current_BNC6_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC6_scaled = handles.current_BNC6_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC7 == 1
        current_BNC7 = handles.BNC_3D(7, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC7_scaled(x) = (current_BNC7(x)-min(current_BNC7))/(max(current_BNC7)-min(current_BNC7)); %create normalized BNC signals
        end
        handles.current_BNC7_scaled = handles.current_BNC7_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC7_scaled = handles.current_BNC7_scaled + min(handles.current_trace_data); %add the F data's offset
    end

    if handles.BNC8 == 1
        current_BNC8 = handles.BNC_3D(8, 1:handles.BNC_Num_Frames, handles.current_datafile);
        for x = 1:handles.BNC_Num_Frames
            handles.current_BNC8_scaled(x) = (current_BNC8(x)-min(current_BNC8))/(max(current_BNC8)-min(current_BNC8)); %create normalized BNC signals
        end
        handles.current_BNC8_scaled = handles.current_BNC8_scaled * (max(handles.current_trace_data)- min(handles.current_trace_data)); %match the F data's dynamic range
        handles.current_BNC8_scaled = handles.current_BNC8_scaled + min(handles.current_trace_data); %add the F data's offset
    end
    
    %UPDATE THE EXISTING PLOT
    set(handles.mainplot_handles(1), 'Xdata', handles.abscissa, 'Ydata', handles.current_trace_data);
    set(handles.mainplot_handles(2), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC1_scaled);
    set(handles.mainplot_handles(3), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC2_scaled);
    set(handles.mainplot_handles(4), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC3_scaled);
    set(handles.mainplot_handles(5), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC4_scaled);
    set(handles.mainplot_handles(6), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC5_scaled);
    set(handles.mainplot_handles(7), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC6_scaled);
    set(handles.mainplot_handles(8), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC7_scaled);
    set(handles.mainplot_handles(9), 'Xdata', handles.BNC_abscissa, 'Ydata', handles.current_BNC8_scaled);

    % now update the motion correction plot
    set(handles.devsplot_handles(1), 'Xdata', handles.abscissa, 'Ydata', current_Xdeviations);
    set(handles.devsplot_handles(2), 'Xdata', handles.abscissa, 'Ydata', current_Ydeviations);

    %Update the Y axis label based on data type
    ylabel(handles.mainaxes_handle, char(ylabel_string));
    
    %Update the PEAKS and TROUGHS Traces if needed
    if handles.peakfile_loaded == 1 %if there are peaks to consider - WARNING THIS DOESN'T CURRENTLY REGISTER HAND MEASURED PEAKS
        handles.current_trough_peak_index_record = get(handles.table_handle, 'Data');
        try num_peaks = size(handles.current_trough_peak_index_record, 1); %if there are peaks this trial & ROI, how many?
        catch 
            num_peaks = 0; %if the current trial has no record, there are no peaks
            display('current_trough_peak_index_record not found');          
        end
        if num_peaks > 0 %if the current trial & ROI has peaks recorded
            handles.current_troughs_frames = handles.current_trough_peak_index_record(:,1)/handles.msec_to_frames_factor; %convert to frames
            handles.current_peaks_frames = handles.current_trough_peak_index_record(:,2)/handles.msec_to_frames_factor; %convert to frames
            current_peak_amps = zeros(1, num_peaks); %make array for num peaks
            current_trough_amps = zeros(1, num_peaks); %make array for num peaks
            for i=1:num_peaks
                current_peak_amps(i) = handles.current_trace_data(handles.current_peaks_frames(i)); %set each element to corresponding data value
                current_trough_amps(i) = handles.current_trace_data(handles.current_troughs_frames(i)); %set each element to corresponding data value
            end          
            handles.current_peaks_trace = generate_analog_peakswave(current_peak_amps, handles.current_peaks_frames, handles.Num_Frames); %generate a trace of zeros with points matching the data at each peak
            handles.current_troughs_trace = generate_analog_peakswave(current_trough_amps, handles.current_troughs_frames, handles.Num_Frames); %generate a trace of zeros with points matching the data at each peak
            set(handles.mainplot_handles(10), 'Xdata', handles.abscissa, 'Ydata', handles.current_peaks_trace);
            set(handles.mainplot_handles(10), 'Visible', 'on'); %this is the peaks trace
            set(handles.mainplot_handles(11), 'Xdata', handles.abscissa, 'Ydata', handles.current_troughs_trace);
            set(handles.mainplot_handles(11), 'Visible', 'on'); %this is the troughs trace            
        else
            set(handles.mainplot_handles(10), 'Visible', 'off'); %this is the peaks trace
            set(handles.mainplot_handles(11), 'Visible', 'off'); %this is the troughs trace
        end
    end        

%NOTE: eventually going to use either getpts or datacursor to select points

    %update labels on the screen
    ROI_label = strcat('ROI #', num2str(handles.current_ROI), {' out of '}, num2str(handles.Num_ROIs));
    datafiles_label = strcat('Trial #', num2str(handles.current_datafile), {' out of '}, num2str(handles.Num_Datafiles));
    set(handles.ROI_number_text, 'String', ROI_label);
    set(handles.Data_filename_text, 'String', datafiles_label);
    set(handles.comptraces_filename_text, 'String', char(handles.Filename_List{handles.current_datafile}));
    stimulus_label = strcat('Stimulus:', handles.Stimulus_List{handles.current_datafile});
    set(handles.stimulus_text, 'String', char(stimulus_label));   

    drawnow;
end



function Update_Peaks_Table(handles)
% handles    structure with handles and user data (see GUIDATA)
if handles.peakfile_loaded == 1
    % first get rid of the old record so we don't have size issues
    clear handles.current_trough_peak_index_record;
    %figure out where the measured troughs and peaks are for the displayed
    %trace
    handles.current_trough_peak_index_record = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,4) == handles.current_ROI & handles.global_trough_peak_index_record(:,3)==handles.current_datafile, :);   
    if size(handles.current_trough_peak_index_record, 2) > 0
        handles.current_trough_peak_index_record = sortrows(handles.current_trough_peak_index_record, 2); %reorder peaks to be in sequence
        peak_order = linspace(1, size(handles.current_trough_peak_index_record, 1), size(handles.current_trough_peak_index_record, 1));
        peak_order = peak_order';
        handles.current_trough_peak_index_record(:,6) = peak_order(:); %add the peak numbers to the displayed records
        %handles.current_trough_peak_index_record(:,3) = handles.current_datafile;
        %handles.current_trough_peak_index_record(:,4) = handles.current_ROI; 
        set(handles.table_handle, 'Data', handles.current_trough_peak_index_record);
    else
        set(handles.table_handle, 'Data', handles.current_trough_peak_index_record);
    end
    
    for i=1:size(handles.current_trough_peak_index_record, 1) %write the peak order to the global record - this gets updated every time we access it in case the tabel gets edited
        %display(i)
        handles.global_trough_peak_index_record((handles.global_trough_peak_index_record(:,5)==handles.current_trough_peak_index_record(i,5)), 6) = handles.current_trough_peak_index_record(i,6);
        %display(handles.global_trough_peak_index_record((handles.global_trough_peak_index_record(:,5)==handles.current_trough_peak_index_record(i,5)),5:6));
        %display(handles.current_trough_peak_index_record(i,:));
    end
    
    %if there's a zero anywhere in the current record, turn text red until it's fixed
    if min(min(handles.current_trough_peak_index_record(:,1:5)))<1
        set(handles.table_handle, 'ForegroundColor', 'red');
    else
        if min((handles.current_trough_peak_index_record(:, 2) - handles.current_trough_peak_index_record(:, 1))) < 1 %if there's a peak that isn't after a trough
            set(handles.table_handle, 'ForegroundColor', 'red');
        else
            if size(unique(handles.current_trough_peak_index_record(:,2)),1) < size(handles.current_trough_peak_index_record(:,2),1) %if there are duplicate peaks with same latency 
                set(handles.table_handle, 'ForegroundColor', 'red');
            else
                set(handles.table_handle, 'ForegroundColor', 'black');
            end
        end
    end
end
guidata(handles.output, handles); %store this data in the handles structure


% --- Executes on button press in previous_ROI_button.
function previous_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI > 1
    handles.current_ROI = handles.current_ROI-1;
    if handles.peakfile_loaded == 1
        Update_Peaks_Table(handles);
    end
    Update_Plot(handles);
end
guidata(hObject, handles); %update data in the handles structure



% --- Executes on button press in next_ROI_button.
function next_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI < handles.Num_ROIs
    handles.current_ROI = handles.current_ROI+1;
    if handles.peakfile_loaded == 1
        Update_Peaks_Table(handles);
        handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
    end
    Update_Plot(handles);
end
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in previous_datafile_button.
function previous_datafile_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_datafile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_datafile > 1
    handles.current_datafile = handles.current_datafile-1;
    if handles.peakfile_loaded == 1
        Update_Peaks_Table(handles);
        handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
    end
    Update_Plot(handles);
end
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in next_datafile_button.
function next_datafile_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_datafile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_datafile < handles.Num_Datafiles
    handles.current_datafile = handles.current_datafile+1;
    if handles.peakfile_loaded == 1
        Update_Peaks_Table(handles);
        handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
    end
    Update_Plot(handles);
end
guidata(hObject, handles); %update data in the handles structure


% --------------------------------------------------------------------
function data_type_radio_panel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to data_type_radio_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes when selected object is changed in data_type_radio_panel.
function data_type_radio_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in data_type_radio_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
if get(hObject, 'Value') == 1
    handles.BNC1 = 1; %turn BNC flag on
    set(handles.mainplot_handles(2), 'Visible', 'on');
else
    handles.BNC1 = 0; %turn BNC flag off
    set(handles.mainplot_handles(2), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure



% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
if get(hObject, 'Value') == 1
    handles.BNC2 = 1; %turn BNC flag on
    set(handles.mainplot_handles(3), 'Visible', 'on');    
else
    handles.BNC2 = 0; %turn BNC flag off
    set(handles.mainplot_handles(3), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
if get(hObject, 'Value') == 1
    handles.BNC3 = 1; %turn BNC flag on
    set(handles.mainplot_handles(4), 'Visible', 'on');
else
    handles.BNC3 = 0; %turn BNC flag off
    set(handles.mainplot_handles(4), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
if get(hObject, 'Value') == 1
    handles.BNC4 = 1; %turn BNC flag on
    set(handles.mainplot_handles(5), 'Visible', 'on');
else
    handles.BNC4 = 0; %turn BNC flag off
    set(handles.mainplot_handles(5), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
if get(hObject, 'Value') == 1
    handles.BNC5 = 1; %turn BNC flag on
    set(handles.mainplot_handles(6), 'Visible', 'on');
else
    handles.BNC5 = 0; %turn BNC flag off
    set(handles.mainplot_handles(6), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
if get(hObject, 'Value') == 1
    handles.BNC6 = 1; %turn BNC flag on
    set(handles.mainplot_handles(7), 'Visible', 'on');
else
    handles.BNC6 = 0; %turn BNC flag off
    set(handles.mainplot_handles(7), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
if get(hObject, 'Value') == 1
    handles.BNC7 = 1; %turn BNC flag on
    set(handles.mainplot_handles(8), 'Visible', 'on');
else
    handles.BNC7 = 0; %turn BNC flag off
    set(handles.mainplot_handles(8), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
if get(hObject, 'Value') == 1
    handles.BNC8 = 1; %turn BNC flag on
    set(handles.mainplot_handles(9), 'Visible', 'on');
else
    handles.BNC8 = 0; %turn BNC flag off
    set(handles.mainplot_handles(9), 'Visible', 'off');
end
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in find_peaks_button.
function find_peaks_button_Callback(hObject, eventdata, handles)
% hObject    handle to find_peaks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%[x,y] = getpts(handles.mainaxes_handle);
%x
%y
%axes(handles.mainaxes_handle);
%handles.dcm_obj = datacursormode;
if handles.dataloaded == 1
    if handles.peakfile_loaded == 0 %this handles the case where no global peak database exists yet
        handles.global_trough_peak_index_record = zeros(1,26);
        display('re-zeroed global peakfile')
        handles.peakfile_loaded = 1;
        need_to_delete_first_row = 1;
    else
        need_to_delete_first_row = 0;
    end
    if size(handles.global_trough_peak_index_record,1) == 0 %this handles the case where the global peak database has been cleared
        handles.global_trough_peak_index_record = zeros(1,26);
        display('re-zeroed global peakfile 2')
        handles.peakfile_loaded = 1;
        need_to_delete_first_row = 1;
    else
        need_to_delete_first_row = 0;  
    end
    
    
    current_trace_data = get(handles.mainplot_handles(1), 'YData'); %note that current_trace_data updates right off the graph
    smoothed_trace = smooth(current_trace_data); %add some smoothing to help with noise
    [rough_peak_amps, peak_locs]=findpeaks(smoothed_trace, 'minpeakheight', handles.min_peak_height, 'minpeakdistance', handles.min_peak_interval, 'threshold', handles.peak_threshold, 'npeaks', handles.max_peak_number);
    if size(peak_locs) == 0;
        msgbox('Error: there were no peaks found on this trace');
        return
    end
    
    %now find trough before each peak
    num_peaks = size(peak_locs, 1);
    if num_peaks > 1 %if there's an interpeak interval to work with
        for i=1:num_peaks-1 %skip the first peak for now, stop at the last interpeak interval
            trough_window = [];
            trough_window = current_trace_data(peak_locs(i):peak_locs(i+1));
            [min_val, local_trough_min_index] = min(trough_window);
            trough_locs(i+1) = peak_locs(i)+local_trough_min_index-1; %the minus one corrects for the peak frame itself
        end
    end
    %ideally look back the equivalent of the first inter-peak interval for the
    %first trough
    if num_peaks > 1 %if there's an interpeak interval to work with
        first_interpeak_interval = peak_locs(2) - peak_locs(1);
        starting_point = peak_locs(1)-first_interpeak_interval;
        if starting_point < 1
            starting_point = 1;
        end
        first_trough_window = current_trace_data(starting_point:peak_locs(1));
        [min_val, relative_first_trough_loc] = min(first_trough_window);
        trough_locs(1) = relative_first_trough_loc+starting_point;
    else %if only one peak, look back half a second
        if size(peak_locs) == 1
            starting_point = peak_locs(1)-round(handles.Sampling_Rate/2);
            msgbox('Only 1 peak, looking back ~500 msec for trough');
            first_trough_window = current_trace_data(starting_point:peak_locs(1));
            [min_val, relative_first_trough_loc] = min(first_trough_window);
            trough_locs(1) = relative_first_trough_loc+starting_point;            
        else
            msgbox('No peaks found');
            return
        end
    end
    
    
    %calculate values of peaks relative to their own trough based on selected latencies
    for i=1:size(peak_locs)
        peak_amp_DF(i) = handles.DF_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DF_ROI_Waveforms_3D(handles.current_ROI, trough_locs(i), handles.current_datafile);
        peak_amp_DF_sHP(i) = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(i), handles.current_datafile);
        peak_amp_DF_sLP(i) = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(i), handles.current_datafile);
        peak_amp_DFperF(i) = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, trough_locs(i), handles.current_datafile);
        peak_amp_DFperF_sHP(i) = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(i), handles.current_datafile);
        peak_amp_DFperF_sLP(i) = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(i), handles.current_datafile);
    end

        %calculate values of peaks relative to the pre-stimulus (first) trough based on selected latencies
    for i=1:size(peak_locs)
        peak_amp_DF_vs_baseline(i) = handles.DF_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DF_ROI_Waveforms_3D(handles.current_ROI, trough_locs(1), handles.current_datafile);
        peak_amp_DF_sHP_vs_baseline(i) = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(1), handles.current_datafile);
        peak_amp_DF_sLP_vs_baseline(i) = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(1), handles.current_datafile);
        peak_amp_DFperF_vs_baseline(i) = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, trough_locs(1), handles.current_datafile);
        peak_amp_DFperF_sHP_vs_baseline(i) = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(1), handles.current_datafile);
        peak_amp_DFperF_sLP_vs_baseline(i) = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, peak_locs(i), handles.current_datafile) - handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, trough_locs(1), handles.current_datafile);
    end
    
    for i = 1:size(peak_locs)
        BNC1_value(i) = handles.raw_BNC_3D(1, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC2_value(i) = handles.raw_BNC_3D(2, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC3_value(i) = handles.raw_BNC_3D(3, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC4_value(i) = handles.raw_BNC_3D(4, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC5_value(i) = handles.raw_BNC_3D(5, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC6_value(i) = handles.raw_BNC_3D(6, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC7_value(i) = handles.raw_BNC_3D(7, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC8_value(i) = handles.raw_BNC_3D(8, peak_locs(i)*handles.BNC_sampling_ratio, handles.current_datafile);
    end
    
    %get info on current state of peaks record, then store the new peaks
    for i=1:size(peak_locs)
        num_rows = size(handles.global_trough_peak_index_record,1);
        max_index = max(handles.global_trough_peak_index_record(:,5));
        handles.global_trough_peak_index_record(num_rows+1, 5) = max_index+1;
        handles.global_trough_peak_index_record(num_rows+1, 4) = handles.current_ROI;
        handles.global_trough_peak_index_record(num_rows+1, 3) = handles.current_datafile;
        handles.global_trough_peak_index_record(num_rows+1, 2) = peak_locs(i)*handles.msec_to_frames_factor;
        handles.global_trough_peak_index_record(num_rows+1, 1) = trough_locs(i)*handles.msec_to_frames_factor; %initial trough value is 1st sample

        handles.global_trough_peak_index_record(num_rows+1, 7) = peak_amp_DF(i);
        handles.global_trough_peak_index_record(num_rows+1, 8) = peak_amp_DF_sHP(i);
        handles.global_trough_peak_index_record(num_rows+1, 9) = peak_amp_DF_sLP(i);
        handles.global_trough_peak_index_record(num_rows+1, 10) = peak_amp_DFperF(i);
        handles.global_trough_peak_index_record(num_rows+1, 11) = peak_amp_DFperF_sHP(i);
        handles.global_trough_peak_index_record(num_rows+1, 12) = peak_amp_DFperF_sLP(i);

        handles.global_trough_peak_index_record(num_rows+1, 13) = peak_amp_DF_vs_baseline(i);
        handles.global_trough_peak_index_record(num_rows+1, 14) = peak_amp_DF_sHP_vs_baseline(i);
        handles.global_trough_peak_index_record(num_rows+1, 15) = peak_amp_DF_sLP_vs_baseline(i);
        handles.global_trough_peak_index_record(num_rows+1, 16) = peak_amp_DFperF_vs_baseline(i);
        handles.global_trough_peak_index_record(num_rows+1, 17) = peak_amp_DFperF_sHP_vs_baseline(i);
        handles.global_trough_peak_index_record(num_rows+1, 18) = peak_amp_DFperF_sLP_vs_baseline(i);    

        handles.global_trough_peak_index_record(num_rows+1, 19) = BNC1_value(i);        
        handles.global_trough_peak_index_record(num_rows+1, 20) = BNC2_value(i);
        handles.global_trough_peak_index_record(num_rows+1, 21) = BNC3_value(i);
        handles.global_trough_peak_index_record(num_rows+1, 22) = BNC4_value(i);
        handles.global_trough_peak_index_record(num_rows+1, 23) = BNC5_value(i);        
        handles.global_trough_peak_index_record(num_rows+1, 24) = BNC6_value(i);
        handles.global_trough_peak_index_record(num_rows+1, 25) = BNC7_value(i);
        handles.global_trough_peak_index_record(num_rows+1, 26) = BNC8_value(i);    
        
        %assign the category value to zero - this allows manual editing or
        %automated editing later
        handles.global_trough_peak_index_record(num_rows+1, 27) = 0;
        
        %store the baseline trough info for later
        handles.global_trough_peak_index_record(num_rows+1, 28) = trough_locs(1)*(1000/handles.Sampling_Rate);

    end
    if need_to_delete_first_row == 1
        handles.global_trough_peak_index_record(1, :) = [];
    end
    Update_Peaks_Table(handles);
    handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
    Update_Plot(handles);
    
    %peak_values = handles.current_trace_data(peak_locs); %gets the real
    %value at peak
else
    msgbox('Data must be loaded before finding peaks!');
end
guidata(hObject, handles); %update data in the handles structure



% --- Executes on button press in choosetroughsbutton.
function choosetroughsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to choosetroughsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dcm_results = getCursorInfo(handles.dcm_obj);
handles.current_trough_peak_index_record(1,1) = dcm_results.DataIndex;
handles.current_trough_peak_index_record(1,3) = handles.current_datafile;
handles.current_trough_peak_index_record(1,4) = handles.current_ROI;
set(handles.table_handle, 'Data', handles.current_trough_peak_index_record);

guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in recordbutton.
function recordbutton_Callback(hObject, eventdata, handles)
% hObject    handle to recordbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dcm_results = getCursorInfo(handles.dcm_obj);
handles.current_trough_peak_index_record(1,2) = dcm_results.DataIndex;
handles.current_trough_peak_index_record(1,3) = handles.current_datafile;
handles.current_trough_peak_index_record(1,4) = handles.current_ROI;
set(handles.table_handle, 'Data', handles.current_trough_peak_index_record);

guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in load_peaks_button.
function load_peaks_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_peaks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%prompt user to find an existing peaks file
if handles.dataloaded == 1
    [rdfile, pathname]=uigetfile({'*_peaks.mat','_peaks File (*_peaks.mat)'}, 'Choose existing peaks file');
    cd(char(pathname));
    load(rdfile);
    handles.global_trough_peak_index_record = Peaks_Table;

    set(handles.peaks_filename_textbox, 'String', char(rdfile));
    handles.peakfile_loaded = 1; %update flag
    Update_Peaks_Table(handles);
    handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
    fclose('all');
else
    msgbox('Data File Must Be Loaded Before Peaks File');
end
Update_Peaks_Table(handles);
handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
Update_Plot(handles);
guidata(hObject, handles); %update data in the handles structure



% --- Executes on button press in save_peaks_button.
function save_peaks_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_peaks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.peakfile_loaded == 1
    savefile_name = strcat(handles.Base_Filename, '_peaks.mat');
    header = {'Trough Time','Peak Time', 'Trial#', 'ROI#', 'Index', 'PeakNum', 'DF', 'DF_sHP', 'DF_sLP', 'DF/F', 'DF/F_sHP', 'DF/F_sLP', 'DF_vs_base', 'DF_sHP_vs_base', 'DF_sLP_vs_base', 'DF/F_vs_base', 'DF/F_sHP_vs_base', 'DF/F_sLP_vs_base', 'BNC1', 'BNC2', 'BNC3', 'BNC4', 'BNC5', 'BNC6', 'BNC7', 'BNC8', 'Category'};

    %Make local copies of all the data passed by handle so you can save it
    Peaks_Table = handles.global_trough_peak_index_record;
    Base_Filename = handles.Base_Filename;
    Comments_List = handles.Comments_List;
    Filename_List = handles.Filename_List;
    Sampling_Rate = handles.Sampling_Rate;
    Stimulus_List = handles.Stimulus_List;

    %get the desired filename and directory - feed the basefilename_peaks
    [writefile, pathname]=uiputfile('*_peaks.mat', 'Where do you want to save the peaks file?',char(savefile_name));
    cd(char(pathname));
    save(writefile, 'Peaks_Table', 'Base_Filename', 'Filename_List', 'Sampling_Rate', 'Stimulus_List', 'header');
    fclose('all');
    set(handles.peaks_filename_textbox, 'String', char(writefile));
else
    msgbox('No Peaks File Loaded')
end
guidata(hObject, handles); %update data in the handles structure



function min_peak_height_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to min_peak_height_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_peak_height_textbox as text
%        str2double(get(hObject,'String')) returns contents of min_peak_height_textbox as a double
handles.min_peak_height = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function min_peak_height_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_peak_height_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_peak_interval_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to min_peak_interval_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_peak_interval_textbox as text
%        str2double(get(hObject,'String')) returns contents of min_peak_interval_textbox as a double
if handles.dataloaded == 1
    min_peak_interval_msec = str2num(get(hObject,'String'));
    if mod(min_peak_interval_msec, handles.msec_to_frames_factor) > 0 %if the time entered is not exactly on a frame border
        min_peak_interval_msec = round(min_peak_interval_msec/handles.msec_to_frames_factor)*handles.msec_to_frames_factor; %move to closest frame border
        msgbox('Minimum interval updated to match closest frame number based on sampling rate');
    end
    if min_peak_interval_msec < 1000/handles.Sampling_Rate
        msgbox('Error: Minimum Peak Interval must be at least one sample duration.');
        set(hObject, 'String', num2str(1000/handles.Sampling_Rate));
        min_peak_interval_msec = 1000/handles.Sampling_Rate;
    end
    set(hObject, 'String', num2str(min_peak_interval_msec));
    handles.min_peak_interval = min_peak_interval_msec/handles.msec_to_frames_factor;
    guidata(hObject,handles);
else
    msgbox('Data must be loaded before editing minimum intervals');
    set(hObject, 'String', num2str(1));
end


% --- Executes during object creation, after setting all properties.
function min_peak_interval_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_peak_interval_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in results_table.
function results_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to results_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.current_trough_peak_index_record = get(handles.table_handle, 'Data');
%edited row index is the fifth element in the row that was edited
edited_row_index = handles.current_trough_peak_index_record(eventdata.Indices(1), 5);
edited_column = eventdata.Indices(2);
global_peak_index = edited_row_index; %this is redundant but used later in the code
new_value = str2num(eventdata.EditData);
if edited_column <= 2 || edited_column == 28 %if it's a latency column
    if mod(new_value, handles.msec_to_frames_factor) > 0 %if the time entered is not exactly on a frame border
        new_value = round(new_value/handles.msec_to_frames_factor)*handles.msec_to_frames_factor; %move to closest frame border
        msgbox('Time value updated to match closest frame number based on sampling rate');
    end
end
handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==edited_row_index, edited_column) = new_value;

baseline_latency_changed = 0; %reset flag prior to condition test
%if a latency has changed, update measurements for that row
if edited_column <= 2 || edited_column == 28 %if it's a latency column
    if handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,6) == 1 %if it was the first peak in the trial that changed
        if edited_column==1 || edited_column == 28 %if it's the trough latency (and therefore the baseline trough time used for measurements on other peaks too
            baseline_latency_changed = 1;
            ROI_changed = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,4);
            trial_changed = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,3);
            indices_changed = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,4)==ROI_changed & handles.global_trough_peak_index_record(:,3)==trial_changed,5);
            handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,1)=new_value;
            handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,28)=new_value;
        end
    end
    
    if baseline_latency_changed == 1
         num_indices_changed = size(indices_changed, 1);
    else
        num_indices_changed = 1;
        indices_changed = global_peak_index;
    end

    for x=1:num_indices_changed
        global_peak_index = indices_changed(x);
        if num_indices_changed > 1
            handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,28) = new_value;
        end
        
        %get the latencies of the peak in frames
        %display(handles.global_trough_peak_index_record);
        peaklat = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,2);
        troughlat = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,1);
        baseline_troughlat = handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index,28);
        peaklat_inframes = peaklat/handles.msec_to_frames_factor;
        troughlat_inframes = troughlat/handles.msec_to_frames_factor;
        baseline_troughlat_inframes = baseline_troughlat/handles.msec_to_frames_factor;

        %calculate values of peaks relative to their own trough based on selected latencies
        peak_amp_DF = handles.DF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
        peak_amp_DF_sHP = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
        peak_amp_DF_sLP = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
        peak_amp_DFperF = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
        peak_amp_DFperF_sHP = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
        peak_amp_DFperF_sLP = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);


        %calculate values of peaks relative to the pre-stimulus (first) trough based on selected latencies
        peak_amp_DF_vs_baseline = handles.DF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
        peak_amp_DF_sHP_vs_baseline = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
        peak_amp_DF_sLP_vs_baseline = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
        peak_amp_DFperF_vs_baseline = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
        peak_amp_DFperF_sHP_vs_baseline = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
        peak_amp_DFperF_sLP_vs_baseline = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);

        BNC1_value = handles.raw_BNC_3D(1, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC2_value = handles.raw_BNC_3D(2, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC3_value = handles.raw_BNC_3D(3, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC4_value = handles.raw_BNC_3D(4, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC5_value = handles.raw_BNC_3D(5, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC6_value = handles.raw_BNC_3D(6, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC7_value = handles.raw_BNC_3D(7, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        BNC8_value = handles.raw_BNC_3D(8, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);

        %store the new peaks
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 7) = peak_amp_DF;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 8) = peak_amp_DF_sHP;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 9) = peak_amp_DF_sLP;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 10) = peak_amp_DFperF;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 11) = peak_amp_DFperF_sHP;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 12) = peak_amp_DFperF_sLP;

             handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 13) = peak_amp_DF_vs_baseline;
             handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 14) = peak_amp_DF_sHP_vs_baseline;
             handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 15) = peak_amp_DF_sLP_vs_baseline;
             handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 16) = peak_amp_DFperF_vs_baseline;
             handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 17) = peak_amp_DFperF_sHP_vs_baseline;
             handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 18) = peak_amp_DFperF_sLP_vs_baseline;    

        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 19) = BNC1_value;        
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 20) = BNC2_value;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 21) = BNC3_value;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 22) = BNC4_value;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 23) = BNC5_value;        
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 24) = BNC6_value;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 25) = BNC7_value;
        handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==global_peak_index, 26) = BNC8_value;    

    end
end

Update_Peaks_Table(handles);
handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
Update_Plot(handles);
guidata(hObject, handles);




% --- Executes when selected cell(s) is changed in results_table.
function results_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to results_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.selected_cell_indices = eventdata.Indices;
if size(eventdata.Indices,1) > 0
    current_trough_peak_index_record = get(handles.table_handle, 'Data');
    handles.selected_row_index = current_trough_peak_index_record(eventdata.Indices(1),5);
end
guidata(hObject, handles);


% --- Executes on button press in add_row_button.
function add_row_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_row_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
peaklat_cell = inputdlg('What is the estimated PEAK latency?');
peaklat = str2num(peaklat_cell{1});
if mod(peaklat, handles.msec_to_frames_factor) > 0 %if the time entered is not exactly on a frame border
    peaklat = round(peaklat/handles.msec_to_frames_factor)*handles.msec_to_frames_factor; %move to closest frame border
    msgbox('Peak time value updated to match closest frame number based on sampling rate');
end
troughlat_cell = inputdlg('What is the estimated TROUGH latency?');
troughlat = str2num(troughlat_cell{1});
if mod(troughlat, handles.msec_to_frames_factor) > 0 %if the time entered is not exactly on a frame border
    troughlat = round(troughlat/handles.msec_to_frames_factor)*handles.msec_to_frames_factor; %move to closest frame border
    msgbox('Trough time value updated to match closest frame number based on sampling rate');
end
baselinelat_cell = inputdlg('What is the estimated BASELINE trough latency?');
baseline_troughlat = str2num(baselinelat_cell{1});
if mod(baseline_troughlat, handles.msec_to_frames_factor) > 0 %if the time entered is not exactly on a frame border
    baseline_troughlat = round(baseline_troughlat/handles.msec_to_frames_factor)*handles.msec_to_frames_factor; %move to closest frame border
    msgbox('Baseline trough time value updated to match closest frame number based on sampling rate');
end
baseline_troughlat_inframes = baseline_troughlat / handles.msec_to_frames_factor;
troughlat_inframes = troughlat / handles.msec_to_frames_factor;
peaklat_inframes = peaklat / handles.msec_to_frames_factor;

num_rows = size(handles.global_trough_peak_index_record,1);
max_index = max(handles.global_trough_peak_index_record(:,5));
handles.global_trough_peak_index_record(num_rows+1, 5) = max_index+1;
handles.global_trough_peak_index_record(num_rows+1, 4) = handles.current_ROI;
handles.global_trough_peak_index_record(num_rows+1, 3) = handles.current_datafile;
handles.global_trough_peak_index_record(num_rows+1, 2) = peaklat;
handles.global_trough_peak_index_record(num_rows+1, 1) = troughlat;



    %calculate values of peaks relative to their own trough based on selected latencies
    peak_amp_DF = handles.DF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
    peak_amp_DF_sHP = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
    peak_amp_DF_sLP = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
    peak_amp_DFperF = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
    peak_amp_DFperF_sHP = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);
    peak_amp_DFperF_sLP = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, troughlat_inframes, handles.current_datafile);


    %calculate values of peaks relative to the pre-stimulus (first) trough based on selected latencies
    peak_amp_DF_vs_baseline = handles.DF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
    peak_amp_DF_sHP_vs_baseline = handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sHP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
    peak_amp_DF_sLP_vs_baseline = handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DF_sLP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
    peak_amp_DFperF_vs_baseline = handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
    peak_amp_DFperF_sHP_vs_baseline = handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sHP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
    peak_amp_DFperF_sLP_vs_baseline = handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, peaklat_inframes, handles.current_datafile) - handles.DFperF_sLP_ROI_Waveforms_3D(handles.current_ROI, baseline_troughlat_inframes, handles.current_datafile);
     
    BNC1_value = handles.raw_BNC_3D(1, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC2_value = handles.raw_BNC_3D(2, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC3_value = handles.raw_BNC_3D(3, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC4_value = handles.raw_BNC_3D(4, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC5_value = handles.raw_BNC_3D(5, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC6_value = handles.raw_BNC_3D(6, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC7_value = handles.raw_BNC_3D(7, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
    BNC8_value = handles.raw_BNC_3D(8, peaklat_inframes*handles.BNC_sampling_ratio, handles.current_datafile);
        
    %get info on current state of peaks record, then store the new peaks
    handles.global_trough_peak_index_record(num_rows+1, 7) = peak_amp_DF;
    handles.global_trough_peak_index_record(num_rows+1, 8) = peak_amp_DF_sHP;
    handles.global_trough_peak_index_record(num_rows+1, 9) = peak_amp_DF_sLP;
    handles.global_trough_peak_index_record(num_rows+1, 10) = peak_amp_DFperF;
    handles.global_trough_peak_index_record(num_rows+1, 11) = peak_amp_DFperF_sHP;
    handles.global_trough_peak_index_record(num_rows+1, 12) = peak_amp_DFperF_sLP;

         handles.global_trough_peak_index_record(num_rows+1, 13) = peak_amp_DF_vs_baseline;
         handles.global_trough_peak_index_record(num_rows+1, 14) = peak_amp_DF_sHP_vs_baseline;
         handles.global_trough_peak_index_record(num_rows+1, 15) = peak_amp_DF_sLP_vs_baseline;
         handles.global_trough_peak_index_record(num_rows+1, 16) = peak_amp_DFperF_vs_baseline;
         handles.global_trough_peak_index_record(num_rows+1, 17) = peak_amp_DFperF_sHP_vs_baseline;
         handles.global_trough_peak_index_record(num_rows+1, 18) = peak_amp_DFperF_sLP_vs_baseline;    

    handles.global_trough_peak_index_record(num_rows+1, 19) = BNC1_value;        
    handles.global_trough_peak_index_record(num_rows+1, 20) = BNC2_value;
    handles.global_trough_peak_index_record(num_rows+1, 21) = BNC3_value;
    handles.global_trough_peak_index_record(num_rows+1, 22) = BNC4_value;
    handles.global_trough_peak_index_record(num_rows+1, 23) = BNC5_value;        
    handles.global_trough_peak_index_record(num_rows+1, 24) = BNC6_value;
    handles.global_trough_peak_index_record(num_rows+1, 25) = BNC7_value;
    handles.global_trough_peak_index_record(num_rows+1, 26) = BNC8_value;    
        
    %assign the category value to zero - this allows manual editing or
    %automated editing later
    handles.global_trough_peak_index_record(num_rows+1, 27) = 0;

    handles.global_trough_peak_index_record(num_rows+1, 28) = baseline_troughlat;

%wrap up
Update_Peaks_Table(handles);
handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
Update_Plot(handles);
guidata(hObject, handles);




% --- Executes on button press in remove_row_button.
function remove_row_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_row_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.selected_row_index > 0 %if a row has been selected
    handles.current_trough_peak_index_record = get(handles.table_handle, 'Data');
    
    %extracted_row = handles.current_trough_peak_index_record(handles.current_trough_peak_index_record(:,5)==handles.selected_row_index)
    %display(extracted_row)

    if size(handles.current_trough_peak_index_record(handles.current_trough_peak_index_record(:,5)==handles.selected_row_index)) > 0
        question_text = strcat('Delete row with Index #', num2str(handles.selected_row_index), '?');
        %confirmation = questdlg(question_text, 'Peak Deletion', 'Yes', 'No', 'No');
        confirmation = 'Yes'; %switch this with commented line above to add dialog box
        if confirmation == 'Yes'
            handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==handles.selected_row_index, :) = [];
        end
    else
        h=msgbox('Error:Please select cell in table before clicking the Remove Row button.');
    end
else
    h = msgbox('Please select cell in table before clicking the Remove Row button.');
end

Update_Peaks_Table(handles);
handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
Update_Plot(handles);
guidata(hObject, handles);


% --- Executes on button press in exit_button.
function exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
question_text = strcat('Are you sure you want to quit? (Make sure you have saved your peak file if you changed it!)');
confirmation = questdlg(question_text, 'Quit Dialog', 'Yes', 'No', 'No');
if confirmation == 'Yes'
    fclose('all');
    clear all;
    clc;
    close;
end


% --- Executes on button press in remove_all_rows_button.
function remove_all_rows_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_all_rows_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.peakfile_loaded == 1 %if there are rows in existence (anywhere)
    handles.current_trough_peak_index_record = get(handles.table_handle, 'Data');
    
    question_text = 'Delete All Peaks for this Trace?';
    %confirmation = questdlg(question_text, 'All Peaks Deletion', 'Yes', 'No', 'No');
    confirmation = 'Yes'; %switch this with commented line above to add dialog box
    if confirmation == 'Yes'
        for i = 1:size(handles.current_trough_peak_index_record, 1); %for each row on the screen delete the global record with the corresponding index number
            handles.global_trough_peak_index_record(handles.global_trough_peak_index_record(:,5)==handles.current_trough_peak_index_record(i,5), :) = [];    
        end        
    end
else
    h = msgbox('Cannot delete: no peaks have been measured yet.');
end

Update_Peaks_Table(handles);
handles = guidata(handles.output); %this updates the overall handles object after changes by Update_Peaks_Table
Update_Plot(handles);
guidata(hObject, handles);



function threshold_height_box_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_height_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_height_box as text
%        str2double(get(hObject,'String')) returns contents of threshold_height_box as a double
handles.peak_threshold = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function threshold_height_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_height_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_num_peaks_box_Callback(hObject, eventdata, handles)
% hObject    handle to max_num_peaks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_num_peaks_box as text
%        str2double(get(hObject,'String')) returns contents of max_num_peaks_box as a double
handles.max_peak_number = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function max_num_peaks_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_num_peaks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.peakfile_loaded == 1
    savefile_name = strcat(handles.Base_Filename, '_peaks.xls');

    %Make local copies of all the data passed by handle so you can save it
    Peaks_Table = handles.global_trough_peak_index_record;

    header = {'Trough Time','Peak Time', 'Trial#', 'ROI#', 'Index', 'PeakNum', 'DF', 'DF_sHP', 'DF_sLP', 'DF/F', 'DF/F_sHP', 'DF/F_sLP', 'DF_vs_base', 'DF_sHP_vs_base', 'DF_sLP_vs_base', 'DF/F_vs_base', 'DF/F_sHP_vs_base', 'DF/F_sLP_vs_base', 'BNC1', 'BNC2', 'BNC3', 'BNC4', 'BNC5', 'BNC6', 'BNC7', 'BNC8', 'Category'};
    
    %get the desired filename and directory - feed the basefilename_peaks
    [writefile, pathname]=uiputfile('*_peaks.xls', 'Where do you want to save the peaks file?',char(savefile_name));
    cd(char(pathname));
    xlswrite(writefile, Peaks_Table);
    xlswrite(writefile, header, 'A1:AA1');
    fclose('all');
else
    msgbox('No Peaks File Loaded')
end


% --- Executes on button press in export_traces_button.
function export_traces_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_traces_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fig2_handle = figure();
copied_axes_handle = copyobj(handles.mainaxes_handle,handles.fig2_handle); % Copy axes object into fig2
set(copied_axes_handle, 'ActivePositionProperty', 'outerposition');
set(copied_axes_handle, 'Position', [10 3 95 28]);
set(copied_axes_handle, 'FontName', 'Arial');
set(get(gca,'XLabel'),'FontName','Arial');
set(get(gca,'YLabel'),'FontName','Arial');
grid off;

%set up sample filename
selected_data_type_button_handle = get(handles.data_type_radio_panel, 'SelectedObject');
data_type_button_selected = get(selected_data_type_button_handle, 'Tag');
switch data_type_button_selected
    case 'DF_radiobutton'   % IMPORTANT NOTE - this handles.current_trace_data is not available outside this function without a guidata call at the end of this function AND after the call to Update_Plot in the calling function
        ylabel_string = '_DF';
    case 'DF_sHP_radiobutton'
        ylabel_string = '_DF_sHP';
    case 'DF_sLP_radiobutton'
        ylabel_string = '_DF_sLP';
    case 'DFperF_radiobutton'
        ylabel_string = '_DFperF';
    case 'DFperF_sHP_radiobutton'
        ylabel_string = '_DFperF_sHP';
    case 'DFperF_sLP_radiobutton'
        ylabel_string = '_DFperF_sLP';
end
samplename = strcat(char(handles.Base_Filename), 'ROI',num2str(handles.current_ROI),'trial', num2str(handles.current_datafile), char(ylabel_string),'.eps');

[output_filename output_filepath] = uiputfile('*.eps', 'Where would you like to save?', char(samplename));
output_filename = strcat(output_filename, '.eps');
print(handles.fig2_handle, '-depsc',char(output_filename)); 
