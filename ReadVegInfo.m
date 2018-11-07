function VegData = ReadVegInfo(SimData,VegData,VegFlag)


if VegFlag ==  1
    fprintf('Reading vegetation information\n')
    
    VegData.Coord = struct([]);
    for N = 1:numel(VegData.LU)
        [row,col] = find(SimData.LU == VegData.LU{N});
        VegData.Coord{N} = [row,col];
        VegData.NbVeg = VegData.NbVeg + size(VegData.Coord{N},1);
    end
    
else    
    VegData.Coord = [];    
end


