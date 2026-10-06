function call_tetgen(filename, options)
%CALL_TETGEN Call Tetgen executable from system with refinement.
%   The tetgen executable is chosen according to the operating system. If an
%   error occurs, you might have to manually change the rights of the Tetgen
%   executable.
%
%   filename: string
%   refinement: [1 x 1]


% Tetgen command for corresponding operating system
if ispc
    tetgen_cmd = "src\tetgen\win64\tetgen";
elseif ismac
    out = system("chmod 775 src/tetgen/mac64/tetgen");
    if out ~= 0
        error_msg = join(["permission denied: src/tetgen/mac64/tetgen,",...
        " please grant 'src/tetgen/mac64/tetgen' executable permission."]);
        error(error_msg)
    end
    tetgen_cmd = "src/tetgen/mac64/tetgen";
elseif isunix
    out = system("chmod 775 src/tetgen/lin64/tetgen");
    if out ~= 0
        error_msg = join(["permission denied: src/tetgen/lin64/tetgen,",...
        " please grant 'src/tetgen/lin64/tetgen' executable permission."]);
        error(error_msg)
    end
    tetgen_cmd = "src/tetgen/lin64/tetgen";
else
    warning("Using Linux Tetgen command.")
    tetgen_cmd = "src/tetgen/tetGen/lin64/tetgen";
end

% Options for Tetgen command
% Options for Tetgen command

if nargin < 2
    tetgen_options = '-pqAVC';
elseif isnumeric(options)
    if options > 0
        tetgen_options = ['-pqAVCa', num2str(options)];
    else
        tetgen_options = '-pqAVC';
    end
else
    tetgen_options = char(options);
end

% Call Tetgen

cmd = [char(tetgen_cmd), ' ', char(tetgen_options), ' ', char(filename)];
disp(cmd)

system(cmd);
