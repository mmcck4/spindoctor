%DRIVER_OCTAVE_ANALYTICAL_DEMO Run a small SpinDoctor simulation in Octave.
% This analytical sphere example does not generate a mesh or run ode15s.

clear

project_root = fileparts(mfilename("fullpath"));
addpath(genpath(fullfile(project_root, "src")));
pkg load datatypes;

setup.name = "octave_smoke";
setup.gamma = 0.2675222005;
setup.geometry.cell_shape = "sphere";
setup.geometry.ncell = 1;
setup.geometry.rmin = 5;
setup.geometry.rmax = 5;
setup.geometry.dmin = 0.1;
setup.geometry.dmax = 0.2;
setup.geometry.include_in = false;
setup.geometry.ecs_shape = "no_ecs";

setup.pde.diffusivity_out = 0.002;
setup.pde.relaxation_out = Inf;
setup.pde.initial_density_out = 1;
setup.pde.permeability_out = 0;

setup.gradient.sequences = {PGSE(8000, 49000)};
setup.gradient.directions = [1; 0; 0];
setup.gradient.values = [0, 500];
setup.gradient.values_type = "b";

setup.analytical.length_scale = 1;
setup.analytical.eigstep = 1e-6;

setup.geometry = prepare_geometry(setup);
setup.pde = prepare_pde(setup);
setup = prepare_experiments(setup);
setup.namplitude = numel(setup.gradient.values);
setup.nsequence = numel(setup.gradient.sequences);

signal = solve_analytical(setup);
expected_zero_gradient_signal = 4 * pi * setup.geometry.rmin^3 / 3;

assert(all(isfinite(signal)), "Analytical signal contains non-finite values.");
assert(abs(signal(1) - expected_zero_gradient_signal) ...
    <= 1e-10 * expected_zero_gradient_signal, ...
    "Zero-gradient signal does not match the sphere volume.");
assert(signal(2) > 0 && signal(2) < signal(1), ...
    "Nonzero gradient did not produce a positive attenuated signal.");

fprintf("Analytical sphere signal at b = 0:   %.6f\n", signal(1));
fprintf("Analytical sphere signal at b = 500: %.6f\n", signal(2));
fprintf("Octave analytical demo passed.\n");
