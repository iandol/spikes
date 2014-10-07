function stereo( sep )
%STEREO         View current figure as 3-D cross-fusable stereo pair
%
%Usage: STEREO
%       STEREO( SEPARATION )
%       STEREO( 'REDRAW' )
%       STEREO( 'OFF' )
%
%       This function resizes the current figure, duplicates the current
%       axis, and then changes the VIEW transformation matrix such that
%       the left and right images have a visual SEPARATION (default is
%       five degrees).
%
%       Crossing your eyes so that the two images overlap will result
%       in a stereo image.
%
%       Invoking with the 'OFF' option will (approximately) restore the
%       figure to its original state.
%
%       Invoking with the 'REDRAW' option will just redraw the right-hand
%       copy of the image.  This allows you change aspects of the left-
%       hand image (e.g., add titles, change the view), and then simply
%       update the other half.
%
%       Note: this file uses the undocumented COPYOBJ command.
%
%       This code is copyright (c) 1993,1995, Dave Caughey, and may be
%       used or disributed for any non-commercial use.  Credit is requested
%       for use in non-commercial publications.
%
%       E-mail: caughey@engr.uvic.ca
%       Dept. of Electrical and Computer Engineering
%       University of Victoria,  Victoria, B.C, Canada
%
%       If you like this m-file send me an e-mail (it's an ego thing).

global vsep

redraw = 0;
if nargin == 0,
    vsep = 2.5;
elseif isstr( sep ),
    if strcmp( sep, '_off' ),
        pos = get( gcf, 'pos' );
        pos = pos + [pos(3)/4 0 -pos(3)/2 0];
        set( gcf, 'pos', pos );
        for h=get(gcf,'children')',
            if ( strcmp( get( h, 'userdata' ), 'copy' ) ),
                delete( h );
            end;
        end;
        pos = get( gca, 'pos' );
        set( gca, 'pos', pos+[pos(1) 0 pos(3) 0] );
        [az el] = view;
        view( [az-vsep el] );
        return
    elseif strcmp( sep, 'off' ),
        stereo _off
        return;
    elseif strcmp( sep, 'on' ),
        vsep = 2.5;
    elseif strcmp( sep, 'redraw' ),
        redraw = 1;
    end;
else,
    vsep = sep;
end;

p = gca;

if redraw == 0,
    for h=get(gcf,'children')',
        if strcmp( get( h, 'userdata' ), 'copy' ),
            stereo _off
        end;
    end;

    pos = get( gcf, 'pos' );
    pos = pos + [-pos(3)/2 0 pos(3) 0];
    set( gcf, 'pos', pos );

    pos = get( gca, 'pos' );
    pos = pos + [-pos(1)/2 0 -pos(3)/2 0];
    set( gca, 'pos', pos );

    [az el] = view;
    a=viewmtx( az+vsep, el, 45 ); view(a); %drawnow;

    axes( 'position', pos+[0.5 0 0 0] );
    set( gca, 'userdata', 'copy' );
end;

%
%  Delete the child axis' objects
%
for h = get(gcf,'children')',
    if strcmp( get(h,'userdata'), 'copy' )
        delete( get(h,'children')' );
        axes( h );
    end;
end;

%
%  Copy all the elements of the parent axis to the child axis
%
for h = get(p,'children')',
    hcopy = copyobj( h, 'legacy' );
    set( hcopy, 'Parent', gca );
end;

%
% Copy the parent axis attributes to the child axis
%
title( get(get(p,'title'),'string') );
xlabel( get(get(p,'xlabel'),'string') );
ylabel( get(get(p,'ylabel'),'string') );
zlabel( get(get(p,'zlabel'),'string') );
if redraw == 0,
    a=viewmtx( az-vsep, el, 45 ); view(a); drawnow;
else,
    h = gca;
    axes(p);
    [az el] = view;
    a=viewmtx( az-vsep, el, 45 ); view(a); drawnow;
    axes(h);
    a=viewmtx( az+vsep, el, 45 ); view(a);
end;
%
% After the view has been transformed, axis properties may have
% changed.  So copy the original values
%
set( gca,'xgrid', get(p,'xgrid'));
set( gca,'ygrid', get(p,'ygrid'));
set( gca,'zgrid', get(p,'zgrid'));
set( gca, 'xLim', get(p,'xLim') );
set( gca, 'yLim', get(p,'yLim') );
set( gca, 'zLim', get(p,'zLim') );
set( gca, 'xtick', get(p,'xtick') );
set( gca, 'ytick', get(p,'ytick') );
set( gca, 'ztick', get(p,'ztick') );
set( gca, 'xticklabels', get(p,'xticklabels') );
set( gca, 'yticklabels', get(p,'yticklabels') );
set( gca, 'zticklabels', get(p,'zticklabels') );
axes( p );
