function varargout = MIASMA_main_interface(varargin)
% MIASMA_MAIN_INTERFACE MATLAB code for MIASMA_main_interface.fig
%      MIASMA_MAIN_INTERFACE, by itself, creates a new MIASMA_MAIN_INTERFACE or raises the existing
%      singleton*.
%
%      H = MIASMA_MAIN_INTERFACE returns the handle to a new MIASMA_MAIN_INTERFACE or the handle to
%      the existing singleton*.
%
%      MIASMA_MAIN_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIASMA_MAIN_INTERFACE.M with the given input arguments.
%
%      MIASMA_MAIN_INTERFACE('Property','Value',...) creates a new MIASMA_MAIN_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MIASMA_main_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MIASMA_main_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MIASMA_main_interface

% Last Modified by GUIDE v2.5 23-Jul-2018 17:22:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MIASMA_main_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @MIASMA_main_interface_OutputFcn, ...
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


% --- Executes just before MIASMA_main_interface is made visible.
function MIASMA_main_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MIASMA_main_interface (see VARARGIN)

% Choose default command line output for MIASMA_main_interface
handles.output = hObject;

%Set up preferences
handles.Preferences.preprocessing.medianfilter_setting = 1;
handles.Preferences.preprocessing.temporalfilter_setting = 1;
handles.Preferences.preprocessing.cropframes_setting = 0;
handles.Preferences.preprocessing.crop_firstframe_setting = 1;
handles.Preferences.preprocessing.crop_lastframe_setting = 100;
handles.Preferences.preprocessing.save_map_PDF_setting = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MIASMA_main_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MIASMA_main_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in trace_browser_button.
function trace_browser_button_Callback(hObject, eventdata, handles)
% hObject    handle to trace_browser_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trace_browser();


% --- Executes on button press in maps_browser_button.
function maps_browser_button_Callback(hObject, eventdata, handles)
% hObject    handle to maps_browser_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Map_Browser();

% --- Executes on button press in peaks_categorizer_button.
function peaks_categorizer_button_Callback(hObject, eventdata, handles)
% hObject    handle to peaks_categorizer_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
peak_categorization_function();

% --- Executes on button press in show_NP_as_movie_button.
function show_NP_as_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_NP_as_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
np_quickview_v2();

% --- Executes on button press in show_procv_file_as_movie_button.
function show_procv_file_as_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_procv_file_as_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
play_all_movies_from_proc_file();

% --- Executes on button press in superimpose_ROIs_button.
function superimpose_ROIs_button_Callback(hObject, eventdata, handles)
% hObject    handle to superimpose_ROIs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_ROIs_on_movies();

% --- Executes on button press in make_heat_maps_button.
function make_heat_maps_button_Callback(hObject, eventdata, handles)
% hObject    handle to make_heat_maps_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
analyze_frame_from_single_traces_file();

% --- Executes on button press in analyze_one_traces_file_button.
function analyze_one_traces_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_one_traces_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
make_picture_from_single_traces_file();

% --- Executes on button press in avg_traces_button.
function avg_traces_button_Callback(hObject, eventdata, handles)
% hObject    handle to avg_traces_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_averaged_trace_v1();


% --- Executes on button press in motion_correct_onefile_button.
function motion_correct_onefile_button_Callback(hObject, eventdata, handles)
% hObject    handle to motion_correct_onefile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
motion_correct_raw_Neuroplex_file_v1();


% --- Executes on button press in motion_correct_batch_button.
function motion_correct_batch_button_Callback(hObject, eventdata, handles)
% hObject    handle to motion_correct_batch_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_motion_correction_v3();

% --- Executes on button press in preprocess_onefile_button.
function preprocess_onefile_button_Callback(hObject, eventdata, handles)
% hObject    handle to preprocess_onefile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NP_filter_preprocessing_v2(handles.Preferences);

% --- Executes on button press in preprocess_batch_button.
function preprocess_batch_button_Callback(hObject, eventdata, handles)
% hObject    handle to preprocess_batch_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_NP_filter_preprocessing_v3(handles.Preferences);


% --- Executes on button press in extract_traces_onefile_button.
function extract_traces_onefile_button_Callback(hObject, eventdata, handles)
% hObject    handle to extract_traces_onefile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
extract_ROI_traces_from_procv1_v2();

% --- Executes on button press in extract_traces_batch_button.
function extract_traces_batch_button_Callback(hObject, eventdata, handles)
% hObject    handle to extract_traces_batch_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_trace_extracter_v4();

% --- Executes on button press in compile_traces_button.
function compile_traces_button_Callback(hObject, eventdata, handles)
% hObject    handle to compile_traces_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trace_file_combiner_v3();


% --- Executes on button press in maps_extracter_button.
function maps_extracter_button_Callback(hObject, eventdata, handles)
% hObject    handle to maps_extracter_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_map_extracter_v2();


% --- Executes on button press in show_heatmaps_as_movie_button.
function show_heatmaps_as_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_heatmaps_as_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
show_compiled_traces_file_as_movie();


% --- Executes on button press in normalize_traces_button.
function normalize_traces_button_Callback(hObject, eventdata, handles)
% hObject    handle to normalize_traces_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
normalize_all_traces();


% --- Executes on button press in average_traces_button.
function average_traces_button_Callback(hObject, eventdata, handles)
% hObject    handle to average_traces_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
average_all_traces_v1();


% --- Executes on button press in batch_subtraction_button.
function batch_subtraction_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_subtraction_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filetype_string = inputdlg('Enter 1 for Neuroplex files or 2 for TurboSM files.');
filetype = str2num(filetype_string{1});
switch filetype
    case 1
        batch_subtraction_function_Neuroplex(); 
    case 2
        batch_subtraction_function_TurboSM();
    otherwise
        display('Invalid choice: enter 1 or 2');
end


% --- Executes on button press in maps_combiner_button.
function maps_combiner_button_Callback(hObject, eventdata, handles)
% hObject    handle to maps_combiner_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map_file_combiner();


% --- Executes on button press in automated_map_output.
function automated_map_output_Callback(hObject, eventdata, handles)
% hObject    handle to automated_map_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_all_maps_as_PDF();


% --- Executes on button press in pool_comp_traces_into_one_traces_file_button.
function pool_comp_traces_into_one_traces_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to pool_comp_traces_into_one_traces_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
combine_comptraces_into_one_matrix_by_glom();


% --- Executes on button press in do_PCA_button.
function do_PCA_button_Callback(hObject, eventdata, handles)
% hObject    handle to do_PCA_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
make_PCA_file_from_comptraces_file();


% --- Executes on button press in PCA_plot_button.
function PCA_plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to PCA_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
generate_3D_PCAorICA_trajectory_plot();


% --- Executes on button press in ROI_selection_button.
function ROI_selection_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_selection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_selection();


% --- Executes on button press in movie_maker_optical.
function movie_maker_optical_Callback(hObject, eventdata, handles)
% hObject    handle to movie_maker_optical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
show_one_movie_from_procv_v2();

% --- Executes on button press in movie_maker_optical_BNC_button.
function movie_maker_optical_BNC_button_Callback(hObject, eventdata, handles)
% hObject    handle to movie_maker_optical_BNC_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
show_one_movie_from_procv_with_BNC_v3();


% --- Executes on button press in pearson_button.
function pearson_button_Callback(hObject, eventdata, handles)
% hObject    handle to pearson_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
measure_within_trial_correlations_v1();


% --- Executes on button press in map_subtraction_button.
function map_subtraction_button_Callback(hObject, eventdata, handles)
% hObject    handle to map_subtraction_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_map_arithmetic();


% --- Executes on button press in pixelwise_correlation_button.
function pixelwise_correlation_button_Callback(hObject, eventdata, handles)
% hObject    handle to pixelwise_correlation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map_correlation_v1();


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_scanbox_preprocessing_v1(handles.Preferences);


% --- Executes on button press in sbx_quickview_button.
function sbx_quickview_button_Callback(hObject, eventdata, handles)
% hObject    handle to sbx_quickview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sbx_quickview_v3();


% --- Executes on button press in add_pupil_data_button.
function add_pupil_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_pupil_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_add_pupil_data();


% --- Executes on button press in heat_browser_button.
function heat_browser_button_Callback(hObject, eventdata, handles)
% hObject    handle to heat_browser_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Heat_Browser();


% --- Executes on button press in measure_traces_button.
function measure_traces_button_Callback(hObject, eventdata, handles)
% hObject    handle to measure_traces_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
make_timedefined_measurements_v1();


% --- Executes on button press in prefs_button.
function prefs_button_Callback(hObject, eventdata, handles)
% hObject    handle to prefs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_preferences_figure_v1(hObject, handles);
guidata(hObject, handles);
