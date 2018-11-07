function SimData = ReadDomainInfo(SimData,Z0Flag,varargin)

% Read domain dimensions, terrain elevation, wind data, land-use and Z0 from WRF output. 
% Possibility to crop domain borders by adding a varargin (expected format: [Xstart,Xend;YStart,Yend]).
% Layers of data are recorder in the following format: (row,col) = (ny,nx).

WRFFile = SimData.WRFFile;
SimData.Clock = ncread(WRFFile,'Times'); % Time in vector format


%% Domain definition %%

SimData.XSTART = 1;
SimData.XEND = double(ncreadatt(WRFFile,'/','WEST-EAST_GRID_DIMENSION'))-1;

SimData.YSTART = 1;
SimData.YEND = double(ncreadatt(WRFFile,'/','SOUTH-NORTH_GRID_DIMENSION'))-1;

SimData.nx = SimData.XEND - SimData.XSTART +1;
SimData.ny = SimData.YEND - SimData.YSTART +1;

SimData.dx = double(ncreadatt(WRFFile,'/','DX'));
SimData.dy = double(ncreadatt(WRFFile,'/','DY'));

% If new domain borders are defined
if nargin == 3 
        
    NewDomainCorners = varargin{1};
    
    XSTART_New = NewDomainCorners(1,1); XEND_New = NewDomainCorners(1,2); 
    YSTART_New = NewDomainCorners(2,1); YEND_New = NewDomainCorners(2,2);
    
    SimData.nx = XEND_New - XSTART_New +1;
    SimData.ny = YEND_New - YSTART_New +1; 
    
    SimData.OLD_XSTART = SimData.XSTART; SimData.OLD_XEND = SimData.XEND;
    SimData.OLD_YSTART = SimData.YSTART; SimData.OLD_YEND = SimData.YEND;
        
    SimData.XSTART = XSTART_New; SimData.XEND = XEND_New;
    SimData.YSTART = YSTART_New; SimData.YEND = YEND_New;
      
end


%% Recording data in format: (row,col) = (ny,nx) %%

% Terrain topography
Relief = ncread(WRFFile,'HGT');
SimData.Relief = Relief(SimData.XSTART:SimData.XEND,SimData.YSTART:SimData.YEND,1)'; 

% Wind data    
SimData = WindFunc(SimData); 

% Land-use 
LU = ncread(WRFFile,'LU_INDEX');
SimData.LU = LU(SimData.XSTART:SimData.XEND, SimData.YSTART:SimData.YEND,1)'; 

% Roughness length
SimData.Z0 = RoughnessLengthFunc(SimData,Z0Flag); 

