%DRIVER_OCTAVE_BTPDE_DEMO Run a small finite-element BTPDE simulation in Octave.

project_root = fileparts(mfilename("fullpath"));
original_dir = pwd();
cd(project_root);
restore_directory = onCleanup(@() cd(original_dir));

pkg load datatypes;
addpath(genpath(fullfile(project_root, "src")));

test_dir = tempname();
mkdir(test_dir);

setup.name = fullfile(test_dir, "sphere");
setup.gamma = 0.2675222005;

setup.geometry.cell_shape = "sphere";
setup.geometry.ncell = 1;
setup.geometry.rmin = 5;
setup.geometry.rmax = 5;
setup.geometry.dmin = 0.1;
setup.geometry.dmax = 0.2;
setup.geometry.include_in = false;
setup.geometry.ecs_shape = "no_ecs";
setup.geometry.refinement = 2;
setup.geometry.deformation = [0; 0];

setup.pde.diffusivity_out = 0.002;
setup.pde.relaxation_out = Inf;
setup.pde.initial_density_out = 1;
setup.pde.permeability_out = 0;

setup.gradient.sequences = {PGSE(8000, 49000)};
setup.gradient.directions = [1; 0; 0];
setup.gradient.values = [0, 5000];
setup.gradient.values_type = "b";

setup.btpde.ode_solver = @ode15s;
setup.btpde.reltol = 1e-4;
setup.btpde.abstol = 1e-6;

[setup, femesh] = prepare_simulation(setup);
npoint = sum(cellfun(@(points) size(points, 2), femesh.points));
fprintf("Running BTPDE on a generated mesh with %d nodes.\n", npoint);

result = solve_btpde(femesh, setup);
signals = result.signal_allcmpts(:);

assert(numel(signals) == 2 && all(isfinite(signals)) && all(signals > 0), ...
    "BTPDE did not return two finite positive signals.");
assert(signals(2) < signals(1), ...
    "The nonzero gradient did not attenuate the BTPDE signal.");

free = compute_free_diffusion( ...
    setup.gradient.bvalues, setup.pde.diffusivity, ...
    femesh.volumes, setup.pde.initial_density);
bvalues = setup.gradient.bvalues(:, 1);
normalized_btpde = abs(signals) / abs(signals(1));
normalized_free = abs(free.signal_allcmpts(:)) / abs(free.signal_allcmpts(1));
normalized_magnetization = abs(result.magnetization{1, 2, 1, 1}) ...
    / setup.pde.initial_density(1);

graphics_toolkit("qt");
plot_figure = figure("color", "white", "position", [100, 100, 1200, 560]);

mesh_axes = axes("position", [0.05, 0.16, 0.38, 0.68]);
facets = [femesh.facets{1, :}];
points = femesh.points{1};
mesh_plot = trisurf(facets', points(1, :), points(2, :), points(3, :), ...
    normalized_magnetization);
set(mesh_plot, "facecolor", "interp", ...
    "edgecolor", [0.25, 0.3, 0.35], "linewidth", 0.25);
axis equal;
axis tight;
view(3);
xlabel("x");
ylabel("y");
zlabel("z");
title(sprintf("Final magnetization at b = %g", bvalues(2)));
colorbar_handle = colorbar();
set(colorbar_handle, "position", [0.46, 0.23, 0.018, 0.55]);
title(colorbar_handle, "|M| / M_0");

signal_axes = axes("position", [0.68, 0.17, 0.28, 0.66]);
plot(bvalues, normalized_btpde, "-o", ...
    "linewidth", 2, "markersize", 8);
hold on;
plot(bvalues, normalized_free, "--s", ...
    "linewidth", 2, "markersize", 7);
grid on;
xlabel("b-value");
ylabel("S(b) / S(0)");
set(gca, "yscale", "log");
ylim([min([normalized_btpde(:); normalized_free(:)]) / 2, 1.05]);
legend("BTPDE", "Free", "location", "southwest", "fontsize", 8);
title("S(b) vs b (log y)");

image_path = fullfile(project_root, "octave_btpde_sphere_demo.png");
drawnow();
print(plot_figure, image_path, "-dpng", "-opengl", "-r200");
close(plot_figure);
image_info = dir(image_path);
if isempty(image_info) || image_info.bytes == 0
    error("Figure export did not create a non-empty PNG at %s.", image_path);
end

fprintf("Signal at b = 0:    %.6f\n", signals(1));
fprintf("Signal at b = 5000: %.6f\n", signals(2));
fprintf("Figure saved to: %s\n", image_path);
fprintf("Octave FEM BTPDE demo passed.\n");

previous_confirmation = confirm_recursive_rmdir(false);
[status, message] = rmdir(test_dir, "s");
confirm_recursive_rmdir(previous_confirmation);
if status ~= 1
    error("Could not remove temporary test directory %s: %s", test_dir, message);
end

clear restore_directory
