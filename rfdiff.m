function rfdiff(action)

%***************************************************************
%
%  RFDiff, GUI for comparing points in a receptive field
%
%***************************************************************

global rfd

if nargin<1;
	action='Initialize';
end

%===============================Start Here=====================================
switch(action)    %As we use the GUI this switch allows us to respond to the user input
	
	%-----------------------------------------------------------------------------------------
	case 'Initialize'
		%-----------------------------------------------------------------------------------------
		rfd=[];
		rfd.version=0.92;
		rfd.auto = 0;
		rfd.path = [];
		rfd.filelist = [];
		rfd.mversion = str2double(regexp(version,'(?<ver>^\d\.\d\d)','match','once'));
		rfd.reload=0;
		rfd.msfinish = 0;
		set(0,'DefaultTextFontSize',8);
		set(0,'DefaultAxesLayer','top');
		set(0,'DefaultAxesTickDir','out');
		set(0,'DefaultAxesTickDirMode','manual');
		
		if ismac && rfd.mversion < 7.12
			rfd.oldlook=javax.swing.UIManager.getLookAndFeel;
			javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
		elseif ispc
			
		end
		
		rfd.fighandle=rfdiff_UI; %this is the GUI figure
		
		if ismac && rfd.mversion < 7.12
			javax.swing.UIManager.setLookAndFeel(rfd.oldlook);
		end
		
		set(rfd.fighandle,'Name', ['RF Diff V' num2str(rfd.version)]);
		rfd.ax1pos=get(gh('RFDCell1Axis'),'Position');
		rfd.ax2pos=get(gh('RFDCell2Axis'),'Position');
		rfd.ax3pos=get(gh('RFDCell3Axis'),'Position');
		rfd.ax4pos=get(gh('RFDDiffAxis'),'Position');
		rfd.ax5pos=get(gh('RFDOutputAxis'),'Position');
		rfd.statstest=1;
		%-----------------------------------------------------------------------------------------
	case 'Load'
		%-----------------------------------------------------------------------------------------
		%set(gh('RFDOutputText'),'String','Please Wait...');
		if rfd.reload==0
			set(gh('RFDUseFFT'),'Value',0);
			set(gh('RFDHideABC'),'Value',0);
			set(gh('RFDYToggle'),'Value',0);
			ax1=rfd.ax1pos;
			ax2=rfd.ax2pos;
			ax3=rfd.ax3pos;
			ax4=rfd.ax4pos;
			ax5=rfd.ax5pos;
			reload=rfd.reload;
			auto = rfd.auto;
			filelist = rfd.filelist;
			path = rfd.path;
			mversion = rfd.mversion;
			rfd=[];
			rfd.mversion = mversion;
			rfd.path = path;
			rfd.filelist = filelist;
			rfd.auto=auto;
			rfd.reload=reload;
			rfd.ax1pos=ax1;
			rfd.ax2pos=ax2;
			rfd.ax3pos=ax3;
			rfd.ax4pos=ax4;
			rfd.ax5pos=ax5;
			rfd.cell1=[];
			rfd.cell2=[];
			rfd.cell3=[];
			rfd.msfinish = 0;
			
			if rfd.auto == 1
				file = rfd.filelist;
				path = rfd.path;
			else
				[file path]=uigetfile('*.*','Load Processed Matrix (one or more):','Multiselect','on');
			end
			if length(file) == 2 || length(file) == 3
				new = {''};
				cd(path);
				new = {''};
				mrep = [];
				zrep = [];
				for i = 1: length(file)
					tname= ['cell' num2str(i)];
					op=pwd;
					[~,~,ext]=fileparts(file{i});
					s=load(file{i});
					t=find(s.data.filename=='/');
					s.data.filename=[s.data.filename((t(end-2))+1:t(end)) ':' num2str(s.data.cell)];
					rfd.(tname)=s.data;
					rfd.(tname).matrixtitle = regexprep(rfd.(tname).matrixtitle, '\\fontname\{Helvetica\}\\fontsize\{12\}','');
					rfd.(tname).matrixtitle = [rfd.(tname).meta.protocol '>' rfd.(tname).matrixtitle];
					rfd.(tname).sumsorig=rfd.(tname).sums;
					midx=find(diff(rfd.(tname).xvalues)<0);
					zidx=find(diff(rfd.(tname).xvalues)==0);
					if ~isempty(midx)
						if isempty(mrep)
							prompt = ['X Value ' num2str(midx) ' wrong ( ' num2str(rfd.cell1.xvalues) ' ) | Enter New Value: '];
							prompt=regexprep(prompt,'\s+', ' ');
							new = inputdlg(prompt,'Replace X Values',1,new);
							mrep = str2num(new{1});
						end
						rfd.(tname).xvalues(midx)=mrep;
					elseif ~isempty(zidx)
						if isempty(zrep)
							prompt = ['X Value ' num2str(zidx+1) ' wrong ( ' num2str(rfd.cell1.xvalues) ' ) | Enter New Value: '];
							prompt=regexprep(prompt,'\s+', ' ');
							new = inputdlg(prompt,'Replace X Values',1,new);
							zrep = str2num(new{1});
						end
						rfd.(tname).xvalues(zidx+1)=zrep;
					end
					clear s;
				end
				if i == 3
					rfd.ignorerecovery=0;
					
				else
					rfd.ignorerecovery=1;
					rfd.cell3=[];
				end
			else
				new = {''};
				if file==0; error('1st File appears empty.'); end;
				cd(path);
				op=pwd;
				[~,~,ext]=fileparts(file);
				s1=load(file);
				t=find(s1.data.filename=='/');
				s1.data.filename=[s1.data.filename((t(end-2))+1:t(end)) ':' num2str(s1.data.cell)];
				rfd.cell1=s1.data;
				rfd.cell1.matrixtitle = regexprep(rfd.cell1.matrixtitle, '\\fontname\{Helvetica\}\\fontsize\{12\}','');
				rfd.cell1.matrixtitle = [rfd.cell1.meta.protocol '>' rfd.cell1.matrixtitle];
				rfd.cell1.sumsorig=rfd.cell1.sums;
				midx=find(diff(rfd.cell1.xvalues)<0);
				zidx=find(diff(rfd.cell1.xvalues)==0);
				if ~isempty(midx)
					prompt = ['X Value ' num2str(midx) ' wrong: ' num2str(rfd.cell1.xvalues) ' | Enter New Value:'];
					prompt=regexprep(prompt,' +', ' ');
					new = inputdlg(prompt);
					rfd.cell1.xvalues(midx)=str2num(new{1});
				elseif ~isempty(zidx)
					prompt = ['X Value ' num2str(zidx+1) ' wrong: ' num2str(rfd.cell1.xvalues) ' | Enter New Value:'];
					prompt=regexprep(prompt,' +', ' ');
					new = inputdlg(prompt);
					rfd.cell1.xvalues(zidx+1)=str2num(new{1});
				end
				clear s1
				
				[file path]=uigetfile('*.*','Load 2nd Processed Matrix:');
				if file==0; error('2nd File appears empty.'); end;
				cd(path);
				[~,~,ext]=fileparts(file);
				s2=load(file);
				t=find(s2.data.filename=='/');
				s2.data.filename=[s2.data.filename((t(end-2))+1:t(end)) ':' num2str(s2.data.cell)];
				rfd.cell2=s2.data;
				rfd.cell2.matrixtitle = regexprep(rfd.cell2.matrixtitle, '\\fontname\{Helvetica\}\\fontsize\{12\}','');
				rfd.cell2.matrixtitle = [rfd.cell2.meta.protocol '>' rfd.cell2.matrixtitle];
				rfd.cell2.sumsorig=rfd.cell2.sums;
				midx=find(diff(rfd.cell2.xvalues)<0);
				zidx=find(diff(rfd.cell2.xvalues)==0);
				if ~isempty(midx)
					prompt = ['X Value ' num2str(midx) ' wrong: ' num2str(rfd.cell2.xvalues) ' | Enter New Value:'];
					prompt=regexprep(prompt,' +', ' ');
					new = inputdlg(prompt);
					rfd.cell2.xvalues(midx)=str2num(new{1});
				elseif ~isempty(zidx)
					prompt = ['X Value ' num2str(zidx+1) ' wrong: ' num2str(rfd.cell2.xvalues) ' | Enter New Value:'];
					prompt=regexprep(prompt,' +', ' ');
					new = inputdlg(prompt);
					rfd.cell2.xvalues(zidx+1)=str2num(new{1});
				end
				clear s2
				
				[file path]=uigetfile('*.*','Load 3rd Processed Matrix:');
				if file==0
					rfd.ignorerecovery=1;
					rfd.cell3=[];
				else
					rfd.ignorerecovery=0;
					cd(path);
					[~,~,ext]=fileparts(file);
					s3=load(file);
					t=find(s3.data.filename=='/');
					s3.data.filename=[s3.data.filename((t(end-2))+1:t(end)) ':' num2str(s3.data.cell)];
					rfd.cell3=s3.data;
					rfd.cell3.matrixtitle = regexprep(rfd.cell3.matrixtitle, '\\fontname\{Helvetica\}\\fontsize\{12\}','');
					rfd.cell3.matrixtitle = [rfd.cell3.meta.protocol '>' rfd.cell3.matrixtitle];
					rfd.cell3.sumsorig=rfd.cell3.sums;
					midx=find(diff(rfd.cell3.xvalues)<0);
					zidx=find(diff(rfd.cell3.xvalues)==0);
					if ~isempty(midx)
						prompt = ['X Value ' num2str(midx) ' wrong: ' num2str(rfd.cell3.xvalues) ' | Enter New Value:'];
						new = inputdlg(prompt);
						rfd.cell3.xvalues(midx)=str2num(new{1});
					elseif ~isempty(zidx)
						prompt = ['X Value ' num2str(zidx+1) ' wrong: ' num2str(rfd.cell3.xvalues) ' | Enter New Value:'];
						new = inputdlg(prompt);
						rfd.cell3.xvalues(zidx+1)=str2num(new{1});
					end
					clear s3
				end
			end
			switch rfd.cell1.numvars
				case 3
					set(gh('RFDYToggle'),'Value',0);
					set(gh('RFDYToggle'),'Enable','off');
					set(gh('RFDZValue1'),'Enable','on');
					set(gh('RFDZValue1'),'String',cellstr(num2str(rfd.cell1.zvalues')));
					set(gh('RFDZValue1'),'Value',1);
					set(gh('RFDZValue2'),'Enable','on');
					set(gh('RFDZValue2'),'String',cellstr(num2str(rfd.cell2.zvalues')));
					set(gh('RFDZValue2'),'Value',1);
					if rfd.ignorerecovery~=1;
						set(gh('RFDZValue3'),'Enable','on');
						set(gh('RFDZValue3'),'String',cellstr(num2str(rfd.cell3.zvalues')));
						set(gh('RFDZValue3'),'Value',1);
					end
				case 2
					if get(gh('RFDYToggle'),'Value')==1
						set(gh('RFDYValue1'),'Enable','on');
						set(gh('RFDYValue2'),'Enable','on');
						if rfd.ignorerecovery~=1;set(gh('RFDYValue3'),'Enable','on');end
					end
					set(gh('RFDYValue1'),'String',cellstr(num2str(rfd.cell1.yvalues')));
					set(gh('RFDYValue1'),'Value',1);
					set(gh('RFDYValue2'),'String',cellstr(num2str(rfd.cell2.yvalues')));
					set(gh('RFDYValue2'),'Value',1);
					if rfd.ignorerecovery~=1;
						set(gh('RFDYValue3'),'String',cellstr(num2str(rfd.cell3.yvalues')));
						set(gh('RFDYValue3'),'Value',1);
					end
				otherwise
					set(gh('RFDZValue1'),'Value',1);
					set(gh('RFDZValue1'),'Enable','off');
					set(gh('RFDZValue1'),'String',' ');
					set(gh('RFDZValue2'),'Value',1);
					set(gh('RFDZValue2'),'Enable','off');
					set(gh('RFDZValue2'),'String',' ');
					set(gh('RFDZValue3'),'Value',1);
					set(gh('RFDZValue3'),'Enable','off');
					set(gh('RFDZValue3'),'String',' ');
					set(gh('RFDYValue1'),'Value',1);
					set(gh('RFDYValue1'),'Enable','off');
					set(gh('RFDYValue1'),'String',' ');
					set(gh('RFDYValue2'),'Value',1);
					set(gh('RFDYValue2'),'Enable','off');
					set(gh('RFDYValue2'),'String',' ');
					set(gh('RFDYValue3'),'Value',1);
					set(gh('RFDYValue3'),'Enable','off');
					set(gh('RFDYValue3'),'String',' ');
			end
		else
			rfd.reload=0;
			rfd.cell1.sums=rfd.cell1.sumsorig;
			rfd.cell2.sums=rfd.cell2.sumsorig;
			if rfd.ignorerecovery~=1;
				rfd.cell3.sums=rfd.cell3.sumsorig;
			end
		end
		
		zval1=1;
		zval2=1;
		zval3=1;
		yval1=1;
		yval2=1;
		yval3=1;
		
		rfd.cell1.numvars=rfd.cell2.numvars; %reset for when we lock y
		
		switch rfd.cell1.numvars
			case 3
				zval1 = get(gh('RFDZValue1'),'Value');
				zval2 = get(gh('RFDZValue2'),'Value');
				zval3 = get(gh('RFDZValue3'),'Value');
				if isempty(zval1); zval1=1; end
				if isempty(zval2); zval2=1; end
				if isempty(zval3); zval3=1; end
				rfd.cell1.matrix=rfd.cell1.matrixall(:,:,zval1);
				rfd.cell2.matrix=rfd.cell2.matrixall(:,:,zval2);
				if rfd.ignorerecovery==0
					rfd.cell3.matrix=rfd.cell3.matrixall(:,:,zval3);
				end
			case 2
				if get(gh('RFDYToggle'),'Value')==1
					yval1 = get(gh('RFDYValue1'),'Value');
					yval2 = get(gh('RFDYValue2'),'Value');
					yval3 = get(gh('RFDYValue3'),'Value');
					if isempty(yval1); yval1=1; end
					if isempty(yval2); yval2=1; end
					if isempty(yval3); yval3=1; end
					rfd.cell1.matrix=rfd.cell1.matrixall(yval1,:);
					rfd.cell2.matrix=rfd.cell2.matrixall(yval2,:);
					rfd.cell1.errormat=rfd.cell1.errormatall(yval1,:);
					rfd.cell2.errormat=rfd.cell2.errormatall(yval2,:);
					if rfd.ignorerecovery==0
						rfd.cell3.matrix=rfd.cell3.matrixall(yval3,:);
						rfd.cell3.errormat=rfd.cell3.errormatall(yval3,:);
					end
					rfd.cell1.numvars=1;
				else
					rfd.cell1.matrix=rfd.cell1.matrixall;
					rfd.cell2.matrix=rfd.cell2.matrixall;
					rfd.cell1.errormat=rfd.cell1.errormatall;
					rfd.cell2.errormat=rfd.cell2.errormatall;
					if rfd.ignorerecovery==0
						rfd.cell3.matrix=rfd.cell3.matrixall;
						rfd.cell3.errormat=rfd.cell3.errormatall;
					end
				end
		end
		
		if rfd.cell1.xvalues~=rfd.cell2.xvalues
			errordlg('Sorry,the two cells seem to have different Variables');
			error('Mismatch between cells');
		end
		
		if rfd.cell1.yvalues~=rfd.cell2.yvalues
			errordlg('Sorry,the two cells seem to have different Variables');
			error('Mismatch between cells');
		end
		
		timeinf=rfd.cell1.matrixtitle;
		index=findstr(':',timeinf);
		switch rfd.cell1.numvars
			case 0
				if length(index)>2 %old files have different title format for 0 variable files
					timeinf=timeinf(index(2)+1:index(3)-4);
				else
					timeinf=timeinf(index(end)+1:end-1);
				end
				index=findstr('-',timeinf);
				timeinf=str2num(timeinf(index+1:end));
			otherwise
				timeinf=timeinf(index(2)+1:index(3)-4);
				index=findstr('-',timeinf);
				timeinf=str2num(timeinf(index+1:end));
		end
		
		timemultiplier=1000/timeinf;
		
		if get(gh('RFDUseFFT'),'Value')==1
			if ~isfield(rfd.cell1,'fftsums') || ~isfield(rfd.cell2,'fftsums')
				errordlg('Sorry this data was not measured with the FFT yet, please reprocess in spikes and reload...')
				error('Sorry this data was not measured with the FFT yet, please reprocess in spikes...');
			end
			rfd.cell1.sums=rfd.cell1.fftsums;
			rfd.cell2.sums=rfd.cell2.fftsums;
			if rfd.ignorerecovery~=1;
				rfd.cell3.sums=rfd.cell3.fftsums;
			end
			timemultiplier=1;
		end
		
		axes(gh('RFDCell1Axis'));
		cla reset
		switch rfd.cell1.numvars
			case 0
				errorbar(rfd.cell1.matrix,rfd.cell1.errormat,'Color',[0 0 0]);
				if rfd.cell1.matrix
					axis([0.9 1.1 0 rfd.cell1.matrix+(2*rfd.cell1.errormat)]);
				end
			case 1
				areabar(rfd.cell1.xvalues,rfd.cell1.matrix,rfd.cell1.errormat,[],'k.-');
				set(gca,'XTick',rfd.cell1.xvalues);
				axis tight
				padaxis(gca,0.2);
				if get(gh('RFDYToggle'),'Value')==1
					legend(['y=' num2str(rfd.cell1.yvalues(yval1))],'Location','Best');
				end
			otherwise
				imagesc(rfd.cell1.xvalues,rfd.cell1.yvalues,rfd.cell1.matrix);
				set(gca,'XTick',rfd.cell1.xvalues);
				set(gca,'YTick',rfd.cell1.yvalues);
				set(gca,'YDir','normal');
				rfd.ax1cbar=colorbar('peer',gca,'FontSize',6);
				pos=get(rfd.ax1cbar,'Position');
				set(rfd.ax1cbar,'Position',[0.2 pos(2) 0.01 0.269]);
		end
		set(gca,'Tag','RFDCell1Axis');
		set(gca,'FontSize',7);
		set(gh('RFDCell1Axis'),'Position',rfd.ax1pos);
		
		[a,b]=find(rfd.cell1.matrix==max(max(rfd.cell1.matrix)));
		if get(gh('RFDYToggle'),'Value')==1
			rfd.cell1max=[yval1 rfd.cell1.xindex(b)];
		else
			rfd.cell1max=[rfd.cell1.yindex(a) rfd.cell1.xindex(b)];
		end
		
		axes(gh('RFDCell2Axis'));
		cla reset
		switch rfd.cell1.numvars
			case 0
				errorbar(rfd.cell2.matrix,rfd.cell2.errormat,'Color',[0 0 0]);
				if rfd.cell2.matrix>0
					axis([0.9 1.1 0 rfd.cell2.matrix+(2*rfd.cell2.errormat)]);
				end
			case 1
				areabar(rfd.cell2.xvalues,rfd.cell2.matrix,rfd.cell2.errormat,[],'k.-');
				set(gca,'XTick',rfd.cell1.xvalues);
				axis tight
				padaxis(gca,0.2);
				if get(gh('RFDYToggle'),'Value')==1
					legend(['y=' num2str(rfd.cell2.yvalues(yval2))],'Location','Best');
				end
			otherwise
				imagesc(rfd.cell2.xvalues,rfd.cell2.yvalues,rfd.cell2.matrix);
				set(gca,'XTick',rfd.cell1.xvalues);
				set(gca,'YTick',rfd.cell1.yvalues);
				set(gca,'YDir','normal');
				rfd.ax2cbar=colorbar('peer',gca,'FontSize',6);
				pos=get(rfd.ax2cbar,'Position');
				set(rfd.ax2cbar,'Position',[0.2 pos(2) 0.01 0.269]);
		end
		set(gca,'Tag','RFDCell2Axis');
		set(gca,'FontSize',7);
		set(gh('RFDCell2Axis'),'Position',rfd.ax2pos);
		
		[a,b]=find(rfd.cell2.matrix==max(max(rfd.cell2.matrix)));
		if get(gh('RFDYToggle'),'Value')==1
			rfd.cell2max=[yval2 rfd.cell1.xindex(b)];
		else
			rfd.cell2max=[rfd.cell1.yindex(a) rfd.cell1.xindex(b)];
		end
		
		if rfd.ignorerecovery==0
			axes(gh('RFDCell3Axis'));
			cla reset
			switch rfd.cell1.numvars
				case 0
					errorbar(rfd.cell3.matrix,rfd.cell3.errormat,'Color',[0 0 0]);
					if rfd.cell3.matrix>0
						axis([0.9 1.1 0 rfd.cell3.matrix+(2*rfd.cell3.errormat)]);
					end
				case 1
					areabar(rfd.cell3.xvalues,rfd.cell3.matrix,rfd.cell3.errormat,[],'k.-');
					set(gca,'XTick',rfd.cell1.xvalues);
					axis tight
					padaxis(gca,0.2);
					if get(gh('RFDYToggle'),'Value')==1
						legend(['y=' num2str(rfd.cell3.yvalues(yval3))],'Location','Best');
					end
				otherwise
					imagesc(rfd.cell3.xvalues,rfd.cell3.yvalues,rfd.cell3.matrix);
					set(gca,'XTick',rfd.cell1.xvalues);
					set(gca,'YTick',rfd.cell1.yvalues);
					set(gca,'YDir','normal');
					set(gca,'Tag','RFDCell3Axis');
					rfd.ax3cbar=colorbar('peer',gca,'FontSize',6);
					pos=get(rfd.ax3cbar,'Position');
					set(rfd.ax3cbar,'Position',[0.2 pos(2) 0.01 0.269]);
					set(gh('RFDCell3Axis'),'Position',rfd.ax3pos);
					[a,b]=find(rfd.cell3.matrix==max(max(rfd.cell3.matrix)));
					rfd.cell3max=[rfd.cell1.yindex(a) rfd.cell1.xindex(b)];
			end
		else
			axes(gh('RFDCell3Axis'));
			plot(0,0);
			axis off;
		end
		set(gca,'Tag','RFDCell3Axis');
		set(gca,'FontSize',7);
		set(gh('RFDCell3Axis'),'Position',rfd.ax3pos);
		
		rfd.diffmatrix=abs(rfd.cell1.matrix-rfd.cell2.matrix);
		[a,b]=find(rfd.diffmatrix==max(max(rfd.diffmatrix)));
		if length(a)>1
			a=a(1);
		end
		if length(b)>1
			b=b(1);
		end
		rfd.diffmax=[rfd.cell1.yindex(a) rfd.cell1.xindex(b)];
		
		axes(gh('RFDDiffAxis'));
		switch rfd.cell1.numvars
			case 0
				plot(rfd.diffmatrix,'k.');
				ylabel('Difference');
				set(gca,'Tag','RFDDiffAxis');
				set(gh('RFDDiffAxis'),'Position',rfd.ax4pos);
			case 1
				plot(rfd.cell1.xvalues,rfd.diffmatrix,'ko-');
				set(gca,'XTick',rfd.cell1.xvalues);
				axis tight
				padaxis(gca,0.2);
				set(gca,'Tag','RFDDiffAxis');
				set(gh('RFDDiffAxis'),'Position',rfd.ax4pos);
			otherwise
				imagesc(rfd.cell1.xvalues,rfd.cell1.yvalues,rfd.diffmatrix);
				set(gca,'Tag','RFDDiffAxis');
				set(gca,'XTick',rfd.cell1.xvalues);
				set(gca,'YTick',rfd.cell1.yvalues);
				colorbar;
				set(gca,'YDir','normal');
				set(gca,'Tag','RFDDiffAxis');
				set(gh('RFDDiffAxis'),'Position',rfd.ax4pos);
		end
		
		
		startrun=str2num(get(gh('RFDStartRun'),'String'));
		endrun=str2num(get(gh('RFDEndRun'),'String'));
		if endrun==Inf;
			endrun1=length(rfd.cell1.sums{rfd.cell1max(1),rfd.cell1max(2),zval1});
			endrun2=length(rfd.cell2.sums{rfd.cell1max(1),rfd.cell1max(2),zval1});
			endrun=min([endrun1 endrun2]);
		end
		if get(gh('RFDYToggle'),'Value')==0
			rfd.comparea.cell1=rfd.cell1.sums{rfd.cell1max(1),rfd.cell1max(2),zval1}(startrun:endrun).*timemultiplier;
			rfd.comparea.cell2=rfd.cell2.sums{rfd.cell1max(1),rfd.cell1max(2),zval2}(startrun:endrun).*timemultiplier;
		else
			rfd.comparea.cell1=rfd.cell1.sums{yval1,rfd.cell1max(2),zval1}(startrun:endrun).*timemultiplier;
			rfd.comparea.cell2=rfd.cell2.sums{yval2,rfd.cell1max(2),zval2}(startrun:endrun).*timemultiplier;
		end
		[rfd.comparea.cell1mean,rfd.comparea.cell1error]=stderr(rfd.comparea.cell1);
		[rfd.comparea.cell2mean,rfd.comparea.cell2error]=stderr(rfd.comparea.cell2);
		[rfd.comparea.cell1ff]=stderr(rfd.comparea.cell1,'F',1); %fano factor
		[rfd.comparea.cell2ff]=stderr(rfd.comparea.cell2,'F',1); %fano factor
		[h,rfd.comparea.ttest]=dostatstest((rfd.comparea.cell1-rfd.comparea.cell2),0,0.05);
		if rfd.ignorerecovery==0
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparea.cell3=rfd.cell3.sums{rfd.cell1max(1),rfd.cell1max(2),zval3}(startrun:endrun).*timemultiplier;
			else
				rfd.comparea.cell3=rfd.cell3.sums{yval3,rfd.cell1max(2),zval3}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparea.cell3mean,rfd.comparea.cell3error]=stderr(rfd.comparea.cell3);
			[rfd.comparea.cell3ff]=stderr(rfd.comparea.cell3,'F',1); %fano factor
			[h,rfd.comparea.ttestr]=dostatstest((rfd.comparea.cell1-rfd.comparea.cell3),0,0.05);
		end
		switch rfd.cell1.numvars
			case 0
				rfd.xy{1}=0;
			case 1
				rfd.xy{1}=rfd.cell1.xvalues(rfd.cell1max(2));
			otherwise
				rfd.xy{1}=[rfd.cell1.xvalues(rfd.cell1max(2)) rfd.cell1.yvalues(rfd.cell1max(1))];
		end
		
		
		endrun=str2num(get(gh('RFDEndRun'),'String'));
		if endrun==Inf;
			endrun1=length(rfd.cell1.sums{rfd.cell1max(1),rfd.cell1max(2),zval1});
			endrun2=length(rfd.cell2.sums{rfd.cell1max(1),rfd.cell1max(2),zval1});
			endrun=min([endrun1 endrun2]);
		end
		if get(gh('RFDYToggle'),'Value')==0
			rfd.compareb.cell1=rfd.cell1.sums{rfd.cell2max(1),rfd.cell2max(2),zval1}(startrun:endrun).*timemultiplier;
			rfd.compareb.cell2=rfd.cell2.sums{rfd.cell2max(1),rfd.cell2max(2),zval2}(startrun:endrun).*timemultiplier;
		else
			rfd.compareb.cell1=rfd.cell1.sums{yval1,rfd.cell2max(2),zval1}(startrun:endrun).*timemultiplier;
			rfd.compareb.cell2=rfd.cell2.sums{yval2,rfd.cell2max(2),zval2}(startrun:endrun).*timemultiplier;
		end
		[rfd.compareb.cell1mean,rfd.compareb.cell1error]=stderr(rfd.compareb.cell1);
		[rfd.compareb.cell2mean,rfd.compareb.cell2error]=stderr(rfd.compareb.cell2);
		[rfd.compareb.cell1ff]=stderr(rfd.compareb.cell1,'F',1); %fano factor
		[rfd.compareb.cell2ff]=stderr(rfd.compareb.cell2,'F',1); %fano factor
		[h,rfd.compareb.ttest]=dostatstest((rfd.compareb.cell1-rfd.compareb.cell2),0,0.05);
		if rfd.ignorerecovery==0
			if get(gh('RFDYToggle'),'Value')==0
				rfd.compareb.cell3=rfd.cell3.sums{rfd.cell2max(1),rfd.cell2max(2),zval3}(startrun:endrun).*timemultiplier;
			else
				rfd.compareb.cell3=rfd.cell3.sums{yval3,rfd.cell2max(2),zval3}(startrun:endrun).*timemultiplier;
			end
			[rfd.compareb.cell3mean,rfd.compareb.cell3error]=stderr(rfd.compareb.cell3);
			[rfd.compareb.cell3ff]=stderr(rfd.compareb.cell3,'F',1); %fano factor
			[h,rfd.compareb.ttestr]=dostatstest((rfd.compareb.cell1-rfd.compareb.cell3),0,0.05);
		end
		switch rfd.cell1.numvars
			case 0
				rfd.xy{2}=[0];
			case 1
				rfd.xy{2}=[rfd.cell1.xvalues(rfd.cell2max(2))];
			otherwise
				rfd.xy{2}=[rfd.cell1.xvalues(rfd.cell2max(2)) rfd.cell1.yvalues(rfd.cell2max(1))];
		end
		
		endrun=str2num(get(gh('RFDEndRun'),'String'));
		if endrun==Inf;
			endrun1=length(rfd.cell1.sums{rfd.cell1max(1),rfd.cell1max(2),zval1});
			endrun2=length(rfd.cell2.sums{rfd.cell1max(1),rfd.cell1max(2),zval1});
			endrun=min([endrun1 endrun2]);
		end
		if get(gh('RFDYToggle'),'Value')==0
			rfd.comparec.cell1=rfd.cell1.sums{rfd.diffmax(1),rfd.diffmax(2),zval1}(startrun:endrun).*timemultiplier;
			rfd.comparec.cell2=rfd.cell2.sums{rfd.diffmax(1),rfd.diffmax(2),zval2}(startrun:endrun).*timemultiplier;
		else
			rfd.comparec.cell1=rfd.cell1.sums{yval1,rfd.diffmax(2),zval1}(startrun:endrun).*timemultiplier;
			rfd.comparec.cell2=rfd.cell2.sums{yval2,rfd.diffmax(2),zval2}(startrun:endrun).*timemultiplier;
		end
		[rfd.comparec.cell1mean,rfd.comparec.cell1error]=stderr(rfd.comparec.cell1);
		[rfd.comparec.cell2mean,rfd.comparec.cell2error]=stderr(rfd.comparec.cell2);
		[rfd.comparec.cell1ff]=stderr(rfd.comparec.cell1,'F',1); %fano factor
		[rfd.comparec.cell2ff]=stderr(rfd.comparec.cell2,'F',1); %fano factor
		[h,rfd.comparec.ttest]=dostatstest((rfd.comparec.cell1-rfd.comparec.cell2),0,0.05);
		if rfd.ignorerecovery==0
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparec.cell3=rfd.cell3.sums{rfd.diffmax(1),rfd.diffmax(2),zval3}(startrun:endrun).*timemultiplier;
			else
				rfd.comparec.cell3=rfd.cell3.sums{yval3,rfd.diffmax(2),zval3}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparec.cell3mean,rfd.comparec.cell3error]=stderr(rfd.comparec.cell3);
			[rfd.comparec.cell3ff]=stderr(rfd.comparec.cell3,'F',1); %fano factor
			[h,rfd.comparec.ttestr]=dostatstest((rfd.comparec.cell1-rfd.comparec.cell3),0,0.05);
		end
		switch rfd.cell1.numvars
			case 0
				rfd.xy{3}=[0];
			case 1
				ypos=axis;
				ypos=ypos(4);
				ypos=ypos-(ypos/10);
				rfd.xy{3}=[rfd.cell1.xvalues(rfd.diffmax(2))];
				if get(gh('RFDHideABC'),'Value')==0
					text(rfd.cell1.xvalueso(rfd.cell1max(2)),ypos+rand,'a','FontSize',12);
					text(rfd.cell2.xvalueso(rfd.cell2max(2)),ypos,'b','FontSize',12);
					text(rfd.cell1.xvalueso(rfd.diffmax(2)),ypos-rand,'c','FontSize',12);
				end
			otherwise
				rfd.xy{3}=[rfd.cell1.xvalues(rfd.diffmax(2)) rfd.cell1.yvalues(rfd.diffmax(1))];
				if get(gh('RFDHideABC'),'Value')==0
					text(rfd.cell1.xvalueso(rfd.cell1max(2))+0.1,rfd.cell1.yvalueso(rfd.cell1max(1))+rand,'a','FontSize',12);
					text(rfd.cell2.xvalueso(rfd.cell2max(2)),rfd.cell2.yvalueso(rfd.cell2max(1)),'b','FontSize',12);
					text(rfd.cell1.xvalueso(rfd.diffmax(2))-0.1,rfd.cell1.yvalueso(rfd.diffmax(1))-rand,'c','FontSize',12);
				end
		end
		
		if get(gh('RFDDOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDDX'),'String'));
			y=str2num(get(gh('RFDDY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{4}=[0];
				case 1
					rfd.xy{4}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{4}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf;
				endrun1=length(rfd.cell1.sums{y,x,zval1});
				endrun2=length(rfd.cell2.sums{y,x,zval1});
				endrun=min([endrun1 endrun2]);
			end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.compared.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.compared.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.compared.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.compared.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.compared.cell1mean,rfd.compared.cell1error]=stderr(rfd.compared.cell1);
			[rfd.compared.cell2mean,rfd.compared.cell2error]=stderr(rfd.compared.cell2);
			[rfd.compared.cell1ff]=stderr(rfd.compared.cell1,'F',1); %fano factor
			[rfd.compared.cell2ff]=stderr(rfd.compared.cell2,'F',1); %fano factor
			[h,rfd.compared.ttest]=dostatstest((rfd.compared.cell1-rfd.compared.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.compared.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.compared.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.compared.cell3mean,rfd.compared.cell3error]=stderr(rfd.compared.cell3);
				[rfd.compared.cell3ff]=stderr(rfd.compared.cell3,'F',1); %fano factor
				[h,rfd.compared.ttestr]=dostatstest((rfd.compared.cell1-rfd.compared.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDDX'),'String')),str2num(get(gh('RFDDY'),'String'))+rand,'d','FontSize',12);
		end
		
		if get(gh('RFDEOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDEX'),'String'));
			y=str2num(get(gh('RFDEY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{5}=[0];
				case 1
					rfd.xy{5}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{5}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf;
				endrun1=length(rfd.cell1.sums{y,x,zval1});
				endrun2=length(rfd.cell2.sums{y,x,zval1});
				endrun=min([endrun1 endrun2]);
			end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparee.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparee.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.comparee.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparee.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparee.cell1mean,rfd.comparee.cell1error]=stderr(rfd.comparee.cell1);
			[rfd.comparee.cell2mean,rfd.comparee.cell2error]=stderr(rfd.comparee.cell2);
			[rfd.comparee.cell1ff]=stderr(rfd.comparee.cell1,'F',1); %fano factor
			[rfd.comparee.cell2ff]=stderr(rfd.comparee.cell2,'F',1); %fano factor
			[h,rfd.comparee.ttest]=dostatstest((rfd.comparee.cell1-rfd.comparee.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.comparee.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.comparee.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.comparee.cell3mean,rfd.comparee.cell3error]=stderr(rfd.comparee.cell3);
				[rfd.comparee.cell3ff]=stderr(rfd.comparee.cell3,'F',1); %fano factor
				[h,rfd.comparee.ttestr]=dostatstest((rfd.comparee.cell1-rfd.comparee.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDEX'),'String')),str2num(get(gh('RFDEY'),'String'))+rand,'e','FontSize',12);
		end
		
		if get(gh('RFDFOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDFX'),'String'));
			y=str2num(get(gh('RFDFY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{6}=[0];
				case 1
					rfd.xy{6}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{6}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf;
				endrun1=length(rfd.cell1.sums{y,x,zval1});
				endrun2=length(rfd.cell2.sums{y,x,zval1});
				endrun=min([endrun1 endrun2]);
			end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparef.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparef.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.comparef.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparef.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparef.cell1mean,rfd.comparef.cell1error]=stderr(rfd.comparef.cell1);
			[rfd.comparef.cell2mean,rfd.comparef.cell2error]=stderr(rfd.comparef.cell2);
			[rfd.comparef.cell1ff]=stderr(rfd.comparef.cell1,'F',1); %fano factor
			[rfd.comparef.cell2ff]=stderr(rfd.comparef.cell2,'F',1); %fano factor
			[h,rfd.comparef.ttest]=dostatstest((rfd.comparef.cell1-rfd.comparef.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.comparef.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.comparef.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.comparef.cell3mean,rfd.comparef.cell3error]=stderr(rfd.comparef.cell3);
				[rfd.comparef.cell3ff]=stderr(rfd.comparef.cell3,'F',1); %fano factor
				[h,rfd.comparef.ttestr]=dostatstest((rfd.comparef.cell1-rfd.comparef.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDFX'),'String')),str2num(get(gh('RFDFY'),'String'))+rand,'f','FontSize',12);
		end
		
		if get(gh('RFDGOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDGX'),'String'));
			y=str2num(get(gh('RFDGY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{7}=[0];
				case 1
					rfd.xy{7}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{7}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf;
				endrun1=length(rfd.cell1.sums{y,x,zval1});
				endrun2=length(rfd.cell2.sums{y,x,zval1});
				endrun=min([endrun1 endrun2]);
			end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.compareg.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.compareg.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.compareg.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.compareg.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.compareg.cell1mean,rfd.compareg.cell1error]=stderr(rfd.compareg.cell1);
			[rfd.compareg.cell2mean,rfd.compareg.cell2error]=stderr(rfd.compareg.cell2);
			[rfd.compareg.cell1ff]=stderr(rfd.compareg.cell1,'F',1); %fano factor
			[rfd.compareg.cell2ff]=stderr(rfd.compareg.cell2,'F',1); %fano factor
			[h,rfd.compareg.ttest]=dostatstest((rfd.compareg.cell1-rfd.compareg.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.compareg.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.compareg.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.compareg.cell3mean,rfd.compareg.cell3error]=stderr(rfd.compareg.cell3);
				[rfd.compareg.cell3ff]=stderr(rfd.compareg.cell3,'F',1); %fano factor
				[h,rfd.compareg.ttestr]=dostatstest((rfd.compareg.cell1-rfd.compareg.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDGX'),'String')),str2num(get(gh('RFDGY'),'String'))+rand,'g','FontSize',12);
		end
		
		if get(gh('RFDHOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDHX'),'String'));
			y=str2num(get(gh('RFDHY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{8}=[0];
				case 1
					rfd.xy{8}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{8}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf;
				endrun1=length(rfd.cell1.sums{y,x,zval1});
				endrun2=length(rfd.cell2.sums{y,x,zval1});
				endrun=min([endrun1 endrun2]);
			end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.compareh.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.compareh.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.compareh.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.compareh.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.compareh.cell1mean,rfd.compareh.cell1error]=stderr(rfd.compareh.cell1);
			[rfd.compareh.cell2mean,rfd.compareh.cell2error]=stderr(rfd.compareh.cell2);
			[rfd.compareh.cell1ff]=stderr(rfd.compareh.cell1,'F',1); %fano factor
			[rfd.compareh.cell2ff]=stderr(rfd.compareh.cell2,'F',1); %fano factor
			[h,rfd.compareh.ttest]=dostatstest((rfd.compareh.cell1-rfd.compareh.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.compareh.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.compareh.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.compareh.cell3mean,rfd.compareh.cell3error]=stderr(rfd.compareh.cell3);
				[rfd.compareh.cell3ff]=stderr(rfd.compareh.cell3,'F',1); %fano factor
				[h,rfd.compareh.ttestr]=dostatstest((rfd.compareh.cell1-rfd.compareh.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDHX'),'String')),str2num(get(gh('RFDHY'),'String'))+rand,'h','FontSize',12);
		end
		
		if get(gh('RFDIOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDIX'),'String'));
			y=str2num(get(gh('RFDIY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{9}=[0];
				case 1
					rfd.xy{9}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{9}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf;
				endrun1=length(rfd.cell1.sums{y,x,zval1});
				endrun2=length(rfd.cell2.sums{y,x,zval1});
				endrun=min([endrun1 endrun2]);
			end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparei.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparei.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.comparei.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparei.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparei.cell1mean,rfd.comparei.cell1error]=stderr(rfd.comparei.cell1);
			[rfd.comparei.cell2mean,rfd.comparei.cell2error]=stderr(rfd.comparei.cell2);
			[rfd.comparei.cell1ff]=stderr(rfd.comparei.cell1,'F',1); %fano factor
			[rfd.comparei.cell2ff]=stderr(rfd.comparei.cell2,'F',1); %fano factor
			[h,rfd.comparei.ttest]=dostatstest((rfd.comparei.cell1-rfd.comparei.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.comparei.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.comparei.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.comparei.cell3mean,rfd.comparei.cell3error]=stderr(rfd.comparei.cell3);
				[rfd.comparei.cell3ff]=stderr(rfd.comparei.cell3,'F',1); %fano factor
				[h,rfd.comparei.ttestr]=dostatstest((rfd.comparei.cell1-rfd.comparei.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDIX'),'String')),str2num(get(gh('RFDIY'),'String'))+rand,'i','FontSize',12);
		end
		
		if get(gh('RFDJOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDJX'),'String'));
			y=str2num(get(gh('RFDJY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{10}=[0];
				case 1
					rfd.xy{10}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{10}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf; endrun=length(rfd.cell1.sums{y,x,zval1}); end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparej.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparej.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.comparej.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparej.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparej.cell1mean,rfd.comparej.cell1error]=stderr(rfd.comparej.cell1);
			[rfd.comparej.cell2mean,rfd.comparej.cell2error]=stderr(rfd.comparej.cell2);
			[rfd.comparej.cell1ff]=stderr(rfd.comparej.cell1,'F',1); %fano factor
			[rfd.comparej.cell2ff]=stderr(rfd.comparej.cell2,'F',1); %fano factor
			[h,rfd.comparej.ttest]=dostatstest((rfd.comparej.cell1-rfd.comparej.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.comparej.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.comparej.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.comparej.cell3mean,rfd.comparej.cell3error]=stderr(rfd.comparej.cell3);
				[rfd.comparej.cell3ff]=stderr(rfd.comparej.cell3,'F',1); %fano factor
				[h,rfd.comparej.ttestr]=dostatstest((rfd.comparej.cell1-rfd.comparej.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDJX'),'String')),str2num(get(gh('RFDJY'),'String'))+rand,'j','FontSize',12);
		end
		
		if get(gh('RFDKOn'),'Value')==1 && rfd.cell1.numvars>0
			x=str2num(get(gh('RFDKX'),'String'));
			y=str2num(get(gh('RFDKY'),'String'));
			switch rfd.cell1.numvars
				case 0
					rfd.xy{11}=[0];
				case 1
					rfd.xy{11}=[x];
					x=find(rfd.cell1.xvalues==x);
					y=1;
				otherwise
					rfd.xy{11}=[x y];
					x=find(rfd.cell1.xvalues==x);
					y=find(rfd.cell1.yvalues==y);
			end
			endrun=str2num(get(gh('RFDEndRun'),'String'));
			if endrun==Inf; endrun=length(rfd.cell1.sums{y,x,zval1}); end
			if get(gh('RFDYToggle'),'Value')==0
				rfd.comparek.cell1=rfd.cell1.sums{y,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparek.cell2=rfd.cell2.sums{y,x,zval2}(startrun:endrun).*timemultiplier;
			else
				rfd.comparek.cell1=rfd.cell1.sums{yval1,x,zval1}(startrun:endrun).*timemultiplier;
				rfd.comparek.cell2=rfd.cell2.sums{yval2,x,zval2}(startrun:endrun).*timemultiplier;
			end
			[rfd.comparek.cell1mean,rfd.comparek.cell1error]=stderr(rfd.comparek.cell1);
			[rfd.comparek.cell2mean,rfd.comparek.cell2error]=stderr(rfd.comparek.cell2);
			[rfd.comparek.cell1ff]=stderr(rfd.comparek.cell1,'F',1); %fano factor
			[rfd.comparek.cell2ff]=stderr(rfd.comparek.cell2,'F',1); %fano factor
			[h,rfd.comparek.ttest]=dostatstest((rfd.comparek.cell1-rfd.comparek.cell2),0,0.05);
			if rfd.ignorerecovery==0
				if get(gh('RFDYToggle'),'Value')==0
					rfd.comparek.cell3=rfd.cell3.sums{y,x,zval3}(startrun:endrun).*timemultiplier;
				else
					rfd.comparek.cell3=rfd.cell3.sums{yval3,x,zval3}(startrun:endrun).*timemultiplier;
				end
				[rfd.comparek.cell3mean,rfd.comparek.cell3error]=stderr(rfd.comparek.cell3);
				[rfd.comparek.cell3ff]=stderr(rfd.comparek.cell3,'F',1); %fano factor
				[h,rfd.comparek.ttestr]=dostatstest((rfd.comparek.cell1-rfd.comparek.cell3),0,0.05);
			end
			text(str2num(get(gh('RFDKX'),'String')),str2num(get(gh('RFDKY'),'String'))+rand,'i','FontSize',12);
		end
		
		
		if get(gh('RFDHideABC'),'Value')==0
			if rfd.ignorerecovery==0
				out=[rfd.comparea.cell1mean rfd.comparea.cell2mean rfd.comparea.cell3mean; rfd.compareb.cell1mean rfd.compareb.cell2mean rfd.compareb.cell3mean; rfd.comparec.cell1mean rfd.comparec.cell2mean rfd.comparec.cell3mean];
				outerror=[rfd.comparea.cell1error rfd.comparea.cell2error rfd.comparea.cell3error; rfd.compareb.cell1error rfd.compareb.cell2error rfd.compareb.cell3error; rfd.comparec.cell1error rfd.comparec.cell2error  rfd.comparec.cell3error];
				outff=[rfd.comparea.cell1ff rfd.comparea.cell2ff rfd.comparea.cell3ff; rfd.compareb.cell1ff rfd.compareb.cell2ff rfd.compareb.cell3ff; rfd.comparec.cell1ff rfd.comparec.cell2ff rfd.comparec.cell3ff];
			else
				out=[rfd.comparea.cell1mean rfd.comparea.cell2mean; rfd.compareb.cell1mean rfd.compareb.cell2mean; rfd.comparec.cell1mean rfd.comparec.cell2mean];
				outerror=[rfd.comparea.cell1error rfd.comparea.cell2error; rfd.compareb.cell1error rfd.compareb.cell2error; rfd.comparec.cell1error rfd.comparec.cell2error];
				outff=[rfd.comparea.cell1ff rfd.comparea.cell2ff; rfd.compareb.cell1ff rfd.compareb.cell2ff; rfd.comparec.cell1ff rfd.comparec.cell2ff];
			end
			label={'a';'b';'c'};
		else
			out=[];
			outerror=[];
			outff=[];
			label={};
		end
		
		if get(gh('RFDDOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.compared.cell1mean rfd.compared.cell2mean rfd.compared.cell3mean];
				outerror=[outerror;rfd.compared.cell1error rfd.compared.cell2error rfd.compared.cell3error];
				outff=[outff;rfd.compared.cell1ff rfd.compared.cell2ff rfd.compared.cell3ff];
			else
				out=[out;rfd.compared.cell1mean rfd.compared.cell2mean];
				outerror=[outerror;rfd.compared.cell1error rfd.compared.cell2error];
				outff=[outff;rfd.compared.cell1ff rfd.compared.cell2ff];
			end
			label=[label;{'d'}];
		end
		if get(gh('RFDEOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.comparee.cell1mean rfd.comparee.cell2mean rfd.comparee.cell3mean];
				outerror=[outerror;rfd.comparee.cell1error rfd.comparee.cell2error rfd.comparee.cell3error];
				outff=[outff;rfd.comparee.cell1ff rfd.comparee.cell2ff rfd.comparee.cell3ff];
			else
				out=[out;rfd.comparee.cell1mean rfd.comparee.cell2mean];
				outerror=[outerror;rfd.comparee.cell1error rfd.comparee.cell2error];
				outff=[outff;rfd.comparee.cell1ff rfd.comparee.cell2ff];
			end
			label=[label;{'e'}];
		end
		if get(gh('RFDFOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.comparef.cell1mean rfd.comparef.cell2mean rfd.comparef.cell3mean];
				outerror=[outerror;rfd.comparef.cell1error rfd.comparef.cell2error rfd.comparef.cell3error];
				outff=[outff;rfd.comparef.cell1ff rfd.comparef.cell2ff rfd.comparef.cell3ff];
			else
				out=[out;rfd.comparef.cell1mean rfd.comparef.cell2mean];
				outerror=[outerror;rfd.comparef.cell1error rfd.comparef.cell2error];
				outff=[outff;rfd.comparef.cell1ff rfd.comparef.cell2ff];
			end
			label=[label;{'f'}];
		end
		if get(gh('RFDGOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.compareg.cell1mean rfd.compareg.cell2mean rfd.compareg.cell3mean];
				outerror=[outerror;rfd.compareg.cell1error rfd.compareg.cell2error rfd.compareg.cell3error];
				outff=[outff;rfd.compareg.cell1ff rfd.compareg.cell2ff rfd.compareg.cell3ff];
			else
				out=[out;rfd.compareg.cell1mean rfd.compareg.cell2mean];
				outerror=[outerror;rfd.compareg.cell1error rfd.compareg.cell2error];
				outff=[outff;rfd.compareg.cell1ff rfd.compareg.cell2ff];
			end
			label=[label;{'g'}];
		end
		if get(gh('RFDHOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.compareh.cell1mean rfd.compareh.cell2mean rfd.compareh.cell3mean];
				outerror=[outerror;rfd.compareh.cell1error rfd.compareh.cell2error rfd.compareh.cell3error];
				outff=[outff;rfd.compareh.cell1ff rfd.compareh.cell2ff rfd.compareh.cell3ff];
			else
				out=[out;rfd.compareh.cell1mean rfd.compareh.cell2mean];
				outerror=[outerror;rfd.compareh.cell1error rfd.compareh.cell2error];
				outff=[outff;rfd.compareh.cell1ff rfd.compareh.cell2ff];
			end
			label=[label;{'h'}];
		end
		if get(gh('RFDIOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.comparei.cell1mean rfd.comparei.cell2mean rfd.comparei.cell3mean];
				outerror=[outerror;rfd.comparei.cell1error rfd.comparei.cell2error rfd.comparei.cell3error];
				outff=[outff;rfd.comparei.cell1ff rfd.comparei.cell2ff rfd.comparei.cell3ff];
			else
				out=[out;rfd.comparei.cell1mean rfd.comparei.cell2mean];
				outerror=[outerror;rfd.comparei.cell1error rfd.comparei.cell2error];
				outff=[outff;rfd.comparei.cell1ff rfd.comparei.cell2ff];
			end
			label=[label;{'i'}];
		end
		if get(gh('RFDJOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.comparej.cell1mean rfd.comparej.cell2mean rfd.comparej.cell3mean];
				outerror=[outerror;rfd.comparej.cell1error rfd.comparej.cell2error rfd.comparej.cell3error];
				outff=[outff;rfd.comparej.cell1ff rfd.comparej.cell2ff rfd.comparej.cell3ff];
			else
				out=[out;rfd.comparej.cell1mean rfd.comparej.cell2mean];
				outerror=[outerror;rfd.comparej.cell1error rfd.comparej.cell2error];
				outff=[outff;rfd.comparej.cell1ff rfd.comparej.cell2ff];
			end
			label=[label;{'j'}];
		end
		if get(gh('RFDKOn'),'Value')==1 && rfd.cell1.numvars>0
			if rfd.ignorerecovery==0
				out=[out;rfd.comparek.cell1mean rfd.comparek.cell2mean rfd.comparek.cell3mean];
				outerror=[outerror;rfd.comparek.cell1error rfd.comparek.cell2error rfd.comparek.cell3error];
				outff=[outff;rfd.comparek.cell1ff rfd.comparek.cell2ff rfd.comparek.cell3ff];
			else
				out=[out;rfd.comparek.cell1mean rfd.comparek.cell2mean];
				outerror=[outerror;rfd.comparek.cell1error rfd.comparek.cell2error];
				outff=[outff;rfd.comparek.cell1ff rfd.comparek.cell2ff];
			end
			label=[label;{'k'}];
		end
		
		axes(gh('RFDOutputAxis'));
		cla;
		if ~isempty(out)
			if size(out,1)==1
				barswitherror(out',outerror');
				axis([0 size(out,2)+1 -inf inf]);
			else
				barswitherror(out,outerror);
				axis([0 size(out,1)+1 -inf inf]);
			end
			set(gca,'XTick',1:size(out,1));
			set(gca,'XTickLabel',label);
			
			set(gca,'Tag','RFDOutputAxis');
			set(gh('RFDOutputAxis'),'Position',rfd.ax5pos);
			%axis tight;
		end
		
		rfd.out = [];
		rfd.outerror =  [];
		rfd.outff = [];
		rfd.outp = [];
		rfd.outrp = [];
		
		meanstext='';
		errorstext='';
		fftext='';
		for i=1:size(out,1)
			for j=1:size(out,2)
				meanstext=[meanstext sprintf('%2.3f\t',out(i,j))];
				errorstext=[errorstext sprintf('%2.3f\t',outerror(i,j))];
				fftext=[fftext sprintf('%2.3f\t',outff(i,j))];
			end
		end
		
		rfd.out = out(1,:);
		rfd.outerror =  outerror(1,:);
		rfd.outff = outff(1,:);
		
		if rfd.ignorerecovery==0;
			toffset=0.75;
		else
			toffset=0.85;
		end
		if get(gh('RFDHideABC'),'Value')==0
			text(toffset,0,['p = ' num2str(rfd.comparea.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			toffset=toffset+1;
			text(toffset,0,['p = ' num2str(rfd.compareb.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			toffset=toffset+1;
			text(toffset,0,['p = ' num2str(rfd.comparec.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
		end
		if rfd.ignorerecovery==0
			outtext={rfd.cell1.matrixtitle;rfd.cell2.matrixtitle;rfd.cell3.matrixtitle};
			if get(gh('RFDHideABC'),'Value')==0
				rfd.outp = [sprintf('%2.3f\t',rfd.comparea.ttest) sprintf('%2.3f\t',rfd.compareb.ttest) sprintf('%2.3f\t',rfd.comparec.ttest)];
				outtext{4}=[sprintf('%s\t','P:') rfd.outp];
				rfd.outrp = [sprintf('%2.3f\t',rfd.comparea.ttestr) sprintf('%2.3f\t',rfd.compareb.ttestr) sprintf('%2.3f\t',rfd.comparec.ttestr)];
				outtext{5}=[sprintf('%s\t','Recovery P:') rfd.outrp];
			else
				outtext{4}=[sprintf('%s\t','P:')];
				outtext{5}=[sprintf('%s\t','Recovery P:')];
			end
			outtext{6}=[sprintf('%s\t','means:') meanstext];
			outtext{7}=[sprintf('%s\t','errors:') errorstext];
			outtext{8}=[sprintf('%s\t','ff:') fftext];
			if get(gh('RFDDOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.compared.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.compared.ttestr)];
				if toffset>0.75;
					toffset=toffset+1;
				end
				text(toffset,0,['p = ' num2str(rfd.compared.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDEOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.comparee.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.comparee.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparee.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDFOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.comparef.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.comparef.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparef.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDGOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.compareg.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.compareg.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.compareg.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDHOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.compareh.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.compareh.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.compareh.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDIOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.comparei.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.comparei.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparei.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDJOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.comparej.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.comparej.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparej.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDKOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{4}=[outtext{4} sprintf('%2.3f\t',rfd.comparek.ttest)];
				outtext{5}=[outtext{5} sprintf('%2.3f\t',rfd.comparek.ttestr)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparek.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
		else
			outtext={rfd.cell1.matrixtitle;rfd.cell2.matrixtitle};
			if get(gh('RFDHideABC'),'Value')==0
				rfd.outp = [sprintf('%2.3f\t',rfd.comparea.ttest) sprintf('%2.3f\t',rfd.compareb.ttest) sprintf('%2.3f\t',rfd.comparec.ttest)];
				outtext{3}=[sprintf('%s\t','P:') rfd.outp];
			else
				toffset = 0.75;
				outtext{3}=[sprintf('%s\t','P:')];
			end
			outtext{4}=[sprintf('%s\t','means:') meanstext];
			outtext{5}=[sprintf('%s\t','errors:') errorstext];
			outtext{6}=[sprintf('%s\t','ff:') fftext];
			if get(gh('RFDDOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.compared.ttest)];
				if toffset>0.75;
					toffset=toffset+1;
				else
					toffset=toffset+0.08;
				end
				text(toffset,0,['p = ' num2str(rfd.compared.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDEOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.comparee.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparee.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDFOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.comparef.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparef.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDGOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.compareg.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.compareg.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDHOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.compareh.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.compareh.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDIOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.comparei.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparei.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDJOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.comparej.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparej.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
			if get(gh('RFDKOn'),'Value')==1 && rfd.cell1.numvars>0
				outtext{3}=[outtext{3} sprintf('%2.3f\t',rfd.comparek.ttest)];
				toffset=toffset+1;
				text(toffset,0,['p = ' num2str(rfd.comparek.ttest)],'Rotation',90,'FontSize',9,'FontName','verdana');
			end
		end
		
		thetatext=sprintf('%s\t','theta:');
		rhotext=sprintf('%s\t','rho:');
		if get(gh('RFDExternal'),'Value')==1
			mainx=str2num(get(gh('RFDX'),'String'));
			mainy=str2num(get(gh('RFDY'),'String'));
			for i=1:length(rfd.xy)
				
				vx=rfd.xy{i}(1)-mainx;
				vy=rfd.xy{i}(2)-mainy;
				
				[theta,rho]=cart2pol(vx,vy);
				
				rfd.thetas{i}=rad2ang(theta);
				rfd.rhos{i}=rho;
				thetatext=[thetatext sprintf('%3.2f\t',rfd.thetas{i})];
				rhotext=[rhotext sprintf('%3.2f\t',rfd.rhos{i})];
			end
		end
		
		outtext{length(outtext)+1}=thetatext;
		outtext{length(outtext)+1}=rhotext;
		outtext{length(outtext)+1} = ['X Values: ' num2str(rfd.cell1.xvalues)];
		
		set(gh('RFDOutputText'),'String',outtext);
		rfd.outtext = outtext;
		
		%-----------------------------------------------------------------------------------------
	case 'Measure'
		%-----------------------------------------------------------------------------------------
		if isempty(rfd)
			error('MeasureError')
		end
		%-----set up some run variables
		rfd.cell1spike=[];
		rfd.cell2spike=[];
		rfd.cell1time=[];
		rfd.cell2time=[];
		
		raw(1).cell1=rfd.cell1.raw{rfd.cell1max};
		raw(1).cell2=rfd.cell2.raw{rfd.cell1max};
		raw(2).cell1=rfd.cell1.raw{rfd.cell2max};
		raw(2).cell2=rfd.cell2.raw{rfd.cell2max};
		raw(3).cell1=rfd.cell1.raw{rfd.diffmax};
		raw(3).cell2=rfd.cell2.raw{rfd.diffmax};
		
		binwidth=rfd.cell1.binwidth;startrun=1;endrun=inf;wrapped=rfd.cell1.wrapped;
		
		for i=1:3
			[time(i),psth(i),rawl(i),sm(i),raws(i)]=binit(raw(i).cell1,binwidth*10,1,inf,startrun,endrun,wrapped);
			[time2(i),psth2(i),rawl2(i),sm2(i),raws2(i)]=binit(raw(i).cell2,binwidth*10,1,inf,startrun,endrun,wrapped);
		end
		
		%-----------------------------------------------------------------------------------------
	case 'getDensity'
		%-----------------------------------------------------------------------------------------
		clear gd
		if isfield(rfd,'compared') && ~isempty(rfd.compared)
			gd = getDensity;
			gd.x = rfd.compared.cell1;
			gd.y = rfd.compared.cell2;
			txt = ['Variable_' num2str(rfd.xy{4})];
			gd.columnlabels = {regexprep(txt, '\.', '_')};
			gd.legendtxt = {'Cell 1', 'Cell 2'};
			gd.addjitter = 'both';
			gd.run;
		end		
		
		%-----------------------------------------------------------------------------------------
	case 'MetricSpace'
		%-----------------------------------------------------------------------------------------
		
		global X;
		rfd.msfinish = 0;
		X = [];
		family = get(gh('RFDMetricInterval'),'Value'); %metric space family 0=spike 1=interval
		startrun=str2num(get(gh('RFDStartRun'),'String'));
		endrun=str2num(get(gh('RFDEndRun'),'String'));
		
		if rfd.auto == 0
			hwait=waitbar(0,'Metric Space data loading');
			pos=get(hwait,'Position');
			set(hwait,'Position',[0 0 pos(3) pos(4)]);
		end
		opts.clustering_exponent = -2;
		opts.unoccupied_bins_strategy = 0;
		opts.metric_family = family;
		opts.parallel = 1;
		opts.possible_words = 'unique';
		%opts.tpmc_possible_words_strategy = 0;
		opts.shift_cost = [0 2.^(-2:10)];
		%opts.start_time = sv.mint/1000;
		%opts.end_time = sv.maxt/1000;
		margins = 0.05;
		
		if isempty(rfd.cell3)
			m=2;
		else
			m=3;
		end
		
		if length(rfd.xy)<4
			x=rfd.xy{3};
		else
			x=rfd.xy{4};
		end
		
		if rfd.cell1.numvars == 0
			x=1;
		else
			x=find(rfd.cell1.xvalues==x);
		end
		
		for i = 1:m
			data=rfd.(['cell' num2str(i)]);
			sv=rfd.cell1.sv;
			Xtmp=makemetric(data,sv,startrun,endrun);
			X.M = int32(i);
			X.N = Xtmp.N;
			X.sites = Xtmp.sites;
			X.categories(i)=Xtmp.categories(x);
			X.categories(i).label = {cell2mat([data.runname X.categories(i).label])};
		end
		
		opts.start_time = min([X.categories(1).trials(:).start_time]);
		opts.end_time = max([X.categories(1).trials(:).end_time]);
		
		if rfd.auto==0;waitbar(0.1,hwait,'Plotting Rasters');end
		clear out out_unshuf shuf out_unjk jk;
		clear info_plugin info_tpmc info_jack info_unshuf info_unjk;
		clear temp_info_shuf temp_info_jk;
		
		rfd.mshandle=figure;
		figpos(1,[],2);
		set(gcf,'name','Metric Space Analysis');
		
		subplot_tight(2,2,1,margins,'Parent',rfd.mshandle);
		staraster(X,[opts.start_time opts.end_time]);
		title('Raster plot');
		
		%%% Simple analysis
		if rfd.auto==0;drawnow;waitbar(0.2,hwait,'Performing Metric space measurement');end
		opts.entropy_estimation_method = {'plugin','tpmc','jack'};
		[out,opts_used] = metric(X,opts);
		
		for q_idx=1:length(opts.shift_cost)
			info_plugin(q_idx) = out(q_idx).table.information(1).value;
			info_tpmc(q_idx) = out(q_idx).table.information(2).value;
			info_jack(q_idx) = out(q_idx).table.information(3).value;
		end
		
		if rfd.auto==0;drawnow;waitbar(0.4,hwait,'Plotting matrix and Information');end
		
		subplot_tight(2,2,2,margins,'Parent',rfd.mshandle);
		%set(gca,'FontName','georgia','FontSize',11);
		[max_info,max_info_idx]=max(info_plugin);
		imagesc(out(max_info_idx).d);
		xlabel('Spike train index');
		ylabel('Spike train index');
		title('Distance matrix at maximum information');
		
		subplot_tight(2,2,3,margins,'Parent',rfd.mshandle);
		%set(gca,'FontName','georgia','FontSize',11);
		plot(1:length(opts.shift_cost),info_plugin);
		hold on;
		plot(1:length(opts.shift_cost),info_tpmc,'--');
		plot(1:length(opts.shift_cost),info_jack,'-.');
		hold off;
		set(gca,'xtick',1:length(opts.shift_cost));
		set(gca,'xticklabel',opts.shift_cost);
		set(gca,'xlim',[1 length(opts.shift_cost)]);
		set(gca,'ylim',[-0.5 max(info_plugin)+1]);
		xlabel('Temporal precision (1/sec)');
		ylabel('Information (bits)');
		legend('No correction','TPMC correction','Jackknife correction',...
			'location','best');
		
		if rfd.auto==0;drawnow;waitbar(0.5,hwait,'Performing Shuffle');end
		%%% Shuffling
		
		opts.entropy_estimation_method = {'plugin'};
		rand('state',0);
		S=10;
		[out_unshuf,shuf,opts_used] = metric_shuf(X,opts,S);
		shuf = shuf';
		for q_idx=1:length(opts.shift_cost)
			info_unshuf(q_idx)= out_unshuf(q_idx).table.information.value;
			for s=1:S
				temp_info_shuf(s,q_idx) = shuf(s,q_idx).table.information.value;
			end
		end
		info_shuf = mean(temp_info_shuf,1);
		info_shuf_std = std(temp_info_shuf,[],1);
		info_shuf_sem = sqrt((S-1)*var(temp_info_shuf,1,1));
		
		if rfd.auto==0;waitbar(0.7,hwait,'Performing JackKnife');end
		%%% leave-one-out Jackknife
		[out_unjk,jk,opts_used] = metric_jack(X,opts);
		if rfd.auto==0;waitbar(0.9,hwait,'Final Calculations');end
		P_total = size(jk,1);
		temp_info_jk = zeros(P_total,length(opts.shift_cost));
		for q_idx=1:length(opts.shift_cost)
			info_unjk(q_idx)= out_unjk(q_idx).table.information.value;
			for p=1:P_total
				temp_info_jk(p,q_idx) = jk(p,q_idx).table.information.value;
			end
		end
		info_jk_std = std(temp_info_jk,[],1);
		info_jk_sem = sqrt((P_total-1)*var(temp_info_jk,1,1));
		
		%%% Plot results
		
		subplot_tight(2,2,4,margins,'Parent',rfd.mshandle);
		%set(gca,'FontName','georgia','FontSize',11);
		errorbar(1:length(opts.shift_cost),info_unjk,info_jk_sem);
		hold on;
		errorbar(1:length(opts.shift_cost),info_shuf,2*info_shuf_std,'r');
		hold off;
		set(gca,'xtick',1:length(opts.shift_cost));
		set(gca,'xticklabel',opts.shift_cost);
		set(gca,'xlim',[1 length(opts.shift_cost)]);
		%set(gca,'ylim',[-0.5 3.5]);
		xlabel('Temporal precision (1/sec)');
		ylabel('Information (bits)');
		legend('Original data(Jackknife\pmSE)','Shuffled data(\pm2SD)');
		
		if family==0
			family='\fontname{georgia}\fontsize{12}D^{spike}';
		else
			family='\fontname{georgia}\fontsize{12}D^{interval}';
		end
		
		dataname=regexprep(data.matrixtitle,'\d\d\s\|',' \|');
		
		suplabel([family '\rightarrow' dataname '| Anal Trials: ' num2str(startrun) ':' num2str(endrun)],'t',[.01 .01 .96 .96]);
		if rfd.auto==0;close(hwait);end
		
		mout.X=X;
		mout.shift_cost=opts.shift_cost;
		mout.info_plugin=info_plugin;
		mout.info_tpmc=info_tpmc;
		mout.info_jack=info_jack;
		mout.info_unjk=info_unjk;
		mout.info_jk_sem=info_jk_sem;
		mout.info_shuf=info_shuf;
		mout.info_shuf_std=info_shuf_std;
		mout.title=data.matrixtitle;
		
		x=[opts.shift_cost;info_unjk;info_jk_sem;info_shuf;info_shuf_std];
		midx=find(x(2,:)==max(x(2,:)), 1, 'last' ); %max information value
		idx=[];
		for i=1:length(opts.shift_cost)
			unjk=x(2,i);
			if unjk>(x(4,i)+(x(5,i)*2))
				idx=[idx i];
			end
		end
		idx=max(idx);
		if isempty(idx) %nothing significantly over shuffle
			idx=1;
		end
		vals=[x(1,1) x(2,1) x(3,1) x(1,idx) x(2,idx) x(3,idx) x(1,midx) x(2,midx) x(3,midx)];
		rfd.msvalues = vals;
		clipboard('Copy',sprintf('%.3g\t',vals));
		rfd.msfinish = 1;
		
end %end of main switch

%-----------------------------------------------------------------------------------------
	function [h,p]=dostatstest(data,m,a)
		%-----------------------------------------------------------------------------------------
		test=get(gh('RFDStatsTest'),'Value');
		switch test
			case 1
				[h,p]=ttest(data,m,a);
			case 2
				[p,h]=signrank(data,m,'alpha',a);
			case 3
				[p,h]=signtest(data,m,'alpha',a);
		end
	end

end
