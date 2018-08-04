function SimData = ReadTerrainInfo(SimData,MaxTerrainSize,TerrainTypeFlag,varargin)

TerrainFile = SimData.TerrainFile;


%% Extracting spatial dimensions %%

if TerrainTypeFlag == 1 %%% WRF file 
    
    SimData.XSTART = 1;
    SimData.XEND = double(ncreadatt(TerrainFile,'/','WEST-EAST_GRID_DIMENSION'))-1;    
    SimData.YSTART = 1;
    SimData.YEND = double(ncreadatt(TerrainFile,'/','SOUTH-NORTH_GRID_DIMENSION'))-1;  
    SimData.nx = SimData.XEND - SimData.XSTART +1;
    SimData.ny = SimData.YEND - SimData.YSTART +1;    
    SimData.dx = double(ncreadatt(TerrainFile,'/','DX'));
    SimData.dy = double(ncreadatt(TerrainFile,'/','DY'));    
    SimData.OriginalCenterLat = double(ncreadatt(TerrainFile,'/','CEN_LAT')); 
    SimData.OriginalCenterLon = double(ncreadatt(TerrainFile,'/','CEN_LON'));  
    [SimData.CenterX,SimData.CenterY] = ll2utm(SimData.OriginalCenterLat,SimData.OriginalCenterLon);
    
    SimData.Matrix = ncread(TerrainFile,'HGT');
    SimData.Matrix = SimData.Matrix(:,:,1)';
    
elseif TerrainTypeFlag == 2 %%% Geotiff file
    
    Info = geotiffinfo(TerrainFile);
    
    SimData.XSTART = 1;
    SimData.XEND = Info.Width;
    SimData.YSTART = 1;
    SimData.YEND = Info.Height;    
    SimData.nx = SimData.XEND - SimData.XSTART +1;
    SimData.ny = SimData.YEND - SimData.YSTART +1;
    SimData.dx = (Info.CornerCoords.X(2) - Info.CornerCoords.X(1) +1)/SimData.nx;
    SimData.dy = (Info.CornerCoords.Y(1) - Info.CornerCoords.Y(3) +1)/SimData.ny;    
%     SimData.OriginalCenterLat = (Info.CornerCoords.Lat(1) + Info.CornerCoords.Lat(3))/2; % Possibility of misadjustment
%     SimData.OriginalCenterLon = (Info.CornerCoords.Lon(2) + Info.CornerCoords.Lon(3))/2;
%     [SimData.CenterX,SimData.CenterY] = ll2utm(SimData.OriginalCenterLat,SimData.OriginalCenterLon);
    SimData.CenterX = (Info.CornerCoords.X(1) + Info.CornerCoords.X(2))/2;
    SimData.CenterY = (Info.CornerCoords.Y(1) + Info.CornerCoords.Y(3))/2;    
    
    SimData.Matrix = imread(TerrainFile);
    SimData.Matrix = flip(SimData.Matrix,1);    
    
end


%% In case of redefinition of domain borders %%

SimData.DistCenter = [0;0]; % Distance between original domain and cropped domain centers (if any new borders are defined)

if nargin == 4
    
    NewDomainCorners = varargin{1};
    XSTART_New = NewDomainCorners(1,1); XEND_New = NewDomainCorners(1,2); 
    YSTART_New = NewDomainCorners(2,1); YEND_New = NewDomainCorners(2,2);
    SimData.nx = XEND_New - XSTART_New +1;
    SimData.ny = YEND_New - YSTART_New +1;
    XDistCenter = XSTART_New  + (XEND_New - XSTART_New)/2 - (SimData.XSTART + (SimData.XEND - SimData.XSTART)/2) +1;
    YDistCenter = YSTART_New  + (YEND_New - YSTART_New)/2 - (SimData.YSTART + (SimData.YEND - SimData.YSTART)/2) +1;
    SimData.DistCenter = [-SimData.dx*XDistCenter; SimData.dy*YDistCenter];
    
    SimData.CenterX = SimData.CenterX + XDistCenter*SimData.dx; % New domain center
    SimData.CenterY = SimData.CenterY + YDistCenter*SimData.dy;
        
    SimData.XSTART = XSTART_New; SimData.XEND = XEND_New;
    SimData.YSTART = YSTART_New; SimData.YEND = YEND_New;
    
    SimData.Matrix = SimData.Matrix(YSTART_New:YEND_New, XSTART_New:XEND_New);        
    
end


%% Averaging terrain matrix when size is too big %%
% Matrix points can be averaged by group of 4 or 9

%if SimData.ReliefFlag > 0
    if numel(SimData.Matrix) >= 4*MaxTerrainSize
        AvgValue = 9;
        fprintf('Terrain is smoothed to reduce number of cell, averaging factor is %i\n', AvgValue)
        SimData = MatrixAveraging(SimData,AvgValue);
    elseif numel(SimData.Matrix) >= MaxTerrainSize
        AvgValue = 4;
        fprintf('Terrain is smoothed to reduce number of cell, averaging factor is %i\n', AvgValue)
        SimData = MatrixAveraging(SimData,AvgValue);
    end
%end

%% Minimizing cell number by lowering minimum altitude to 0 %%

SimData.Min = min(min(min(SimData.Matrix))); %(TerrainData.YSTART:TerrainData.YEND, TerrainData.XSTART:TerrainData.XEND)))); %%% /!\ Not tested if WRF lower altitude than terrain lower altitude ?

SimData.Matrix = SimData.Matrix - SimData.Min;

SimData.Max = max(max(SimData.Matrix));

IndMin = find(SimData.Matrix <= 0.5); % Relief below 50 cm is considered 0 m level

SimData.NbTerrain = size(SimData.Matrix,1)*size(SimData.Matrix,2) - size(IndMin,1);

