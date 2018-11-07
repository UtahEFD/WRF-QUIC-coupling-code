function WritePROJ(SimData, ProjectPath, ProjectName)

CreatorName = 'unnamed';
Notes = 'None';
InnerGridInletProf = 'Discrete';
RooftopInnerGrid = 'Vortex';
WindAngleInnerGrid = 0;
VelocRefInnerGrid = 3;
NestedGridFlag = 0;
InnerGridLocX = 0;
InnerGridLocY = 0;
BatchProcFlag = 0;

dz = 1;

fid = fopen([ProjectPath ProjectName '.proj'],'w');

fprintf(fid,'Creator:\n \t %s \n', CreatorName);
fprintf(fid,'Date: \n \t %s \n', date);
fprintf(fid,'Notes: \n \t %s \n', Notes);
fprintf(fid,'Inner Grid Inlet Profile: \n \t %s \n', InnerGridInletProf);
fprintf(fid,'Roof Top (Inner Grid): \n \t %s \n', RooftopInnerGrid);
fprintf(fid,'Wind Angle(Inner Grid): \n \t %.f \n', WindAngleInnerGrid);
fprintf(fid,'Velocity Ref(Inner Grid): \n \t %.f \n', VelocRefInnerGrid);
fprintf(fid,'# of Buildings(Inner Grid): \n \t %.f \n',0);
fprintf(fid,'Inner Grid Scale: \n \t %s %.f %s %.f %s %.f \n', 'dx =', SimData.dx, 'dy =', SimData.dy, 'dz =', dz);
fprintf(fid,'Nested Grid Flag: \n \t %.f \n', NestedGridFlag);
fprintf(fid,'Inner Grid Location,X: \n \t %.f \n', InnerGridLocX);
fprintf(fid,'Inner Grid Location,Y: \n \t %.f \n', InnerGridLocY);
fprintf(fid,'Batch Processing Flag: \n \t %.f \n', BatchProcFlag);
fprintf(fid,'~');

fclose(fid);