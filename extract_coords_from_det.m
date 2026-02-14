function extract_coords_from_DET()
    % SAVE_CENTROIDS_TO_EXCEL_WITH_ROI Allows selection of 3 DET files and saves ROI centroids into an Excel file
    %
    % This script:
    % - Prompts the user to select three DET files via a GUI
    % - Calculates the ROI centroids for each file, including ROI numbers
    % - Saves the centroids into an Excel file with three sheets: M, B, and H
    % - Names the Excel file "locs.xlsx" and saves it to the directory of the last selected file

    % Define image dimensions
    imageHeight = 256; 
    imageWidth = 256;

    % Initialize storage for centroids and file paths
    allCentroids = cell(3, 1);
    lastFilePath = '';

    % Sheet names for the Excel file
    sheetNames = {'M', 'B', 'H'};

    % Loop to select 3 files
    for i = 1:3
        [fileName, filePath] = uigetfile('*.det', sprintf('Select DET file %d', i));
        if isequal(fileName, 0)
            disp('File selection cancelled. Exiting...');
            return;
        end
        fullFilePath = fullfile(filePath, fileName);
        lastFilePath = filePath; % Update the last file path
        
        % Update the MATLAB workspace to the current file's directory
        cd(filePath);

        % Read the DET file content
        fileID = fopen(fullFilePath, 'r');
        detData = fread(fileID, '*char')';
        fclose(fileID);

        % Split the DET data into ROIs (using commas as delimiters)
        roiStrings = split(detData, ',');

        % Initialize storage for centroids in this file
        centroids = cell(length(roiStrings), 3); % Columns: ROI Number, Centroid X, Centroid Y

        % Process each ROI
        roiCounter = 1;
        for j = 1:length(roiStrings)
            roiString = strtrim(roiStrings{j}); % Remove leading/trailing whitespace
            if ~isempty(roiString)
                % Convert the pixel indices in the ROI to numeric values
                pixelIndices = str2double(splitlines(roiString));
                pixelIndices = pixelIndices(~isnan(pixelIndices)); % Remove NaNs

                % Convert linear indices to (row, column) coordinates
                [rows, cols] = ind2sub([imageHeight, imageWidth], pixelIndices);

                % Calculate the centroid of the ROI
                centroidX = mean(cols);
                centroidY = mean(rows);

                % Store the ROI number and centroids
                centroids{roiCounter, 1} = roiCounter; % ROI Number
                centroids{roiCounter, 2} = centroidX;  % Centroid X
                centroids{roiCounter, 3} = centroidY;  % Centroid Y
                roiCounter = roiCounter + 1;
            end
        end

        % Remove empty rows in the centroids
        centroids = centroids(~cellfun(@isempty, centroids(:, 1)), :);
        
        % Store centroids for this file
        allCentroids{i} = centroids;
    end

    % Save all centroids to an Excel file
    outputFileName = fullfile(lastFilePath, 'locs.xlsx');
    for i = 1:3
        % Write each set of centroids to its corresponding sheet
        writecell({'ROI Number', 'Centroid X', 'Centroid Y'}, outputFileName, 'Sheet', sheetNames{i}, 'Range', 'A1'); % Write headers
        writecell(allCentroids{i}, outputFileName, 'Sheet', sheetNames{i}, 'Range', 'A2'); % Write data
    end

    % Change the working directory to the last file's location
    cd(lastFilePath);

    % Display success message
    disp(['Centroids with ROI numbers saved to ', outputFileName]);
end
