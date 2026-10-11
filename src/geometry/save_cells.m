function save_cells(cells, cellfilename)

%SAVE_CELLS Write geometrical cell configuration to file.

% Extract cell parameters
centers = cells.centers;
radii = cells.radii;

% Sizes
ncell = length(radii);
dim = size(centers, 1);

% Save geometry to file
disp(["Writing geometry to ", char(cellfilename)]);

fid = fopen(cellfilename, "w");

fprintf(fid, "Number of cells:\n");
fprintf(fid, "%d\n", ncell);

fprintf(fid, "Dimension:\n");
fprintf(fid, "%d\n", dim);

c = "x,y";

if dim == 3
    c = [c, ",z"];
end

fprintf(fid, "Number n, Center (%s), Radius r\n", c);

for icell = 1:ncell

    if fid ~= -1
        format_string = ["%d ", repmat("%g ", 1, dim), "%g\n"];
        fprintf(fid, format_string, icell, centers(:, icell), radii(icell));
    end

end

fclose(fid);

end