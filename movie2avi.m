function movie2avi(mov, filename, varargin)
    % Custom replacement for the removed MATLAB function movie2avi
    % Uses VideoWriter internally to avoid modifying legacy code.
    %
    % Parameters:
    % - mov: MATLAB movie structure
    % - filename: Output AVI file name
    % - varargin: Optional parameters (compression, FPS, quality, etc.)
    
    % Default settings
    compression = 'None';
    fps = 15;  % Default frame rate
    quality = 75;  % Default quality (if using Motion JPEG)
    
    % Parse optional arguments
    for i = 1:length(varargin)
        if ischar(varargin{i})
            switch lower(varargin{i})
                case 'compression'
                    compression = varargin{i+1};
                case 'fps'
                    fps = varargin{i+1};
                case 'quality'
                    quality = varargin{i+1};
            end
        end
    end
    
    % Set VideoWriter format
    if strcmpi(compression, 'None')
        v = VideoWriter(filename, 'Uncompressed AVI');
    elseif strcmpi(compression, 'Indeo5') || strcmpi(compression, 'Motion JPEG AVI')
        v = VideoWriter(filename, 'Motion JPEG AVI');
        v.Quality = quality;  % Set quality if using Motion JPEG
    else
        error('Unsupported compression type: %s', compression);
    end
    
    v.FrameRate = fps;  % Set frame rate
    open(v);
    
    % Write frames
    for k = 1:length(mov)
        writeVideo(v, mov(k).cdata);
    end
    
    close(v);
end
