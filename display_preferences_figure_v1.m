function [] = display_preferences_figure_v1(hObject, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
handles.prefs_figure = figure('Name','Preferences','NumberTitle','off', 'Position', [400 100 500 600]);

% make preferences display for preprocessing
preprocessing_label = uicontrol('Style', 'text', 'Position', [1 550 200 30], 'String', 'Preprocessing Settings');
handles.Preferences.preprocessing.medianfilter_checkbox=uicontrol('Style','Checkbox', 'Position',[70 530 200 25], 'String',"Median Spatial Filter", 'Value', handles.Preferences.preprocessing.medianfilter_setting, ...
   'TooltipString', 'Reduce shot noise with 3x3 median filter');
handles.Preferences.preprocessing.temporalfilter_checkbox=uicontrol('Style','Checkbox', 'Position',[70 505 200 25], 'String',"Temporal Filter", 'Value', handles.Preferences.preprocessing.temporalfilter_setting, ...
   'TooltipString', 'Apply Gaussian temporal filter');
handles.Preferences.preprocessing.crop_firstframe_edit=uicontrol('Style','Edit', 'Position',[100 455 90 25], 'String',"First Frame #", 'String', num2str(handles.Preferences.preprocessing.crop_firstframe_setting), ...
   'TooltipString', 'Enter first frame to be included', 'Enable', 'off', 'Callback',{@firstframe_callback,hObject,handles});
handles.Preferences.preprocessing.crop_lastframe_edit=uicontrol('Style','Edit', 'Position',[100 430 90 25], 'String',"Last Frame #", 'String', num2str(handles.Preferences.preprocessing.crop_lastframe_setting), ...
   'TooltipString', 'Enter last frame to be included', 'Enable', 'off', 'Callback', {@lastframe_callback,hObject,handles});
handles.Preferences.preprocessing.cropframes_checkbox=uicontrol('Style','Checkbox', 'Position',[70 480 200 25], 'String',"Use Subset of Frames", 'Value', handles.Preferences.preprocessing.cropframes_setting, ...
   'TooltipString', 'Crop data to use only specified frame range', 'Callback',{@cropframes_callback,hObject,handles});
handles.Preferences.preprocessing.save_map_PDF_checkbox=uicontrol('Style','Checkbox', 'Position',[70 405 200 25], 'String',"Save Maps as PDF", 'Value', handles.Preferences.preprocessing.save_map_PDF_setting, ...
   'TooltipString', 'Save PDF file with maximum projection maps');

if handles.Preferences.preprocessing.cropframes_setting == 1
    set(handles.Preferences.preprocessing.crop_firstframe_edit, 'Enable', 'on');
    set(handles.Preferences.preprocessing.crop_lastframe_edit, 'Enable', 'on');
end


save_button=uicontrol('Style','pushbutton', 'Position',[270 100 40 40], 'String',"Save", ...
   'TooltipString', 'Save preferences', 'Callback', {@savebutton_callback,hObject,handles});
% save_button=uicontrol('Style','pushbutton', 'Position',[270 200 40 40], 'String',"Test", ...
%    'TooltipString', 'Save preferences', 'Callback', @testbutton);

guidata(hObject,handles);
end

function [] = savebutton_callback(src, event,hObject,handles)
handles.Preferences.preprocessing.medianfilter_setting = get(handles.Preferences.preprocessing.medianfilter_checkbox, 'Value');
handles.Preferences.preprocessing.temporalfilter_setting = get(handles.Preferences.preprocessing.temporalfilter_checkbox, 'Value');
handles.Preferences.preprocessing.cropframes_setting = get(handles.Preferences.preprocessing.cropframes_checkbox, 'Value');
handles.Preferences.preprocessing.crop_firstframe_setting = str2num(get(handles.Preferences.preprocessing.crop_firstframe_edit, 'String'));
handles.Preferences.preprocessing.crop_lastframe_setting = str2num(get(handles.Preferences.preprocessing.crop_lastframe_edit, 'String'));
handles.Preferences.preprocessing.save_map_PDF_setting = get(handles.Preferences.preprocessing.save_map_PDF_checkbox,'Value');
guidata(hObject,handles);
close(handles.prefs_figure);
end

function [] = cropframes_callback(src, event,hObject,handles)
handles.Preferences.preprocessing.cropframes_setting = get(src, 'Value');
if handles.Preferences.preprocessing.cropframes_setting == 1
    set(handles.Preferences.preprocessing.crop_firstframe_edit, 'Enable', 'on');
    set(handles.Preferences.preprocessing.crop_lastframe_edit, 'Enable', 'on');
else
    set(handles.Preferences.preprocessing.crop_firstframe_edit, 'Enable', 'off');
    set(handles.Preferences.preprocessing.crop_lastframe_edit, 'Enable', 'off');    
end
guidata(hObject,handles.Preferences);

end

function [] = firstframe_callback(src, event,hObject,handles)
handles.Preferences.preprocessing.crop_firstframe_setting = str2num(get(src, 'String'));
guidata(hObject,handles.Preferences);
end

function [] = lastframe_callback(src, event,hObject,handles)
handles.Preferences.preprocessing.crop_lastframe_setting = str2num(get(src, 'String'));
guidata(hObject,handles.Preferences);
end


% function [] = testbutton()
% disp('yes');
% end