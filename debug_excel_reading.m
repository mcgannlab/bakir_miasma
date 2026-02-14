function debug_excel_reading()
%DEBUG_EXCEL_READING Reads an Excel file and identifies row-reading issues

    % Prompt user to select the Excel file
    [excel_filename, excel_path] = uigetfile('*.xlsx', 'Select Excel file with paths');
    if isequal(excel_filename, 0)
        disp('No Excel file selected. Exiting...');
        return;
    end
    
    file_path = fullfile(excel_path, excel_filename);
    disp(['Selected Excel file: ', file_path]);

    % Attempt to read the Excel file without specifying a range
    try
        disp('Attempting to read Excel file without range...');
        file_data = readtable(file_path, 'PreserveVariableNames', true);
        disp('Contents of the Excel file (without range):');
        disp(file_data);
        disp(['Number of rows detected: ', num2str(height(file_data))]);
    catch ME
        disp('Error reading Excel file without range:');
        disp(ME.message);
    end

    % Attempt to read the Excel file with explicit range
    try
        disp('Attempting to read Excel file with explicit range...');
        % Adjust range based on data location
        file_data = readtable(file_path, 'Sheet', 1, 'Range', 'A1:F9', 'PreserveVariableNames', true);
        disp('Contents of the Excel file (with explicit range):');
        disp(file_data);
        disp(['Number of rows detected with explicit range: ', num2str(height(file_data))]);
    catch ME
        disp('Error reading Excel file with explicit range:');
        disp(ME.message);
    end
end
