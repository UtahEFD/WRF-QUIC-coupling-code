function WriteQUICFiles(SimData,WRFData,BdData,VegData,Z0,StretchFlag,TerrainFlag,ProjectName)

%%% Creating project structure %%%

ProjectPath = [pwd '/' ProjectName '/'];
ProjectPathInner = [ProjectPath ProjectName '_inner' '/'];

mkdir(ProjectPath)  %%% By default, project is created in actual directory
mkdir([ProjectPath ProjectName '_inner'])
mkdir([ProjectPath ProjectName '_outer'])

WritePROJ(SimData.dx, SimData.dy, ProjectPath, ProjectName);
writeQU_fileoptions(ProjectPathInner);
writeINFO(ProjectPathInner, ProjectName);
writeQP_elevation(ProjectPathInner);
writeQU_landuse(ProjectPathInner);

%%% Writing output files %%%

if TerrainFlag == 0
    SimData.Matrix = 0;
end

WriteQU_BUILDINGS(SimData,BdData,VegData,TerrainFlag,ProjectPathInner);

%WriteQU_SIMPARAMS_BRUNT(Avg_U_Approach,HillHeight,N,Clock,TIMEVECT,nx_INNER,ny_INNER,CoordZ,dx_INNER,dy_INNER,maxTH,VerticalStretchFLAG,ProjectPathInner);
WriteQU_SIMPARAMS(SimData,WRFData,ProjectPathInner,StretchFlag);

WriteQU_METPARAMS(SimData,ProjectPathInner);

WriteSENSOR(SimData,WRFData,Z0,ProjectPathInner);

