function [x, y, button, ax] = ginputAMedit(varargin)
%Parts of this function have been copied from a function called GINPUTC by 
%Jiro Doke, October 19 2012, Copyright 2012 The MathWorks, Inc. Function
%has been edited to include two different axes for coordinate selection on a
%figure which contains two images. Function has also been edited to include
%labelling of coordinates in order of selection.

try
    if verLessThan('matlab', '7.5')
        error('ginputc:Init:IncompatibleMATLAB', ...
            'GINPUTC requires MATLAB R2007b or newer');
    end
catch %#ok<CTCH>
    error('ginputc:Init:IncompatibleMATLAB', ...
        'GINPUTC requires MATLAB R2007b or newer');
end

% Check input arguments
p = inputParser();

addOptional(p, 'N', inf, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}));
addParamValue(p, 'Color', 'k', @colorValidFcn);
addParamValue(p, 'LineWidth', 0.5 , @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'positive'}));
addParamValue(p, 'LineStyle', '-' , @(x) validatestring(x, ...
    {'-', '--', '-.', ':'}));
addParamValue(p, 'ShowPoints', false, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));
addParamValue(p, 'ConnectPoints', true, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));
addParamValue(p, 'Axis', true); %@(x) validateattributes(x, ...
    %{'numeric'}, {'row'}));
addParamValue(p, 'FirstCall', true, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));

parse(p, varargin{:});

N = p.Results.N;
color = p.Results.Color;
linewidth = p.Results.LineWidth;
linestyle = p.Results.LineStyle;
showpoints = p.Results.ShowPoints;
connectpoints = p.Results.ConnectPoints;
axis = p.Results.Axis;
firstcall = p.Results.FirstCall;

%--------------------------------------------------------------------------
    function tf = colorValidFcn(in)
        % This function validates the color input parameter
        
        validateattributes(in, {'char', 'double'}, {'nonempty'});
        if ischar(in)
            validatestring(in, {'b', 'g', 'r', 'c', 'm', 'y', 'k', 'w'});
        else
            assert(isequal(size(in), [1 3]) && all(in>=0 & in<=1), ...
                'ginputc:InvalidColorValues', ...
                'RGB values for "Color" must be a 1x3 vector between 0 and 1');
            % validateattributes(in, {'numeric'}, {'size', [1 3], '>=', 0, '<=', 1})
        end
        tf = true;
    end
%--------------------------------------------------------------------------

hFig = gcf;
hAx = axis;

% Save current window functions
curWBDF = get(hFig, 'WindowButtonDownFcn');
curWBMF = get(hFig, 'WindowButtonMotionFcn');
curWBUF = get(hFig, 'WindowButtonUpFcn');
curKPF  = get(hFig, 'KeyPressFcn');
curKRF  = get(hFig, 'KeyReleaseFcn');
curRF   = get(hFig, 'ResizeFcn');
try  %#ok<TRYNC> % for newer versions of MATLAB
    curWKPF = get(hFig, 'WindowKeyPressFcn');
    curWKRF = get(hFig, 'WindowKeyReleaseFcn');
end

% Save current pointer
curPointer = get(hFig, 'Pointer');
curPointerShapeCData = get(hFig, 'PointerShapeCData');

% Change window functions
set(hFig, 'WindowButtonDownFcn', @mouseClickFcn);
set(hFig, 'WindowButtonMotionFcn', @mouseMoveFcn);
set(hFig, 'WindowButtonUpFcn', '');
set(hFig, 'KeyPressFcn', @keyPressFcn);
set(hFig, 'KeyReleaseFcn', '');
set(hFig, 'ResizeFcn', @resizeFcn);
try %#ok<TRYNC> % for newer versions of MATLAB
    set(hFig, 'WindowKeyPressFcn', @keyPressFcn);
    set(hFig, 'WindowKeyReleaseFcn', '');
end

% Change actual cursor to blank
set(hFig, ...
    'Pointer', 'custom', ...
    'PointerShapeCData', nan(16, 16));

% Create an invisible axes for displaying the full crosshair cursor
hInvisibleAxes = axes(...
    'Units', 'normalized', ...
    'XLim', [0 1], ...
    'YLim', [0 1], ...
    'Position', [0 0 1 1], ...
    'HitTest', 'off', ...
    'HandleVisibility', 'off', ...
    'Visible', 'off');
    
  
% Create line object for the selected points
if showpoints
    if connectpoints
        pointsLineStyle = '-';
    else
        pointsLineStyle = 'none';
    end
    
    selectedPoints = [];
    hPoints = line(nan, nan, ...
        'Parent', hInvisibleAxes, ...
        'HandleVisibility', 'off', ...
        'HitTest', 'off', ...
        'Color', [1 0 0], ...
        'Marker', 'o', ...
        'MarkerFaceColor', [1 .7 .7], ...
        'MarkerEdgeColor', [1 0 0], ...
        'LineStyle', pointsLineStyle);
end


if firstcall
    % Create tooltip for displaying selected points
    
    hTooltipControl = text(0, 1, 'Selected Pixels', ...
        'Parent',axis,...
        'HandleVisibility', 'callback', ...
        'FontName', 'FixedWidth', ...
        'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [.5 1 .5]);
    hTooltip = text(0, 0, 'No points', ...
        'Parent',axis,...
        'HandleVisibility', 'off', ...
        'HitTest', 'off', ...
        'FontName', 'FixedWidth', ...
        'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 .5]);
else
    
    hTooltipControl = text(0, 1, 'Selected Pixels', ...
        'Parent',axis,...
        'HandleVisibility', 'callback', ...
        'FontName', 'FixedWidth', ...
        'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [.5 1 .5]);
    hTooltip = text(0, 0, 'No points', ...
        'Parent',axis,...
        'HandleVisibility', 'off', ...
        'HitTest', 'off', ...
        'FontName', 'FixedWidth', ...
        'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 .5]);
end

% Call resizeFcn to update tooltip location
resizeFcn();

% Create full crosshair lines
hCursor = line(nan, nan, ...
    'Parent', hInvisibleAxes, ...
    'Color', color, ...
    'LineWidth', linewidth, ...
    'LineStyle', linestyle, ...
    'HandleVisibility', 'off', ...
    'HitTest', 'off');

% Prepare results
x = [];
y = [];
button = [];
ax = [];

% Wait until enter is pressed.
uiwait(hFig);


%--------------------------------------------------------------------------
    function mouseMoveFcn(varargin)
        % This function updates cursor location based on pointer location
        
        cursorPt = get(hInvisibleAxes, 'CurrentPoint');
        
        set(hCursor, ...
            'XData', [0 1 nan cursorPt(1) cursorPt(1)], ...
            'YData', [cursorPt(3) cursorPt(3) nan 0 1]);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function mouseClickFcn(varargin)
        % This function captures mouse clicks.
        % If the tooltip control is clicked, then toggle tooltip display.
        % If anywhere else is clicked, record point.

        if isequal(gco, hTooltipControl)
            tooltipClickFcn();
        else
            updatePoints(get(hFig, 'SelectionType'));
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function keyPressFcn(varargin)
        % This function captures key presses.
        % If "return", then exit.
        % If "delete" (or "backspace"), then delete previous point.
        % If any other key, record point.
        
        key = double(get(hFig, 'CurrentCharacter'));
        if isempty(key)
            return;
        end
        
        switch key
            case 13  % return
                exitFcn();
                
            case {8, 127}   % delete or backspace
                if ~isempty(x)
                    x(end) = [];
                    y(end) = [];
                    button(end) = [];
                    ax(end) = [];
                    
                    if showpoints
                        selectedPoints(end, :) = [];
                        set(hPoints, ...
                            'XData', selectedPoints(:, 1), ...
                            'YData', selectedPoints(:, 2));
                    end
                    
                    displayCoordinates(axis);
                end
                
            otherwise
                updatePoints(key);
                
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function updatePoints(clickType)
        % This function captures the information for the selected point
        
        hAx = axis;
        pt = get(hAx, 'CurrentPoint');
        x = [x; pt(1)];
        y = [y; pt(3)];
        ax = [ax; hAx];

        if ischar(clickType)   % Mouse click
            switch lower(clickType)
                case 'open'
                    clickType = 1;
                case 'normal'
                    clickType = 1;
                case 'extend'
                    clickType = 2;
                case 'alt'
                    clickType = 3;
            end
        end
        button = [button; clickType];
        
        displayCoordinates(axis);
        
        if showpoints
            cursorPt = get(hInvisibleAxes, 'CurrentPoint');
            selectedPoints = [selectedPoints; cursorPt([1 3])];
            set(hPoints, ...
                'XData', selectedPoints(:, 1), ...
                'YData', selectedPoints(:, 2));
        end
        
        % If captured all points, exit
        if length(x) == N
            exitFcn();
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function tooltipClickFcn()
        % This function toggles the display of the tooltip
        
        if strcmp(get(hTooltipControl, 'String'), 'SHOW')
            set(hTooltipControl, 'String', 'HIDE');
            set(hTooltip, 'Visible', 'on');
        else
            set(hTooltipControl, 'String', 'SHOW');
            set(hTooltip, 'Visible', 'off');
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function displayCoordinates(axis)
        % This function updates the coordinates display in the tooltip
        
        set(gcf,'CurrentAxes',axis);
        
        if isempty(x)
            str = 'No points';
        else
            str = sprintf('%d: %0.3f, %0.3f\n', [1:length(x); x'; y']);
            str(end) = '';
        end
        set(hTooltip, ...
            'String', str);
        pointerLabel = sprintf('%d',length(x));
        text(x(length(x))+3,y(length(x))+3,pointerLabel);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function resizeFcn(varargin)
        % This function adjusts the position of tooltip when the figure is
        % resized
        
        sz = get(hTooltipControl, 'Extent');
        set(hTooltip, 'Position', [0 sz(2)]);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function exitFcn()
        % This function exits GINPUTC and restores previous figure settings
        
        % Restore window functions and pointer
        set(hFig, 'WindowButtonDownFcn', curWBDF);
        set(hFig, 'WindowButtonMotionFcn', curWBMF);
        set(hFig, 'WindowButtonUpFcn', curWBUF);
        set(hFig, 'KeyPressFcn', curKPF);
        set(hFig, 'KeyReleaseFcn', curKRF);
        set(hFig, 'ResizeFcn', curRF);gca
        set(hFig, 'Pointer', curPointer);
        set(hFig, 'PointerShapeCData', curPointerShapeCData);

        try %#ok<TRYNC> % for newer versions of MATLAB
            set(hFig, 'WindowKeyPressFcn', curWKPF);
            set(hFig, 'WindowKeyReleaseFcn', curWKRF);
        end

        % Delete invisible axes and return control
%         delete(hInvisibleAxes);
         uiresume(hFig);
    end
%--------------------------------------------------------------------------

end