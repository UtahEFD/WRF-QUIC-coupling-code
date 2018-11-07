function writeQU_landuse(ProjectPathInner)

fid = fopen([ProjectPathInner 'QU_landuse.inp'],'w','l');

fwrite(fid,4*3,'int32');
fwrite(fid,[0,0,0],'int32');
fwrite(fid,4*3,'int32');

fclose(fid);