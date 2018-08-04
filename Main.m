%%%%%%%%%%%%                                                  %%%%%%%%%%%%
%%%%%%%%%%%%        WRF - QUIC ONE-WAY COUPLING SCRIPT        %%%%%%%%%%%%
%%%%%%%%%%%%                                                  %%%%%%%%%%%%

clear; close all; clc

%%% This script creates a project directory and the necessary files for a
%%% QUIC-URB simulation based on WRF data as wind data input. Terrain,
%%% buildings and vegetation layer can also be added.

ProjectName = 'Test';


%% Flags and simulation settings %%

WRFFile = 'RXCwrfout_d07_2012-11-11_15-21';

MinWRFAlt = 00; % Min sensor altitude
MaxWRFAlt = 200;% Max sensor altitude 

SimData.TerrainFile = WRFFile;

MaxTerrainSize = 40000;     %%% Triggers a domain averaging script in case of too many terrain cells
SimData.NbStat = 500;       %%% Number of WRF sensors
SimData.TIMEVECT = (1);     %%% Simulation time moments in units provided by WRF file

StretchFlag = 0;            %%% 0 = Uniform vertical resolution; 1 = Stretched vertical grid fitting with WRF levels
TerrainTypeFlag = 1;        %%% 1 = WRF; 2 = GEOTIFF 
TerrainFlag = 1;            %%% 0 = No relief; 1 = W/ relief
BdFlag = 0;                 %%% 0 = No buildings; 1 = Defined by the user
VegFlag = 0;                %%% 0 = No vegetation; 1 = Defined by the user; 2 = Extracted from WRF
Z0Flag = 3;                 %%% 1 = Extracted from WRF restart; 2 = Defined by WRF land use; 3 = Constant value
Z0DataSource = 0.1;         %%% If Z0FLAG = 1, put WRF RESTART FILE name; if Z0FLAG = 2, put WRFOUTPUT FILE name; if Z0FLAG = 3, put a CONSTANT VALUE

%BdFile = ''; % Building position as defined on QUIC's terrain grid    

%% Extracting terrain information %%

fprintf('Reading terrain information\n')    
SimData = ReadTerrainInfo(SimData,MaxTerrainSize,TerrainTypeFlag); % Domain borders can be modified by adding a varargin

Z0 = RoughnessLengthFunction(SimData,Z0DataSource,Z0Flag);


%% Extracting WRF data  %%

fprintf('Reading WRF information\n')
[SimData,WRFData] = ReadWRFInfo(SimData,WRFFile);


%% Computing wind data %%

fprintf('Computing wind sensors horizontal and vertical positions\n')
[SimData,WRFData] = GetWindSensorsPosition(SimData,WRFData,MinWRFAlt,MaxWRFAlt);

fprintf('Computing wind sensors velocity and direction\n')
WRFData = GetWindSensorsVeloc_Dir(SimData,WRFData,WRFFile);


%% Extracting buildings information %%

if BdFlag >0
    BdData = ReadBDInfo(BdFile);
else
    BdData.List = [];
    BdData.NbBd = 0;
end
                       

%% Extracting vegetation information %%

% User-defined vegetation coverage

% VegData.Lim{1} = [15,30,50,40; 20,10,15,35];
% VegData.Lim{2} = [];

% VegData.Coeff{1} = 2;
% VegData.Coeff{2} = ;

% VegData.Height{1} = 15;
% VegData.Height{2} = ;

% WRF vegetation coverage

VegData.LU{1} = 8;        % Vegetation identified by WRF land use number
VegData.LU{2} = 18;
VegData.LU{3} = 14;
VegData.LU{4} = 7;        % Virtual trees

VegData.Coeff{1} = 1.7;     % Cionco 72 & Bradley for tall forest att. coeff. ref
VegData.Coeff{2} = 1.7;
VegData.Coeff{3} = 1.7;
VegData.Coeff{4} = 0.5;

VegData.Height{1} = 22;   % Info from Brian's LIDAR results ~20-25m
VegData.Height{2} = 22;
VegData.Height{3} = 22;
VegData.Height{4} = 2;

VegData = ReadVegInfo(VegData, WRFData, VegFlag);

        
%% Stability conditions %%

%GetStabilityParam();


%% Writing output files %%

fprintf('Writing project %s\n', ProjectName)

WriteQUICFiles(SimData,WRFData,BdData,VegData,Z0,StretchFlag,TerrainTypeFlag,ProjectName)

DataToBeSaved = struct('SimData',SimData,'WRFData',WRFData, 'VEGData', VegData);
        
filename = strcat(ProjectName,'Data.mat');
        
save(filename, '-struct', 'DataToBeSaved')

