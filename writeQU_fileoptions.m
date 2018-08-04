function writeQU_fileoptions(ProjectPath)

version = 6.1;

OutputFLAG = 2;
NonmassConservedInitFieldFLAG = 0;
UOSensorFieldFLAG = 0;
StaggeredVelocFLAG = 0;

fid = fopen([ProjectPath 'QU_fileoptions.inp'],'w');

fprintf(fid,'!QUIC %g\n', version);
fprintf(fid,'%i !output data file format flag (1=ascii, 2=binary, 3=both)\n', OutputFLAG);
fprintf(fid,'%i !flag to write out non-mass conserved initial field (uofield.dat) (1=write,0=no write)\n', NonmassConservedInitFieldFLAG);
fprintf(fid,'%i !flag to write out the file uosensorfield.dat, the initial sensor velocity field (1=write,0=no write)\n', UOSensorFieldFLAG);
fprintf(fid,'%i !flag to write out the file QU_staggered_velocity.bin used by QUIC-Pressure(1=write,0=no write)\n', StaggeredVelocFLAG);

fclose(fid);