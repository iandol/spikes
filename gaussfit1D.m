function gaussfit1D(action)

global gdat
global o

if nargin<1,
    action='Initialize';
end

%%%%%%%%%%%%%%See what dog needs to do%%%%%%%%%%%%%
switch(action)
    
case 'Initialize' 
    
    gdat=[];
    gaussfig1Db
    
    gdat.c1.mat=o.cell1.matrix;
    gdat.c2.mat=o.cell2.matrix;
    gdat.c1.name=o.cell1.filename;
    gdat.c2.name=o.cell2.filename;
    gdat.xvals=o.cell1.xvalues;
    gdat.yvals=o.cell1.yvalues;
    gdat.xhold=o.xhold-ceil(o.cell1.xrange/2);
    gdat.yhold=o.yhold-ceil(o.cell1.yrange/2);
    
    gdat.c1h=gdat.c1.mat(o.yhold,:)';
    gdat.c1v=gdat.c1.mat(:,o.xhold);
    
    gdat.c2h=gdat.c2.mat(o.yhold,:)';
    gdat.c2v=gdat.c2.mat(:,o.xhold);
    
    %---------------------------------------------------------------work out the diagonal positions	
    %-new snazzy method to select diagonals
    gdat.c1d1=diag(gdat.c1.mat,(gdat.xhold-gdat.yhold));
    gdat.c1d2=diag(fliplr(gdat.c1.mat),-(gdat.xhold+gdat.yhold));
    gdat.c2d1=diag(gdat.c2.mat,(gdat.xhold-gdat.yhold));
    gdat.c2d2=diag(fliplr(gdat.c2.mat),-(gdat.xhold+gdat.yhold));    
    
    %---------------------------------------------------------------------------------------interpolate curves
    
    gdat.xh=linspace(min(gdat.xvals),max(gdat.xvals),50);
    gdat.c1h=interp1(gdat.xvals,gdat.c1h,gdat.xh,'linear');
    gdat.c2h=interp1(gdat.xvals,gdat.c2h,gdat.xh,'linear');
    
    gdat.xv=linspace(min(gdat.yvals),max(gdat.yvals),50);
    gdat.c1v=interp1(gdat.yvals,gdat.c1v,gdat.xv,'linear');
    gdat.c2v=interp1(gdat.yvals,gdat.c2v,gdat.xv,'linear');
    
    r=sqrt((mean(diff(gdat.xvals)))^2+(mean(diff(gdat.yvals)))^2);
    q=0:r:(length(gdat.c1d1)-1)*r;
    gdat.xd1=linspace(min(q),max(q),50);
    gdat.c1d1=interp1(q,gdat.c1d1,gdat.xd1,'linear');
    gdat.c2d1=interp1(q,gdat.c2d1,gdat.xd1,'linear');
    
    r=sqrt((mean(diff(gdat.xvals)))^2+(mean(diff(gdat.yvals)))^2);
    q=0:r:(length(gdat.c1d2)-1)*r;
    gdat.xd2=linspace(min(q),max(q),50);
    gdat.c1d2=interp1(q,gdat.c1d2,gdat.xd2,'linear');
    gdat.c2d2=interp1(q,gdat.c2d2,gdat.xd2,'linear');
    
    %---------------------------------------------------------------------------------------------set defaults for each cell
    
    set(gh('H1Edit'),'String',num2str(max(gdat.c1h)));      %magnitude
    set(gh('H1Edit2'),'String',num2str(max(gdat.c2h)));
    t=gdat.xh(find(gdat.c1h==max(gdat.c1h)));
    t=num2str(t(1));
    set(gh('H2Edit'),'String',t); %position
    t=gdat.xh(find(gdat.c2h==max(gdat.c2h)));
    t=num2str(t(1));
    set(gh('H2Edit2'),'String',t); 
    set(gh('H3Edit'),'String','1');      %width
    set(gh('H3Edit2'),'String','1');      
    set(gh('H4Edit'),'String',num2str(min(gdat.c1h)));      %spontaneous
    set(gh('H4Edit2'),'String',num2str(min(gdat.c2h)));      
    
    set(gh('V1Edit'),'String',num2str(max(gdat.c1v)));      %magnitude
    set(gh('V1Edit2'),'String',num2str(max(gdat.c2v)));
    t=gdat.xv(find(gdat.c1v==max(gdat.c1v)));
    t=num2str(t(1));
    set(gh('V2Edit'),'String',t); %position
    t=gdat.xv(find(gdat.c2v==max(gdat.c2v)));
    t=num2str(t(1));
    set(gh('V2Edit2'),'String',t); 
    set(gh('V3Edit'),'String','1');      %width
    set(gh('V3Edit2'),'String','1');      
    set(gh('V4Edit'),'String',num2str(min(gdat.c1v)));      %spontaneous
    set(gh('V4Edit2'),'String',num2str(min(gdat.c2v)));      
    
    set(gh('D11Edit'),'String',num2str(max(gdat.c1d1)));      %magnitude
    set(gh('D11Edit2'),'String',num2str(max(gdat.c2d1)));
    t=gdat.xd1(find(gdat.c1d1==max(gdat.c1d1)));
    t=num2str(t(1));
    set(gh('D12Edit'),'String',t); %position
    t=gdat.xd1(find(gdat.c2d1==max(gdat.c2d1)));
    t=num2str(t(1));
    set(gh('D12Edit2'),'String',t); 
    set(gh('D13Edit'),'String','1');      %width
    set(gh('D13Edit2'),'String','1');      
    set(gh('D14Edit'),'String',num2str(min(gdat.c1d1)));      %spontaneous
    set(gh('D14Edit2'),'String',num2str(min(gdat.c2d1)));      
    
    set(gh('D21Edit'),'String',num2str(max(gdat.c1d2)));      %magnitude
    set(gh('D21Edit2'),'String',num2str(max(gdat.c2d2)));
    t=gdat.xd2(find(gdat.c1d2==max(gdat.c1d2)));
    t=num2str(t(1));
    set(gh('D22Edit'),'String',t); %position
    t=gdat.xd2(find(gdat.c2d2==max(gdat.c2d2)));
    t=num2str(t(1));
    set(gh('D22Edit2'),'String',t); 
    set(gh('D23Edit'),'String','1');      %width
    set(gh('D23Edit2'),'String','1');      
    set(gh('D24Edit'),'String',num2str(min(gdat.c1d2)));      %spontaneous
    set(gh('D24Edit2'),'String',num2str(min(gdat.c2d2)));      
    
    drawgauss(1);
    drawgauss(2);
    drawgauss(3);
    drawgauss(4);
    
    %============================================================
case 'HPlot'
    %============================================================
    drawgauss(1);
    
    %============================================================
case 'VPlot'
    %============================================================
    drawgauss(2)
    
    %============================================================
case 'D1Plot'
    %============================================================
    drawgauss(3)
    
    %============================================================
case 'D2Plot'
    %============================================================
    drawgauss(4)
    
    %============================================================
case 'HFit'
    %============================================================
    fitgauss(1)
    drawgauss(1)
    
    %============================================================
case 'VFit'
    %============================================================
    fitgauss(2)
    drawgauss(2)
    
    %============================================================
case 'D1Fit'
    %============================================================
    fitgauss(3)
    drawgauss(3)
    
    %============================================================
case 'D2Fit'
    %============================================================
    fitgauss(4)
    drawgauss(4)
    
end





%============================================================
%
%============================================================
function drawgauss(s)

global gdat

switch s
case 1 %horizontal
    
    if get(gh('LockPBox'),'Value')==1
        switch get(gh('LockMenu'),'Value')
        case 1   %position+width 
            c1p(1)=str2num(get(gh('H1Edit'),'String'));	
            c2p(1)=str2num(get(gh('H1Edit2'),'String'));
            c1p(2)=str2num(get(gh('H2Edit'),'String'));
            c2p(2)=str2num(get(gh('H2Edit'),'String'));
            c1p(3)=str2num(get(gh('H3Edit'),'String'));
            c2p(3)=str2num(get(gh('H3Edit'),'String'));
            c1p(4)=str2num(get(gh('H4Edit'),'String'));
            c2p(4)=str2num(get(gh('H4Edit2'),'String'));	
            set(gh('H1Edit'),'String',num2str(c1p(1)));
            set(gh('H1Edit2'),'String',num2str(c2p(1)));
            set(gh('H2Edit'),'String',num2str(c1p(2)));
            set(gh('H2Edit2'),'String',num2str(c2p(2)));
            set(gh('H3Edit'),'String',num2str(c1p(3)));
            set(gh('H3Edit2'),'String',num2str(c2p(3)));
            set(gh('H4Edit'),'String',num2str(c1p(4)));
            set(gh('H4Edit2'),'String',num2str(c2p(4)));
        case 2 %position
            c1p(1)=str2num(get(gh('H1Edit'),'String'));	
            c2p(1)=str2num(get(gh('H1Edit2'),'String'));
            c1p(2)=str2num(get(gh('H2Edit'),'String'));
            c2p(2)=str2num(get(gh('H2Edit'),'String'));
            c1p(3)=str2num(get(gh('H3Edit'),'String'));
            c2p(3)=str2num(get(gh('H3Edit2'),'String'));
            c1p(4)=str2num(get(gh('H4Edit'),'String'));
            c2p(4)=str2num(get(gh('H4Edit2'),'String'));	
            set(gh('H1Edit'),'String',num2str(c1p(1)));
            set(gh('H1Edit2'),'String',num2str(c2p(1)));
            set(gh('H2Edit'),'String',num2str(c1p(2)));
            set(gh('H2Edit2'),'String',num2str(c2p(2)));
            set(gh('H3Edit'),'String',num2str(c1p(3)));
            set(gh('H3Edit2'),'String',num2str(c2p(3)));
            set(gh('H4Edit'),'String',num2str(c1p(4)));
            set(gh('H4Edit2'),'String',num2str(c2p(4)));
        case 3 %width
            c1p(1)=str2num(get(gh('H1Edit'),'String'));	
            c2p(1)=str2num(get(gh('H1Edit2'),'String'));
            c1p(2)=str2num(get(gh('H2Edit'),'String'));
            c2p(2)=str2num(get(gh('H2Edit2'),'String'));
            c1p(3)=str2num(get(gh('H3Edit'),'String'));
            c2p(3)=str2num(get(gh('H3Edit'),'String'));
            c1p(4)=str2num(get(gh('H4Edit'),'String'));
            c2p(4)=str2num(get(gh('H4Edit2'),'String'));	
            set(gh('H1Edit'),'String',num2str(c1p(1)));
            set(gh('H1Edit2'),'String',num2str(c2p(1)));
            set(gh('H2Edit'),'String',num2str(c1p(2)));
            set(gh('H2Edit2'),'String',num2str(c2p(2)));
            set(gh('H3Edit'),'String',num2str(c1p(3)));
            set(gh('H3Edit2'),'String',num2str(c2p(3)));
            set(gh('H4Edit'),'String',num2str(c1p(4)));
            set(gh('H4Edit2'),'String',num2str(c2p(4)));
        end        
    else 
        c1p(1)=str2num(get(gh('H1Edit'),'String'));	
        c2p(1)=str2num(get(gh('H1Edit2'),'String'));
        c1p(2)=str2num(get(gh('H2Edit'),'String'));
        c2p(2)=str2num(get(gh('H2Edit2'),'String'));
        c1p(3)=str2num(get(gh('H3Edit'),'String'));
        c2p(3)=str2num(get(gh('H3Edit2'),'String'));
        c1p(4)=str2num(get(gh('H4Edit'),'String'));
        c2p(4)=str2num(get(gh('H4Edit2'),'String'));	
    end
    
    gdat.c1hp=c1p;
    gdat.c2hp=c2p;
    gdat.c1hgauss=gauss(c1p,gdat.xh);
    gdat.c2hgauss=gauss(c2p,gdat.xh);
    
    if max(gdat.c1h)>max(gdat.c2h)
        x1=gdat.xh;
        y1=gdat.c1h;
        x1g=gdat.xh;
        y1g=gdat.c1hgauss;
        x2=gdat.xh;
        y2=gdat.c2h*(max(gdat.c1h)/max(gdat.c2h));
        x2g=gdat.xh;
        y2g=gdat.c2hgauss*(max(gdat.c1h)/max(gdat.c2h));
    else
        x1=gdat.xh;
        y1=gdat.c1h*(max(gdat.c2h)/max(gdat.c1h));
        x1g=gdat.xh;
        y1g=gdat.c1hgauss*(max(gdat.c2h)/max(gdat.c1h));
        x2=gdat.xh;
        y2=gdat.c2h;
        x2g=gdat.xh;
        y2g=gdat.c2hgauss;
    end
    axes(gh('HAxis'));    
    cla
    hold on
    plot(x1,y1,'ko',x1g,y1g,'k-');
    plot(x2,y2,'ro',x2g,y2g,'r-');    
    hold off
    set(gca,'Tag','HAxis');
    g1=num2str(goodness(y1,y1g,'m'));
    g2=num2str(goodness(y2,y2g,'m'));
    g5=num2str(goodness(y1,y1g,'mfe'));
    g6=num2str(goodness(y2,y2g,'mfe'));
    g3=num2str(goodness(y1,y1g,num2str(c1p(4))));
    g4=num2str(goodness(y2,y2g,num2str(c2p(4))));
    t=strvcat(['Mean = ' g1 '% / ' g2 '%'],['Spontaneous = ' g3 '% / ' g4 '%'],['MFE = ' g5 ' / ' g6]);
    set(gh('HText'),'String',t);
    
case 2 %vertical
    
    if get(gh('LockPBox'),'Value')==1
        switch get(gh('LockMenu'),'Value')
        case 1   %position+width 
            c1p(1)=str2num(get(gh('V1Edit'),'String'));	
            c2p(1)=str2num(get(gh('V1Edit2'),'String'));
            c1p(2)=str2num(get(gh('V2Edit'),'String'));
            c2p(2)=str2num(get(gh('V2Edit'),'String'));
            c1p(3)=str2num(get(gh('V3Edit'),'String'));
            c2p(3)=str2num(get(gh('V3Edit'),'String'));
            c1p(4)=str2num(get(gh('V4Edit'),'String'));
            c2p(4)=str2num(get(gh('V4Edit2'),'String'));	
            set(gh('V1Edit'),'String',num2str(c1p(1)));
            set(gh('V1Edit2'),'String',num2str(c2p(1)));
            set(gh('V2Edit'),'String',num2str(c1p(2)));
            set(gh('V2Edit2'),'String',num2str(c2p(2)));
            set(gh('V3Edit'),'String',num2str(c1p(3)));
            set(gh('V3Edit2'),'String',num2str(c2p(3)));
            set(gh('V4Edit'),'String',num2str(c1p(4)));
            set(gh('V4Edit2'),'String',num2str(c2p(4)));
        case 2 %position
            c1p(1)=str2num(get(gh('V1Edit'),'String'));	
            c2p(1)=str2num(get(gh('V1Edit2'),'String'));
            c1p(2)=str2num(get(gh('V2Edit'),'String'));
            c2p(2)=str2num(get(gh('V2Edit'),'String'));
            c1p(3)=str2num(get(gh('V3Edit'),'String'));
            c2p(3)=str2num(get(gh('V3Edit2'),'String'));
            c1p(4)=str2num(get(gh('V4Edit'),'String'));
            c2p(4)=str2num(get(gh('V4Edit2'),'String'));	
            set(gh('V1Edit'),'String',num2str(c1p(1)));
            set(gh('V1Edit2'),'String',num2str(c2p(1)));
            set(gh('V2Edit'),'String',num2str(c1p(2)));
            set(gh('V2Edit2'),'String',num2str(c2p(2)));
            set(gh('V3Edit'),'String',num2str(c1p(3)));
            set(gh('V3Edit2'),'String',num2str(c2p(3)));
            set(gh('V4Edit'),'String',num2str(c1p(4)));
            set(gh('V4Edit2'),'String',num2str(c2p(4)));
        case 3 %width
            c1p(1)=str2num(get(gh('V1Edit'),'String'));	
            c2p(1)=str2num(get(gh('V1Edit2'),'String'));
            c1p(2)=str2num(get(gh('V2Edit'),'String'));
            c2p(2)=str2num(get(gh('V2Edit2'),'String'));
            c1p(3)=str2num(get(gh('V3Edit'),'String'));
            c2p(3)=str2num(get(gh('V3Edit'),'String'));
            c1p(4)=str2num(get(gh('V4Edit'),'String'));
            c2p(4)=str2num(get(gh('V4Edit2'),'String'));	
            set(gh('V1Edit'),'String',num2str(c1p(1)));
            set(gh('V1Edit2'),'String',num2str(c2p(1)));
            set(gh('V2Edit'),'String',num2str(c1p(2)));
            set(gh('V2Edit2'),'String',num2str(c2p(2)));
            set(gh('V3Edit'),'String',num2str(c1p(3)));
            set(gh('V3Edit2'),'String',num2str(c2p(3)));
            set(gh('V4Edit'),'String',num2str(c1p(4)));
            set(gh('V4Edit2'),'String',num2str(c2p(4)));
        end        
    else 
        c1p(1)=str2num(get(gh('V1Edit'),'String'));	
        c2p(1)=str2num(get(gh('V1Edit2'),'String'));
        c1p(2)=str2num(get(gh('V2Edit'),'String'));
        c2p(2)=str2num(get(gh('V2Edit2'),'String'));
        c1p(3)=str2num(get(gh('V3Edit'),'String'));
        c2p(3)=str2num(get(gh('V3Edit2'),'String'));
        c1p(4)=str2num(get(gh('V4Edit'),'String'));
        c2p(4)=str2num(get(gh('V4Edit2'),'String'));	
    end
        
    gdat.c1vp=c1p;
    gdat.c2vp=c2p;
    gdat.c1vgauss=gauss(c1p,gdat.xv);
    gdat.c2vgauss=gauss(c2p,gdat.xv);
    
    if max(gdat.c1v)>max(gdat.c2v)
        x1=gdat.xv;
        y1=gdat.c1v;
        x1g=gdat.xv;
        y1g=gdat.c1vgauss;
        x2=gdat.xv;
        y2=gdat.c2v*(max(gdat.c1v)/max(gdat.c2v));
        x2g=gdat.xv;
        y2g=gdat.c2vgauss*(max(gdat.c1v)/max(gdat.c2v));
    else
        x1=gdat.xv;
        y1=gdat.c1v*(max(gdat.c2v)/max(gdat.c1v));
        x1g=gdat.xv;
        y1g=gdat.c1vgauss*(max(gdat.c2v)/max(gdat.c1v));
        x2=gdat.xv;
        y2=gdat.c2v;
        x2g=gdat.xv;
        y2g=gdat.c2vgauss;
    end
    axes(gh('VAxis')); 
    cla
    hold on
    plot(x1,y1,'ko',x1g,y1g,'k-');
    plot(x2,y2,'ro',x2g,y2g,'r-');    
    hold off
    set(gca,'Tag','VAxis');
%     g1=goodness(y1,y1g);
%     g2=goodness(y2,y2g);
%     set(gh('VText'),'String',['Control Fit: ' num2str(g1) '%     Drug Fit: ' num2str(g2) '%']);
    g1=num2str(goodness(y1,y1g,'m'));
    g2=num2str(goodness(y2,y2g,'m'));
    g5=num2str(goodness(y1,y1g,'mfe'));
    g6=num2str(goodness(y2,y2g,'mfe'));
    g3=num2str(goodness(y1,y1g,num2str(c1p(4))));
    g4=num2str(goodness(y2,y2g,num2str(c2p(4))));
    t=strvcat(['Mean = ' g1 '% / ' g2 '%'],['Spontaneous = ' g3 '% / ' g4 '%'],['MFE = ' g5 ' / ' g6]);
    set(gh('VText'),'String',t);
    
    
case 3	%diagonal 1
    
    if get(gh('LockPBox'),'Value')==1
        switch get(gh('LockMenu'),'Value')
        case 1   %position+width 
            c1p(1)=str2num(get(gh('D11Edit'),'String'));	
            c2p(1)=str2num(get(gh('D11Edit2'),'String'));
            c1p(2)=str2num(get(gh('D12Edit'),'String'));
            c2p(2)=str2num(get(gh('D12Edit'),'String'));
            c1p(3)=str2num(get(gh('D13Edit'),'String'));
            c2p(3)=str2num(get(gh('D13Edit'),'String'));
            c1p(4)=str2num(get(gh('D14Edit'),'String'));
            c2p(4)=str2num(get(gh('D14Edit2'),'String'));	
            set(gh('D11Edit'),'String',num2str(c1p(1)));
            set(gh('D11Edit2'),'String',num2str(c2p(1)));
            set(gh('D12Edit'),'String',num2str(c1p(2)));
            set(gh('D12Edit2'),'String',num2str(c2p(2)));
            set(gh('D13Edit'),'String',num2str(c1p(3)));
            set(gh('D13Edit2'),'String',num2str(c2p(3)));
            set(gh('D14Edit'),'String',num2str(c1p(4)));
            set(gh('D14Edit2'),'String',num2str(c2p(4)));
        case 2 %position
            c1p(1)=str2num(get(gh('D11Edit'),'String'));	
            c2p(1)=str2num(get(gh('D11Edit2'),'String'));
            c1p(2)=str2num(get(gh('D12Edit'),'String'));
            c2p(2)=str2num(get(gh('D12Edit'),'String'));
            c1p(3)=str2num(get(gh('D13Edit'),'String'));
            c2p(3)=str2num(get(gh('D13Edit2'),'String'));
            c1p(4)=str2num(get(gh('D14Edit'),'String'));
            c2p(4)=str2num(get(gh('D14Edit2'),'String'));	
            set(gh('D11Edit'),'String',num2str(c1p(1)));
            set(gh('D11Edit2'),'String',num2str(c2p(1)));
            set(gh('D12Edit'),'String',num2str(c1p(2)));
            set(gh('D12Edit2'),'String',num2str(c2p(2)));
            set(gh('D13Edit'),'String',num2str(c1p(3)));
            set(gh('D13Edit2'),'String',num2str(c2p(3)));
            set(gh('D14Edit'),'String',num2str(c1p(4)));
            set(gh('D14Edit2'),'String',num2str(c2p(4)));
        case 3 %width
            c1p(1)=str2num(get(gh('D11Edit'),'String'));	
            c2p(1)=str2num(get(gh('D11Edit2'),'String'));
            c1p(2)=str2num(get(gh('D12Edit'),'String'));
            c2p(2)=str2num(get(gh('D12Edit2'),'String'));
            c1p(3)=str2num(get(gh('D13Edit'),'String'));
            c2p(3)=str2num(get(gh('D13Edit'),'String'));
            c1p(4)=str2num(get(gh('D14Edit'),'String'));
            c2p(4)=str2num(get(gh('D14Edit2'),'String'));	
            set(gh('D11Edit'),'String',num2str(c1p(1)));
            set(gh('D11Edit2'),'String',num2str(c2p(1)));
            set(gh('D12Edit'),'String',num2str(c1p(2)));
            set(gh('D12Edit2'),'String',num2str(c2p(2)));
            set(gh('D13Edit'),'String',num2str(c1p(3)));
            set(gh('D13Edit2'),'String',num2str(c2p(3)));
            set(gh('D14Edit'),'String',num2str(c1p(4)));
            set(gh('D14Edit2'),'String',num2str(c2p(4)));
        end        
    else 
        c1p(1)=str2num(get(gh('D11Edit'),'String'));	
        c2p(1)=str2num(get(gh('D11Edit2'),'String'));
        c1p(2)=str2num(get(gh('D12Edit'),'String'));
        c2p(2)=str2num(get(gh('D12Edit2'),'String'));
        c1p(3)=str2num(get(gh('D13Edit'),'String'));
        c2p(3)=str2num(get(gh('D13Edit2'),'String'));
        c1p(4)=str2num(get(gh('D14Edit'),'String'));
        c2p(4)=str2num(get(gh('D14Edit2'),'String'));	
    end
    
    gdat.c1d1p=c1p;
    gdat.c2d1p=c2p;
    gdat.c1d1gauss=gauss(c1p,gdat.xd1)
    gdat.c2d1gauss=gauss(c2p,gdat.xd1)
    
    if max(gdat.c1d1)>max(gdat.c2d1)
        x1=gdat.xd1;
        y1=gdat.c1d1;
        x1g=gdat.xd1;
        y1g=gdat.c1d1gauss;
        x2=gdat.xd1;
        y2=gdat.c2d1*(max(gdat.c1d1)/max(gdat.c2d1));
        x2g=gdat.xd1;
        y2g=gdat.c2d1gauss*(max(gdat.c1d1)/max(gdat.c2d1));
    else
        x1=gdat.xd1;
        y1=gdat.c1d1*(max(gdat.c2d1)/max(gdat.c1d1));
        x1g=gdat.xd1;
        y1g=gdat.c1d1gauss*(max(gdat.c2d1)/max(gdat.c1d1));
        x2=gdat.xd1;
        y2=gdat.c2d1;
        x2g=gdat.xd1;
        y2g=gdat.c2d1gauss;
    end
    axes(gh('D1Axis')); 
    cla
    hold on
    plot(x1,y1,'ko',x1g,y1g,'k-');
    plot(x2,y2,'ro',x2g,y2g,'r-');    
    hold off
    set(gca,'Tag','D1Axis');
    g1=num2str(goodness(y1,y1g,'m'));
    g2=num2str(goodness(y2,y2g,'m'));
    g5=num2str(goodness(y1,y1g,'mfe'));
    g6=num2str(goodness(y2,y2g,'mfe'));
    g3=num2str(goodness(y1,y1g,num2str(c1p(4))));
    g4=num2str(goodness(y2,y2g,num2str(c2p(4))));
    t=strvcat(['Mean = ' g1 '% / ' g2 '%'],['Spontaneous = ' g3 '% / ' g4 '%'],['MFE = ' g5 ' / ' g6]);
    set(gh('D1Text'),'String',t);
    
case 4 %diagonal 2
    
   if get(gh('LockPBox'),'Value')==1
        switch get(gh('LockMenu'),'Value')
        case 1   %position+width 
            c1p(1)=str2num(get(gh('D21Edit'),'String'));	
            c2p(1)=str2num(get(gh('D21Edit2'),'String'));
            c1p(2)=str2num(get(gh('D22Edit'),'String'));
            c2p(2)=str2num(get(gh('D22Edit'),'String'));
            c1p(3)=str2num(get(gh('D23Edit'),'String'));
            c2p(3)=str2num(get(gh('D23Edit'),'String'));
            c1p(4)=str2num(get(gh('D24Edit'),'String'));
            c2p(4)=str2num(get(gh('D24Edit2'),'String'));	
            set(gh('D21Edit'),'String',num2str(c1p(1)));
            set(gh('D21Edit2'),'String',num2str(c2p(1)));
            set(gh('D22Edit'),'String',num2str(c1p(2)));
            set(gh('D22Edit2'),'String',num2str(c2p(2)));
            set(gh('D23Edit'),'String',num2str(c1p(3)));
            set(gh('D23Edit2'),'String',num2str(c2p(3)));
            set(gh('D24Edit'),'String',num2str(c1p(4)));
            set(gh('D24Edit2'),'String',num2str(c2p(4)));
        case 2 %position
            c1p(1)=str2num(get(gh('D21Edit'),'String'));	
            c2p(1)=str2num(get(gh('D21Edit2'),'String'));
            c1p(2)=str2num(get(gh('D22Edit'),'String'));
            c2p(2)=str2num(get(gh('D22Edit'),'String'));
            c1p(3)=str2num(get(gh('D23Edit'),'String'));
            c2p(3)=str2num(get(gh('D23Edit2'),'String'));
            c1p(4)=str2num(get(gh('D24Edit'),'String'));
            c2p(4)=str2num(get(gh('D24Edit2'),'String'));	
            set(gh('D21Edit'),'String',num2str(c1p(1)));
            set(gh('D21Edit2'),'String',num2str(c2p(1)));
            set(gh('D22Edit'),'String',num2str(c1p(2)));
            set(gh('D22Edit2'),'String',num2str(c2p(2)));
            set(gh('D23Edit'),'String',num2str(c1p(3)));
            set(gh('D23Edit2'),'String',num2str(c2p(3)));
            set(gh('D24Edit'),'String',num2str(c1p(4)));
            set(gh('D24Edit2'),'String',num2str(c2p(4)));
        case 3 %width
            c1p(1)=str2num(get(gh('D21Edit'),'String'));	
            c2p(1)=str2num(get(gh('D21Edit2'),'String'));
            c1p(2)=str2num(get(gh('D22Edit'),'String'));
            c2p(2)=str2num(get(gh('D22Edit2'),'String'));
            c1p(3)=str2num(get(gh('D23Edit'),'String'));
            c2p(3)=str2num(get(gh('D23Edit'),'String'));
            c1p(4)=str2num(get(gh('D24Edit'),'String'));
            c2p(4)=str2num(get(gh('D24Edit2'),'String'));	
            set(gh('D21Edit'),'String',num2str(c1p(1)));
            set(gh('D21Edit2'),'String',num2str(c2p(1)));
            set(gh('D22Edit'),'String',num2str(c1p(2)));
            set(gh('D22Edit2'),'String',num2str(c2p(2)));
            set(gh('D23Edit'),'String',num2str(c1p(3)));
            set(gh('D23Edit2'),'String',num2str(c2p(3)));
            set(gh('D24Edit'),'String',num2str(c1p(4)));
            set(gh('D24Edit2'),'String',num2str(c2p(4)));
        end        
    else 
        c1p(1)=str2num(get(gh('D21Edit'),'String'));	
        c2p(1)=str2num(get(gh('D21Edit2'),'String'));
        c1p(2)=str2num(get(gh('D22Edit'),'String'));
        c2p(2)=str2num(get(gh('D22Edit2'),'String'));
        c1p(3)=str2num(get(gh('D23Edit'),'String'));
        c2p(3)=str2num(get(gh('D23Edit2'),'String'));
        c1p(4)=str2num(get(gh('D24Edit'),'String'));
        c2p(4)=str2num(get(gh('D24Edit2'),'String'));	
    end
    
    gdat.c1d2p=c1p;
    gdat.c2d2p=c2p;
    gdat.c1d2gauss=gauss(c1p,gdat.xd2)
    gdat.c2d2gauss=gauss(c2p,gdat.xd2)
    
    if max(gdat.c1d2)>max(gdat.c2d2)
        x1=gdat.xd2;
        y1=gdat.c1d2;
        x1g=gdat.xd2;
        y1g=gdat.c1d2gauss;
        x2=gdat.xd2;
        y2=gdat.c2d2*(max(gdat.c1d2)/max(gdat.c2d2));
        x2g=gdat.xd2;
        y2g=gdat.c2d2gauss*(max(gdat.c1d2)/max(gdat.c2d2));
    else
        x1=gdat.xd2;
        y1=gdat.c1d2*(max(gdat.c2d2)/max(gdat.c1d2));
        x1g=gdat.xd2;
        y1g=gdat.c1d2gauss*(max(gdat.c2d2)/max(gdat.c1d2));
        x2=gdat.xd2;
        y2=gdat.c2d2;
        x2g=gdat.xd2;
        y2g=gdat.c2d2gauss;
    end
    
    axes(gh('D2Axis')); 
    cla
    hold on
    plot(x1,y1,'ko',x1g,y1g,'k-');
    plot(x2,y2,'ro',x2g,y2g,'r-');    
    hold off
    set(gca,'Tag','D2Axis');
    g1=num2str(goodness(y1,y1g,'m'));
    g2=num2str(goodness(y2,y2g,'m'));
    g5=num2str(goodness(y1,y1g,'mfe'));
    g6=num2str(goodness(y2,y2g,'mfe'));
    g3=num2str(goodness(y1,y1g,num2str(c1p(4))));
    g4=num2str(goodness(y2,y2g,num2str(c2p(4))));
    t=strvcat(['Mean = ' g1 '% / ' g2 '%'],['Spontaneous = ' g3 '% / ' g4 '%'],['MFE = ' g5 ' / ' g6]);
    set(gh('D2Text'),'String',t);
    
end

%============================================================
%
%============================================================
function fitgauss(s)

global gdat

lb=[0 -100 0 0];
ub=[500 100 100 100];
disp='iter';
ls='off';
options = optimset('Display',disp,'LargeScale',ls);

switch s
case 1
    c1p(1)=str2num(get(gh('H1Edit'),'String'));	
    c2p(1)=str2num(get(gh('H1Edit2'),'String'));
    c1p(2)=str2num(get(gh('H2Edit'),'String'));
    c2p(2)=str2num(get(gh('H2Edit2'),'String'));
    c1p(3)=str2num(get(gh('H3Edit'),'String'));
    c2p(3)=str2num(get(gh('H3Edit2'),'String'));
    c1p(4)=str2num(get(gh('H4Edit'),'String'));
    c2p(4)=str2num(get(gh('H4Edit2'),'String'));	
    
    [c1p,f,exit1,output]=fmincon(@dogauss,c1p,[],[],[],[],lb,ub,[],options,gdat.xh,gdat.c1h);
    [c2p,f,exit2,output]=fmincon(@dogauss,c2p,[],[],[],[],lb,ub,[],options,gdat.xh,gdat.c2h);
    
    if exit1>=0
        set(gh('HC1Text'),'String','Found Optimal Parameters.')
    elseif exit1<0
        set(gh('HC1Text'),'String','Did not converge, run again.')
    end
    
    if exit2>=0
        set(gh('HC2Text'),'String','Found Optimal Parameters.')
    elseif exit2<0
        set(gh('HC2Text'),'String','Did not converge, run again.')
    end
    
    set(gh('H1Edit'),'String',num2str(c1p(1)));
    set(gh('H1Edit2'),'String',num2str(c2p(1)));
    set(gh('H2Edit'),'String',num2str(c1p(2)));
    set(gh('H2Edit2'),'String',num2str(c2p(2)));
    set(gh('H3Edit'),'String',num2str(c1p(3)));
    set(gh('H3Edit2'),'String',num2str(c2p(3)));
    set(gh('H4Edit'),'String',num2str(c1p(4)));
    set(gh('H4Edit2'),'String',num2str(c2p(4)));
    
    gdat.c1hp=c1p;
    gdat.c2hp=c2p;
    
case 2
    c1p(1)=str2num(get(gh('V1Edit'),'String'));	
    c2p(1)=str2num(get(gh('V1Edit2'),'String'));
    c1p(2)=str2num(get(gh('V2Edit'),'String'));
    c2p(2)=str2num(get(gh('V2Edit2'),'String'));
    c1p(3)=str2num(get(gh('V3Edit'),'String'));
    c2p(3)=str2num(get(gh('V3Edit2'),'String'));
    c1p(4)=str2num(get(gh('V4Edit'),'String'));
    c2p(4)=str2num(get(gh('V4Edit2'),'String'));	
    
    [c1p,f,exit1,output]=fmincon(@dogauss,c1p,[],[],[],[],lb,ub,[],options,gdat.xv,gdat.c1v);
    [c2p,f,exit2,output]=fmincon(@dogauss,c2p,[],[],[],[],lb,ub,[],options,gdat.xv,gdat.c2v);
    
    if exit1>=0
        set(gh('VC1Text'),'String','Found Optimal Parameters.')
    elseif exit1<0
        set(gh('VC1Text'),'String','Did not converge, run again.')
    end
    
    if exit2>=0
        set(gh('VC2Text'),'String','Found Optimal Parameters.')
    elseif exit2<0
        set(gh('VC2Text'),'String','Did not converge, run again.')
    end
    
    set(gh('V1Edit'),'String',num2str(c1p(1)));
    set(gh('V1Edit2'),'String',num2str(c2p(1)));
    set(gh('V2Edit'),'String',num2str(c1p(2)));
    set(gh('V2Edit2'),'String',num2str(c2p(2)));
    set(gh('V3Edit'),'String',num2str(c1p(3)));
    set(gh('V3Edit2'),'String',num2str(c2p(3)));
    set(gh('V4Edit'),'String',num2str(c1p(4)));
    set(gh('V4Edit2'),'String',num2str(c2p(4)));
    
    gdat.c1vp=c1p;
    gdat.c2vp=c2p;
    
case 3
    c1p(1)=str2num(get(gh('D11Edit'),'String'));	
    c2p(1)=str2num(get(gh('D11Edit2'),'String'));
    c1p(2)=str2num(get(gh('D12Edit'),'String'));
    c2p(2)=str2num(get(gh('D12Edit2'),'String'));
    c1p(3)=str2num(get(gh('D13Edit'),'String'));
    c2p(3)=str2num(get(gh('D13Edit2'),'String'));
    c1p(4)=str2num(get(gh('D14Edit'),'String'));
    c2p(4)=str2num(get(gh('D14Edit2'),'String'));	
    
    [c1p,f,exit1,output]=fmincon(@dogauss,c1p,[],[],[],[],lb,ub,[],options,gdat.xd1,gdat.c1d1);
    [c2p,f,exit2,output]=fmincon(@dogauss,c2p,[],[],[],[],lb,ub,[],options,gdat.xd1,gdat.c2d1);
    
    if exit1>=0
        set(gh('D1C1Text'),'String','Found Optimal Parameters.')
    elseif exit1<0
        set(gh('D1C1Text'),'String','Did not converge, run again.')
    end
    
    if exit2>=0
        set(gh('D1C2Text'),'String','Found Optimal Parameters.')
    elseif exit2<0
        set(gh('D1C2Text'),'String','Did not converge, run again.')
    end
    
    set(gh('D11Edit'),'String',num2str(c1p(1)));
    set(gh('D11Edit2'),'String',num2str(c2p(1)));
    set(gh('D12Edit'),'String',num2str(c1p(2)));
    set(gh('D12Edit2'),'String',num2str(c2p(2)));
    set(gh('D13Edit'),'String',num2str(c1p(3)));
    set(gh('D13Edit2'),'String',num2str(c2p(3)));
    set(gh('D14Edit'),'String',num2str(c1p(4)));
    set(gh('D14Edit2'),'String',num2str(c2p(4)));
    
    gdat.c1d1p=c1p;
    gdat.c2d1p=c2p;
    
case 4
    c1p(1)=str2num(get(gh('D21Edit'),'String'));	
    c2p(1)=str2num(get(gh('D21Edit2'),'String'));
    c1p(2)=str2num(get(gh('D22Edit'),'String'));
    c2p(2)=str2num(get(gh('D22Edit2'),'String'));
    c1p(3)=str2num(get(gh('D23Edit'),'String'));
    c2p(3)=str2num(get(gh('D23Edit2'),'String'));
    c1p(4)=str2num(get(gh('D24Edit'),'String'));
    c2p(4)=str2num(get(gh('D24Edit2'),'String'));	
    
    [c1p,f,exit1,output]=fmincon(@dogauss,c1p,[],[],[],[],lb,ub,[],options,gdat.xd2,gdat.c1d2);
    [c2p,f,exit2,output]=fmincon(@dogauss,c2p,[],[],[],[],lb,ub,[],options,gdat.xd2,gdat.c2d2);
    
    if exit1>=0
        set(gh('D2C1Text'),'String','Found Optimal Parameters.')
    elseif exit1<0
        set(gh('D2C1Text'),'String','Did not converge, run again.')
    end
    
    if exit2>=0
        set(gh('D2C2Text'),'String','Found Optimal Parameters.')
    elseif exit2<0
        set(gh('D2C2Text'),'String','Did not converge, run again.')
    end
    
    set(gh('D21Edit'),'String',num2str(c1p(1)));
    set(gh('D21Edit2'),'String',num2str(c2p(1)));
    set(gh('D22Edit'),'String',num2str(c1p(2)));
    set(gh('D22Edit2'),'String',num2str(c2p(2)));
    set(gh('D23Edit'),'String',num2str(c1p(3)));
    set(gh('D23Edit2'),'String',num2str(c2p(3)));
    set(gh('D24Edit'),'String',num2str(c1p(4)));
    set(gh('D24Edit2'),'String',num2str(c2p(4)));
    
    gdat.c1d2p=c1p;
    gdat.c2d2p=c2p;
    
end

%============================================================
%
%============================================================
function f=dogauss(p,x,y)

a=find(p==0);
p(a)=0.0000000000001;

yy=p(4)+p(1)*exp(-0.5*((x-p(2))/p(3)).^2);

f=sum((y-yy).^2);



%============================================================
%
%============================================================
function f=gauss(p,x)

a=find(p==0);
p(a)=0.0000000000001;

f=p(4)+p(1)*exp(-0.5*((x-p(2))/p(3)).^2);


%============================================================
%
%============================================================
function [handle] = gu(tag)

handle=findobj('UserData',tag);






