classdef (Abstract) AbsSequence
    %SEQUENCE Gradient sequence (time profile)
    %   This represents an abstract gradient sequence. Such a sequence is
    %   not assumed to have a fixed driection vector.
    
     methods (Abstract)
        function f = call(obj, t)
        end

        function t = diffusion_time(obj)
        end

        function [timelist, interval_str, timeprofile_str] = intervals(obj)
        end
    end
     methods
        
        function F = integral(obj, t)
            %INTEGRAL Compute the integral of the time profile from `0` to `t`.
            %   Unless overwritten, it computes a numerical approximation.
            F = arrayfun(@(s) integral(@obj.call, 0, s, "AbsTol", 1e-6,"RelTol", 1e-3),t);
        end
        % 
        function int = integral_F2(obj)
            %INTEGRAL_F2 Compute the temporal integration of F^2 (F = integral(obj, t)).
            %   Unless overwritten, it computes a numerical approximation.
            int = integral(@(s) obj.integral(s).^2, 0, obj.echotime, ...
            "AbsTol", 1e-6, "RelTol", 1e-3);
        end
        
        function b = bvalue_no_q(obj)
            %BVALUE_NO_Q Compute the time profile contribution to the b-value.
            b = obj.integral_F2;
        end
        
        function jn = J(obj, lambda, ninterval)
            %J Compute the quantity J(lambda) for the sequence.
            %   Unless overwritten, it computes a numerical approximation.
            if nargin == 2
                ninterval = 500;
            end
            ntime = ninterval + 1;
            time = linspace(0, seq.echotime, ntime);
            dtime = seq.echotime / ntime;

            fprintf("Use numerical integration to compute the the quantity J(lambda).\n");
            jn = @(t) integral(@(s) exp(lambda * (s - t)) .* obj.call(s), 0, t, ...
                    "Waypoints", [obj.delta, obj.Delta]);
            jn = lambda * obj.integral(time) .* arrayfun(jn, time);
            jn = dtime * trapz(jn) / obj.integral_F2;
        end
        
        function s = char(obj)
            %CHAR Convert sequence to character array.
            %   This is a wrapper for the STRING function.
            s = char(obj.string);
        end
    end

end