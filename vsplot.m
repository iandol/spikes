function vsplot(action)
%VSPLOT(V1.4) Plots data using errors from VS File
% VsPlot: Function to plot data from modified VS files 
% Simple plot of VS data to form a 2-D plot, ideas about 
% what to include will evolve here....


%%%%%%%%%%%%%%%%% Declare Global Variables%%%%%%%%%%%%
global gridvalue;
global version;
global data
global plottype;
global baseline;
global plotmode;
global addreplace;  
global header;      %Header data from vs file
global arrowpoint;  %For drawing Arrow at the iso-frequency point

%%%%%Check whether we are starting for the first time%%%
if nargin<1,
    action='Initialize';
 end
 
%%%%%%%%%%%%%%See what VSPlot needs to do%%%%%%%%%%%%%
switch(action)
    
%%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%   
case 'Initialize'   
   vsplotfig2; %This is our current GUI file
   version='VS-Plot v1.4';
   set(gcf,'Name', version) %Sets Version data
   gridvalue=0;
   plottype='Mean';
   plotmode='Error Bar Plot';
   baseline=25;   
   addreplace=0;
   arrowpoint='';
   set(gcf, 'DefaultLineLineWidth', 1.5);
   set(gcf, 'DefaultAxesLineWidth', 1.5);
   xtext={'Temporal Frequency of Surround Grating (Hz)';'Patch Diameter (deg)';...
   'Spot Diameter (deg)';'Angle with Optimum (deg)';'Diameter of Inner Wall of Annulus (deg)';...
   'Speed of Outer Texture Patch (deg/second)';'Temporal Frequency (Hz)';...
   'Spatial Frequency (cycles/degree)';'Contrast';'Luminance';'Temporal Difference'};
   typetext={'Error Bar Plot';'Error Bar2 Plot';'Percentage Plot';'Patch Percentage Plot';'Plateau Plot'};
   set(findobj('Tag','AnalMenu'),'String',typetext);
   set(findobj('Tag','XAxisMenu'),'String',xtext);
   if exist('c:\frogtemp'); delete('c:\frogtemp');end
   
%%%%%%%%%%%%%Load a Straight text file%%%%%%%%%%%%%%%
case 'Load' 
   %%%%%%%%%%%%%%Old style, pre-frogbit%%%%%%%%%%%%%%%%%%
   %[lfile,lpath]=uigetfile('*.*','VS-Plot V1.4: Choose File'); 
   %if ~lfile
   %   errordlg('No File Specified', version)
   %else  
   %end  
   %i = find(lfile == '.');
   %x = eval(lfile(1:(i-1))); %Just converts filename to Var x 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   dos('"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\vsstrip.FB"')
   curr=pwd;
   cd('c:\');   
   [header,x]=hdload('frogtemp');  % Loads file   
   cd(curr);
   set(gcbf, 'UserData', x);    %Put this info into the UserData    
   VSLocalPlot                  %Call plotting routine
   
%%%%%%%%Saves Values for Use by Other Routines%%%%%%%%%
case 'Save'
   [file,path] = uiputfile('d:\a\newfile.mat',version)    
   if ~file
      errordlg('No File Specified', version)   
   end   
   curr=pwd
   cd(path)
   if strcmp(plotmode,'Percentage Plot')
      x=get(gcbf,'UserData');
      data=zeros(size(x,1),6);
      data(:,1:6)=x(:,1:6);
      data(:,5)=(data(:,3)/str2num(baseline))*100; 
      data(:,6)=str2num(baseline);
      acell.header=header;
      acell.type='Percentage Plot';
      acell.data=data;
      save(file, 'acell')      
   elseif strcmp(plotmode,'Patch Percentage Plot') 
      x=get(gcbf,'UserData');
      data=zeros(size(x,1),5);
      data(:,1:5)=x(:,1:5);
      baseline=data(1,3);   %assumes this is the zero point
      ivalue=(data(:,3)-baseline);
      maxvalue=max(ivalue);
      data(:,5)=ivalue/maxvalue*100; %converts to percent of maximum
      acell.header=header;
      acell.type='Patch Percentage Plot';
      acell.data=data;
      save(file, 'acell')      
   elseif strcmp(plotmode,'Error Bar Plot')
      x=get(gcbf,'UserData');
      data=zeros(size(x,1),4);
      data(:,1:4)=x(:,1:4); 
      acell.header=header;
      acell.type='Error Bar Plot';
      acell.data=data;
      save(file, 'acell') 
   elseif strcmp(plotmode,'Error Bar2 Plot')      
      x=get(gcbf,'UserData');
      data=zeros(size(x,1),4);
      data(:,1:4)=x(:,1:4); 
      acell.header=header;
      acell.type='Error Bar Plot';
      acell.data=data;
      save(file, 'acell')
   end  
   
   cd(curr)
   
%%%%%%%%%%%%%%%%%Calls Plotting routine%%%%%%%%%%%%%%%%   
case 'Plot'
  if  isempty(get(gcf,'UserData'))   %Just check that we can plot
      errordlg('No Data Specified', version)
   else      
      VSLocalPlot
   end   
   
%%%%%%%%%%%%%%Clears current axes data%%%%%%%%%%%%%%%%   
case 'Clear'
   cla;
   header = '';
   set(gcf,'UserData', '')
   
%%%%%%Allows the graph to be reproduced for saving%%%%   
case 'Spawn'   
   if  isempty(get(gcf,'UserData')) 
      errordlg('No File Specified','VS-Plot V1.3');
   else       
      SpawnPlot(gca);
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Percentage'
   baseline=get(findobj('Tag','Basetext'),'String');
   
   
%%%%%%%%%%%%%%%For choosing type of plot%%%%%%%%%%%%%%
case 'Error Bar Plot'
   plotmode='Error Bar Plot';
   set(findobj('UserData','PlotTypeTag'),'Enable', 'on');
   set(findobj('UserData','BaselineValue'),'Enable', 'off');
   
case 'Error Bar2 Plot'   
   plotmode='Error Bar2 Plot';
   set(findobj('UserData','PlotTypeTag'),'Enable', 'on');
   set(findobj('UserData','BaselineValue'),'Enable', 'off');
   
case 'Percentage Plot'
   plotmode='Percentage Plot';   
   set(findobj('UserData','BaselineValue'),'Enable', 'on');
   set(findobj('UserData','PlotTypeTag'),'Enable', 'off');
   baseline=get(findobj('Tag','Basetext'),'String'); 
   
case 'Patch Percentage Plot'
   plotmode='Patch Percentage Plot';   
   set(findobj('UserData','BaselineValue'),'Enable', 'off');
   set(findobj('UserData','PlotTypeTag'),'Enable', 'off');
   
case 'Plateau Plot'
   plotmode='Plateau Plot';
   set(findobj('UserData','BaselineValue'),'Enable', 'on');
   set(findobj('UserData','PlotTypeTag'),'Enable', 'on');
   baseline=get(findobj('Tag','Basetext'),'String');
   
%%%%%%%%%%%%%%%%If FFT option is chosen%%%%%%%%%%%%%%%   
case 'FFT'
   ylabel ('FFT Spikes/Second  \pm 1 S.E.M','FontName','Arial','FontSize', 10)
     
%%%%%%%%%%%%%%%If Mean option is chosen%%%%%%%%%%%%%%%
case 'Mean'
   ylabel ('Mean Spikes/Second  \pm 1 S.E.M','FontName','Arial','FontSize', 10)
      
%%%%%%%%%%%%%%%%%Set Axis properties%%%%%%%%%%%%%%%%%%   
case 'Axis'
   val=get(findobj('Tag','Axeschk'), 'Value');
   if val == 1
      axis auto      
      set(findobj('UserData','AxesValues'),'Enable', 'off')
   else      
      xmin=str2num(get(findobj('Tag','Xmintext'),'String'));
      xmax=str2num(get(findobj('Tag','Xmaxtext'),'String'));
      ymin=str2num(get(findobj('Tag','Ymintext'),'String'));
      ymax=str2num(get(findobj('Tag','Ymaxtext'),'String'));      
      axis([xmin xmax ymin ymax]);   
      set(findobj('UserData','AxesValues'),'Enable', 'on');
   end
   
%%%%%%%%%%%%%%%%Set Add or Replace%%%%%%%%%%%%%%%%%%%%   
case 'AddReplace'
   addreplace=get(gcbo, 'Value');
   if addreplace == 0          
      set(gca,'NextPlot','replacechildren');
   else      
      set(gca,'NextPlot','add');      
   end 
   
case 'Arrow'
   val=get(findobj('Tag','Arrowchk'), 'Value');
   if val == 1      
      set(findobj('Tag','Arrowtext'),'Enable', 'on');
      arrowpoint=str2num(get(findobj('Tag','Arrowtext'), 'String'));
   else
      arrowpoint=str2num('');
      set(findobj('Tag','Arrowtext'),'Enable', 'off');
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
   clear all
   close(gcf)
   vs
   
%%%%%%%%%%%%%%%%%See Header Information%%%%%%%%%%%%%%%
case 'Header'
   if isempty(header)
      msgbox('No Header Information for this file','VS-Plot Message','help');
   else
      data = get(gcbf,'UserData'); %This is where we store the data
      if strcmp(plotmode,'Percentage Plot')
         xvalues = num2str(data(:,2)',3);
         yvalues=num2str(((data(:,3)/str2num(baseline))*100)',3);
         iyvalues=num2str(100-((data(:,3)/str2num(baseline))*100)',3); % % suppression
      elseif strcmp(plotmode,'Patch Percentage Plot')
         baseline=data(1,3);
         xvalues = num2str(data(:,2)',3);
         y=data(:,3)-baseline;        %This couple of lines subtract the 0 baseline, then
         yvalues=num2str((y/max(y)*100)',3);        %converts to percent of maximum
         iyvalues=num2str(100-(y/max(y)*100)',3);
      elseif strcmp(plotmode,'Error Bar Plot')
         xvalues = num2str(data(:,2)',3);
         yvalues = num2str(data(:,3)',3);
         iyvalues = yvalues;      %nothing useful to do here....
      elseif strcmp(plotmode,'Error Bar2 Plot')
         xvalues = num2str(data(:,2)',3);
         yvalues = num2str(data(:,3)',3);
         iyvalues = yvalues;      %nothing useful to do here....
      end      
      s=' ';
      xinfo='X values:';
      yinfo='Y Values:';
      msg = strvcat(header,s,s,xinfo,xvalues,s,s,yinfo,yvalues,iyvalues);
      msgbox(msg,'VS-Plot Data Values','help');
      if exist('c:\temp.txt','file'); delete('c:\temp.txt');end
      diary c:\temp.txt
      msg
      diary off
   end
   
   
end %end the switch function



function VSLocalPlot()
% Internal function to plot data using user options
global gridvalue;
global plottype;
global plotmode;
global baseline;
global addreplace;
global header;
global arrowpoint;

%Check whether we are adding or replacing
   if addreplace == 0;       
      set(gca,'NextPlot','replacechildren')
   else      
      set(gca,'NextPlot','add')      
   end 
   
%Choose plotmode and plot the data
figure(gcf)
data = get(gcbf,'UserData'); %This is where we store the data 
if strcmp(plotmode,'Percentage Plot')   
   y=(data(:,3)/str2num(baseline))*100;
   plothndl=plot(data(:,2),y,'k.-','MarkerSize',22.5);
   set(findobj('Tag','Ymaxtext'),'String','100');
   ylabel ('Percentage of Baseline Firing (%)','FontName','Arial','FontSize', 10);
   Value=get(findobj('Tag','XAxisMenu'),'Value');
   String=get(findobj('Tag','XAxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',10);
   if ~isempty(arrowpoint);
      axis(axis);
      arrow([arrowpoint 0],[arrowpoint 10]);
   else
   end   
   
elseif strcmp(plotmode,'Patch Percentage Plot')
   baseline=data(1,3);
   y=data(:,3)-baseline;       %This couple of lines subtract the 0 baseline, then 
   y=(y/max(y))*100;        %converts to percent of maximum
   plothndl=plot(data(:,2),y,'k.-','MarkerSize',22.5);
   set(findobj('Tag','Ymaxtext'),'String','105');
   ylabel ('Percentage of Baseline Corrected Maximum Firing (%)','FontName','Arial','FontSize', 10);
   Value=get(findobj('Tag','XAxisMenu'),'Value');
   String=get(findobj('Tag','XAxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',10);
   if ~isempty(arrowpoint);
      axis(axis);
      arrow([arrowpoint 0],[arrowpoint 10]);
   else
   end   

elseif strcmp(plotmode,'Error Bar Plot')
   e = data(:,4); 
   plothndl=errorbar(data(:,2),data(:,3),e,'k.-');  %'MarkerSize',22.5Plot errorbar data Figure 
   set(plothndl,'Color',[0 0 0]);
   Value = get(findobj('Tag','Plotmenu'),'Value');
   String = get(findobj('Tag','Plotmenu'),'String');
   plottype = String{Value};
   if strcmp(plottype,'FFT')
      ylabel ('FFT Spikes/Second  \pm 1 S.E.M','FontName','Arial','FontSize', 10);
      Value=get(findobj('Tag','XAxisMenu'),'Value');
      String=get(findobj('Tag','XAxisMenu'),'String');
      Str=String{Value};
      xlabel(Str,'FontName','Arial','FontSize',10);
   else
      ylabel ('Mean Spikes/Second  \pm 1 S.E.M','FontName','Arial','FontSize', 10);
      Value=get(findobj('Tag','XAxisMenu'),'Value');
      String=get(findobj('Tag','XAxisMenu'),'String');
      Str=String{Value};
      xlabel(Str,'FontName','Arial','FontSize',10);
   end
   if ~isempty(arrowpoint);    %draw iso-freq arrow
      axis(axis);
      m=max(data(:,3))/10;
      arrow([arrowpoint 0],[arrowpoint m]);
   else
   end  
   
elseif strcmp(plotmode,'Plateau Plot')
   x=data(:,2);
   %y=(data(:,3)/str2num(baseline))*100;
   y=data(:,3)-str2num(baseline);
   y=(y/max(y))*100;
   plothndl=plot(x,y,'kh-');
   set(findobj('Tag','Ymaxtext'),'String','100');
   ylabel ('Percent of Max - spontaneous corrected (%)','FontName','Arial','FontSize', 10);
   Value=get(findobj('Tag','XAxisMenu'),'Value');
   String=get(findobj('Tag','XAxisMenu'),'String');
   Str=String{Value};
   xlabel(Str,'FontName','Arial','FontSize',10);
      
   hold on
   
   %Takes coordinates of 1 click on the axis
   [xclicks,yclicks]=ginput(1);
   
   %Assigns the nearest point of data in the x direction to the last 1 clicks 
   a = modulus(x-xclicks(1));
   chosenpoint = x(find(a==min(a)));
   optimumheight = y(find(a==min(a)));
   
   plot(chosenpoint, optimumheight,'ro','LineWidth',3);
   
   [xclicks,yclicks]=ginput(2);
   
	%Assigns the nearest points of intersection in the x direction to the last 2 clicks 
   a = modulus(x-xclicks(1));
   b = modulus(x-xclicks(2));
   chosenpoints = [x(find(a==min(a))) x(find(b==min(b)))];
   
   %finds plateau level
   if chosenpoints(2)>chosenpoints(1)      
      Plateau = mean(y(find(x<=chosenpoints(2) & x>=chosenpoints(1))));
   else
      Plateau = mean(y(find(x<=chosenpoints(1) & x>=chosenpoints(2))));
   end
   
   plot([min(x) max(x)], [Plateau Plateau],'r-');
   plot([chosenpoints(1) chosenpoints(1)],[min(y) Plateau],'r:');
   plot([chosenpoints(2) chosenpoints(2)],[min(y) Plateau],'r:');
   
   axis tight
   Percentage=(Plateau/max(y))*100;
   t=['Plateau=', num2str(Percentage), '%'];
   text(chosenpoint-(chosenpoint/8), Plateau+(Plateau/12),t,'Color',[1 0 0],'FontName','Arial','FontSize', 10);
   pause(0.5);
   SpawnPlot(gca);  
   
elseif strcmp(plotmode,'Error Bar2 Plot')
   cla
   error = data(:,4);    
   x=size(data(:,3),1);
   err=zeros(x+x,1);
   err(1:x,1)=data(:,3)+error;
   err(x+1:x+x,1)=flipud(data(:,3)-error);
   areax=zeros(x+x,1);
   areax(1:x,1)=data(:,2);
   areax(x+1:x+x,1)=flipud(data(:,2));
   hold on;
   fill(areax,err,[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);
   plot(data(:,2),data(:,3),'k.-','MarkerSize',22.5);
   hold off;
   Value = get(findobj('Tag','Plotmenu'),'Value');
   String = get(findobj('Tag','Plotmenu'),'String');
   plottype = String{Value}
   if strcmp(plottype,'FFT')
      ylabel ('FFT Spikes/Second  \pm 1 S.E.M','FontName','Arial','FontSize', 10);
      Value=get(findobj('Tag','XAxisMenu'),'Value');
      String=get(findobj('Tag','XAxisMenu'),'String');
      Str=String{Value};
      xlabel(Str,'FontName','Arial','FontSize',10);
   else
      ylabel ('Mean Spikes/Second  \pm 1 S.E.M','FontName','Arial','FontSize', 10);
      Value=get(findobj('Tag','XAxisMenu'),'Value');
      String=get(findobj('Tag','XAxisMenu'),'String');
      Str=String{Value};
      xlabel(Str,'FontName','Arial','FontSize',10);
   end
   if ~isempty(arrowpoint);    %draw iso-freq arrow
      axis(axis);
      m=max(data(:,3))/10;
      arrow([arrowpoint 0],[arrowpoint m]);
   else
   end  

end

if ~strcmp(plotmode,'Plateau Plot')
   %Set up the rest of the figure for the users preferences
   set(findobj(gca,'Tag','Axes1'),'FontName','Arial','FontSize',10)
   val=get(findobj('Tag','Axeschk'), 'Value');
   if val == 1
      axis auto      
   else      
      xmin=str2num(get(findobj('Tag','Xmintext'),'String'));
      xmax=str2num(get(findobj('Tag','Xmaxtext'),'String'));
      ymin=str2num(get(findobj('Tag','Xmintext'),'String'));
      ymax=str2num(get(findobj('Tag','Ymaxtext'),'String'));      
      axis([xmin xmax ymin ymax])      
   end
end


if gridvalue == 1      
   grid on
else
   grid off
end 
title(header)

function SpawnPlot(plothandle)
%To plot current info on new object
a=axis;
childfigure=figure;
copyobj(plothandle,childfigure)
set(gca,'Position',[44.25 43.5 341.25 253.5])
set(gca,'Units','Normalized');
axis(a);


%Modulus function squares then roots a matrix losing its negative roots, thus leaving its modulus
function [matrixout] = modulus(matrixin)
	matrixout = ((matrixin.^2).^.5);
%End of modulus finding function%

