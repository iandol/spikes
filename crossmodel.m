function crossmodel(action)

% Crossmodel is a GUI modeller for the cross-correlation orientation data set
% Just type crossmodel to run

global model
global init

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1;
   action='Initialize';
end

switch(action)    %As we use the GUI this switch allows us to respond to the user input
   
%%%%%%%%%%%%%%%%%%%%%%assuming we have just started%%%%%%%%%%%%%%%%%%%
case 'Initialize'   
    
   model=0;
   version='Cross Correlation Modeller V1.0a';
   crossmodelfig;
   set(gcf,'Name', version);
   set(gcf, 'DefaultLineLineWidth', 1);
   model.num=0;
   set(findobj('Tag','IntBox'),'String',{'0.1';'0.15';'0.2';'0.25';'0.3';'0.35';'0.4';'0.45';'0.55';'0.65';'0.75';'0.85';'0.95';'1'});
   init=0;
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load a Model%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Load Model'
    
   clear global model
   crossmodel('Delete Cell')
   [file path]=uigetfile('*.mat','Load Processed Model Mat File');
   if isempty(file), break, end;
   cd(path)
   load(file)
   
   set(findobj('Tag','CellText'),'String','Constructing Receptive Field...');
   
   drawrf
   
   t=['There are now ' num2str(model.num) ' cell/s in the database...'];
   set(findobj('Tag','CellText'),'String',t);
   
   b=model.cell(1).xcor(1).time';
   index=round(size(b,1)/2);
   set(findobj('Tag','StartBin'),'String',cellstr(num2str(b)));
   set(findobj('Tag','EndBin'),'String',cellstr(num2str(b)));
   set(findobj('Tag','StartBin'),'Value',index);
   set(findobj('Tag','EndBin'),'Value',index);
   set(findobj('Tag','CellMenu'),'String',model.cellnames)      
   
   makemodel
   plotmodel   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%Save Model%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Save Model'   
    
   if ~isempty(model);
      [file path]=uiputfile('*.mat','Save Model as a MAT File');
      if isempty(file), break, end;
      cd(path)
      x='model';
      save(file,x);
   else
      errordlg('No Data has been Processed...');
   end   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Cell Menu Selection%%%%%%%%%%%%%%%%%%%%%   
case 'See Cell'
   
   x=get(findobj('Tag','CellMenu'),'Value');
   name=['Cell: ' model.cellnames{x}];
   %values=[num2str(model.cell(x).xvalues)];
   sep=['Sep: ' num2str(model.cell(x).sep)];
   sizes=['RFSizes: ' num2str([model.cell(x).size1, model.cell(x).size2])];
   type=['Type: ' model.cell(x).type1 ' ' model.cell(x).type2];
   t={name;sep;sizes;type};
   set(findobj('Tag','CellText'),'String',t);
   a=cellstr(num2str(model.cell(x).xvalues'));
   set(findobj('Tag','AngleMenu'),'String',a);
   a=find(model.cell(x).xvalues==model.index(x));
   set(findobj('Tag','AngleMenu'),'Value',a);
   set(findobj('Tag','Flip'),'Value',model.flip(x));
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%Change a Cells Angle index%%%%%%%%%%%%%%%%%%%%%%   
case 'Angle'
   
   x=get(findobj('Tag','CellMenu'),'Value');
   
   String=get(findobj('Tag','AngleMenu'),'String');
   Value=get(findobj('Tag','AngleMenu'),'Value');
   model.index(x)=str2num(String{Value});
   
   drawrf
   
   makemodel
   plotmodel
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'See Tuning'
   
   datatype='Tune';
   axes(findobj('Tag','HWAxis'));
   
   corrline=zeros(1,max(size(model.xcor.angles)));
   
   s=get(findobj('Tag','StartBin'),'Value');
   f=get(findobj('Tag','EndBin'),'Value');
   
   stext=get(findobj('Tag','StartBin'),'String');
   ftext=get(findobj('Tag','EndBin'),'String');
   stext=stext{s};
   ftext=ftext{f};
   
   for i=1:max(size(model.xcor.angles))
      xsum=sum(model.xcor.matrix(s:f,i));
      corrline(i)=xsum;
   end
   
   if size(corrline,1)>size(corrline,2)
      corrline=corrline';
   end   
   %corrline=(corrline/max(corrline))*100;
   plot(model.xcor.angles,corrline,'Color',[0 0 0],'Marker','o','MarkerSize',5,'MarkerFaceColor',[0.5 0 0]);
   crossmodel('Axis');
   xlabel('Orientation (deg)');
   ylabel('Number of Correlated Events');
   set(gca,'Tag','HWAxis');
   
   model.xcor.corrline=corrline;
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Half-Width'
   
   cline=zeros(1,max(size(model.xcor.angles)));
   
   s=get(findobj('Tag','StartBin'),'Value');
   f=get(findobj('Tag','EndBin'),'Value');
   
   stext=get(findobj('Tag','StartBin'),'String');
   ftext=get(findobj('Tag','EndBin'),'String');
   stext=stext{s};
   ftext=ftext{f};
   
   for i=1:max(size(model.xcor.angles))
      xsum=sum(model.xcor.matrix(s:f,i));
      cline(i)=xsum;
   end
   
   if size(cline,1)>size(cline,2)
      cline=cline';         
   end  
   %cline=(cline/max(cline))*100;
   string=get(findobj('Tag','PolyBox'),'String');
   value=get(findobj('Tag','PolyBox'),'Value');
   pnum=str2num(string{value});
   string=get(findobj('Tag','IntBox'),'String');
   value=get(findobj('Tag','IntBox'),'Value');
   inttype=str2num(string{value});
   xval=model.xcor.angles;
   axval=axis;
   a=find(xval>=axval(1) &xval<=axval(2));
   x=xval(a);
   y=cline(a);
   p=polyfit(x,y,pnum);
   pp=polyval(p,x);
   xx=linspace(min(x),max(x),(size(x,2)*5));
   %yy=interp1(x,y,xx,inttype);
   yy=loess(x,y,xx,inttype,2);
   hold on;
   plot(xx,yy,'r',x,pp,'g');
   hold off
   [m,i]=max(yy);
   [n,j]=max(pp);
   line([axval(1) axval(2)],[n/2 n/2],'Color', [0 1 0],'LineStyle',':')
   line([axval(1) axval(2)],[m/2 m/2],'Color', [1 0 0],'LineStyle',':')
   line([xx(i) xx(i)],[axval(3) axval(4)],'Color', [1 0 0],'LineStyle',':')
   line([x(j) x(j)],[axval(3) axval(4)],'Color', [0 1 0],'LineStyle',':')
   [o,p]=ginput(2);
   m=xx(i);
   n=x(j);
   ah=m-o(1);
   ap=n-o(1);
   bh=o(2)-m;
   bp=o(2)-n;
   hw=(ah+bh)/2;
   hwp=(ap+bp)/2;   
   t=[num2str(inttype) 'Loess HWHH = ' num2str(hw) ' / Poly HWHH = ' num2str(hwp)];
   title(t,'FontSize',8);   
   line={x,y,xx,yy,x,pp};
   assignin('base','line',line);
      
%%%%%%%%%%%%%%%%%%%%%%Add a cell to the model database%%%%%%%%%%%%%%%%%%%%%%   
case 'Add Cell'
   
   if model.num==0;
      set(findobj('Tag','CellText'),'String','Initialising New Model...');
      init=1;
   end
   
   [file path]=uigetfile('*.mat','Load Cell Mat File');
   if isempty(file), break, end;
   cd(path)
   load(file)
   
   if init==1;
      model.binwidth=data.model.binwidth;
      model.window=data.model.window;
      model.index=[];
      model.flip=[];
      init=0;
   else
      if data.model.binwidth~=model.binwidth
         errordlg('Sorry, this cell has a different binwidth');
         break;
      end
      if data.model.window~=model.window
         errordlg('Sorry, this cell has a different window');
         break;
      end
   end
   
   model.num=model.num+1; %ramp up the number
   
   model.cellnames{model.num,1}=file; %give it a name
   model.cell(model.num).optimum=data.xvalues(data.model.optimum); %find the optimum value
   model.cell(model.num).xvalues=data.xvalues-model.cell(model.num).optimum; % converts the orientations in terms of the optimum
   for i=1:data.xrange
      data.xcor(i).values=(data.xcor(i).values/data.model.maxvalue)*100;
      model.cell(model.num).xcor(i).values=data.xcor(i).values;
      model.cell(model.num).xcor(i).time=data.xcor(i).time;
   end  
   model.cell(model.num).sep=data.model.sep;
   model.cell(model.num).size1=data.model.size1;
   model.cell(model.num).size2=data.model.size2;
   model.cell(model.num).type1=data.model.type1;
   model.cell(model.num).type2=data.model.type2;
   model.index=[model.index, 0];
   model.flip=[model.flip, 0];
   
   set(findobj('Tag','CellText'),'String','Constructing Receptive Field...');
   
   drawrf
   
   b=model.cell(1).xcor(1).time';
   index=round(size(b,1)/2);
   set(findobj('Tag','StartBin'),'String',cellstr(num2str(b)));
   set(findobj('Tag','EndBin'),'String',cellstr(num2str(b)));
   set(findobj('Tag','StartBin'),'Value',index);
   set(findobj('Tag','EndBin'),'Value',index);
   set(findobj('Tag','CellMenu'),'String',model.cellnames)  
   
   t=['There are now ' num2str(model.num) ' cell/s in the database...'];
   set(findobj('Tag','CellText'),'String',t);
   
   makemodel
   plotmodel
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%Delete Cell%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Delete Cell'
   
   model=0;
   model.num=0;
   set(findobj('Tag','CellText'),'String','Model Deleted, Load new data');
   init=0;
   axes(findobj('Tag','HWAxis'));
   cla;
   axes(findobj('Tag','RFAxis'));
   cla;
   
   set(findobj('Tag','StartBin'),'Value',1);
   set(findobj('Tag','EndBin'),'Value',1);
   set(findobj('Tag','StartBin'),'String','0');
   set(findobj('Tag','EndBin'),'String','0');
   set(findobj('Tag','CellMenu'),'Value',1);
   set(findobj('Tag','CellMenu'),'String',' '); 
   set(findobj('Tag','AngleMenu'),'Value',1);
   set(findobj('Tag','AngleMenu'),'String','0');
   set(findobj('Tag','Flip'),'Value',0);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Spawn Axis1'
   
   axes(findobj('Tag','RFAxis'));
   h=gca;
   cf=figure;
   copyobj(h,cf, 'legacy');   
   colormap(rbmap)
   set(gca,'Tag','spawn1')
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
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
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Spawn Axis2'  
   
   axes(findobj('Tag','HWAxis'));
   h=gca;
   cf=figure;
   copyobj(h,cf, 'legacy');
   set(gca,'Tag','spawn2')
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Exit'   
   close;
   
end %end of main switch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draws the combined receptive fields

function drawrf

global model

axes(findobj('Tag','RFAxis'));
cla
axis([-4 4 -4 4]);

gab=gabor(100,100, 28,16, pi/2, pi/2, 35,0,0,0);

xgab=linspace(-4,4,100);
ygab=linspace(-4,4,100);

onx=[0 0 1];
offx=[0 0 1];
ony=[0 0 1];
offy=[0 0 1];

pcolor(xgab,ygab,gab);
shading interp
colormap(rbmap)
set(gca,'YDir','normal');
set(gca,'Tag','RFAxis');

hold on

for i=1:model.num   
    
    r=rand;
    
  
        cell1y=model.cell(i).sep/2;  % Y position in space, + relative to 0   
        if model.index(i)>0 %check to see if we are not using optimum angle
            theta=(pi/180)*(90-model.index(i));  %convert into radians and for tan
            cell1x=(cell1y/tan(theta))*2; %X position defined from simple geometry
        elseif model.index(i)<0
            theta=(pi/180)*(90-model.index(i));  %convert into radians and for tan
            cell1x=(cell1y/tan(theta))*2;
        elseif model.index(i)==0
            cell1x=0;
        end
        cell1r=model.cell(i).size1;  %radius of RF
        if strcmp(model.cell(i).type1,'ON X'); %this simply chooses a colour
            cell1c=onx; 
        elseif strcmp(model.cell(i).type1,'OFF X');
            cell1c=offx; 
        elseif strcmp(model.cell(i).type1,'ON Y');
            cell1c=ony; 
        elseif strcmp(model.cell(i).type1,'OFF Y');
            cell1c=offy; 
        end
        
  
        cell2y=-(model.cell(i).sep/2); % Y position in space, - relative to 0
        if model.index(i)>0 %check to see if we are not using optimum angle
            theta=(pi/180)*(90-model.index(i));  %convert into radians and for tan
            cell2x=-(abs(cell2y)/tan(theta))*2; %X position defined from simple geometry
        elseif model.index(i)<0
            theta=(pi/180)*(90-model.index(i));  %convert into radians and for tan
            cell2x=-(abs(cell2y)/tan(theta))*2;
        elseif model.index(i)==0
            cell2x=0;
        end
        cell2r=model.cell(i).size2;
        if strcmp(model.cell(i).type2,'ON X');
            cell2c=onx;
        elseif strcmp(model.cell(i).type2,'OFF X');
            cell2c=offx;
        elseif strcmp(model.cell(i).type2,'ON Y');
            cell2c=ony;
        elseif strcmp(model.cell(i).type2,'OFF Y');
            cell2c=offy;
        end
  
   x=[cell1x;cell2x];
   y=[cell1y;cell2y];
   r=[cell1r;cell2r];
   c=[cell1c;cell2c];
   h=circle(r,x,y,c);
   set(h,'LineWidth',2);
end

set(gca,'Tag','RFAxis');
xlabel('Visual Space (deg)');
ylabel('Visual Space (deg)');

hold off



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Makes the model cross correlograms

function makemodel

global model

model.xcor=0;
angles=[];

for i=1:model.num %this  puts all the angles, relative to scatter into 1 list
   angles=[angles,(model.cell(i).xvalues-model.index(i))];
end

model.xcor.time=model.cell(1).xcor(1).time;
model.xcor.angles=unique(angles); %sorts and removes doubled angles
model.xcor.numcells=zeros(1,max(size(model.xcor.angles))); %initialise
model.xcor.values=cell(1,max(size(model.xcor.angles))); %initialise

for i=1:max(size(model.xcor.angles)) %set up the individual cell arrays
   model.xcor.values{i}=zeros(1,max(size(model.xcor.time)));
end

for i=1:max(size(model.xcor.angles)) %for each of the angles available
   for j=1:model.num % for each cell
      x=find((model.cell(j).xvalues-model.index(j))==model.xcor.angles(i)); %find if that cell has the angle, modified by scatter
      if x>0 %yes it does
         v=model.cell(j).xcor(x).values;
         if model.flip(j)==1  %we want to flip that cell
            v=fliplr(v);
         end         
         model.xcor.values{i}=model.xcor.values{i}+v;        
         model.xcor.numcells(i)=model.xcor.numcells(i)+1;
      end
   end
   model.xcor.values{i}=model.xcor.values{i}/model.xcor.numcells(i); %this divides each angle by the number of cells which have contributed to that angle, to normalise the values
end


model.xcor.matrix=zeros(size(model.xcor.time,2),size(model.xcor.angles,2));

for i=1:max(size(model.xcor.angles))
   model.xcor.matrix(:,i)=model.xcor.values{i}';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Just constructs a matrix and then plots it

function plotmodel

global model

axes(findobj('Tag','HWAxis'));
cla

xlinear=1:max(size(model.xcor.angles));
imagesc(xlinear,model.xcor.time,model.xcor.matrix);
set(gca,'XTick',xlinear);
set(gca,'XTickLabel',model.xcor.angles);
grid on
axis tight
colormap(rbmap);
set(gca,'Tag','HWAxis');
set(gca,'YDir','normal');

xlabel('Orientation (deg)');
ylabel('Cross Correlation Time (ms)');



