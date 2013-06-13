function A = LoadData( fname )
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(fname, 'r');
A = fscanf(fid, '%f', inf);
fclose(fid);


end

