function displayimage(varargin) 
%DISPLAYIMAGE First argument is 2-D image, optional 2nd and 3rd arguments
%are min and max scale

switch nargin
    case 1
        frame = varargin{1};
        maxbrightness = max(max(frame));
        minbrightness = min(min(frame));
    case 3
        frame = varargin{1};
        minbrightness = varargin{2};
        maxbrightness = varargin{3};
    otherwise
        display('Displayimage requires 1 argument or 3');
end
imshow(frame, [minbrightness maxbrightness]);
drawnow;
end