function [SimData,WRFData] = ReadWRFInfo(SimData,WRFFile)

WRFData.Clock = ncread(WRFFile,'Times');
WRFData.DistCenter = [0;0];


%% Extracting spatial dimensions %%

WRFData.XSTART = 1;
WRFData.XEND = double(ncreadatt(WRFFile,'/','WEST-EAST_GRID_DIMENSION'))-1;
WRFData.YSTART = 1;
WRFData.YEND = double(ncreadatt(WRFFile,'/','SOUTH-NORTH_GRID_DIMENSION'))-1;
WRFData.nx = WRFData.XEND - WRFData.XSTART +1;
WRFData.ny = WRFData.YEND - WRFData.YSTART +1;
WRFData.dx = double(ncreadatt(WRFFile,'/','DX'));
WRFData.dy = double(ncreadatt(WRFFile,'/','DY'));
WRFData.OriginalCenterLat = double(ncreadatt(WRFFile,'/','CEN_LAT'));
WRFData.OriginalCenterLon = double(ncreadatt(WRFFile,'/','CEN_LON'));
[WRFData.CenterX,WRFData.CenterY] = ll2utm(WRFData.OriginalCenterLat,WRFData.OriginalCenterLon);


%% Reducing WRF data to simulation domain %%

%if SimData.nx*SimData.dx < WRFData.nx*WRFData.dx || SimData.ny*SimData.dy < WRFData.ny*WRFData.dy
    
    % Computing domain borders in meters
    
    XSTART_TERRAIN = SimData.CenterX - SimData.nx*SimData.dx/2; % In meters
    XEND_TERRAIN = SimData.CenterX + SimData.nx*SimData.dx/2;
    YSTART_TERRAIN = SimData.CenterY - SimData.ny*SimData.dy/2;
    YEND_TERRAIN = SimData.CenterY + SimData.ny*SimData.dy/2;
    
    XSTART_WRF = WRFData.CenterX - WRFData.nx*WRFData.dx/2;
    XEND_WRF = WRFData.CenterX + WRFData.nx*WRFData.dx/2;
    YSTART_WRF = WRFData.CenterY - WRFData.ny*WRFData.dy/2;
    YEND_WRF = WRFData.CenterY + WRFData.ny*WRFData.dy/2;
    
    % Finding WRF indices included in terrain domain
    
    IndWRF_X = [];
    IndWRF_Y = [];
    
    for i = 1:WRFData.nx % From XSTART_WRF to XEND_WRF then    
        if XSTART_WRF + (i-1)*WRFData.dx >= XSTART_TERRAIN && XSTART_WRF + (i-1)*WRFData.dx <= XEND_TERRAIN
            IndWRF_X = [IndWRF_X i];
        end        
    end
    
    for i = 1:WRFData.ny % From XSTART_WRF to XEND_WRF then    
        if YSTART_WRF + (i-1)*WRFData.dy >= YSTART_TERRAIN && YSTART_WRF + (i-1)*WRFData.dy <= YEND_TERRAIN
            IndWRF_Y = [IndWRF_Y i];
        end        
    end    
    
    % Corresponding terrain indices
    
    Xi_WRF = XSTART_WRF + (IndWRF_X-1).*WRFData.dx; % WRF X axis in meters
    Yi_WRF = YSTART_WRF + (IndWRF_Y-1).*WRFData.dy;
    
    IndTerrain_X = 1 + (Xi_WRF-XSTART_TERRAIN)./SimData.dx; % WRF indices on terrain grid
    IndTerrain_Y = 1 + (Yi_WRF-YSTART_TERRAIN)./SimData.dy;
    
    % Updating variables
    
    WRFData.XSTART = IndWRF_X(1); 
    WRFData.XEND = IndWRF_X(end);
    
    WRFData.XSTARTm = XSTART_WRF;
    WRFData.YSTARTm = YSTART_WRF;
    
    WRFData.YSTART = IndWRF_Y(1); 
    WRFData.YEND = IndWRF_Y(end);
    
    WRFData.CenterX = (XSTART_WRF + (IndWRF_X(1)-1)*WRFData.dx  +  XSTART_WRF + IndWRF_X(end)*WRFData.dx) / 2;
    WRFData.CenterY = (YSTART_WRF + (IndWRF_Y(1)-1)*WRFData.dy  +  YSTART_WRF + IndWRF_Y(end)*WRFData.dy) / 2;
    
    % Recording variables
    
    WRFData.IndWRF_X = IndWRF_X;
    WRFData.IndWRF_Y = IndWRF_Y;
    WRFData.XSTART = IndWRF_X(1);
    WRFData.YSTART = IndWRF_Y(1);
    WRFData.XEND = IndWRF_X(end);
    WRFData.YEND = IndWRF_Y(end);
    WRFData.nx = numel(IndWRF_X);
    WRFData.ny = numel(IndWRF_Y);
    
    SimData.IndTerrain_X = IndTerrain_X;
    SimData.IndTerrain_Y = IndTerrain_Y;
        
%     % Converting terrain domain corners coordinates in real coordinates
%     
%     XSTART_UTM = SimData.CenterX - SimData.nx*SimData.dx/2; XEND_UTM = XSTART_UTM + SimData.nx*SimData.dx;
%     YSTART_UTM = SimData.CenterY - SimData.ny*SimData.dy/2; YEND_UTM = YSTART_UTM + SimData.ny*SimData.dy;
%     
%     % And back again to WRF coordinates
%     
%     XSTART_WRF = ceil(WRFData.nx/2 - (WRFData.CenterX - XSTART_UTM)/WRFData.dx); XEND_WRF = floor(WRFData.nx/2 - (WRFData.CenterX - XEND_UTM)/WRFData.dx - 1);
%     YSTART_WRF = ceil(WRFData.ny/2 - (WRFData.CenterY - YSTART_UTM)/WRFData.dy); YEND_WRF = floor(WRFData.ny/2 - (WRFData.CenterY - YEND_UTM)/WRFData.dy - 1);
%     
%     % Updating variables
%     
%     WRFData.nx = XEND_WRF - XSTART_WRF +1;
%     WRFData.ny = YEND_WRF - YSTART_WRF +1;    
%     XDistCenter = XSTART_WRF  + (XEND_WRF - XSTART_WRF)/2 - (WRFData.XSTART + (WRFData.XEND - WRFData.XSTART)/2);
%     YDistCenter = YSTART_WRF  + (YEND_WRF - YSTART_WRF)/2 - (WRFData.YSTART + (WRFData.YEND - WRFData.YSTART)/2);
%     WRFData.DistCenter = [WRFData.dx*XDistCenter; WRFData.dy*YDistCenter]; 
%     
%     WRFData.CenterX = WRFData.CenterX + XDistCenter*WRFData.dx;
%     WRFData.CenterY = WRFData.CenterY + YDistCenter*WRFData.dy;
%     
%     WRFData.XSTART = XSTART_WRF; WRFData.XEND = XEND_WRF; 
%     WRFData.YSTART = YSTART_WRF; WRFData.YEND = YEND_WRF;
%    


%% Computing WRF sensors height (in meters) thanks to geopotential height %%

PHB = ncread(WRFFile,'PHB');
PHB = double(PHB(WRFData.XSTART:WRFData.XEND, WRFData.YSTART:WRFData.YEND, :, SimData.TIMEVECT));

PH = ncread(WRFFile,'PH');
PH = double(PH(WRFData.XSTART:WRFData.XEND, WRFData.YSTART:WRFData.YEND, :, SimData.TIMEVECT));

WRFData.Height = (PHB + PH)./9.81; % In meters


%% Recording land use categories %%

LU = ncread(WRFFile,'LU_INDEX');
WRFData.LU = LU(WRFData.XSTART:WRFData.XEND, WRFData.YSTART:WRFData.YEND,1); % Assuming it remains constant for all sims

