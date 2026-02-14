function varargout = ROI_selection(varargin)
% ROI_SELECTION MATLAB code for ROI_selection.fig
%      ROI_SELECTION, by itself, creates a new ROI_SELECTION or raises the existing
%      singleton*.
%
%      H = ROI_SELECTION returns the handle to a new ROI_SELECTION or the handle to
%      the existing singleton*.
%
%      ROI_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_SELECTION.M with the given input arguments.
%
%      ROI_SELECTION('Property','Value',...) creates a new ROI_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_selection

% Last Modified by GUIDE v2.5 25-Aug-2015 21:47:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_selection_OutputFcn, ...
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


% --- Executes just before ROI_selection is made visible.
function ROI_selection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_selection (see VARARGIN)

% Choose default command line output for ROI_selection
handles.output = hObject;
handles.ROI_selector_handle = hObject;


%Add java based checkboxlist of ROIs on the side
% First create the data model
handles.ROI_jList = java.util.ArrayList;  % any java.util.List will be ok

% Next prepare a CheckBoxList component within a scroll-pane
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
 
% Now place this scroll-pane within a Matlab container (figure or panel)
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],hObject);
% Set callbaxk function for checkbox update events
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

%set flag that there's no data yet
handles.dataloaded = 0;

handles.avg_map_display = 0;
handles.current_maptype = 1; %set to display DF by default
handles.current_scaling_mode = 2; %set to automatic by default
handles.xlim =[];
handles.ylim=[];
handles.zoomFactor = 1;

handles.ROIs_loaded=0;
handles.ROI_centroid_xcoords = 1;
handles.ROI_centroid_ycoords = 1;
handles.current_ROI = 0;

%set up the handles to make sure we don't get the graphs confused
handles.map_axes_handle = findobj(hObject, 'Tag', 'map_axes');
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
handles.current_ROI_editbox_handle = findobj(hObject, 'Tag', 'current_ROI_editbox');
handles.previousmap_button_handle = findobj(hObject, 'Tag', 'previousmap_button');
handles.nextmap_button_handle = findobj(hObject, 'Tag', 'nextmap_button');
handles.avgmap_button_handle = findobj(hObject, 'Tag', 'avgmap_button');
handles.avg_value_text = findobj(hObject, 'Tag', 'avg_value_text');
handles.zoom_text_handle = findobj(hObject, 'Tag', 'zoom_text');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROI_selection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_selection_OutputFcn(hObject, eventdata, handles) 
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

if handles.dataloaded == 1;
    button = questdlg('Are you sure you want to clear all ROIs?','Confirm clear all','Yes','Cancel','Cancel');
    switch button
        case 'Yes'
            num_rows = size(handles.All_Maps, 1);
            num_columns = size(handles.All_Maps, 2);
            clear handles.ROI_masks handles.ROI_centroid_xcoords handles.ROI_centroid_ycoords
            handles.ROI_masks = false(num_rows, num_columns, 1); %reinitialize

            handles.ROIs_loaded = 0;
            set(handles.avg_value_text, 'String', 'None selected');


            %delete the old Checkbox List and components
            clear('handles.ROI_jList');
            clear('handles.ROI_jCBList');
            clear('handles.ROI_jScrollPane');
            clear('handles.ROI_jhScroll');
            clear('handles.ROI_hContainer');
            %make new checkbox list etc.
            handles.ROI_jList = java.util.ArrayList;  % any java.util.List will be ok
            handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
            handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
            [handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
            handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
            set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

        case 'Cancel'
    end
end

%prompt user to find a compiled trace file
[rdfile, pathname]=uigetfile({'*_maps.mat','_maps File (*_maps.mat)'}, 'Choose maps file');
cd(char(pathname));
load(rdfile);
handles.dataloaded = 1;
set(hObject, 'BackgroundColor', [0.94 0.94 0.94]); %turn load maps button gray

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

num_rows = size(All_Maps, 1);
num_columns = size(All_Maps, 2);
handles.ROI_masks=false(num_rows,num_columns,1); %initialize a 3-D array of 2-D masks
handles.xlim = [0.5 num_columns+.5];
handles.ylim = [0.5 num_rows+.5];

%take some measurements on the data and set up
handles.Num_Maps = size(All_Maps, 4);
handles.current_map = 1; %Reset to display the first map in the data

handles.current_min = min(min(handles.All_Maps(:,:,handles.current_maptype,handles.current_map)));
set(handles.min_editbox_handle, 'String', num2str(handles.current_min)); %update GUI
handles.current_max = max(max(handles.All_Maps(:,:,handles.current_maptype,handles.current_map)));
set(handles.max_editbox_handle, 'String', num2str(handles.current_max)); %update GUI

%now plot the first map
handles.map_axes_handle = imshow(handles.All_Maps(:,:,handles.current_maptype,handles.current_map), [handles.current_min handles.current_max]);
set(handles.map_axes_handle, 'Visible', 'on');

%UPDATE ALL LABELS AND AXES
current_map_label = strcat('Map #', num2str(handles.current_map), {' out of '}, num2str(handles.Num_Maps));
set(handles.map_number_label_text_handle, 'String', current_map_label);
set(handles.stimulus_text_handle, 'String', char(handles.Stimulus_List{handles.current_map}));
set(handles.fileloaded_text_handle, 'String', char(handles.Base_Filename_List{handles.current_map}));
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

        current_map = handles.All_Maps(:,:,handles.current_maptype,handles.current_map);
        %now plot the current map scaled properly
        %first convert matrix to grayscale image double from 0 to 1
        grayscale_image = mat2gray(current_map, [handles.current_min handles.current_max]);
        
        %then convert to RGB
        grayscale_uint8 = uint8(grayscale_image * 256);
        red_image = cast(cat(3, grayscale_uint8, zeros(size(grayscale_uint8)), zeros(size(grayscale_uint8))), class(grayscale_uint8));
        green_image = cast(cat(3, zeros(size(grayscale_uint8)), grayscale_uint8, zeros(size(grayscale_uint8))), class(grayscale_uint8));
        blue_image = cast(cat(3, zeros(size(grayscale_uint8)), zeros(size(grayscale_uint8)), grayscale_uint8), class(grayscale_uint8));
        
        %color in the ROIs
        % Get the state of the ROI checkboxes
        if handles.ROIs_loaded == 1
            ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
            for x=1:size(handles.ROI_masks, 3)
                if ROI_jCBModel.isIndexChecked(x-1) == 1 %if the ROI box is checked
                  mask_matrix = handles.ROI_masks(:,:,x);
                  red_image(mask_matrix)=100;
                  green_image(mask_matrix)=100;
                  blue_image(mask_matrix)=100;
                end
            end
        end
        
        %combine into one RGB image
        RGB_image = cat(3, red_image(:,:,1), green_image(:,:,2), blue_image(:,:,3));
        
        % plot the RGB version of the image and zoom and set pan accordingly
        handles.map_axes_handle = imshow(RGB_image);
        if handles.zoomFactor > 1
            xlim(handles.xlim); %set to the previous zoom level
            ylim(handles.ylim);
            set(handles.map_axes, 'ButtonDownFcn', 'disp(''This executes'')');
           set(handles.map_axes, 'Tag', 'DoNotIgnore');
           h = pan;
           set(h, 'Enable', 'on');
        end
%         try
%             zoom('out');
%             zoom(handles.zoomFactor);
%             if handles.zoomFactor > 1
%                 set(handles.map_axes, 'ButtonDownFcn', 'disp(''This executes'')');
%                 set(handles.map_axes, 'Tag', 'DoNotIgnore');
%                 h = pan;
%                 set(h, 'Enable', 'on');
%             end
%         catch
%         end
        
        %label the ROIs
        if handles.ROIs_loaded == 1
            ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
            if size(handles.ROI_masks, 3) == size(handles.ROI_centroid_xcoords, 2)
                for q = 1:size(handles.ROI_masks, 3)
                    if ROI_jCBModel.isIndexChecked(q-1) == 1 %if the ROI box is checked
                        text(handles.ROI_centroid_xcoords(q)-2, handles.ROI_centroid_ycoords(q), num2str(q), 'Color', [1 0 0], 'FontSize', 8);
                    end
                end
            end
        end
        
        %UPDATE ALL LABELS AND AXES
        current_map_label = strcat('Map #', num2str(handles.current_map), {' out of '}, num2str(handles.Num_Maps));
        set(handles.map_number_label_text_handle, 'String', current_map_label);
        set(handles.stimulus_text_handle, 'String', char(handles.Stimulus_List{handles.current_map}));
        if iscellstr(handles.Base_Filename_List{handles.current_map})
            set(handles.fileloaded_text_handle, 'String', '');
        else
            set(handles.fileloaded_text_handle, 'String', char(handles.Base_Filename_List{handles.current_map}));
        end
    else %if we are displaying average maps not individual maps
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
        current_map = current_avg_map;
        %first convert matrix to grayscale image double from 0 to 1
        grayscale_image = mat2gray(current_map, [handles.current_min handles.current_max]);
        
        %then convert to RGB
        grayscale_uint8 = uint8(grayscale_image * 256);
        red_image = cast(cat(3, grayscale_uint8, zeros(size(grayscale_uint8)), zeros(size(grayscale_uint8))), class(grayscale_uint8));
        green_image = cast(cat(3, zeros(size(grayscale_uint8)), grayscale_uint8, zeros(size(grayscale_uint8))), class(grayscale_uint8));
        blue_image = cast(cat(3, zeros(size(grayscale_uint8)), zeros(size(grayscale_uint8)), grayscale_uint8), class(grayscale_uint8));
        
        %color in the ROIs
        % Get the state of the ROI checkboxes
        if handles.ROIs_loaded == 1
            ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
            for x=1:size(handles.ROI_masks, 3)
                if ROI_jCBModel.isIndexChecked(x-1) == 1 %if the ROI box is checked
                  mask_matrix = handles.ROI_masks(:,:,x);
                  red_image(mask_matrix)=100;
                  green_image(mask_matrix)=100;
                  blue_image(mask_matrix)=100;
                end
            end
        end
        
        %combine into one RGB image
        RGB_image = cat(3, red_image(:,:,1), green_image(:,:,2), blue_image(:,:,3));
        
        % plot the RGB version of the image
        handles.map_axes_handle = imshow(RGB_image);       
        
        %label the ROIs
        if handles.ROIs_loaded == 1
            ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
            if size(handles.ROI_masks, 3) == size(handles.ROI_centroid_xcoords, 2)
                for q = 1:size(handles.ROI_masks, 3)
                    if ROI_jCBModel.isIndexChecked(q-1) == 1 %if the ROI box is checked
                        text(handles.ROI_centroid_xcoords(q)-2, handles.ROI_centroid_ycoords(q), num2str(q), 'Color', [1 0 0], 'FontSize', 8);
                    end
                end
            end
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
%grayscale_image = mat2gray(current_raw_image, [current_display_min current_display_max]);

full_image = getimage(handles.mapaxes_handle);

%quickie display what will be saved without saving - handy for debugging
%figure(); 
%imshow(grayscale_image);
suggested_name = strcat('Filename_', char(label), '_max',num2str(current_display_max),'_min',num2str(current_display_min),'.tif');
[rdfile, pathname]=uiputfile({'*.tif','Tagged Image File (*.tif)'}, 'Where would you like to save?', char(suggested_name));
cd(char(pathname));
imwrite(full_image,rdfile);


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


% --- Executes on button press in new_ROI_freehand_button.
function new_ROI_freehand_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_ROI_freehand_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_imfreehand = imfreehand('Closed', 'true');
new_ROI_mask=createMask(new_imfreehand);
current_map_values = handles.Avg_Maps(:,:,handles.current_maptype);
average = mean(current_map_values(new_ROI_mask));
set(handles.avg_value_text, 'String', num2str(average));
pixel_coords = getPosition(new_imfreehand);
coords = round(mean(pixel_coords));
if handles.ROIs_loaded == 0
    ROI_index = 1;
    handles.ROIs_loaded = 1;
else
    ROI_index = size(handles.ROI_masks, 3)+1;
end
handles.ROI_masks(:,:,ROI_index)=new_ROI_mask;
handles.ROI_centroid_xcoords(ROI_index) = coords(1);
handles.ROI_centroid_ycoords(ROI_index) = coords(2);

%create a new entry in the ROI Checkbox List
newlabel = strcat('ROI',num2str(ROI_index));
handles.ROI_jList.add(ROI_index-1, newlabel);
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jCBModel.checkIndex(ROI_index-1);
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);


% --- Executes on button press in clear_ROI_button.
function clear_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_ROIs = size(handles.ROI_masks, 3);
handles.ROI_masks(:,:,num_ROIs)=[]; %delete last map
handles.ROI_centroid_xcoords(num_ROIs)=[]; %delete last map centroid
handles.ROI_centroid_ycoords(num_ROIs)=[]; %delete last map centroid
if num_ROIs == 1
    handles.ROIs_loaded =0; %if this was the only ROI
end

%delete the entry in the ROI Checkbox List
handles.ROI_jList.remove(num_ROIs-1);
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);


% --- Executes on button press in export_det_button.
function export_det_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_det_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_masks = size(handles.ROI_masks, 3);
[output_filename output_path] = uiputfile('*.det', 'Save detector file as text', 'ROIs.det');
cd(char(output_path));
for x=1:num_masks %for each mask
    current_mask = handles.ROI_masks(:,:,x);
    non_zero_indices = find(current_mask'); %returns non-zero linear indices - need to transpose the array first for compatibility with NP
    if x==1
        dlmwrite(char(output_filename), non_zero_indices, 'delimiter', '\r', 'newline', 'pc'); %write to file for each ROI (slow but easy)
        dlmwrite(char(output_filename), ',', 'delimiter', '\r', 'newline', 'pc', '-append'); %add comma to separate masks  
    else
        dlmwrite(char(output_filename), non_zero_indices, 'delimiter', '\r', 'newline', 'pc', '-append'); %append after first ROI
        dlmwrite(char(output_filename), ',', 'delimiter', '\r', 'newline', 'pc', '-append'); %add comma to separate masks  
    end        
end


% --- Executes on button press in clear_all_ROIs_button.
function clear_all_ROIs_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_all_ROIs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button = questdlg('Are you sure you want to clear all ROIs?','Confirm clear all','Yes','Cancel','Cancel');
switch button
    case 'Yes'
        num_rows = size(handles.All_Maps, 1);
        num_columns = size(handles.All_Maps, 2);
        clear handles.ROI_masks handles.ROI_centroid_xcoords handles.ROI_centroid_ycoords
        handles.ROI_masks = false(num_rows, num_columns, 1); %reinitialize
        
        handles.ROIs_loaded = 0;
        set(handles.avg_value_text, 'String', 'None selected');
        

        %delete the old Checkbox List and components
        clear('handles.ROI_jList');
        clear('handles.ROI_jCBList');
        clear('handles.ROI_jScrollPane');
        clear('handles.ROI_jhScroll');
        clear('handles.ROI_hContainer');
        %make new checkbox list etc.
        handles.ROI_jList = java.util.ArrayList;  % any java.util.List will be ok
        handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
        handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
        [handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
        handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
        set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

    case 'Cancel'
end
Update_Map(handles);
guidata(hObject, handles);


% --- Executes on button press in export_ROI_button.
function export_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[output_filename output_path] = uiputfile('*_ROIs.mat', 'Save _ROIs file as matlab logical mask', '_ROIs.mat');
strcat(output_filename, '_ROIs.mat');
ROI_masks = handles.ROI_masks;
ROI_centroid_xcoords = handles.ROI_centroid_xcoords;
ROI_centroid_ycoords = handles.ROI_centroid_ycoords;
cd(char(output_path));
save(output_filename, 'ROI_masks', 'ROI_centroid_xcoords', 'ROI_centroid_ycoords');


% --- Executes on button press in new_ROI_drawbox_button.
function new_ROI_drawbox_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_ROI_drawbox_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_imrect = imrect;
new_ROI_mask=createMask(new_imrect);
current_map_values = handles.Avg_Maps(:,:,handles.current_maptype);
average = mean(current_map_values(new_ROI_mask));
set(handles.avg_value_text, 'String', num2str(average));
pixel_coords = getPosition(new_imrect);
xcoord = round(pixel_coords(1)+ pixel_coords(3)/2); %xmin plus half width
ycoord = round(pixel_coords(2)+ pixel_coords(4)/2); %ymin plus half height
if handles.ROIs_loaded == 0
    ROI_index = 1;
    handles.ROIs_loaded = 1;
else
    ROI_index = size(handles.ROI_masks, 3)+1;
end
handles.ROI_masks(:,:,ROI_index)=new_ROI_mask;
handles.ROI_centroid_xcoords(ROI_index) = xcoord;
handles.ROI_centroid_ycoords(ROI_index) = ycoord;
%create a new entry in the ROI Checkbox List
newlabel = strcat('ROI',num2str(ROI_index));
handles.ROI_jList.add(ROI_index-1, newlabel);
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jCBModel.checkIndex(ROI_index-1);
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);

% --- Executes on button press in newROI_draw_ellipse_button.
function newROI_draw_ellipse_button_Callback(hObject, eventdata, handles)
% hObject    handle to newROI_draw_ellipse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_imellipse = imellipse;
new_ROI_mask=createMask(new_imellipse);
current_map_values = handles.Avg_Maps(:,:,handles.current_maptype);
average = mean(current_map_values(new_ROI_mask));
set(handles.avg_value_text, 'String', num2str(average));
pixel_coords = getPosition(new_imellipse);
xcoord = round(pixel_coords(1)+ pixel_coords(3)/2); %xmin plus half width
ycoord = round(pixel_coords(2)+ pixel_coords(4)/2); %ymin plus half height
if handles.ROIs_loaded == 0
    ROI_index = 1;
    handles.ROIs_loaded = 1;
else
    ROI_index = size(handles.ROI_masks, 3)+1;
end
handles.ROI_masks(:,:,ROI_index)=new_ROI_mask;
handles.ROI_centroid_xcoords(ROI_index) = xcoord;
handles.ROI_centroid_ycoords(ROI_index) = ycoord;
%create a new entry in the ROI Checkbox List
newlabel = strcat('ROI',num2str(ROI_index));
handles.ROI_jList.add(ROI_index-1, newlabel);
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jCBModel.checkIndex(ROI_index-1);
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);

% --- Executes on button press in load_ROI_file_button.
function load_ROI_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_ROI_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button = questdlg('Are you sure you want to clear all ROIs?','Confirm clear all','Yes','Cancel','Cancel');
switch button
    case 'Yes'
        [rdfile, input_path] = uigetfile('*_ROIs.mat', 'Load _ROIs file as matlab logical mask', '_ROIs.mat');
        cd(char(input_path));
        load(rdfile, 'ROI_masks');
        handles.ROI_masks = ROI_masks;
        load(rdfile, 'ROI_centroid_xcoords');
        handles.ROI_centroid_xcoords=ROI_centroid_xcoords;
        load(rdfile, 'ROI_centroid_ycoords');       
        handles.ROI_centroid_ycoords=ROI_centroid_ycoords;
        handles.ROIs_loaded = 1;
    case 'Cancel'
        return
end

%delete the old Checkbox List and components
clear('handles.ROI_jList');
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jList = java.util.ArrayList;  % any java.util.List will be ok
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);


Num_ROIs = size(handles.ROI_masks, 3);
%create a new entry in the ROI Checkbox List
for x=1:Num_ROIs
    newlabel = strcat('ROI',num2str(x));
    handles.ROI_jList.add(x-1, newlabel);
end

%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);


% --- Executes on button press in load_det_file_button.
function load_det_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_det_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.dataloaded ==1
    button = questdlg('Are you sure you want to clear all ROIs?','Confirm clear all','Yes','Cancel','Cancel');
    switch button
        case 'Yes'
            %first clear the existing masks
            num_rows = size(handles.All_Maps, 1);
            num_columns = size(handles.All_Maps, 2);
            clear handles.ROI_masks
            clear handles.ROI_centroid_xcoords
            clear handles.ROI_centroid_ycoords
            handles.ROI_masks = false(num_rows, num_columns, 1); %reinitialize
            handles.ROIs_loaded = 0;
            %then import the text file
            [rdfile input_path] = uigetfile('*.det', 'Load NP-compatible .det file', '*.det');
            cd(char(input_path));
            input_values=dlmread(char(rdfile));
            %find the zeros that correspond to commas - breaks between ROIs
            zero_indices = find(input_values==0);
            num_ROIs = size(zero_indices, 1);

            for x=1:num_ROIs
                if x==1 %on first ROI
                    %extract pixel numbers between zeros and build logical mask
                    ROI_pixel_numbers=input_values(1:zero_indices(1)-1);
                    handles.ROIs_loaded = 1;
                else
                    ROI_pixel_numbers=input_values((zero_indices(x-1)+1):zero_indices(x)-1);
                end               
                mask = false(num_rows, num_columns); %create a blank mask
                mask(ROI_pixel_numbers)=1; %swap in true where indicated
                mask=mask'; %transpose to convert from NP to matlab logic
                %assign mask to global structure
                handles.ROI_masks(:,:,x)=mask;
                positive_indices = find(mask); %get non-zero values
                dimensions = [num_rows,num_columns]; %assumes 256x256 camera - the only source of .det files
                [xcoords, ycoords] = ind2sub(dimensions, positive_indices); %swap from linear to 2D coords
                handles.ROI_centroid_xcoords(x) = round(mean(ycoords)); %backwards to switch from NP coords to matlab
                handles.ROI_centroid_ycoords(x) = round(mean(xcoords));                
            end
        case 'Cancel'
            display('Load cancelled by user.');
            return;
    end
else
    display('Maps must be loaded first');
    return;
end


%delete the old Checkbox List and components
clear('handles.ROI_jList');
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jList = java.util.ArrayList;  % any java.util.List will be ok
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);


Num_ROIs = size(handles.ROI_masks, 3);
%create a new entry in the ROI Checkbox List
for x=1:Num_ROIs
    newlabel = strcat('ROI',num2str(x));
    handles.ROI_jList.add(x-1, newlabel);
end

%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);


%executes when checkbox values are changed (specified in opening fcn)
function Checkbox_ValueChanged_CallbackFcn(hObject, callbackdata)
% hObject    handle to load_det_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%display(callbackdata)
%handles = guihandles(gcf);
%Update_Map(handles);
%display('ran callback')
%guidata(hObject, handles);


% --- Executes on button press in delete_numbered_ROI_button.
function delete_numbered_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_numbered_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg('What number ROI would you like to delete?', 'ROI deletion');
target_ROI = str2num(answer{1});

num_ROIs = size(handles.ROI_masks, 3);
if target_ROI > num_ROIs
    errordlg('No such ROI');
    return
end
handles.ROI_masks(:,:,target_ROI)=[]; %delete last map
handles.ROI_centroid_xcoords(target_ROI)=[]; %delete last map centroid
handles.ROI_centroid_ycoords(target_ROI)=[]; %delete last map centroid
if num_ROIs == 1
    handles.ROIs_loaded =0; %if this was the only ROI
end

%delete the entry in the ROI Checkbox List
handles.ROI_jList.remove(num_ROIs-1); %don't remove this specific ROI#, just the last one, since we will renumber
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);


% --- Executes on button press in refresh_button.
function refresh_button_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_Map(handles);
guidata(hObject, handles);


% --- Executes on button press in checkall_button.
function checkall_button_Callback(hObject, eventdata, handles)
% hObject    handle to checkall_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.checkAll;
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);

% --- Executes on button press in uncheckall_button.
function uncheckall_button_Callback(hObject, eventdata, handles)
% hObject    handle to uncheckall_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%delete the old Checkbox List and components
clear('handles.ROI_jCBList');
clear('handles.ROI_jScrollPane');
clear('handles.ROI_jhScroll');
clear('handles.ROI_hContainer');
%make new checkbox list etc.
handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
handles.ROI_jCBModel.uncheckAll;
handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
[handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

Update_Map(handles);
guidata(hObject, handles);



function current_ROI_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to current_ROI_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try %if there are no numbers give error popup
    value = str2num(get(hObject, 'String'));
catch
    msgbox('Invalid Entry in Current ROI Box - must be an integer.');
    set(hObject, 'String', '0');
    handles.current_ROI = 0;
    return
end
try %if there are no masks right now, reset to zero
    Num_ROIs = size(handles.ROI_masks,3);
catch
    set(hObject, 'String', '0');
    handles.current_ROI = 0;
    return
end
if value == 999
    handles.current_ROI = value;
%    msgbox('999 entered: All ROIs will move together!');
    guidata(hObject, handles);
    return
end
if value < 0 || value > Num_ROIs
    msgbox('Invalid Entry in Current ROI Box - ROI does not exist');
    set(hObject, 'String', '0');
    handles.current_ROI = 0;
    return
else
    handles.current_ROI = value;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function current_ROI_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_ROI_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in up_button.
function up_button_Callback(hObject, eventdata, handles)
% hObject    handle to up_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI > 0
    if handles.current_ROI ~= 999
        handles = move_ROI_up(handles.current_ROI, hObject, handles);
    else
        [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
        for x=1:Num_ROIs
            handles.current_ROI=x
            handles = move_ROI_up(handles.current_ROI, hObject, handles);
        end
        handles.current_ROI=999; %set it back to the original value from the edit box
    end
else
   msgbox('No Current ROI Selected');
end
Update_Map(handles);
guidata(hObject, handles);

function handles = move_ROI_up(current_ROI, hObject, handles)
    %this moves the selected ROI upward in the frame by 1 pixel
     [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
     selected_mask = handles.ROI_masks(:,:,current_ROI);
     positive_indices = find(selected_mask); %get non-zero values
     dimensions = [Num_Rows,Num_Columns];
     [xcoords, ycoords] = ind2sub(dimensions, positive_indices); %swap from linear to 2D coords
     xcoords = xcoords-1; %move all points by 1 pixel - direction is backwards because of NP to matlab difference
     if max(xcoords) > Num_Rows || min(xcoords) < 1
         msgbox('Cannot move off the edge of the map');
         return
     end
       if max(ycoords) > Num_Columns || min(ycoords) < 1
           msgbox('Cannot move off the edge of the map');
           return
       end
    revised_indices = sub2ind([Num_Rows Num_Columns], xcoords, ycoords);
    new_mask = false([Num_Rows Num_Columns]);
    new_mask(revised_indices)=1;
    handles.ROI_masks(:,:,current_ROI)=new_mask;
    handles.ROI_centroid_xcoords(current_ROI) = round(mean(ycoords)); %backwards to switch from NP coords to matlab
    handles.ROI_centroid_ycoords(current_ROI) = round(mean(xcoords));     
    guidata(hObject, handles);
    

% --- Executes on button press in movedown_button.
function movedown_button_Callback(hObject, eventdata, handles)
% hObject    handle to movedown_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI > 0
    if handles.current_ROI ~= 999
        handles = move_ROI_down(handles.current_ROI, hObject, handles);
    else
        [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
        for x=1:Num_ROIs
            handles.current_ROI=x;
            handles = move_ROI_down(handles.current_ROI, hObject, handles);
        end
        handles.current_ROI=999; %set it back to the value from the edit box
    end
else
   msgbox('No Current ROI Selected');
end
Update_Map(handles);
guidata(hObject, handles);


function handles = move_ROI_down(current_ROI, hObject, handles)
    %this moves the selected ROI down in the frame by 1 pixel
     [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
     selected_mask = handles.ROI_masks(:,:,current_ROI);
     positive_indices = find(selected_mask); %get non-zero values
     dimensions = [Num_Rows,Num_Columns];
     [xcoords, ycoords] = ind2sub(dimensions, positive_indices); %swap from linear to 2D coords
     xcoords = xcoords+1; %move all points by 1 pixel - direction is backwards because of NP to matlab difference
     if max(xcoords) > Num_Rows || min(xcoords) < 1
         msgbox('Cannot move off the edge of the map');
         return
     end
       if max(ycoords) > Num_Columns || min(ycoords) < 1
           msgbox('Cannot move off the edge of the map');
           return
       end
    revised_indices = sub2ind([Num_Rows Num_Columns], xcoords, ycoords);
    new_mask = false([Num_Rows Num_Columns]);
    new_mask(revised_indices)=1;
    handles.ROI_masks(:,:,current_ROI)=new_mask;
    handles.ROI_centroid_xcoords(current_ROI) = round(mean(ycoords)); %backwards to switch from NP coords to matlab
    handles.ROI_centroid_ycoords(current_ROI) = round(mean(xcoords));     
    guidata(hObject, handles);


% --- Executes on button press in move_left_button.
function move_left_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI > 0
    if handles.current_ROI ~= 999
        handles = move_ROI_left(handles.current_ROI, hObject, handles);
    else
        [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
        for x=1:Num_ROIs
            handles.current_ROI=x;
            handles = move_ROI_left(handles.current_ROI, hObject, handles);
        end
        handles.current_ROI=999; %set it back to the value from the edit box
    end
else
   msgbox('No Current ROI Selected');
end
Update_Map(handles);
guidata(hObject, handles);


function handles = move_ROI_left(current_ROI, hObject, handles)
    %this moves the selected ROI left in the frame by 1 pixel
     [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
     selected_mask = handles.ROI_masks(:,:,current_ROI);
     positive_indices = find(selected_mask); %get non-zero values
     dimensions = [Num_Rows,Num_Columns];
     [xcoords, ycoords] = ind2sub(dimensions, positive_indices); %swap from linear to 2D coords
     ycoords = ycoords-1; %move all points by 1 pixel - direction is backwards because of NP to matlab difference
     if max(xcoords) > Num_Rows || min(xcoords) < 1
         msgbox('Cannot move off the edge of the map');
         return
     end
       if max(ycoords) > Num_Columns || min(ycoords) < 1
           msgbox('Cannot move off the edge of the map');
           return
       end
    revised_indices = sub2ind([Num_Rows Num_Columns], xcoords, ycoords);
    new_mask = false([Num_Rows Num_Columns]);
    new_mask(revised_indices)=1;
    handles.ROI_masks(:,:,current_ROI)=new_mask;
    handles.ROI_centroid_xcoords(current_ROI) = round(mean(ycoords)); %backwards to switch from NP coords to matlab
    handles.ROI_centroid_ycoords(current_ROI) = round(mean(xcoords));     
    guidata(hObject, handles);


% --- Executes on button press in move_right_button.
function move_right_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_right_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI > 0
    if handles.current_ROI ~= 999
        handles = move_ROI_right(handles.current_ROI, hObject, handles);
    else
        [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
        for x=1:Num_ROIs
            handles.current_ROI=x;
            handles = move_ROI_right(handles.current_ROI, hObject, handles);
        end
        handles.current_ROI=999; %set it back to the value from the edit box
    end
else
   msgbox('No Current ROI Selected');
end
Update_Map(handles);
guidata(hObject, handles);


function handles = move_ROI_right(current_ROI, hObject, handles)
    %this moves the selected ROI right in the frame by 1 pixel
     [Num_Rows, Num_Columns, Num_ROIs] = size(handles.ROI_masks);
     selected_mask = handles.ROI_masks(:,:,current_ROI);
     positive_indices = find(selected_mask); %get non-zero values
     dimensions = [Num_Rows,Num_Columns];
     [xcoords, ycoords] = ind2sub(dimensions, positive_indices); %swap from linear to 2D coords
     ycoords = ycoords+1; %move all points by 1 pixel - direction is backwards because of NP to matlab difference
     if max(xcoords) > Num_Rows || min(xcoords) < 1
         msgbox('Cannot move off the edge of the map');
         return
     end
       if max(ycoords) > Num_Columns || min(ycoords) < 1
           msgbox('Cannot move off the edge of the map');
           return
       end
    revised_indices = sub2ind([Num_Rows Num_Columns], xcoords, ycoords);
    new_mask = false([Num_Rows Num_Columns]);
    new_mask(revised_indices)=1;
    handles.ROI_masks(:,:,current_ROI)=new_mask;
    handles.ROI_centroid_xcoords(current_ROI) = round(mean(ycoords)); %backwards to switch from NP coords to matlab
    handles.ROI_centroid_ycoords(current_ROI) = round(mean(xcoords));     
    guidata(hObject, handles);


% --- Executes on button press in delete_current_ROI_button.
function delete_current_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_current_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_ROI > 0
    handles.ROI_masks(:,:,handles.current_ROI) =[];
    handles.ROI_centroid_xcoords(handles.current_ROI)=[];
    handles.ROI_centroid_ycoords(handles.current_ROI)=[];
    
    num_ROIs = size(handles.ROI_masks, 3);
    if num_ROIs == 0
        handles.ROIs_loaded =0; %if this was the only ROI
    end

    %delete the entry in the ROI Checkbox List
    handles.ROI_jList.clear();
    %delete the old Checkbox List and components
    clear('handles.ROI_jCBList');
    clear('handles.ROI_jScrollPane');
    clear('handles.ROI_jhScroll');
    clear('handles.ROI_hContainer');
    
    if num_ROIs > 0    %recreate all entries in the ROI Checkbox List
        for x=1:num_ROIs
            newlabel = strcat('ROI',num2str(x));
            handles.ROI_jList.add(x-1, newlabel);
        end
    end
    
    %make new checkbox list etc.
    handles.ROI_jCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.ROI_jList);
    handles.ROI_jCBModel = handles.ROI_jCBList.getCheckModel;
    handles.ROI_jCBModel.checkAll;
    handles.ROI_jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.ROI_jCBList);
    [handles.ROI_jhScroll,handles.ROI_hContainer] = javacomponent(handles.ROI_jScrollPane,[1530,158,120,845],handles.ROI_selector_handle);
    handles.ROI_jCBModel_handle = handle(handles.ROI_jCBModel, 'CallbackProperties');
    set(handles.ROI_jCBModel_handle, 'ValueChangedCallback', @Checkbox_ValueChanged_CallbackFcn);

    if handles.current_ROI > num_ROIs %if deleting an ROI moved the current ROI out of range, reset it to zero
        set(handles.current_ROI_editbox, 'String', '0');
    end
       
else
   msgbox('No Current ROI Selected');
end
Update_Map(handles);
guidata(hObject, handles);


% --- Executes on slider movement.
function Zoom_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% 	scrollbarValue = get(hObject,'Value');
% 	caption = sprintf('H value = %.2f', scrollbarValue);
% 	set(handles.txtZoom, 'string', caption);
handles.zoomFactor = get(hObject,'Value');
axes(handles.map_axes);
zoom('out');
zoom(handles.zoomFactor);
mag_factor_text = sprintf('Zoom Factor = %.2f (%d %%)', handles.zoomFactor, round(handles.zoomFactor * 100));
set(handles.zoom_text_handle, 'String', mag_factor_text);

%get new scaling info
newXLim = get(handles.map_axes,'XLim');
newYLim = get(handles.map_axes,'YLim');
handles.xlim = newXLim;
handles.ylim = newYLim;

% Set up to allow panning of the image by clicking and dragging.
% Cursor will show up as a little hand when it is over the image.
if handles.zoomFactor > 1
    set(handles.map_axes, 'ButtonDownFcn', 'disp(''This executes'')');
    set(handles.map_axes, 'Tag', 'DoNotIgnore');
    h = pan;
    set(h, 'ButtonDownFilter', @myPanCallbackFunction);
    set(h,'ActionPostCallback',@mypostcallback);
    set(h, 'Enable', 'on');
else
    h = pan;
    set(h, 'Enable', 'off');
end
guidata(hObject, handles);
	return; % from Zoom_Slider_Callback
    

function mypostcallback(obj,evd)  
%this function runs when the image is panned
%it gets the new X and Y range and updates it
handles = guihandles(obj);
newXLim = get(evd.Axes,'XLim');
%msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newXLim));
newYLim = get(evd.Axes,'YLim');
handles=guidata(handles.figure1);
handles.xlim = newXLim;
handles.ylim = newYLim;
%Update_Map(handles);
guidata(obj, handles);



function [flag] = myPanCallbackFunction(obj, eventdata)
% Sets up panning by clicking and dragging via the hand cursor.
% If the tag of the object is 'DoNotIgnore', then return true.
% Indicate what the target is
%disp(['In myPanCallbackFunction, you clicked on a ' get(obj,'Type') 'object.'])
objTag = get(obj, 'Tag');
if strcmpi(objTag, 'DoNotIgnore')
flag = true;
else
flag = false;
end
return;





% --- Executes during object creation, after setting all properties.
function Zoom_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zoom_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
