%*--------------------------------------------------------*
%|                Plateau Analysis v0.2                   |
%|              by Rowland, December 2000                 | 
%|--------------------------------------------------------|
%|Written as an accessory to Ian's Spike Anaylsis program | 
%*--------------------------------------------------------*
function Plateau(action)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Variable Declaration %%%%%%

%Variables in which to store information from the Spike Analysis Program
global varlist

%Variables containing the data to be plotted on the tuning curve
global tcdata
global tcxaxis


%Lists containing interpolation methods and labels and file types and labels
global filetypelist


%Varibles used in the HwHH calculations and TCurve Plotting
global chvi %CurrentHeldVariableIndex

global chosenpoints
global xclicks
global tmphndl

%Data Structure in which to store Optimum and HwHH values for different held variables
global PlateauData

%Data structure to store the data imported from Ian's spike program 
global data sv

%%%%%% End of Variable Declaration %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Main Switch %%%%%%

switch action
case 'go'
   %Sets up lists containing interpolation methods
   filetypelist={'.WMF','.AI','.TIF','.BMP','.EPS'};
   
   
   %Takes necessary data from the spike analysis program
%    if data.numvars>1
%        varlist={data.xtitle;data.ytitle};
%    else
%        varlist={'SingleIndependent'};
%    end
   
   %Loads GUI toolbar thing
   plateauAnalysis;
     
   %Sets up menuboxes in GUI
%    set(gh('ChooseHoldVar'),'String',varlist);
   set(gh('PlotFileTypeMenu'),'String',filetypelist);
   
   %Sets default settings
   set(gh('SelectAutoAxis'),'value',1);
   PlateauData.axislimits.mode = 'auto';
    set(gh('ChooseZeroNoise'),'value',1);      
   PlateauData.noiselevel = 0;
   set(gh('ChooseHeldVarValue'),'enable','on');
   
   %Sets up callbacks
   set(gh('ChooseHeldVarValue'),'CallBack','plateau(''plot'')');
   set(gh('StartRefresh'),'CallBack','plateau(''plotsequencepreparation''), plateau(''plot'')');
   set(gh('FindOptimum'),'CallBack','plateau(''findOptimum'')');
   set(gh('FindPlateau'),'CallBack','plateau(''findPlateau'')');
   set(gh('SavePlotButton'),'CallBack','plateau(''saveplot'')');
   
case 'plotsequencepreparation'
   %Finds out from GUI which variable is held and adds it to the PlateauData structure
   %PlateauData.heldvar.name = varlist{get(findobj('tag','ChooseHoldVar'),'Value')};
   PlateauData.heldvar.name = 'Held Variable';
   %Finds out what the axis limits are
   if get(gh('SelectAutoAxis'),'value') == 1
      PlateauData.axislimits.mode = 'auto';
      PlateauData.axislimits.xlimits = [];
      PlateauData.axislimits.ylimits = [];
   else
      PlateauData.axislimits.mode = 'manual';
      PlateauData.axislimits.xlimits = [str2num(get(gh('MinXAxis'),'string')) str2num(get(gh('MaxXAxis'),'string'))];
      PlateauData.axislimits.ylimits = [str2num(get(gh('MinYAxis'),'string')) str2num(get(gh('MaxYAxis'),'string'))];
   end
   
   %Puts the name of the chosen held variable in the tuning curve toolbox in the GUI
   %set(gh('HeldVarName'),'string',varlist{get(gh('ChooseHoldVar'),'Value')});
   
   %Finds the xaxis to be used in 2D plotting and stores the values of the held variable to be used
   if data.numvars==2		
		if sv.xlock==1 && sv.ylock==0
         PlateauData.tuningvar.name = data.ytitle;
         PlateauData.heldvar.values = data.xvalues;
         tcxaxis=data.yvalues;
%          set(gh('ChooseHeldVarValue'),'Enable','on');
%          set(gh('ChooseHeldVarValue'),'Min',1);
%          set(gh('ChooseHeldVarValue'),'Max',length(data.yvalues));
%          set(gh('ChooseHeldVarValue'),'SliderStep',[(1/(length(data.yvalues)-1)) 1]);
%          set(gh('ChooseHeldVarValue'),'Value',1);
%          set(gh('HeldVarValue'),'String',num2str(data.yvalues(1)));
		elseif sv.xlock==0 && sv.ylock==1
         PlateauData.tuningvar.name = data.xtitle;
         PlateauData.heldvar.values = data.yvalues
         tcxaxis=data.xvalues;
%          set(gh('ChooseHeldVarValue'),'Enable','on');
%          set(gh('ChooseHeldVarValue'),'Min',1);
%          set(gh('ChooseHeldVarValue'),'Max',length(data.xvalues));
%          set(gh('ChooseHeldVarValue'),'SliderStep',[(1/(length(data.xvalues)-1)) 1]);
%          set(gh('ChooseHeldVarValue'),'Value',1);
%          set(gh('HeldVarValue'),'String',num2str(data.xvalues(1)));
      end
   else
      PlateauData.tuningvar.name = data.xtitle;
      PlateauData.heldvar.values = [1];
      tcxaxis=data.xvalues;
% 		set(gh('ChooseHeldVarValue'),'Enable','on');
%       set(gh('ChooseHeldVarValue'),'Min',0);
%       set(gh('ChooseHeldVarValue'),'Max',1);
%       set(gh('ChooseHeldVarValue'),'SliderStep',[0 1]);
%       set(gh('ChooseHeldVarValue'),'Value',1);
%       set(gh('HeldVarValue'),'String','1');
   end
   
   
   %Sets up the PlateauData structure with locations in which to put the optimum and HwHH values
   PlateauData.tuningvar.optimum=zeros(1,length(PlateauData.heldvar.values));
   PlateauData.tuningvar.plateau=zeros(1,length(PlateauData.heldvar.values));
   PlateauData.tuningvar.plateaupcent=zeros(1,length(PlateauData.heldvar.values));
   PlateauData.tuningvar.optimumheight=zeros(1,length(PlateauData.heldvar.values));
   
case 'plot'
   %closes plot window if it's already open
   close(gh('TCPlotFigure'));
   
   %finds out which held variable value we're on
   %chvi = get(gh('ChooseHeldVarValue'),'Value');
	chvi = 1;
   
   %takes the relevent slice from the imported data matrix
   if data.numvars==2
      tcdata=data.matrix;  
   else
      tcdata=data.matrixall;
   end
   
    %Finds out what the background noise level is set at
   if get(gh('ChooseZeroNoise'),'Value') == 1
   	PlateauData.noiselevel = 0;
   elseif get(gh('ChooseUserNoise'),'Value') == 1
      PlateauData.noiselevel = str2num(get(gh('UserNoiseValue'),'string'));
      if PlateauData.noiselevel==-1 && tcxaxis(1)==0
          PlateauData.noiselevel=tcdata(1);
		elseif PlateauData.noiselevel<0
			PlateauData.noiselevel=0;
      end
   end

   %subtracts the noiselevel
   tcdata = tcdata - PlateauData.noiselevel;
   
   %Opens the window used for plotting plots the data and sets up the axis
   TCPlotFigure;
   set(gh('TCurvePlotAxis'),'NextPlot','replacechildren');
   
   %Plots the data
   axes(gh('TCurvePlotAxis'));
   %xlinear=1:max(size(tcxaxis));
   plot(tcxaxis,tcdata,'ko-');   
   %set(gca,'XTick',xlinear);
   %set(gca,'XTickLabel',tcxaxis');      
   
   %Sets up the axes to have the desired ranges
	switch PlateauData.axislimits.mode
   case 'manual'
   	setaxislimits('TCurvePlotAxis',PlateauData.axislimits.xlimits,PlateauData.axislimits.ylimits);
	case 'auto'
      [PlateauData.axislimits.xlimits,PlateauData.axislimits.ylimits]=autoaxislimits('TCurvePlotAxis');    
   end
   
   %If already calculated, writes the Plateau under the graph plotted and in the toolbar
   if PlateauData.tuningvar.plateau(chvi) ~= 0
   	set(gh('PlotHwHHBox'),'String',strcat('Plateau = ',num2str(PlateauData.tuningvar.plateau(chvi))));
   	set(gh('PlateauBox'),'String',num2str(PlateauData.tuningvar.plateau(chvi)));
      set(gh('Plateau%Box'),'String',num2str(PlateauData.tuningvar.plateaupcent(chvi)));
   else
      set(gh('PlateauBox'),'String','?');
      set(gh('Plateau%Box'),'String','?');
   end
   
   
   %If already calculated, writes the optimum under the graph plotted and in the toolbar
   if PlateauData.tuningvar.optimumheight(chvi) ~= 0
   	set(gh('PlotOptimumBox'),'String',strcat('Optimum = ',num2str(PlateauData.tuningvar.optimum(chvi))));
      set(gh('OptimumBox'),'String',num2str(PlateauData.tuningvar.optimum(chvi)));
      set(gh('OptimumHeightBox'),'String',num2str(PlateauData.tuningvar.optimumheight(chvi)));
   else
      set(gh('OptimumBox'),'String','?');
      set(gh('OptimumHeightBox'),'String','?');
   end
   
   %Labels the axes
   setaxislabels('TCurvePlotAxis',PlateauData.tuningvar.name,'Mean Spikes/Second','',tcxaxis,tcxaxis);   
   %xlabel(PlateauData.tuningvar.name)
   %ylabel('Spikes/Second')
   
   %Says which Held Variable value we're on in the GUI
   set(gh('HeldVarValue'),'string',num2str(PlateauData.heldvar.values(chvi))); 
   
case 'findOptimum'
   %finds out which held variable value we're on
   %chvi = get(gh('ChooseHeldVarValue'),'Value');
	chvi=1;
   
   %sets up axes
   axes(gh('TCurvePlotAxis'));
   set(gh('TCurvePlotAxis'),'NextPlot','add'); 
   
   %Takes coordinates of 1 click on the axis
   [xclicks,yclicks]=ginput(1);
      
   %Assigns the nearest point of data in the x direction to the last 1 clicks 
   a = modulus(tcxaxis-xclicks(1));
   chosenpoint = tcxaxis(find(a==min(a)));
   optimumheight = tcdata(find(a==min(a)));
   
   plot(chosenpoint, optimumheight,'ro','LineWidth',3);
   
   %Unticks find/update Optimum box on GUI
   set(gh('FindOptimum'),'value',0);
     
   %Stores the Optimum value
   PlateauData.tuningvar.optimum(chvi)= chosenpoint;
   PlateauData.tuningvar.optimumheight(chvi) = optimumheight;
   
   %Writes the Optimum under the graph plotted and in the toolbar
   set(gh('PlotOptimumBox'),'String',strcat('Optimum = ',num2str(PlateauData.tuningvar.optimum(chvi))));
   set(gh('OptimumBox'),'String',PlateauData.tuningvar.optimum(chvi));
   set(gh('OptimumHeightBox'),'String',PlateauData.tuningvar.optimumheight(chvi));

case 'findPlateau'
   %finds out which held variable value we're on
   %chvi = get(gh('ChooseHeldVarValue'),'Value');
	chvi=1;
   
   %sets up axes
   axes(gh('TCurvePlotAxis'));
   set(gh('TCurvePlotAxis'),'NextPlot','add'); 
   
   %Takes coordinates of 2 clicks on the axis
   [xclicks,yclicks]=ginput(2);
   
	%Assigns the nearest points of intersection in the x direction to the last 2 clicks 
   a = modulus(tcxaxis-xclicks(1));
   b = modulus(tcxaxis-xclicks(2));
   chosenpoints = [tcxaxis(find(a==min(a))) tcxaxis(find(b==min(b)))];
   
   %Removes the lines drawn
   findline = get(get(gca,'children'),'YData');
   tmphndl=get(gca,'children');
   for n = 1:length(findline)
      if length(findline{n})==length([PlateauData.axislimits.ylimits(1) PlateauData.axislimits.ylimits(2)]) & findline{n}==([PlateauData.axislimits.ylimits(1) PlateauData.axislimits.ylimits(2)])
         delete(tmphndl(n));
      end
   end
   findline = 0;
   
   %plots greenlines on chosen points
   plot([chosenpoints(1) chosenpoints(1)],[PlateauData.axislimits.ylimits(1) PlateauData.axislimits.ylimits(2)],'r:');
   plot([chosenpoints(2) chosenpoints(2)],[PlateauData.axislimits.ylimits(1) PlateauData.axislimits.ylimits(2)],'r:');
   
   if chosenpoints(2)>chosenpoints(1)
   	%finds plateau level
   	PlateauData.tuningvar.plateau(chvi) = mean(tcdata(find(tcxaxis<=chosenpoints(2) & tcxaxis>=chosenpoints(1))));
      Plateau = mean(tcdata(find(tcxaxis<=chosenpoints(2) & tcxaxis>=chosenpoints(1))));
   else
   	PlateauData.tuningvar.plateau(chvi) = mean(tcdata(find(tcxaxis<=chosenpoints(1) & tcxaxis>=chosenpoints(2))));
      Plateau = mean(tcdata(find(tcxaxis<=chosenpoints(1) & tcxaxis>=chosenpoints(2))));
   end
   
   plot([min(tcxaxis) max(tcxaxis)], [Plateau Plateau],'r-');
   
   %finds plateau% level
   PlateauData.tuningvar.plateaupcent(chvi) = (PlateauData.tuningvar.plateau(chvi)/(max(tcdata)))*100;
   
   t=['Plateau=', num2str(PlateauData.tuningvar.plateaupcent(chvi)), '%'];
   text(chosenpoints(1)-(chosenpoints(1)/8), Plateau+(Plateau/12),t,'Color',[1 0 0],'FontName','Arial','FontSize', 10);
   
   %writes plateau levels in GUI and plot
   set(gh('PlotHwHHBox'),'String',strcat('Plateau level = ',num2str(PlateauData.tuningvar.plateau(chvi))));
   set(gh('PlateauBox'),'String',num2str(PlateauData.tuningvar.plateau(chvi)));
   set(gh('Plateau%Box'),'String',num2str(PlateauData.tuningvar.plateaupcent(chvi)));
   
   %Unticks find/update Plateau box on GUI
   set(gh('FindPlateau'),'value',0);   

   s=[sprintf('%2.3g\t',PlateauData.tuningvar.optimum(1)) sprintf('%2.3g\t',PlateauData.tuningvar.optimumheight(1)) sprintf('%2.3g\t',PlateauData.tuningvar.plateau(1)) sprintf('%2.3g',PlateauData.tuningvar.plateaupcent(1))];
   clipboard('copy',s);
   
case 'saveplot'
   %finds out which held variable value we're on
   chvi = get(gh('ChooseHeldVarValue'),'Value');
   
   %saves plot
   switch filetypelist{get(gh('PlotFileTypeMenu'),'Value')}
   case {'.BMP'}
   	name = strcat(PlateauData.heldvar.name,'=',num2str(PlateauData.heldvar.values(chvi)),'.bmp');
      [fname,pname] = uiputfile(name,'Save Plot as a Windows Bitmap File');
      print(gh('TCPlotFigure'),'-dbitmap',strcat(pname,fname));
   case {'.WMF'}
      name = strcat(PlateauData.heldvar.name,'=',num2str(PlateauData.heldvar.values(chvi)),'.wmf');
      [fname,pname] = uiputfile(name,'Save Plot as a Windows Metafile');
      print(gh('TCPlotFigure'),'-dmeta',strcat(pname,fname));
   case {'.AI'}
      name = strcat(PlateauData.heldvar.name,'=',num2str(PlateauData.heldvar.values(chvi)),'.ai');
      [fname,pname] = uiputfile(name,'Save Plot as an Adobe Illustrator File');
      print(gh('TCPlotFigure'),'-dill',strcat(pname,fname));
   case {'.TIF'}
      name = strcat(PlateauData.heldvar.name,'=',num2str(PlateauData.heldvar.values(chvi)),'.tif');
      [fname,pname] = uiputfile(name,'Save Plot as TIFF File');
      %NB can add -r<nn> where <nn> is the desired output resolution, otherwise defaults at 150dpi
      print(gh('TCPlotFigure'),'-dtiff',strcat(pname,fname));
   case {'.EPS'}
      name = strcat(PlateauData.heldvar.name,'=',num2str(PlateauData.heldvar.values(chvi)),'.eps');
      [fname,pname] = uiputfile(name,'Save Plot Encapsulated Colour Postscript File');
      print(gh('TCPlotFigure'),'-depsc',strcat(pname,fname));
   end
end
%%%%%% End of Main Switch %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Additional Functions %%%%%%

%Axis limit setting routine
function setaxislimits(axistag,xlimits,ylimits)
   	set(findobj('tag',axistag),'XLimMode','manual');
		set(findobj('tag',axistag),'YLimMode','manual');
		set(findobj('tag',axistag),'XLim',xlimits);
      set(findobj('tag',axistag),'YLim',ylimits);
%End of axis limit setting routine%

%Auto axis limit setting/finding routine
function [autoxlim,autoylim] = autoaxislimits(axistag)
   	set(findobj('tag',axistag),'XLimMode','auto');
		set(findobj('tag',axistag),'YLimMode','auto');
		autoxlim = get(findobj('tag',axistag),'XLim');
      autoylim = get(findobj('tag',axistag),'YLim');
%End of auto axis limit setting/finding routine%

%Axis label setting routine
function setaxislabels(tag,xalabel,yalabel,tlabel,xticks,xticklabels)
	axes(gh(tag));
   xlabel(xalabel);
   ylabel(yalabel);
   title(tlabel);
   set(gca,'xtickmode','manual');
   set(gca,'xtick',xticks);
   set(gca,'xticklabelmode','manual');
   set(gca,'xticklabel',xticklabels);   
%End of axis label setting routine%

%Modulus function squares then roots a matrix losing its negative roots, thus leaving its modulus
function [matrixout] = modulus(matrixin)
	matrixout = ((matrixin.^2).^.5);
%End of modulus finding function%
   
%%%%%% End Of Additional Functions %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    