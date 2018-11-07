function SimData = Smooth(SimData)

% Smooth the following layers: topography, wind data, Z0 and land-use
% using imresize (bicubic interpolation by default).
% Land-use is interpolated with the "nearest point" method as we must not
% change the categories values.

% Updating dimensions
nx2 = floor(sqrt(SimData.MaxTerrainSize*SimData.nx/SimData.ny));
ny2 = floor(sqrt(SimData.MaxTerrainSize*SimData.ny/SimData.nx));
SimData.nx = nx2;
SimData.ny = ny2;
SimData.dx = SimData.dx*SimData.nx/nx2;
SimData.dy = SimData.dy*SimData.ny/ny2; 

% Terrain
SimData.Relief = imresize(SimData.Relief,[ny2,nx2]);

% Wind velocity, direction and vertical position
SimData.WS = imresize(SimData.WS,[ny2,nx2]);
SimData.WD = imresize(SimData.WD,[ny2,nx2]);
SimData.CoordZ = imresize(SimData.CoordZ,[ny2,nx2]);

% Roughness length
SimData.Z0 = imresize(SimData.Z0,[ny2,nx2]);

% Land-use
SimData.LU = imresize(SimData.LU,[ny2,nx2],'nearest');

fprintf('Domain smoothed : new number of cells is %i\n', nx2*ny2) 