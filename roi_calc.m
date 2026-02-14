% MATLAB Script for Analyzing Fluorescence Data

% Prompt user to select the Excel data file
[filename, filepath] = uigetfile('*.xlsx', 'Select the Excel Data File');
if isequal(filename, 0)
    error('No file selected. Exiting script.');
end
file = fullfile(filepath, filename);
data = readtable(file);

% Prepare the output table
output = zeros(3, 13);

% Loop through each odor (1, 2, 3)
for odor = 1:3
    % Filter data for the current odor
    odor_data = data(data.odor == odor, :);

    % Separate data into block 1 (pre-drug) and block 2 (post-drug)
    block1_data = odor_data(odor_data.block == 1, :);
    block2_data = odor_data(odor_data.block == 2, :);

    % Find ROI with the highest "max" value in block 1
    [~, max1_idx] = max(block1_data.max);
    roi1_num = block1_data.roi(max1_idx);
    roi1_pre = block1_data.max(max1_idx);
    roi1_post = block2_data.max(block2_data.roi == roi1_num);
    roi1_perc = ((roi1_post - roi1_pre) / roi1_pre) * 100;

    % Find ROI with the highest "max" value in block 2
    [~, max2_idx] = max(block2_data.max);
    roi2_num = block2_data.roi(max2_idx);
    roi2_post = block2_data.max(max2_idx);
    roi2_pre = block1_data.max(block1_data.roi == roi2_num);
    roi2_perc = ((roi2_post - roi2_pre) / roi2_pre) * 100;

    % Find ROI with the highest percentage increase
    perc_changes = ((block2_data.max - block1_data.max) ./ block1_data.max) * 100;
    [~, change_idx] = max(perc_changes);
    changeroi_num = block1_data.roi(change_idx);
    changeroi_pre = block1_data.max(change_idx);
    changeroi_post = block2_data.max(change_idx);
    changeroi_perc = perc_changes(change_idx);

    % Store results in the output table
    output(odor, :) = [odor, roi1_num, roi1_pre, roi1_post, roi1_perc, ...
                       roi2_num, roi2_pre, roi2_post, roi2_perc, ...
                       changeroi_num, changeroi_pre, changeroi_post, changeroi_perc];
end

% Convert the output array to a table for better readability
output_table = array2table(output, 'VariableNames', {
    'odor', '1roi_num', '1roi_pre', '1roi_post', '1roi_perc', ...
    '2roi_num', '2roi_pre', '2roi_post', '2roi_perc', ...
    'changeroi_num', 'changeroi_pre', 'changeroi_post', 'changeroi_perc'});

% Save the output table to a file
output_file = fullfile(filepath, 'roi.xlsx');
writetable(output_table, output_file);

% Change the current working directory to the file's folder
cd(filepath);

% Display the results
disp(output_table);
