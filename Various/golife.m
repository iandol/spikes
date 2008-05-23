function golife(n,m)

global Go ijcell ijlive ijdead man move Pointer Hfigure Himage Htitle

if nargin == 1 & isequal(n,'help')
   fprintf('   GoLife is another "game of life" based on the rules of the Chinese   \n')
   fprintf('   board game Go, arguably the best game ever devised by mankind.       \n')
   fprintf('   This version of GoLife is not intended to be an AI opponent.         \n')
   fprintf('   Rather it is written to see how a Go system evolves by itself.       \n')
   fprintf('   The system can be interpreted as a 2D universe being colonized       \n')
   fprintf('   by two species competing for dominance.  To start, type "golife"     \n')
   fprintf('   in the command window for usage information.  Type "golife help"     \n')
   fprintf('   for this message.  A board size of 19x19 is ok for a typical         \n')
   fprintf('   pentium 133 computer to handle.  A bigger board requires more        \n')
   fprintf('   computing power.  There are two game modes: auto and manual,         \n')
   fprintf('   which can be toggled by right-clicking the mouse.  In auto mode,     \n')
   fprintf('   the system randomly generates each move and automatically evolves    \n')
   fprintf('   according to the rules of Go.  Although predictable, the long-term   \n')
   fprintf('   pattern displayed by a large system (> 9x9) is quite interesting.    \n')
   fprintf('   In manual mode, left-clicking an unoccupied square makes a move.     \n')
   fprintf('   Manual mode can be used by two human players against each other,     \n')
   fprintf('   or as a way to inflict some "divine" interference when desired.      \n')
   fprintf('   Grid lines can be turned on and off by shift-left-clicking.          \n')
   fprintf('   Due to Matlab''s rendering of graphics, the image flicks when        \n')
   fprintf('   the grid lines are turned on.  It is recommended to turn off         \n')
   fprintf('   the grid lines in auto mode.  Because of the intensive graphics,     \n')
   fprintf('   reducing the figure window to a smaller size will speed up a large   \n')
   fprintf('   board.  To restart, double-click the board.  For more information    \n')
   fprintf('   about Go, go to http://www.usgo.org/.                                \n')
   fprintf('   (Tested under Matlab 5.2 on DEC/Unix and PC/Windows95.)              \n')
   fprintf('                                                                        \n')
   fprintf('   Jake Fan, 11/28/98                                                   \n')
   fprintf('   root@paradise.svec.uh.edu                                            \n\n')
   return, end

if nargin == 1 & isequal(n,'bye!')
   warndlg([   'Copyright 1998, by Jake Fan'    char(10)...
               'golife@paradise.svec.uh.edu'    char(10) char(10)...
               'Go Info: http://www.usgo.org'   ],['GoLife(' num2str(length(Go)-2) ') - bye!'])
   return, end

if nargin == 0 | ~isnumeric(n) | n < 1
   fprintf(   'Usage: golife(n[,1]), where n is the size of the board (19 for a normal board)\n')
   fprintf(   '       golife(n) starts in auto mode, while golife(n,1) starts in manual mode \n')
   fprintf(   '       for additional information, type in the command line: golife help      \n\n')
   return, end

if gcbo & n == inf
   if isequal(get(Hfigure,'SelectionType'),'normal')
      move = get(gca,'CurrentPoint');
      move = round([move(1,2) move(1,1)]);
      uiresume, end
   if isequal(get(Hfigure,'SelectionType'),'alt')
      move = [1 1];
      man = ~man; if ~man
      uiresume, end, end
   if isequal(get(Hfigure,'SelectionType'),'extend')
      if isequal(get(Hfigure,'Renderer'),'zbuffer')
      set(Hfigure,'Renderer','painters')
      elseif isequal(get(Hfigure,'Renderer'),'painters')
      set(Hfigure,'Renderer','zbuffer'), end, end
   if isequal(get(Hfigure,'SelectionType'),'open')
      n = length(Go)-2;
      Go = zeros(n+2,n+2);
      Go(1,:) = inf; Go(n+2,:) = inf;
      Go(:,1) = inf; Go(:,n+2) = inf;
      set(Himage,'CData',Go+1), drawnow, end
   return, end

if nargin == 1 man = 0; else man = m; end


rand('state',sum(100*clock))
n = fix(n);
Go = zeros(n+2,n+2);
Go(1,:) = inf; Go(n+2,:) = inf;
Go(:,1) = inf; Go(:,n+2) = inf;
Hfigure = figure('Name','GoLife','NumberTitle','off','MenuBar','figure',...
                 'Pointer','custom','PointerShapeHotSpot',[8 8],...
                 'Renderer','zbuffer','DeleteFcn','golife bye!');
colormap([1 1 1; 1 0 0; 0 0 1; 0 0 0])
SetPointer
Himage = image(Go+1,'ButtonDownFcn','golife(inf)');
set(gca,'XColor',[.8 .8 .8],'YColor',[.8 .8 .8],...
        'XTickLabel','','YTickLabel','',...
        'XTick',1:n+2,'YTick',1:n+2,...
        'GridLine','-')
Htitle = title(''); axis image, grid on, drawnow
xlabel(['left-click: make a move (in manual mode)   '...
        'right-click: toggle mode' char(10)...
        'shift-left-click: toggle gridline   '...
        'double-click: restart'],...
        'Color',[.6 .6 .6])

life = 1; while 1 kill = 0;

   life1 = 0; life2 = 0; for k = 1:(n+2)*(n+2)
   if Go(k) == 1 life1 = life1 + 1; end
   if Go(k) == 2 life2 = life2 + 1; end, end
   if man set(Hfigure,'Name',['GoLife(' num2str(n) ') - manual'])
   else set(Hfigure,'Name',['GoLife(' num2str(n) ') - auto']), end
   set(Htitle,'String',['Red(cross): ' num2str(life1) '   Blue(shield): ' num2str(life2)])
   set(gcf,'PointerShapeCData',Pointer(:,:,3-life))
   if man uiwait, end

   l = 0; for k = 1:(n+2)*(n+2) if ~Go(k) l = l + 1; end, end
   k = 0; l = ceil(rand*l); while l k = k + 1; if ~Go(k) l = l - 1; end, end
   if man l = (move(2)-1)*(n+2) + move(1); if Go(l) ~= inf k = l; end, end
   if ~Go(k) life = 3-life; Go(k) = life; end
   set(Himage,'CData',Go+1), drawnow

   ijlive = []; ijdead = []; i = rem(k,n+2); j = ceil(k/(n+2));
   ijcell = []; CheckLife(i,j); ijdead = [ijdead; ijcell];
   ijcell = []; if i-1 < n CheckLife(i+1,j); ijdead = [ijdead; ijcell]; end
   ijcell = []; if i-1 > 1 CheckLife(i-1,j); ijdead = [ijdead; ijcell]; end
   ijcell = []; if j-1 < n CheckLife(i,j+1); ijdead = [ijdead; ijcell]; end
   ijcell = []; if j-1 > 1 CheckLife(i,j-1); ijdead = [ijdead; ijcell]; end
   l = 0; if ijdead l = length(ijdead(:,1)); end
   for k = 1:l if Go(ijdead(k,1),ijdead(k,2)) == 3-life
      kill = 1; Go(ijdead(k,1),ijdead(k,2)) = 0; end, end
   for k = 1:l if Go(ijdead(k,1),ijdead(k,2)) == life & ~kill
      kill = 0; Go(ijdead(k,1),ijdead(k,2)) = 0; end, end
   set(Himage,'CData',Go+1), drawnow, end


function CheckLife(i,j)

global Go ijcell ijlive ijdead

if ijdead & ~all(ijdead(:,1)-i | ijdead(:,2)-j) | ...
   ~all([Go(i,j) Go(i+1,j) Go(i-1,j) Go(i,j+1) Go(i,j-1)]) | ...
   0; ijlive = [ijlive; ijcell]; ijcell = []; return, end
if ijlive & ~all(ijlive(:,1)-i | ijlive(:,2)-j) | ...
   ijlive & ~all(ijlive(:,1)-(i+1) | ijlive(:,2)-j) & Go(i+1,j) == Go(i,j) | ...
   ijlive & ~all(ijlive(:,1)-(i-1) | ijlive(:,2)-j) & Go(i-1,j) == Go(i,j) | ...
   ijlive & ~all(ijlive(:,1)-i | ijlive(:,2)-(j+1)) & Go(i,j+1) == Go(i,j) | ...
   ijlive & ~all(ijlive(:,1)-i | ijlive(:,2)-(j-1)) & Go(i,j-1) == Go(i,j) | ...
   0; ijlive = [ijlive; ijcell]; ijcell = []; return, end

ijcell = [ijcell; i j];

if ijcell & all(ijcell(:,1)-(i+1) | ijcell(:,2)-j) & Go(i+1,j) == Go(i,j) CheckLife(i+1,j); end
if ijcell & all(ijcell(:,1)-(i-1) | ijcell(:,2)-j) & Go(i-1,j) == Go(i,j) CheckLife(i-1,j); end
if ijcell & all(ijcell(:,1)-i | ijcell(:,2)-(j+1)) & Go(i,j+1) == Go(i,j) CheckLife(i,j+1); end
if ijcell & all(ijcell(:,1)-i | ijcell(:,2)-(j-1)) & Go(i,j-1) == Go(i,j) CheckLife(i,j-1); end


function SetPointer()

global Pointer

Pointer(:,:,1) = [ NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN  1   1   1   1   1   1   1   1   1   1   1  NaN NaN NaN   
                   NaN NaN  1   2   2   2   2   1   2   2   2   2   1  NaN NaN NaN   
                   NaN NaN  1   2  NaN  2   2   1   2   2  NaN  2   1  NaN NaN NaN   
                   NaN NaN  1   2   2  NaN NaN  1  NaN NaN  2   2   1  NaN NaN NaN   
                   NaN NaN  1   2   2  NaN NaN  1  NaN NaN  2   2   1  NaN NaN NaN   
                   NaN NaN  1   1   1   1   1   1   1   1   1   1   1  NaN NaN NaN   
                   NaN NaN  1   2   2  NaN NaN  1  NaN NaN  2   2   1  NaN NaN NaN   
                   NaN NaN  1   2   2  NaN NaN  1  NaN NaN  2   2   1  NaN NaN NaN   
                   NaN NaN  1   2  NaN  2   2   1   2   2  NaN  2   1  NaN NaN NaN   
                   NaN NaN  1   2   2   2   2   1   2   2   2   2   1  NaN NaN NaN   
                   NaN NaN  1   1   1   1   1   1   1   1   1   1   1  NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ];

Pointer(:,:,2) = [ NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN  1   1   1   1   1   1   1   1   1   1   1  NaN NaN NaN   
                   NaN NaN  1   1   2   2   2   2   2   2   2   1   1  NaN NaN NaN   
                   NaN NaN  1   2   1   2   2  NaN  2   2   1   2   1  NaN NaN NaN   
                   NaN NaN  1   2   2   1  NaN NaN NaN  1   2   2   1  NaN NaN NaN   
                   NaN NaN  1   2   2  NaN  1  NaN  1  NaN  2   2   1  NaN NaN NaN   
                   NaN NaN  1   2  NaN NaN NaN  1  NaN NaN NaN  2   1  NaN NaN NaN   
                   NaN NaN  1   2   2  NaN  1  NaN  1  NaN  2   2   1  NaN NaN NaN   
                   NaN NaN  1   2   2   1  NaN NaN NaN  1   2   2   1  NaN NaN NaN   
                   NaN NaN  1   2   1   2   2  NaN  2   2   1   2   1  NaN NaN NaN   
                   NaN NaN  1   1   2   2   2   2   2   2   2   1   1  NaN NaN NaN   
                   NaN NaN  1   1   1   1   1   1   1   1   1   1   1  NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   
                   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ];


