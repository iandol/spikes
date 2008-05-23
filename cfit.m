function cfit(action)

global cdata
global data

if nargin<1,
   action='Initialize';
end

%%%%%%%%%%%%%%See what VSPlot needs to do%%%%%%%%%%%%%
switch(action)
   
   %%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%   
case 'Initialize'   
   cdata=[];
   cfitfig
   set(gh('CurveType'),'String',{'Control';'Drug 1';'Drug 2';'Recovery'});
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   t=strvcat('Control','Drug 1','Drug 2','Recovery');
   set(gh('Curve1Menu'),'String',t);
   set(gh('Curve2Menu'),'String',t); 
   cdata.init=1;
   cdata.type=[];
   cdata.control=0;
   cdata.anal='';
   cdata.drug1=0;
   cdata.drug2=0;
   cdata.recovery=0;
   
   
case 'Load'   
   cdata.curve1=[];
   cdata.curve2=[];
   cdata.curve1err=[];
   cdata.curve2err=[];
   cdata.curveax=[];
   
   if isempty(data)
      errordlg('Sorry, cant find Spikes Data file...')
      break;
   end   
       
   cdata.type=get(gh('CurveType'),'Value');
   if cdata.type==1
      cdata.control=1; 
      cdata.xvalues=data.xvalues;
      if data.numvars==1
         cdata.yvalues=1
         set(gh('HoldValue'),'Enable','off');
         set(gh('YMenu'),'Enable','off');
         set(gh('XMenu'),'Enable','off');
      else         
         cdata.yvalues=data.yvalues;
         set(gh('HoldValue'),'Enable','on');
         set(gh('YMenu'),'Enable','on');
         set(gh('XMenu'),'Enable','on');
      end   
      set(findobj('Tag','cradio'),'Value',1)
   elseif cdata.type==2
      cdata.drug1=1;
      if data.xvalues~=cdata.xvalues
         errordlg('Sorry, data has different variables to control')
         break
      end
      set(findobj('Tag','d1radio'),'Value',1)
   elseif cdata.type==3
      cdata.drug2=1;
      if data.xvalues~=cdata.xvalues
         errordlg('Sorry, data has different variables to control')
         break
      end
      set(findobj('Tag','d2radio'),'Value',1)
   elseif cdata.type==4
      cdata.recovery=1;
      if data.xvalues~=cdata.xvalues
         errordlg('Sorry, data has different variables to control')
         break
     end
     set(findobj('Tag','rradio'),'Value',1)
 end
 
 if get(gh('CFNormalizeBox'),'Value')==1
     
     for i=1:data.yrange
         if  data.plotburst==0 &  data.plottonic==0
             data.errormat(i,:) =  data.errormat(i,:) ./ max(data.matrix(i,:));
             data.matrix(i,:) =  data.matrix(i,:) ./ max(data.matrix(i,:));
             
         elseif data.plotburst==1
             data.errormat(i,:) =  data.errormat(i,:) ./ max(data.bmatrix(i,:));
             data.bmatrix(i,:) =  data.bmatrix(i,:) ./ max(data.bmatrix(i,:));
             
         elseif data.plottonic==1
             data.errormat(i,:) =  data.errormat(i,:) ./ max(data.tmatrix(i,:));
             data.tmatrix(i,:) =  data.tmatrix(i,:) ./ max(data.tmatrix(i,:));        
         end
     end
 end
 
 if data.plotburst==0 &  data.plottonic==0
     cdata.anal='mean';
     cdata.matrix{cdata.type}=data.matrix;
     cdata.error{cdata.type}=data.errormat;
 elseif data.plotburst==1
     cdata.anal='burst';
     cdata.matrix{cdata.type}=data.bmatrix;
     cdata.error{cdata.type}=data.errormat;
 elseif data.plottonic==1
     cdata.anal='tonic';
     cdata.matrix{cdata.type}=data.tmatrix;
     cdata.error{cdata.type}=data.errormat;
 end
 
 cdata.title{cdata.type}=data.matrixtitle;
 
 set(gh('XMenu'),'String',num2str(cdata.xvalues'));
 set(gh('YMenu'),'String',num2str(cdata.yvalues'));
 
case 'Plot'
    cla
   x=get(gh('HoldValue'),'Value');
   if x==1
      cdata.held=get(gh('XMenu'),'Value');
      cdata.dim=1;
   elseif x==2
      cdata.held=get(gh('YMenu'),'Value');
      cdata.dim=2;
   end
   
   x=get(gh('Curve1Menu'),'Value')
   y=get(gh('Curve1Menu'),'String')
   l{1}=y(x,:)
   if cdata.dim==1
      cdata.curve1=cdata.matrix{x}(1:end,cdata.held);
      cdata.curve1err=cdata.error{x}(1:end,cdata.held);
      cdata.curveax=cdata.yvalues;
   elseif cdata.dim==2
      cdata.curve1=cdata.matrix{x}(cdata.held,1:end);
      cdata.curve1err=cdata.error{x}(cdata.held,1:end);
      cdata.curveax=cdata.xvalues;
   end
   
   x=get(gh('Curve2Menu'),'Value')
   y=get(gh('Curve2Menu'),'String')
   l{2}=y(x,:)
   if cdata.dim==1
      cdata.curve2=cdata.matrix{x}(1:end,cdata.held);
      cdata.curve2err=cdata.error{x}(1:end,cdata.held);
      cdata.curveax=cdata.yvalues;
   elseif cdata.dim==2
      cdata.curve2=cdata.matrix{x}(cdata.held,1:end);
      cdata.curve2err=cdata.error{x}(cdata.held,1:end);
      cdata.curveax=cdata.xvalues;
   end
   
   hold on  
   areabar(cdata.curveax,cdata.curve1,cdata.curve1err,[.85 .85 .85],'Color',[0 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[0 0 0])
   areabar(cdata.curveax,cdata.curve2,cdata.curve2err,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0])
   hold on
   plot(cdata.curveax,cdata.curve1,'Color',[0 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[0 0 0]);
   hold on
   plot(cdata.curveax,cdata.curve2,'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0]);
   hold off
   legend(l{1},l{2},0)
   
   statcurve=cdata.curve1-cdata.curve1err;     
   s=goodness(cdata.curve1,statcurve);
   x=goodness(cdata.curve1,cdata.curve2);
   
   title(['Goodness of Fit = ' num2str(x) '% (' num2str(s) '% significant)']);
   
   r=cdata.curve1-cdata.curve2;
   
   figure
   box on
   hold on  
   areabar(cdata.curveax,cdata.curve1,cdata.curve1err,[.85 .85 .85],'Color',[0 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[0 0 0])
   areabar(cdata.curveax,cdata.curve2,cdata.curve2err,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0])
   hold on
   plot(cdata.curveax,cdata.curve1,'Color',[0 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[0 0 0]);
   hold on
   plot(cdata.curveax,cdata.curve2,'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0]);
   legend(l{1},l{2},0)
   hold off
   if cdata.control==1
      a=find(cdata.title{1}=='/');
      t=cdata.title{1}(1:a(2)-1);
   end
   if cdata.drug1==1
      a=find(cdata.title{2}=='/');
      t=[t ' | ' cdata.title{2}(a(2)-4:a(2)-1)];
   end
   if cdata.drug2==1
      a=find(cdata.title{3}=='/');
      t=[t ' | ' cdata.title{3}(a(2)-4:a(2)-1)];
   end   
   if cdata.recovery==1
      a=find(cdata.title{4}=='/');
      t=[t ' | ' cdata.title{4}(a(2)-4:a(2)-1)];
   end
   a=find(cdata.title{1}=='[');
   t=[t ' ' cdata.title{1}(a:end)];
   if cdata.yvalues>1
      String=get(gh('YMenu'),'String');
      Value=get(gh('YMenu'),'Value');
      t=[t ' {Y Variable = ' String(Value,:) '}'];
   end
   title(t)
   
   cfitaxisfig
   
   axes(gh('CurveAxis'))
   hold on  
   areabar(cdata.curveax,cdata.curve1,cdata.curve1err,[.85 .85 .85],'Color',[0 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[0 0 0])
   areabar(cdata.curveax,cdata.curve2,cdata.curve2err,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0])
   hold on
   plot(cdata.curveax,cdata.curve1,'Color',[0 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[0 0 0]);
   hold on
   plot(cdata.curveax,cdata.curve2,'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0]);
   legend(l{1},l{2},0)
   hold off   
      
   statcurve=cdata.curve1-cdata.curve1err;     
   s=goodness(cdata.curve1,statcurve);
   x=goodness(cdata.curve1,cdata.curve2);
   
   title(['Goodness of Fit = ' num2str(x) '% (' num2str(s) '% significant)']);
   ylabel('Firing Rate') 
   
   axes(gh('RAxis'))   
   area(cdata.curveax,r,'FaceColor',[0.5 0 0])
   axis tight
   ylabel('Residuals')
   set(gh('CurveAxis'),'Tag','')
   set(gh('RAxis'),'Tag','')
   
   figure
   a1=cdata.curve1-cdata.curve2;
   a2=cdata.curve1-statcurve;
   hold on
   plot(cdata.curveax,a1,'ko-','MarkerFaceColor',[0 0 0]);
   hold on
   plot(cdata.curveax,a2,'ro-','MarkerFaceColor',[1 0 0]);
   hold off
   legend('Curve Residuals','Stats Residuals',0)
   ylabel('Residuals (curve-curve or curve-stats curve)')
   title('A plot of Residuals between Curves and Error Values')
   legend(l{1},l{2},0)
   
   
case 'Tuning Curves'
   x=get(gh('HoldValue'),'Value');
   if x==1
      cdata.held=get(gh('XMenu'),'Value');
      cdata.dim=1;
   elseif x==2
      cdata.held=get(gh('YMenu'),'Value');
      cdata.dim=2;
   end
   tage=1;
   if cdata.control==1 & (cdata.drug1==1|cdata.drug2==1) & cdata.recovery==1
      if cdata.dim==1
         cua=cdata.matrix{1}(1:end,cdata.held);
         cuaerr=cdata.error{1}(1:end,cdata.held);
         a=find(cdata.title{1}=='/');
         t=cdata.title{1}(1:a(2)-1);
         cax=cdata.yvalues;
         if cdata.drug1==1
            tage=2;
            cub=cdata.matrix{2}(1:end,cdata.held);
            cuberr=cdata.error{2}(1:end,cdata.held);
            a=find(cdata.title{2}=='/');
            t=[t '|' cdata.title{2}(a(2)-4:a(2)-1)];         
         end
         if cdata.drug2==1
            if tage==2
               tage=4;
               cuc=cdata.matrix{3}(1:end,cdata.held);
               cucerr=cdata.error{3}(1:end,cdata.held);
               a=find(cdata.title{3}=='/');
               t=[t '|' cdata.title{3}(a(2)-4:a(2)-1)];
            else
               tage=3
               cub=cdata.matrix{3}(1:end,cdata.held);
               cuberr=cdata.error{3}(1:end,cdata.held);
               a=find(cdata.title{3}=='/');
               t=[t '|' cdata.title{3}(a(2)-4:a(2)-1)];
            end
         end
         if cdata.recovery==1
            if tage==2
               cuc=cdata.matrix{4}(1:end,cdata.held);
               cucerr=cdata.error{4}(1:end,cdata.held);
               a=find(cdata.title{4}=='/');
               t=[t '|' cdata.title{4}(a(2)-4:a(2)-1)];
            elseif tage==3
               cud=cdata.matrix{4}(1:end,cdata.held);
               cuderr=cdata.error{4}(1:end,cdata.held);
               a=find(cdata.title{4}=='/');
               t=[t '|' cdata.title{4}(a(2)-4:a(2)-1)];
            end                     
         end
      elseif cdata.dim==2
         cua=cdata.matrix{1}(cdata.held,1:end);
         cuaerr=cdata.error{1}(cdata.held,1:end);
         cax=cdata.xvalues;
         a=find(cdata.title{1}=='/');
         t=cdata.title{1}(1:a(2)-1);
         if cdata.drug1==1
            tage=2;
            cub=cdata.matrix{2}(cdata.held,1:end);
            cuberr=cdata.error{2}(cdata.held,1:end);
         	a=find(cdata.title{2}=='/');
            t=[t '|' cdata.title{2}(a(2)-4:a(2)-1)]; 
         end
         if cdata.drug2==1
            if tage==2
               tage=4;
               cuc=cdata.matrix{3}(cdata.held,1:end);
               cucerr=cdata.error{3}(cdata.held,1:end);
               a=find(cdata.title{3}=='/');
               t=[t '|' cdata.title{3}(a(2)-4:a(2)-1)];
            else
               tage=3
               cub=cdata.matrix{3}(cdata.held,1:end);
               cuberr=cdata.error{3}(cdata.held,1:end);
               a=find(cdata.title{3}=='/');
               t=[t '|' cdata.title{3}(a(2)-4:a(2)-1)];
            end
         end
         if cdata.recovery==1
            if tage==2 | tage==3
               cuc=cdata.matrix{4}(cdata.held,1:end);
               cucerr=cdata.error{4}(cdata.held,1:end);
               a=find(cdata.title{4}=='/');
               t=[t '|' cdata.title{4}(a(2)-4:a(2)-1)];
            elseif tage==4
               cud=cdata.matrix{4}(cdata.held,1:end);
               cuderr=cdata.error{4}(cdata.held,1:end);
               a=find(cdata.title{4}=='/');
               t=[t '|' cdata.title{4}(a(2)-4:a(2)-1)];
            end                     
         end
      end
   end
   
   a=find(cdata.title{1}=='[');
   t=[t ' ' cdata.title{1}(a:end)];
   if cdata.yvalues>1
      String=get(gh('YMenu'),'String');
      Value=get(gh('YMenu'),'Value');
      t=[t ' {Y Variable = ' String(Value,:) '}'];
   end
   
   if get(gh('PropAxis'),'Value')==0
      cax=1:length(cua);   
   end
   
   figure   
   box on   
   if get(gh('AreaSelect'),'Value')==0;
      if tage==2
         hold on
         errorbar(cax,cua,cuaerr,'k-')
         hold on
         plot(cax,cua,'ks','MarkerSize',8,'MarkerFaceColor',[0 0 0])
         errorbar(cax,cuc,cucerr,'b-')
         hold on
         plot(cax,cuc,'bs','MarkerSize',6,'MarkerFaceColor',[0 0 1])
         errorbar(cax,cub,cuberr,'r-')
         hold on
         plot(cax,cub,'ro','MarkerSize',7,'MarkerFaceColor',[1 0 0])      
         hold off
      elseif tage==3
         hold on
         errorbar(cax,cua,cuaerr,'k-')
         hold on
         plot(cax,cua,'ks','MarkerSize',7,'MarkerFaceColor',[0 0 0])
         errorbar(cax,cuc,cucerr,'b-')
         hold on
         plot(cax,cuc,'bs','MarkerSize',6,'MarkerFaceColor',[0 0 1])
         errorbar(cax,cub,cuberr,'r-')
         hold on
         plot(cax,cub,'ro','MarkerSize',7,'MarkerFaceColor',[1 0 0])      
         hold off
      elseif tage==4
         hold on
         errorbar(cax,cua,cuaerr,'k-')
         hold on
         plot(cax,cua,'ks','MarkerSize',7,'MarkerFaceColor',[0 0 0])
         errorbar(cax,cud,cuderr,'b-')
         hold on
         plot(cax,cud,'bs','MarkerSize',6,'MarkerFaceColor',[0 0 1])
         errorbar(cax,cub,cuberr,'r-')
         hold on
         plot(cax,cub,'ro','MarkerSize',7,'MarkerFaceColor',[1 0 0])
         errorbar(cax,cuc,cucerr,'r-')
         hold on
         plot(cax,cuc,'ro','MarkerSize',6,'MarkerFaceColor',[1 1 1])      
         hold off
      end
   else
      if tage==2
         hold on
         areabar(cax,cua,cuaerr,[.85 .85 .85],'Color',[0 0 0],'Marker','s','MarkerSize',8,'MarkerFaceColor',[0 0 0])
         areabar(cax,cuc,cucerr,[.8 .8 .9],'Color',[0 0 .8],'Marker','o','MarkerSize',7,'MarkerFaceColor',[0 0 0.8])
         areabar(cax,cub,cuberr,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0])
         hold on
         plot(cax,cua,'ks-','MarkerSize',8,'MarkerFaceColor',[0 0 0])
         hold on
         plot(cax,cuc,'bo-','MarkerSize',7,'MarkerFaceColor',[0 0 1])
         hold on
         plot(cax,cub,'ro-','MarkerSize',6,'MarkerFaceColor',[1 0 0]) 
         legend('All spikes','Tonic','Burst',0)
         hold off
      elseif tage==3
         hold on
         areabar(cax,cua,cuaerr,[.85 .85 .85],'Color',[0 0 0],'Marker','s','MarkerSize',8,'MarkerFaceColor',[0 0 0])
         areabar(cax,cuc,cucerr,[.8 .8 .9],'Color',[0 0 .8],'Marker','o','MarkerSize',7,'MarkerFaceColor',[0 0 0.8])
         areabar(cax,cub,cuberr,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0])
         hold on
         plot(cax,cua,'ks-','MarkerSize',8,'MarkerFaceColor',[0 0 0])
         hold on
         plot(cax,cuc,'bo-','MarkerSize',7,'MarkerFaceColor',[0 0 1])
         hold on
         plot(cax,cub,'ro-','MarkerSize',6,'MarkerFaceColor',[1 0 0]) 
         legend('Control','Recoveryt','Drug1',0)
         hold off
      elseif tage==4
         hold on
         areabar(cax,cua,cuaerr,[.85 .85 .85],'Color',[0 0 0],'Marker','s','MarkerSize',9,'MarkerFaceColor',[0 0 0])
         areabar(cax,cud,cuderr,[.8 .8 .9],'Color',[0 0 .8],'Marker','o','MarkerSize',7.5,'MarkerFaceColor',[0 0 0.8])
         areabar(cax,cub,cuberr,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 0 0])
         areabar(cax,cuc,cucerr,[.9 .8 .8],'Color',[1 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[1 1 1])
         hold on
         plot(cax,cua,'ks-','MarkerSize',9,'MarkerFaceColor',[0 0 0])
         hold on
         plot(cax,cud,'bo-','MarkerSize',7.5,'MarkerFaceColor',[0 0 1])
         hold on
         plot(cax,cub,'ro-','MarkerSize',6,'MarkerFaceColor',[1 0 0])
         hold on
         plot(cax,cuc,'ro-','MarkerSize',6,'MarkerFaceColor',[1 1 1]) 
         legend('Control','Recovery','Drug 1','Drug 2',0)
         hold off
      end
   end
   
   
   if get(gh('PropAxis'),'Value')==0
      set(gca,'XTick',cax);
      set(gca,'XTickLabel',cdata.xvalues);   
   end
   
   title(t)
   ylabel('Firing Rate')
   xlabel('Diameter (deg)')
   
   a=find(t=='|' | t=='/' | t=='{' | t=='}' |  t==' ');
   t(a)='';
   
   tt=t(1:find(t=='[')-1);
   ttt=t(find(t=='=')+1:end);
   
   t=[tt 'lum is ' ttt];
   
   fname{1}=['D:\txt\' t ' Control.txt'];
   fname{2}=['D:\txt\' t ' Drug1.txt'];
   fname{3}=['D:\txt\' t ' Drug2.txt'];
   fname{4}=['D:\txt\' t ' Recovery.txt'];
   fname{5}=['D:\txt\' t ' Controlerr.txt'];
   fname{6}=['D:\txt\' t ' Drug1err.txt'];
   fname{7}=['D:\txt\' t ' Drug2err.txt'];
   fname{8}=['D:\txt\' t ' Recoveryerr.txt'];
       
   
   for i=1:4
       x=fname{i};
       d=cdata.matrix{i}';      
       xx=['save ''' x ''' d -ascii'];
       eval(xx) ;      
   end
   
   q(5:8)=1:4;
   for i=5:8
        x=fname{i};
       d=cdata.error{q(i)}';      
       xx=['save ''' x ''' d -ascii'];
       eval(xx);
   end
   
   
   
case 'Load Mat'
   cfit('Reset')
   [lfile,lpath] = uigetfile('*.mat','Curve Fit: Load Matrix');    
   if ~lfile
      errordlg('No File Specified')   
   else      
      cd (lpath)
      load(lfile)
      set(gh('XMenu'),'String',num2str(cdata.xvalues'));
      set(gh('YMenu'),'String',num2str(cdata.yvalues'));      
      if cdata.yvalues==1
         set(gh('HoldValue'),'Enable','off');
         set(gh('YMenu'),'Enable','off');
         set(gh('XMenu'),'Enable','off');
      else         
         set(gh('HoldValue'),'Enable','on');
         set(gh('YMenu'),'Enable','on');
         set(gh('XMenu'),'Enable','on');
      end   
      if cdata.control==1
         set(gh('cradio'),'Value',1)
      end
      if cdata.drug1==1
         set(gh('d1radio'),'Value',1)
      end
      if cdata.drug2==1
         set(gh('d2radio'),'Value',1)
      end
      if cdata.recovery==1
         set(gh('rradio'),'Value',1)
      end      
   end
   
case 'Save Mat'   
   [f,path] = uiputfile('*.mat','Curve Fit: Save Matrix')    
   if ~f
      errordlg('No File Specified')
   else      
      curr=pwd
      cd(path)            
      save(f,'cdata')
      cd(curr)
   end
   
   
case 'Reset'
   cdata=[];
   cla reset
   box on
   set(gh('XMenu'),'String',' ');
   set(gh('YMenu'),'String',' ');
   set(gh('CurveType'),'String',{'Control';'Drug 1';'Drug 2';'Recovery'});
   set(gh('CurveType'),'Value',1);
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   t=strvcat('Control','Drug 1','Drug 2','Recovery');
   set(gh('Curve1Menu'),'String',t);
   set(gh('Curve1Menu'),'Value',1);
   set(gh('Curve2Menu'),'String',t); 
   set(gh('Curve2Menu'),'Value',1);
   cdata.type=[];
   cdata.control=0;
   cdata.drug1=0;
   cdata.drug2=0;
   cdata.recovery=0;
   set(gh('cradio'),'Value',0)
   set(gh('d1radio'),'Value',0)
   set(gh('d2radio'),'Value',0)
   set(gh('rradio'),'Value',0)
     
   
case 'Exit'
   close(gcf)
   
   
   
end


%GH Gets Handle From Tag
function [handle] = gh(tag)
handle=findobj('Tag',tag);
%End of handle getting routine
