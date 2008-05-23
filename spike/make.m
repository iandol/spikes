function make()
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

disp('Compiling direct method code.');
fixpath(['mex' args 'info/direct/directbin.c info/direct/DirectBinComp.c info/direct/direct_mx.c' common_files]);
fixpath(['mex' args 'info/direct/directcondcat.c info/direct/direct_mx.c' common_files]); 
fixpath(['mex' args 'info/direct/directcondformal.c info/direct/direct_mx.c' common_files]); 
fixpath(['mex' args 'info/direct/directcondtime.c info/direct/direct_mx.c' common_files]); 
fixpath(['mex' args libs 'info/direct/directcountcond.c info/direct/DirectCountComp.c info/direct/direct_mx.c' common_files entropy_files]); 
fixpath(['mex' args libs 'info/direct/directcountclass.c info/direct/DirectCountComp.c info/direct/direct_mx.c' common_files entropy_files]); 
fixpath(['mex' args libs 'info/direct/directcounttotal.c info/direct/DirectCountComp.c info/direct/direct_mx.c' common_files entropy_files]); 

disp('Compiling metric space method code.');
fixpath(['mex' args 'info/metric/metricopen.c info/metric/MetricOpenComp.c info/metric/metric_mx.c' common_files]);
fixpath(['mex' args 'info/metric/metricdist.c info/metric/MetricDistSingleQComp.c info/metric/MetricDistSingleQKComp.c info/metric/MetricDistAllQComp.c info/metric/MetricDistAllQKComp.c info/metric/MetricDistCommonQKComp.c info/metric/metric_mx.c' common_files]);
fixpath(['mex' args 'info/metric/metricclust.c info/metric/MetricClustComp.c info/metric/metric_mx.c' common_files]);

disp('Compiling binless method code.');
fixpath(['mex' args 'info/binless/binlessopen.c info/binless/BinlessOpenComp.c info/binless/binless_mx.c' common_files]);
fixpath(['mex' args 'info/binless/binlesswarp.c info/binless/BinlessWarpComp.c info/binless/binless_mx.c' common_files]);
fixpath(['mex' args 'info/binless/binlessembed.c info/binless/BinlessEmbedComp.c info/binless/binless_mx.c' common_files]);
fixpath(['mex' args libs 'info/binless/binlessinfo.c info/binless/BinlessInfoComp.c info/binless/binless_mx.c shared/MatrixToHist2DComp.c shared/Info2DComp.c' common_files entropy_files]);

disp('Preparing example data files.');
% Prepare data files
cd data;

% Get a list of the stap files
stap_list = dir('*.stap');
num_files = size(stap_list,1);

% For each stap file
for file_idx = 1:num_files
  % Get the basename
  [temp,baseflip] = strtok(fliplr(stap_list(file_idx).name),'.');
  base = fliplr(baseflip);
  fid=fopen([base 'stap'],'r');

  % Read in the stap file and replace the datafile string
  datafile_full_path = [pwd filesep base 'stad'];
  idx = 1;
  done_flag=0;
  while(done_flag==0)
    line{idx} = fgets(fid);
    if(line{idx}==-1)
      done_flag=1;
    else
      line2{idx} = strrep(line{idx},'DATAFILE_FULL_PATH',datafile_full_path);
      idx = idx+1;
    end
  end
  num_lines = idx-1;
  fclose(fid);
  
  % Write the stam file
  fid=fopen([base 'stam'],'w');
  for idx=1:num_lines
    fprintf(fid,'%s',line2{idx});
  end
  fclose(fid);
end
cd ..;
%}

disp('Finished.');

function fixpath(in)

eval(strrep(in,'/',filesep));
