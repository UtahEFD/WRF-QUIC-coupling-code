function WriteQU_SIMPARAMS(SimData,WRFData,ProjectDir,StretchFlag)

version = 6.1;
TotalTimeIncr = numel(SimData.TIMEVECT);
UTCconversion = 0;

RooftopFlag = 0;             %%% (0-none, 1-log profile, 2-vortex)
UpwindFlag = 0;              %%% (0-none, 1-Rockle, 2-MVP, 3-HMVP)
StreetCanyonFlag = 0;        %%% (0-none, 1-Roeckle, 2-CPB, 3-exp. param. PKK, 4-Roeckle w/ Fackrel)
StreetIntersecFlag = 0;      %%% (0-off, 1-on)
WakeFlag = 0;                %%% (0-none, 1-Rockle, 2-Modified Rockle, 3-Area Scaled)
SidewallFlag = 0;            %%% (0-off, 1-on)
QUICCFDFlag = 0;
ExploBdDamageFlag = 0;
BdArrayFlag = 0;

MaxIter = 500;
ResidualReduc = 3;
DiffusionFlag = 0;
DiffusionIter = 20;

DomainRotation = 0;
UTMXorigin = 0.0;
UTMYorigin = 0.0;
UTMzone = 1;
UTMletter = 17;

fid = fopen([ProjectDir 'QU_simparams.inp'],'w');

fprintf(fid,'!QUIC %g\n', version);
fprintf(fid, '%.0f\t!nx - Domain Length(X) Grid Cells\n', SimData.nx);
fprintf(fid, '%.0f\t!ny - Domain Width(Y) Grid Cells\n', SimData.ny);

switch StretchFlag    
    case 0        
        fprintf(fid, '%i\t!nz - Domain Height(Z) Grid Cells\n', round(1.2*max(max(max(WRFData.CoordZ))))); %%% Sim height has to be greater than sensors max altitude %%%
        fprintf(fid, '%i\t!dx (meters)\n', SimData.dx);        
        fprintf(fid, '%i\t!dy (meters)\n', SimData.dy);        
        fprintf(fid, '%i\t!Vertical stretching flag(0=uniform,1=custom,2=parabolic Z,3=parabolic DZ,4=exponential) \n', StretchFlag);
        fprintf(fid, '%i\t!dz (meters)\n', 1);        
    case 1
        if SimData.max == 0
            SimData.max = round(mean(mean(WRFData.CoordZ(1,:)))); %%% Virtually increases maximum height to allow vertical stretching grid process to work.
        end
        
        N = find(round(SimData.max)<= round(mean(WRFData.CoordZ,2))); %%% Number of sensors altitude under maximum relief altitude
        
        fprintf(fid, '%i\t!nz - Domain Height(Z) Grid Cells \n', round(SimData.max) + size(N,1) + 5);        
        fprintf(fid, '%i\t!dx (meters)\n', SimData.dx);        
        fprintf(fid, '%i\t!dy (meters)\n', SimData.dy);        
        fprintf(fid, '%i\t!Vertical stretching flag(0=uniform,1=custom,2=parabolic Z,3=parabolic DZ,4=exponential) \n', StretchFlag);       
        fprintf(fid, '%s \n', '!dz array (meters)');
        
        DZ_ARRAY = zeros(round(SimData.max)+size(N,1),1);       
        
        for  i = 1:round(SimData.max) %%% Vertical resolution set to 1 below maximum terrain elevation
            DZ_ARRAY(i) = 1.000000;
            fprintf(fid, '%i \n', DZ_ARRAY(i));
        end
        
        DZ_ARRAY(1+round(SimData.max)) = 2*(WRFData.CoordZ(N(1)) - round(SimData.max)+0.5)-DZ_ARRAY(round(SimData.max));
        
        fprintf(fid, '%i \n', DZ_ARRAY(1+round(SimData.max))); %%% Transition term between vertical resolution set to 1 and stretched resolution
        
        for i = 2 : size(N,1) %%% Vertical resolution is computed so that considered altitudes are based on CoordZ vector   
            DZ_ARRAY(i+round(SimData.max)) = 2*(WRFData.CoordZ(N(i)) - WRFData.CoordZ(N(i-1)))-DZ_ARRAY(i+round(SimData.max)-1);
            fprintf(fid, '%i \n', DZ_ARRAY(i+round(SimData.max)));
        end
        
        for i =1:5
            fprintf(fid, '%i \n',20.00000); %%% Simulation max height should be greater than sensor max altitude, 100 meters are added with a 20 m resolution%%%
        end            
end

fprintf(fid, '%i\t!total time increments\n', TotalTimeIncr);
fprintf(fid, '%i\t!UTC conversion\n', UTCconversion);
fprintf(fid, '!Begining of time step in Unix Epoch time (integer seconds since 1970/1/1 00:00:00)\n');
for t = SimData.TIMEVECT
    fprintf(fid, '%i \n', UTC2epoch(WRFData.Clock(:,t)'));
end
fprintf(fid, '%i\t!rooftop flag (0-none, 1-log profile, 2-vortex)\n', RooftopFlag);
fprintf(fid, '%i\t!upwind cavity flag (0-none, 1-Rockle, 2-MVP, 3-HM    VP)\n', UpwindFlag);
fprintf(fid, '%i\t!street canyon flag (0-none, 1-Roeckle, 2-CPB, 3-exp. param. PKK, 4-Roeckle w/ Fackrel)\n', StreetCanyonFlag);
fprintf(fid, '%i\t!street intersection flag (0-off, 1-on)\n', StreetIntersecFlag);
fprintf(fid, '%i\t!wake flag (0-none, 1-Rockle, 2-Modified Rockle, 3-Area Scaled)\n',WakeFlag);
fprintf(fid, '%i\t!sidewall flag (0-off, 1-on)\n', SidewallFlag);
fprintf(fid, '%i\t!Maximum number of iterations\n', MaxIter);
fprintf(fid, '%i\t!Residual Reduction (Orders of Magnitude)\n', ResidualReduc);
fprintf(fid, '%i\t!Use Diffusion Algorithm (1 = on)\n', DiffusionFlag);
fprintf(fid, '%i\t!Number of Diffusion iterations\n', DiffusionIter);
fprintf(fid, '%i\t!Domain rotation relative to true north (cw = +)\n', DomainRotation);
fprintf(fid, '%g\t!UTMX of domain origin (m)\n', UTMXorigin);
fprintf(fid, '%g\t!UTMY of domain origin (m)\n', UTMYorigin);
fprintf(fid, '%i\t!UTM zone\n', UTMzone);
fprintf(fid, '%i\t!UTM zone leter (1=A,2=B,etc.)\n', UTMletter);
fprintf(fid, '%i\t!QUIC-CFD Flag\n', QUICCFDFlag);
fprintf(fid, '%i\t!Explosive building damage flag (1 = on)\n', ExploBdDamageFlag);
fprintf(fid, '%i\t!Building Array Flag (1 = on)\n', BdArrayFlag);

fclose(fid);