function varargout = Map_Browser(varargin)
% MAP_BROWSER MATLAB code for Map_Browser.fig
%      MAP_BROWSER, by itself, creates a new MAP_BROWSER or raises the existing
%      singleton*.
%
%      H = MAP_BROWSER returns the handle to a new MAP_BROWSER or the handle to
%      the existing singleton*.
%
%      MAP_BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAP_BROWSER.M with the given input arguments.
%
%      MAP_BROWSER('Property','Value',...) creates a new MAP_BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Map_Browser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Map_Browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Map_Browser

% Last Modified by GUIDE v2.5 21-Feb-2017 15:10:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Map_Browser_OpeningFcn, ...
                   'gui_OutputFcn',  @Map_Browser_OutputFcn, ...
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

alper = create_alper();  % Generate the colormap

% --- Executes just before Map_Browser is made visible.
function Map_Browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Map_Browser (see VARARGIN)

% Choose default command line output for Map_Browser
handles.output = hObject;

%set flag that there's no data yet
handles.dataloaded = 0;

handles.avg_map_display = 0;
handles.current_maptype = 1; %set to display DF by default
handles.current_scaling_mode = 2; %set to automatic by default

%load color map info
handles.current_colormap = 1;
handles.clut2b_colormap = load_clut2b_colormap(); %load custom colormap - Wachowiak standard

%set up the handles to make sure we don't get the graphs confused
handles.mapaxes_handle = findobj(hObject, 'Tag', 'map_axes');
handles.fileloaded_text_handle = findobj(hObject, 'Tag', 'fileloaded_text');
handles.stimulus_text_handle = findobj(hObject, 'Tag', 'stimulus_text');
handles.maps_file_text_handle = findobj(hObject, 'Tag', 'maps_file_text');
handles.map_type_panel_handle = findobj(hObject, 'Tag', 'map_type_panel');
handles.map_number_label_text_handle = findobj(hObject, 'Tag', 'map_number_label_text');
handles.scaling_mode_panel_handle = findobj(hObject, 'Tag', 'scaling_mode_panel');
handles.manual_radiobutton_handle = findobj(hObject, 'Tag', 'manual_radiobutton');
handles.automatic_radiobutton_handle = findobj(hObject, 'Tag', 'automatic_radiobutton');
handles.min_editbox_handle = findobj(hObject, 'Tag', 'min_editbox');
handles.max_editbox_handle = findobj(hObject, 'Tag', 'max_editbox');
handles.previousmap_button_handle = findobj(hObject, 'Tag', 'previousmap_button');
handles.nextmap_button_handle = findobj(hObject, 'Tag', 'nextmap_button');
handles.avgmap_button_handle = findobj(hObject, 'Tag', 'avgmap_button');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Map_Browser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Map_Browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in nextmap_button.
function nextmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to nextmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_map < handles.Num_Maps
    handles.current_map = handles.current_map+1;
    Update_Map(handles);
end
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in previousmap_button.
function previousmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to previousmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_map > 1
    handles.current_map = handles.current_map-1;
    Update_Map(handles);
end
guidata(hObject, handles); %update data in the handles structure


% --- Executes on button press in loadmaps_button.
function loadmaps_button_Callback(hObject, eventdata, handles)
% hObject    handle to loadmaps_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%prompt user to find a compiled trace file
[rdfile, pathname]=uigetfile({'*_maps.mat','_maps File (*_maps.mat)'; '*_procv1.mat', '_procv1 File'}, 'Choose maps file or procv file');
maps_or_procv_filetype = strcmp(rdfile(end-8:end),'_maps.mat'); %returns 1 for maps files, 0 otherwise
cd(char(pathname));
if maps_or_procv_filetype == 1
    load(rdfile);
else
    load(rdfile, 'max_projection', 'Base_Filename', 'Sampling_Rate', 'Stimulus', 'Notes', 'RLI_Frame');
end
handles.dataloaded = 1;
set(hObject, 'BackgroundColor', [0.94 0.94 0.94]); %turn load maps button gray

if maps_or_procv_filetype == 1
    %assemble variables into handles structure so other functions can access it
    handles.All_Maps = All_Maps;
    handles.Base_Filename_List = Base_Filename_List;
    handles.Sampling_Rate_List = Sampling_Rate_List;
    handles.Stimulus_List = Stimulus_List;
    handles.Notes_List = Notes_List;
    handles.Avg_DF_Map = Avg_DF_Map;
    handles.Avg_DF_sHP_Map = Avg_DF_sHP_Map;
    handles.Avg_DF_sLP_Map = Avg_DF_sLP_Map;
    handles.Avg_DFperF_Map = Avg_DFperF_Map;
    handles.Avg_DFperF_sHP_Map = Avg_DFperF_sHP_Map;
    handles.Avg_DFperF_sLP_Map = Avg_DFperF_sLP_Map;
    handles.Avg_RLI_Map = Avg_RLI_Map;
    handles.Avg_Maps = Avg_Maps;
else
    %manually set up max projection from procv file as a single map
    handles.All_Maps(:,:,1,1) = max_projection.DF;
    handles.All_Maps(:,:,2,1) = max_projection.DF_sHP;
    handles.All_Maps(:,:,3,1) = max_projection.DF_sLP;
    handles.All_Maps(:,:,4,1) = max_projection.DFperF;
    handles.All_Maps(:,:,5,1) = max_projection.DFperF_sHP;
    handles.All_Maps(:,:,6,1) = max_projection.DFperF_sLP;
    handles.All_Maps(:,:,7,1) = RLI_Frame;
    All_Maps = handles.All_Maps;
    
    handles.Base_Filename_List = {Base_Filename};
    handles.Sampling_Rate_List = Sampling_Rate;
    handles.Stimulus_List = Stimulus;
    handles.Notes_List = Notes;

    %by definition the projections are their own avg
    handles.Avg_DF_Map = max_projection.DF;
    handles.Avg_DF_sHP_Map = max_projection.DF_sHP;
    handles.Avg_DF_sLP_Map = max_projection.DF_sLP;
    handles.Avg_DFperF_Map = max_projection.DFperF;
    handles.Avg_DFperF_sHP_Map = max_projection.DFperF_sHP;
    handles.Avg_DFperF_sLP_Map = max_projection.DFperF_sLP;
    handles.Avg_RLI_Map = RLI_Frame;
    handles.Avg_Maps = handles.All_Maps;
end

%take some measurements on the data and set up
handles.Num_Maps = size(All_Maps, 4);
handles.current_map = 1; %Reset to display the first map in the data

handles.current_min = min(min(handles.All_Maps(:,:,handles.current_maptype,handles.current_map)));
set(handles.min_editbox_handle, 'String', num2str(handles.current_min)); %update GUI
handles.current_max = max(max(handles.All_Maps(:,:,handles.current_maptype,handles.current_map)));
set(handles.max_editbox_handle, 'String', num2str(handles.current_max)); %update GUI

%now plot the first map
handles.map_axes_handle = imshow(handles.All_Maps(:,:,handles.current_maptype,handles.current_map), [handles.current_min handles.current_max]);
switch handles.current_colormap
    case 1
        colormap(gca, gray);
    case 2
        colormap(gca, jet);
    case 3
        colormap(gca, alper);
    case 4
        colormap(gca, handles.clut2b_colormap);
    case 5
        colormap(gca, parula);
end
set(handles.map_axes_handle, 'Visible', 'on');

%UPDATE ALL LABELS AND AXES
current_map_label = strcat('Map #', num2str(handles.current_map), {' out of '}, num2str(handles.Num_Maps));
set(handles.map_number_label_text_handle, 'String', current_map_label);
set(handles.stimulus_text_handle, 'String', char(handles.Stimulus_List{handles.current_map}));
%set(handles.fileloaded_text_handle, 'String', char(handles.Base_Filename_List{handles.current_map}));
set(handles.fileloaded_text_handle, 'String', char(rdfile));
set(handles.maps_file_text_handle, 'String', char(rdfile));

Update_Map(handles);
guidata(hObject, handles); %store this data in the handles structure

%called by other functions
function Update_Map(handles)
if handles.dataloaded == 0
    return %if no data has been loaded, don't try to update the plots
else
    if handles.avg_map_display == 0 %if not showing the global max files
        if handles.current_scaling_mode == 2
            %update max and min from current map
            handles.current_min = min(min(handles.All_Maps(:,:,handles.current_maptype,handles.current_map)));
            set(handles.min_editbox_handle, 'String', num2str(handles.current_min)); %update GUI
            handles.current_max = max(max(handles.All_Maps(:,:,handles.current_maptype,handles.current_map)));
            set(handles.max_editbox_handle, 'String', num2str(handles.current_max)); %update GUI
        else
            handles.current_min = str2num(get(handles.min_editbox_handle, 'String'));
            handles.current_max = str2num(get(handles.max_editbox_handle, 'String'));
        end

        %now plot the current map scaled properly
        handles.map_axes_handle = imshow(handles.All_Maps(:,:,handles.current_maptype,handles.current_map), [handles.current_min handles.current_max]);  
        switch handles.current_colormap
            case 1
                colormap(gca, gray);
            case 2
                colormap(gca, jet);
            case 3
                colormap(gca, alper);
            case 4
                colormap(gca, handles.clut2b_colormap);
            case 5
                colormap(gca, parula);
        end

        %UPDATE ALL LABELS AND AXES
        current_map_label = strcat('Map #', num2str(handles.current_map), {' out of '}, num2str(handles.Num_Maps));
        set(handles.map_number_label_text_handle, 'String', current_map_label);
        set(handles.stimulus_text_handle, 'String', char(handles.Stimulus_List{handles.current_map}));
        if iscellstr(handles.Base_Filename_List{handles.current_map})
            set(handles.fileloaded_text_handle, 'String', 'Avg of multiple files');
        else
             if ischar(handles.Base_Filename_List{handles.current_map}) %if this is an original filename
                 text = char(handles.Base_Filename_List{handles.current_map});
            else
                text = 'Avg of multiple files';
             end
             set(handles.fileloaded_text_handle, 'String', text);
        end
    else
        switch handles.current_maptype
            case 1
                current_avg_map = handles.Avg_Maps(:,:,1);
            case 2
                current_avg_map = handles.Avg_Maps(:,:,2);
            case 3
                current_avg_map = handles.Avg_Maps(:,:,3);
            case 4
                current_avg_map = handles.Avg_Maps(:,:,4);
            case 5 
                current_avg_map = handles.Avg_Maps(:,:,5);
            case 6
                current_avg_map = handles.Avg_Maps(:,:,6);
            case 7
                current_avg_map = handles.Avg_Maps(:,:,7);
        end
                
        if handles.current_scaling_mode == 2
            %update max and min from current map
            handles.current_min = min(min(current_avg_map));
            set(handles.min_editbox_handle, 'String', num2str(handles.current_min)); %update GUI
            handles.current_max = max(max(current_avg_map));
            set(handles.max_editbox_handle, 'String', num2str(handles.current_max)); %update GUI
        else
            handles.current_min = str2num(get(handles.min_editbox_handle, 'String'));
            handles.current_max = str2num(get(handles.max_editbox_handle, 'String'));
        end      
        
        %now plot the appropriate avg map scaled properly
        handles.map_axes_handle = imshow(current_avg_map, [handles.current_min handles.current_max]); 
        switch handles.current_colormap
            case 1
                colormap(gca, gray);
            case 2
                colormap(gca, jet);
            case 3
                colormap(gca, alper);
            case 4
                colormap(gca,handles.clut2b_colormap);
            case 5
                colormap(gca, parula);
        end
        
        %UPDATE ALL LABELS AND AXES
        current_map_label = strcat('Average of ALL Maps');
        set(handles.map_number_label_text_handle, 'String', current_map_label);
        set(handles.stimulus_text_handle, 'String', '');
        set(handles.fileloaded_text_handle, 'String', '');

    end
    
    drawnow;
end


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the current map data
if handles.avg_map_display == 0 %if not showing the global max files
    current_raw_image = handles.All_Maps(:,:,handles.current_maptype, handles.current_map);
    switch handles.current_maptype
        case 1
            label='DF';
        case 2
            label='DF_sHP';
        case 3
            label='DF_sLP';
        case 4
            label='DFperF';
        case 5 
            label='DFperF_sHP';
        case 6
            label='DFperF_sLP';
        case 7
            label='RLI';
    end
else
    switch handles.current_maptype
        case 1
            current_raw_image = handles.Avg_DF_Map;
            label='DF';
        case 2
            current_raw_image = handles.Avg_DF_sHP_Map;
            label='DF_sHP';
        case 3
            current_raw_image = handles.Avg_DF_sLP_Map;
            label='DF_sLP';
        case 4
            current_raw_image = handles.Avg_DFperF_Map;
            label='DFperF';
        case 5 
            current_raw_image = handles.Avg_DFperF_sHP_Map;
            label='DFperF_sHP';
        case 6
            current_raw_image = handles.Avg_DFperF_sLP_Map;
            label='DFperF_sLP';
        case 7
            current_raw_image = handles.Avg_RLI_Map;
            label='RLI';
    end
end

%get the display max and min currently used by the user
current_display_min = str2num(get(handles.min_editbox_handle, 'String'));
current_display_max = str2num(get(handles.max_editbox_handle, 'String'));

%convert matrix to grayscale image double from 0 to 1 with current scaling
grayscale_image = mat2gray(current_raw_image, [current_display_min current_display_max]);
indexed_image = gray2ind(grayscale_image, 256);

%quickie display what will be saved without saving - handy for debugging
%figure(); 
%imshow(grayscale_image);

switch handles.current_colormap
    case 1
        cmap=gray();
        map='gray';
    case 2
        cmap=jet();
        map = 'jet';
    case 3
        cmap=alper();
        map = 'alper';
    case 4
        cmap = handles.clut2b_colormap;
        map = 'wach';
    case 5
        cmap=parula();
        map = 'parula';
end

suggested_name = strcat('FILENAME_', char(label), map, '_max',num2str(current_display_max),'_min',num2str(current_display_min),'.tif');
[rdfile, pathname]=uiputfile({'*.tif','Tagged Image File (*.tif)'}, 'Where would you like to save?', char(suggested_name));
cd(char(pathname));
imwrite(indexed_image,cmap, rdfile);





% --- Executes when selected object is changed in map_type_panel.
function map_type_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in map_type_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
    %first figure out which data we're supposed to be graphing and load it
    selected_data_type_button_handle = get(handles.map_type_panel_handle, 'SelectedObject');
    map_type_button_selected = get(selected_data_type_button_handle, 'Tag');
    switch map_type_button_selected
        case 'DF_radiobutton'   
            handles.current_maptype = 1;
        case 'DF_sHP_radiobutton'
            handles.current_maptype = 2;
        case 'DF_sLP_radiobutton'
            handles.current_maptype = 3;
        case 'DFperF_radiobutton'
            handles.current_maptype = 4;
        case 'DFperF_sHP_radiobutton'
            handles.current_maptype = 5;
        case 'DFperF_sLP_radiobutton'
            handles.current_maptype = 6;
        case 'RLI_radiobutton'
            handles.current_maptype = 7;
    end
Update_Map(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes when selected object is changed in scaling_mode_panel.
function scaling_mode_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in scaling_mode_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
selected_scaling_mode_handle = get(handles.scaling_mode_panel_handle, 'SelectedObject');
scaling_mode_button_selected = get(selected_scaling_mode_handle, 'Tag');
switch scaling_mode_button_selected
    case 'manual_radiobutton'   
        handles.current_scaling_mode = 1;
    case 'automatic_radiobutton'
        handles.current_scaling_mode = 2;
end
Update_Map(handles);
guidata(hObject, handles); %update data in the handles structure


function max_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to max_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_editbox as text
%        str2double(get(hObject,'String')) returns contents of max_editbox as a double
set(handles.scaling_mode_panel_handle, 'SelectedObject', handles.manual_radiobutton_handle);
handles.current_scaling_mode = 1; %set scaling mode to manual
Update_Map(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes during object creation, after setting all properties.
function max_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to min_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_editbox as text
%        str2double(get(hObject,'String')) returns contents of min_editbox as a double
set(handles.scaling_mode_panel_handle, 'SelectedObject', handles.manual_radiobutton_handle);
handles.current_scaling_mode = 1; %set scaling mode to manual
Update_Map(handles);
guidata(hObject, handles); %update data in the handles structure


% --- Executes during object creation, after setting all properties.
function min_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in avgmap_button.
function avgmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to avgmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgmap_button
avg_map_display = get(hObject, 'Value');
handles.avg_map_display = avg_map_display;
if avg_map_display == 1
    set(handles.previousmap_button_handle, 'Enable', 'off');
    set(handles.nextmap_button_handle, 'Enable', 'off');
    set(hObject, 'BackgroundColor', [1 .6 1]);
end
if avg_map_display == 0
    set(handles.previousmap_button_handle, 'Enable', 'on');
    set(handles.nextmap_button_handle, 'Enable', 'on');
    set(hObject, 'BackgroundColor', [0.94,0.94,0.94]);
end

Update_Map(handles);
guidata(hObject, handles);


% --- Executes on selection change in colormap_popupmenu.
function colormap_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to colormap_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colormap_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colormap_popupmenu
handles.current_colormap = get(hObject, 'Value');
Update_Map(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function colormap_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colormap_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'grayscale'; 'jet'; 'alper'; 'Wachowiak'; 'parula'});
