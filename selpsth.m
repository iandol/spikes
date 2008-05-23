%*-------------------------------------------------*
%|Routine for selecting individual PSTH Timeslices |
%|           Rowland Sillito July 2001             |
%|                                                 |
%|    Plotting of PSTH's taken from SPIKES         |
%|    Timeslice selection taken from SPIKES        |
%|    Selection method/GUI **new**                 |
%*-------------------------------------------------*
function output=selpsth(action)
global data
persistent finished;
persistent selected;


if nargin~=0 & action(1:2)=='cb'
   action
   if selected(str2num(action(3:end)))==0
      sett(action(3:end),'Color',[1 .8 .8]);
      selected(str2num(action(3:end)))=1;
   else
      sett(action(3:end),'Color',[1 1 1]);
      selected(str2num(action(3:end)))=0;
   end   
elseif nargin==0
psthselector;
%First plot all the psth's in a grid for user selection
switch data.numvars
case 1
   m=1; %this will find the max value out of all the PSTH's and scale by this
   for i=1:data.xrange
      if m<=max(data.psth{i})
         m=max(data.psth{i});
      end
   end
   m=round(m+m/20);  %just to scale a bit bigger than the maximum value
   
   for i=1:data.xrange
      han=subplot(data.xrange,5,(data.xrange)*4+i);
      colormap([0 0 0;1 0 0]);
      bar(data.time{i},data.psth{i},1,'k');
      shading flat
      hold on
      bar(data.time{i},data.bpsth{i},1,'r');
      hold off
      %text(5,(m-m/10), data.names{y(i)},'FontSize',4);
      set(gca,'FontSize',5);
      axis tight;
      axis([-inf inf -inf m]);
      set(han,'tag',num2str(i));
      set(han,'ButtonDownFcn',strcat('selpsth(','''cb',num2str(i),''');'));
   end
   selected = zeros(1:data.xrange);
   selected(1)=1;
   sett('1','Color',[1 0 0]);
otherwise
   m=1; %this will find the max value out of all the PSTH's and scale by this
   for i=1:data.xrange*data.yrange
      if m<=max(data.psth{i})
         m=max(data.psth{i});
      end
   end
   m=round(m+m/20);  %just to scale a bit bigger than the maximum value
   
   %the problem is that our data is in rows, but subplot indexes in columns
   %so we have to create an index that converts between the 2 as
   %i want the data to look that same as it is loaded into the matrices
   x=1:(data.yrange*data.xrange);
   y=reshape(x,data.yrange,data.xrange);
   y=fliplr(y'); %order it so we can load our data to look like the surface plots
   subplot(data.yrange,data.xrange,1)
   for i=1:data.yrange*data.xrange
      han=subplot(data.yrange,data.xrange,i); 
      colormap([0 0 0;1 0 0]);
      bar(data.time{y(i)},data.psth{y(i)},1,'k');
      hold on         
      bar(data.time{(i)},data.bpsth{y(i)},1,'r');
      hold off  	
      %text(5,(m-m/10), data.names{y(i)},'FontSize',5);
      set(gca,'FontSize',5);
      axis tight;
      axis([-inf inf -inf m]);
      set(han,'tag',num2str(i));
      set(han,'ButtonDownFcn',strcat('selpsth(','''cb',num2str(i),''');'));
   end
   selected = zeros(data.yrange,data.xrange);
   selected(1)=1;
   sett('1','Color',[1 0 0]);
end
end
