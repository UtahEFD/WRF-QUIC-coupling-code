function SimData = MinDomainHeight(SimData)

% Here we lower minimum altitude to 0 in order to save computational space.
% For the same reason, topography below 50 cm will not be considered.

SimData.OldTopoMin = min(min(SimData.Relief));
SimData.Relief = SimData.Relief - SimData.OldTopoMin;  % Lowering minimum altitude to 0 

IndLowRelief = find(SimData.Relief <= 15); % Relief below 0.5m is not considered
SimData.Relief(IndLowRelief) = 0;

SimData.NbTerrain = numel(SimData.Relief) - size(IndLowRelief,1);
SimData.NewTopoMax = max(max(SimData.Relief));
SimData.CoordZ = SimData.CoordZ - SimData.OldTopoMin;
