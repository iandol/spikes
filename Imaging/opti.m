function opti(action)

% Opti loads and subracts data frames from a file

global optdata


if nargin<1;
   action='Initialize';
end

switch(action)    %As we use the GUI this switch allows us to
                  %respond to the user input
   
case 'Initialize'   %assuming we have just started
	optifig
	optdata.frame0indx=[0 1 2 3];
	optdata.dataframeindx=[4 5 6 7 8 9 10 11];
	optdata.clip=3;

case 'Load'
	[file dirpath]=uigetfile('*.*','Load Imaging BlockFile');
   	if isempty(file), break, end;
   	cd(dirpath)
      [optdata.frame0, x, y]=loadsumh(file, optdata.frame0indx, 1);
      optdata.frame0=reshape(optdata.frame0,x,y);
      [optdata.dataframe, x, y]=loadsumh(file, optdata.dataframeindx, 1);
      optdata.dataframe=reshape(optdata.dataframe,x,y)
      optdata.frame0=rot90(clip(optdata.frame0, optdata.clip));
   	optdata.dataframe=rot90(clip(optdata.dataframe, optdata.clip));
      optdata.data=optdata.dataframe-optdata.frame0;
      
      colormap(bone);
      
      axes(findobj('Tag','Axes1'));      
      imagesc(optdata.frame0);
      set(gca,'FontSize',4);
      colorbar
      set(gca,'Tag','Axes1');
      
      axes(findobj('Tag','Axes2'));
      imagesc(optdata.dataframe);
      set(gca,'FontSize',4);
      colorbar
      set(gca,'Tag','Axes2');
      
      axes(findobj('Tag','Axes3'));
      imagesc(optdata.data);
      set(gca,'FontSize',4);
      colorbar
      set(gca,'Tag','Axes3');
      
case 'Export'
	


end


function data=clip(data, sd)
%clips the data around the median value

med=median(median(data));
sd=mean(std(data))*sd;

data=data-med;

indx1=find(data>0+sd);
indx2=find(data<0-sd);
data(indx1)=0+sd;
data(indx2)=0-sd;







	