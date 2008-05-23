function temporal(action)
% Temporal is a GUI function to analyse data spat out by the VS temporal
% script file, will do a surface plot of all the data, or show individual
% time slices. Just type Temporal at the command prompt to run.

global version;
global PlotData;
global Data;
global XValues;
global YValues;
global PlotType;
global CMap;
global ShadingType;
global header;
global Tag;
global StartTimes;
global M;
global Raw;
global normalise;
global SmoothType;
global SmoothValue;


if nargin<1,
   action='Initialize';
end

switch(action)     %As we use the GUI this switch allows us to
                   %respond to the user input 
   
    
%%%%%%%%%%%%%%%%%%Initialise%%%%%%%%%%%%%%%%%%%%
case 'Initialize' 
   version='VS Temporal Analysis v1.9';
   PlotType='CheckerBoard';
   plottype='FFT';
   CMap='hot';
   ShadingType='interp';   
   arrowpoint='';
   temporalfig3              %this is our GUI file that we call to load
   set(gcf,'Name', version) %Sets Version data
   orbmenu={'All';'Max of Slice';'Max of Variable'};
   orbanmode='All';
   set(findobj('Tag','OrbanMenu'),'String',orbmenu);
   Raw=1;
   normalise=0;
   SmoothType='cubic';
   SmoothValue=5;

   
%%%%%%%%%%%%%%%%%%Load File%%%%%%%%%%%%%%%%%%%%%
case 'Open'   
   [lfile,lpath]=uigetfile('*ta.txt','VS Temporal Analysis: Choose File');
   if ~lfile
      errordlg('No File Specified', version)
   else 
      cd(lpath);
      [header,Data]=hdload(lfile);      
      %This for loop Initialises the data for further processing
      %used when input file is one long string
      %Temp=ones(size(a,2)/4,4); %Initialise data matrix
      %loop=0;
      %rownum=1;
      %for i=1:size(a,2)    
      %   block=i-loop;         
      %   Temp(rownum,block)=a(1,i);
      %   if block == 4;
      %      loop=loop+4;
      %      rownum=rownum+1;
      %   end
      %end 
      
      %Actually Generate our Matrix for Plotting 
      if size(Data,2)==4
         Tag='Temporal';
         XValues=unique(Data(:,1));    %1st column contains start times
         YValues=unique(Data(:,2));    %2nd column contains variable value
         PlotData=ones(size(YValues,1),size(XValues,1));
         PlotData(:)=Data(1:size(Data,1),3); %Faster matrix version      
         %%%%%%This section converts values to Percentage of Max%%%%%%
         if Raw==1  %check 
            %leave data as it is.......
         else 
            if normalise==0 %use percentage
               plotmax=max(max(PlotData))
               if plotmax==0;
                  errordlg('The File appears empty!!!', version);
               else            
                  PlotData=(PlotData/plotmax)*100;  %matrix version faster
               end  
            else
               PlotData=(PlotData/normalise)*100;  %matrix version faster
            end 
               
         end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         set(gcbf, 'UserData', PlotData);     %Just in case
         set(findobj('Tag','PlotCheckbox'),'Value',0) %these reset single analysis
         set(findobj('Tag','PlotCheckbox'),'Enable','on')
         set(findobj('Tag','Timepopup'),'String',cell(1)); 
         set(findobj('Tag','Timepopup'),'Value',1);
         set(findobj('UserData','plotopts'),'Enable','on');
         set(findobj('UserData','Singleopts'),'Enable','off');
         %%%%%%%Set Up the Min and Max boxes for the colordata%%%%%%%%
         str=strcat('Minimum (',num2str(round(min(min(PlotData)))),'):');
         set(findobj('Tag','MinimumText'),'String',str);
         set(findobj('Tag','MinTextEdit'),'String',num2str(round(min(min(PlotData)))));
         str=strcat('Maximum (',num2str(round(max(max(PlotData)))),'):');
         set(findobj('Tag','MaximumText'),'String',str);
         set(findobj('Tag','MaxTextEdit'),'String',num2str(round(max(max(PlotData)))));
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         PlotTemporal(PlotData);
         
      elseif size(Data,2)==5
         Tag='Density';
         StartTimes=unique(Data(:,1)); %1st col contains start times
         XValues=unique(Data(:,2));   %2nd col contains X variable value
         YValues=unique(Data(:,3));    %3rd col contains Y variable value
         PlotData=zeros(size(XValues,1),size(YValues,1));    
         set(findobj('Tag','PlotCheckbox'),'Value',1); 
         set(findobj('UserData','plotopts'),'Enable','on');
         set(findobj('UserData','Singleopts'),'Enable','on')
         set(findobj('Tag','ffttext'),'Enable','off')
         set(findobj('Tag','fftmenu'),'Enable','off')
         set(findobj('Tag','xaxistext'),'Enable','off')
         set(findobj('Tag','XaxisMenu'),'Enable','off')
         set(findobj('Tag','PlotCheckbox'),'Enable','off')
         x=cellstr(num2str(StartTimes));
         set(findobj('Tag','Timepopup'),'String',x);
         set(findobj('Tag','Timepopup'),'Value',1);
         %%%%%%%%%%%%%%%%Set up ColorScale Edit Box info%%%%%%%%%%%%%%%%%%%%%%%%%%%
         str=strcat('Minimum (',num2str(round(min(Data(:,4)))),'):');
         set(findobj('Tag','MinimumText'),'String',str);
         set(findobj('Tag','MinTextEdit'),'String',num2str(round(min(Data(:,4)))));
         str=strcat('Maximum (',num2str(round(max(Data(:,4)))),'):');
         set(findobj('Tag','MaximumText'),'String',str);
         set(findobj('Tag','MaxTextEdit'),'String',num2str(round(max(Data(:,4)))));
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         PlotDensity;
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%Ratio Analysis%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Ratio'
   [xi,yi]=ginput(2);
   data=PlotData(4,:);
   [x(1),indx(1)]=minim(XValues,xi(1));
   [x(2),indx(2)]=minim(XValues,xi(2));
   for i=3:8
      x(i)=x(i-2)+500;
      [x(i),indx(i)]=minim(XValues,x(i));
   end
   
   hold on;
   a=axis;
   for i=1:max(size(x))
      line([x(i),x(i)],[a(3),a(4)]);      
   end
   hold off;
   
   centre=sum(data(indx(1):indx(2)))
   a=1;
   for i=3:2:7
      s(a)=sum(data(indx(i):indx(i+1)));
      a=a+1;
   end
   s
   surround=sum(s)/3
   
   if surround<=0;surround=0.00001;end
   
   time=XValues(indx(1)) 
   
   ratio=surround/centre*100
     
   text(0,2,num2str(ratio),'Color',[0 0 1]);
      
   
   
   
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%Spawn New Figure%%%%%%%%%%%%%%%%%%%%%%%%%
case 'Spawn'
   % Check to see whether we are in Plot or Single and then spawn
   if strcmp(Tag,'Temporal')==1
      [a,b]=view;
      figure;
      PlotTemporal(PlotData);
      view(a,b);
      colorbar;
   elseif strcmp(Tag,'Density')==1
      [a,b]=view;
      figure;
      PlotDensity;
      view(a,b);
      colorbar
   elseif strcmp(Tag,'Single')==1
      figure;
      PlotSingle(Data);
   end  
   
%%%%%%%%%%%%%%%%%%%Change ColorData info%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'ColorData'   
%    minim=round(str2num(get(findobj('Tag','MinTextEdit'),'String')));   
%    maxim=round(str2num(get(findobj('Tag','MaxTextEdit'),'String')));
%    caxis([minim maxim]);

   
%%%%%%%%%%%%%%%%%%%Various Plotting Options%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'PlotOpts'
   Value=get(gcbo,'Value');
   String=get(gcbo,'String');
   PlotType=String{Value};
   if strcmp(Tag,'Temporal')==1
      PlotTemporal(PlotData);
   elseif strcmp(Tag,'Density')==1
      PlotDensity
   end
   
   
case 'ShadingOpts'   
   Value=get(gcbo,'Value');
   String=get(gcbo,'String');
   ShadingType=String{Value};
   switch(ShadingType)
   case 'Flat'
      ShadingType='flat';
      shading(ShadingType)
   case 'Interpolated'
      ShadingType='interp';
      shading(ShadingType)
   case 'Faceted'
      ShadingType='faceted';
      shading(ShadingType)
   end    
   
case 'InterOpts'
   Value=get(gcbo,'Value');
   String=get(gcbo,'String');
   InterType=String{Value};
   PlotTemporal(PlotData);  
   
%%%%%%%%%%%%%%%%%Set up to Look at Single Time Slice%%%%%%%%%%%%%%%%%%%%%%
case 'SinglePlot'
   
   Value=get(gcbo,'Value');
   if Value==1;               %We are in singleplot mode
      Tag='Single';
      x=cellstr(num2str(XValues));
      set(findobj('UserData','plotopts'),'Enable','off');
      set(findobj('UserData','Singleopts'),'Enable','on');
      set(findobj('Tag','Timepopup'),'String',x);
      set(findobj('Tag','Timepopup'),'Value',1);     
   else   
      Tag='Temporal'
      set(findobj('Tag','Timepopup'),'String',cell(1));
      set(findobj('Tag','Timepopup'),'Value',1);
      set(findobj('UserData','plotopts'),'Enable','on');
      set(findobj('UserData','Singleopts'),'Enable','off');
      PlotTemporal(PlotData);
   end
   
case 'Orbanize'
   if strcmp(Tag,'Temporal')==1
      OrbanizeIt
   else
   end
   
   
case 'Slices';
   
   
case 'UndoOrban'
   PlotData=get(gcbf, 'UserData');
   PlotTemporal(PlotData)
   
case 'gosingle'
   if strcmp(Tag,'Single')==1
      PlotSingle(Data);
   elseif strcmp(Tag,'Density')==1
      PlotDensity
   else
   end
   
   
%%%%%%%%%%%%%%%%If FFT option is chosen%%%%%%%%%%%%%%%   
case 'FFT'
   ylabel ('FFT Spikes/Second \pm 1 S.E.M','FontName','Arial','FontSize', 10);   
   
%%%%%%%%%%%%%%%If Mean option is chosen%%%%%%%%%%%%%%%
case 'Mean'
   ylabel ('Mean Spikes/Second \pm 1 S.E.M','FontName','Arial','FontSize', 10);
   
%%%%%%%%%%%%%%%%%Set Axis properties%%%%%%%%%%%%%%%%%%   
case 'Axis'
   val=get(findobj('Tag','Axescheck'), 'Value');
   if val == 1
      axis auto;      
      set(findobj('UserData','AxesValues'),'Enable', 'off');
      axis tight;
   else      
      xmin=str2num(get(findobj('Tag','Xmintext'),'String'));
      xmax=str2num(get(findobj('Tag','Xmaxtext'),'String'));
      ymin=str2num(get(findobj('Tag','Ymintext'),'String'));
      ymax=str2num(get(findobj('Tag','Ymaxtext'),'String'));      
      axis([xmin xmax ymin ymax]);   
      set(findobj('UserData','AxesValues'),'Enable', 'on');
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
   
case 'Movie'
   if strcmp(Tag,'Temporal')==1
      errordlg('Need to have Density Map data loaded for Movie...', version)
   elseif strcmp(Tag,'Density')==1
      val=axis;
      %=========Set Up the x and y positions for the text==========%
      if val(1)<0
         offset=(val(1)*-1)/4;
      else
         offset=val(1)/5;
      end    
      
      x=val(1)+offset;
      
      if val(3)<0
         offset=(val(3)*-1)/4;
      else
         offset=val(3)/5;
      end  
      
      y=val(3)+offset;
      %===========================================================%
      if size(StartTimes,1)<30
         figure;
         set(gcf,'Position',[240 240 250 200])
         set(gca,'NextPlot','replacechildren');
         set(gca,'Color',[0 0 0]);
         M=moviein(size(StartTimes,1)); 
         for i=1:size(StartTimes,1);
            set(findobj(1,'Tag','Timepopup'),'Value',i);
            pause(0.9)
            PlotDensity;
            text(x,y,num2str(StartTimes(i)),'FontSize',13,'Color',[1 1 1])
            M(:,i)=getframe;
         end 
         movie(M,30,8);
      else
         figure;         
         set(gcf,'Position',[200 200 350 310])
         set(gca,'NextPlot','replacechildren');
         set(gca,'Color',[0 0 0]);
         for i=1:size(StartTimes,1);            
            set(findobj(1,'Tag','Timepopup'),'Value',i);
            pause(0.9)
            PlotDensity;            
            text(x,y,num2str(StartTimes(i)),'FontSize',13,'Color',[1 1 1]);
         end 
      end      
   elseif strcmp(Tag,'Single')==1
      errordlg('Need to have Density Map data loaded for Movie...', version)
   end  


end

% End of Main Function

      
function PlotTemporal(data)
%Internal function to plot the matrix data according to the user options

global PlotType;
global XValues;
global YValues;
global CMap;
global ShadingType;
global header;
global SmoothType;
global SmoothValue;

PlotData=data;

if isempty(SmoothType); 
   SmoothType='none' 
end;
if isempty(SmoothValue); 
   SmoothValue='5' 
end;

xlinear=1:size(XValues,1);
ylinear=1:size(YValues,1);

switch(SmoothType)
case 'none'
   xx=XValues';
   yy=ylinear';   
   dd=PlotData;
case 'cubic'
   xx=linspace(min(XValues),max(XValues),(size(XValues,1)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(XValues,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*cubic');
case 'linear'
   xx=linspace(min(XValues),max(XValues),(size(XValues,1)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(XValues,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*linear');
case 'nearest'
   xx=linspace(min(XValues),max(XValues),(size(XValues,1)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(XValues,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*nearest');
case 'spline'
   xx=linspace(min(XValues),max(XValues),(size(XValues,1)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(XValues,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*spline');
end

%%%Find what the options are%%%
switch(PlotType)    %For different plots
case 'Raw Data'   
   imagesc(XValues,ylinear,PlotData);    
   %set(gca,'XTick',xvaltick);
   set(gca,'YTick',ylinear);
   %set(gca,'XTickLabel',xval);
   set(gca,'YTickLabel',YValues);   
   set(gca,'YDir','normal');
case 'Mesh'    
   mesh(xx,yy,dd)
   %set(gca,'XTick',xvaltick);
   set(gca,'YTick',ylinear);
   %set(gca,'XTickLabel',xval);
   set(gca,'YTickLabel',YValues); 
   shading(ShadingType)    
case 'CheckerBoard'
   pcolor(xx,yy,dd);
   %set(gca,'XTick',[1 2 3 4 5]);
   set(gca,'YTick',ylinear);
   %xtick=linspace(min(XValues),max(XValues),5);
   %set(gca,'XTickLabel',xtick);
   set(gca,'YTickLabel',YValues);   
   shading(ShadingType);        
case 'CheckerBoard+Contour'
   pcolor(xx,yy,dd)
   shading(ShadingType)
   hold on
   [c,h] = contour(xx,yy,dd,'k'); clabel(c,h)
   hold off  
   %set(gca,'XTick',xvaltick);
   set(gca,'YTick',ylinear);
   %set(gca,'XTickLabel',xval);
   set(gca,'YTickLabel',YValues);   
case 'Surface'
   surf(xx,yy,dd)
   %set(gca,'XTick',xlinear);
   set(gca,'YTick',ylinear);
   %set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);
   shading(ShadingType)    
case 'Lighted Surface'
   material shiny
   surfl(xx,yy,dd)
   %set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   %set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);
   shading(ShadingType)    
case 'Surface+Contour'
   surfc(xx,yy,dd)
   %set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   %set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);
   shading(ShadingType)
case 'Contour'
   [c,h] = contour(xx,yy,dd); clabel(c,h) 
   %set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   %set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);
case 'Filled Contour'
   [c,h] = contourf(xx,yy,dd); clabel(c,h)
   %set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   %set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);
case 'Waterfall'
   waterfall(xx,yy,dd) 
   %set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   %set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);
end 

% min=round(str2num(get(findobj('Tag','MinTextEdit'),'String')));   
% max=round(str2num(get(findobj('Tag','MaxTextEdit'),'String')));
% caxis([min max]);

if ~isempty(header)
   title(header,'FontName','Arial','FontSize',9) 
end
CMap=get(findobj('Tag','TemporalFig'),'Colormap'); 
colormap(CMap); 
xlabel('Start Time of Temporal Slice (ms)','FontName','Arial','FontSize',10)
ylabel('Independant Variable Used','FontName','Arial','FontSize',10)
val=get(findobj('Tag','Axescheck'), 'Value');
if val == 1
   axis auto;
   axis tight;
else      
   xmin=str2num(get(findobj('Tag','Xmintext'),'String'));
   xmax=str2num(get(findobj('Tag','Xmaxtext'),'String'));
   ymin=str2num(get(findobj('Tag','Ymintext'),'String'));
   ymax=str2num(get(findobj('Tag','Ymaxtext'),'String'));      
   axis([xmin xmax ymin ymax]);         
end

% End of PlotTemporal

function OrbanizeIt()
% Reshapes the matrix showing values that are significant
% working out the mean spontaneous a 2xStDev and subtracting
% all values which fall below this baseline,

global PlotData
global XValues
global YValues
global zi;
global xi;
global yi;


Value=get(findobj('Tag','OrbanMenu'),'Value');
String=get(findobj('Tag','OrbanMenu'),'String');
orbmode=String{Value};

switch(orbmode)
   
case 'All'        %This works out the mean and std for all values
   time=str2num(get(findobj('Tag','TimePoint'),'String'));
   columnsused=find(XValues<time);
   val=PlotData(:,columnsused);
   [a b]=size(val);
   m=a*b;
   vector=zeros(m,1);
   for i=1:m
      vector(i)=val(i);
   end
   threshold=mean(vector)+(std(vector)*2)
   index=find(PlotData<threshold);
   tmatrix=PlotData;
   tmatrix(index)=0;
   

case 'Max of Slice'
   time=str2num(get(findobj('Tag','TimePoint'),'String'));
   columnsused=find(XValues<time);
   val=PlotData(:,columnsused);
   maxvals=max(val);
   threshold=mean(maxvals)+(std(maxvals)*2) %work out mean + 2stddev
   index=find(PlotData<threshold);
   tmatrix=PlotData;
   tmatrix(index)=0;

case 'Max of Variable'
   time=str2num(get(findobj('Tag','TimePoint'),'String'));
   columnsused=find(XValues<time);
   val=PlotData(:,columnsused);
   maxvals=max(val');
   threshold=mean(maxvals)+(std(maxvals)*2) %work out mean + 2stddev
   index=find(PlotData<threshold);
   tmatrix=PlotData;
   tmatrix(index)=0;  %Set those values less than threshold to 0
end 

if str2num(get(findobj('Tag','SlicePoint'),'String'))==1;


elseif str2num(get(findobj('Tag','SlicePoint'),'String'))==2;
   [row col]=size(tmatrix);
   for i=1:row
      for k=2:col-1    
         if tmatrix(i,k+1)==0   %is the next value there?
            if tmatrix(i,k-1)==0 %is the previous?
               tmatrix(i,k)=0;   %NO so set it to 0
            end  
         end
      end
   end

elseif str2num(get(findobj('Tag','SlicePoint'),'String'))==3;   
   [row col]=size(tmatrix);
   for i=1:row
      for k=3:col-2    
         if tmatrix(i,k+1)==0   %is the next value there?
            if tmatrix(i,k-1)==0 %is the previous?
               tmatrix(i,k)=0;   %NO so set it to 0
            elseif tmatrix(i,k-2)==0  %is the -2 there?
               tmatrix(i,k)=0; %NO so set it to 0
            end  
         else 
            if tmatrix(i,k+2)==0   %is the +2 val there?
               if tmatrix(i,k-1)==0 %is the previous val there?
                  tmatrix(i,k)=0;   %NO so set it to 0
               end  
            end
         end
      end
   end
else
   
end

PlotData=tmatrix;
PlotTemporal(PlotData)

function PlotDensity()
% Internal function for Plotting the density plot data for different timeslices

global PlotType
global XValues
global YValues
global PlotData
global Data
global CMap;
global ShadingType;
global header;
global SmoothValue;
global SmoothType;

Value=get(findobj('Tag','Timepopup'),'Value');
matsize=size(XValues,1)*size(YValues,1);

if Value==1
   PlotData(:)=Data(1:matsize,4);
else
   startblock=(matsize*(Value-1))+1;
   endblock=matsize*Value; 
   PlotData(:)=Data(startblock:endblock,4);        
end

if isempty(SmoothType); 
   SmoothType='none' 
end;
if isempty(SmoothValue); 
   SmoothValue='5' 
end;

xlinear=1:size(XValues,1);
ylinear=1:size(YValues,1);

switch(SmoothType)
case 'none'
   xx=xlinear;
   yy=ylinear';   
   dd=PlotData;
case 'cubic'
   xx=linspace(min(xlinear),max(xlinear),(size(xlinear,2)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xlinear,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*cubic');
case 'linear'
   xx=linspace(min(xlinear),max(xlinear),(size(xlinear,2)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xlinear,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*linear');
case 'nearest'
   xx=linspace(min(xlinear),max(xlinear),(size(xlinear,2)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xlinear,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*nearest');
case 'v4'
   xx=linspace(min(xlinear),max(xlinear),(size(xlinear,2)*SmoothValue));
   yy=linspace(min(ylinear),max(ylinear),(size(ylinear,2)*SmoothValue)); 
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xlinear,ylinear);
   dd=interp2(x,y,PlotData,xx,yy,'*spline');
end

%%%Find what the options are%%%
switch(PlotType)    %For different plots
case 'Raw Data' 
   imagesc(xlinear,ylinear,PlotData);    
   set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues);   
   set(gca,'YDir','normal');
case 'Mesh'    
   mesh(xx,yy,dd)
   set(gca,'XTick',xlinear);
   set(gca,'YTick',xlinear);
   set(gca,'XTickLabel',XValues);
   set(gca,'YTickLabel',YValues); 
   shading(ShadingType)    
 case 'CheckerBoard'
    pcolor(xx,yy,dd);
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);   
    shading(ShadingType);        
 case 'CheckerBoard+Contour'
    pcolor(xx,yy,dd)
    shading(ShadingType)
    hold on
    [c,h] = contour(xx,yy,dd,'k'); clabel(c,h)
    hold off  
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);   
 case 'Surface'
    surf(xx,yy,dd)
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);
    shading(ShadingType)    
 case 'Lighted Surface'
    material shiny
    surfl(xx,yy,dd)
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);
    shading(ShadingType)    
 case 'Surface+Contour'
    surfc(xx,yy,dd)
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);
    shading(ShadingType)
 case 'Contour'
    [c,h] = contour(xx,yy,dd); clabel(c,h) 
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);
 case 'Filled Contour'
    [c,h] = contourf(xx,yy,dd); clabel(c,h)
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);
 case 'Waterfall'
    waterfall(xx,yy,dd) 
    set(gca,'XTick',xlinear);
    set(gca,'YTick',xlinear);
    set(gca,'XTickLabel',XValues);
    set(gca,'YTickLabel',YValues);
 end  
 
%  min=round(str2num(get(findobj('Tag','MinTextEdit'),'String')));   
%  max=round(str2num(get(findobj('Tag','MaxTextEdit'),'String')));
%  caxis([min max]);
 
 if ~isempty(header)
    title(header,'FontName','Arial','FontSize',9) 
 end
 CMap=get(findobj('Tag','TemporalFig'),'Colormap'); 
 colormap(CMap); 
 xlabel('X Axis Variable','FontName','Arial','FontSize',10);
 ylabel('Y Axis Variable','FontName','Arial','FontSize',10);
 val=get(findobj('Tag','Axeschk'), 'Value');
 if val == 1
    axis auto;
    axis tight;
 else    
    xmin=str2num(get(findobj('Tag','Xmintext'),'String'));
    xmax=str2num(get(findobj('Tag','Xmaxtext'),'String'));
    ymin=str2num(get(findobj('Tag','Ymintext'),'String'));
    ymax=str2num(get(findobj('Tag','Ymaxtext'),'String')); 
    axis([xmin xmax ymin ymax]);  
 end



function PlotSingle(Data)
% Internal function for plotting chosen time slice as Tuning Curve
% uses original loaded data not processed data, so the errors can be
% extracted as well.

global header;
global YValues;

Value=get(findobj('Tag','Timepopup'),'Value');
range=size(unique(Data(:,2)),1);   %work out how to chunk up data
firingrate=ones(range,1);
error=ones(range,1);
if Value==1
   for i=1:1:range
      firingrate(i)=Data(i,3);
      error(i)=Data(i,4);
   end
else
   startvalue=range*(Value-1)+1;
   endvalue=startvalue+range-1;
   firingrate(:)=Data(startvalue:endvalue,3);  %Matrix rather than loop version
   error(:)=Data(startvalue:endvalue,4);   
end
plothndl=errorbar(YValues,firingrate,error,'ko-');  %Plot errorbar data Figure 
val=get(findobj('Tag','Axeschk'), 'Value');
   if val == 1
      axis auto;     
   else      
      xmin=str2num(get(findobj('Tag','Xmintext'),'String'));
      xmax=str2num(get(findobj('Tag','Xmaxtext'),'String'));
      ymin=str2num(get(findobj('Tag','Ymintext'),'String'));
      ymax=str2num(get(findobj('Tag','Ymaxtext'),'String'));      
      axis([xmin xmax ymin ymax]);         
   end
title(header,'FontName','Arial','FontSize',9);
Value=get(findobj('Tag','fftmenu'),'Value');
String=get(findobj('Tag','fftmenu'),'String');
if strcmp(String{Value},'Mean') == 1
   ylabel ('Mean Spikes/Second \pm 1 S.E.M.','FontName','Arial','FontSize', 10);
else
   ylabel ('FFT Spikes/Second \pm 1 S.E.M.','FontName','Arial','FontSize', 10);
end
Value=get(findobj('Tag','XaxisMenu'),'Value');
String=get(findobj('Tag','XaxisMenu'),'String');
xlabel(String{Value},'FontName','Arial','FontSize',10);

% End of PlotSingle


