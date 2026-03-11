function [x, y, h] = ellipse2D(xc, yc, a, b, theta, N, varargin)
%ELLIPSE2D  Generate (and optionally plot/fill) a 2-D ellipse.
%
%   [x, y, h] = ellipse2D(xc, yc, a, b, theta, N, Name, Value, ...)
%
%   Ellipse (centered at (xc, yc)) with semi-axes a (x-radius) and b (y-radius),
%   rotated by angle theta (radians). Generates N points (default 400).
%
%   Name-Value options:
%       'DoPlot'    (true/false)    : plot automatically (default: false)
%       'FaceColor' (color or 'none'): fill color (default: 'none')
%       'EdgeColor' (color)          : outline color (default: [0 0 0])
%       'LineWidth' (scalar)         : outline width (default: 2)
%       'Alpha'     (0..1)           : face transparency (default: 1)
%       'Parent'    (axes handle)    : target axes (default: gca when plotting)
%
%   Outputs:
%       x, y : 1xN vectors of ellipse coordinates
%       h    : graphics handle to the drawn object (line/patch), or [] if not plotted
%
%   Examples:
%       % Filled blue ellipse with 40% transparency
%       ellipse2D(0,0,4,2,deg2rad(30),400,'DoPlot',true,'FaceColor',[0 0.45 0.74],'Alpha',0.4);
%
%       % Red edge, no fill
%       ellipse2D(1,2,3,1,0,300,'DoPlot',true,'FaceColor','none','EdgeColor','r','LineWidth',1.5);

    if nargin < 6 || isempty(N), N = 400; end

    % Parse name-value pairs
    p = inputParser;
    p.addParameter('DoPlot',   false, @(v)islogical(v) || isnumeric(v));
    p.addParameter('FaceColor','none');
    p.addParameter('EdgeColor',[0 0 0]);
    p.addParameter('LineWidth',2, @(v)isnumeric(v) && isscalar(v) && v>=0);
    p.addParameter('Alpha',    1, @(v)isnumeric(v) && isscalar(v) && v>=0 && v<=1);
    p.addParameter('Parent',   [], @(v) isempty(v) || ishghandle(v,'axes'));
    p.parse(varargin{:});
    opt = p.Results;

    % Parameterization
    t = linspace(0, 2*pi, N);
    ct = cos(t); st = sin(t);
    c = cos(theta); s = sin(theta);

    x = xc + a*ct*c - b*st*s;
    y = yc + a*ct*s + b*st*c;

    % Plot if requested
    h = [];
    if opt.DoPlot
        ax = opt.Parent;
        if isempty(ax), ax = gca; end
        holdState = ishold(ax);
        hold(ax, 'on');

        % If filled (FaceColor ~= 'none' and Alpha>0), use patch; else use line
        doFill = ~( (ischar(opt.FaceColor) && strcmpi(opt.FaceColor,'none')) || ...
                    (isstring(opt.FaceColor) && strcmpi(opt.FaceColor,"none")) || ...
                    (isnumeric(opt.FaceColor) && numel(opt.FaceColor)==1 && isnan(opt.FaceColor)) || ...
                    opt.Alpha==0 );

        if doFill
            h = patch('XData', x, 'YData', y, ...
                      'FaceColor', opt.FaceColor, ...
                      'EdgeColor', opt.EdgeColor, ...
                      'LineWidth', opt.LineWidth, ...
                      'FaceAlpha', opt.Alpha, ...
                      'Parent', ax);
        else
            h = plot(ax, x, y, 'Color', opt.EdgeColor, 'LineWidth', opt.LineWidth);
        end

        axis(ax, 'equal');
        grid(ax, 'on');
        if ~holdState, hold(ax, 'off'); end
    end
end