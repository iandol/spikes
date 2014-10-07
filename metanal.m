function metanal(action)
%MetAnal(V1) Performs a meta-analysis of VS Tuning curve data

global version;
global meta;
global AnalysisMode;
global arrowpoint;
global ErrorMode;
global str;

%%%%%Check whether we are starting for the first time%%%
if nargin<1,
    action='Initialize';
 end
 
 %%%%%%%%%%%%%%See what MetAnal needs to do%%%%%%%%%%%%%
switch(action)
    
%%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%   
case 'Initialize' 
   metanal_UI;
   version='Meta-Analysis V1.3';
   box on;
   set(gcf,'Name', version); %Sets Version data
   gridvalue=0;
   addreplace=0;
   arrowpoint='';
   menu={'Standard Error';'Standard Deviation';'2 StdDevs';'2 StdErrs';'Variance'};
   ErrorMode='Standard Error';
   set(findobj('Tag','MAErrorMenu'),'String',menu);
   
%%%%%%%%%%%%%%%%%Load a Meta-Analysis File%%%%%%%%%%%%%%%
case 'Load'
   cla;
   meta='';
   set(findobj('Tag','MACellCheck'),'Value',0);
   set(findobj('Tag','MACellMenu'),'Enable','off');
   [file,path]=uigetfile('*.mat','Meta-Analysis:Choose Meta File');
   if ~file
      errordlg('No File Specified', 'Meta-Analysis Error')
   else     
   curr=pwd;
   cd(path);
   load(file);
   cd(curr);
   AnalysisMode=meta.type;
   switch(AnalysisMode)
   case 'Percentage Plot'
      menu={'Percentage Plot';'MinMax Analysis';'Raw Firing Data';'Distribution';'CurveFit'};
      set(findobj('Tag','MAAnalysisMenu'),'String',menu);
   case 'Patch Percentage Plot'
      menu={'Patch Percentage Plot';'MinMax Analysis';'Raw Firing Data'};
      set(findobj('Tag','MAAnalysisMenu'),'String',menu);
   case 'Error Bar Plot'
      menu={'MinMax Analysis';'Raw Firing Data'};
      set(findobj('Tag','MAAnalysisMenu'),'String',menu);
   end
   plotdata;
   
end  

%%%%%%%%%%Adds Cell data to the Meta-Analysis file%%%%%
case 'AddData'
   [file,path]=uigetfile('*.mat','Meta-Analysis:Choose Cell File');
   if ~file
      errordlg('No File Specified', 'Meta-Analysis Error');
   else     
   curr=pwd;
   cd(path);
   load(file);
   
   if isempty(meta)==1;
      meta.cell(1)=acell;
      meta.type=acell.type;
      meta.size=size(meta.cell,2);
      AnalysisMode=meta.type;
      switch(AnalysisMode)
      case 'Percentage Plot'
         menu={'Percentage Plot';'MinMax Analysis';'Raw Firing Data';'Distribution';'CurveFit'};
         set(findobj('Tag','MAAnalysisMenu'),'String',menu);
         AnalysisMode='Percentage Plot';
      case 'Patch Percentage Plot'
         menu={'Patch Percentage Plot';'MinMax Analysis';'Raw Firing Data'};
         set(findobj('Tag','MAAnalysisMenu'),'String',menu);
         AnalysisMode='Patch Percentage Plot';
      case 'Error Bar Plot'
         menu={'MinMax Analysis';'Raw Firing Data'};
         set(findobj('Tag','MAAnalysisMenu'),'String',menu);
         AnalysisMode='MinMax Analysis';
      end

   else
      if strcmp(meta.type,acell.type)==0;
         errordlg('File Incompatibility Error', 'Meta-Analysis Error');
      else         
         meta.cell(meta.size+1)=acell;
         meta.size=size(meta.cell,2);
      end 
   end
   cd(curr);
   if ~isempty(meta)
      plotdata;
   end
end


%%%%%%%%Saves Values for Use by Other Routines%%%%%%%%%
case 'Save'
   [file,path] = uiputfile('d:\a\newfile.mat',version);    
   if ~file
      errordlg('No File Specified', version)   
   else   
   curr=pwd;
   cd(path);
   save(file, 'meta');
   cd(curr);
   end
   
%%%%%%%Saves as text to Import into Statistica etc%%%%
case 'SaveText'     
   per=zeros(meta.size,size(meta.cell(1).data,1));
   fir=zeros(meta.size,size(meta.cell(1).data,1));
   discont=zeros(meta.size,2)
   for i=1:meta.size
      per(i,:)=meta.cell(i).data(:,5)';
      fir(i,:)=meta.cell(i).data(:,3)';
      discont(i,1)=max(meta.cell(i).data(:,5));
      discont(i,2)=meta.cell(i).data(4,5);
   end
   per
   fir
   
   [file,path] = uiputfile('c:\*.txt',version);    
   if ~file
      errordlg('No File Specified', version)   
   else  
   space=0
   curr=pwd;
   cd(path);
   save(file, 'per', 'space', 'fir', 'space', 'discont', '-ascii');
   cd(curr);
   end   

   
%%%%%%%%%%%%%%Clears current axes data%%%%%%%%%%%%%%%%
case 'Clear'
   cla reset;
   meta='';
   
%%%%%%%%%%%%%%%%%Re-Plots Data%%%%%%%%%%%%%%%%%%%%%
case 'Plot'
   plotdata;
   
%%%%%%%%%%%%%%%%Shows Values for Plot%%%%%%%%%%%%%%%%
case 'Values'
   if isempty(meta)
      msgbox('No Values, has file been loaded?','Meta-Analysis Message','help');
   else
      switch(AnalysisMode)
         
      case 'Percentage Plot'
         for i=1:meta.size
            percentage(:,i)=meta.cell(i).data(:,5);
         end
         error=num2str(errorfun(percentage',ErrorMode)');
         yvalues=num2str(mean(percentage'));
         num=num2str(meta.size);
         
      case 'Patch Percentage Plot'
         for i=1:meta.size            
            percentage(:,i)=meta.cell(i).data(:,5); 
         end
         error=num2str(errorfun(percentage',ErrorMode)');
         yvalues=num2str(mean(percentage'));
         num=num2str(meta.size);
         
      case 'MinMax Analysis'
         for i=1:meta.size
            data(:,i)=meta.cell(i).data(:,3);
            minmax(:,i)=(data(:,i)-min(data(:,i)))/(max(data(:,i)-min(data(:,i))))*100;            
         end
         error=num2str(errorfun(minmax',ErrorMode)');
         yvalues=num2str(mean(minmax'));
         num=num2str(meta.size);
         
      case 'Raw Firing Data'  
         for i=1:meta.size
            data(:,i)=meta.cell(i).data(:,3);
         end
         error=num2str(errorfun(data',ErrorMode)');
         yvalues=num2str(mean(data'));
         num=num2str(meta.size);
         
      case 'Distribution'
         for i=1:meta.size
            data(:,i)=meta.cell(i).data(:,3);
         end
         error=num2str(errorfun(data',ErrorMode)');
         yvalues=num2str(mean(data'));
         num=num2str(meta.size);
         
      end 
      
      ret=' '; 
      str1='Values:';
      str2='Error:';
      str3='Number of Cells:';
      str=strvcat(str3,num,ret,str1,yvalues,ret,str2,error);
      msgbox(str,'Meta-Analysis Data Values','help'); 
      
   end
   


   
%%%%%%%%%%%%%%%%Choose type of Analysis%%%%%%%%%%%%%%%   
case 'AnalOpts'
   Value=get(findobj('Tag','MAAnalysisMenu'),'Value');
   String=get(findobj('Tag','MAAnalysisMenu'),'String');
   Str=String{Value};
   switch(Str)
   case 'Percentage Plot'
      AnalysisMode='Percentage Plot';
      if ~isempty(meta)
         plotdata;
      end    
   case 'Patch Percentage Plot'
      AnalysisMode='Patch Percentage Plot';
      if ~isempty(meta)
         plotdata;
      end      
   case 'MinMax Analysis'
      AnalysisMode='MinMax Analysis';
      if ~isempty(meta)
         plotdata;
      end    
   case 'Raw Firing Data'
      AnalysisMode='Raw Firing Data';
      if ~isempty(meta)
         plotdata;
      end   
      case 'Distribution'
      AnalysisMode='Distribution';
      if ~isempty(meta)
         plotdata;
      end 
      case 'CurveFit'
      AnalysisMode='CurveFit';
      if ~isempty(meta)
         plotdata;
      end 


   end
   
%%%%%%%%%%%%%%%%Choose type of Analysis%%%%%%%%%%%%%%%   
case 'ErrorType'
   Value=get(findobj('Tag','MAErrorMenu'),'Value');
   String=get(findobj('Tag','MAErrorMenu'),'String');
   Str=String{Value};
   switch(Str)
   case 'Standard Error'
      ErrorMode='Standard Error';
      plotdata;
   case 'Standard Deviation'
      ErrorMode='Standard Deviation';
      plotdata;
   case '2 StdDevs'
      ErrorMode='2 StdDevs';
      plotdata;
   case '2 StdErrs'
      ErrorMode='2 StdErrs';
      plotdata;
   case 'Variance'
      ErrorMode='Variance';
      plotdata;
   end
   
%%%%%%%%%%%%%%To see individual plots%%%%%%%%%%%%%%%%
case 'InitCell'
   Value=get(findobj('Tag','MACellCheck'),'Value');
   if Value==1;      
      str='';
      for i=1:meta.size         
         str{i}=strtok(meta.cell(i).header); 
	  end 
	  str=str';
	  if get(findobj('Tag','MACellMenu'),'Value') > meta.size
		  set(findobj('Tag','MACellMenu'),'Value',1);
	  end
      set(findobj('Tag','MACellMenu'),'Visible','on');
	  set(findobj('Tag','MACellMenu'),'Enable','on');  
      set(findobj('Tag','MACellMenu'),'String',str);
	  metanal('SeeCell')
   else
      set(findobj('Tag','MACellMenu'),'Enable','off');      
      plotdata;
   end
   
%%%%%%%%%%%%%%To see individual plots%%%%%%%%%%%%%%%%
case 'SeeCell'
   Value=get(findobj('Tag','MACellMenu'),'Value');
   data=meta.cell(Value).data;
   plotcell(data,Value);   
   
   
%%%%%%Allows the graph to be reproduced for saving%%%%   
case 'Spawn'   
   if  isempty(meta) 
      errordlg('No File Specified',version);
   else       
      SpawnPlot(gca);
   end
   
   
%%%%%%%%%%%%%%%%%Set Axis properties%%%%%%%%%%%%%%%%%%   
case 'Axis'
   val=get(findobj('Tag','MAAxeschk'), 'Value');
   if val == 1
      axis auto;      
      set(findobj('UserData','AxesValues'),'Enable', 'off');
   else      
      xmin=str2num(get(findobj('Tag','MAXmintext'),'String'));
      xmax=str2num(get(findobj('Tag','MAXmaxtext'),'String'));
      ymin=str2num(get(findobj('Tag','MAYmintext'),'String'));
      ymax=str2num(get(findobj('Tag','MAYmaxtext'),'String'));      
      axis([xmin xmax ymin ymax]);   
      set(findobj('UserData','AxesValues'),'Enable', 'on');
   end
   
%%%%%%%%%%%%%%%Arrow%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'Arrow'
   val=get(findobj('Tag','Arrowchk'), 'Value');
   if val == 1      
      set(findobj('Tag','Arrowtext'),'Enable', 'on')
      arrowpoint=str2num(get(findobj('Tag','Arrowtext'), 'String'));
   else
      arrowpoint=str2num('')
      set(findobj('Tag','Arrowtext'),'Enable', 'off')
   end
   
%%%%%%%%%%%%%%%%%Show Meta-File Data%%%%%%%%%%%%%%%%%   
case 'Header'
   if isempty(meta)
      msgbox('No Values, has file been loaded?','Meta-Analysis Message','help');
   else
      msg='';
      str='';
      for i=1:meta.size
         str{i}=strtok(meta.cell(i).header);
         msg = strvcat(msg,str{i});
      end    
      msgbox(msg,'Cells Included in Analysis:','help');
   end
   
   
%%%%%%%%%%%%%%%%%Turn grid on or off%%%%%%%%%%%%%%%%%   
case 'Grid'
   gridvalue=get(gcbo, 'Value');
   if gridvalue == 1      
      grid on
   else
      grid off
   end   
   
%%%%%%%%%%%%%%%%%Close the Program%%%%%%%%%%%%%%%%%%%%   
case 'Finish' 
   clear meta
   close(gcf)
  


end   % end of main switch

function plotdata()
% Function to Plot the Meta-analysis

global meta;
global AnalysisMode;
global arrowpoint;
global ErrorMode;
global ydata;
global data;

box on
cla reset
switch(AnalysisMode)
case 'Percentage Plot'
   for i=1:meta.size      
      percentage(:,i)=meta.cell(i).data(:,5);
   end
   xvalues=meta.cell(1).data(:,2);
   ydata=percentage;
   type=ErrorMode;
   areabar(xvalues,ydata,type); 
   title('Meta-Analysis of Percentage Suppression');
   ylabel('Percentage Suppression of BaseLine (%) \pm 1 S.E.M','FontName','Arial','FontSize', 12);
   Value=get(findobj('Tag','MAXaxisMenu'),'Value');
   String=get(findobj('Tag','MAXaxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',12);
   
case 'Patch Percentage Plot'
   for i=1:meta.size      
      percentage(:,i)=meta.cell(i).data(:,5);
   end
   xvalues=meta.cell(1).data(:,2);
   ydata=percentage';
   type=ErrorMode;
   areabar(xvalues,ydata,type); 
   title('Meta-Analysis of Normalised Patch Tuning Curves');
   ylabel('Normalised Percentage of Patch (%) \pm 1 S.E.M','FontName','Arial','FontSize', 12);
   Value=get(findobj('Tag','MAXaxisMenu'),'Value');
   String=get(findobj('Tag','MAXaxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',12);
   
case 'MinMax Analysis'
   for i=1:meta.size  
      raw(:,i)=meta.cell(i).data(:,3);
      minmax(:,i)=(raw(:,i)-min(raw(:,i)))/(max(raw(:,i)-min(raw(:,i))))*100;
   end
   xvalues=meta.cell(1).data(:,2);
   ydata=minmax;
   type=ErrorMode;
   areabar(xvalues,ydata,type);
   title('Meta-Analysis of MinMax Normalised Data')
   ylabel('Percentage Firing of MinMax(%) \pm 1 S.E.M','FontName','Arial','FontSize', 12);
   Value=get(findobj('Tag','MAXaxisMenu'),'Value');
   String=get(findobj('Tag','MAXaxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',12);
   
case 'Raw Firing Data'
   for i=1:meta.size
      raw(:,i)=meta.cell(i).data(:,3); 
   end
   xvalues=meta.cell(1).data(:,2);
   ydata=raw;
   type=ErrorMode;
   areabar(xvalues,ydata,type); 
   title('Meta-Analysis of Raw Firing Data')
   ylabel ('Firing Rate (i/s) \pm 1 S.E.M','FontName','Arial','FontSize', 12);
   Value=get(findobj('Tag','MAXaxisMenu'),'Value');
   String=get(findobj('Tag','MAXaxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',12);

case 'Distribution'
   
   for i=1:meta.size  
      x=meta.cell(i).data(:,2);
      y=meta.cell(i).data(:,5);
      p1=polyfit(x(4:5),y(4:5),1);
      p1=polyval(p1,x(4:5));
      p2=polyfit(x(6:8),y(6:8),1);
      p2=polyval(p2,x(6:8));
      plot(x,y,x(4:5),p1,x(6:8),p2)
      slope1(i)=(p1(2)-p1(1))/(x(5)-x(4));
      slope2(i)=(p2(3)-p2(1))/(x(8)-x(6));
      text(2,max(y)/1.5,[num2str(slope1(i)) '  |  ' num2str(slope2(i))]);
      pause(0.25)
   end
   slope1;
   slope2;
   value=slope1./slope2;
   assignin('base','slope1', slope1);
   assignin('base','slope2', slope2);
   assignin('base','sloperatio', value);
   hist(value,10)
   title('Distribution of Cells');
   ylabel('Number of Cells','FontName','Arial','FontSize', 12);   
   xlabel('Ratio of Continuous/Discontinuous','FontName','Arial','FontSize',12);

case 'CurveFit'
   hold on
   for i=1:meta.size 
      x1(i,:)=[meta.cell(i).data(4,2), meta.cell(i).data(5,2)];
      y1(i,:)=[meta.cell(i).data(4,5), meta.cell(i).data(5,5)];
      y1(i,:)=y1(i,:)/mean(y1(i,:));
      val=curvefit(x1(i,:),y1(i,:),1,[0 0 1]);
      p1(i)=val(1);
      x2(i,:)=[meta.cell(i).data(6,2), meta.cell(i).data(7,2), meta.cell(i).data(8,2)];
      y2(i,:)=[meta.cell(i).data(6,5), meta.cell(i).data(7,5), meta.cell(i).data(8,5)];
      y2(i,:)=y2(i,:)/mean(y2(i,:));
      val=curvefit(x2(i,:),y2(i,:),1,[0 0 1]);
      p2(i)=val(1);
      x(i)=p1(i)-p2(i);
   end
   p1=p1';
   p2=p2';
   x=x';
   hold off
   axis([0  8.5 -inf inf]);
   figure
   %hist(x)
   %save('c:\temp.mat', 'p1',  'p2',  'x')
   
   doangle=1;
   if doangle==1
      for i=1:meta.size
         xa=x1(i,2)-x1(i,1);         
         ya=(y1(i,2)-y1(i,1))*8
         xb=x2(i,3)-x2(i,1);
         yb=(y2(i,3)-y2(i,1))*8
         
         angle1(i)=90-(180/pi*atan((abs(ya)/abs(xa))));
         angle2(i)=90-(180/pi*atan((abs(yb)/abs(xb))));
         
         %if (xa>=0 & ya>=0) | (xa<=0 & ya<=0)
         %   
         %elseif (xa>=0 & ya<=0) | (xa<=0 & ya>=0)
         %   angle1(i)=angle1(i)-(2*angle1(i));  
         %end  
         %if (xb>=0 & yb>=0) | (xb<=0 & yb<=0)
         %   
         %elseif (xb>=0 & yb<=0) | (xb<=0 & yb>=0)
         %   angle2(i)=angle2(i)-(2*angle2(i));  
         %end               
      end
      angle1;
      angle2;
	  assignin('base','angle1', angle1);
	  assignin('base','angle2', angle2);
      %x=55:1:95
      angle1=angle1*(pi/180);
      angle2=angle2*(pi/180);
      [r,t]=rose(angle1);
      [r2,t2]=rose(angle2);  
      r=[r',r2'];
      t=[t',t2'];
      polar(r,t);
   end
   
   
end %end of switch

if ~isempty(arrowpoint);    %draw iso-freq arrow
   axis(axis);
   m=min(mean(ydata))/2
   arrow([arrowpoint 0],[arrowpoint m]);
end  


function plotcell(data,Value)
% Plots individual cell
global meta;

cla;
xvalues=data(:,2);
yvalues=data(:,3);
error=data(:,4);
x=size(data,1);
err=zeros(x+x,1);
err(1:x,1)=yvalues+error;
err(x+1:x+x,1)=flipud(yvalues-error);
areax=zeros(x+x,1);
areax(1:x,1)=xvalues;
areax(x+1:x+x,1)=flipud(xvalues);
hold on;
fill(areax,err,[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);
plot(xvalues,yvalues,'k.-','MarkerSize',22.5);
title(meta.cell(Value).header)
ylabel ('Firing Rate (i/s) \pm 1 S.E.M','FontName','Arial','FontSize', 12);
hold off;



function areabar(xvalues,ydata,type)
% Performs an errorbar plot using a single polygon

global meta

cla;
set(gca,'NextPlot','replacechildren');
yvalues=mean(ydata')';
type=type;
error=errorfun(ydata',type);
x=size(meta.cell(1).data,1);
err=zeros(x+x,1);
err(1:x,1)=yvalues+error;
err(x+1:x+x,1)=flipud(yvalues-error);
areax=zeros(x+x,1);
areax(1:x,1)=xvalues;
areax(x+1:x+x,1)=flipud(xvalues);
hold on;
fill(areax,err,[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);
plot(xvalues,yvalues,'k.-','MarkerSize',22.5);
hold off;

function error = errorfun(data,type)
% Computes the Error Data

global meta

switch(type)
   
case 'Standard Error' 
   err=std(data)';
   error=sqrt(err.^2/size(data,1));  
case 'Standard Deviation'
   error=std(data)';
case '2 StdDevs' 
   error=std(data)'*2;
case '2 StdErrs' 
   err=std(data)';
   error=sqrt((err.^2/size(data,2)))*2;   
case 'Variance'
   error=std(data)'.^2;
   
end

function SpawnPlot(plothandle)
%To plot current info on new object
childfigure=figure;
copyobj(plothandle,childfigure, 'legacy')
set(gca,'Position',[44.25 43.5 341.25 253.5])
set(gca,'Units','Normalized');
axis normal

