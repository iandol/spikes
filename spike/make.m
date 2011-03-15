function make(varargin)
%MAKE Compile functions in the Spike Train Analysis Toolkit.
%   MAKE compiles the necessary functions in the Spike Train Analysis
%   Toolkit. This m-file shares some similarities with the GNU make
%   utility in its basic operation and options. Namely, a particular
%   MEX file will be compiled only if it doesn't already exist, or if
%   its modification date is older than the modification date of any
%   of its dependencies.
%
%   Additionally, the following options are permitted, passed on the
%   command line as with GNU make or in functional form as individual
%   string arguments (note that in Octave prior to version 3.2 you
%   must first give the command "mark_as_command make" or use the
%   functional form):
%
%   -B, --always-make Unconditionally compile all MEX files.
%   -Dname[=value] Define a symbol name (and optional value) to the C
%      preprocessor (see also MEX).
%   -g Compile MEX files with debug symbols.
%   -h, --ignore-header-files Do not consider the modification date
%      of the header files.
%   -n, --just-print, --dry-run, --recon Print the commands that
%      would be executed, but do not execute them.
%
%   Specific goals or targets may also be specified to compile a
%   particular portion of the toolkit. If no goal is specified, then
%   all goals will be compiled. The currently available goals are
%   (multiple goals may be passed):
%
%   all: Compiles all code and prepares data (default goal).
%   input: Compiles input code.
%   shared: Compiles shared code.
%   direct: Compiles direct method code.
%   metric: Compiles metric space method code.
%   binless: Compiles binless method code.
%   ctwmcmc: Compiles ctwmcmc method code.
%   data: Prepares data.
%
%   After the toolkit has been compiled, you may use the following
%   goals to check and install the toolkit:
%
%   check: Checks that all toolkit functions work as expected (runs
%      demo/staverify).
%   install: "Installs" the toolkit by adding and saving the toolkit
%      path to your pathdef (may not work on some systems - please
%      save path manually).
%
%   Examples:
%      make
%         Conditionally compiles the whole toolkit.
%      make -B
%         Unconditionally compiles the whole toolkit.
%      make -g -B ctwmcmc
%         Unconditionally compiles ctwmcmc method code with debug
%         symbols (w/o -B may not give desired result).
%      make --just-print
%         Print the commands that would be executed to conditionally
%         compile the whole toolkit.
%      make('-n','--always-make','binless')
%         Functional form to print the commands that would be
%         executed to compile all binless methods.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

cd(fileparts(mfilename('fullpath'))); %switch to base directory

%%%%% Enumerate Files %%%%%

% Developers will need to add new files to the variables in this
% section, and/or modify the mex_files variable as necessary to direct
% the compilation and linking of the MEX files (see details below).

common_files = fixpath({'input/input_c.c'
                        'input/input_mx.c'
                        'shared/gen_c.c'
                        'shared/gen_mx.c'
                        'shared/sort_c.c'});

entropy_files = fixpath({'entropy/entropy_bub_c.c'
                         'entropy/entropy_bub_mx.c'
                         'entropy/entropy_c.c'
                         'entropy/entropy_chaoshen_c.c'
                         'entropy/entropy_jack_c.c'
                         'entropy/entropy_ma_c.c'
                         'entropy/entropy_mx.c'
                         'entropy/entropy_nsb_c.cpp'
                         'entropy/entropy_nsb_mx.cpp'
                         'entropy/entropy_plugin_c.c'
                         'entropy/entropy_tpmc_c.c'
                         'entropy/entropy_tpmc_mx.c'
                         'entropy/entropy_ww_c.c'
                         'entropy/entropy_ww_mx.c'
                         'entropy/variance_boot_c.c'
                         'entropy/variance_boot_mx.c'
                         'entropy/variance_jack_c.c'
                         'shared/hist_c.c'
                         'shared/hist_mx.c'});

header_files = fixpath({'entropy/entropy_c.h'
                        'entropy/entropy_mx.h'
                        'input/input_c.h'
                        'input/input_mx.h'
                        'shared/gen_c.h'
                        'shared/gen_mx.h'
                        'shared/hist_c.h'
                        'shared/hist_mx.h'
                        'shared/sort_c.h'
                        'shared/toolkit_c.h'
                        'shared/toolkit_mx.h'});

binless_headers = fixpath({'info/binless/binless_c.h' 'info/binless/binless_mx.h'});
ctwmcmc_headers = fixpath({'info/ctwmcmc/ctwmcmc_c.h' 'info/ctwmcmc/ctwmcmc_mx.h'});
direct_headers = fixpath({'info/direct/direct_c.h' 'info/direct/direct_mx.h'});
metric_headers = fixpath({'info/metric/metric_c.h' 'info/metric/metric_mx.h'});

binless_files = {'info/binless/binless_mx.c'};
ctwmcmc_files = {'info/ctwmcmc/ctwmcmc_c.cpp' 'info/ctwmcmc/ctwmcmc_mx.cpp'};
direct_files = {'info/direct/direct_mx.c'};
metric_files = {'info/metric/metric_mx.c'};

% The following variable, mex_files, contains the information
% necessary to create each of the MEX files in the STAToolkit. Each
% column contains a required piece of the necesary information:
% (1) the relative path to the primary file (with full file name),
% (2) a flag to allow linking with shared libraries (e.g., GSL),
% (3) a flag to allow linking with the common_files (see above),
% (4) a flag to allow linking with the entropy_files (see above),
% (5) a cell array of additional files to compile and link,
% (6) and a cell array of additional header files.
% Note that toolkit-wide header files (see header_files above) are
% included by default. Only developers should modify this list.
mex_files = {'info/binless/binlessembed.c'    0 1 0 {'info/binless/BinlessEmbedComp.c' binless_files{:}} binless_headers;
             'info/binless/binlessinfo.c'     1 1 1 {'info/binless/BinlessInfoComp.c' 'shared/MatrixToHist2DComp.c' 'shared/Info2DComp.c' binless_files{:}} binless_headers;
             'info/binless/binlessopen.c'     0 1 0 {'info/binless/BinlessOpenComp.c' binless_files{:}} binless_headers;
             'info/binless/binlesswarp.c'     0 1 0 {'info/binless/BinlessWarpComp.c' binless_files{:}} binless_headers;

             'info/ctwmcmc/ctwmcmcbridge.cpp' 1 1 1 {'info/ctwmcmc/CTWMCMCSampleComp.cpp' 'info/ctwmcmc/CTWMCMCTreeComp.cpp' ctwmcmc_files{:}} ctwmcmc_headers;
             'info/ctwmcmc/ctwmcmcsample.cpp' 1 1 1 {'info/ctwmcmc/CTWMCMCSampleComp.cpp' ctwmcmc_files{:}} ctwmcmc_headers;
             'info/ctwmcmc/ctwmcmctree.cpp'   1 1 0 {'info/ctwmcmc/CTWMCMCTreeComp.cpp' ctwmcmc_files{:}} ctwmcmc_headers;

             'info/direct/directbin.c'        0 1 0 {'info/direct/DirectBinComp.c' direct_files{:}} direct_headers;
             'info/direct/directcondcat.c'    0 1 0 direct_files direct_headers;
             'info/direct/directcondformal.c' 0 1 0 direct_files direct_headers;
             'info/direct/directcondtime.c'   0 1 0 direct_files direct_headers;
             'info/direct/directcountclass.c' 1 1 1 {'info/direct/DirectCountComp.c' direct_files{:}} direct_headers;
             'info/direct/directcountcond.c'  1 1 1 {'info/direct/DirectCountComp.c' direct_files{:}} direct_headers;
             'info/direct/directcounttotal.c' 1 1 1 {'info/direct/DirectCountComp.c' direct_files{:}} direct_headers;

             'info/metric/metricclust.c'      0 1 0 {'info/metric/MetricClustComp.c' metric_files{:}} metric_headers;
             'info/metric/metricdist.c'       0 1 0 {'info/metric/MetricDistAllQComp.c' 'info/metric/MetricDistAllQKComp.c' 'info/metric/MetricDistCommonQKComp.c' 'info/metric/MetricDistSingleQComp.c' 'info/metric/MetricDistSingleQKComp.c' metric_files{:}} metric_headers;
             'info/metric/metricopen.c'       0 1 0 {'info/metric/MetricOpenComp.c' metric_files{:}} metric_headers;

             'input/multisitearray.c'         0 1 0 {} {};
             'input/multisitesubset.c'        0 1 0 {} {};
             'input/staread.c'                0 1 0 {} {};

             'shared/entropy1d.c'             1 1 1 {} {};
             'shared/entropy1dvec.c'          1 1 1 {'shared/Entropy1DVecComp.c'} {};
             'shared/info2d.c'                1 1 1 {'shared/Info2DComp.c'} {};
             'shared/infocond.c'              1 1 1 {'shared/InfoCondComp.c' 'shared/Entropy1DVecComp.c'} {};
             'shared/matrix2hist2d.c'         1 1 1 {'shared/MatrixToHist2DComp.c'} {}};
mex_files(:,1) = fixpath(mex_files(:,1)); %note column 5 will fixpath when used (below)


%%%%% Parse Inputs %%%%%
CONDITIONAL = true;
HEADERS = true;
JUSTPRINT = false;
COMPILE = [];
DATA = false;
args = {'-DTOOLKIT' ,'-I/usr/local/include/','-L/usr/local/lib/'}; %developers may need to add arguments that cannot be passed as input
if ispc %add dynamic libraries and set extension for compiled object files
	libs = {};
	obj = 'obj';
else
	libs = {'-lgsl' '-lgslcblas'};
	obj = 'o';
end
for i=1:length(varargin) %handle varargin
	if strcmp(varargin{i},'all')
		COMPILE = 1:size(mex_files,1);
		DATA = true;
	elseif strcmp(varargin{i},'binless')
		COMPILE = union(COMPILE,1:4); %indices to mex_files (see above)
		DATA = DATA | false;
	elseif strcmp(varargin{i},'ctwmcmc')
		COMPILE = union(COMPILE,5:8); %indices to mex_files (see above)
		DATA = DATA | false;
	elseif strcmp(varargin{i},'direct')
		COMPILE = union(COMPILE,[8:14 24]); %indices to mex_files (see above)
		DATA = DATA | false;
	elseif strcmp(varargin{i},'metric')
		COMPILE = union(COMPILE,[15:17 23 25]); %indices to mex_files (see above)
		DATA = DATA | false;
	elseif strcmp(varargin{i},'input')
		COMPILE = union(COMPILE,18:20); %indices to mex_files (see above)
		DATA = DATA | false;
	elseif strcmp(varargin{i},'shared')
		COMPILE = union(COMPILE,21:25); %indices to mex_files (see above)
		DATA = DATA | false;
	elseif strcmp(varargin{i},'data')
		DATA = true;
	elseif strcmp(varargin{i},'-B') || strcmp(varargin{i},'--always-make')
		CONDITIONAL = false;
	elseif strcmp(varargin{i},'-h') || strcmp(varargin{i},'--ignore-header-files')
		HEADERS = false;
	elseif strcmp(varargin{i},'-n') || strcmp(varargin{i},'--just-print') || strcmp(varargin{i},'--dry-run') || strcmp(varargin{i},'--recon')
		JUSTPRINT = true;
	elseif strcmp(varargin{i},'-g') || (length(varargin{i})>1 && strcmp(varargin{i}(1:2),'-D'))
		args = [args varargin(i)];
	elseif strcmp(varargin{i},'check')
		cd demo;
		staverify;
		cd ..;
		return;
	elseif strcmp(varargin{i},'install')
		addpath(pwd);
		savepath;
		return;
	else
		warning(['Unrecognized option: ' varargin{i}]);
	end
end
if isempty(COMPILE) && ~DATA %no goal was specified (default all)
	COMPILE = 1:size(mex_files,1);
	DATA = true;
end


%%%%% Compile and Link %%%%%
specific_obj = {}; %collect list of compiled object files for cleanup
if ~isempty(COMPILE);
	if JUSTPRINT
		disp_fflush('MEX file compilation instructions.');
	else
		disp_fflush('Creating MEX files.');
	end
end
for i=COMPILE
	%check dependencies
	[path name] = fileparts(mex_files{i,1});
	target_name = [name '.' mexext];
	target = dir(target_name);
	if ~isempty(target) && CONDITIONAL
		target = fixdatenum(target);
		dependencies = fixdatenum(dir(mex_files{i,1}));
		if mex_files{i,3} %get common files
			if ~exist('common_dep','var')
				common_dep = struct([]);
				for j=1:length(common_files)
					common_dep = [common_dep fixdatenum(dir(common_files{j}))];
				end
			end
			dependencies = [dependencies common_dep];
		end
		if mex_files{i,4} %get entropy files
			if ~exist('entropy_dep','var')
				entropy_dep = struct([]);
				for j=1:length(entropy_files)
					entropy_dep = [entropy_dep fixdatenum(dir(entropy_files{j}))];
				end
			end
			dependencies = [dependencies entropy_dep];
		end
		if ~isempty(mex_files{i,5}) %get specific files
			files = fixpath(mex_files{i,5});
			specific_dep = struct([]);
			for j=1:length(files)
				specific_dep = [specific_dep fixdatenum(dir(files{j}))];
			end
			dependencies = [dependencies specific_dep];
		end
		if HEADERS %get header files
			if ~exist('header_dep','var') %get global header files
				header_dep = struct([]);
				for j=1:length(header_files)
					header_dep = [header_dep fixdatenum(dir(header_files{j}))];
				end
			end
			dependencies = [dependencies header_dep];
			if ~isempty(mex_files{i,6}) %get specific header files
				files = mex_files{i,6};
				specific_head = struct([]);
				for j=1:length(files)
					specific_head = [specific_head fixdatenum(dir(files{j}))];
				end
				dependencies = [dependencies specific_head];
			end
		end
		
		%continue (skip compile) if target is current
		if all(target.datenum>[dependencies.datenum])
			disp_fflush(['   ' target_name ' is already current.']);
			continue;
		end
	end

	%compile and link
	specific_obj = [specific_obj; getobj(mex_files(i,1),obj)];
	if mex_files{i,2} %link with dynamic libraries
		mexargs = [args libs];
	else
		mexargs = args;
	end
	references = {}; %collect list of references to compile and/or link
	if mex_files{i,3} %get common objects
		if ~exist('common_obj','var')
			compile(JUSTPRINT,'-c',mexargs{:},common_files{:});
			common_obj = getobj(common_files,obj);
		end
		references = [references; common_obj];
	end
	if mex_files{i,4} %get entropy objects
		if ~exist('entropy_obj','var')
			compile(JUSTPRINT,'-c',mexargs{:},entropy_files{:});
			entropy_obj = getobj(entropy_files,obj);
		end
		references = [references; entropy_obj];
	end
	if ~isempty(mex_files{i,5}) %get specific objects
		files = fixpath(mex_files{i,5}');
		objects = getobj(files,obj);
		for j=1:length(files)
			if exist(objects{j},'file')
				files{j} = objects{j};
			end
		end
		references = [references; files];
		specific_obj = [specific_obj; objects]; %collect object files
	end
	compile(JUSTPRINT,mexargs{:},mex_files{i,1},references{:});
end


%%%%% Clean Up %%%%%
if exist('OCTAVE_VERSION','builtin')
	if exist('common_obj','var')
		for i=1:length(common_obj)
			delete(common_obj{i});
		end
	end
	if exist('entropy_obj','var')
		for i=1:length(entropy_obj)
			delete(entropy_obj{i});
		end
	end
	specific_obj = unique(specific_obj);
	for i=1:length(specific_obj)
		delete(specific_obj{i});
	end
else
	delete(['*.' obj]);
end


%%%% Prepare Data %%%%
if DATA
	if JUSTPRINT
		disp_fflush('Example data files would be prepared.');
	else
		disp_fflush('Preparing example data files.');
		cd data;

		%get a list of the stap files
		stap_list = dir('*.stap');
		num_files = length(stap_list);

		for i=1:num_files
			[path name] = fileparts(stap_list(i).name); %get the basename

			%read in the stap file and replace the datafile string
			fid = fopen(stap_list(i).name,'r');
			datafile_full_path = [pwd filesep name '.stad'];
			idx = 1;
			done_flag = 0;
			while done_flag==0
				line{idx} = fgets(fid);
				if line{idx}==-1
					done_flag = 1;
				else
					line2{idx} = strrep(line{idx},'DATAFILE_FULL_PATH',datafile_full_path);
					idx = idx+1;
				end
			end
			num_lines = idx-1;
			fclose(fid);

			%write the stam file
			fid = fopen([name '.stam'],'w');
			for idx=1:num_lines
				fprintf(fid,'%s',line2{idx});
			end
			fclose(fid);
		end
		cd ..;
	end
end
disp_fflush('Finished.');


%%%%% Subfunctions %%%%%
function compile(justprint,varargin)
%COMPILE Compiles and/or prints compilation instructions.

msg = ['   mex' sprintf(' %s',varargin{:})];

if justprint
	disp_fflush(msg);
else
	disp_fflush([msg(1:70) ' ...']);
	mex(varargin{:});
end

function names = getobj(names,ext)
%GETOBJ Gets compiled object names from cell array of names and ext.

for i=1:length(names)
	[path name] = fileparts(names{i});
	if exist('OCTAVE_VERSION','builtin')
		names{i} = [path filesep name '.' ext]; %Octave places object file in same directory as its source file
	else
		names{i} = [name '.' ext]; %Matlab places object file in current directory
	end
end

function dir_struct = fixdatenum(dir_struct)
%FIXDATENUM Fixes datenum field in structure returned by DIR.

%add datenum field for older versions of Matlab or fix them in Octave
if ~isfield(dir_struct,'datenum') || exist('OCTAVE_VERSION','builtin')
	for i=1:length(dir_struct)
		dir_struct(i).datenum = datenum(dir_struct(i).date);
	end
end

function strings = fixpath(strings)
%FIXPATH Fixes the path separation character for Windows machines.

if exist('OCTAVE_VERSION','builtin')
	slash = filesep;
	for i=1:length(strings)
		strings{i} = strrep(strings{i},'/',slash);
	end
else
	strings = strrep(strings,'/',filesep);
end

function disp_fflush(string);
%DISP_FFLUSH Display string to screen and flush if necessary.
disp(string);
if exist('OCTAVE_VERSION','builtin')
	fflush(stdout);
end
