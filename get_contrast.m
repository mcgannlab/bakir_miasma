function process_pre_post_trials_with_averaging()
%PROCESS_PRE_POST_TRIALS_WITH_AVERAGING Processes 4 pre and 4 post trials
%   Reads an Excel file with paths and processes pre and post trials.

    % Prompt user to select the Excel sheet
    [excel_filename, excel_path] = uigetfile('*.xlsx', 'Select Excel file with paths');
    if isequal(excel_filename, 0)
        disp('No Excel file selected. Exiting...');
        return;
    end
    
    % Read the Excel file without any range limitations
    file_data = readtable(fullfile(excel_path, excel_filename), 'PreserveVariableNames', true);
    
    % Debugging: Display the data and column names
    disp('Detected column names:');
    disp(file_data.Properties.VariableNames);
    disp(['Number of rows detected: ', num2str(height(file_data))]);
    
    num_rows = 8;

    % Initialize storage for pre and post trial averages
    pre_combined = [];
    post_combined = [];
    pre_output_file = '';
    post_output_file = '';

    % Loop through all rows dynamically
    for trial = 1:num_rows
        % Extract file paths and names dynamically for each trial
        procv1_path = resolve_column_value(file_data.procv1_path(trial));
        procv1_name = resolve_column_value(file_data.procv1_name(trial));
        det_path = resolve_column_value(file_data.det_path(trial));
        det_name = resolve_column_value(file_data.det_name(trial));
        output_path = resolve_column_value(file_data.output_path(trial));
        output_filename = resolve_column_value(file_data.output_filename(trial));
        
        % Assign output file names for pre and post trials
        if trial <= 4
            pre_output_file = fullfile(output_path, output_filename);
        else
            post_output_file = fullfile(output_path, output_filename);
        end
        
        % Construct full file paths
        procv1_filepath = fullfile(procv1_path, strcat(procv1_name, '_procv1.mat'));
        det_filepath = fullfile(det_path, strcat(det_name, '.det'));
        
        % Debugging output
        disp(['Processing trial: ', num2str(trial)]);
        disp(['Procv1 filepath: ', procv1_filepath]);
        disp(['Det filepath: ', det_filepath]);

        % Load the procv1 data
        if ~isfile(procv1_filepath)
            error(['Procv1 file not found: ', procv1_filepath]);
        end
        load(procv1_filepath, 'Data_3D_DFperF');
        if ~exist('Data_3D_DFperF', 'var')
            error(['Data_3D_DFperF variable not found in file: ', procv1_filepath]);
        end
        
        % Load and parse the .det file
        if ~isfile(det_filepath)
            error(['Det file not found: ', det_filepath]);
        end
        det_mask = parse_det_file(det_filepath);
        
        % Find the frame with the maximum value
        [max_val, max_idx] = max(Data_3D_DFperF(:));
        [max_row, max_col, max_frame] = ind2sub(size(Data_3D_DFperF), max_idx);
        
        % Extract the frame with the maximum value
        max_frame_data = Data_3D_DFperF(:, :, max_frame);
        
        % Apply the det_mask to isolate ROI
        roi_data = max_frame_data .* det_mask;
        [roi_rows, roi_cols] = find(det_mask);
        
        % Compute Euclidean distances to the max pixel
        distances = sqrt((roi_rows - max_row).^2 + (roi_cols - max_col).^2);
        pixel_values = roi_data(det_mask);
        
        % Bin distances starting from 0 (only max pixel) and incrementing by 1 pixel
        max_distance = ceil(max(distances));
        bins = 0:max_distance; % Bin edges
        avg_values = zeros(length(bins), 1);
        
        for i = 1:length(bins)
            if i == 1
                % Special case: Distance = 0 (exact max value)
                bin_indices = distances == 0;
            else
                % General case: Distances in the range (bins(i-1), bins(i)]
                bin_indices = distances > bins(i-1) & distances <= bins(i);
            end
            avg_values(i) = mean(pixel_values(bin_indices), 'omitnan'); % Average value in the bin
        end
        
        % Combine pre and post trials for averaging dynamically
        if trial <= 4
            % Pre trials
            if isempty(pre_combined)
                pre_combined = avg_values;
            else
                min_length = min(length(pre_combined), length(avg_values));
                pre_combined = pre_combined(1:min_length) + avg_values(1:min_length);
            end
        else
            % Post trials
            if isempty(post_combined)
                post_combined = avg_values;
            else
                min_length = min(length(post_combined), length(avg_values));
                post_combined = post_combined(1:min_length) + avg_values(1:min_length);
            end
        end
    end
    
    % Average pre and post trials
    pre_combined = pre_combined / 4;
    post_combined = post_combined / 4;
    
    % Save averaged results
    writematrix([(0:length(pre_combined)-1)', pre_combined], pre_output_file, 'Delimiter', ',');
    writematrix([(0:length(post_combined)-1)', post_combined], post_output_file, 'Delimiter', ',');
    
    disp(['Saved pre-averaged results to: ', pre_output_file]);
    disp(['Saved post-averaged results to: ', post_output_file]);
end

function value = resolve_column_value(column_entry)
%RESOLVE_COLUMN_VALUE Ensures compatibility for different column types
    if iscell(column_entry)
        value = column_entry{1}; % Extract the cell value
    elseif isstring(column_entry)
        value = char(column_entry); % Convert string to char
    elseif isnumeric(column_entry)
        value = num2str(column_entry); % Convert numeric to string
    else
        error('Unsupported column type for entry: %s', class(column_entry));
    end
end

function det_mask = parse_det_file(det_filepath)
%PARSE_DET_FILE Parses the .det file and creates a mask

    fid = fopen(det_filepath, 'r');
    det_mask = zeros(256, 256); % Assuming a 256x256 grid
    pixel_list = [];
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if isempty(line)
            continue;
        elseif strcmp(line, ',') % End of a detector
            for pixel = pixel_list
                row = floor((pixel - 1) / 256) + 1;
                col = mod((pixel - 1), 256) + 1;
                det_mask(row, col) = 1;
            end
            pixel_list = [];
        else
            pixel_list = [pixel_list; str2double(line)];
        end
    end
    fclose(fid);
    det_mask = logical(det_mask);
end
