function Z0 = RoughnessLengthFunc(SimData,Z0Flag)

% Computes a roughness length array covering each point of the grid
% In case 1 INPUT file must be WRF RESTART file
% In case 2 INPUT file must be WRF OUTPUT
% In case 3 INPUT variable is a constant value

switch Z0Flag
    
    case 1   %%% WRF RESTART file
        
        Z0 = ncread(SimData.Z0DataSource ,'Z0');
        Z0 = Z0(SimData.XSTART:SimData.XEND, SimData.YSTART:SimData.YEND)';
        
    case 2   %%% WRF OUTPUT file
        
        Z0 = zeros(size(SimData.LU,1),size(SimData.LU,2));
        
        for i = 1:size(SimData.LU,1)
            for j = 1:size(SimData.LU,2) 
                
                switch SimData.LU(i,j) 
                    
%%%%%%%%%%%%%%%%%%%%%%%%%     USGS LAND COVER     %%%%%%%%%%%%%%%%%%%%%%%%% 

%                     case 1   %%% Urban and built-up land
%                         Z0(i,j) = 0.8;
%                     case 2   %%% Dryland cropland and pasture
%                         Z0(i,j) = 0.15;
%                     case 3   %%% Irrigated cropland and pasture
%                         Z0(i,j) = 0.1;
%                     case 4   %%% Mixed dryland/irrigated cropland and pasture
%                         Z0(i,j) = 0.15;
%                     case 5   %%% Cropland/grassland mosaic
%                         Z0(i,j) = 0.14;
%                     case 6   %%% Cropland/woodland mosaic
%                         Z0(i,j) = 0.2;
%                     case 7   %%% Grassland
%                         Z0(i,j) = 0.12;
%                     case 8   %%% Shrubland
%                         Z0(i,j) = 0.05;
%                     case 9   %%% Mixed shrubland/grassland
%                         Z0(i,j) = 0.06;
%                     case 10   %%% Savanna
%                         Z0(i,j) = 0.15;
%                     case 11   %%% Deciduous broadleaf forest
%                         Z0(i,j) = 0.5;
%                     case 12   %%% Deciduous needleleaf forest
%                         Z0(i,j) = 0.5;
%                     case 13   %%% Evergreeen broadleaf forest
%                         Z0(i,j) = 0.5;
%                     case 14   %%% Evergreen needleleaf forest
%                         Z0(i,j) = 0.5;
%                     case 15   %%% Mixed forest
%                         Z0(i,j) = 0.5;
%                     case 16   %%% Water bodies
%                         Z0(i,j) = 0.0001;
%                     case 17   %%% Herbaceous wetland
%                         Z0(i,j) = 0.2;
%                     case 18   %%% Wooded wetland
%                         Z0(i,j) = 0.4;
%                     case 19   %%% Barren or sparsely vegetated
%                         Z0(i,j) = 0.01;
%                     case 20   %%% Herbaceous tundra
%                         Z0(i,j) = 0.1;
%                     case 21   %%% Wooded tundra
%                         Z0(i,j) = 0.3;
%                     case 22   %%% Mixed tundra
%                         Z0(i,j) = 0.15;
%                     case 23   %%% Bare ground tundra
%                         Z0(i,j) = 0.1;
%                     case 24   %%% Snow or ice
%                         Z0(i,j) = 0.001;

%%%%%%%%%%%%%%%%%%%%%%%%%      MODIS-WINTER      %%%%%%%%%%%%%%%%%%%%%%%%%%

                    case 1   %%% Evergreen needleleaf forest
                        Z0(i,j) = 0.5;
                    case 2   %%% Evergreeen broadleaf forest
                        Z0(i,j) = 0.5;
                    case 3   %%% Deciduous needleleaf forest
                        Z0(i,j) = 0.5;
                    case 4   %%% Deciduous broadleaf forest
                        Z0(i,j) = 0.5;
                    case 5   %%% Mixed forests
                        Z0(i,j) = 0.5;
                    case 6   %%% Closed Shrublands
                        Z0(i,j) = 0.1;
                    case 7   %%% Open Shrublands
                        Z0(i,j) = 0.1;
                    case 8   %%% Woody Savannas
                        Z0(i,j) = 0.15;
                    case 9   %%% Savannas
                        Z0(i,j) = 0.15;
                    case 10   %%% Grasslands
                        Z0(i,j) = 0.075;
                    case 11   %%% Permanent wetlands
                        Z0(i,j) = 0.3;
                    case 12   %%% Croplands
                        Z0(i,j) = 0.075;
                    case 13   %%% Urban and built-up land
                        Z0(i,j) = 0.5;
                    case 14   %%% Cropland/natural vegetation mosaic
                        Z0(i,j) = 0.065;
                    case 15   %%% Snow or ice
                        Z0(i,j) = 0.01;
                    case 16   %%% Barren or sparsely vegetated
                        Z0(i,j) = 0.065;
                    case 17   %%% Water
                        Z0(i,j) = 0.0001;
                    case 18   %%% Wooded tundra
                        Z0(i,j) = 0.15;
                    case 19   %%% Mixed tundra
                        Z0(i,j) = 0.1;
                    case 20   %%% Barren tundra
                        Z0(i,j) = 0.06;
                    case 21   %%% Lakes
                        Z0(i,j) = 0.0001;
                end
            end
        end
        
    case 3   %%% User-defined constant
        
        Z0 = repmat(SimData.Z0DataSource, SimData.XEND-SimData.XSTART+1, SimData.YEND-SimData.YSTART+1)';
end
