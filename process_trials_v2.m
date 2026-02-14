function process_trials2()
    % Open a dialog to select the input Excel file
    [file, path] = uigetfile('*.xlsx', 'Select the Input Excel File');
    if isequal(file, 0)
        disp('No file selected. Exiting.');
        return;
    end
    input_file = fullfile(path, file);

    % Read input Excel file
    input_data = readtable(input_file);

    % Initialize progress bar
    f = waitbar(0, 'Processing trials...');
    total_trials = height(input_data);

    % Check and retrieve the general output folder
    if ismember('Path_to_Output_Folder', input_data.Properties.VariableNames)
        output_folder = input_data.Path_to_Output_Folder{1};
        if ~isfolder(output_folder)
            mkdir(output_folder);
        end
    else
        error('The input Excel file must include a column named "Path_to_Output_Folder".');
    end

    % Initialize data storage for conditions
    condition_data = struct('M', [], 'B', [], 'H', []);
    condition_avg = struct('M', struct('pre', [], 'post', []), 'B', struct('pre', [], 'post', []), 'H', struct('pre', [], 'post', []));

    % Iterate through each row in the input file
    for i = 1:height(input_data)
        % Update progress bar
        waitbar(i / total_trials, f, sprintf('Processing trial %d of %d...', i, total_trials));

        % Extract information for the current trial
        input_path = fullfile(input_data.Path_to_Input_File{i}, [num2str(input_data.Trial(i)), '_traces.mat']);
        condition = input_data.Condition{i};
        trial_num = input_data.Trial(i);
        drug_state = input_data.Pre_Post(i); % 1 for pre-drug, 2 for post-drug

        % Check if the file exists
        if ~isfile(input_path)
            warning('File not found: %s. Skipping.', input_path);
            continue;
        end

        % Load the .mat file
        data = load(input_path);

        % Extract DFperF_ROI_Waveforms
        if isfield(data, 'DFperF_ROI_Waveforms')
            waveforms = data.DFperF_ROI_Waveforms;
        else
            warning('DFperF_ROI_Waveforms not found in %s. Skipping.', input_path);
            continue;
        end

        % Get the number of ROIs
        num_rois = size(waveforms, 1);

        % Initialize output data
        trial_data = [];

        % Process each ROI
        for roi = 1:num_rois
            trace = waveforms(roi, :);

            % Calculate required metrics, stopping offset at zero crossing
            max_value = max(trace(200:800));
            max_time = find(trace(200:800) == max_value, 1, 'first') + 199; % Frame at which the maximum peak was reached
            time1 = max(trace(225:325));
            time2 = max(trace(326:425));
            time3 = max(trace(426:525));
            time4 = max(trace(526:625));
            time5 = max(trace(626:725));

            % Offset calculation (stop at zero crossing)
            offset_signal = trace(576:end);
            offset_signal(offset_signal < 0) = 0; % Remove negatives
            zero_crossing_idx = find(offset_signal == 0, 1);
            if ~isempty(zero_crossing_idx)
                offset_signal = offset_signal(1:zero_crossing_idx - 1);
            end
            offvol = sum(offset_signal);
            offarea = trapz(offset_signal);

            % Append data for this ROI
            trial_data = [trial_data; trial_num, roi, max_value, max_time, time1, time2, time3, time4, time5, offvol, offarea];
        end

        % Separate pre and post-drug data by condition and ROI
        if drug_state == 1
            condition_avg.(condition).pre = [condition_avg.(condition).pre; trial_data];
        else
            condition_avg.(condition).post = [condition_avg.(condition).post; trial_data];
        end

        % Append trial data to condition-specific data
        condition_data.(condition) = [condition_data.(condition); trial_data];
    end

    % Write data for each condition to separate files
    column_names = {'trial', 'roi', 'max', 'maxtime', 'time1', 'time2', 'time3', 'time4', 'time5', 'offvol', 'offarea'};
    conditions = fieldnames(condition_data);

    for c = 1:numel(conditions)
        condition = conditions{c};
        all_data = condition_data.(condition);
        if ~isempty(all_data)
            output_table = array2table(all_data, 'VariableNames', column_names);
            output_path = fullfile(output_folder, [condition, '.xlsx']);
            writetable(output_table, output_path);
        end
    end

    % Write the peaks file
    peak_path = fullfile(output_folder, 'peaks.xlsx');
    for c = 1:numel(conditions)
        condition = conditions{c};
        pre_data = condition_avg.(condition).pre;
        post_data = condition_avg.(condition).post;

        % Initialize peaks data
        peaks_data = [];

        % Process each ROI
        unique_rois = unique(pre_data(:, 2));
        for roi = unique_rois'
            % Extract data for this ROI
            pre_roi_data = pre_data(pre_data(:, 2) == roi, 3:end);
            post_roi_data = post_data(post_data(:, 2) == roi, 3:end);

            % Compute averages
            avg_pre = mean(pre_roi_data, 1, 'omitnan'); % Average across trials for pre-drug
            avg_post = mean(post_roi_data, 1, 'omitnan'); % Average across trials for post-drug

            % Append to peaks data
            peaks_data = [peaks_data; 1, roi, avg_pre; 2, roi, avg_post]; % 1 = pre-drug, 2 = post-drug
        end

        % Define column names for peaks file
        peaks_column_names = {'block', 'roi', 'max', 'maxtime', 'time1', 'time2', 'time3', 'time4', 'time5', 'offvol', 'offarea'};

        % Sort peaks data by trial and then by ROI
        peaks_data = sortrows(peaks_data, [1, 2]);

        % Create peaks table
        peaks_table = array2table(peaks_data, 'VariableNames', peaks_column_names);

        % Write peaks data to the appropriate sheet
        writetable(peaks_table, peak_path, 'Sheet', condition);
    end

    % Write the percentages file based on peaks file
    percentages_path = fullfile(output_folder, 'percentages.xlsx');
    conditions = {'M', 'B', 'H'};

    for c = 1:numel(conditions)
        condition = conditions{c};
        peak_table = readtable(peak_path, 'Sheet', condition);
        pre_data = peak_table(peak_table.block == 1, :);
        post_data = peak_table(peak_table.block == 2, :);

        % Initialize percentages data
        percentages_data = [];

        for roi = unique(pre_data.roi)'
            pre_row = pre_data(pre_data.roi == roi, :);
            post_row = post_data(post_data.roi == roi, :);

            if isempty(pre_row) || isempty(post_row)
                warning('Skipping ROI %d in condition %s due to missing data.', roi, condition);
                continue;
            end

            % Calculate percentage changes for all metrics except maxtime
            percent_changes = ((post_row{1, 3:end} - pre_row{1, 3:end}) ./ pre_row{1, 3:end}) * 100;

            % Calculate maxtime difference
            maxtime_diff = post_row{1, 'maxtime'} - pre_row{1, 'maxtime'};

            % Combine changes and maxtime_diff
            percent_changes(:, 2) = maxtime_diff; % Replace maxtime column

            percentages_data = [percentages_data; roi, percent_changes];
        end

        % Define column names
        percentages_column_names = {'roi', 'max_change', 'maxtime_diff', 'time1_change', 'time2_change', 'time3_change', 'time4_change', 'time5_change', 'offvol_change', 'offarea_change'};

        % Create percentages table
        percentages_table = array2table(percentages_data, 'VariableNames', percentages_column_names);

        % Write percentages table
        writetable(percentages_table, percentages_path, 'Sheet', condition);
    end

    % Existing code above remains unchanged

    % Combine sheets from peaks.xlsx into peaks_comp.xlsx
    peaks_comp_path = fullfile(output_folder, 'peaks_comp.xlsx');
    peaks_data_combined = [];

    for c = 1:numel(conditions)
        condition = conditions{c};
        sheet_data = readtable(peak_path, 'Sheet', condition);
        sheet_data = addvars(sheet_data, repmat(c, height(sheet_data), 1), 'NewVariableNames', 'odor', 'Before', 1); % Add the "odor" column as the first column
        peaks_data_combined = [peaks_data_combined; sheet_data];
    end

    % Write the combined peaks data
    writetable(peaks_data_combined, peaks_comp_path, 'Sheet', 'Combined');

    % Combine sheets from percentages.xlsx into percentages_comp.xlsx
    percentages_comp_path = fullfile(output_folder, 'percentages_comp.xlsx');
    percentages_data_combined = [];

    for c = 1:numel(conditions)
        condition = conditions{c};
        sheet_data = readtable(percentages_path, 'Sheet', condition);
        sheet_data = addvars(sheet_data, repmat(c, height(sheet_data), 1), 'NewVariableNames', 'odor', 'Before', 1); % Add the "odor" column as the first column
        percentages_data_combined = [percentages_data_combined; sheet_data];
    end

    % Write the combined percentages data
    writetable(percentages_data_combined, percentages_comp_path, 'Sheet', 'Combined');

    % Close the progress bar
    close(f);
end
