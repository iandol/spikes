function make(varargin)
%MAKE Compile functions in the Spike Train Analysis Toolkit.
%   MAKE compiles the necessary functions in the Spike Train
%   Analysis Toolkit. This m-file shares some similarities
%   with the GNU make utility in its basic operation and
%   options. Namely, a particular MEX file will be compiled
%   only if it doesn't already exist, or if its modification
%   date is older than the modification date of any of its
%   dependencies.
%
%   Additionally, the following options are permitted
%   (passed on the command line as with GNU make or as
%   individual string arguments):
%
%   -B, --always-make Unconditionally compile all MEX files.
%   -h, --ignore-header-files Do not consider the modification
%      date of the header files.
%   -n, --just-print, --dry-run, --recon Print the commands
%      that would be executed, but do not execute them.
%   -Dname[=value] Define a symbol name (and optional value)
%      to the C preprocessor (see also mex).

%
%  Copyright 2009, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
global CONDITIONAL HEADERS JUSTPRINT;

CONDITIONAL = true;
HEADERS = true;
JUSTPRINT = false;
args = ' -L/usr/local/lib/ -I/usr/local/include/ -DTOOLKIT ';
for i=1:length(varargin)
    if strcmp(varargin{i},'-B') || strcmp(varargin{i},'--always-make')
        CONDITIONAL = false;
    end
    if strcmp(varargin{i},'-h') || strcmp(varargin{i},'--ignore-header-files')
        HEADERS = false;
    end
    if strcmp(varargin{i},'-n') || strcmp(varargin{i},'--just-print') || strcmp(varargin{i},'--dry-run') || strcmp(varargin{i},'--recon')
        JUSTPRINT = true;
    end
    if strcmp(varargin{i}(1:2),'-D')
        args = [args varargin{i} ' '];
    end
end

cd(fileparts(mfilename('fullpath'))); %switch to base directory

common_files=' shared/sort_c.c shared/gen_c.c shared/gen_mx.c input/input_c.c input/input_mx.c';
entropy_files=' shared/hist_c.c shared/hist_mx.c entropy/entropy_mx.c entropy/entropy_c.c entropy/entropy_plugin_c.c entropy/entropy_tpmc_c.c entropy/entropy_tpmc_mx.c entropy/entropy_jack_c.c entropy/entropy_ma_c.c entropy/entropy_bub_mx.c entropy/entropy_bub_c.c entropy/entropy_chaoshen_c.c entropy/entropy_ww_c.c entropy/entropy_ww_mx.c entropy/entropy_nsb_c.cpp entropy/entropy_nsb_mx.cpp entropy/variance_jack_c.c entropy/variance_boot_mx.c entropy/variance_boot_c.c';

if(ispc)
  libs = ' ';
else
  libs = ' -lgsl -lgslcblas ';
end

if JUSTPRINT
    disp('Shared code compilation instructions.');
else
    disp('Compiling shared code.');
end
fixpath(['mex' args 'input/multisitearray.c' common_files]);
fixpath(['mex' args 'input/multisitesubset.c' common_files]);
fixpath(['mex' args 'input/staread.c' common_files]);
fixpath(['mex' args libs 'shared/matrix2hist2d.c shared/MatrixToHist2DComp.c' common_files entropy_files]);
fixpath(['mex' args libs 'shared/entropy1d.c' common_files entropy_files]);
fixpath(['mex' args libs 'shared/entropy1dvec.c shared/Entropy1DVecComp.c' common_files entropy_files]);
fixpath(['mex' args libs 'shared/info2d.c shared/Info2DComp.c' common_files entropy_files]);
fixpath(['mex' args libs 'shared/infocond.c shared/InfoCondComp.c shared/Entropy1DVecComp.c ' common_files entropy_files]); 

if JUSTPRINT
    disp('Direct method code compilation instructions.');
else
    disp('Compiling direct method code.');
end
fixpath(['mex' args 'info/direct/directbin.c info/direct/DirectBinComp.c info/direct/direct_mx.c' common_files]);
fixpath(['mex' args 'info/direct/directcondcat.c info/direct/direct_mx.c' common_files]); 
fixpath(['mex' args 'info/direct/directcondformal.c info/direct/direct_mx.c' common_files]); 
fixpath(['mex' args 'info/direct/directcondtime.c info/direct/direct_mx.c' common_files]); 
fixpath(['mex' args libs 'info/direct/directcountcond.c info/direct/DirectCountComp.c info/direct/direct_mx.c' common_files entropy_files]); 
fixpath(['mex' args libs 'info/direct/directcountclass.c info/direct/DirectCountComp.c info/direct/direct_mx.c' common_files entropy_files]); 
fixpath(['mex' args libs 'info/direct/directcounttotal.c info/direct/DirectCountComp.c info/direct/direct_mx.c' common_files entropy_files]); 

if JUSTPRINT
    disp('Metric space method code compilation instructions.');
else
    disp('Compiling metric space method code.');
end
fixpath(['mex' args 'info/metric/metricopen.c info/metric/MetricOpenComp.c info/metric/metric_mx.c' common_files]);
fixpath(['mex' args 'info/metric/metricdist.c info/metric/MetricDistSingleQComp.c info/metric/MetricDistSingleQKComp.c info/metric/MetricDistAllQComp.c info/metric/MetricDistAllQKComp.c info/metric/MetricDistCommonQKComp.c info/metric/metric_mx.c' common_files]);
fixpath(['mex' args 'info/metric/metricclust.c info/metric/MetricClustComp.c info/metric/metric_mx.c' common_files]);

if JUSTPRINT
    disp('Binless method code compilation instructions.');
else
    disp('Compiling binless method code.');
end
fixpath(['mex' args 'info/binless/binlessopen.c info/binless/BinlessOpenComp.c info/binless/binless_mx.c' common_files]);
fixpath(['mex' args 'info/binless/binlesswarp.c info/binless/BinlessWarpComp.c info/binless/binless_mx.c' common_files]);
fixpath(['mex' args 'info/binless/binlessembed.c info/binless/BinlessEmbedComp.c info/binless/binless_mx.c' common_files]);
fixpath(['mex' args libs 'info/binless/binlessinfo.c info/binless/BinlessInfoComp.c info/binless/binless_mx.c shared/MatrixToHist2DComp.c shared/Info2DComp.c' common_files entropy_files]);

if JUSTPRINT
    disp('Example data files would be prepared.');
else
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
end

disp('Finished.');

function fixpath(in)
%FIXPATH Evaluate MEX compilation string.
%   FIXPATH(IN) Parses the input string IN and evaluates the compilation
%   command if the target is outdated.

global CONDITIONAL HEADERS JUSTPRINT;
header_files = {'entropy/entropy_c.h',
                'entropy/entropy_mx.h',
                'input/input_c.h',
                'input/input_mx.h',
                'shared/gen_c.h',
                'shared/gen_mx.h',
                'shared/hist_c.h',
                'shared/hist_mx.h',
                'shared/sort_c.h',
                'shared/toolkit_c.h',
                'shared/toolkit_mx.h'};

in = strrep(in,'/',filesep); %fix file separation character
[tok rem] = strtok(in,' ');
if CONDITIONAL && strcmp(tok,'mex') %string indicates a mex command
    [tok rem] = strtok(rem,' ');
    while strcmp(tok(1),'-') %skip options
        [tok rem] = strtok(rem,' ');
    end
    
    %get target and dependency names and modification dates
    [pathstr name ext] = fileparts(tok);
    target_name = [name '.' mexext]; 
    target = dir(target_name);
    if length(target) %MEX file already exists
        dependencies = dir(tok);
        while rem
            [tok rem] = strtok(rem,' ');
            dependencies(end+1) = dir(tok); %WARNING: this fails if tok doesn't exist
        end

        %get header files
        if HEADERS
            for i=1:length(header_files)
                headers(i) = dir(header_files{i});
            end
        end
        
        %add datenum field for older versions of Matlab
        if ~isfield(target,'datenum')
            target.datenum = datenum(target.date);
            for i=1:length(dependencies)
                dependencies(i).datenum = datenum(dependencies(i).date);
            end
            if HEADERS
                for i=1:length(headers)
                    headers(i).datenum = datenum(headers(i).date);
                end
            end
        end

        %return if target and (optionally) headers are current
        %NOTE: blindly assumes target and/or dependencies depend on all headers
        if all(target.datenum>[dependencies.datenum]) && (~HEADERS || all(target.datenum>[headers.datenum]))
            disp(['    ' target_name ' is already current.']);
            return;
        end
    end
end

%evaluate string
if JUSTPRINT
    disp(['    ' in]);
else
    disp(['    ' in(1:72) ' ...']);
    eval(in);
end
