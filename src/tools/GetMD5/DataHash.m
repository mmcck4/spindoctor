function H = DataHash(Data, n)
    % Octave-compatible replacement for the MATLAB DataHash/GetMD5
    % implementation used by SpinDoctor.
    %
    % SpinDoctor only uses this to generate a short identifier for mf.eigs.

    if nargin < 2
        n = 32;
    end

    % Convert the input to a reproducible byte representation.
    if isnumeric(Data) || islogical(Data)
        bytes = typecast(Data(:), 'uint8');
    elseif ischar(Data)
        bytes = uint8(Data(:));
    elseif isstring(Data)
        bytes = uint8(char(Data));
    else
        bytes = uint8(evalc('disp(Data)'));
    end

    % Simple deterministic hash.
    h = uint32(2166136261);

    for k = 1:numel(bytes)
        h = bitxor(h, uint32(bytes(k)));
        h = uint32(mod(uint64(h) * uint64(16777619), uint64(2^32)));
    end

    H = lower(dec2hex(h, 8));

    % Extend deterministically if more characters are requested.
    while length(H) < n
        h = uint32(mod(uint64(h) * uint64(16777619), uint64(2^32)));
        H = [H, lower(dec2hex(h, 8))];
    end

    H = H(1:min(n, length(H)));
end