function vsrfplot(action)
%VSRFPlot Plots data files of 2 independant variables
% The raw VS text file is used as input
% Does not require any input variables as everything is GUI driven

global version;
global PlotData;
global XValues;
global YValues;
global PlotType;
global CMap;
global ShadingType;
global InterType;
global loop;
global header;

if nargin<1,
   action='Initialize';
end

switch(action)     %As we use the GUI this switch allows us to
   %respond to the user input 
   
   %%%%%%%%%%%%%%%%%%Initialise%%%%%%%%%%%%%%%%%%%%
case 'Initialize' 
   version='VS-RFPlot v1.0';
   PlotType='CheckerBoard+Contour';
   CMap='hot';
   ShadingType='interp';
   InterType='none';
   vsrffig                %this is our GUI file that we call to load
   
   %%%%%%%%%%%%%%%%%Load Data%%%%%%%%%%%%%%%%%%%%%%
case 'Load'
   
   %%%%%%%%Load file: this is the pre-frogbit method....%%%%%%%%%%%%
   %[lfile,lpath]=uigetfile('*.*','VS-RFPlot V1.0: Choose File'); 
   %   if ~lfile
   %      errordlg('No File Specified', version)
   %   else
   %load(lfile)
   %i = find(lfile == '.');      
   %a = eval(lfile(1:(i-1))); %Assigns data to variable a 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   % Frogbit pre-processes the VS file so there are only numbers and a header
   dos('"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\vsrfstrip.FB"')
   curr=pwd
   cd('c:\')
   [header,a]=hdrload('vsrftemp');  %new frogbit style 
   cd(curr)
   ylines=header(2:end,:);
   header=header(1,:);   
   x=find(ylines(1,:)=='=');
   y=find(ylines(1,:)==',');
   YValues=zeros(size(ylines,1),1);
   for i=1:size(ylines,1)
      if y>0
         x=find(ylines(i,:)=='=');
         y=find(ylines(i,:)==',');
         YValues(i,:)=str2num(ylines(i,x+1:y-1));
      else
         x=find(ylines(i,:)=='=');
         YValues(i,:)=str2num(ylines(i,x+1:end));
      end      
   end    
   XValues=unique(a(:,2));    %2nd column contains range of X variables      
   startblock=1;
   endblock=size(XValues,1);         %Chunk data in terms of x
   PlotData=ones(endblock,endblock); %Initialise data matrix
   a=a(:,3);                 %Firing data is stored in the 3rd Col 
   for i=startblock:endblock
      PlotData(:,i)=a(startblock:endblock);
      startblock=startblock+size(XValues,1);
      endblock=endblock+size(XValues,1);
   end 
   PlotData=PlotData' 
   set(gcbf, 'UserData', PlotData)         %Just in case anything else needs to know  
   rfplot(PlotData)                        %Plot the data...
   
   
   %%%%%%%%%%%%%Copies figure for output%%%%%%%%%%%%%%%%%%%%%%%%
case 'Spawn'   
   if  isempty(get(gcf,'UserData')) 
      errordlg('No File Specified',version)
   else        
      SpawnPlot(gca)
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%For two Plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'TwoPlots'
   for i=1:2
      loop=i;
      dos('"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\vsstrip.FB"')      
      curr=pwd
      cd('c:\')
      [header,a]=hdrload('frogtemp');  %new frogbit style 
      cd(curr)       
      XValues=unique(a(:,2));    %2nd column contains range of X variables      
      YValues=XValues;           %thus Y variables is total/X values
      startblock=1;
      endblock=size(XValues,1);         %Chunk data in terms of x
      PlotData=ones(endblock,endblock); %Initialise data matrix
      a=a(:,3);                 %Firing data is stored in the 3rd Col 
      for i=startblock:endblock
         PlotData(:,i)=a(startblock:endblock);
         startblock=startblock+size(XValues,1);
         endblock=endblock+size(XValues,1);
      end    
      if loop==1
         plot1=PlotData;
      elseif loop==2 
         plot2=PlotData;
      elseif loop==3
         plot3=PlotData;
      end   
   end
   %%%%%%%%%%%%%%%%%%%%Need to even out responses%%%%%%%%%%%%%%%%%%%
   plot1max=max(max(plot1));
   plot2max=max(max(plot2));
   if loop==3
      plot3max=max(max(plot3));
   end
   
   [m n]=size(plot1);
   newloop=m*n;
   for i=1:newloop
      plot1(i)=(plot1(i)/plot1max)*100;
      plot2(i)=(plot2(i)/plot2max)*100;
      if loop==3
         plot3(i)=(plot3(i)/plot3max)*100;
         if plot3(i)<40;
            plot3(i)=0.1;
         end
      end
      
      if plot1(i)<40;      %This is a threshholding function
         plot1(i)=plot1(i)*0.1;
      end
      if plot2(i)<40;
         plot2(i)=plot2(i)*0.1;
      end
      
      if loop==3
         if plot3(i)<40;
            plot3(i)=plot3(i)*0.1;
         end
      end
      
      
      
      
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if loop==2
      PlotData=plot1+plot2;
   else
      PlotData=plot1+plot2+plot3;
   end
   
   PlotData=PlotData';  %flip matrix
   set(gcbf, 'UserData', PlotData)
   rfplot(PlotData)
   cmap=igrey;
   colormap(cmap);
   FindLAngle
   
   %%%%%%%%%%%%%%%%%%%%%Load Matrix%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'Load Matrix'
   [lfile,lpath] = uigetfile('*.*','VSRFPlot: Load Matrix');    
   if ~lfile
      errordlg('No File Specified', version)   
   else      
      cd (lpath)
      load(lfile)
      i = find(lfile == '.');      
      PlotData = eval(lfile(1:(i-1)))
      set(gcbf, 'UserData', PlotData)
      rfplot(PlotData)
   end
   
   
   %%%%%%%%%%%%%%%%%%%%%Save Matrix%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'Save Matrix'
   [file,path] = uiputfile('newfile.m',version)    
   if ~file
      errordlg('No File Specified', version)   
   else      
      curr=pwd
      cd(path)
      data=get(gcbf,'UserData')
      plotmax=max(max(data));
      data=(data/plotmax)*100
      save(file, 'data','-ascii')
      cd(curr)
   end
   
   
   %%%%%%%%%%%%%%%%%%%Various call from the GUI%%%%%%%%%%%%%%%%%   
case 'PlotOpts'
   Value=get(gcbo,'Value');
   String=get(gcbo,'String');
   PlotType=String{Value};
   rfplot(PlotData)
   
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
   rfplot(PlotData)   
   
case 'Close'   
   clear all
   close(gcf)
   vs
   
end  %end switch


function rfplot(data)
%Internal function to plot the RF data according to the user options

global plothandle;
global PlotType;
global XValues;
global YValues;
global CMap;
global ShadingType;
global InterType;
global header;
%%%Find what the options are%%%


%%%Initialise Data%%%

%[x,y]=meshgrid(x,y);
%[xi,yi] = meshgrid(min(XValues):resolution:max(XValues));

%switch(InterType) %Change Interpolation Method
%   case 'Cubic'
%      zi = interp2(x,y,data,xi,yi,'*cubic');
%   case 'Nearest Neighbour'
%      zi = interp2(x,y,data,xi,yi,'*nearest');
%   case 'Linear'
%      zi = interp2(x,y,data,xi,yi,'*linear');      
%end

SmoothValue=get(findobj('Tag','SmoothSlider'),'Value');
x=XValues;
y=YValues;

switch(InterType)
case 'none'
   xx=XValues;
   yy=YValues';   
   dd=data;
case 'cubic'   
   xsmooth=(abs(x(1))+abs(x(end)))/((size(XValues,1)-1)*SmoothValue);
   ysmooth=(abs(y(1))+abs(y(end)))/((size(YValues,1)-1)*SmoothValue);   
   xx=x(1):xsmooth:x(end);
   yy=y(1):ysmooth:y(end);
   yy=yy';   
   dd=griddata(XValues,YValues',data,xx,yy,'cubic');
case 'linear'
   xsmooth=(abs(x(1))+abs(x(end)))/((size(XValues,1)-1)*SmoothValue);
   ysmooth=(abs(y(1))+abs(y(end)))/((size(YValues,1)-1)*SmoothValue);   
   xx=x(1):xsmooth:x(end);
   yy=y(1):ysmooth:y(end);
   yy=yy';
   dd=griddata(XValues,YValues',data,xx,yy,'linear');
case 'nearest'
   xsmooth=(abs(x(1))+abs(x(end)))/((size(XValues,1)-1)*SmoothValue);
   ysmooth=(abs(y(1))+abs(y(end)))/((size(YValues,1)-1)*SmoothValue);   
   xx=x(1):xsmooth:x(end);
   yy=y(1):ysmooth:y(end);
   yy=yy';
   dd=griddata(XValues,YValues',data,xx,yy,'nearest');
case 'v4'
   xsmooth=(abs(x(1))+abs(x(end)))/((size(XValues,1)-1)*SmoothValue);
   ysmooth=(abs(y(1))+abs(y(end)))/((size(YValues,1)-1)*SmoothValue);   
   xx=x(1):xsmooth:x(end);
   yy=y(1):ysmooth:y(end);
   yy=yy';
   dd=griddata(XValues,YValues',data,xx,yy,'v4');
end


switch(PlotType)    %For different plots
case 'Raw Data'
   x=XValues;
   y=YValues;
   imagesc(x,y,data)
   set(gca,'YDir','normal');
case 'Mesh'    
   mesh(xx,yy,dd)
   shading(ShadingType)
case 'CheckerBoard'
   pcolor(xx,yy,dd)
   shading(ShadingType)
case 'CheckerBoard+Contour'
   pcolor(xx,yy,dd)
   shading(ShadingType)
   hold on
   [c,h] = contour(xx,yy,dd,'k'); clabel(c,h)
   hold off
case 'Surface'
   surf(xx,yy,dd)
   shading(ShadingType)
case 'Lighted Surface'
   material metal
   surfl(xx,yy,dd)
   shading(ShadingType)
case 'Surface+Contour'
   surfc(xx,yy,dd)
   shading(ShadingType)
case 'Contour'
   [c,h] = contour(xx,yy,dd); clabel(c,h)
case 'Filled Contour'
   [c,h] = contourf(xx,yy,dd); clabel(c,h)
case 'Waterfall'
   waterfall(xx,yy,dd)
end  

if ~isempty(header)
   title(header) 
end

axis square
axis vis3d
set(gca,'XTick',XValues)
set(gca,'YTick',YValues)
xlabel('X Position (deg)')
ylabel('Y Position (deg)')

function SpawnPlot(handle)
%To plot current info on new object
cmap=get(gcf,'ColorMap');
[a,b]=view;     
childfigure=figure;
copyobj(handle,childfigure, 'legacy')
set(gca,'Position',[30 30 350 250]);
set(gca,'Units','Normalized');
colormap(cmap);
view(a,b);
colorbar;

function FindLAngle
%Works out the linking angle

[x,y]=ginput(3);                 
opp=y(2)-y(1);                    
adj=x(2)-x(1);
angle=90-(180/pi*atan(opp/adj));
str=['Angle=', num2str(angle)];
text(x(3),y(3),str);

%end of FindLAngle

function cmap=igrey
%Just a colormap....
cmap=[
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   1.0000    1.0000    1.0000
   0.9773    0.9773    0.9773
   0.9545    0.9545    0.9545
   0.9318    0.9318    0.9318
   0.9091    0.9091    0.9091
   0.8864    0.8864    0.8864
   0.8636    0.8636    0.8636
   0.8409    0.8409    0.8409
   0.8182    0.8182    0.8182
   0.7955    0.7955    0.7955
   0.7727    0.7727    0.7727
   0.7500    0.7500    0.7500
   0.7273    0.7273    0.7273
   0.7045    0.7045    0.7045
   0.6818    0.6818    0.6818
   0.6591    0.6591    0.6591
   0.6364    0.6364    0.6364
   0.6136    0.6136    0.6136
   0.5909    0.5909    0.5909
   0.5682    0.5682    0.5682
   0.5455    0.5455    0.5455
   0.5227    0.5227    0.5227
   0.5000    0.5000    0.5000
   0.4773    0.4773    0.4773
   0.4545    0.4545    0.4545
   0.4318    0.4318    0.4318
   0.4091    0.4091    0.4091
   0.3864    0.3864    0.3864
   0.3636    0.3636    0.3636
   0.3409    0.3409    0.3409
   0.3182    0.3182    0.3182
   0.2955    0.2955    0.2955
   0.2727    0.2727    0.2727
   0.2500    0.2500    0.2500
   0.2273    0.2273    0.2273
   0.2045    0.2045    0.2045
   0.1818    0.1818    0.1818
   0.1591    0.1591    0.1591
   0.1364    0.1364    0.1364
   0.1136    0.1136    0.1136
   0.0909    0.0909    0.0909
   0.0682    0.0682    0.0682
   0.0455    0.0455    0.0455
   0.0227    0.0227    0.0227
   0         0         0
];


function [header, data] = hdrload(file)
% check number and type of arguments
if nargin < 1
   error('Function requires one input argument');
elseif ~isstr(file)
   error('Input argument must be a string representing a filename');
end

% Open the file.  
fid = fopen(file);
if fid==-1
   error('File not found or permission denied');
end

% Initialize loop variables
% We store the number of lines in the header, and the maximum length
% of any one line in the header.  These are used later in assigning
% the 'header' output variable.
no_lines = 0;
max_line = 0;

% We also store the number of columns in the data we read.  This way
% we can compute the size of the output based on the number of
% columns and the total number of data points.
ncols = 0;

% Finally, we initialize the data to [].
data = [];

% Start processing.
line = fgetl(fid);
if ~isstr(line)
   disp('Warning: file contains no header and no data')
end;
[data, ncols, errmsg, nxtindex] = sscanf(line, '%f');

% One slight problem, pointed out by Peter vanderWal: If the first
% character of the line is 'e', then this will scan as 0.00e+00.
% We can trap this case specifically by using the 'next index'
% output: in the case of a stripped 'e' the next index is one,
% indicating zero characters read.  See the help entry for 'sscanf'
% for more information on this output parameter.
% We loop through the file one line at a time until we find some
% data.  After that point we stop checking for header information.
% This part of the program takes most of the processing time, because
% fgetl is relatively slow (compared to fscanf, which we will use
% later).
while isempty(data)|(nxtindex==1)
   no_lines = no_lines+1;
   max_line = max([max_line, length(line)]);
   % Create unique variable to hold this line of text information.
   % Store the last-read line in this variable.
   eval(['line', num2str(no_lines), '=line;']);
   line = fgetl(fid);
   if ~isstr(line)
      disp('Warning: file contains no data')
      break
   end;
   [data, ncols, errmsg, nxtindex] = sscanf(line, '%f');
end % while

% Now that we have read in the first line of data, we can skip the
% processing that stores header information, and just read in the
% rest of the data. 
data = [data; fscanf(fid, '%f')];
fclose(fid);

% Create header output from line information. The number of lines and
% the maximum line length are stored explicitly, and each line is
% stored in a unique variable using the 'eval' statement within the
% loop. Note that, if we knew a priori that the headers were 10 lines
% or less, we could use the STR2MAT function and save some work.
% First, initialize the header to an array of spaces.
header = setstr(' '*ones(no_lines, max_line));
for i = 1:no_lines   
   varname = ['line' num2str(i)]; 
   eval(['x = ' varname ' ';'']);
   if length(x) == 0
      eval([' ' varname ' = '' '' ';'']);
   end   
   % Note that we only assign this line variable to a subset of this
   % row of the header array.  We thus ensure that the matrix sizes in
   % the assignment are equal.
   eval(['header(i, 1:length(' varname ')) = ' varname ';']);
end

% Resize output data, based on the number of columns (as returned
% from the sscanf of the first line of data) and the total number of
% data elements. Since the data was read in row-wise, and MATLAB
% stores data in columnwise format, we have to reverse the size
% arguments and then transpose the data.  If we read in irregularly
% spaced data, then the division we are about to do will not work.
% Therefore, we will trap the error with an EVAL call; if the reshape
% fails, we will just return the data as is.
eval('data = reshape(data, ncols, length(data)/ncols)'';', '');

% End of Hdrload
