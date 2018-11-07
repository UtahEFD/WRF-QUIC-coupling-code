function SimData = WindFunc(SimData)

% This function computes velocity magnitude, direction and vertical
% coordinates from WRF velocity components U,V and geopotential height.
% Values are interpolated at each corresponding cell center.


%% Extraction %%
% Wind data vertical position
PHB = ncread(SimData.WRFFile,'PHB');
PHB = double(PHB(SimData.XSTART:SimData.XEND, SimData.YSTART:SimData.YEND, :, SimData.TIMEVECT));

PH = ncread(SimData.WRFFile,'PH');
PH = double(PH(SimData.XSTART:SimData.XEND, SimData.YSTART:SimData.YEND, :, SimData.TIMEVECT));

Height = (PHB + PH)./9.81; % Converting to meters
SimData.NbAlt = size(Height,3) - 1;

% Wind components
Ustagg = ncread(SimData.WRFFile,'U');
Ustagg = Ustagg(SimData.XSTART:SimData.XEND +1, SimData.YSTART:SimData.YEND, :, SimData.TIMEVECT);

Vstagg = ncread(SimData.WRFFile,'V');
Vstagg = Vstagg(SimData.XSTART:SimData.XEND, SimData.YSTART:SimData.YEND +1, :, SimData.TIMEVECT);


%% Centering values %%

SimData.NbAlt = size(Height,3) - 1;

U = zeros(SimData.nx,SimData.ny,SimData.NbAlt,numel(SimData.TIMEVECT));
for x = 1:SimData.nx
    U(x,:,:,:) = .5*(Ustagg(x,:,:,:) + Ustagg(x+1,:,:,:));
end

V = zeros(SimData.nx,SimData.ny,SimData.NbAlt,numel(SimData.TIMEVECT));
for y = 1:SimData.ny   
    V(:,y,:,:) = .5*(Vstagg(:,y,:,:) + Vstagg(:,y+1,:,:));
end

SimData.CoordZ = zeros(SimData.nx,SimData.ny,SimData.NbAlt,numel(SimData.TIMEVECT));
for k = 1:SimData.NbAlt
    SimData.CoordZ(:,:,k,:) = .5*(Height(:,:,k,:) + Height(:,:,k+1,:));
end

%% Velocity and direction %%

SimData.WS = sqrt(U.^2 + V.^2);

SimData.WD = zeros(SimData.nx,SimData.ny,SimData.NbAlt,numel(SimData.TIMEVECT));

for x = 1:SimData.nx
    for y = 1:SimData.ny
        for Alt = 1:SimData.NbAlt
            for Time = 1:numel(SimData.TIMEVECT)
                if U(x,y,Alt,Time) > 0
                    SimData.WD(x,y,Alt,Time) = 270-(180/pi)*atan(V(x,y,Alt,Time)/U(x,y,Alt,Time));
                else
                    SimData.WD(x,y,Alt,Time) = 90-(180/pi)*atan(V(x,y,Alt,Time)/U(x,y,Alt,Time));
                end
            end
        end
    end
end

%% Permutation to set dimensions as (row,col,etc) = (ny,nx,nz,nt) %%

SimData.WD = permute(SimData.WD,[2 1 3 4]);
SimData.WS = permute(SimData.WS,[2 1 3 4]);
SimData.CoordZ = permute(SimData.CoordZ,[2 1 3 4]);
