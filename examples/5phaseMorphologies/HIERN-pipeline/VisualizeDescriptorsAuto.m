function [ ElecDescriptorValues, ElecDescriptorNames ] = VisualizeDescriptorsAuto( NameFileSave, TimeStepChoice, hhh, numworkflow, ResultsSaveFile )

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the data from the file written by Olga's Graspi routine 5-ExtractDescriptors2.sh
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File ResultsSaveFile with location/Name: [NameFolderGraspi 'visualizeData/Descriptors' NameFileSave '_' num2str(numworkflow) '.txt']
% THIS IS THE IMPORTANT FILE WE USE THE DATA FROM IN THE DD1D SIMULATIONS!!!
% This contains the four electronic descriptors for several morphologies

% Data=readmatrix([ResultsSaveFile],'NumHeaderLines',1);
% fid = fopen([ResultsSaveFile],'r');
% t = textscan(fid,'%s','delimiter',' ');
% fclose(fid);

MorphNames = [];
Data = [];

fid = fopen(ResultsSaveFile,'r');
if ( fid > 0 )
	
	% loop over each line until the end of file (eof) is reached
	while ~feof(fid)
		
		% Grab the next line in the file
		lineTxt = fgetl(fid);
		% Character as the delimiter
		cellArray = strsplit(lineTxt,' ');
		
		% Morphology name
		morph = convertCharsToStrings(cellArray{1});
		MorphNames = [MorphNames; morph];
		
		% Electronic descriptor values
		MUeG  = str2num(cellArray{2}); % effective Elec mobility
		MUhG  = str2num(cellArray{3}); % effective Hole mobility
		KrG   = str2num(cellArray{4}); % krec normalized with N2
		ETAdG = str2num(cellArray{5}); % Exciton dissociation efficiency
		
		% Print to the command window for check
		fprintf("MUeG = %f, MUhG = %f, KrG = %f, ETAdG = %f\n",MUeG,MUhG,KrG,ETAdG);
		disp(['hhh=' num2str(hhh)])
		
		% Concatenate into a matrix
		Data = [Data;[MUeG,MUhG,KrG,ETAdG]];
		
	end
	
end
% close the file
fclose(fid);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Organize the data for output and further use
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ElecDescriptorNames = {'MUeG','MUhG','KrG','ETAdG'};
index = find(MorphNames==['Morph' NameFileSave '_sv_'  num2str(TimeStepChoice(hhh)) '_wf_' num2str(numworkflow)]);
ElecDescriptorValues = Data(index-1,:);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures for checks / Analysis
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%        DataLabels = [1,2,3,4,5,6,7,8,9,10,11,12,13] ;
%        figure; set(gca,'FontSize',18);
%        hold on;
%        xtickangle(90)
%        xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
%        xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
%        ylabel('$\mu_e^g$', 'Interpreter', 'latex')
%        plot(DataLabels(:),(Data(:,1)),'o','MarkerFaceColor', 'b');
%        print('MUeG','-dpng');
%
%        figure; set(gca,'FontSize',18);
%        hold on;
%        xtickangle(90)
%        xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
%        xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
%        ylabel('$\mu_h^g$', 'Interpreter', 'latex')
%        plot(DataLabels(:),(Data(:,2)),'o','MarkerFaceColor', 'b');
%        print('MUhG','-dpng');
%
%        figure; set(gca,'FontSize',18);
%        hold on;
%        xtickangle(90)
%        xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
%        xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
%        ylabel('$k_r^g$', 'Interpreter', 'latex')
%        plot(DataLabels(:),(Data(:,3)),'o','MarkerFaceColor', 'b');
%        print('KrG','-dpng');
%
%
%        figure; set(gca,'FontSize',18);
%        hold on;
%        xtickangle(90)
%        xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
%        xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
% %       ylabel('\eta_d^g');
%        ylabel('$\eta_d^g$', 'Interpreter', 'latex')
%        plot(DataLabels(:),Data(:,4),'o','MarkerFaceColor', 'b');
%        print('ETAdG','-dpng');

end
