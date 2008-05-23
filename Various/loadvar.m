function variable=loadvar(matfile,varname)
%LOADVAR Read the value of a single variable from a mat-file.
%
%       variable=LOADVAR(matfile,varname)
%
%       Output argument:
%       variable = the variable to take the value of the loaded one
%
%       Input arguments:
%       matfile = name of the mat-file. Default extension: .mat
%       varname = name of the variable in the mat-file
%           if varname is 'who' or 'whos', the command will be executed.
%
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given.
%
%       Usage: variable=loadvar(matfile,varname);
%       Example: itlimit=loadvar('inpchans.ebn','itmax');
%
%       See also: SAVEVAR.

%       Copyright (c) I. Kollar, 1990-96
%       Copyright (c) Vrije Universiteit Brussel, Dienst ELEC, 1990-96
%       All rights reserved.
%       Last modified: 04-Oct-1996

if nargin<2, error('not enough input arguments'), end
if isempty(varname), error('varname is empty'), end
if ~isstr(varname), error('varname is not a string'), end
donotusethisnamemf=matfile;
donotusethisnamev=varname;
load(donotusethisnamemf,'-mat')
clear donotusethisnamemf varname ans
if strcmp(donotusethisnamev,'who')
  clear donotusethisnamev matfile, eval('clear variable')
  who
elseif strcmp(donotusethisnamev,'whos')
  clear donotusethisnamev matfile, eval('clear variable')
  whos
else
  if exist(donotusethisnamev)==0
    error(['Variable ''',donotusethisnamev,''' does not exist in file ''',...
        matfile,''''])
  end
  eval(['variable=',donotusethisnamev,';'])
end
%%%%%%%%%%%%%%%%%%%%%%%% end of loadvar %%%%%%%%%%%%%%%%%%%%%%%%
