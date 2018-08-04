function WRFData = GetWindSensorsVeloc_Dir(SimData,WRFData,WRFFile)


%% Reading WRF file %%

U_staggered = ncread(WRFFile,'U');
U_staggered = U_staggered(WRFData.XSTART:WRFData.XEND +1, WRFData.YSTART:WRFData.YEND, WRFData.IndZ, SimData.TIMEVECT); %%% Vertical coordinate indexed on IndZ in case of negative altitude correction
U = zeros(WRFData.nx, WRFData.ny, SimData.NbAlt, numel(SimData.TIMEVECT));
for x = 1:WRFData.nx
    U(x,:,:,:) = .5*(U_staggered(x,:,:,:) + U_staggered(x+1,:,:,:)); %%% U value is approximated at cell center
end

V_staggered = ncread(WRFFile,'V');
V_staggered = V_staggered(WRFData.XSTART:WRFData.XEND, WRFData.YSTART:WRFData.YEND +1, WRFData.IndZ, SimData.TIMEVECT);
V = zeros(WRFData.nx, WRFData.ny, SimData.NbAlt, numel(SimData.TIMEVECT));
for y = 1:WRFData.ny   
    V(:,y,:,:) = .5*(V_staggered(:,y,:,:) + V_staggered(:,y+1,:,:)); %%% V value is approximated at cell center
end


%% Wind velocity %%

VELOC = sqrt(U.^2 + V.^2);
WRFData.VELOC_SENSOR = zeros(SimData.NbAlt, SimData.NbStat, numel(SimData.TIMEVECT));  

for Stat = 1:SimData.NbStat
    WRFData.VELOC_SENSOR(:,Stat,:) = VELOC(WRFData.CoordX(Stat),WRFData.CoordY(Stat),:,:); %%% Velocity at sensor position
end


%% Wind direction %%

DIR = zeros(WRFData.nx,WRFData.ny,SimData.NbAlt,numel(SimData.TIMEVECT));

for x = 1:WRFData.nx
    for y = 1:WRFData.ny
        for Alt = 1:SimData.NbAlt
            for Time = 1:numel(SimData.TIMEVECT)
                if U(x,y,Alt) > 0
                    DIR(x,y,Alt,Time) = 270-(180/pi)*atan(V(x,y,Alt,Time)/U(x,y,Alt,Time)); %%% Converting wind direction in QUIC coordinates
                else
                    DIR(x,y,Alt,Time) = 90-(180/pi)*atan(V(x,y,Alt,Time)/U(x,y,Alt,Time));
                end
            end
        end
    end
end

WRFData.DIR_SENSOR = zeros(SimData.NbAlt, SimData.NbStat, numel(SimData.TIMEVECT));

for Stat = 1:SimData.NbStat
    WRFData.DIR_SENSOR(:,Stat,:) = DIR(WRFData.CoordX(Stat), WRFData.CoordY(Stat),:,:); %%% Direction at sensor position
end

