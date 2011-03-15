function staversion()
%STAVERSION Return the version and revision number of the Spike Train Analysis Toolkit.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
fid=fopen('VERSION');
version = fscanf(fid,'%s');
fclose(fid);
%%% Read in VERSION file

fid=fopen('REVISION');
revision = fscanf(fid,'%s');
fclose(fid);
%%% Read in REVISION file

disp(sprintf('Spike Train Analysis Toolkit Version %s Revision %s',version,revision));
