function diagonal(action)
%VSRFPlot Plots data files of 2 independant variables
% The raw VS text file is used as input
% Does not require any input variables as everything is GUI driven

global angles;
global PlotType;
global version;
global PlotData;
global XValues;
global YValues;
global CMap;
global DataType;
global ShadingType;
global bins;
global time;

if nargin<1,
    action='Initialize';
 end
 
 switch(action)     %As we use the GUI this switch allows us to
                    %respond to the user input 
    
%%%%%%%%%%%%%%%%%%Initialise%%%%%%%%%%%%%%%%%%%%
case 'Initialize' 
version='Diagonal Plotter V1.0a';
PlotType='CheckerBoard';
CMap='jet';
ShadingType='interp';
angles='';
DataType='pstX';
diagonalfig2;                %this is our GUI file that we call to load
set(gcf,'Name', version); %Sets Version data
datamenu={'pstX';'pstY';'pstXQ';'pstYQ';'pstDR';'pstDRQ';'pstD';'pstD2';'XCHIS'};
set(findobj('Tag','DataSetMenu'),'String',datamenu);
set(findobj('Tag','DataSetMenu'),'Value',1);


%%%%%%%%%%%%%%%%%Load Data%%%%%%%%%%%%%%%%%%%%%%
case 'Load'
   [fname,pname] = uigetfile('*.*','Find Directory and Any File:');
   cd(pname);
   file=fname(1:size(fname,2)-4);
   windowtitle='Please Select Files and Information:';
   prompt={'First extension to use: ','Last extension to use: ',...
      'Experiment:','Run:','Other Info:'};
   def={'001','047','LGCOR','',''};
   answer=inputdlg(prompt,windowtitle,1,def);   
   firstext=str2num(char(answer(1)));
   lastext=str2num(char(answer(2)));
   exp=char(answer(3));
   run=char(answer(4));
   info=char(answer(5));
   header=strcat(exp,'-',run,' [histograms= ',num2str(firstext),':',...
      num2str(lastext),']       {',info,'}');
   a=1;   
   for i=firstext:2:lastext
      if i<10;
         filename=strcat(file,'.00',num2str(i));
         load(filename);
      elseif i>=10;
         if i>=100;
            filename=strcat(file,'.',num2str(i));
            load(filename);
         else
            filename=strcat(file,'.0',num2str(i));
            load(filename);
         end     
      end
      
            angles(a).header=header;
      bins=hists(3);
      angles(a).info=hists(1:3);
      abin=4;
      bbin=4+bins-1;      
      angles(a).pstX=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+bins-1;  
      angles(a).pstY=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+bins-1; 
      angles(a).pstXQ=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+bins-1; 
      angles(a).pstYQ=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+(bins*2)-1; 
      angles(a).pstDR=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+(bins*2)-1; 
      angles(a).pstDRQ=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+(bins*2)-1; 
      angles(a).pstD=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+(bins*2)-1; 
      angles(a).pstD2=hists(abin:bbin);
      abin=bbin+1;
      bbin=abin+(bins*2)-1; 
      angles(a).XCHIS=hists(abin:bbin);
      a=a+1;
      clear hists
   end  
   
   diagplot('Main');
   
%%%%%%%%%%%%%Copies figure for output%%%%%%%%%%%%%%%%%%%%%%%%
case 'Spawn'   
   if  isempty(angles) 
      errordlg('No File Specified',version);
   else        
      SpawnPlot;
   end
   
%%%%%%%%%%%%%%%%%%%Various call from the GUI%%%%%%%%%%%%%%%%%   
case 'PlotOpts'       %change the type of plot
   Value=get(gcbo,'Value');
   String=get(gcbo,'String');
   PlotType=String{Value};
   diagplot('Main');
   
case 'DataSet'        %change the data set
   diagplot('Main');
   
case 'ShadingOpts'          %change shading  
   Value=get(gcbo,'Value');
   String=get(gcbo,'String');
   ShadingType=String{Value};
   switch(ShadingType)
   case 'Flat'
      ShadingType='flat';
      shading(ShadingType);
   case 'Interpolated'
      ShadingType='interp';
      shading(ShadingType);
   case 'Faceted'
      ShadingType='faceted';
      shading(ShadingType)
   end    
      
case 'Close'   
   clear all;
   close(gcf);
   
   
end  %end switch


function diagplot(call)
%Internal function to plot the RF data according to the user options

global angles;
global plothandle;
global PlotType;
global XValues;
global YValues;
global CMap;
global ShadingType;
global InterType;
global DataType;
global data;

%%%Find what the options are%%%

Value=get(findobj('Tag','DataSetMenu'),'Value');
String=get(findobj('Tag','DataSetMenu'),'String');
DataType=String{Value};

if call=='Main'
   axes(findobj('Tag','MainAxis'));  %sets to main axes
else 
   axes(call)
end

switch DataType
   
case 'pstX'
   data=ones(size(angles(1).pstX,1),size(angles,2));
   for i=1:size(angles,2);      
      data(:,i)=angles(i).pstX;      
   end 
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Raw X PSTH'); 

case 'pstY'
   data=ones(size(angles(1).pstY,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstY;
   end  
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Raw Y PSTH');
   
case 'pstXQ'
   data=ones(size(angles(1).pstXQ,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstXQ;
   end  
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Squared X PSTH');

case 'pstYQ'
   data=ones(size(angles(1).pstYQ,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstYQ;
   end 
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Squared X PSTH');

case 'pstDR'
   data=ones(size(angles(1).pstDR,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstDR;
   end  
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)*2-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Raw Diagonal');

case 'pstDRQ'
   data=ones(size(angles(1).pstDRQ,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstDRQ;
   end
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)*2-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Squared Diagonal');
  
case 'pstD'
   data=ones(size(angles(1).pstD,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstD;
   end
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)*2-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Diagonal');

case 'pstD2'
   data=ones(size(angles(1).pstD2,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).pstD2;
   end
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)*2-1);
   YValues=0:binwidth:angles(1).info(2);
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Smoothed Diagonal');

case 'XCHIS'  %this will be different to the others
   data=ones(size(angles(1).XCHIS,1),size(angles,2));
   for i=1:size(angles,2);
      data(:,i)=angles(i).XCHIS;
   end
   x=size(data,1)/4;
   data=data(x+1:x*3,:);         %cursor in to the central portion
   XValues=1:(size(data,2));
   binwidth=angles(1).info(2)/(angles(1).info(3)*2-1);
   start=angles(1).info(2)/4-((angles(1).info(2)/4)*2);
   finish=angles(1).info(2)/4;
   YValues=start:finish*2/(size(data,1)-1):finish;
   set(findobj('Tag','InfoText'),'String','Diagonal Plotter:  Cross Correlogram');

end

switch(PlotType)    %For different plots
case 'Raw Data'
   imagesc(XValues,YValues,data)
   set(gca,'YDir','normal')
case 'Mesh' 
   mesh(XValues,YValues,data)
   shading(ShadingType)
   %axis vis3d
case 'CheckerBoard'
   pcolor(XValues,YValues,data)
   shading(ShadingType)
case 'CheckerBoard+Contour'
   pcolor(XValues,YValues,data)
   shading(ShadingType)
   hold on
   [c,h] = contour(XValues,YValues,data,'k'); clabel(c,h)
   hold off
case 'Surface'
   surf(XValues,YValues,data)
   shading(ShadingType)
   %axis vis3d
case 'Lighted Surface'
   material metal
   surfl(XValues,YValues,data)
   shading(ShadingType)
   %axis vis3d
case 'Surface+Contour'
   surfc(XValues,YValues,data)
   shading(ShadingType)
   %axis vis3d
case 'Contour'
   [c,h] = contour(XValues,YValues,data); clabel(c,h)
case 'Filled Contour'
   [c,h] = contourf(XValues,YValues,data); clabel(c,h)
case 'Waterfall'
   waterfall(XValues,YValues,data)
   %axis vis3d
end  

if strcmp(DataType,'XCHIS')==1;
   x=[min(XValues),max(XValues)];
   y=[0,0];
   line(x,y);
   axis tight;
else
   axis tight;
end

colormap(CMap);

if strcmp(call,'Main')==1       %draw the X and Y sum histograms
   
   set(gca,'XTick',[])
   set(gca,'YTick',[])

   axes(findobj('Tag','XAxis'));  %sets to X axis
   histx=sum(data,1);
   bar(XValues,histx,'b-',1);   
   xlabel('angles (deg)','FontSize', 6)
   set(gca,'Tag','XAxis')
   set(gca,'FontSize',7);
   axis tight
   
   axes(findobj('Tag','YAxis'));  %sets to Y axis
   histy=sum(data,2)';   
   bar(YValues,histy,'k-',1);   
   set(gca,'CameraUpVector',[1 0 0]);
   %xlabel('Time (msec)','FontSize', 8);
   set(gca,'XAxisLocation','top')
   set(gca,'Tag','YAxis');
   set(gca,'FontSize',7);
   axis tight;
      
   axes(findobj('Tag','MainAxis'));  %sets to main axes
end


function SpawnPlot()
%Outputs a Summary figure, hopefully multiaxis

global data
global XValues
global YValues
global angles

cmap=get(gcf,'ColorMap');
header=angles(1).header;
diagoutput;
set(findobj('Tag','TitleText'),'String',header);
for i=1:4
   if i==1
      h=findobj('Tag','MainAx1');
      set(findobj('Tag','DataSetMenu'),'Value',1);      
      diagplot(h);
      colormap(cmap);
      set(findobj('Tag','Text1'),'String','Cell 1 PSTH');
      set(gca,'XTick',[])
      set(gca,'YTick',[])
      
      axes(findobj('Tag','XAx1'));  %sets to X axis
      histx=sum(data,1);
      bar(XValues,histx,'b-',1);
      axis tight
      %xlabel('angles (deg)','FontSize', 7)
      set(gca,'Tag','XAx1')
      set(gca,'FontSize',7);
      
      axes(findobj('Tag','YAx1'));  %sets to Y axis
      histy=sum(data,2)'; 
      bar(YValues,histy,'k-',1); 
      axis tight;
      set(gca,'CameraUpVector',[1 0 0]);
      %xlabel('Time (msec)','FontSize', 8);
      set(gca,'XAxisLocation','top')
      set(gca,'Tag','YAx1');
      set(gca,'FontSize',7);
      
      axes(findobj('Tag','ColorBar1'));  %sets to colorbar axis
      makecbar(cmap)
      
   elseif i==2
      h=findobj('Tag','MainAx2');
      set(findobj('Tag','DataSetMenu'),'Value',2);
      diagplot(h);
      colormap(cmap);
      set(findobj('Tag','Text2'),'String','Cell 2 PSTH');
      set(gca,'XTick',[])
      set(gca,'YTick',[])
      
      axes(findobj('Tag','XAx2'));  %sets to X axis
      histx=sum(data,1);
      bar(XValues,histx,'b-',1);
      axis tight
      %xlabel('angles (deg)','FontSize', 7)
      set(gca,'Tag','XAx2')
      set(gca,'FontSize',7);
      
      axes(findobj('Tag','YAx2'));  %sets to Y axis
      histy=sum(data,2)'; 
      bar(YValues,histy,'k-',1); 
      axis tight;
      set(gca,'CameraUpVector',[1 0 0]);
      %xlabel('Time (msec)','FontSize', 8);
      set(gca,'XAxisLocation','top')
      set(gca,'Tag','YAx2');
      set(gca,'FontSize',7);      
      
      axes(findobj('Tag','ColorBar2'));  %sets to colorbar axis
      makecbar(cmap)
      
   elseif i==3
      h=findobj('Tag','MainAx3');
      set(findobj('Tag','DataSetMenu'),'Value',8);
      diagplot(h);
      colormap(cmap);
      set(findobj('Tag','Text3'),'String','Smoothed Diagonal');
      set(gca,'XTick',[])
      set(gca,'YTick',[])
      
      axes(findobj('Tag','XAx3'));  %sets to X axis
      histx=sum(data,1);
      bar(XValues,histx,'b-',1);
      axis tight
      %xlabel('angles (deg)','FontSize', 7)
      set(gca,'Tag','XAx3')
      set(gca,'FontSize',7);
      
      axes(findobj('Tag','YAx3'));  %sets to Y axis
      histy=sum(data,2)'; 
      bar(YValues,histy,'k-',1); 
      axis tight;
      set(gca,'CameraUpVector',[1 0 0]);
      %xlabel('Time (msec)','FontSize', 8);
      set(gca,'XAxisLocation','top')
      set(gca,'Tag','YAx3');
      set(gca,'FontSize',7);
      
      axes(findobj('Tag','ColorBar3'));  %sets to colorbar axis
      makecbar(cmap)
      
   elseif i==4
      h=findobj('Tag','MainAx4');
      set(findobj('Tag','DataSetMenu'),'Value',9);
      diagplot(h);
      colormap(cmap);
      set(findobj('Tag','Text4'),'String','Xcor Histogram');
      set(gca,'XTick',[])
      set(gca,'YTick',[])
      
      axes(findobj('Tag','XAx4'));  %sets to X axis
      histx=sum(data,1);
      bar(XValues,histx,'b-',1);
      axis tight
      %xlabel('angles (deg)','FontSize', 7)
      set(gca,'Tag','XAx4')
      set(gca,'FontSize',7);
      
      axes(findobj('Tag','YAx4'));  %sets to Y axis
      histy=sum(data,2)'; 
      bar(YValues,histy,'k-',1); 
      axis tight;
      set(gca,'CameraUpVector',[1 0 0]);
      %xlabel('Time (msec)','FontSize', 8);
      set(gca,'XAxisLocation','top')
      set(gca,'Tag','YAx4');
      set(gca,'FontSize',7);
            
      axes(findobj('Tag','ColorBar4'));  %sets to colorbar axis
      makecbar(cmap)

   end
end

function makecbar(cmap)
%Used to generate the Colorbar for each plot on the spawn

global data
global XValues
global YValues

maximum=max(max(data));
s=size(data,1);

colorrange=(0:maximum/(s-1):maximum)';
y=colorrange;
x=[0 1];
colorrange(:,2)=colorrange;
pcolor(x,y,colorrange)
shading flat






      


