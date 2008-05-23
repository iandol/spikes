function [H,T] = BARXY(x,y,CellLabels, normx,normy,logy, gap,box,Renderer)
%function [H,T] = BARXY(x,y,CellLabels, normx,normy,logy, gap,box,Renderer)
%
%PURPOSE: Plot clusters/cells of x-y data as 2D bar graphs: stacked bar format in
%         the x-direction, grouped bar format in the y-direction.
%--------------------------------------------------------------------------------
% NOTES: 1) Use [] to skip over input variable(s) and accept the default value(s)
%        2) Positive x-values yield solid-color bars color-coded by the y-values 
%           Negative x-values yield hollow black bars
%        3) Delimit data cells in the input data (x and y vectors) with zeros
%           (see the default demonstration dataset for an example)
%-------------------------------------------------------------------------------------
%INPUT: 
%          x: vector of cell x-values ....................... default: demo
%          y:   "     "   "  y   "    ....................... default: demo
% CellLabels: cell group labels
%             e.g. str2mat('cell1label','cell2label') ....... default: ['A';'B';,'C',...]
%      normx: x-axis normalization flag: 0 - no, 1 - yes .... default: 0
%      normy: y-axis normalization flag:
%             0 or [] - no normalization
%            'c' - cell-by-cell normalization 
%            Any other alphanumeric - global 
%               normalization across cells .................. default: 0       
%       logy: base-10 logarithmic Y-axis 0 - no, 1 - yes .... default: 0
%        gap: gap between cells ............................. default: 1
%        box: axes property - enclosing box: off|on ......... default: 'off'
%   Renderer: [ painters | zbuffer | OpenGL ] ............... default: 'OpenGL'
%OUTPUT:
%          H: axes handle
%          T: bar height multiplier label handles (normalized bars)
%----------------------------------------------------------------------- jdc 8-Sep-98
%        [H,T] = BARXY(x,y,CellLabels, normx,normy,logy, gap,box,Renderer)
%
%    Demo:  BARXY; <cr>   
%   Usage:  cellabels = str2mat('Cell #1','Cell #2','Cell #3','Cell #4');
%           BARXY(xvec,yvec,cellabels,1,[],1); <cr>


if exist('x')~=1, x = []; end
if isempty(x),                %...................................... demo data
   x = [ -1  -1  .6 .3 .1  0    .4 .4 .2 0   .2  .3 .5  .3 -1 -.4 .4 .1 .5 .1 .1];
   y = [0.6 0.5 1.2 .5 .25 0   1.1 .8 .2 0   .9  .5 .15 .8 .7  .5 .6 .4 .3 .2 .1];
end   
if exist('logy'    )~=1,   logy = 0;       elseif isempty(logy),       logy = 0;  end
if exist('normy'   )~=1,  normy = 0;       elseif isempty(normy),     normy = 0;   end
if exist('normx'   )~=1,  normx = 0;       elseif isempty(normx),     normx = 0;    end
if exist('gap'     )~=1,    gap = 1;       elseif isempty(gap),         gap = 1;     end
if exist('box'     )~=1,    box = 'off';   elseif isempty(box),         box = 'off';  end
if exist('Renderer')~=1,Renderer='OpenGL'; elseif isempty(Renderer),Renderer='OpenGL'; end


if exist('CellLabels')~=1, CellLabels = []; end
if isempty(CellLabels),
   CellLabels = ['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';...
                 'N';'O';'P';'Q';'R';'S';'T';'U';'V';'W';'X';'Y';'Z'];  
end


if length(x)~=length(y),
   fprintf(['\n DATA ERROR: The x and y vectors must be the same length.\n',7])
   return
end   
figure('Units','normal','Position',[.5 .45 .5 .5]);
H = axes;
yi = find(x~=0);
mny = min(y(yi));
mxy = max(y(yi));
hilo = mxy-mny;
basey = 0;
if normy & isempty(findstr('c',lower(normy))),
   normy = 'g';
   gnorm = abs(max([mxy -mny]));
   y = y/gnorm;
   mny = min(y(yi));
   mxy = max(y(yi));
   hilo = mxy-mny;
end   
if logy, %......................................... set y-axis minimum for semilogy plot
   basey = 10^floor(log10(mny - 0.05*(mxy-mny)));
end   
if x(length(x))~=0,
   x = [x 0];
   y = [y 0];
end
BCstart = 1;
BCbreaks = find(x==0);
Xwidth = zeros(size(BCbreaks));
if normx, %....................................................... normalize the x-data
   for I = 1:length(BCbreaks), 
      Irange = BCstart:BCbreaks(I)-1;
      xIrange = x(Irange);
      x(Irange) = xIrange/max([sum(xIrange(find(xIrange>0))) -sum(xIrange(find(xIrange<0)))]);
      BCstart = BCbreaks(I)+1;
   end      
end      
%---------------------------------------------------------------------------------------------
BCstart = 1;
xx = [0 0 0 0];
xxs = xx;
ymax = 0;
for I = 1:length(BCbreaks), % ........................................ process bar clusters 
   X = x(BCstart:BCbreaks(I)-1);
   Y = y(BCstart:BCbreaks(I)-1);
   if findstr('c',lower(normy)), % ............................... normalize individual cells
      mny = min(Y);
      mxy = max(Y);
      cnorm(I) = abs(max([mxy -mny]));
      Y = Y/cnorm(I);
      mny = min(Y);
      mxy = max(Y);
      hilo = mxy-mny;
   end   
   BCstart = BCbreaks(I)+1;
   xx(4) = xx(4) + gap;   
   xxs(4) = xx(4); 
   iPos = find(sign(X)>=0);
   CellMarker(I) = xx(4);
   for i = 1:length(iPos), %.............................................. draw filled bars   
      xx = [  0    0         X(iPos(i))  X(iPos(i))] + xx(4);
      yy = [basey Y(iPos(i)) Y(iPos(i))  basey];
      if hilo,
         cs = (yy(2)-mny)/hilo;
      else
         cs = 1;
      end   
      fill(xx,yy,[cs*(2-cs) 1-cs^2 4*cs*(1-cs)]), hold on
   end      
   iNeg = find(sign(X)<0);
   for i = 1:length(iNeg), %.............................................. draw empty bars
      xxs = -[  0    0         X(iNeg(i))  X(iNeg(i))] + xxs(4);
      yys =  [basey Y(iNeg(i)) Y(iNeg(i))  basey];
%      if hilo,
%         cs = (yys(2)-mny)/hilo;
%      else
%         cs = 1;
%      end   
       line(xxs,yys,'LineWidth',2,'Color','k'); %,'Color',[cs*(2-cs) 1-cs^2 4*cs*(1-cs)])
       hold on
   end                                                     
   xx(4) = max([xx(4) xxs(4)]);
   CellMarker(I) = mean([CellMarker(I) xx(4)]);
   ymax = max([ymax Y]);
end
set(gca,'Xtick',CellMarker,'XtickLabel',CellLabels)
%---------------------------------------------------------------------------------------------
xlim = get(gca,'Xlim');
ylim = get(gca,'Ylim');
ylim = [basey ylim(2)];
if logy,
   set(gca,'YScale','log')
   Lylim = log10([ylim(1) ymax]);
   texy = 10.^(Lylim(1) + [1.03 1.09 1.15]*diff(Lylim));
else
   texy = ylim(1) + [1.03 1.09 1.15]*diff([ylim(1) ymax]);   
end
set(gca,'Ylim',[basey texy(3)])
if findstr('g',lower(normy)),
   set(gca,'Ytick',[0 .2 .4 .6 .8 1],'YtickLabel',[0 .2 .4 .6 .8 1]')
   T = text(gap,texy(1),sprintf('Global Multiplier: %4.3f', gnorm),...
      'FontSize',8,'HorizontalAlignment','left','VerticalAlignment','bottom');
elseif findstr('c',lower(normy)),
   set(gca,'Ytick',[0 .2 .4 .6 .8 1],'YtickLabel',[0 .2 .4 .6 .8 1]')
   T = text(gap,texy(2),sprintf('Cell Multipliers:'),... 
       'FontSize',8,'HorizontalAlignment','left','VerticalAlignment','bot');
   T2 = text(CellMarker,texy(1)*ones(size(CellMarker)),num2str(cnorm'),...
        'FontSize',8,'HorizontalAlignment','right','VerticalAlignment','bot');
   T = [T; T2];     
end   
line(gap/2+[0 xx(4)],[1 1]*basey,'Color','k')
set(get(gca,'XLabel'),'VerticalAlignment','top')
set(gca,'Xlim',gap/2+[0 xx(4)],'Box',box)
if findstr(lower(Renderer),'zbuffer'),
   set(gcf,'Renderer','zbuffer')
   L = light;
   set(L,'Color',[1 1 1])
elseif findstr(lower(Renderer),'opengl'),
   set(gcf,'Renderer','OpenGL')
end
hold off