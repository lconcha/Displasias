function h = rhomboid2D(C, u, v, a, b, varargin)
%RHOMBOID2D  Plot a rhomboid defined by major/minor axis vectors.
%
%   h = rhomboid2D(C, u, v, a, b)
%   h = rhomboid2D(..., 'FaceColor', [r g b], 'EdgeColor','k', 'LineWidth',2)
%
%   C : [xc yc] center
%   u : major-axis direction (need not be normalized)
%   v : minor-axis direction (need not be normalized)
%   a : half-length along u
%   b : half-length along v

    u = u(:)' / norm(u);
    v = v(:)' / norm(v);

    % Compute corners
    p1 = C +  a*u +  b*v;
    p2 = C +  a*u -  b*v;
    p3 = C -  a*u -  b*v;
    p4 = C -  a*u +  b*v;

    X = [p1(1) p2(1) p3(1) p4(1)];
    Y = [p1(2) p2(2) p3(2) p4(2)];

    % Draw rhomboid
    h = patch(X, Y, 'w', varargin{:});
    axis equal;
end