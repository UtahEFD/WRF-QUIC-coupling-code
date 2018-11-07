function WriteSENSOR(SimData,StatData,ProjectDir)

SiteCoordFlag = 1; %%% 1=QUIC, 2=UTM, 3=Lat/Lon
InvMOL = 0;        %%% Reciprocal Monin-Obukhov Length (1/m), used for log profile site boundary layer

for Stat = 1 : SimData.NbStat
    
    fid = fopen([ProjectDir 'sensor' num2str(Stat) '.inp'],'w');
    fprintf(fid,'%s\t!Site name\n', ['sensor' num2str(Stat) '.inp']);
    fprintf(fid,'%i\t!Site Coordinate Flag (1=QUIC, 2=UTM, 3=Lat/Lon)\n', SiteCoordFlag);
    fprintf(fid,'%g\t!X coordinate (meters)\n', StatData.CoordX(Stat)*SimData.dx);
    fprintf(fid,'%g\t!Y coordinate (meters)\n', StatData.CoordY(Stat)*SimData.dy);
    
    for Time = 1:numel(SimData.TIMEVECT)
        fprintf(fid,'%.0f\t!Begining of time step in Unix Epoch time (integer seconds since 1970/1/1 00:00:00)\n', UTC2epoch(SimData.Clock(:,SimData.TIMEVECT(Time))') );
        if StatData.nz(Stat) == 1
            SiteBdLayer = 1; %%% 1 = log, 2 = exp, 3 = urban canopy, 4 = discrete data points
        else
            SiteBdLayer = 4;
        end
        fprintf(fid,'%i\t!site boundary layer flag (1 = log, 2 = exp, 3 = urban canopy, 4 = discrete data points)\n', SiteBdLayer);
        fprintf(fid,'%g\t!site zo\n', SimData.Z0(StatData.CoordY(Stat),StatData.CoordX(Stat)));
        
        if SiteBdLayer == 1
            fprintf(fid,'%g!reciprocal Monin-Obukhov Length (1/m) \n', InvMOL);
        elseif SiteBdLayer == 4
            fprintf(fid,'%g %s \n', StatData.nz(Stat), '!enter number of wind speed data points');
        end
        
        fprintf(fid,'!Height (m),Speed (m/s), Direction (deg relative to true N)\n');
        
        for Alt = 1:StatData.nz(Stat)
            fprintf(fid,'%g %g %g \n',StatData.CoordZ{Stat}(Alt,Time),StatData.WS{Stat}(Alt,Time),StatData.WD{Stat}(Alt,Time));
        end
    end
    
end

fclose(fid);