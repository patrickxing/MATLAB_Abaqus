function [Node_cohesive, Element_cohesive,mouth,mcod]=no_triangle(min_node_number_up,num_division,line_start_pt,line_last_pt,element_number_start,name_flag,file_location)
%% ==================== Nodes =========================
% Creating points:
% preparing upper points:
%min_node_number_up=200000;
%num_division=1200;   % total number of elements on that line
%line_start_pt=[0,0];    % the start point of the line of cohesive [x_min,y_min]
%line_last_pt=[0.,0.15];     % the last point of the line of cohesive [x_max,y_max]
node_numbers_up=linspace(min_node_number_up,min_node_number_up+num_division,num_division+1);
if line_start_pt(1) ~= line_last_pt(1)
    % This line can be modifided to work for the vertical line
    y=@(x) line_start_pt(2)+((line_last_pt(2)-line_start_pt(2))./(line_last_pt(1)-line_start_pt(1))).*(x-line_start_pt(1));
    node_x_up=linspace(line_start_pt(1),line_last_pt(1),num_division+1);
    node_y_up=y(node_x_up);
elseif (line_start_pt(1) == line_last_pt(1)) && line_start_pt(2) ~= line_last_pt(2) 
    node_x_up=line_start_pt(1)*ones(1,num_division+1);
    node_y_up=linspace(line_start_pt(2),line_last_pt(2),num_division+1);
else
    error('give different points on the line of CZM');
end
% preparing lower points:
min_node_number_lower=min_node_number_up+num_division+100;
node_numbers_lower=linspace(min_node_number_lower,min_node_number_lower+num_division,num_division+1);
node_x_lower=node_x_up;
node_y_lower=node_y_up;

% preparing middle points:
min_node_number_middle=min_node_number_lower+num_division+100;
node_numbers_middle=linspace(min_node_number_middle,min_node_number_middle+num_division,num_division+1);
node_x_middle=node_x_up;
node_y_middle=node_y_up;

node_numbers=[node_numbers_up,node_numbers_lower,node_numbers_middle];
node_x=[node_x_up,node_x_lower,node_x_middle];
node_y=[node_y_up,node_y_lower,node_y_middle];
points=[node_numbers;node_x;node_y]';

fileID = fopen(strcat(file_location,'/Nodes_cohesive_',name_flag,'.txt'),'wt');
fprintf(fileID,'%7g,%13.8f,%13.8f\n',points');
fclose(fileID);

fileID=fopen(strcat(file_location,'/Nodes_cohesive_',name_flag,'.txt'));
Node_cohesive=textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);
Node_cohesive=Node_cohesive{1,1};

mouth=min_node_number_middle;
mcod=[min_node_number_up,min_node_number_lower];
%% =================== Cohesive =======================
% input:
%Generating cohesive zone element connections:
upper_start=min_node_number_up;
lower_start=min_node_number_lower;
middle_start=min_node_number_middle;
% if Upper node numbers are increasing along the crack put 1 else -1
gener_upper=1;
% if Middle node numbers are increasing along the crack put 1 else -1
gener_middle=1;
% if Lower node numbers are increasing along the crack put 1 else -1
gener_lower=1;
%element_number_start;    % starting number of the cohesive element
%if it is pore pressure element put 1 unless 0
pore_choose=1;
% give the last number of the either upper or lower node
last_node=min_node_number_up+num_division;
vectorInp=[upper_start,middle_start,lower_start];
tzg=sort(vectorInp);
zg=max(find(tzg<=last_node));
kgb=find([upper_start,middle_start,lower_start]==tzg(zg));
% calculation:
if pore_choose==0
    out_connection=zeros(length(vectorInp(kgb):last_node)-1,5);
    for i=1:length(vectorInp(kgb):last_node)-1
        out_connection(i,1)=element_number_start+i-1;
        out_connection(i,2:3)=[lower_start+(i-1)*gener_lower,lower_start+i*gener_lower];
        out_connection(i,4:5)=[upper_start+i*gener_upper,upper_start+(i-1)*gener_upper];
    end
    out_connection(end,3:4)=[last_node,last_node];
    fileID = fopen('C:/Users/User/Desktop/Abaqus/10-28-2014/Element_connectivity_cohesive.txt','wt');
    fprintf(fileID,['%' num2str(ceil(log10(max(out_connection(:,1))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,2))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,3))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,4))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,5))))+1) 'g\n'],out_connection');
    fclose(fileID);
    %type('Element_connectivity_cohesive.txt');
elseif pore_choose==1
    out_connection=zeros(length(vectorInp(kgb):last_node)-1,7);
    for i=1:length(vectorInp(kgb):last_node)-1
        out_connection(i,1)=element_number_start+i-1;
        out_connection(i,2:3)=[lower_start+(i-1)*gener_lower,lower_start+i*gener_lower];
        out_connection(i,4:5)=[upper_start+i*gener_upper,upper_start+(i-1)*gener_upper];
        out_connection(i,6:7)=[middle_start+(i-1)*gener_middle,middle_start+i*gener_middle];
    end
    %out_connection(end,3:4)=[last_node,last_node];
    fileID = fopen(strcat(file_location,'/Element_connectivity_cohesive-',name_flag,'.txt'),'wt');
    fprintf(fileID,['%' num2str(ceil(log10(max(out_connection(:,1))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,2))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,3))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,4))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,5))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,6))))+1) 'g,%' num2str(ceil(log10(max(out_connection(:,7))))+1) 'g\n'],out_connection');
    fclose(fileID);
    fileID=fopen(strcat(file_location,'/Element_connectivity_cohesive-',name_flag,'.txt'));
    Element_cohesive=textscan(fileID,'%s','Delimiter','\n');
    fclose(fileID);
    Element_cohesive=Element_cohesive{1,1};

end






