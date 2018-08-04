function BdData = ReadBDInfo(BdFile)


fprintf('Reading building information\n')
BdData.List = csvread(BdFile,1,0);
BdData.NbBd = size(BdData,1);
