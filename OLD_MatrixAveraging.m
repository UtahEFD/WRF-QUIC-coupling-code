function SimData = SIM_MatrixAveraging(SimData,AvgValue)

NbRow = size(SimData.Matrix,1); NbCol = size(SimData.Matrix,2);

if AvgValue == 9    
    NbRow2 = floor(NbRow/3); NbCol2 = floor(NbCol/3);
    
    if mod(NbRow,3) ~=0
        Mem1 = zeros(NbRow2+1,NbCol);
    else
        Mem1 = zeros(NbRow2,NbCol);
    end
    
    for i = 1:NbRow2
        for j = 1:NbCol
            ind = 3*i-1;
            Mem1(i,j) = mean([SimData.Matrix(ind-1,j)  SimData.Matrix(ind,j)  SimData.Matrix(ind+1,j)]);
        end
    end
    
    if mod(NbRow,3) == 1
        for j = 1:NbCol
            Mem1(end,j) = SimData.Matrix(end,j);
        end
    elseif mod(NbRow,3) == 2
        for j = 1:NbCol
            Mem1(end,j) = (SimData.Matrix(end-1,j) + SimData.Matrix(end,j))/2 ;
        end
    end
    
    %%%
    
    if mod(NbCol,3) ~=0
        Mem2 = zeros(size(Mem1,1),NbCol2+1);
    else
        Mem2 = zeros(size(Mem1,1),NbCol2);
    end
    
    for j = 1:NbCol2
        for i = 1:size(Mem1,1)
            ind = 3*j-1;
            Mem2(i,j) = mean([Mem1(i,ind-1)  Mem1(i,ind)  Mem1(i,ind+1)]);
        end
    end
    
    if mod(NbCol,3) == 1
        for i = 1:size(Mem1,1)
            Mem2(i,end) = Mem1(i,end);
        end
    elseif mod(NbCol,3) == 2
        for i = 1:size(Mem1,1)
            Mem2(i,end) = (Mem1(i,end-1) + Mem1(i,end))/2 ;
        end
    end       
    
elseif AvgValue == 4    
    
    NbRow2 = floor(NbRow/2); NbCol2 = floor(NbCol/2);
    
    if mod(NbRow,2) ~=0
        Mem1 = zeros(NbRow2+1,NbCol);
    else
        Mem1 = zeros(NbRow2,NbCol);
    end
    
    for i = 1:NbRow2
        for j = 1:NbCol
            ind = 2*i-1;
            Mem1(i,j) = mean([SimData.Matrix(ind,j)  SimData.Matrix(ind+1,j)]);
        end
    end
    
    if mod(NbRow,2) == 1
        for j = 1:NbCol
            Mem1(end,j) = SimData.Matrix(end,j);
        end
    end
    
    %%%
    
    if mod(NbCol,2) ~=0
        Mem2 = zeros(size(Mem1,1),NbCol2+1);
    else
        Mem2 = zeros(size(Mem1,1),NbCol2);
    end
    
    for j = 1:NbCol2
        for i = 1:size(Mem1,1)
            ind = 2*j-1;
            Mem2(i,j) = mean([Mem1(i,ind)  Mem1(i,ind+1)]);
        end
    end
    
    if mod(NbCol,2) == 1
        for i = 1:size(Mem1,1)
            Mem2(i,end) = Mem1(i,end);
        end
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

