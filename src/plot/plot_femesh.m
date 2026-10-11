function plot_femesh(femesh, compartments,make_new_figure)
%PLOT_FEMESH Plot the finite element meshes of inner, outer, and ECS compartments.
%
%   femesh: struct
%   compartments
colors = ["r" "b" "g" "y" "k" "c" "w"];

ncompartment = length(compartments);
labels = unique(compartments);

% Determine limits of domain
pmin = min([femesh.points{:}], [], 2);
pmax = max([femesh.points{:}], [], 2);
axis_vec = [pmin(1) pmax(1) pmin(2) pmax(2) pmin(3) pmax(3)];

for label = labels
    if nargin == 2 || make_new_figure
    figure;
    end
    hold on
    for icmpt = find(strcmp(compartments, label))
        facets = [femesh.facets{icmpt, :}];
        points = femesh.points{icmpt};

        h = trisurf(facets', points(1, :), points(2, :), points(3, :));
        set(h, "facealpha", 0.7);
        if 0 % ncompartment <= length(colors)
            set(h, "facecolor", colors(icmpt));
        else
            set(h, "facecolor", "interp");
        end

        % set(h, "LineStyle", "none");
        set(h, "LineWidth", 0.03);
        center = mean(points, 2);
        center(3) = max(points(3, :)) + 1;
        text(center(1), center(2), center(3), num2str(icmpt), "color", "r", "fontsize", 20);
    end

    xlabel("x");
    ylabel("y");
    zlabel("z");
    grid on;
    view(3);
    axis equal;
    axis(axis_vec);
    inds = find(strcmp(compartments, label));
    cmpt_str = sprintf("%d, ", inds);
if ~isempty(cmpt_str)
    cmpt_str = cmpt_str(1:end-2);
end
    title(sprintf("Finite element mesh, %s compartment: [%s]", char(label), cmpt_str));
end
