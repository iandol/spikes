function [param1,param2,param3,param4,param5,param6,param7,param8,param9,param10]=get_head(filename,param_names);
% GET_HEAD Extract parameters from VDAQ blockfile.
% function param_list=get_head(param_names);
%
% Called with filename of a blockfile
% and a string containing a comma separated list of parameter names.
% Names are case-insensitive. For more info., 'type get_head'.
%
% Returns (up to 10) values of parameters from the header.
% Non-scalar parameters must be retreived one by one.
%
% Examples:
% [xsize,ysize]= get_head('sum10.d2a','framewidth,frameheight')
% get_head('sum3.a','creationdate')

fid=fopen(filename,'r','l');
if fid == -1,
	error(['Invalid filename: ',filename])
end
%%%%%%%%%%%%%%%%%% BEGIN DEFINITIONS OF VARIABLES %%%%%%%%%%%%%%%%%%

% DATA INTEGRITY 		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filesize				=fread(fid,1,'long');
checksum_header			=fread(fid,1,'long');
	% beginning with the lLen Header field

checksum_data			=fread(fid,1,'long');

% COMMON TO ALL DATA FILES 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lenheader			=fread(fid,1,'long');
versionid			=fread(fid,1,'float');
filetype			=fread(fid,1,'long');
	% RAWBLOCK_FILE          (11)
	% DCBLOCK_FILE           (12)
	% SUM_FILE               (13)

filesubtype			=fread(fid,1,'long');
	% FROM_VDAQ              (11)
	% FROM_ORA               (12)
	% FROM_DYEDAQ            (13)

datatype			=fread(fid,1,'long');
	% DAT_UCHAR     (11)
	% DAT_USHORT    (12)
	% DAT_LONG      (13)
	% DAT_FLOAT     (14)

sizeof				=fread(fid,1,'long');
	% e.g. sizeof(long), sizeof(float)

framewidth			=fread(fid,1,'long');
frameheight			=fread(fid,1,'long');
nframesperstim		=fread(fid,1,'long');
nstimuli			=fread(fid,1,'long');
initialxbinfactor	=fread(fid,1,'long');
	% from data acquisition
initialybinfactor	=fread(fid,1,'long');
	% from data acquisition

xbinfactor			=fread(fid,1,'long');
	% this file
ybinfactor			=fread(fid,1,'long');
	% this file

username			=setstr(fread(fid,32,'char'))';
recordingdate		=setstr(fread(fid,16,'char'))';
x1roi				=fread(fid,1,'long');
y1roi				=fread(fid,1,'long');
x2roi				=fread(fid,1,'long');
y2roi				=fread(fid,1,'long');

% LOCATE DATA AND REF FRAMES 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimoffs			=fread(fid,1,'long');
stimsize			=fread(fid,1,'long');
frameoffs			=fread(fid,1,'long');
framesize			=fread(fid,1,'long');
refoffs				=fread(fid,1,'long');
refsize				=fread(fid,1,'long');
refwidth			=fread(fid,1,'long');
refheight			=fread(fid,1,'long');

% Common to data files that have undergone some form of
% "compression" or "summing"
% i.e. The data in the current file may be the result of
%      having summed blocks 'a'-'f', frames 1-7
whichblocks			=fread(fid,16,'ushort');
whichframes			=fread(fid,16,'ushort');

% DATA ANALYSIS			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loclip				=fread(fid,1,'long');
hiclip				=fread(fid,1,'long');
lopass				=fread(fid,1,'long');
hipass				=fread(fid,1,'long');
operationsperformed	=setstr(fread(fid,64,'char'))';

% ORA-SPECIFIC			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
magnification		=fread(fid,1,'float');
gain				=fread(fid,1,'ushort');
wavelength			=fread(fid,1,'ushort');
exposuretime			=fread(fid,1,'long');
nrepetitions			=fread(fid,1,'long');
acquisitiondelay		=fread(fid,1,'long');
interstiminterval		=fread(fid,1,'long');
creationdate			=setstr(fread(fid,16,'char'))';
datafilename			=setstr(fread(fid,64,'char'))';
orareserved			=setstr(fread(fid,256,'char'))';


if filesubtype == 13,   %it's dyedaq file
  
  %  OIHEADER.H
  %  last revised 4.5.97 by Chaipi Wijnbergen for DyeDaq
  %  
  %  DyeDaq-specific
  includesrefframe =fread(fid,1, 'long');     % 0 or 1
  temp =fread(fid,128, 'char');
  listofstimuli=temp(1:max(find(temp~=0)))';  % up to first non-zero stimulus
  ntrials =fread(fid,1, 'long');
  scalefactor =fread(fid,1, 'long');          % bin * trials
  cameragain =fread(fid,1, 'short');         % shcameragain        1,   2,   5,  10
  ampgain =fread(fid,1, 'short');            % amp gain            1,   4,  10,  16,
                                             %                    40,  64, 100, 160,
                                             %                    400,1000
  samplingrate =fread(fid,1, 'short');       % sampling rate (1/x)
                                             %                     1,   2,   4,   8,
                                             %                     16,  32,  64, 128,
                                             %                     256, 512,1024,2048
  average =fread(fid,1, 'short');            % average             1,   2,   4,   8,
                                             %                    16,  32,  64, 128
  exposuretime =fread(fid,1, 'short');       % exposure time       1,   2,   4,   8,
                                             %                    16,  32,  64, 128,
                                             %                    256, 512,1024,2048
  samplingaverage =fread(fid,1, 'short');    % sampling average    1,   2,   4,   8,
                                             %                    16,  32,  64, 128
  presentaverage =fread(fid,1, 'short');
  framesperstim =fread(fid,1, 'short');
  trialsperblock =fread(fid,1, 'short');
  sizeofanalogbufferinframes =fread(fid,1, 'short');
  cameratrials=fread(fid,1, 'short');
  filler =setstr(fread(fid,106, 'char'))';
  
  dyedaqreserved =setstr(fread(fid,256, 'char'))';
else   % it's not dyedaq specific

  % VDAQ-SPECIFIC			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  includesrefframe		=fread(fid,1,'long');
  listofstimuli			=setstr(fread(fid,256,'char'))';
  nvideoframesperdataframe	=fread(fid,1,'long');
  ntrials				=fread(fid,1,'long');
  scalefactor			=fread(fid,1,'long');
  meanampgain			=fread(fid,1,'float');
  meanampdc			=fread(fid,1,'float');
  vdaqreserved			=setstr(fread(fid,256,'char'))';
end    % end of VDAQ specific

% USER-DEFINED			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  user				=setstr(fread(fid,256,'char'))';

% COMMENT			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
comment				=setstr(fread(fid,256,'char'))';
refscalefactor =fread(fid,1, 'long');          % bin * trials for reference

%%%%%%%%%%%%%%%%%%  END DEFINITIONS OF VARIABLES  %%%%%%%%%%%%%%%%%%

fseek(fid,0,1);            % go to EOF
actuallength=ftell(fid);   % report where EOF is in bytes

fclose(fid);

% do a quick consistency check for filesize
%[w,s]=unix(['ls -l ',filename]); 
	% s is result of ls -l, containing, among other things, file length

%if filesubtype ~= 13,   % dyedaq files have screwed up filesizes currently
  %  if isempty(findstr(s,int2str(filesize))),   % s ~includes correct filesize ?
%  if filesize ~= actuallength,
%    error(['Actual size of ',filename,' ~= filesize in header']);
%  end
%end

param_names=lower(param_names);
commas=findstr(param_names,',');
if nargout < 2,		% just return simple stuff
	% now set up parameter list to include requested variables
	comm=['param1=[',param_names,'];'];
	eval(comm);
	% we get weird stuff if we concatenate a string with a number
	if isstr(param1) & commas,   % see error on next line
		error('Supply output variables if one paramter is a string');
	end
else			% divide the parameters between the output variables
	if nargout ~= length(commas)+1,
	% make sure number of output variables = number of parameters requested
		error('Number of outputs must equal number of parameters');
	end
	commas=[0,commas,length(param_names)+1];
	for n=1:nargout
		comm=['param',int2str(n),'=',param_names(commas(n)+1:commas(n+1)-1),';'];
		eval(comm)
	end
end
