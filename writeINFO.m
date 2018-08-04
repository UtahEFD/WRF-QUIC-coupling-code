function writeINFO(ProjectPath, ProjectName)

ColorScheme = 'height';
ColorMap = 'colormap';
TransparentBUILDING = 'off';
NumberedFlag = 'off';
BldReshapeFlag = 'on';
BldAutoCorrFlag = 'on';
ConstantColor = 0.6;

ColorRGB = 0.8;
TransparentGROUND = 'off';
MapFlag = 'on';
TopolinesFlag = 'off';
TopolineLabelsFlag = 'on';
Topolevels = 20;
AxesFlag = 'on';
AxesUpdateSpeed = 2;

fid = fopen([ProjectPath ProjectName '.info'],'w');

fprintf(fid,'BUILDING INFO\n');
fprintf(fid,'%s \t\t !Color scheme\n', ColorScheme);
fprintf(fid,'%s \t\t !Color Map\n', ColorMap);
fprintf(fid,'%s \t\t !Transparent\n', TransparentBUILDING);
fprintf(fid,'%s \t\t !Numbered\n', NumberedFlag);
fprintf(fid,'%s \t\t !Bld Reshape Symbols \n', BldReshapeFlag);
fprintf(fid,'%s \t\t !Bld Auto-Correlation \n', BldAutoCorrFlag);
fprintf(fid,'%g \n', 0.6);
fprintf(fid,'%g \n', 0.6);
fprintf(fid,'%g \t\t !Constant Color \n', ConstantColor);
fprintf(fid,'GROUND INFO \n');
fprintf(fid,'%g \t\t !Color (RGB)  \n', ColorRGB);
fprintf(fid,'%g \t\t ! \n', 0.8);
fprintf(fid,'%g \t\t ! \n', 0.8);
fprintf(fid,'%s \t\t !Transparent\n', TransparentGROUND);
fprintf(fid,'%s \t\t !Map\n', MapFlag);
fprintf(fid,'%s \t\t !Topolines\n', TopolinesFlag);
fprintf(fid,'%s \t\t !Topoline labels\n', TopolineLabelsFlag);
fprintf(fid,'%g \t\t !Topo Levels\n', Topolevels);
fprintf(fid,'%s \t\t !Axes\n', AxesFlag);
fprintf(fid,'%g \t\t !Axes Update Speed\n', AxesUpdateSpeed);

fclose(fid);
