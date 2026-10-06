function pde = prepare_pde(setup)
%PREPARE_PDE Create initial data for solving PDE.
%
%   setup: struct
%
%   pde: struct


% Extract compartment information
cell_shape = setup.geometry.cell_shape;
ncell = setup.geometry.ncell;
include_in = setup.geometry.include_in;
include_ecs = ~strcmp(char(setup.geometry.ecs_shape), 'no_ecs');

pde = setup.pde;

% check diffusivity (tensorize if scalars), relaxation, permeability
pde.diffusivity_out = pde.diffusivity_out * eye(3);
assert(check_diffusion_tensor(pde.diffusivity_out), "Please check diffusivity_out.");
if ~isfield(pde, 'initial_density_out')
    pde.initial_density_out = 1.0;
end
if isfield(pde, 'relaxation_out')
    assert(pde.relaxation_out > 0, "relaxation_out is negative or zero.");
else
    pde.relaxation_out = Inf;
end
if isfield(pde, 'permeability_out')
    assert(pde.permeability_out >= 0, "permeability_out is negative.");
else
    pde.permeability_out = 0;
end

if include_ecs
    pde.diffusivity_ecs = pde.diffusivity_ecs * eye(3);
    assert(check_diffusion_tensor(pde.diffusivity_ecs), "Please check diffusivity_ecs.");
    if ~isfield(pde, 'initial_density_ecs')
        pde.initial_density_ecs = 1.0;
    end
    if isfield(pde, 'relaxation_ecs')
        assert(pde.relaxation_ecs > 0, "relaxation_ecs is negative or zero.");
    else
        pde.relaxation_ecs = Inf;
    end
    if isfield(pde, 'permeability_ecs')
        assert(pde.permeability_ecs >= 0, "permeability_ecs is negative.");
    else
        pde.permeability_ecs = 0;
    end
    if isfield(pde, 'permeability_out_ecs')
        assert(pde.permeability_out_ecs >= 0, "permeability_out_ecs is negative.");
    else
        pde.permeability_out_ecs = 0;
    end
else
    useless_fields = {'diffusivity_ecs', 'initial_density_ecs', ...
        'relaxation_ecs', 'permeability_ecs', 'permeability_out_ecs'};
    pde = rmfields(pde, useless_fields);
end

if include_in
    pde.diffusivity_in = pde.diffusivity_in * eye(3);
    assert(check_diffusion_tensor(pde.diffusivity_in), "Please check diffusivity_in.");
    if ~isfield(pde, 'initial_density_in')
        pde.initial_density_in = 1.0;
    end
    if isfield(pde, 'relaxation_in')
        assert(pde.relaxation_in > 0, "relaxation_in is negative or zero.");
    else
        pde.relaxation_in = Inf;
    end
    if isfield(pde, 'permeability_in')
        assert(pde.permeability_in >= 0, "permeability_in is negative.");
    else
        pde.permeability_in = 0;
    end
    if isfield(pde, 'permeability_in_out')
        assert(pde.permeability_in_out >= 0, "permeability_in_out is negative.");
    else
        pde.permeability_in_out = 0;
    end
else
    useless_fields = {'diffusivity_in', 'initial_density_in', ...
        'relaxation_in', 'permeability_in', 'permeability_in_out'};
    pde = rmfields(pde, useless_fields);
end

% Number of compartments
ncompartment = (1 + include_in) * ncell + include_ecs;

% Find number of boundaries
switch char(cell_shape)
    case 'cylinder'
        % An axon has a side interface, and a top-bottom boundary
        nboundary = (include_in + 1) * 2 * ncell + include_ecs;
    case 'sphere'
        % For a sphere, there is one interface
        nboundary = (include_in + 1) * ncell + include_ecs;
    case 'neuron'
        % For a neuron, there is one interface
        nboundary = 1 + include_ecs;
end

% the list `boundaries` must have the same order as surfaces.facetmarkers
% cylinder: `boundaries` = [('in,out'), ('out,ecs')/('out'), ('in'), 'out', ('ecs')]
% sphere, neuron: `boundaries` = [('in,out'), ('out,ecs')/('out'), ('ecs')]
compartments = {};
boundaries = {};
if include_in
    % Add in-compartments and in-out-interfaces
    compartments = repmat({'in'}, 1, ncell);
    boundaries = repmat({'in,out'}, 1, ncell);
end

compartments = [compartments repmat({'out'}, 1, ncell)];

if include_ecs
    % Add ecs-compartment and out-ecs interfaces
    compartments = [compartments {'ecs'}];
    boundaries = [boundaries repmat({'out,ecs'}, 1, ncell)];
else
    % Add outer cylinder side wall or sphere/neuron out boundaries
    boundaries = [boundaries repmat({'out'}, 1, ncell)];
end

if strcmp(char(cell_shape), 'cylinder')
    if include_in
        % Add inner cylinder top and bottom boundary
        boundaries = [boundaries repmat({'in'}, 1, ncell)];
    end
    % Add outer cylinder top and bottom boundary
    boundaries = [boundaries repmat({'out'}, 1, ncell)];
    % Add ecs boundary
    if include_ecs
        boundaries = [boundaries {'ecs'}];
    end
end

if (strcmp(char(cell_shape), 'sphere') || strcmp(char(cell_shape), 'neuron')) && include_ecs
    % Add ecs boundary
    boundaries = [boundaries {'ecs'}];
end

% Initialization
diffusivity = zeros(3, 3, ncompartment);
relaxation = zeros(1, ncompartment);
initial_density = zeros(1, ncompartment);
permeability = zeros(1, nboundary);

% out compartments
% out compartments
out_compartments = strcmp(compartments, 'out');
out_boundaries = strcmp(boundaries, 'out');

diffusivity(:, :, out_compartments) = ...
    repmat(pde.diffusivity_out, 1, 1, sum(out_compartments));

initial_density(out_compartments) = pde.initial_density_out;
relaxation(out_compartments) = pde.relaxation_out;
permeability(out_boundaries) = pde.permeability_out;

if include_ecs
    ecs_compartments = strcmp(compartments, 'ecs');
    ecs_boundaries = strcmp(boundaries, 'ecs');
    out_ecs_boundaries = strcmp(boundaries, 'out,ecs');

    diffusivity(:, :, ecs_compartments) = ...
        repmat(pde.diffusivity_ecs, 1, 1, sum(ecs_compartments));

    initial_density(ecs_compartments) = pde.initial_density_ecs;
    relaxation(ecs_compartments) = pde.relaxation_ecs;

    permeability(ecs_boundaries) = pde.permeability_ecs;
    permeability(out_ecs_boundaries) = pde.permeability_out_ecs;
end

if include_in
    in_compartments = strcmp(compartments, 'in');
    in_boundaries = strcmp(boundaries, 'in');
    in_out_boundaries = strcmp(boundaries, 'in,out');

    diffusivity(:, :, in_compartments) = ...
        repmat(pde.diffusivity_in, 1, 1, sum(in_compartments));

    initial_density(in_compartments) = pde.initial_density_in;
    relaxation(in_compartments) = pde.relaxation_in;

    permeability(in_boundaries) = pde.permeability_in;
    permeability(in_out_boundaries) = pde.permeability_in_out;
end

% Update domain parameters with new variables
pde.diffusivity = diffusivity;
pde.relaxation = relaxation;
pde.initial_density = initial_density;
pde.permeability = permeability;
pde.compartments = compartments;
pde.boundaries = boundaries;
end

function flag = check_diffusion_tensor(diffusion_tensor)
    % need to check the properties of intrinsic diffusion tensor
    eigvals = eig(diffusion_tensor);
    flag = all(eigvals >= 0) && all(size(diffusion_tensor) == 3);
end
