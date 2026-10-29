function mag = btpde_seq_camino(seq,q,rho,Jx,K,Q,R,solve_ode,options_template,iseq,nsequence,npoint_cmpts,solver_str)
%BTPDE_SEQ Solves the Bloch-Torrey partial differential equation for a
%single constant direction sequence
%   
%  This solves the Bloch-Torrey partial differential equation by a finite
%  element method for a single sequence which is taken from a camino file.
%
%   seq : (AbsSequence) a single sequence
%   rho: (array) initial magnetisation
%   J: (matrix) gradient direction matrix
%   K : (matrix) stiffness matrix
%   Q : (matrix) flux matrix
%   R : (matrix) relaxation matrix
%   solve_ode: (func) ode solver
%   options_template: (odeset) parameters for ODE solver
%   iseq: (int) sequence index 
%   nsequence: (int) number of sequences

    [timelist, ~, ~] = seq.intervals;
    
    % Number of intervals
    ninterval = length(timelist) - 1;
    
    % Assemble gradient direction dependent finite element matrix
    
    
    
    % Initial magnetization
    mag = rho;
    
    % Solve for each interval consecutively
    for iint = 1:ninterval           
        % Add a third point to the interval, so that the ODE solver does not
        % store the magnetization for all time steps during the solve. If
        % there were only two points in the interval, the ODE solver would
        % store all time steps. This would require a lot of memory,
        % especially during parfor iterations
        interval_midpoint = (timelist(iint) + timelist(iint + 1)) / 2;
        time_list_interval = [timelist(iint), interval_midpoint, timelist(iint + 1)];
        ug = seq.vec_call(interval_midpoint);
        if norm(ug) < 1e-4
            ug = 0*ug;
        else
            ug= ug/norm(ug);
        end
        J = ug(1) * Jx{1} + ug(2) * Jx{2} + ug(3) * Jx{3};
        % Create new ODE functions on given interval
        [ode_function, Jacobian] = btpde_functions_interval( ...
            K, Q, R, J, q, seq, interval_midpoint);

        fprintf( ...
            ["Solving BTPDE of size %d using %s:\n" ...
             "  Direction at midpoint: ug = [%.2f; %.2f; %.2f]\n" ...
             "  Sequence %d of %d: f(t_mid) = %g\n" ...
             "  Interval %d of %d: t = [%g, %g]\n"], ...
            sum(npoint_cmpts), solver_str, ...
            ug(1), ug(2), ug(3), ...
            iseq, nsequence, seq.call(interval_midpoint), ...
            iint, ninterval, timelist(iint), timelist(iint + 1) ...
        );
    
        % Update options with new Jacobian, which is either a
        % function handle or a constant matrix, depending on the
        % time profile
        % Solve ODE on domain, starting from the magnetization at
        % the end of the previous interval (mag)
        mag = solve_btpde_ode(ode_function, Jacobian, ...
            time_list_interval, mag, options_template, solve_ode);
        fprintf("  Completed interval %d of %d.\n", iint, ninterval);
    end

end