function scalefig(h,sc)
%SCALEFIG Scale figure window for demos.
% SCALEFIG(H,SC) scales figure windows for demo plots. H is the
% figure handle and SC is the scaling factor.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

if(length(sc)==1)
  sc=sc*ones([1 2]);
end

a = get(h,'position');
b(3) = sc(1)*a(3);
b(4) = sc(2)*a(4);
x_tmp = b(3) - a(3);
y_tmp = b(4) - a(4);
b(1) = a(1) - (x_tmp/2);
b(2) = a(2) - (y_tmp/2);
set(h,'position',b);
