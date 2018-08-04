function WriteSENSOR(SimData,WRFData,Z0,ProjectDir)

%%% INPUT: Clock - Wind measurements time values, TIMEVECT - Sim time vector,
%%% NbStat - Number of sensors, CoordXY - Sensor grid coordinate,
%%% CoordZ - Altitude level with available wind data, VELOC_SENSOR - Measured wind magnitude,
%%% DIR_SENSOR - Measured wind direction, d - Resolution along one axe,
%%% Z0 - Roughness length on each grid point, ProjectDir - Project directory

SiteCoordFlag = 1; %%% 1=QUIC, 2=UTM, 3=Lat/Lon
SiteBdLayer = 4;   %%% 1 = log, 2 = exp, 3 = urban canopy, 4 = discrete data points
InvMOL = 0;        %%% Reciprocal Monin-Obukhov Length (1/m), used for log profile site boundary layer

for Stat = 1:SimData.NbStat    
    fid = fopen([ProjectDir 'sensor' num2str(Stat) '.inp'],'w');
    fprintf(fid,'%s\t!Site name\n', ['sensor' num2str(Stat) '.inp']);
    fprintf(fid,'%i\t!Site Coordinate Flag (1=QUIC, 2=UTM, 3=Lat/Lon)\n', SiteCoordFlag);
    fprintf(fid,'%g\t!X coordinate (meters)\n', SimData.CoordX(Stat)*SimData.dx);
    fprintf(fid,'%g\t!Y coordinate (meters)\n', SimData.CoordY(Stat)*SimData.dy);
    
    for Time = 1:size(SimData.TIMEVECT,2)        
        fprintf(fid,'%.0f\t!Begining of time step in Unix Epoch time (integer seconds since 1970/1/1 00:00:00)\n', UTC2epoch(WRFData.Clock(:,SimData.TIMEVECT(Time))') );
        fprintf(fid,'%i\t!site boundary layer flag (1 = log, 2 = exp, 3 = urban canopy, 4 = discrete data points)\n', SiteBdLayer);
        fprintf(fid,'%g\t!site zo\n', Z0( round(SimData.CoordX(Stat)), round(SimData.CoordY(Stat)) ));
        
        if SiteBdLayer == 1
            fprintf(fid,'%g!reciprocal Monin-Obukhov Length (1/m) \n', InvMOL);
        elseif SiteBdLayer == 4            
            fprintf(fid,'%g %s \n', size(WRFData.CoordZ,1), '!enter number of wind speed data points');
        end
        
        fprintf(fid,'!Height (m),Speed (m/s), Direction (deg relative to true N)\n');
        
        for Alt = 1:SimData.NbAlt
            fprintf(fid,'%g %g %g \n', WRFData.CoordZ(Alt,Stat), WRFData.VELOC_SENSOR(Alt,Stat,Time), WRFData.DIR_SENSOR(Alt,Stat,Time));
        end
    end
    fclose(fid);    
end