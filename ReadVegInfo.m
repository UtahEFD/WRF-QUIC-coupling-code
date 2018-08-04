function VegData = ReadVegInfo(VegData,WRFData,VegFlag)

VegData.NbVeg = 0;

if VegFlag == 1    
    fprintf('Reading vegetation information\n')
    
    for N = 1:size(VegData.Lim,2)
        try
            VegData.Coord{N} = SIM_ZoneVeg(VegData.Lim{N});
            VegData.NbVeg = VegData.NbVeg + size(VegData.Coord{N},2);
        catch
            fprintf('ERROR: Vegetation zone %i %s\n', N, 'not correctly defined, see user guide for more details')
            return
        end
    end    
elseif VegFlag == 2    
    fprintf('Reading vegetation information\n')
    
    % Removing vegetation close to domain borders to avoid NaN during calculation
    % (((Should be refined in case of new domain borders)))
    
    %XSTART_NEW = 20; XEND_NEW = WRFData.nx - 20; YSTART_NEW = 20; YEND_NEW = WRFData.ny - 20;    
    %WRFData.LU(1:XSTART_NEW,:) = 99; WRFData.LU(XEND_NEW:WRFData.nx,:) = 99; WRFData.LU(:,1:YSTART_NEW) = 99; WRFData.LU(:,YEND_NEW:WRFData.ny) = 99;
     
    for N = 1:numel(VegData.LU)        
        [row,col] = find(WRFData.LU == VegData.LU{N});        
        VegData.Coord{N} = [row,col];        
        VegData.NbVeg = VegData.NbVeg + size(VegData.Coord{N},1);        
    end    
else    
    VegData.Coord = [];    
end

