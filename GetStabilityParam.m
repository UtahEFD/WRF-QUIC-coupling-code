function GetStabilityParam()


TEMP = ncread(OUTER_Domain,'T') + 300 ; % WRF user guide def (could use base state temperature)
TEMP = TEMP(XSTART_OUTER:XEND_OUTER, YSTART_OUTER:YEND_OUTER, IndZ, TIMEVECT);
TEMP_SENSOR = zeros(NbAlt,NbStat,size(TIMEVECT,2));
for n = 1:NbStat
    TEMP_SENSOR(:,n,:) = TEMP(CoordXY_OUTER(1,n),CoordXY_OUTER(2,n),:,:);
end

%%%%% Gradient potential temperature %%%%%

% Get complete temperature profile at sensor position with linear interpolation

%%% PRENDRE EN COMPTE DIFFERENTS INSTANTS DANS LE TEMPS

%%% WE ASSUME THAT SURFACE TEMPERATURE IS EQUAL TO LOWER LEVEL AVAILABLE

HillHeight = 50; %%% Considered height above the ground, representing hill influence

Avg_Temp_Sensors = zeros(NbStat,1);
Avg_Grad_Temp_Sensors = zeros(NbStat,1);

for n = 1:NbStat    
    
    zmin = floor(min(CoordZ(:,n)));
    zmax = ceil(max(CoordZ(:,n))) - zmin + 1;
    
    temp = zeros(zmax,1);
    
    for k = 1:NbAlt-1
        
        Zstart = floor(CoordZ(k,n));
        Zend = ceil(CoordZ(k+1,n));
        
        for z = Zstart - zmin +1: Zend - zmin +1
            
            temp(z) = TEMP_SENSOR(k,n,:) + (z - Zstart) * ...
                (TEMP_SENSOR(k+1,n,:) - TEMP_SENSOR(k,n,:))/(Zend -Zstart);
        
        end
    end
    
    %%% On est seulement interesse par la moyenne a hauteur de la colline
    
    Avg_Temp_Sensors(n) = mean(temp(1:HillHeight)); 
    
    Avg_Grad_Temp_Sensors(n) = (temp(zmax) - temp(zmin)) / (zmax - zmin);
    
end

%%% FOR NOW TOTAL GRADIENT IS USED, NEGATIVE GRADIENT WILL LEAD TO NO EFFECT

Avg_Temp = mean(Avg_Temp_Sensors);
Avg_Grad_Temp = mean(Avg_Grad_Temp_Sensors);

%%%%% Global Brunt-Vaisala frequency %%%%%

if Avg_Grad_Temp >= 0
    N = sqrt(9.81*Avg_Grad_Temp/Avg_Temp);
else
    N = 0;
    fprintf('Unstable conditions, no Brunt Vaisala frequency available\n')
end

%%% RECORDED IN QU_SIMPARAMS.INP


%%% WIND VELOCITY SHOULD BE AVERAGED ONLY IN A CERTAIN APPROACH AREA TO BE DETERMINED

Avg_U_Approach = mean(mean(VELOC_SENSOR));

