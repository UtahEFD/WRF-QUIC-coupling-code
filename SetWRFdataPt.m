function [SimData,StatData] = SetWRFdataPt(SimData)

% If MaxNbStat is smaller than the number of WRF data point available, then
% we operate a selection. Vertical height is selected between defined boundaries.
% For each stations, their horizontal and vertical coordinates, wind speed 
% and direction, along with the number of vertical altitude pts, are recorded 

if SimData.nx*SimData.ny > SimData.MaxNbStat
    
    nx2 = sqrt(SimData.MaxNbStat*SimData.nx/SimData.ny);
    ny2 = sqrt(SimData.MaxNbStat*SimData.ny/SimData.nx);
    
    WRF_RowY = (1:SimData.ny/ny2:SimData.ny);
    WRF_ColX = (1:SimData.nx/nx2:SimData.nx);
    
    WRF_RowY = unique(round(WRF_RowY));
    WRF_ColX = unique(round(WRF_ColX));
    
else
    
    WRF_RowY = (1:SimData.ny);
    WRF_ColX = (1:SimData.nx);
    
end

SimData.NbStat = numel(WRF_RowY)*numel(WRF_ColX);
StatData.CoordX = zeros(1,SimData.NbStat);
StatData.CoordY = zeros(1,SimData.NbStat);
StatData.nz = zeros(1,SimData.NbStat);

StatData.CoordZ = struct([]);
StatData.WS = struct([]);
StatData.WD = struct([]);


Stat = 1;
for y = WRF_RowY
    for x = WRF_ColX
        
        StatData.CoordX(Stat) = x;
        StatData.CoordY(Stat) = y;
        
        levelk_max = 0;
        for t = 1:numel(SimData.TIMEVECT)                     
            CoordZ_xyt = SimData.CoordZ(y,x,:,t);        
            [levelk] = find(CoordZ_xyt >= SimData.MinWRFAlt & CoordZ_xyt <= SimData.MaxWRFAlt);
            if numel(levelk) > numel(levelk_max)
                levelk_max = levelk; % If wind data heights change during time, higher height vector is selected
            end
        end
        
        StatData.CoordZ{Stat} = reshape(SimData.CoordZ(y,x,levelk_max,:),numel(levelk_max),size(SimData.CoordZ,4));
        StatData.nz(Stat) = size(StatData.CoordZ{Stat},1);
        
        StatData.WS{Stat} = reshape(SimData.WS(y,x,levelk_max,:),numel(levelk_max),size(SimData.WS,4));
        StatData.WD{Stat} = reshape(SimData.WD(y,x,levelk_max,:),numel(levelk_max),size(SimData.WD,4));   
        
        Stat = Stat + 1;
    end
end

SimData.maxCoordz = 0; % Will be used to set domain vertical dimension
for i = 1:SimData.NbStat
    SimData.maxCoordz = max(max(max(SimData.maxCoordz,StatData.CoordZ{i})));
end

fprintf('%i %s\n',SimData.NbStat,' WRF data points have been generated')

