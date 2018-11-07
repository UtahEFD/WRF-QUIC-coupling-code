function WriteQUICFiles(SimData,StatData,BdData,VegData,TerrainFlag,ProjectName)


%% Creating project structure %%

ProjectPath = [pwd '/' ProjectName '/'];
ProjectPathInner = [ProjectPath ProjectName '_inner' '/'];

mkdir(ProjectPath)  %%% By default, project is created in actual directory
mkdir([ProjectPath ProjectName '_inner'])
mkdir([ProjectPath ProjectName '_outer'])

WritePROJ(SimData, ProjectPath, ProjectName);
writeQU_fileoptions(ProjectPathInner);
writeINFO(ProjectPathInner, ProjectName);
writeQP_elevation(ProjectPathInner);
writeQU_landuse(ProjectPathInner);

%% Writing output files %%

WriteQU_BUILDINGS(SimData,BdData,VegData,TerrainFlag,ProjectPathInner);
WriteQU_SIMPARAMS(SimData,ProjectPathInner);
WriteQU_METPARAMS(SimData,StatData,ProjectPathInner);
WriteSENSOR(SimData,StatData,ProjectPathInner);

