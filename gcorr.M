%this reads data into Carlos programs, computes xcorr, and extracts the
%region near zero for further manipulation.
%	v1  GLG  30 OCT 97  initial single file version.
%	v2  GLG  30 OCT 97  works on several files.
%	v3  GLG  31 OCT 97  plots sum counts; cent and max locations.
%	v4  GLG  31 OCT 97  same as v3; combines fig2+3 into 1 page
%	v5  GLG  26 NOV 97  uses dxcorr.m for excess corr page;
%			inputs actual angles used for x scale (si)
%	v6  GLG  28 NOV 97  adds automatic scaling in diff pics.
%	v7  GLG  16 DEC 97  automatic time scale in all pics.
%
%*********************************************************************
function gcorr()

clear

[fname,pname] = uigetfile('*.*','Find Exported Data Directory')
cd(pname)
[p,defname,e]=fileparts(fname);
%bfname=input('base file name (NO extension): ','s');
%fnum=input('first extension to use: ');
%lnum=input('last extension to use: ');
%binw=input('binwidth in ms: ');
%ua=input('first unit (1-3): ');
%ub=input('second unit (1-3): ');
prompt={'base file name (NO extension): ','first extension to use: ','last extension to use: ',...
      'binwidth in ms: ','first unit (1-6): ','second unit (1-6): '};
windowtitle='XCor Analysis';
def={defname,'1','8','6','1','2'};
answer=inputdlg(prompt,windowtitle,1,def);
bfname=char(answer(1));
fnum=str2num(char(answer(2)));
lnum=str2num(char(answer(3)));
binw=str2num(char(answer(4)));
ua=str2num(char(answer(5)));
ub=str2num(char(answer(6)));

dn1=['d' int2str(ua)];
dn2=['d' int2str(ub)];
k=0;
while (k <= (lnum-fnum))
   filename = [bfname '.' int2str(fnum + k)];
   if ~exist(filename), break, end
   %
   % read data file into Carlos programs and run dxcorr
   [d1,d2,d3,d4,d5,d6,st]=dload(filename);
   [x,timebase,mu,sd,sx,stime,smu]=dxcorr2(eval(dn1),eval(dn2),'binwidth',binw,'nosub','noplot');
   l=1;
   while (timebase(l)~=0)
      l=l+1;
   end
   xc1=x(l-25:l+25);
   % xc1(51)=xc1(50);
   tb1=timebase(l-25:l+25);
   
   %  [size(timebase) timebase(1) timebase(size(timebase)]
   %
   figure(1)
   m=lnum-fnum+1;
   if (k<=25)
      if m<=2 
         subplot(2,1,k+1)
      elseif m<=4
         subplot(2,2,k+1)
      elseif m<=6
         subplot(3,2,k+1)
      elseif m<=8
         subplot(2,4,k+1)
      elseif m<=9
         subplot(3,3,k+1)
      elseif m<=16
         subplot(4,4,k+1)
      elseif m<=20
         subplot(5,4,k+1)
      elseif m<=25
         subplot(5,5,k+1)
      end 
   end
   plot(tb1,xc1,'k-')
   [m,j]=max(xc1);
   maxl(k+1)=j;
   top=round(m + 1);
   axis([tb1(1) tb1(51) -0.5 top]);
   title([int2str(ua) ',' int2str(ub) ' '  filename]);
   %
   % find centroid and plot it
   cs=cumsum(xc1);
   i=1;
   while (cs(i)<=((cs(51))/2))
      i=i+1;
   end
   if(cs(i)-(cs(51)/2)<=(xc1(i))/2)
      i=i-1;
   end
   cenl(k+1)=i;
   csc=zeros(1,51);
   csc=csc-1;
   csc(i)=csc(i)+0.5+((top+0.5)/10);
   hold on
   stairs(tb1,csc,'r-')
   hold off
   %
   % work on excess correlation page
   %figure(2)
   %m=lnum-fnum+1;
   %if (k<=16)
   %   if m<=2 
   %      subplot(2,1,k+1)
   %   elseif m<=4
   %      subplot(2,2,k+1)
   %   elseif m<=6
   %      subplot(3,2,k+1)
   %   elseif m<=8
   %      subplot(2,4,k+1)
   %   elseif m<=9
   %      subplot(3,3,k+1)
   %   elseif m<=16
   %      subplot(4,4,k+1)
   %   elseif m<=20
   %      subplot(5,4,k+1)
   %   elseif m<=25
   %      subplot(5,5,k+1)      
   %   end 
   %end
   %[x,timebase,av,sd,sx,stime,sav]=dxcorr(eval(dn1),eval(dn2),'binwidth',binw);
   %xc2=x(l-25:l+25);
   %avc2=av(l-25:l+25);
   %sdc2=sd(l-25:l+25);
   % scale pictures appropriately
   %hi(1)=1.1*max(xc2-avc2);
   %hi(2)=2.2*max(sdc2);
   %top2=max(hi);
   %bot2=-hi(2);
   %axis([tb1(1) tb1(51) bot2 top2]);
   %title([int2str(ua) ',' int2str(ub) ' '  filename]);
   % 
   % find 3bin sums around zero time, around max time, around centroid time.
   zers(k+1)=sum(xc1(25:27));
   if(j==1)
      j=2;
   end
   if(j==51)
      j=50;
   end
   maxs(k+1)=sum(xc1(j-1:j+1));
   cens(k+1)=sum(xc1(i-1:i+1));
   %
   k=k+1;
   %clear d1,d2,d3,st,x,timebase,xc1,tb1;
end
%end of loop through the several files.
%
% plot the several sum counts
figure(3)
subplot(2,1,1)
%si=[fnum:lnum];
%si=input('[ Enter the actual orientation angles ]: ');
si=inputdlg('Enter the Orientation angles:','XCor Analysis',1,{'-4 -3 -2 -1 0 1 2 3 4'});
si=str2num(char(si));
plot(si,zers,'-',si,maxs,'--',si,cens,'-.')
vmax=[max(zers) max(maxs) max(cens)];
%axis([fnum lnum 0 (max(vmax)+1)])
axis([si(1) si(length(si)) 0 (max(vmax)+1)])
title(['Cells ' int2str(ua) ',' int2str(ub) ': xcor sums at zero(-), max(--), centroid(-.)']);
%xlabel([bfname ' extension']);
xlabel('Orientation Angle (deg)')
%
% plot the locations of centroid and maximum
%figure(3)
subplot(2,1,2)
plot(si,(maxl-26)*binw,'-',si,(cenl-26)*binw,'--')
axis([si(1) si(length(si)) tb1(1) tb1(51)])
title(['Cells ' int2str(ua) ',' int2str(ub) ': xcor time of maximum (-) and centroid (--)'])
%xlabel([bfname ' extension']);
xlabel('Orientation Angle (deg)')
ylabel('XCor Time (ms)')
grid on
%
