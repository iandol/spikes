function cufit(action)

global cdata
global data

if nargin<1,
   action='Initialize';
end

%%%%%%%%%%%%%%See what VSPlot needs to do%%%%%%%%%%%%%
switch(action)
   
   %%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%   
case 'Initialize'   
	
	version=['Tuning Curve | Started - ',datestr(now)];
	cufitfig;  			%our GUI file
	set(gcf,'Name', version);
    cdata=[];
   
if get(gh('BurstTonicBox'),'Value')==0 & get(gh('Beebox'),'Value')==0

   set(gh('CurveType'),'String',{'Control';'Drug 1';'Drug 2';'Recovery'});
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   set(gh('PlotType'),'String',{'Raw Data';'Contour'});
   t=strvcat('Control','Drug 1','Drug 2','Recovery');
elseif get(gh('Beebox'),'Value')==1 
   
   set(gh('CurveType'),'String',{'Mono';'Red';'Green';'Blue';'Yellow'});
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   t=strvcat('Mono','Red','Green','Blue','Yellow');
      
elseif get(gh('BurstTonicBox'),'Value')==1 

   set(gh('CurveType'),'String',{'All Spikes';'Burst';'Temp';'Tonic'});
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   t=strvcat('All Spikes','Burst ','Temp','Tonic');
   

end
   set(gh('Curve1Menu'),'String',t);
   set(gh('Curve2Menu'),'String',t); 
   cdata.init=1;
   cdata.type=[];
   cdata.control=0;
   cdata.anal='';
   cdata.drug1=0;
   cdata.drug2=0;
   cdata.recovery=0;
   cdata.data5=0;
   

   
case 'Load'   
   cdata.curve1=[];
   cdata.curve2=[];
   cdata.curve1err=[];
   cdata.curve2err=[];
   cdata.curveax=[];
   
   if isempty(data)
      errordlg('Sorry, cant find Spikes Data file...')
     return;
   end   
       
   cdata.type=get(gh('CurveType'),'Value');
   if cdata.type==1
      cdata.control=1; 
      cdata.xvalues=data.xvalues;
      if data.numvars==1
         cdata.yvalues=1
         set(gh('HoldValue'),'Enable','off');
         set(gh('YMenu'),'Enable','off');
         set(gh('XMenu'),'Enable','on');
      else         
         cdata.yvalues=data.yvalues;
         set(gh('HoldValue'),'Enable','on');
         set(gh('YMenu'),'Enable','on');
         set(gh('XMenu'),'Enable','on');
      end   
      set(findobj('Tag','d1radio'),'Value',1)
	  	 	  
   elseif cdata.type==2
      cdata.drug1=1;
      if data.xvalues~=cdata.xvalues
        
		 errordlg('Sorry, data has different variables to control')
	 end
      set(findobj('Tag','d2radio'),'Value',1)
	  	  	  
   elseif cdata.type==3
      cdata.drug2=1;
      if data.xvalues~=cdata.xvalues
		  
         errordlg('Sorry, data has different variables to control')
	 end
      set(findobj('Tag','d3radio'),'Value',1)
  elseif cdata.type==4
	  cdata.recovery=1;
	  if data.xvalues~=cdata.xvalues
		  
		  errordlg('Sorry, data has different variables to control')
	  end
	  set(findobj('Tag','d4radio'),'Value',1)
	  	 	  
  elseif cdata.type==5
	  cdata.data5=1;
	  if data.xvalues~=cdata.xvalues
		  
		  errordlg('Sorry, data has different variables to control')
	  end
	  set(findobj('Tag','d5radio'),'Value',1)
	 
 end
 
 
  
 if get(gh('CFNormalizeBox'),'Value')==1& get(gh('Beebox'),'Value')==0

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


 
 
 
 colour.error=[];
 colour.matrix=[];
 intensity.error=[];
 intensity.matrix=[];
case 'Bee plot'
		
	if get(gh('CFNormalizeBox'),'Value')==1 & get(gh('Beebox'),'Value')==1
		for i=1:cdata.type
			colour.error{i}=cdata.error{i};
			colour.error{i}(1) =  0; %cdata.error{i} - cdata.error{i}(1);
			colour.matrix{i} =  cdata.matrix{i} -cdata.matrix{i}(1);
			
		end
	else %if get(gh('Beebox'),'Value')==1 & get(gh('CFNormalizeBox'),'Value')==0
		for i=1:cdata.type
			colour.error{i} =  cdata.error{i};
			colour.matrix{i} =  cdata.matrix{i} ;
		end
	end
	
	
	
	figure
	
	hold on
	plot(cdata.xvalues, colour.matrix{1},'ks-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 0 0])
	hold on
	plot(cdata.xvalues, colour.matrix{2},'rs-','linewidth',[3],'MarkerSize',7,'MarkerFaceColor',[1 0 0])
	hold on
	plot(cdata.xvalues, colour.matrix{3},'go-','linewidth',[3],'MarkerSize',6,'MarkerFaceColor',[0 1 0]) 
	hold on
	plot(cdata.xvalues, colour.matrix{4},'bo-','linewidth',[3],'MarkerSize',6,'MarkerFaceColor',[0 0 1]) 
	hold on
	plot(cdata.xvalues, colour.matrix{5},'yo-','linewidth',[3],'MarkerSize',6,'MarkerFaceColor',[1 1 0]) 
	
	T=get(gh('CurveType'),'String');
	legend('Mono','Red','Green','Blue','Yellow',0);
	
	hold on
	errorbar(cdata.xvalues, colour.matrix{1}, colour.error{1},'k-')
	hold on
	errorbar(cdata.xvalues, colour.matrix{2}, colour.error{2},'r-')
	hold on
	errorbar(cdata.xvalues, colour.matrix{3}, colour.error{3},'g-')
	hold on
	errorbar(cdata.xvalues, colour.matrix{4}, colour.error{4},'b-')
	hold on
	errorbar(cdata.xvalues, colour.matrix{5}, colour.error{5},'y-')
	
	T=get(gh('CurveType'),'String');
	legend('Mono','Red','Green','Blue','Yellow',0);
	
	t=cdata.title;
	t=[t{1}(1:7),t{1}(12:13),'/',t{2}(12:13),'/',t{3}(12:13),'/',t{4}(12:13),'/',t{5}(12:end)];
	title(t);
	ylabel('Firing Rate')
	xlabel('Colour Intensity')
	
	hold off


	for i=1:cdata.type
		intensity.error{i}=colour.error{i};
		intensity.matrix{i}=colour.matrix{i};
	end
	
	
    ii=get(gh('XMenu'), 'Value');
	c=cdata.xvalues(ii);
	c=num2str(c);
			
	figure
	
	hold on
	bar(1,colour.matrix{1}(ii), 'k-')
	hold on
	bar(2,colour.matrix{4}(ii), 'b-')
	hold on
	bar(3,colour.matrix{3}(ii), 'g-')
	hold on
	bar(4,colour.matrix{5}(ii), 'y-')
	hold on
	bar(5,colour.matrix{2}(ii), 'r-')

	%legend('Mono','Blue','Green','Yellow','Red',0);
	hold on
	errorbar(1, colour.matrix{1}(ii), colour.error{1}(ii),'k-')
	hold on
	errorbar( 2,colour.matrix{4}(ii), colour.error{4}(ii),'b-')
	hold on
	errorbar(3,colour.matrix{3}(ii), colour.error{3}(ii),'g-')
	hold on
	errorbar(4,colour.matrix{5}(ii), colour.error{5}(ii),'y-')
	hold on
	errorbar(5,colour.matrix{2}(ii), colour.error{2}(ii),'r-')
	
	t=cdata.title;
	t=[t{1}(1:6),t{1}(12:13),'/',t{2}(12:13),'/',t{3}(12:13),'/',t{4}(12:13),'/',t{5}(12:end),'--', 'Intensity:',c];
	title(t);
	ylabel('Firing Rate (s/s)')
	xlabel('Colour ')
	xx=1:cdata.type;
	set(gca,'XTick',xx);
	set(gca,'XTickLabel',{'Mono','Blue','Green','Yellow','Red'});   
		
	
 curve1.error=[];
 curve2.matrix=[];
case '2ColourPlot'
	
		if get(gh('CFNormalizeBox'),'Value')==1 & get(gh('Beebox'),'Value')==1
		for i=1:cdata.type
			colour.error{i}=cdata.error{i};
			colour.error{i}(1) =  0; %cdata.error{i} - cdata.error{i}(1);
			colour.matrix{i} =  cdata.matrix{i} -cdata.matrix{i}(1);
			
		end
	else %if get(gh('Beebox'),'Value')==1 & get(gh('CFNormalizeBox'),'Value')==0
		for i=1:cdata.type
			colour.error{i} =  cdata.error{i};
			colour.matrix{i} =  cdata.matrix{i} ;
		end
	end
	
	x=get(gh('Curve1Menu'),'Value');
	y=get(gh('Curve2Menu'),'Value');
	T={'Mono';'Red';'Green';'Blue';'Yellow'};
	T1=T(x);
	T2=T(y);
	S=[T1 T2];
	
	curve1.error = colour.error{x};
	curve2.error = colour.error{y};
	curve1.matrix = colour.matrix{x};
	curve2.matrix  = colour.matrix{y};
	
	figure
	
	hold on
	if x==1
		plot(cdata.xvalues, curve1.matrix,'ks-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 0 0])
	elseif x==2
		plot(cdata.xvalues, curve1.matrix,'rs-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[1 0 0])
	elseif x==3
		plot(cdata.xvalues, curve1.matrix,'gs-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 1 0])
	elseif x==4
		plot(cdata.xvalues, curve1.matrix,'bs-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 0 1])
	else x==5
		plot(cdata.xvalues, curve1.matrix,'ys-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[1 1 0])
	end
	
	hold on
		if y==1
		plot(cdata.xvalues, curve2.matrix,'ks-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 0 0])
	elseif y==2
		plot(cdata.xvalues, curve2.matrix,'rs-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[1 0 0])
	elseif y==3
		plot(cdata.xvalues, curve2.matrix,'gs-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 1 0])
	elseif y==4
		plot(cdata.xvalues, curve2.matrix,'bs-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[0 0 1])
	else y==5
		plot(cdata.xvalues, curve2.matrix,'ys-','linewidth',[3],'MarkerSize',8,'MarkerFaceColor',[1 1 0])
	end
	
	legend(S,0);
	
	hold on
	if x==1
		errorbar(cdata.xvalues, curve1.matrix, curve1.error,'k-')
	elseif x==2
		errorbar(cdata.xvalues, curve1.matrix, curve1.error,'r-')
	elseif x==3
		errorbar(cdata.xvalues, curve1.matrix, curve1.error,'g-')
	elseif x==4
		errorbar(cdata.xvalues, curve1.matrix, curve1.error,'b-')
	else x==5
		errorbar(cdata.xvalues, curve1.matrix, curve1.error,'y-')
	end
	
	hold on
		if y==1
		errorbar(cdata.xvalues, curve2.matrix, curve2.error,'k-')
	elseif y==2
		errorbar(cdata.xvalues, curve2.matrix, curve2.error,'r-')
	elseif y==3
		errorbar(cdata.xvalues, curve2.matrix, curve2.error,'g-')
	elseif y==4
		errorbar(cdata.xvalues, curve2.matrix, curve2.error,'b-')
	else y==5
		errorbar(cdata.xvalues, curve2.matrix, curve2.error,'y-')
	end
		
	legend(S,0);

	t=cdata.title;
	t=[t{x}(1:7),t{1}(12:13),'/',t{y}(12:end)];
	title(t);
	ylabel('Firing Rate')
	xlabel('Colour Intensity')
	
	hold off	
	
		
case 'qplot'

if data.numvars==1 
	if get(gh('CFNormalizeBox'),'Value')==1
	    x=get(gh('Curve1Menu'),'Value');
        T=get(gh('Curve1Menu'),'String');
        T=T(x,:);
        a=cdata.matrix{x};
        aerr=cdata.error{x};
		w=cdata.xvalues;
	elseif  get(gh('CFNormalizeBox'),'Value')==0
    
        errordlg('Sorry, has to normalize the data first')
    end

if w(1)==0
    s=a(1);
    a=a-s;
else
    errordlg('sorry, no 0 diameter, please calculate manually')
    s=0;
end

[m,i]=max(a);
a=a./max(a);
d=w(i);
figure;
areabar(w, a, aerr,[.9 .8 .8],'Color',[1 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[1 0 0])
t=cdata.title{x};
title(t);
ylabel('Normalized Firing Rate');
xlabel('Diameter');
legend(T,0)

[xx,b]=ginput(2);
b=mean(b);
b=100-b*100;
o=[s,d,b]; %spontaneous - diameter - percent suppression

 t1=['Spontaneous: ' sprintf('%0.5f',s)];
 t2=['Optimal Diameter: ' sprintf('%0.5g',d)];
 t3=['Surround Suppression: ' sprintf('%0.5f',b)];
 tt={t1,t2,t3};
 gtext (tt);
 %gtext(num2str(o))
s=[sprintf('%s\t',t),sprintf('%0.6g\t',o)];
clipboard('Copy',s);

else data.numvars==2 % Two Variable Condition
	if get(gh('CFNormalizeBox'),'Value')==1 
	   y=get(gh('YMenu'),'Value');
	   YY=cdata.yvalues(y);
		x=get(gh('Curve1Menu'),'Value');
        T=get(gh('Curve1Menu'),'String');
        T=T(x,:);
        a=cdata.matrix{x};
		a=a(y,:);
        aerr=cdata.error{x};
		aerr=aerr(y,:);
		w=cdata.xvalues;
	elseif get(gh('CFNormalizeBox'),'Value')==0
       
        errordlg('Sorry, has to normalize the data first')
    end	

if w(1)==0
    s=a(1);
    a=a-s;
else
    errordlg('sorry, no 0 diameter, please calculate manually')
    s=0;
end

[m,i]=max(a);
a=a./max(a);
d=w(i);
figure;
areabar(w, a, aerr,[.9 .8 .8],'Color',[1 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[1 0 0])
t=cdata.title{x};
yt=['----' data.ytitle ' ' sprintf('%0.5g',YY)];
t=[t yt];
title(t);
ylabel('Normalized Firing Rate');
xlabel('Diameter');
legend(T,0)

[xx,b]=ginput(2);
b=mean(b);
b=100-b*100;
o=[s,d,b]; %spontaneous - diameter - percent suppression

 t1=['Spontaneous: ' sprintf('%0.5f',s)];
 t2=['Optimal Diameter: ' sprintf('%0.5g',d)];
 t3=['Surround Suppression: ' sprintf('%0.5f',b)];
 tt={t1,t2,t3};
 gtext (tt);
  %gtext(num2str(o))
s=[sprintf('%s\t',t),sprintf('%0.6g\t',o)];
clipboard('Copy',s);
end

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
   
   cufitaxisfig
   
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
   
case 'T-Test'
		
if data.numvars==1 
    if  get(gh('CFNormalizeBox'),'Value')==1
        x=get(gh('Curve1Menu'),'Value');
        xx=get(gh('Curve1Menu'),'String');
        xx=xx(x,:);
        y=get(gh('Curve2Menu'),'Value');
        yy=get(gh('Curve2Menu'),'String');
        yy=yy(y,:);
        a=cdata.matrix{x};
        aerr=cdata.error{x};
        b=cdata.matrix{y};
        berr=cdata.error{y};
       [h,p]=ttest((a-b),0);
       %[h,p]=kstest2(a,b,0.05);
       % [p,h]=signrank(a,b,0.05)
    elseif  get(gh('CFNormalizeBox'),'Value')==0
		
        errordlg('Sorry, has to normalize the data first')
	end   
    figure
    areabar(cdata.xvalues, a, aerr,[.9 .8 .8],'Color',[1 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[1 0 0])
    hold on
    areabar(cdata.xvalues, b, berr,[.85 .85 .85],'Color',[0 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0])
    hold on
    plot(cdata.xvalues, a, 'Color',[1 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[1 0 0])
    hold on
    plot(cdata.xvalues, b, 'Color',[0 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0])
    hold off
	t=cdata.title{x};
	t=t(:,1:18);
    title(t);
    legend(xx,yy,0)
    if h==1
        t1=['Paired T-Test Significance: p = ' sprintf('%0.5f',p) '(Significant)'];
        gtext (t1);
    elseif h==0
        t1=['Paired T-Test Significance: p = ' sprintf('%0.5f',p) '(Not significant)'];
        gtext (t1);
    end   
    
else data.numvars==2  
	    if  get(gh('CFNormalizeBox'),'Value')==1
	   w=get(gh('YMenu'),'Value');
	   ww=cdata.yvalues(w);
        x=get(gh('Curve1Menu'),'Value');
        xx=get(gh('Curve1Menu'),'String');
        xx=xx(x,:);
        y=get(gh('Curve2Menu'),'Value');
        yy=get(gh('Curve2Menu'),'String');
        yy=yy(y,:);
        a=cdata.matrix{x};
		a=a(w,:);
        aerr=cdata.error{x};
		aerr=aerr(w,:);
        b=cdata.matrix{y};
		b=b(w,:);
        berr=cdata.error{y};
		berr=berr(w,:);
       [h,p]=ttest((a-b),0);
       % [h,p]=kstest2(a,b,0.05);
       % [p,h]=signrank(a,b,0.05)
    elseif  get(gh('CFNormalizeBox'),'Value')==0
		
        errordlg('Sorry, has to normalize the data first')
	end   
    figure
    areabar(cdata.xvalues, a, aerr,[.9 .8 .8],'Color',[1 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[1 0 0])
    hold on
    areabar(cdata.xvalues, b, berr,[.85 .85 .85],'Color',[0 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0])
    hold on
    plot(cdata.xvalues, a, 'Color',[1 0 0],'Marker','s','MarkerSize',6,'MarkerFaceColor',[1 0 0])
    hold on
    plot(cdata.xvalues, b, 'Color',[0 0 0],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0])
    hold off
	t=cdata.title{x};
	t=t(:,1:18);
    yt=['----' data.ytitle ' ' sprintf('%0.5g',ww)];
    t=[t yt];
    title(t);
   legend(xx,yy,0)
    if h==1
        t1=['Paired T-Test Significance: p = ' sprintf('%0.5f',p) '(Significant)'];
        gtext (t1);
    elseif h==0
        t1=['Paired T-Test Significance: p = ' sprintf('%0.5f',p) '(Not significant)'];
        gtext (t1);
    end   
end

%----------------------------------------------------------------------
case 'Subtraction'
	
	wx=cdata.xvalues;
	wy=cdata.yvalues;
	%wtitle={controltitle drugtitle   recoverytitle};
	
	x=get(gh('Curve1Menu'),'Value');
	xx=get(gh('Curve1Menu'),'String');
	xx=xx(x,:);
	y=get(gh('Curve2Menu'),'Value');
	yy=get(gh('Curve2Menu'),'String');
	yy=yy(y,:);
	a=cdata.matrix{x};
	b=cdata.matrix{y};
	
	if y==3;
		dd=a; 
	else
		dd=b-a;
	end
	
	if get(gh('CFNormalizeBox'),'Value')==1
		dd=dd./b;
	end
	
	pt=get(gh('PlotType'),'Value');
	
	
	figure
	if pt==1
		
		ax=cdata.xvalues;
		ay=cdata.yvalues;
		%xlinear=ax;
		%ylinear=ay;
		zdata=dd;
		imagesc(wx,wy,zdata);
		axis auto
		axis tight
		set(gca,'YDir','normal');
		xlabel('X Position');
		ylabel('Y Position');
	elseif pt==2
		
		pcolor(wx,wy,dd);
		shading interp
		grid on
		axis auto
		axis tight
		xlabel('X Position');
		ylabel('Y Position');
	end
	
		fixfig
		colorbar
		
		if y==3;
			TT=data.matrixtitle(1:13);
			t=['------' xx];
			TT=[TT t];
			title(TT)
		else
			TT=data.matrixtitle(1:13);
			t=[ '----' yy '-Subtract-'    xx];
			TT=[TT t];
			title(TT)
		end
		
		
val=get(gh('AxisBox'), 'Value');  % Check axes

if val == 1
	if data.dim==0
		axis auto
		axis tight
		axval=axis;	 %[-inf inf -inf inf];
		set(gca,'CLimMode','auto')
		cval=caxis;
	else
		axis auto
		axis tight
		axval=axis	%[-inf inf -inf inf -inf inf];
		set(gca,'CLimMode','auto')
		cval=caxis;
	end
	z1=min(cval);
	set(gh('ZTextMin'),'String',num2str(z1));
	z2=max(cval);
	set(gh('ZTextMax'),'String',num2str(z2));
	
else
	xval=str2num(get(gh('XAxisEdit'),'String'));
	yval=str2num(get(gh('YAxisEdit'),'String'));
	zval=str2num(get(gh('ZAxisEditInput'),'String'));
	if data.dim==0
		axval=[xval yval];
		cval=zval;
	else
		axval=[xval yval zval];
		cval=zval;
	end
	axis(axval);
	caxis(cval);
end

if data.xrange==data.yrange
	axis square
end

set(gca,'FontSize',8)
colorbar

if get(gh('HotMap'),'Value')==1
	colormap(hot)
end

save D:\Origin50\name.txt dd -ascii
dd

%-----------------------------------------------

%-----------------------------------------------------------------------
		
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
		 legend('Control','Recovery','Drug1',0)
		 if get(gh('BurstTonicBox'),'Value')==1
         legend('All spikes','Tonic','Burst',0)
	     end
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
   
   %[p,h]=signrank(cdata.matrix{2},cdata.matrix{4});
   %gtext('p,h')
   
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
   
   		s1=mean(data.ratio); t='mean burst ratio :';
	    s=[sprintf('%s\t',t), sprintf('%0.5g\t',s1)];
		gtext(s); 
   
   
case 'Load Mat'
   cufit('Reset')
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
         set(gh('XMenu'),'Enable','on');
      else         
         set(gh('HoldValue'),'Enable','on');
         set(gh('YMenu'),'Enable','on');
         set(gh('XMenu'),'Enable','on');
      end   
      if cdata.control==1 
         set(gh('d1radio'),'Value',1)
      end
      if cdata.drug1==1
         set(gh('d2radio'),'Value',1)
      end
      if cdata.drug2==1
         set(gh('d3radio'),'Value',1)
      end
      if cdata.recovery==1
         set(gh('d4radio'),'Value',1)
	 end      
	 if cdata.data5==1
		 set(gh('d5radio'),'Value',1)
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
   if get(gh('BurstTonicBox'),'Value')==0 & get(gh('Beebox'),'Value')==0
   set(gh('CurveType'),'String',{'Control';'Drug 1';'Drug 2';'Recovery'});
   set(gh('CurveType'),'Value',1);
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   t=strvcat('Control','Drug 1','Drug 2','Recovery');
   elseif get(gh('BurstTonicBox'),'Value')==1
   set(gh('CurveType'),'String',{'All Spikes';'Burst';'Temp';'Tonic'});
   set(gh('CurveType'),'Value',1);
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   set(gh('HoldValue'),'Value',2);
   t=strvcat('All Spikes','Burst','Temp','Tonic');
   
else get(gh('Beebox'),'Value')==1 
   
   set(gh('CurveType'),'String',{'Mono';'Red';'Green';'Blue';'Yellow'});
   set(gh('HoldValue'),'String',{'X Variable Held';'Y Variable Held'});
   %set(gh('Colour Intensity'),'String',' ');
   set(gh('HoldValue'),'Value',2);
   t=strvcat('Mono','Red','Green','Blue','Yellow');

end
   set(gh('Curve1Menu'),'String',t);
   set(gh('Curve1Menu'),'Value',1);
   set(gh('Curve2Menu'),'String',t); 
   set(gh('Curve2Menu'),'Value',1);
   cdata.type=[];
   cdata.control=0;
   cdata.drug1=0;
   cdata.drug2=0;
   cdata.recovery=0;
   cdata.data5=0;
   set(gh('d1radio'),'Value',0)
   set(gh('d2radio'),'Value',0)
   set(gh('d3radio'),'Value',0)
   set(gh('d4radio'),'Value',0)
   set(gh('d5radio'),'Value',0)
   
case 'Exit'
   close(gcf)
   
   
   
end


%GH Gets Handle From Tag
function [handle] = gh(tag)
handle=findobj('Tag',tag);
%End of handle getting routine
