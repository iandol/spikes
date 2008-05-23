function freezeColors(h)
% freezeColors  Lock colors of an image to current colors
%
%   Problem: There is only one colormap per figure. This function provides
%       an easy solution when images using different colomaps are desired
%       in the same figure.
%
%   Useful if you want different colormaps on same page. freezeColors will
%       freeze the colors of images in the current axis so that later 
%       changes to the colormap will not change the image. The original 
%       indexed image is saved, and can be restored by unfreezeColors,
%       making the image once again subject to change with the colormap.
%
%   Usage:
%       freezeColors works on gca, freezeColors(axh) works on axis axh
%
%   Example:
%       subplot(2,1,1); imagesc(X); colormap hot; freezeColors
%       subplot(2,1,2); imagesc(Y); colormap hsv etc...
%
%       Note: colorbars must be explicitly frozen
%           hc = colorbar; freezeColors(hc)
%       
%       see also unfreezeColors
%
%   JRI (iversen@nsi.edu) 3/23/05

if nargin < 1,
    h = gca;
end

imh = findobj(h, 'type','image'); %find all images in this axis
cmap = colormap;
cax = caxis;
nColors = size(cmap,1);

% convert image color indexes into colormap to true color data using 
%  current colormap
for hh = imh',
    cdata = get(hh,'cdata');
    scalemode = get(hh,'cdatamapping');
    
    if size(cdata,3) == 1, %it's an indexed image
        siz = size(cdata);
        %save original indexed data for use with unfreezeColors
        %  not sure how new saveappdata is, so provide userdata alternative
        try
            setappdata(hh, 'JRI_freezeColorsData', {cdata scalemode});
        catch
            if isempty(get(hh,'userdata')),
                set(hh,'userdata',{cdata scalemode})
            else
                warning('non-empty userdata on this image')
            end
        end
        
        %convert cdata to indexes into colormap
        if strcmp(scalemode,'scaled'),
            idx = ceil( (cdata - cax(1)) / (cax(2)-cax(1)) * nColors);
        else %direct mapping
            idx = cdata;
        end
        %clamp to [1, nColors]
        idx(idx<1) = 1;
        idx(idx>nColors) = nColors;
        
        %make true color image
        realcolor = [];
        for i = 1:3,
            c = cmap(idx,i);
            c = reshape(c,siz);
            realcolor(:,:,i) = c;
        end
        set(hh,'cdata',realcolor);
    end %if indexed images
end %loop on images

