function WriteQU_BUILDINGS(SimData,BdData,VegData,TerrainFlag,ProjectDir)

version = 6.1; %%% QUIC current version
zo_wall = 0.1; %%% Wall roughness length
numnodes = 0;    %%% Number of polygon nodes

if TerrainFlag == 0
    SimData.Relief = 0;
    SimData.NbTerrain = 0;
end

NbStruc = SimData.NbTerrain + BdData.NbBd + VegData.NbVeg; % Total number of structures

%%%
GeomNbTypeRelief = 1;
GeomTypeRelief = 'Rectangular';
NbTypeRelief = 5;
TypeRelief = 'Relief';
%%%
NbTypeBd = 1;
TypeBd = 'Solid';
%%%
GeomNbTypeVeg = 1;
GeomTypeVeg = 'Rectangular';
NbTypeVeg = 2;
TypeVeg = 'Canopy';
%%%

fid = fopen([ProjectDir 'QU_buildings.inp'],'w+');

%%% Header

fprintf(fid,'!QUIC %g\n',version);
fprintf(fid,'%g\t\t\t!Wall roughness length (m)\n',zo_wall);
fprintf(fid,'%g\t\t\t!Number of Buildings\n',NbStruc);
fprintf(fid,'%g\t\t\t!Number of Polygon Building Nodes\n',numnodes);

%%% Body

ind = 1;

%% Relief
if TerrainFlag ~=0
    for x = 1:SimData.nx
        for y = 1:SimData.ny
            fprintf(fid,'!Start Building %i\n', ind);
            fprintf(fid,'%g\t\t\t!Group ID\n', 1);
            fprintf(fid,'%g\t\t\t!Geometry = ', GeomNbTypeRelief);
            fprintf(fid,'%c', GeomTypeRelief);
            fprintf(fid,'\n');
            fprintf(fid,'%g\t\t\t!Building Type = ', NbTypeRelief);
            fprintf(fid,'%c', TypeRelief);
            fprintf(fid,'\n');
            fprintf(fid,'%g\t\t\t!Height [m]\n', SimData.Relief(y,x));
            fprintf(fid,'%g\t\t\t!Base Height (Zfo) [m]\n', 0);
            fprintf(fid,'%g\t\t\t!Centroid X [m]\n', (x-1/2)*SimData.dx);
            fprintf(fid,'%g\t\t\t!Centroid Y [m]\n', (y-1/2)*SimData.dy);
            fprintf(fid,'%g\t\t\t!Xfo [m]\n', (x-1)*SimData.dx);
            fprintf(fid,'%g\t\t\t!Yfo [m]\n', (y-1/2)*SimData.dy);
            fprintf(fid,'%g\t\t\t!Length [m]\n', SimData.dx);
            fprintf(fid,'%g\t\t\t!Width [m]\n', SimData.dy);
            fprintf(fid,'%g\t\t\t!Rotation [deg]\n', 0);
            fprintf(fid,'!End Building %g\n', ind);
            ind = ind + 1;
        end
    end
end

%% Vegetation
for VegZone = 1:size(VegData.Coord,2) %%% for each vegetation zone
    for VegPt = 1:size(VegData.Coord{VegZone},1) %%% for each points in this zone
        y = VegData.Coord{VegZone}(VegPt,1);
        x = VegData.Coord{VegZone}(VegPt,2);
        if TerrainFlag == 0
            BaseHeight = 0;
        else
            BaseHeight = SimData.Relief(y,x);
        end
        fprintf(fid,'!Start Building %i\n', ind);
        fprintf(fid,'%g\t\t\t!Group ID\n', 1);
        fprintf(fid,'%g\t\t\t!Geometry = ', GeomNbTypeVeg);
        fprintf(fid,'%c', GeomTypeVeg);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t\t\t!Building Type = ', NbTypeVeg);
        fprintf(fid,'%c', TypeVeg);        
        fprintf(fid,'\n');
        fprintf(fid, '%.3f\t\t\t%s\n', VegData.Coeff{VegZone}, '!Attenuation Coefficient');
        fprintf(fid,'%g\t\t\t!Height [m]\n', VegData.Height{VegZone});
        fprintf(fid,'%g\t\t\t!Base Height (Zfo) [m]\n', BaseHeight);
        fprintf(fid,'%g\t\t\t!Centroid X [m]\n', (x-1/2)*SimData.dx);
        fprintf(fid,'%g\t\t\t!Centroid Y [m]\n', (y-1/2)*SimData.dy);
        fprintf(fid,'%g\t\t\t!Xfo [m]\n', (x-1)*SimData.dx);
        fprintf(fid,'%g\t\t\t!Yfo [m]\n', (y-1/2)*SimData.dy);
        fprintf(fid,'%g\t\t\t!Length [m]\n', SimData.dx);
        fprintf(fid,'%g\t\t\t!Width [m]\n', SimData.dy);
        fprintf(fid,'%g\t\t\t!Rotation [deg]\n', 0);
        fprintf(fid,'!End Building %g\n', ind);
        ind = ind + 1;        
    end
end

%% Buildings
if ind == 1
    indGpID = 1;
else
    indGpID = 2; %%% Vegetation and relief share the same group ID
end

for n = 1:size(BdData.List,1)
    
    GeomNbType = BdData.List(n,1);
    
    switch GeomNbType
        case  1
            GeomType = 'Rectangular';
        case 2
            GeomType = 'Elliptical';
        case 4
            GeomType = 'Rectangular Stadium';
        case 5
            GeomType = 'Elliptical Stadium';
        case 6
            GeomType = 'Polygon';
    end
    
     Height = BdData.List(n,2);
    
    if GeomNbType~=6

        CenterX = BdData.List(n,3);
        CenterY = BdData.List(n,4);
        Length = BdData.List(n,5);
        Width = BdData.List(n,6);
        Rotation = BdData.List(n,7);
        if TerrainFlag == 0
            BaseHeight = 0;
        else
            BaseHeight = SimData.Relief(CenterY,CenterX); % Base height is height at building center.
        end
        fprintf(fid,'!Start Building %i\n', ind);
        fprintf(fid,'%g\t\t\t!Group ID\n', indGpID);
        fprintf(fid,'%g\t\t\t!Geometry = ', GeomNbType);
        fprintf(fid,'%c', GeomType);
        fprintf(fid,'\n');        
        
        if strcomp(GeomType,'Rectangular Stadium') || strcomp(GeomType,'Elliptical Stadium')
            fprintf(fid,'%g\t\t\t!Base Wall Thickness [m]\n', BdData.List(n,8));
            fprintf(fid,'%i\t\t\t!Roof Flag\n ', BdData.List(n,9));
        end
        
        fprintf(fid,'%g\t\t\t!Building Type = ', NbTypeBd);
        fprintf(fid,'%c', TypeBd);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t\t\t!Height [m]\n', Height);
        fprintf(fid,'%g\t\t\t!Base Height (Zfo) [m]\n', BaseHeight);
        fprintf(fid,'%g\t\t\t!Centroid X [m]\n', CenterX*SimData.dx);
        fprintf(fid,'%g\t\t\t!Centroid Y [m]\n', CenterY*SimData.dy);
        fprintf(fid,'%g\t\t\t!Xfo [m]\n', CenterX*SimData.dx-cosd(Rotation)*Length/2);
        fprintf(fid,'%g\t\t\t!Yfo [m]\n', CenterY*SimData.dy-sind(Rotation)*Length/2);
        fprintf(fid,'%g\t\t\t!Length [m]\n', Length);
        fprintf(fid,'%g\t\t\t!Width [m]\n', Width);
        fprintf(fid,'%g\t\t\t!Rotation [deg]\n', Rotation);
        
    else
        
        fprintf(fid,'!Start Building %i\n', ind);
        fprintf(fid,'%g\t\t\t!Group ID\n', indGpID);
        fprintf(fid,'%g\t\t\t!Geometry = ', GeomNbType);
        fprintf(fid,'%c', GeomType);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t\t\t!Building Type = ', NbTypeBd);
        fprintf(fid,'%c', TypeBd);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t\t\t!Height [m]\n', Height);
        fprintf(fid,'%g\t\t\t!Base Height (Zfo) [m]\n', BaseHeight);
        fprintf(fid,'%g\t\t\t!Centroid X [m]\n', mean(BdData.PolygonPts{n}(:,1)));
        fprintf(fid,'%g\t\t\t!Centroid Y [m]\n', mean(BdData.PolygonPts{n}(:,2)));
        fprintf(fid,'%g\t\t\t!Number of Polygons\n', 1);
        fprintf(fid,'!Start Polygon %g\n', 1);
        fprintf(fid,'%g\t\t\t!Number of Nodes\n', size(BdData.PolygonPts{n},1));
        fprintf(fid,'!X [m]   Y [m]\n');
        for p = 1:size(BdData.PolygonPts{n},1)
            fprintf(fid,'%g\t%g\n',BdData.PolygonPts{n}(p,1),BdData.PolygonPts{n}(p,2));
        end
        fprintf(fid,'!End Polygon %g\n', 1);

    end    
    
    fprintf(fid,'!End Building %g\n', ind);
    ind = ind + 1;
    indGpID = indGpID + 1;
    
end

fclose(fid);

