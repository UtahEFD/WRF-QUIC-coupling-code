function [SimData,WRFData] = GetWindSensorsPosition(SimData,WRFData,MinWRFAlt, MaxWRFAlt)


%% Computing sensors horizontal coordinates in WRF and terrain domains %%

% in WRF Coordinates

if WRFData.nx*WRFData.ny <= SimData.NbStat  % If maximum number of station is reached, all of them will be used    
    [WRFData.CoordX, WRFData.CoordY] = reshaperepmat((1:WRFData.nx),(1:WRFData.ny));
    fprintf('WARNING: Maximum station number available is: %.f \n', numel(WRFData.CoordX));    
else    
    STEPX = round((WRFData.nx - 1)/sqrt(SimData.NbStat));
    STEPY = round((WRFData.ny - 1)/sqrt(SimData.NbStat)); 
    [WRFData.CoordX, WRFData.CoordY] = reshaperepmat((1:STEPX:WRFData.nx),(1:STEPY:WRFData.ny));
    if numel(WRFData.CoordX) ~= SimData.NbStat % Sensors number is modified to assert a better distribution in respect with their positions.
        fprintf('WARNING : Number of stations has changed from %.f %s %.f\n', SimData.NbStat, 'to', numel(WRFData.CoordX))
    end    
end

SimData.NbStat = numel(WRFData.CoordX);

% in Terrain coordinates

SimData.CoordX = SimData.IndTerrain_X(WRFData.CoordX);
SimData.CoordY = SimData.IndTerrain_Y(WRFData.CoordY);


%% Vertical position %%

WRFData.CoordZ = zeros(size(WRFData.Height,3), SimData.NbStat, numel(SimData.TIMEVECT));

for Alt = 1:size(WRFData.Height,3)-1
    for Stat = 1:SimData.NbStat
        for Time = 1:numel(SimData.TIMEVECT)
            %%% Averaging altitude value at cell center
            WRFData.CoordZ(Alt,Stat,Time) = (WRFData.Height(WRFData.CoordX(Stat),WRFData.CoordY(Stat),Alt,Time) + ...
                                             WRFData.Height(WRFData.CoordX(Stat),WRFData.CoordY(Stat),Alt+1,Time))/2 - SimData.Min;
        end
    end
end


% %% Deleting negative altitude coordinates %%
% 
% WRFData.IndZ = (1:SimData.NbAlt)';
% 
% for Stat = 1:SimData.NbStat
%     for Time = 1:numel(SimData.TIMEVECT)
%         IndZi = find(WRFData.CoordZ(:,Stat,Time) > 0); % Need to be done relatively to SimData.Matrix
%         if size(IndZi,1) < size(WRFData.IndZ,1)
%             WRFData.IndZ = IndZi;
%             fprintf('Stat %i %s %i\n',Stat,' Time',Time) 
%             fprintf('WARNING : Number of sensors altitude information has changed from %.f %s %.f\n',SimData.NbAlt,'to', size(WRFData.IndZ,1))
%         end        
%     end
% end
% 
% WRFData.CoordZ = WRFData.CoordZ(WRFData.IndZ,:,:);
% SimData.NbAlt = size(WRFData.CoordZ,1);
 

%% Deleting sensors close to the ground %%

IndZAlt = cell(SimData.NbStat,numel(SimData.TIMEVECT));

for Stat = 1:SimData.NbStat
    for Time = 1:numel(SimData.TIMEVECT)        
        IndZAlt{Stat,Time} = find( WRFData.CoordZ(:,Stat,Time) >= MinWRFAlt + SimData.Matrix(round(SimData.CoordY(Stat)),round(SimData.CoordX(Stat))) ...
                                 & WRFData.CoordZ(:,Stat,Time) <= MaxWRFAlt + SimData.Matrix(round(SimData.CoordY(Stat)),round(SimData.CoordX(Stat))) );
                             
    end
end

WRFData.IndZ = IndZAlt{1,:};

for Stat = 1:SimData.NbStat
    for Time = 1:numel(SimData.TIMEVECT)
        WRFData.IndZ = intersect(IndZAlt{Stat,Time},WRFData.IndZ);
        if isempty(WRFData.IndZ)
            fprintf([num2str(Stat) '\n'])
        end
    end
end

WRFData.CoordZ = WRFData.CoordZ(WRFData.IndZ,:,:);

SimData.NbAlt = numel(WRFData.IndZ);

fprintf(['Wind data is extracted between ' num2str(min(min(min(WRFData.CoordZ)))) ' and ' num2str(max(max(max(WRFData.CoordZ)))) ' meters AGL \n'])

