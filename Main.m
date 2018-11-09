%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%                                                  %%%%%%%%%%%%
%%%%%%%%%%%%        WRF - QUIC ONE-WAY COUPLING SCRIPT        %%%%%%%%%%%%
%%%%%%%%%%%%                                                  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all; clc

%%% This script creates a project directory and the necessary files for a
%%% QUIC-URB simulation based on WRF data. Terrain, buildings and vegetation
%%% layer can also be added.


%% Flags and simulation settings %%

% QUIC-URB project name
ProjectName = 'Test';

% WRF output in netCDF format
SimData.WRFFile = 'RXCwrfout_d07_2012-11-11_15-21'; 

% Min WRF site altitude in meters AGL --- ! CHOOSE A MINIMUM ALTITUDE ABOVE CANOPY LAYER HEIGHT !
SimData.MinWRFAlt = 22;

% Max WRF site altitude in meters AGL 
SimData.MaxWRFAlt = 330;

% Number max of topography blocks
SimData.MaxTerrainSize = 10001;

% Number of WRF sites
SimData.MaxNbStat = 156; 

% Time moments in units provided by WRF file
SimData.TIMEVECT = (1:2);                         

TerrainFlag = 1;                       %%% 0 = No relief; 1 = W/ relief.
BdFlag = 0;                            %%% 0 = No buildings; 1 = Defined by the user.
VegFlag = 0;                           %%% 0 = No vegetation; 1 = Extracted from WRF.
Z0Flag = 2;                            %%% 1 = Extracted from WRF Restart File; 2 = Defined by WRF land use; 3 = Constant value.
SimData.Z0DataSource = SimData.WRFFile;            %%% If Z0Flag = 1, put WRF Restart File name; if Z0Flag = 2, put WRFOUTPUT FILE name; if Z0Flag = 3, put a CONSTANT VALUE.


%% Extracting WRF data  %%

fprintf('Reading WRF information\n')
SimData = ReadDomainInfo(SimData,Z0Flag);  % Domain borders can be modified by adding a varargin (expected format: [Xstart,Xend;YStart,Yend]).


%% Domain smoothing %% 

if SimData.nx*SimData.ny > SimData.MaxTerrainSize
    fprintf('Smoothing domain - ')
    SimData = Smooth(SimData);       
end


%% Minimizing cell number %%

fprintf('Lowering minimum altitude\n')
SimData = MinDomainHeight(SimData);


%% Selecting WRF data points %%

fprintf('Generating WRF wind data points\n')
[SimData,StatData] = SetWRFdataPt(SimData); 


%% Extracting building data %%

%BdFile = ''; % Building position defined on QUIC's terrain grid.    

if BdFlag > 0
    fprintf('Reading building information\n')
    BdData = ReadBDInfo(BdFile);
else
    BdData.List = [];
    BdData.NbBd = 0;
end
                       

%% Extracting vegetation data %%

VegData.NbVeg = 0;       %%% Do not modified. Will be computed in ReadVegInfo.

% VegData.LU{1} = ;      %%% Land-Use category as set by WRF netCDF output.
% VegData.Coeff{1} = ;   %%% Attenuation coefficient.
% VegData.Height{1} = ;  %%% Canopy layer height.
% 
% VegData.LU{2} = ;
% VegData.Coeff{2} = ;
% VegData.Height{2} = ;
% 
% VegData.LU{3} = ;
% VegData.Coeff{3} = ;
% VegData.Height{3} = ;
% 
% VegData.LU{4} = ;
% VegData.Coeff{4} = ;
% VegData.Height{4} = ;
% 
% ...

VegData = ReadVegInfo(SimData,VegData,VegFlag);


%% Writing output files %%

fprintf('Writing project %s\n', ProjectName)
WriteQUICFiles(SimData,StatData,BdData,VegData,TerrainFlag,ProjectName);


%% Saving variables for validation %%

DataToBeSaved = struct('SimData',SimData,'StatData',StatData);
        
filename = strcat(ProjectName,'_Data.mat');
        
save(filename, '-struct', 'DataToBeSaved')

