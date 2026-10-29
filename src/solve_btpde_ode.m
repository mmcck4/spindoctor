function mag = solve_btpde_ode(ode_function, Jacobian, time_list, mag, options_template, solve_ode)
%SOLVE_BTPDE_ODE Solve a BTPDE interval with the active ODE solver.

if exist("OCTAVE_VERSION", "builtin")
    nstate = numel(mag);
    mass = odeget(options_template, "Mass", []);
    options = odeset(options_template, ...
        "Mass", complex_matrix_to_real(mass), ...
        "Jacobian", @(t, y) real_jacobian(Jacobian, t, y, nstate), ...
        "MStateDependence", "none");
    ode_function = @(t, y) complex_vector_to_real( ...
        ode_function(t, real_vector_to_complex(y, nstate)));
    mag = complex_vector_to_real(mag);
    [~, y] = solve_ode(ode_function, time_list, mag, options);
    mag = real_vector_to_complex(y(end, :).', nstate);
else
    options = odeset(options_template, "Jacobian", Jacobian);
    [~, y] = solve_ode(ode_function, time_list, mag, options);
    mag = y(end, :).';
end
end

function y = complex_vector_to_real(z)
y = [real(z(:)); imag(z(:))];
end

function z = real_vector_to_complex(y, nstate)
z = y(1:nstate) + 1i * y(nstate + 1:end);
end

function A = complex_matrix_to_real(A_complex)
A = [real(A_complex), -imag(A_complex); ...
     imag(A_complex), real(A_complex)];
end

function J = real_jacobian(Jacobian, t, y, nstate)
if isa(Jacobian, "function_handle")
    J_complex = Jacobian(t, real_vector_to_complex(y, nstate));
else
    J_complex = Jacobian;
end
J = complex_matrix_to_real(J_complex);
end
