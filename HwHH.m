%*--------------------------------------------------------*
%|                  HwHH Analysis v0.3                    |
%|              by Rowland, December 2000                 |
%|--------------------------------------------------------| 
%|Written as an accessory to Ian's Spike Anaylsis program |
%*--------------------------------------------------------*

function HwHH(action)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Variable Declaration %%%%%%

%Variables in which to store information from the Spike Analysis Program
global varlist

%Variables containing the data to be plotted on the tuning curve
global tcdata
global tcfitdata
global tcxaxis
global tcfitxaxis

%Lists containing interpolation methods and labels and file types and labels
global interplist
global interpdatas
global sminterplist
global sminterpdatas
global filetypelist
global datafiletypelist


%Varibles used in the HwHH calculations and TCurve Plotting
global chvi %CurrentHeldVariableIndex
global hhval
global hhxvals
global chosenhhxpoints
%global uhhval
global uhhxvals
%global uchosenhhxpoints
global xclicks
global yclicks
global tmphndl
global usermax

%Matrix for exporting data
global exportmatrix
global exportinfo

%Data Structure in which to store Optimum and HwHH values for different held variables
global HwHHdata

%Data structure to store the data imported from Ian's spike program 
global data

%%%%%% End of Variable Declaration %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Main Switch %%%%%%

switch action
case 'go'
   %Sets up lists containing interpolation methods
	interplist={'Linear';'Nearest Neighbour';'Cubic Spline';'Cubic'};
	interpdatas={'linear';'nearest';'spline';'cubic'};
	sminterplist={'No Interpolation';'Linear';'Nearest Neighbour';'Cubic Spline';'Cubic'};
	sminterpdatas={'none';'linear';'nearest';'spline';'cubic'};
   filetypelist={'.AI','.TIF','.EPS'};
   datafiletypelist={'.MAT','.WK1','.TXT'};
   onoff={'on','off'};
   
   %Takes necessary data from the spike analysis program
   if data.numvars~=1
   	varlist={data.xtitle;data.ytitle};
   else
      varlist={'SingleIndependent'}
   end
   
   %Loads GUI toolbar thing
   HwHHAnalysis;
     
   %Sets up menuboxes in GUI
   set(ghft('InterpMethod'),'String',interplist);
   set(ghft('SmoothInterpMethod'),'String',sminterplist);
   set(ghft('ChooseHoldVar'),'String',varlist);
   set(ghft('PlotFileTypeMenu'),'String',filetypelist);
   set(ghft('ChooseDataType'),'String',datafiletypelist);
      
   set(ghft('StartRefresh'),'String','Start / Reset');
   
   %Sets default settings
   set(ghft('SelectInterp'),'value',1);
   set(ghft('Interpmethod'),'enable','on');
   HwHHdata.curvefit = 'interpolated';
   HwHHdata.fitattribute = 'linear';
   set(ghft('SelectAutoAxis'),'value',1);
   HwHHdata.axislimits.mode = 'auto';
	set(ghft('ChooseZeroNoise'),'value',1);      
   HwHHdata.noiselevel = 0;
   set(ghft('ChooseHeldVarValue'),'enable','on');
   set(ghft('SaveCurr'),'value',1);
   set(ghft('DiagonalCheckBox'),'value',0);
   
   %Sets up callbacks
   set(ghft('ChooseHeldVarValue'),'CallBack','HwHH(''plot'')');
   set(ghft('StartRefresh'),'CallBack','HwHH(''plotsequencepreparation''), HwHH(''plot'')');
   set(ghft('FindHwHH'),'CallBack','HwHH(''plot'')');
   set(ghft('ShowRawLine'),'CallBack','HwHH(''plot'')');
   set(ghft('ShowConstructLines'),'CallBack','HwHH(''plot'')');
   set(ghft('SavePlotButton'),'CallBack','HwHH(''saveplot'')');
   set(ghft('SaveData'),'CallBack','HwHH(''savedata'')');
   set(ghft('LoadData'),'CallBack','HwHH(''loaddata'')');
   
case 'plotsequencepreparation'
   %Finds out from GUI which variable is held and adds it to the HwHHdata structure
   if get(ghft('DiagonalCheckBox'),'value') ~= 1
      HwHHdata.heldvar.name = varlist{get(findobj('tag','ChooseHoldVar'),'Value')};
   else
      HwHHdata.heldvar.name = 'Diagonal';
   end
   
   %Finds out what sort of curve fit is being used
   if get(ghft('SelectInterp'),'Value') == 1
      HwHHdata.curvefit = 'interpolated';
      HwHHdata.fitattribute = interpdatas{get(ghft('InterpMethod'),'value')};
   end
   if get(ghft('SelectPoly'),'Value') == 1
      HwHHdata.curvefit = 'polynomial';
      HwHHdata.fitattribute = str2num(get(ghft('PolyOrder'),'string'));
   end
   if get(ghft('SelectSmooth'),'Value') == 1
      HwHHdata.curvefit = 'smoothed';
      HwHHdata.fitattribute = sminterpdatas{get(ghft('SmoothInterpMethod'),'value')};
   end
   
   %Finds out what the background noise level is set at
   if get(ghft('ChooseZeroNoise'),'Value') == 1
   	HwHHdata.noiselevel = 0;
   elseif get(ghft('ChooseUserNoise'),'Value') == 1
      HwHHdata.noiselevel = str2num(get(ghft('UserNoiseValue'),'string'));
   end
   
   %Finds out what the axis limits are
   if get(ghft('SelectAutoAxis'),'value') == 1
      HwHHdata.axislimits.mode = 'auto';
      HwHHdata.axislimits.xlimits = [];
      HwHHdata.axislimits.ylimits = [];
   else
      HwHHdata.axislimits.mode = 'manual';
      HwHHdata.axislimits.xlimits = [str2num(get(ghft('MinXAxis'),'string')) str2num(get(ghft('MaxXAxis'),'string'))];
      HwHHdata.axislimits.ylimits = [str2num(get(ghft('MinYAxis'),'string')) str2num(get(ghft('MaxYAxis'),'string'))];
   end
   
   %Puts the name of the chosen held variable in the tuning curve toolbox in the GUI
   set(ghft('HeldVarName'),'string',varlist{get(ghft('ChooseHoldVar'),'Value')});
   
   %Finds the xaxis to be used in 2D plotting and stores the values of the held variable to be used
   if data.numvars~=1
      switch HwHHdata.heldvar.name
      case {data.ytitle}
         HwHHdata.tuningvar.name = data.xtitle;
         HwHHdata.heldvar.values = data.yvalues;
         tcxaxis=data.xvalues;
         set(ghft('ChooseHeldVarValue'),'Enable','on');
         set(ghft('ChooseHeldVarValue'),'Min',1);
         set(ghft('ChooseHeldVarValue'),'Max',length(data.yvalues));
         set(ghft('ChooseHeldVarValue'),'SliderStep',[(1/(length(data.yvalues)-1)) 1]);
         set(ghft('ChooseHeldVarValue'),'Value',1);
         set(ghft('HeldVarValue'),'String',num2str(data.yvalues(1)));
      case {data.xtitle}
         HwHHdata.tuningvar.name = data.ytitle;
         HwHHdata.heldvar.values = data.xvalues
         tcxaxis=data.yvalues;
         set(ghft('ChooseHeldVarValue'),'Enable','on');
         set(ghft('ChooseHeldVarValue'),'Min',1);
         set(ghft('ChooseHeldVarValue'),'Max',length(data.xvalues));
         set(ghft('ChooseHeldVarValue'),'SliderStep',[(1/(length(data.xvalues)-1)) 1]);
         set(ghft('ChooseHeldVarValue'),'Value',1);
         set(ghft('HeldVarValue'),'String',num2str(data.xvalues(1)));
      case 'Diagonal'
         HwHHdata.tuningvar.name = strcat(data.xtitle,' (diagonal)');
         HwHHdata.heldvar.values = [1];
         tcxaxis=data.xvalues;
         set(ghft('ChooseHeldVarValue'),'Enable','on');
         set(ghft('ChooseHeldVarValue'),'Min',1);
         set(ghft('ChooseHeldVarValue'),'Max',1);
         set(ghft('ChooseHeldVarValue'),'SliderStep',[0 1]);
         set(ghft('ChooseHeldVarValue'),'Value',1);
         set(ghft('HeldVarValue'),'String','1');      
      end   
   else
      HwHHdata.tuningvar.name = data.xtitle;
      HwHHdata.heldvar.values = [1];
      tcxaxis=data.xvalues;
      set(ghft('ChooseHeldVarValue'),'Enable','on');
      set(ghft('ChooseHeldVarValue'),'Min',1);
      set(ghft('ChooseHeldVarValue'),'Max',1);
      set(ghft('ChooseHeldVarValue'),'SliderStep',[0 1]);
      set(ghft('ChooseHeldVarValue'),'Value',1);
      set(ghft('HeldVarValue'),'String','1');
   end
   
   %Sets up the HwHHdata structure with locations in which to put the optimum and HwHH values
   HwHHdata.tuningvar.optimum=zeros(1,length(HwHHdata.heldvar.values));
   HwHHdata.tuningvar.HwHH=zeros(1,length(HwHHdata.heldvar.values));
   HwHHdata.tuningvar.userHwHH=zeros(1,length(HwHHdata.heldvar.values));
   HwHHdata.tuningvar.HH=zeros(1,length(HwHHdata.heldvar.values));
      
case 'plot'
   %closes plot window if it's already open
   close(ghft('TCPlotFigure'));
   
   %finds out which held variable value we're on
   chvi = get(ghft('ChooseHeldVarValue'),'Value');
   
   %takes the relevent slice from the imported data matrix
   if data.numvars~=1
   	switch HwHHdata.heldvar.name
      case {data.ytitle}
         tcdata=data.matrix(chvi,:);   
      case {data.xtitle}
         tcdata=data.matrix(:,chvi);
      case 'Diagonal'
         tcdata=diag(data.matrix)
      end
   else
      tcdata=data.matrix(chvi,:);   
   end   
      
   %fits the chosen curve to the data
   if size(tcxaxis)~=size(tcdata)
      tcdata=tcdata';
   end
   [tcfitxaxis,tcfitdata] = fitdata(tcxaxis,tcdata,HwHHdata.curvefit,HwHHdata.fitattribute);
   
   %Opens the window used for plotting plots the data and sets up the axis
   TCPlotFigure;
   set(ghft('TCurvePlotAxis'),'NextPlot','replacechildren');
   
   switch get(ghft('ShowRawLine'),'value')
   case 0   
   	%Plots the raw data points, fitted line and dot-to-dot line
   	axes(ghft('TCurvePlotAxis'));
   	plot(tcxaxis,tcdata,'kx',tcfitxaxis,tcfitdata,'k-');
   case 1
      %Plots the raw data points and fitted line
   	axes(ghft('TCurvePlotAxis'));
   	plot(tcxaxis,tcdata,'kx',tcxaxis,tcdata,'b-',tcfitxaxis,tcfitdata,'k-');
   end
   
   %Plots construction lines if desired
   if get(ghft('ShowConstructLines'),'value')~=0 & HwHHdata.tuningvar.HH(chvi)~=0;
      hhval = HwHHdata.tuningvar.HH(chvi);
   	hhxvals = tcfitxaxis(find(tcfitdata==hhval));
   	for n = 1:1:(length(tcfitdata)-1)
      	if tcfitdata(n) < hhval & tcfitdata(n+1) > hhval
         	hhxvals = [hhxvals (.5*(tcfitxaxis(n)+tcfitxaxis(n+1)))];
      	end
      	if tcfitdata(n) > hhval & tcfitdata(n+1) < hhval
         	hhxvals = [hhxvals (.5*(tcfitxaxis(n)+tcfitxaxis(n+1)))];
      	end
   	end
   	axes(ghft('TCurvePlotAxis'));
   	set(ghft('TCurvePlotAxis'),'NextPlot','add'); 
   	plot(hhxvals,hhval*ones(1,length(hhxvals)),'bo',hhxvals,hhval*ones(1,length(hhxvals)),'r--');
   	if HwHHdata.noiselevel ~= 0
   		plot(tcxaxis,HwHHdata.noiselevel*ones(1,length(tcxaxis)),'r:');
   	end
   	plot(tcxaxis,max(tcfitdata)*ones(1,length(tcxaxis)),'r:');
   end
   
   %Sets up the axes to have the desired ranges
	switch HwHHdata.axislimits.mode
   case 'manual'
   	setaxislimits('TCurvePlotAxis',HwHHdata.axislimits.xlimits,HwHHdata.axislimits.ylimits);
	case 'auto'
      [HwHHdata.axislimits.xlimits,HwHHdata.axislimits.ylimits]=autoaxislimits('TCurvePlotAxis');    
   end
   
   %finds out how many optimum points exist, and hence finds a single optimum value
   switch length(find(tcfitdata == max(tcfitdata(find(HwHHdata.axislimits.xlimits(1)<=tcfitxaxis & tcfitxaxis<=HwHHdata.axislimits.xlimits(2))))))  
   case 1   
   	%Finds the optimum withtin the range specified and stores in HwHHdata
   	HwHHdata.tuningvar.optimum(chvi) = tcfitxaxis(find(tcfitdata == max(tcfitdata(find(HwHHdata.axislimits.xlimits(1)<=tcfitxaxis & tcfitxaxis<=HwHHdata.axislimits.xlimits(2))))));
   otherwise
      %Works out the halfway point between more than one optima
      opttmp = tcfitxaxis(find(tcfitdata == max(tcfitdata(find(HwHHdata.axislimits.xlimits(1)<=tcfitxaxis & tcfitxaxis<=HwHHdata.axislimits.xlimits(2))))));
      HwHHdata.tuningvar.optimum(chvi) = sum(opttmp)/length(opttmp);
   end
   
   %Writes the optimum under the graph plotted and in the toolbar
   set(ghft('PlotOptimumBox'),'String',strcat('Optimum = ',num2str(HwHHdata.tuningvar.optimum(chvi))));
   set(ghft('OptimumBox'),'String',num2str(HwHHdata.tuningvar.optimum(chvi)));
   
   %If already calculated, writes the HwHH under the graph plotted and in the toolbar
   if HwHHdata.tuningvar.HwHH(chvi) ~= 0
   	set(ghft('PlotHwHHBox'),'String',strcat('HwHH = ',num2str(HwHHdata.tuningvar.HwHH(chvi))));
   	set(ghft('HwHHBox'),'String',num2str(HwHHdata.tuningvar.HwHH(chvi)));
   else
      set(ghft('HwHHBox'),'String','?');
   end
   
   %If already calculated, writes the userHwHH under the graph plotted and in the toolbar
   if HwHHdata.tuningvar.userHwHH(chvi) ~= 0
   	set(ghft('PlotUserHwHHBox'),'String',strcat('User HwHH = ',num2str(HwHHdata.tuningvar.userHwHH(chvi))));
   	set(ghft('userHwHHBox'),'String',num2str(HwHHdata.tuningvar.userHwHH(chvi)));
   else
      set(ghft('userHwHHBox'),'String','?');
   end
   
   %Labels the axes
   setaxislabels('TCurvePlotAxis',HwHHdata.tuningvar.name,'Mean Spikes/Second','',tcxaxis,tcxaxis);   
   
   %Says which Held Variable value we're on in the GUI
   set(ghft('HeldVarValue'),'string',num2str(HwHHdata.heldvar.values(chvi))); 
   
   %tells it to go through the HwHH finding procedure if the user has checked the relevant box
   if get(ghft('FindHwHH'),'value')==1
      HwHH('findHwHH')
   end
   
case 'findHwHH'
   %finds out which held variable value we're on
   chvi = get(ghft('ChooseHeldVarValue'),'Value');
   
   %finds the half height within the x limits specified, taking into account the specified noise level
   hhval=HwHHdata.noiselevel+((max(tcfitdata(find(HwHHdata.axislimits.xlimits(1)<=tcfitxaxis & tcfitxaxis<=HwHHdata.axislimits.xlimits(2))))-HwHHdata.noiselevel)/2);
   HwHHdata.tuningvar.HH(chvi)=hhval;
   
   %finds data points equal to half height and adds their x coordinate to hhxvals
   hhxvals = tcfitxaxis(find(tcfitdata==hhval));
   
   %finds pairs of adjacent data points between which the hh lies, averages their x coordinates & adds them to hhxvals
   for n = 1:1:(length(tcfitdata)-1)
      if tcfitdata(n) < hhval & tcfitdata(n+1) > hhval
         hhxvals = [hhxvals (.5*(tcfitxaxis(n)+tcfitxaxis(n+1)))];
      end
      if tcfitdata(n) > hhval & tcfitdata(n+1) < hhval
         hhxvals = [hhxvals (.5*(tcfitxaxis(n)+tcfitxaxis(n+1)))];
      end
   end
   
   %Prepares the axes and plots a Half Width line with points of intersection with curve marked
   %with cirles and dotted lines marking the peak height and noise level 
   axes(ghft('TCurvePlotAxis'));
   set(ghft('TCurvePlotAxis'),'NextPlot','add'); 
   plot(hhxvals,hhval*ones(1,length(hhxvals)),'bo',hhxvals,hhval*ones(1,length(hhxvals)),'r--');
   if HwHHdata.noiselevel ~= 0
   	plot(tcxaxis,HwHHdata.noiselevel*ones(1,length(tcxaxis)),'r:');
   end
   usermax=max(tcfitdata(find(HwHHdata.axislimits.xlimits(1)<=tcfitxaxis & tcfitxaxis<=HwHHdata.axislimits.xlimits(2))));
   plot(tcxaxis,usermax*ones(1,length(tcxaxis)),'r:');
   
   %Takes coordinates of 2 clicks on the axis
   [xclicks,yclicks]=ginput(2);
        
   %stores raw user-clicked xcoordinates
   uhhxvals = [xclicks(1) xclicks(2)];
      
   %Assigns the nearest points of intersection in the x direction to the last 2 clicks 
   a = modulus(hhxvals-xclicks(1));
   b = modulus(hhxvals-xclicks(2));
   chosenhhxpoints = [hhxvals(find(a==min(a))) hhxvals(find(b==min(b)))];
   
   if get(ghft('ShowConstructLines'),'value')==0
   	%Removes the lines drawn
   	findline = get(get(gca,'children'),'YData');
   	tmphndl=get(gca,'children');
   	for n = 1:length(findline)
      	if length(findline{n})==length(hhval*ones(1,length(hhxvals))) & findline{n}==(hhval*ones(1,length(hhxvals)))
         	delete(tmphndl(n));
      	end
      	if length(findline{n})==length(tcxaxis) & findline{n}==(HwHHdata.noiselevel*ones(1,length(tcxaxis)))
         	delete(tmphndl(n));
      	end
      	if length(findline{n})==length(tcxaxis) & findline{n}==(usermax*ones(1,length(tcxaxis)))
         	delete(tmphndl(n));
      	end
   	end
   	findline = 0;
   end
      
   %Stores the HwHH value
   HwHHdata.tuningvar.HwHH(chvi)= modulus(chosenhhxpoints(1) - chosenhhxpoints(2))/2;
   
   %stores the userclicked HwHHvalue
   HwHHdata.tuningvar.userHwHH(chvi)=modulus(uhhxvals(1)-uhhxvals(2))/2;
   
   %Writes the HwHH under the graph plotted and in the toolbar
   set(ghft('PlotHwHHBox'),'String',strcat('HwHH = ',num2str(HwHHdata.tuningvar.HwHH(chvi))));
   set(ghft('PlotUserHwHHBox'),'String',strcat('User HwHH = ',num2str(HwHHdata.tuningvar.userHwHH(chvi))));
	set(ghft('HwHHBox'),'String',HwHHdata.tuningvar.HwHH(chvi));
   set(ghft('userHwHHBox'),'String',HwHHdata.tuningvar.userHwHH(chvi));
   
case 'saveplot'
   %finds out which held variable value we're on
   chvi = get(ghft('ChooseHeldVarValue'),'Value');
   
   %saves plot
   switch filetypelist{get(ghft('PlotFileTypeMenu'),'Value')}
   %case {'.BMP'}
   %	name = strcat(HwHHdata.heldvar.name,'=',num2str(HwHHdata.heldvar.values(chvi)),'.bmp');
   % 	[fname,pname] = uiputfile(name,'Save Plot as a Windows Bitmap File');
   %  	print(ghft('TCPlotFigure'),'-dbitmap',strcat(pname,fname));
   %case {'.WMF'}
   %  	name = strcat(HwHHdata.heldvar.name,'=',num2str(HwHHdata.heldvar.values(chvi)),'.wmf');
   %  	[fname,pname] = uiputfile(name,'Save Plot as a Windows Metafile');
   %  	print(ghft('TCPlotFigure'),'-dmeta',strcat(pname,fname));
   case {'.AI'}
     	name = strcat(HwHHdata.heldvar.name,'=',num2str(HwHHdata.heldvar.values(chvi)),'.ai');
     	[fname,pname] = uiputfile(name,'Save Plot as an Adobe Illustrator File');
     	print(ghft('TCPlotFigure'),'-dill',strcat(pname,fname));
   case {'.TIF'}
     	name = strcat(HwHHdata.heldvar.name,'=',num2str(HwHHdata.heldvar.values(chvi)),'.tif');
     	[fname,pname] = uiputfile(name,'Save Plot as TIFF File');
     	%NB can add -r<nn> where <nn> is the desired output resolution, otherwise defaults at 150dpi
     	print(ghft('TCPlotFigure'),'-dtiff',strcat(pname,fname));
   case {'.EPS'}
     	name = strcat(HwHHdata.heldvar.name,'=',num2str(HwHHdata.heldvar.values(chvi)),'.eps');
     	[fname,pname] = uiputfile(name,'Save Plot Encapsulated Colour Postscript File');
     	print(ghft('TCPlotFigure'),'-depsc',strcat(pname,fname));
   end
   
   %Unticks find/update HwHH box on GUI
   set(ghft('FindHwHH'),'value',0);
   
   if get(ghft('SaveAll'),'value')~=0;
   	for n = 1:length(HwHHdata.heldvar.values)
      	set(ghft('ChooseHeldVarValue'),'Value',n);
         fname = strcat(HwHHdata.heldvar.name,'=',num2str(HwHHdata.heldvar.values(n)));
         fname = strrep(fname,'\','|');
      	HwHH('plot');
      	switch filetypelist{get(ghft('PlotFileTypeMenu'),'Value')}
   		case {'.BMP'}
         	print(ghft('TCPlotFigure'),'-dbitmap',strcat(pname,fname,'.bmp'));
      	case {'.WMF'}
      		print(ghft('TCPlotFigure'),'-dmeta',strcat(pname,fname,'.wmf'));
   		case {'.AI'}
      		print(ghft('TCPlotFigure'),'-dill',strcat(pname,fname,'.ai'));
   		case {'.TIF'}
      		%NB can add -r<nn> where <nn> is the desired output resolution, otherwise defaults at 150dpi
      		print(ghft('TCPlotFigure'),'-dtiff',strcat(pname,fname,'.tif'));
   		case {'.EPS'}
      		print(ghft('TCPlotFigure'),'-depsc',strcat(pname,fname,'.eps'));
         end
   	end
   end
   
case 'savedata'
   exportinfo = strcat('Curve fit(',HwHHdata.curvefit,')_Fit type(',num2str(HwHHdata.fitattribute),')_Held Variable(',HwHHdata.heldvar.name,')_X Axis Limits(',num2str(HwHHdata.axislimits.xlimits(1)),'_to_',num2str(HwHHdata.axislimits.xlimits(2)),')_Noise Level(',num2str(HwHHdata.noiselevel),')');
   exportmatrix = zeros(length(HwHHdata.heldvar.values),5);
   exportmatrix(:,1)=(ones(length(HwHHdata.heldvar.values),1)*HwHHdata.noiselevel);
   exportmatrix(:,2)=HwHHdata.heldvar.values';
   exportmatrix(:,3)=HwHHdata.tuningvar.optimum';
   exportmatrix(:,4)=HwHHdata.tuningvar.HwHH';
   exportmatrix(:,5)=HwHHdata.tuningvar.userHwHH';
 	switch datafiletypelist{get(ghft('ChooseDataType'),'value')};
   case '.MAT'
   	[fname,pname] = uiputfile('.mat','Save Matlab Data File');  
   	save(strcat(pname,fname),'HwHHdata');
   case '.WK1'
      [fname,pname] = uiputfile('.wk1','Save .WK1 Speadsheet File');   
      wk1write(strcat(pname,fname),exportmatrix);
      dlmwrite(strcat(pname,'datainfo.txt'),exportinfo,'');
   case '.TXT'
      [fname,pname] = uiputfile('.txt','Save Delimited ASCII .txt File');  
      dlmwrite(strcat(pname,fname),exportmatrix,' , ');
      dlmwrite(strcat(pname,'datainfo.txt'),exportinfo,'');
   end
   
case 'loaddata'
   [fname,pname] = uigetfile('.mat','Choose Matlab Data File To Load');
   load(strcat(pname,fname))
   
   %Puts correct settings on GUI
   switch HwHHdata.curvefit
   case 'interpolated'
      set(ghft('SelectInterp'),'Value',1);
      set(ghft('SelectPoly'),'Value',0);
      set(ghft('SelectSmooth'),'Value',0);
      for n = 1:1:4
         if length(HwHHdata.fitattribute)==length(interpdatas{n})
         if HwHHdata.fitattribute==interpdatas{n}
            r=n;
         end
         end
      end
      set(ghft('InterpMethod'),'value',r);
      set(ghft('InterpMethod'),'enable','on');
      set(ghft('PolyOrder'),'enable','off');
      set(ghft('SmoothInterpMethod'),'enable','off');
   case 'polynomial'
      set(ghft('SelectPoly'),'Value',1);
      set(ghft('SelectInterp'),'Value',0);
      set(ghft('SelectSmooth'),'Value',0);
      set(ghft('PolyOrder'),'string',num2str(HwHHdata.fitattribute));
      set(ghft('PolyOrder'),'enable','on');
      set(ghft('InterpMethod'),'enable','off');
      set(ghft('SmoothInterpMethod'),'enable','off');
   case 'smoothed'
      set(ghft('SelectPoly'),'Value',0);
      set(ghft('SelectInterp'),'Value',0);
      set(ghft('SelectSmooth'),'Value',1);
      for n = 1:1:4
         if length(HwHHdata.fitattribute)==length(interpdatas{n})
         if HwHHdata.fitattribute==interpdatas{n}
            r=n;
         end
         end      
      end
      set(ghft('SmoothInterpMethod'),'value',r);
      set(ghft('SmoothInterpMethod'),'enable','on');
      set(ghft('PolyOrder'),'enable','off');
      set(ghft('InterpMethod'),'enable','off');
   end
   if HwHHdata.noiselevel == 0;
      set(ghft('ChooseZeroNoise'),'Value',1);
      set(ghft('ChooseUserNoise'),'Value',0);
   else
      set(ghft('ChooseUserNoise'),'Value',1);
      set(ghft('ChooseZeroNoise'),'Value',0);
      set(ghft('UserNoiseValue'),'string',num2str(HwHHdata.noiselevel));
   end
   switch HwHHdata.axislimits.mode
   case 'auto'   
      set(ghft('SelectManAxis'),'value',0);
      set(ghft('SelectAutoAxis'),'value',1);
   case 'manual'
      set(ghft('SelectManAxis'),'value',1);
      set(ghft('SelectAutoAxis'),'value',0);
      set(ghft('MinXAxis'),'string',HwHHdata.axislimits.xlimits(1));
      set(ghft('MaxXAxis'),'string',HwHHdata.axislimits.xlimits(2));
      set(ghft('MinYAxis'),'string',HwHHdata.axislimits.ylimits(1));
      set(ghft('MaxYAxis'),'string',HwHHdata.axislimits.ylimits(2));
   end
   set(ghft('HeldVarName'),'string',HwHHdata.heldvar.name);
   
   
   HwHH('plot');
   
end
%%%%%% End of Main Switch %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Additional Functions %%%%%%

%Curve fitting routine
function [xaxisout,dataout] = fitdata(xaxisin,datain,fittype,fitdetail);
	switch fittype
	case 'interpolated'
   	xaxisout = min(xaxisin):0.01:max(xaxisin);
   	dataout = interp1(xaxisin,datain,xaxisout,fitdetail);
	case 'polynomial'
   	xaxisout = min(xaxisin):0.01:max(xaxisin);
   	polyinfo = polyfit(xaxisin,datain,fitdetail);
   	dataout = polyval(polyinfo,xaxisout);
	case 'smoothed'
      %smooth calls an external smoothing routine
      switch fitdetail
      case 'none'
      	xaxisout=xaxisin;
      	dataout=smooth(datain,1);
   	otherwise
      	xaxisout = min(xaxisin):0.01:max(xaxisin);  
         dataout = smooth(interp1(xaxisin,datain,xaxisout,fitdetail),100);
     	end
   end
%End of curve fitting routine%

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
	axes(ghft(tag));
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

%GHFT GetsHandleFromTag
function [handle] = ghft(tag)
	handle=findobj('tag',tag);
%End of handle getting routine%
   
%%%%%% End Of Additional Functions %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    