function xc3d(action)
%declare variables
global fname
global pname
global xaxis
global raw
global yaxis
global data
global templatedata
global title
global colordata
global colordatas
global shadedata
global shadedatas
global interpdata
global interpdatas
global interplist
global dataextdir
global numfiles
global bins
global stbin
global finbin
global datalen
global samplexc
global rotatedata
global xlabhand
global ylabhand
global zlabhand
global axisfont
global fontset
global multaddfiles
global interpres1
global interpres2
global xi
global yi
global datai

global mathsaction

global routinetype

%New hack (RRS 2005-01-10)
global clip_data
global clip_datai
global clip_on

global main_orig_dim
global spawn_orig_dim
%-------

colordatas = {'autumn';'bone';'colorcube';'cool';'copper';'flag';'gray';'hot';'hsv';'jet';'lines';'pink';'prism';'spring';'summer';'white';'winter'};
shadedatas={'interp';'faceted';'flat'};
interplist={'Bilinear Interpolation';'Nearest Neighbour Interpolation';'Spline Interpolation';'Bicubic Interpolation'};
interpdatas={'linear';'nearest';'spline';'cubic'};

%stores the location from which this program is being run
%as this will contain the data extraction program
dataextdir = [matlabroot '\user\rowland2\'];

switch action
	
	case 'selectroutine'
		if get(findobj('tag','choosevssimp'),'value')>0
			routinetype = 'simple';
		end
		if get(findobj('tag','choosevsadd'),'value')>0
			routinetype = 'addmult';
		end
		if get(findobj('tag','choosexcorel'),'value')>0
			routinetype = 'xcorel';
		end
		set(findobj('tag','calcplot'),'enable','off');
		
	case 'initialiseroutine'
		set(findobj('tag','openbutton'),'enable','on');
		set(findobj('tag','chooseadd'),'enable','off');
		set(findobj('tag','choosemult'),'enable','off');
		set(findobj('tag','startbin'),'enable','off');
		set(findobj('tag','finalbin'),'enable','off');
		set(findobj('tag','addmultlist'),'enable','off');
		
		%New hack (RRS 2005-01-10)
		main_orig_dim=get(gh('3dplotaxes'),'Position');
		%-------
		
		switch routinetype
			case 'simple'
				set(findobj('tag','openbutton'),'string','Open VS Matrix');
				set(findobj('tag','opennbtext'),'string','');
			case 'xcorel'
				set(findobj('tag','openbutton'),'string','Open Template Matrix');
				set(findobj('tag','opennbtext'),'string','NB. Template matrix file must be in the same directory as the relevant xcorel files.');
				set(findobj('tag','startbin'),'enable','on');
				set(findobj('tag','finalbin'),'enable','on');
			case 'addmult'
				multaddfiles=[];
				set(findobj('tag','addmultlist'),'string',multaddfiles);
				set(findobj('tag','openbutton'),'string','Select VS Matrix Files');
				set(findobj('tag','opennbtext'),'string','NB. More than one file must be selected; matrixes must be of the same type and size.');
				set(findobj('tag','chooseadd'),'enable','on');
				set(findobj('tag','choosemult'),'enable','on');
				set(findobj('tag','addmultlist'),'enable','on');
		end
		
	case 'openmatrix'
		switch routinetype
			case 'simple'
				%opens VS data file using dataext.exe program which produce 3 text files
				%tempd(data with 1st column as y axis) tempx (x axis) and tempt(title/header of data file)
				[fname,pname] = uigetfile('*.txt','Specify Template Matrix File') ;
				
				cd (dataextdir);
				fn=strcat('dataextractor','£$space$£',pname,fname);
				fn=strrep(fn,'£$space$£',' ');
				dos(fn,'-echo');
				
				%assigns files produced by dataext to variables
				cd (dataextdir);
				xaxis=load('tempx.txt');
				%title=load('tempt.txt');
				raw=load('tempd.txt');
				data = raw(:,2:end);
				yaxis=raw(:,1);
				
				templatedata=data;
				
				%deletes the temporary files created
				delete temp*.txt
				
			case 'xcorel'
				%opens VS data file using dataext.exe program which produce 3 text files
				%tempd(data with 1st column as y axis) tempx (x axis) and tempt(title/header of data file)
				[fname,pname] = uigetfile('*.txt','Specify Template Matrix File') ;
				
				cd (dataextdir);
				fn=strcat('dataextractor','£$space$£',pname,fname);
				fn=strrep(fn,'£$space$£',' ');
				dos(fn,'-echo');
				
				%assigns files produced by dataext to variables
				cd (dataextdir);
				xaxis=load('tempx.txt');
				%title=load('tempt.txt');
				raw=load('tempd.txt');
				data = raw(:,2:end);
				yaxis=raw(:,1);
				
				templatedata=data;
				
				%deletes the temporary files created
				delete temp*.txt
				xc3d('findxcorelbins')
				
			case 'addmult'
				%cd(dataextdir);
				%fn=strcat('vsfilechoice','£$space$£',dataextdir);
				%fn=strrep(fn,'£$space$£',' ');
				%dos(fn);
				%multaddfiles=textread('filetemp.txt','%s');
				%set(findobj('tag','addmultlist'),'string',multaddfiles);
				%delete('filetemp.txt');
				[fn, pn] = uigetfile('*.txt', 'Add txt file to list');
				multaddfiles{end+1}=[pn fn];
				set(findobj('tag','addmultlist'),'string',multaddfiles);
		end
		set(findobj('tag','calcplot'),'enable','on');
		
		
	case 'findxcorelbins'
		cd(dataextdir);
		fn=strcat('xcorelextractor','£$space$£',pname,'1.prn');
		fn=strrep(fn,'£$space$£',' ');
		dos(fn);
		samplexc=load('tmpxc.txt');
		bins = {samplexc(:,2)};
		set(findobj('tag','startbin'),'string',bins);
		set(findobj('tag','finalbin'),'string',bins);
		
	case 'setxcorelbins'
		stbin=(get(findobj('tag','startbin'),'value'));
		finbin=(get(findobj('tag','finalbin'),'value'));
		if finbin<stbin
			tmp = finbin;
			finbin = stbin;
			stbin = tmp;
		end
		
	case 'datacalc'
		switch routinetype
			case 'xcorel'
				s = size(data);
				datalen = s(1)*s(2);
				h=waitbar(0,'Calculating.....');
				for x = 1:datalen
					waitbar((x/datalen),h);
					cd (dataextdir);
					fn=strcat('xcorelextractor','£$space$£',pname,num2str(x),'.prn');
					fn=strrep(fn,'£$space$£',' ');
					dos(fn);
					tempxc=load('tmpxc.txt');
					delete tmpxc.txt
					sumtemp=0;
					for n = stbin:finbin
						sumtemp=sumtemp+tempxc(n,3);
					end
					data(x)=sumtemp;
				end
				close(h);
			case 'simple'
				%single matrix already in memory hence no calculations necessary
				
			case 'addmult'
				fn=strcat(dataextdir,'dataextractor','£$space$£',multaddfiles{1})
				fn=strrep(fn,'£$space$£',' ')
				dos(fn,'-echo')
				%assigns files produced by dataext to variables
				cd(dataextdir);
				xaxis=load('tempx.txt');
				%title=load('tempt.txt');
				raw=load('tempd.txt');
				data = raw(:,2:end);
				yaxis=raw(:,1);
				templatedata=data;
				
				if get(findobj('tag','choosemult'),'value')>0
					mathsaction=3;
				else
					ButtonName=questdlg('Add/Subtract?', ...
						'Operation?', ...
						'Add','Subtract','Add');
					switch ButtonName
						case 'Add'
							mathsaction=1;
						otherwise
							mathsaction=2;
					end
				end
				
				cd (dataextdir);
				data = templatedata;
				for x = 2:length(multaddfiles)
					fn=strcat('dataextractor','£$space$£',multaddfiles{x});
					fn=strrep(fn,'£$space$£',' ');
					dos(fn,'-echo');
					raw=load('tempd.txt');
					tmp = raw(:,2:end);
					delete temp*.txt;
					%tmp
					%data
					%tmp.*data
					switch mathsaction
						case 1
							data = data+tmp;
						case 2
							data = data-tmp;
						case 3
							newdata = (data .* tmp);
							data = newdata;
					end
				end
		end
		
		if get(findobj('tag','interpyesno'),'value')>0
			%creates matrix of interpolated data to resolutions and type specified [datai]
			if length(interpdata)==0
				interpdata='linear';
			end
			interpres1 = str2num(get(findobj('tag','interpres1'),'string'));
			interpres2 = str2num(get(findobj('tag','interpres2'),'string'));
			x = xaxis;
			y = yaxis;
			[xi,yi]=meshgrid(min(x):interpres1:max(x),min(y):interpres2:max(y));
			[x,y]=meshgrid(x,y);
			datai=interp2(x,y,data,xi,yi,interpdata);
		end

			
		
		
	case 'graphplot'
		if length(colordata)==0
			colordata='autumn';
		end
		if length(shadedata)==0
			shadedata='interp';
		end
		t = findobj('tag','3dplotaxes');
		if get(findobj('tag','interpyesno'),'value')>0
			%New hack (RRS 2005-01-10)
			if(clip_on),
				surf(xi,yi,clip_datai);
			else
				surf(xi,yi,datai);
			end
			%------
			set(t,'ytick',yaxis);
			set(t,'yticklabel',yaxis);
			set(t,'xtick',xaxis);
			set(t,'xticklabel',xaxis);
		else
			%New hack (RRS 2005-01-10)
			if(clip_on),
				surf(clip_data);
			else
				surf(data);
			end
			%------
			set(t,'ytick',1:length(yaxis));
			set(t,'yticklabel',yaxis);
			set(t,'xtick',1:length(xaxis));
			set(t,'xticklabel',xaxis);
		end
		axis tight;
						
		colormap (colordata);
		shading (shadedata);
		
		%New hack (RRS 2005-01-10)
		colorbar off;
		set(gh('3dplotaxes'),'Position',main_orig_dim);
		
		if get(gh('usecbar'),'value')>0
			colorbar;
		end
		%------
		
		
	case 'addzeroes'
		if get(findobj('tag','addz'),'value')>0
			data(:,end+1)=(zeros(size(data,1),1));
			data(end+1,:)=(zeros(1,size(data,2)));
		else
			data=data(1:end-1,1:end-1);
		end
		xc3d('graphplot');
		
	case 'makeflat'
		set(findobj('tag','3dplotaxes'),'view',[180 90]);
		
	case 'setcolor'
		value=get(findobj('tag','colourmenu'),'Value');
		colordata=colordatas{value};
		colormap (colordata);
		
	case 'setshadedata'
		value=get(findobj('tag','shademenu'),'Value');
		shadedata=shadedatas{value};
		shading (shadedata);
		
	case 'setinterpdata'
		value=get(findobj('tag','interptype'),'Value');
		interpdata=interpdatas{value};
		
	case 'findshadesandcolours'
		set(findobj('tag','colourmenu'),'string',colordatas);
		set(findobj('tag','shademenu'),'string',shadedatas);
		set(findobj('tag','interptype'),'string',interplist);
		
	case 'spawn'
		close(findobj('tag','spawnwindow'));
		t=findobj('tag','3dplotaxes');
		rotatedata=get(t,'view');
		
		spawnwindow;
		
		%New hack (RRS 2005-01-10)
		spawn_orig_dim=get(gh('spawnaxes'),'Position');
		%-------
		
		axes(findobj('tag','spawnaxes'));
		
		if fontset == 1
			set(findobj('tag','spawnaxes'),axisfont);
		end
		
		if get(findobj('tag','interpyesno'),'value')>0
			%New hack (RRS 2005-01-10)
			if(clip_on),
				surf(xi,yi,clip_datai);
			else
				surf(xi,yi,datai);
			end
			%------
			set(gca,'ytick',yaxis);
			set(gca,'yticklabel',yaxis);
			set(gca,'xtick',xaxis);
			set(gca,'xticklabel',xaxis);
		else
			%New hack (RRS 2005-01-10)
			if(clip_on),
				surf(clip_data);
			else
				surf(data);
			end
			%------
			set(gca,'ytick',1:length(yaxis));
			set(gca,'yticklabel',yaxis);
			set(gca,'xtick',1:length(xaxis));
			set(gca,'xticklabel',xaxis);
		end
		
		axis tight;
		
		colormap(colordata);
		shading(shadedata);
		
		%New hack (RRS 2005-01-10)
		colorbar off;
		set(gh('spawnaxes'),'Position',spawn_orig_dim);
		
		if get(gh('usecbar'),'value')>0
			colorbar;
		end
		%------
		
		if get(findobj('tag','toglabel'),'value')>0
			%sets axis labels
			xlabel(get(findobj('tag','xlabel'),'string'));
			ylabel(get(findobj('tag','ylabel'),'string'));
			zlabel(get(findobj('tag','zlabel'),'string'));
		end
		
		if get(findobj('tag','reversex'),'value')>0
			set(findobj('tag','spawnaxes'),'xdir','reverse');
		end
	
		if get(findobj('tag','reversey'),'value')>0
			set(findobj('tag','spawnaxes'),'ydir','reverse');
		end
		
		if get(findobj('tag','3dvisopt'),'value')>0
			axis vis3d;
		end
		
		set(findobj('tag','spawnaxes'),'view',rotatedata);
		
		
	case 'setcolourscale'
		if get(findobj('tag','customscale'),'value')>0
			c=get(findobj('tag','minsc'),'string');
			d=get(findobj('tag','maxsc'),'string');
			a=str2num(c);
			b=str2num(d);
			if length(c).*length(d)>0
				%New hack (RRS 2005-01-10)
				clip_on=1;
				clip_data=data;
				clip_datai=datai;
				clip_datai(datai>b)=b;
				clip_datai(datai<a)=a;
				clip_data(data>b)=b;
				clip_data(data<a)=a;
				%-------
			else
				msgbox('You must specify values for minimum and maximum values','No values specified!','warn');
				set(findobj('tag','customscale'),'value',0);
			end
		else
			%New hack (RRS 2005-01-10)
			clip_on=0;
			%-------
		end
		xc3d('graphplot');
		
	case('fitplot')
		axis tight;
		
	case('threedvis')
		if get(findobj('tag','3dvisopt'),'value')>0
			axis vis3d;
		else
			axis normal;
		end
		
	case('resetax')
		axis normal;
		
	case('revx')
		if get(findobj('tag','reversex'),'value')>0
			set(findobj('tag','3dplotaxes'),'xdir','reverse');
		else
			set(findobj('tag','3dplotaxes'),'xdir','normal');
		end
		
	case('revy')
		if get(findobj('tag','reversey'),'value')>0
			set(findobj('tag','3dplotaxes'),'ydir','reverse');
		else
			set(findobj('tag','3dplotaxes'),'ydir','normal');
		end
		
	case('printset')
		printdlg;
		
		
	case('printfig')
		close(findobj('tag','spawnwindow'));
		xc3d('spawn')
		printdlg(findobj('tag','spawnwindow'));
		close(findobj('tag','spawnwindow'));
		
	case('wk1exp')
		spreadtemp=zeros(1+size(data,1),1+size(data,2));
		spreadtemp(1,1)=0;
		spreadtemp(1,2:end)=xaxis;
		spreadtemp(2:end,1)=yaxis;
		spreadtemp(2:end,2:end)=data;
		[fname,pname] = uiputfile('*.wk1','Export To .WK1 Spreadsheet file');
		cd (pname);
		wk1write(fname,spreadtemp);
		
	case('wmfclip')
		close(findobj('tag','spawnwindow'));
		xc3d('spawn');
		print(findobj('tag','spawnwindow'),'-dmeta');
		close(findobj('tag','spawnwindow'));
		
	case('bmpclip')
		close(findobj('tag','spawnwindow'));
		xc3d('spawn');
		print(findobj('tag','spawnwindow'),'-dbitmap');
		close(findobj('tag','spawnwindow'));
		
	case('setlabels')
		if get(findobj('tag','toglabel'),'value')>0
			%sets axis labels
			xlabel(get(findobj('tag','xlabel'),'string'));
			ylabel(get(findobj('tag','ylabel'),'string'));
			zlabel(get(findobj('tag','zlabel'),'string'));
			%keeps handles so labels can be deleted
			xlabhand = (xlabel(get(findobj('tag','xlabel'),'string')));
			ylabhand = (ylabel(get(findobj('tag','ylabel'),'string')));
			zlabhand = (zlabel(get(findobj('tag','zlabel'),'string')));
		else
			if (xlabhand+ylabhand+zlabhand)>0
				delete(xlabhand);
				delete(ylabhand);
				delete(zlabhand);
			end
		end
		
	case('setaxisfont')
		fontset=1;
		axisfont=uisetfont(findobj('tag','3dplotaxes'));
		
end