function writeQP_elevation(ProjectPathInner)

fid = fopen([ProjectPathInner 'QP_elevation.inp'],'w','l');

fwrite(fid,4*3,'int32');
fwrite(fid,[0,0,0],'real*4');
fwrite(fid,4*3,'int32');

fclose(fid);