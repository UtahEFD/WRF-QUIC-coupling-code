function SimData = MatrixAveraging(SimData,AvgValue)

NbRow = size(SimData.Matrix,1);
NbCol = size(SimData.Matrix,2);

if AvgValue == 9 
    
    % Cutting edges to the right and to the top to get an exact modulo
    
    NbRow2 = floor(NbRow/3); 
    NbCol2 = floor(NbCol/3);    
    SimData.Matrix = SimData.Matrix(1:3*NbRow2,1:3*NbCol2);
    Mem1 = zeros(NbRow2, 3*NbCol2);
    Mem2 = zeros(NbRow2, NbCol2);
    
    % Averaging along X axis
    
    for i = 1:NbRow2
        for j = 1:3*NbCol2
            ind = 3*i-1;
            Mem1(i,j) = mean([SimData.Matrix(ind-1,j)  SimData.Matrix(ind,j)  SimData.Matrix(ind+1,j)]);
        end
    end
    
    % Averaging along Y axis
    
    for j = 1:NbCol2
        for i = 1:size(Mem1,1)
            ind = 3*j-1;
            Mem2(i,j) = mean([Mem1(i,ind-1)  Mem1(i,ind)  Mem1(i,ind+1)]);
        end
    end
    
    % Updating center coordinates
    
    if mod(NbRow,3) == 1
    	SimData.CenterY = SimData.CenterY - SimData.dy/2;
    elseif mod(NbRow,3) == 2
    	SimData.CenterY = SimData.CenterY - SimData.dy;  
    end
    if mod(NbCol,3) == 1
    	SimData.CenterX = SimData.CenterX - SimData.dx/2;
    elseif mod(NbCol,3) == 2
    	SimData.CenterX = SimData.CenterX - SimData.dx;
    end
    
elseif AvgValue == 4
    
    % Cutting edges to the right and to the top to get an exact modulo
    
    NbRow2 = floor(NbRow/2); 
    NbCol2 = floor(NbCol/2);    
    SimData.Matrix = SimData.Matrix(1:2*NbRow2, 1:2*NbCol2);        
    Mem1 = zeros(NbRow2,2*NbCol2);
    Mem2 = zeros(NbRow2,NbCol2);
    
    % Averaging along X axis
    
    for i = 1:NbRow2
        for j = 1:2*NbCol2
            ind = 2*i-1;
            Mem1(i,j) = mean([SimData.Matrix(ind,j)  SimData.Matrix(ind+1,j)]);
        end
    end    
    
    % Averaging along Y axis        
    
    for j = 1:NbCol2
        for i = 1:size(Mem1,1)
            ind = 2*j-1;
            Mem2(i,j) = mean([Mem1(i,ind)  Mem1(i,ind+1)]);
        end
    end
    
    % Update center coordinates
    
    if mod(NbRow,2) == 1
        SimData.CenterY = SimData.CenterY - SimData.dy/2; 
    end
    if mod(NbCol,2) == 1
        SimData.CenterX = SimData.CenterX - SimData.dx/2;
    end   
    
end

SimData.nx = size(Mem2,2);
SimData.ny = size(Mem2,1);

RatioX = size(SimData.Matrix,2)/size(Mem2,2);
RatioY = size(SimData.Matrix,1)/size(Mem2,1);

SimData.Matrix = Mem2;

SimData.dx = RatioX * SimData.dx;
SimData.dy = RatioY * SimData.dy;

SimData.NbTerrain = numel(Mem2);

