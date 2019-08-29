% ABAQUS help generator file
clear
clc
currentWorkFolder='C:\Users\User\Documents\MATLAB';
%% 0.======Read the input file
cd(currentWorkFolder)
fileID=fopen('02-input_main_frame2blocks.m');
pyfile_name=textscan(fileID,'%s',1,'CommentStyle','%');
initialinp_name=textscan(fileID,'%s',1,'CommentStyle','%');
submitinp_name=textscan(fileID,'%s',1,'CommentStyle','%');
dimension_domain=textscan(fileID,'%f',4,'CommentStyle','%','Delimiter',','); %dimension of the domain
height_fraction=textscan(fileID,'%f',1,'CommentStyle','%','Delimiter',','); % define the height fraction of the test
mesh_seed=textscan(fileID,'%d',2,'CommentStyle','%','Delimiter',',');
min_node_number_up=textscan(fileID,'%f',1,'CommentStyle','%'); 
num_division=textscan(fileID,'%f',1,'CommentStyle','%'); 
line_start_pt=textscan(fileID,'%f',2,'CommentStyle','%','Delimiter',','); 
line_last_pt=textscan(fileID,'%f',2,'CommentStyle','%','Delimiter',','); 
element_number_start=textscan(fileID,'%d',1,'CommentStyle','%');
viscosity_control=textscan(fileID,'%f',1,'CommentStyle','%');
confining_stress=textscan(fileID,'%s',2,'CommentStyle','%');
simu_time=textscan(fileID,'%f',1,'CommentStyle','%');
fclose(fileID);
%Export part of matlab input to abaqus input
fileID=fopen('02-input_main_frame2blocks.m');
abaqus_input=textscan(fileID,'%s',6,'CommentStyle','%');
fclose(fileID);
abaqus_input=abaqus_input{1};
fileID=fopen('03-abaqus_input_main_frame2blocks.m','w');
       [nrows,ncols] = size(abaqus_input);
    for row = 1:nrows
        fprintf(fileID,'%s\n',abaqus_input{row,:});
    end
fclose(fileID);

pyfile_name=char(pyfile_name{1});
file_location=regexp(pyfile_name,'/','split');
file_location=char(file_location(1));
initialinp_name=char(initialinp_name{1});
submitinp_name=char(submitinp_name{1});
submitinp_name_sys0=regexp(submitinp_name,'\.','split');
submitinp_name_sys=char(submitinp_name_sys0(1));
dimension_domain=cell2mat(dimension_domain);
height_fraction=cell2mat(height_fraction);
mesh_seed=cell2mat(mesh_seed);
min_node_number_up=cell2mat(min_node_number_up);
num_division=cell2mat(num_division);
line_start_pt=cell2mat(line_start_pt);
line_last_pt=cell2mat(line_last_pt);
element_number_start=cell2mat(element_number_start);
viscosity_control=cell2mat(viscosity_control);
confining_stress=confining_stress{1,1};
simu_time=cell2mat(simu_time);
%% 1.======create the Node and Element file of the main body
cd(currentWorkFolder)
[Node_cohesive, Element_cohesive,mouth,mcod]=no_triangle(min_node_number_up,num_division,line_start_pt,line_last_pt,element_number_start,submitinp_name_sys,file_location);

%% 1.======create the Node and Element file of the main body
tic
%==
%copy 01-creating_model_2blocks.py to the destination and rename it to submitinp_name_sys.py

sourcepyFile='01-creating_model_2blocks.py';
cd(currentWorkFolder)
targetFile_pathNS='b02_by_Python_viscosity';
copyfile(sourcepyFile,targetFile_pathNS,'f')
cd(strcat(currentWorkFolder,'\',targetFile_pathNS))
movefile(sourcepyFile,strcat(submitinp_name_sys,'.py'))
system(['abaqus cae ','script',strcat('=C:/Users/User/Documents/MATLAB/',pyfile_name)])
%==
%need to copy job1.inp to the destination folder
toc
%% 2.======output nodes and elements of the initial inp file
tic
% lineNum is the number of total lines, line_Node is the beginging line of the node
% line_Element is the beginning line of the element, line_End_Part is the end line the element
lineNum=0;line_Node=[];line_Element=[];line_End_Part=[];
Node_Number=0; Element_Number=0;
flag_Node=0;
flag_Element=0;

fid=fopen(strcat(file_location,'/',initialinp_name,'.inp'));
while 1
    line_Node_flag=0;
    line_Element_flag=0;
    lineNum=lineNum+1;
    tline = fgetl(fid);
    if strncmpi(tline,'*NODE',5)==1     
        line_Node=[line_Node;lineNum];
        flag_Node=1;
        line_Node_flag=1; % mark the line of *Node
    elseif strncmpi(tline,'*ELEMENT',5)==1
        line_Element=[line_Element;lineNum];
        flag_Element=1;
        flag_Node=0;
        line_Element_flag=1; % mark the line of *Element
    elseif  strncmpi(tline,'*END Part',6)==1
        line_End_Part=[line_End_Part;lineNum];
        flag_Element=0;
    end
    
    %Read the information of Node
    if flag_Node==1 && line_Node_flag~=1
        Node_Number=Node_Number+1;
        Node{Node_Number}=tline;
    end
    if flag_Element==1 && line_Element_flag~=1
        Element_Number=Element_Number+1;
        Element{Element_Number}=tline;
    end
    if ~ischar(tline),   break,   end
end
fclose(fid);
toc

%% =====3.Create the inp file for Abaqus calculation
cd(currentWorkFolder)
fileID_final=fopen(strcat(file_location,'/',submitinp_name),'w');
fprintf(fileID_final,'*Heading\n');
fprintf(fileID_final,'Equilibrium height growth\n');
fprintf(fileID_final,'*Preprint, echo=NO, model=NO, history=NO, contact=NO\n');
fprintf(fileID_final,'*parameter\n');
%This is to define maximum nomial stress in the normal only mode and shear only mode
fprintf(fileID_final,'%s%e\n','ultI   = ',1.0e+6); 
fprintf(fileID_final,'%s%e\n','ultII   = ',1.0e+15); 
fprintf(fileID_final,'%s%e\n','Emod   = ',3E12); 
fprintf(fileID_final,'%s%f\n','GIc   = ',29.25); 
fprintf(fileID_final,'%s%f\n','GIIc   = ',29.25); 
fprintf(fileID_final,'%s%f\n','eta   = ',2.284); 
fprintf(fileID_final,'%s%f\n','thick   = ',1.0); 
fprintf(fileID_final,'%s%f\n','width   = ',1.0); 
fprintf(fileID_final,'%s%f\n','amu   = ',5); %Fluid viscosity
fprintf(fileID_final,'%s%e\n','qbound   = ',1e-3); %Flow rate m^3/s

% Format of the main body nodes
fprintf(fileID_final,'%s\n','**-+ The rock nodes');
fprintf(fileID_final,'%s\n','*Node, nset=Rock');
    % Read the nodes of main body
    [nrows,ncols] = size(Node);
    for col = 1:ncols
        fprintf(fileID_final,'%s\n',Node{:,col});
    end
    fprintf(fileID_final,'%s\n','**--');

%Read the nodes of vertical crack
fprintf(fileID_final,'%s\n','**-+ The crack nodes');
fprintf(fileID_final,'%s\n','*Node, nset=vertical_crack');
    [nrows,ncols] = size(Node_cohesive);
    for row = 1:nrows
        fprintf(fileID_final,'%s\n',Node_cohesive{row,:});
    end
    fprintf(fileID_final,'%s\n','**--');
fprintf(fileID_final,'%s\n%s\n','*Nset, nset=crack','vertical_crack');    
fprintf(fileID_final,'*nset, nset=mouth\n%d\n',mouth);
fprintf(fileID_final,'*nset, nset=mcod\n%d,%d\n',mcod);

%Read the elements of the main body
fprintf(fileID_final,'%s\n','**-+ The rock elements');
fprintf(fileID_final,'%s\n','*Element, type=CPE4R, Elset=rock_all');
    [nrows,ncols] = size(Element);
    for col = 1:ncols
        fprintf(fileID_final,'%s\n',Element{:,col});
    end
    fprintf(fileID_final,'%s\n','**--');
    
% Read the vertical crack element
fprintf(fileID_final,'%s\n','**-+ The crack elements');
fprintf(fileID_final,'%s\n','*ELEMENT,TYPE=COH2D4P,ELSET=vertical_crack');
    [nrows,ncols] = size(Element_cohesive);
    for row = 1:nrows
        fprintf(fileID_final,'%s\n',Element_cohesive{row,:});
    end
    fprintf(fileID_final,'%s\n','**--');
    fprintf(fileID_final,'%s\n%s\n','*Elset, elset=crack','vertical_crack');

% Devide the rock into four parts  
    Element_Rock_1=mesh_seed(1)*mesh_seed(2);
    fprintf(fileID_final,'%s\n%d, %d\n','*Elset, elset=Rock_1, generate',1,Element_Rock_1);
    fprintf(fileID_final,'%s\n%d, %d\n','*Elset, elset=Rock_3, generate',Element_Rock_1+1,Element_Rock_1*2);
    fprintf(fileID_final,'%s\n%d, %d\n','*Elset, elset=Rock_1_1, generate',1,Element_Rock_1/6);
    fprintf(fileID_final,'%s\n%d, %d\n','*Elset, elset=Rock_1_2, generate',Element_Rock_1/6+1,Element_Rock_1);
    fprintf(fileID_final,'%s\n%d, %d\n','*Elset, elset=Rock_3_1, generate',Element_Rock_1+1,Element_Rock_1+Element_Rock_1/6);
    fprintf(fileID_final,'%s\n%d, %d\n','*Elset, elset=Rock_3_2, generate',Element_Rock_1/6+Element_Rock_1+1,Element_Rock_1*2);
    fprintf(fileID_final,'%s\n%s, %s\n','*Elset, elset=Rock_100mpa','Rock_1','Rock_3');
%Define the edge of the parts
fprintf(fileID_final,'%s\n%d, %d, %d\n','*Elset,elset=Rock_1_right, generate',mesh_seed(1),Element_Rock_1,mesh_seed(1));
fprintf(fileID_final,'%s\n%d, %d, %d\n','*Elset,elset=Rock_3_left, generate',Element_Rock_1+1,Element_Rock_1*2-mesh_seed(1)+1,mesh_seed(1));
% Define the relation between the cohesive element and rock element
    %Define the slave surface
    fprintf(fileID_final,'%s\n%s, %s\n','*Surface, Name=Sver_top, Type=element','vertical_crack','S3');
    fprintf(fileID_final,'%s\n%s, %s\n','*Surface, Name=Sver_bottom, Type=element','vertical_crack','S1');
    %Define the master surface
    fprintf(fileID_final,'%s\n%s, %s\n','*Surface, Name=SRock_1_right, Type=element','Rock_1_right','S2');
    fprintf(fileID_final,'%s\n%s, %s\n','*Surface, Name=SRock_3_left, Type=element','Rock_3_left','S4');
    % Tie them together
    fprintf(fileID_final,'%s\n%s, %s\n','*Tie,NAME=Rock_1_3_left,position tolerance=0','Sver_top','SRock_1_right');
    fprintf(fileID_final,'%s\n%s, %s\n','*Tie,NAME=Rock_1_3_right,position tolerance=0','Sver_bottom','SRock_3_left');

%Define the property of the cohesive elements
    fprintf(fileID_final,'%s\n%s\n%s, %f\n','*COHESIVE SECTION,ELSET=crack,MATERIAL=MAT1,RESPONSE=TRACTION SEPARATION,','THICKNESS=SPECIFIED,CONTROLS=VISCO','<thick>',1.0);
    fprintf(fileID_final,'%s\n','*SECTION CONTROLS,NAME=VISCO,VISCOSITY=0.1');
    fprintf(fileID_final,'%s\n','*MATERIAL,NAME=MAT1');
    fprintf(fileID_final,'%s\n%s\n','*ELASTIC,TYPE=TRACTION','<Emod>,<Emod>');
    fprintf(fileID_final,'%s\n%s\n','*DAMAGE INITIATION,CRITERION=QUADS','<ultI>, <ultII>');
    fprintf(fileID_final,'%s\n%s\n','*DAMAGE EVOLUTION,TYPE=ENERGY,MIXED MODE BEHAVIOR=BK,POWER=<eta>','<GIc>, <GIIc>');
    fprintf(fileID_final,'%s\n%s\n','*GAP FLOW','<amu>');
    %Define the rock materials
    fprintf(fileID_final,'%s\n%s\n','*Solid Section, elset=Rock_100mpa, material=Material-1','1.');
    fprintf(fileID_final,'%s\n%s\n%e, %f\n','*Material, name=Material-1','*Elastic',30.0e+09,0.2);
    fprintf(fileID_final,'%s\n%s\n','*Solid Section, elset=Rock_200mpa, material=Material-2','1.');
    fprintf(fileID_final,'%s\n%s\n%e, %f\n','*Material, name=Material-2','*Elastic',30.0e+09,0.2);
    
    %Define some group of nodes
    Node_rock_1=(mesh_seed(1)+1)*(mesh_seed(2)+1);
    fprintf(fileID_final,'%s\n%d, %d, %d\n','*Nset, nset=Rock_1_left,generate',1,(mesh_seed(1)+1)*mesh_seed(2)+1,mesh_seed(1)+1);
    fprintf(fileID_final,'%s\n%d, %d, %d\n','*Nset, nset=Rock_3_right,generate',Node_rock_1+mesh_seed(1)+1,Node_rock_1*2,mesh_seed(1)+1);
    fprintf(fileID_final,'%s\n%d, %d\n','*Nset, nset=Rock_1_top,generate',(mesh_seed(1)+1)*mesh_seed(2)+1,Node_rock_1);
    fprintf(fileID_final,'%s\n%d, %d\n','*Nset, nset=Rock_3_top,generate',Node_rock_1*2-mesh_seed(1),Node_rock_1*2);
    fprintf(fileID_final,'%s\n%d, %d\n','*Nset, nset=Rock_1_bottom,generate',1,mesh_seed(1)+1);
    fprintf(fileID_final,'%s\n%d, %d\n','*Nset, nset=Rock_3_bottom,generate',Node_rock_1+1,Node_rock_1+1+mesh_seed(1));

 %Define the initial gap and other initial conditions
 
    fprintf(fileID_final,'%s\n%d\n','*INITIAL CONDITIONS,TYPE=INITIAL GAP',element_number_start);
    fprintf(fileID_final,'%s\n%s, %s\n','*INITIAL CONDITIONS,TYPE=STRESS','Rock_1_1',confining_stress{1,1});
    fprintf(fileID_final,'%s\n%s, %s\n','*INITIAL CONDITIONS,TYPE=STRESS','Rock_3_1',confining_stress{1,1});
    fprintf(fileID_final,'%s\n%s, %s\n','*INITIAL CONDITIONS,TYPE=STRESS','Rock_1_2',confining_stress{2,1});
    fprintf(fileID_final,'%s\n%s, %s\n','*INITIAL CONDITIONS,TYPE=STRESS','Rock_3_2',confining_stress{2,1});
%
    fprintf(fileID_final,'%s\n%d\n','*elset,elset=one',element_number_start);
 % Define the boundary conditions
     fprintf(fileID_final,'%s\n%s\n%s\n','*Boundary','Rock_1_left, 1, 1','Rock_3_right, 1, 1');
     fprintf(fileID_final,'%s\n%s\n%s\n','*Boundary','Rock_1_bottom, 2, 2','Rock_3_bottom, 2, 2');
% Define the magnitute of volume rate
     fprintf(fileID_final,'%s\n%s\n','*Amplitude, name=volumerate','0.0,0.0, 0.0001,-1');

 %Define the solving step of the cohesive elements
      fprintf(fileID_final,'%s\n','*Step, name=Step-1, nlgeom=YES, inc=5000, unsymm=YES');
      fprintf(fileID_final,'Injection over %f second\n',simu_time);
      fprintf(fileID_final,'%s\n','*Soils, consolidation, end=PERIOD, utol=28000000.00');
      fprintf(fileID_final,'%f, %f, %f, %f\n',0.001,simu_time,0.00001, 0.1);
      fprintf(fileID_final,'%s\n%s\n','*Controls, PARAM=FIELD, FIELD=DISPLACEMENT','0.00001,0.00001');
% Apply the fluid flow
      fprintf(fileID_final,'%s\n','*cflow,amplitude=volumerate');
      fprintf(fileID_final,'%d, ,<qbound>\n',mouth);
      
 % Output requests
       fprintf(fileID_final,'%s\n','*Restart, write, frequency=20, overlay');
       fprintf(fileID_final,'%s\n%s\n%s\n%s\n','*Output, field', '*Node Output','U','por');
       fprintf(fileID_final,'%s\n%s\n%s\n%s\n%s\n','*element output','LE', 'S','SDEG','PFOPEN');
       fprintf(fileID_final,'%s\n%s\n%s\n%s\n%s\n','*Output, history, variable=PRESELECT', '*node output,nset=mouth','por','*node output,nset=mcod','u1');
       fprintf(fileID_final,'%s\n%s\n%s\n%s\n','*el print', 'SDEG','PFOPEN','*End Step');      
fclose(fileID_final);
%% Submit the inp file to solver
%system(['abaqus ','job',strcat('=C:\Users\User\Documents\MATLAB\01_by_Python\',submitinp_name)])
tic
cd(strcat(currentWorkFolder,'\',targetFile_pathNS))
system(['abaqus ','job',strcat('=',submitinp_name_sys,' int')]);
toc
%suspend job
% system(['abaqus ','suspend job',strcat('=',submitinp_name_sys)]);
%resume job
% system(['abaqus ','resume job',strcat('=',submitinp_name_sys)]);
%terminate job
% system(['abaqus ','terminate job',strcat('=',submitinp_name_sys)]);










