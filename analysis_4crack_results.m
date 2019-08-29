clc
clear
%% define the basic name and location, please change this before the new test 
currentWorkFolder='C:\Users\User\Documents\MATLAB';
subFolder='a01_by_Python_toughness\a01_numericalTest\a00_version_2016_cod\results';
featureName='a29_4blocks_python_480Tk2Hc1VFo5PVrVbVc';
cd(currentWorkFolder)
%% Change the content of python file and run it
%copy 25_analysis_results.py to the destination and rename it to results_featureName.py

pythonName=strcat(featureName,'results.py');
sourcepyFile='25_analysis_results.py';
cd(currentWorkFolder)
targetFile_pathNS=strcat(subFolder,'\',featureName);
pythonCopyCk=input('Do you need to copy the origin py file [Y or N]<Y> ');
if isempty(pythonCopyCk)==1
    copyfile(sourcepyFile,targetFile_pathNS,'f')
    cd(strcat(currentWorkFolder,'\',targetFile_pathNS))
    movefile(sourcepyFile,pythonName)
end
pythonFileCk=input('Have you change the content of python script file pythonName [Y or N]<Y> ');
if pythonFileCk=='N'
    fprintf ('Please go back to change the content of python file\n')
    fprintf('You should change the path, featureName, mouth, mcod, delt0 and the relevent element and node numbers')
end
%% run the script to get the data from the odb file
system(['abaqus python ',strcat(currentWorkFolder,'\',targetFile_pathNS,'\',pythonName)])
%% processing the pore pressure data of the mouth
porFile=strcat(featureName,'_pressure.data');
fileID=fopen(strcat(currentWorkFolder,'\',targetFile_pathNS,'\',porFile));
porTitle=textscan(fileID,'%s %s', 1);
porData=textscan(fileID,'%f%f ','Delimiter','space');
fclose(fileID);
time=porData{1};
psiMPa=input('What do you want the pressure unit to be [Pa-0 or psi-1] ');
if psiMPa==0
    porPressure=porData{2};
elseif psiMPa==1
    porPressure=porData{2}/1e6*145;
end
figure('NumberTitle','off','name','Pore pressure change with time')

plot(time, porPressure)
title(featureName)
xlabel('time (s)')
if psiMPa==0
    ylabel('pressure (pa)')
elseif psiMPa==1
    ylabel('pressure (psi)')
end
saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\',featureName,'_pressure'))

%% processing the crack width of element one (source point)
widthCal=input('Do you want to calculate by pfopen or displacement[pfopen-0, dis-1]');
input('Please check the value of initialOpen')
initialOpen=0.0002;
% The results of this two methods are very close
if widthCal==0
    widthFile=strcat(featureName,'_pfWidth.data');
elseif widthCal==1
    widthFile=strcat(featureName,'_width.data');
end
fileID=fopen(strcat(currentWorkFolder,'\',targetFile_pathNS,'\',widthFile));
widthTitle=textscan(fileID,'%s %s', 1);
widthData=textscan(fileID,'%f%f ','Delimiter','space');
fclose(fileID);
time=widthData{1};

if widthCal==0
    crackWidth=widthData{2}-initialOpen;
    figure('NumberTitle','off','name','Crack width by pfopen of the injection source change with time')
elseif widthCal==1
    crackWidth=widthData{2}*2;
    figure('NumberTitle','off','name','Crack width by displacement of the injection source change with time')
end
plot(time, crackWidth)
title(featureName)
xlabel('time (s)')
ylabel('crack width (m)')
if widthCal==0
    saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\',featureName,'_pfWidth'))
elseif widthCal==1
    saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\','_width'))
end

%% processing the crack length
%however if the crack length want to be equivalent to the crack length of LEFM, 
%SDEG method is not applicable, we should change the criteria to the pfopen>delt0
lengthCal=input('Please choose the criteria of length calculation[(pfopen-0.002>delta0)-0, (SDEG=1)-1]');
if lengthCal==0
    V1File=strcat(featureName,'_V1pfLen.data');
    V2File=strcat(featureName,'_V2pfLen.data');
    H1File=strcat(featureName,'_H1pfLen.data');
    H2File=strcat(featureName,'_H2pfLen.data');
elseif lengthCal==1
    V1File=strcat(featureName,'_V1SDEG.data');
    V2File=strcat(featureName,'_V2SDEG.data');
    H1File=strcat(featureName,'_H1SDEG.data');
    H2File=strcat(featureName,'_H2SDEG.data');
end

fileID=fopen(strcat(currentWorkFolder,'\',targetFile_pathNS,'\',V1File));
V1title=textscan(fileID,'%s %s %s %s', 1);
V1Data=textscan(fileID,'%d%f %d%f','Delimiter','space');
fclose(fileID);
time=V1Data{2};
V1CrackLength=V1Data{4};
if lengthCal==0
    figure('NumberTitle','off','name','Crack length by pfopen of vertical crack V1')
elseif lengthCal==1
    figure('NumberTitle','off','name','Crack length by SDEG of vertical crack V1')
end
plot(time,V1CrackLength)
title(featureName)
xlabel('time (s)')
ylabel('vertical crack length of V1(m)')
if lengthCal==0
    saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\',featureName,'_V1pfLen'))
elseif lengthCal==1
    saveas(gcf, strcat(currentWorkFolder,subFolder,featureName,'_V1SDEG'))
end

fileID=fopen(strcat(currentWorkFolder,'\',targetFile_pathNS,'\',V2File));
V2title=textscan(fileID,'%s %s %s %s', 1);
V2Data=textscan(fileID,'%d%f %d%f','Delimiter','space');
fclose(fileID);
time=V2Data{2};
V2CrackLength=V2Data{4};
if lengthCal==0
    figure('NumberTitle','off','name','Crack length by pfopen of vertical crack V2')
elseif lengthCal==1
    figure('NumberTitle','off','name','Crack length by SDEG of vertical crack V2')
end
plot(time,V2CrackLength)
title(featureName)
xlabel('time (s)')
ylabel('vertical crack length of V2(m)')
if lengthCal==0
    saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\',featureName,'_V2pfLen'))
elseif lengthCal==1
    saveas(gcf, strcat(currentWorkFolder,subFolder,featureName,'_V2SDEG'))
end



fileID=fopen(strcat(currentWorkFolder,'\',targetFile_pathNS,'\',H1File));
H1title=textscan(fileID,'%s %s %s %s', 1);
H1Data=textscan(fileID,'%d%f %d%f','Delimiter','space');
fclose(fileID);
time=H1Data{2};
H1CrackLength=H1Data{4};
if lengthCal==0
    figure('NumberTitle','off','name','Crack length by pfopen of vertical crack H1')
elseif lengthCal==1
    figure('NumberTitle','off','name','Crack length by SDEG of vertical crack H1')
end
plot(time,H1CrackLength)
title(featureName)
xlabel('time (s)')
ylabel('vertical crack length of H1(m)')
if lengthCal==0
    saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\',featureName,'_H1pfLen'))
elseif lengthCal==1
    saveas(gcf, strcat(currentWorkFolder,subFolder,featureName,'_H1SDEG'))
end


fileID=fopen(strcat(currentWorkFolder,'\',targetFile_pathNS,'\',H2File));
H2title=textscan(fileID,'%s %s %s %s', 1);
H2Data=textscan(fileID,'%d%f %d%f','Delimiter','space');
fclose(fileID);
time=H2Data{2};
H2CrackLength=H2Data{4};
if lengthCal==0
    figure('NumberTitle','off','name','Crack length by pfopen of vertical crack H2')
elseif lengthCal==1
    figure('NumberTitle','off','name','Crack length by SDEG of vertical crack H2')
end
plot(time,H2CrackLength)
title(featureName)
xlabel('time (s)')
ylabel('vertical crack length of H2(m)')
if lengthCal==0
    saveas(gcf, strcat(currentWorkFolder,'\',targetFile_pathNS,'\',featureName,'_H2pfLen'))
elseif lengthCal==1
    saveas(gcf, strcat(currentWorkFolder,subFolder,featureName,'_H2SDEG'))
end