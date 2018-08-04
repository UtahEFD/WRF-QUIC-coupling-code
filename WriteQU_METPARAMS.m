function WriteQU_METPARAMS(SimData,ProjectDir)

version = 6.1;
METinputFlag = 0;

fid= fopen([ProjectDir 'QU_metparams.inp'],'w');

fprintf(fid,'!QUIC %g\n',version);
fprintf(fid, '%i\t!Met input flag (0=QUIC,1=WRF,2=ITT MM5,3=HOTMAC)\n', METinputFlag);
fprintf(fid, '%i\t!Number of measuring sites\n', SimData.NbStat);
fprintf(fid, '%i\t!Maximum size of data points profiles\n', SimData.NbAlt);

for Stat = 1 : SimData.NbStat
    fprintf(fid, '%s !Site Name \n', ['sensor' num2str(Stat)]);
    fprintf(fid, '!File name \n');
    fprintf(fid, '%s \n', ['sensor' num2str(Stat) '.inp']);
end

fclose(fid);