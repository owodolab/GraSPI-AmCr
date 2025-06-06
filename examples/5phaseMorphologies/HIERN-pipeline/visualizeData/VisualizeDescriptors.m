

%load data

%[name DESC_3a DESC_3b DESC_3c STAT_n] = csvimport('AllDescriptors.txt', 'columns', {'name', 'DESC_3a', 'DESC_3b', 'DESC_3c', 'STAT_n',});

Data=readmatrix("AllDescriptors.txt",'NumHeaderLines',1);


fid = fopen('AllDescriptors.txt','r');
t = textscan(fid,'%s','delimiter',' ');
fclose(fid);

MorphNames=[];
Data=[];

      % try to open the file
      fid = fopen('AllDescriptors.txt','r');
      if fid > 0
          % loop over each line until the end of file (eof) is reached
          while ~feof(fid)
             % grab the next line in the file
              lineTxt = fgetl(fid);
               % character as the delimiter
               cellArray = strsplit(lineTxt,' ');
               % grab the second element of the array
               morph=convertCharsToStrings(cellArray{1});

               MUeG  = str2num(cellArray{2});%effective Elec mobility
               MUhG  = str2num(cellArray{3});%effective Hole mobility
               KrG   = str2num(cellArray{4});%krec normalized with N2
               ETAdG = str2num(cellArray{5});

               MorphNames=[MorphNames; morph];
                
               fprintf("v:%f v:%f v:%f v:%f\n",MUeG,MUhG,KrG,ETAdG);
               
               Data=[Data;[MUeG,MUhG,KrG,ETAdG]];
   
              end
       end
       % close the file
       fclose(fid);


       DataLabels = [1,2,3,4,5,6,7,8,9,10,11,12,13] ;
       figure; set(gca,'FontSize',18);
       hold on;
       xtickangle(90)
       xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
       xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
       ylabel('$\mu_e^g$', 'Interpreter', 'latex')
       plot(DataLabels(:),(Data(:,1)),'o','MarkerFaceColor', 'b');
       print('MUeG','-dpng');

       figure; set(gca,'FontSize',18);
       hold on;
       xtickangle(90)
       xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
       xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
       ylabel('$\mu_h^g$', 'Interpreter', 'latex')
       plot(DataLabels(:),(Data(:,2)),'o','MarkerFaceColor', 'b');
       print('MUhG','-dpng');

       figure; set(gca,'FontSize',18);
       hold on;
       xtickangle(90)
       xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
       xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
       ylabel('$k_r^g$', 'Interpreter', 'latex')
       plot(DataLabels(:),(Data(:,3)),'o','MarkerFaceColor', 'b');
       print('KrG','-dpng');


       figure; set(gca,'FontSize',18);
       hold on;
       xtickangle(90)
       xticks([1 2 3 4 5 6 7 8  9 10 11 12 13])
       xticklabels({ '19sv45','19sv89', '20sv54','20sv80', '20sv99', '21sv193', '21sv65', '24sv125', '24sv56', '26sv101', '26sv210', '32sv46', '32sv80'});
%       ylabel('\eta_d^g');
       ylabel('$\eta_d^g$', 'Interpreter', 'latex')
       plot(DataLabels(:),Data(:,4),'o','MarkerFaceColor', 'b');
       print('ETAdG','-dpng');




   