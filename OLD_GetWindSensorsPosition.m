function [SimData,WRFData] = SIM_OLD_GetWindSensorsPosition(SimData,WRFData)


%% Distance (in meters) between WRF and terrain domain centers %%

DistCenterAxeX = SimData.DistCenter(1) + DistLatLon_Meters([0,WRFData.CenterLon],[0,SimData.CenterLon]) - WRFData.DistCenter(1);
        
DistCenterAxeY = SimData.DistCenter(2) + DistLatLon_Meters([WRFData.CenterLat,0],[SimData.CenterLat,0]) - WRFData.DistCenter(2);


%% Computing sensors horizontal coordinates in WRF and terrain domains %%


SimData.DELTAxWest = double(DistCenterAxeX + (WRFData.nx*WRFData.dx)/2 - (SimData.nx*SimData.dx)/2 ); % Distance between left side of WRF grid and left side of terrain grid.
SimData.DELTAySouth = double(DistCenterAxeY + (WRFData.ny*WRFData.dy)/2 - (SimData.ny*SimData.dy)/2 ); % Distance between bottom side of WRF grid and bottom side of terrain grid.

WRFData.CoordX = [];
WRFData.CoordY = [];

if SimData.nx*SimData.ny*(SimData.dx/WRFData.dx)*(SimData.dy/WRFData.dy) <= SimData.NbStat  % If maximum number of station is reached, all of them will be used
    
    for x = 1:WRFData.nx
        for y = 1:WRFData.ny
            if x > SimData.DELTAxWest/WRFData.dx && x < (SimData.DELTAxWest+SimData.nx*SimData.dx)/WRFData.dx && ...
               y > SimData.DELTAySouth/WRFData.dy && y < (SimData.DELTAySouth+SimData.ny*SimData.dy)/WRFData.dy
                WRFData.CoordX = [WRFData.CoordX x];
                WRFData.CoordY = [WRFData.CoordY y];
            end
        end
    end
    fprintf('WARNING: Maximum station number available is: %.f \n', numel(WRFData.CoordX));
    
else
    
    STARTx = ceil(SimData.DELTAxWest/WRFData.dx);
    STARTy = ceil(SimData.DELTAySouth/WRFData.dy);
    
    ENDx = floor((SimData.DELTAxWest+SimData.nx*SimData.dx)/WRFData.dx);
    ENDy = floor((SimData.DELTAySouth+SimData.ny*SimData.dy)/WRFData.dy);
    
    STEPx = ceil((ENDx - STARTx)/round(sqrt(SimData.NbStat)));
    STEPy = ceil((ENDy - STARTy)/round(sqrt(SimData.NbStat)));
    
    for x = STARTx+round(STEPx/10):STEPx:ENDx %%% Sensor positions are shifted from grid edges by STEP/10
        for y = STARTy+round(STEPy/10):STEPy:ENDy
            WRFData.CoordX = [WRFData.CoordX x];
            WRFData.CoordY = [WRFData.CoordY y];
        end
    end
    if size([WRFData.CoordX;WRFData.CoordY],2) ~= SimData.NbStat %%% Sensors number is modified to assert a better distribution in respect with their positions.
        fprintf('WARNING : Number of stations has switched from %.f %s %.f\n', SimData.NbStat, 'to', numel(WRFData.CoordX))
    end
    
end

SimData.CoordX = round((WRFData.CoordX.*WRFData.dx - SimData.DELTAxWest)./SimData.dx);
SimData.CoordY = round((WRFData.CoordY.*WRFData.dy - SimData.DELTAySouth)./SimData.dy);

% ??? Averaging wind data sharing approximatively the same coordinate on terrain domain ??? %

% CoordX and CoordY at position 0 are removed %
IndCoordX_0 = find(SimData.CoordX == 0);
SimData.CoordX(IndCoordX_0) = [];
SimData.CoordY(IndCoordX_0) = [];
WRFData.CoordX(IndCoordX_0) = [];
WRFData.CoordY(IndCoordX_0) = [];

IndCoordY_0 = find(SimData.CoordY == 0);
SimData.CoordX(IndCoordY_0) = [];
SimData.CoordY(IndCoordY_0) = [];
WRFData.CoordX(IndCoordY_0) = [];
WRFData.CoordY(IndCoordY_0) = [];

SimData.NbStat = numel(SimData.CoordX);


%% Vertical position %%

WRFData.CoordZ = zeros(SimData.NbAlt, SimData.NbStat, numel(SimData.TIMEVECT));

for Alt = 1:SimData.NbAlt
    for Stat = 1:SimData.NbStat
        for Time = 1:numel(SimData.TIMEVECT)
            %%% Averaging altitude value at cell center
            WRFData.CoordZ(Alt,Stat,Time) = .5*(WRFData.SensorHeight(WRFData.CoordX(Stat),WRFData.CoordY(Stat),Alt,Time) + ...
                                                WRFData.SensorHeight(WRFData.CoordX(Stat),WRFData.CoordY(Stat),Alt+1,Time)) ...
                                              - SimData.Min;
        end
    end
end

% Deleting negative altitude coordinates %

WRFData.IndZ = (1:SimData.NbAlt)';

for Stat = 1:SimData.NbStat
    for Time = 1:numel(SimData.TIMEVECT)     
        IndZi = find(WRFData.CoordZ(:,Stat,Time) > 0);
        if size(IndZi,1) < size(WRFData.IndZ,1)
            WRFData.IndZ = IndZi;
            fprintf('WARNING : Number of sensors altitude information has switched from %.f %s %.f\n',SimData.NbAlt,'to', size(WRFData.IndZ,1))
        end        
    end
end

WRFData.CoordZ = WRFData.CoordZ(WRFData.IndZ,:,:);
SimData.NbAlt = size(WRFData.CoordZ,1);

% Deleting sensors closest to the ground %

for Stat = 1:SimData.NbStat
    for Time = 1:numel(SimData.TIMEVECT)
        
        IndZAlt = find(WRFData.CoordZ(:,Stat,Time) > MinAlt + SimData.Matrix(SimData.CoordY(Stat), SimData.CoordX(Stat)));
        
        if size(IndZAlt,1) < size(WRFData.IndZ,1)
            WRFData.IndZ = IndZAlt;
            fprintf('Station number %i',Stat)
            fprintf('WARNING : Number of sensors altitude information has switched from %.f %s %.f\n', SimData.NbAlt, 'to', size(WRFData.IndZ,1))
        end        
    end
end
        
WRFData.CoordZ = WRFData.CoordZ(WRFData.IndZ,:,:);
SimData.NbAlt = size(WRFData.CoordZ,1);

