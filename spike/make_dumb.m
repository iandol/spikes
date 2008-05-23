function make_dumb()
%MAKE Compile functions in the Spike Train Analysis Toolkit.
%   MAKE compiles the necessary functions in the Spike Train
%   Analysis Toolkit.

%
%  Copyright 2006, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
common_files=' shared/sort_c.c shared/gen_c.c shared/gen_mx.c input/input_c.c input/input_mx.c';
entropy_files=' shared/hist_c.c shared/hist_mx.c entropy/entropy_mx.c entropy/entropy_c.c entropy/entropy_plugin_c.c entropy/entropy_tpmc_c.c entropy/entropy_tpmc_mx.c entropy/entropy_jack_c.c entropy/entropy_ma_c.c entropy/entropy_bub_mx.c entropy/entropy_bub_c.c entropy/entropy_chaoshen_c.c entropy/entropy_ww_c.c entropy/entropy_ww_mx.c entropy/variance_jack_c.c entropy/variance_boot_mx.c entropy/variance_boot_c.c';

if(ispc)
  libs = ' ';
else
  libs = ' -lgsl -lgslcblas ';
end
args = ' -DTOOLKIT ';

disp('Compiling shared code.');
fixpath(['mex' args 'input/multisitearray.c' common_files]);
fixpath(['mex' args 'input/multisitesubset.c' common_files]);
fixpath(['mex' args 'input/staread.c' common_files]);
fixpath(['mex' args libs 'shared/matrix2hist2d.c shared/MatrixToHist2DComp.c' ...
         common_files entropy_files]);
fixpath(['mex' args libs 'shared/entropy1d.c' common_files entropy_files]);
fixpath(['mex' args libs 'shared/entropy1dvec.c shared/Entropy1DVecComp.c' common_files entropy_files]);
fixpath(['mex' args libs 'shared/info2d.c shared/Info2DComp.c' ...
         common_files entropy_files]);
fixpath(['mex' args libs 'shared/infocond.c shared/InfoCondComp.c shared/Entropy1DVecComp.c ' ...
         common_files entropy_files]); 

disp('Finished.');

function fixpath(in)

eval(strrep(in,'/',filesep));
