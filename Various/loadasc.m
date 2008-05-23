function [data,datline,header,comments,comline]=loadasc(filename,ASCIItype)
%LOADASC Load data from an ASCII file into a variable with given name.
%
%       [data,datline,header,comments,comline]=LOADASC(filename,ASCIItype)
%
%       Output arguments:
%       data = data vector or array
%           If in the file each number is in a separate line, data will be a
%           vector. If each line contains several numbers (the number of
%           elements in each line must be the same), separated by spaces or
%           tabs, and ASCIItype is 'flat', data will be a corresponding matrix.
%           If ASCIItype is 'array', and each array line contains the same
%           number of elements, comments are filtered out, and the array of
%           numbers will be assigned to data.
%       datline = lines in ASCII file, which contain corresponding rows of data
%       header = first comment lines until first noncomment line (string array)
%       comments = comments as a string array
%       comline = lines in ASCII file, which contain the corresponding comment
%                 lines 
%
%       Input arguments:
%       filename = name of the file
%       ASCIItype = type of the file
%           If the value of ASCIItype is 'flat', the ASCII file may contain
%           no text, if it is 'text' or 'array', then comments may be included,
%           preceded in each line by the character %.
%           For 'string', data contains an array of the strings of the numbers,
%           rather than the vector of their values.
%       Default value of ASCIItype: 'text'.
%
%       The file has to be somewhere within the path of MATLAB.
%
%       Usage: 
%           [data,datline,header,comments,comline]=loadasc(filename,ASCIItype);
%       Example: fprintf('lasctest.txt','%.0f %%N\n%.4e, %.4e %%amp1\n',1,5,6)
%                type lasctest.txt, v3=loadasc('lasctest.txt')
%
%       See also: LOAD.

%       Copyright (c) I. Kollar, 1990-96
%       Copyright (c) Vrije Universiteit Brussel, Dienst ELEC, 1990-96
%       All rights reserved.
%       Last modified: 04-Oct-1996

if nargin<2, ASCIItype='text'; end
point=find(filename=='.');
if ~(isempty(point)),
  filevar=filename(1:point(1)-1);
  ext=filename(point(1)+1:length(filename));
else
  filevar=filename;
  ext=[];
end
%
%Attempt follows to get rid of path description if it was given.
c=[computer,'  '];
if strcmp(c(1:3),'MAC')
  %get rid of subdirectory names on a Macintosh
  nali=find(ext==':'); %extension should not contain ':'
  if length(nali)>0, error(['Extension ''',ext,''' not allowed']), end
  spi=find(filename==' '); %spaces (not allowed in Matlab)
  if length(spi)>0, error(['File name ''',filename,''' contains spaces']), end
  bsi=find(filevar==':');
  if ~isempty(bsi)
    filevar=filevar(bsi(length(bsi))+1:length(filevar));
  end
  if length(filevar)>19,
    error(['Filename ''',filevar,''' is longer than 19 characters'])
  elseif length(filevar)==0
    error(['File name ''',filename,''' ends by '':'''])
  end
elseif strcmp(c(1:2),upper('pc'))
  %get rid of subdirectory names on a PC
  nali=find(ext=='\'); %extension should not contain '\'
  if length(nali)>0, error(['Extension ''',ext,''' not allowed']), end
  bsi=find(filevar=='\');
  if ~isempty(bsi)
    filevar=filevar(bsi(length(bsi))+1:length(filevar));
  end
  if length(filevar)==0
    error(['File name ''',filename,''' ends by ''\'''])
  end
  %filevar may be longer than 8 characters: Matlab creates the new
  %variable named after the filename given in the load command
  %(without extension), even if the DOS truncates it to 8 characters.
else %Unix assumed
  nali=find(ext=='/'); %extension should not contain '/'
  if length(nali)>0, error(['Extension ''',ext,''' not allowed']), end
  bsi=find(filevar=='/');
  if ~isempty(bsi)
    filevar=filevar(bsi(length(bsi))+1:length(filevar));
  end
  if length(filevar)==0
    error(['File name ''',filename,''' ends by ''/'''])
  end
end
%
if strcmp(filevar,'filevar')==1
  %avoid conflict with the name 'filevar'
  filevarsave=filevar;
end
tab=setstr(9);
lf=setstr(10);
cr=setstr(13);
if strcmp(ASCIItype,'text')|strcmp(ASCIItype,'array')...
        |strcmp(ASCIItype,'string')
  %ASCII file with comments
  fid=fopen(filename,'r');
  dch=setstr(fread(fid,inf,'uchar'));
  fclose(fid);
  dch=[dch(:)',cr,lf]; %Row vector
  ind=find(dch==cr);
  indlf=find(dch(ind+1)==lf);
  dch(ind(indlf)+1)=''; %eliminate lf's from cr-lf pairs
  indlf=find(dch==lf);
  dch(indlf)=setstr(13*ones(length(indlf),1)); %elim lf-s, leave cr-s only
  ind=find((dch=='%')|(dch==cr)); %comments (with ending cr-s)
  indp=find(dch(ind)=='%');
  indpp=find(dch(ind(indp+1))=='%'); %two percent marks in a line
  ind(indp(indpp+1))='';
  indp=find(dch(ind)=='%');
  if nargout>2
    comments=setstr(32*ones(length(indp),max(ind(indp+1)-ind(indp))-1));
    comline=zeros(length(indp),1);
  else
    comline=[];
  end
  for i=length(indp):-1:1 %eliminate comments
    if nargout>2
      comml=dch(ind(indp(i)):ind(indp(i)+1)-1);
      comments(i,1:length(comml))=comml;
      comline(i)=sum(dch(ind(1:indp(i)+1))==cr);
    end
    dch(ind(indp(i)):ind(indp(i)+1)-1)='';
  end %for i
  ih=min(find(diff([0;comline;inf])>1));
  if nargout>2
    header=comments(1:ih-1,:);
    if ~isempty(header), header=header(:,1:max(find(~all(header==' ')))); end
  end
  %
  %Change commas to spaces
  dchcom=dch;
  ind=find(dch==','); dch(ind)=setstr(' '*ones(1,length(ind)));
  %
  %data=sscanf(dch,'%g');
  ind=find(dch==cr);
  lineno=1; datalno=0;
  if strcmp(ASCIItype,'text')|strcmp(ASCIItype,'array')
    data=zeros(length(ind),1); lch=0; %last processed char
    if nargout>1, datline=data; end
    while lch<length(dch)
      icr=min(find(dch==cr)); %first cr
      [data0,datano,sscanferr,nextchar]=feval('sscanf',dch(lch+1:icr),'%g');
      if ~isempty(sscanferr)
        disp(['WARNING! sscanf error ''',sscanferr,''' in loadasc'])
        fprintf('   Illegal characters in line, like letters, symbols, etc.\n')
        fprintf(['   Line %.0f: ',dchcom(lch+1:icr),'\n'],lineno)
      end
      if strcmp(ASCIItype,'text')&~isempty(data0)
        if length(data)-datalno<length(data0(:))
          data(datalno+50*length(data0))=0;
        end
        data(datalno+[1:length(data0)])=data0(:);
        if nargout>1
          datline(datalno+[1:length(data0)])=lineno*ones(length(data0),1);
        end
        datalno=datalno+length(data0);
      elseif strcmp(ASCIItype,'array')&~isempty(data0)
        if datalno==0, data=zeros(size(data,1),length(data0)); end
        if size(data,2)==size(data0,1)
          data(datalno+1,:)=data0(:)';
          datalno=datalno+1;
          if nargout>1, datline(datalno)=lineno; end
        else
          error([sprintf(['Number of elements in line %.0f is not the same',...
                ' as in earlier lines, %.0f:\n'],lineno,size(data,2)),...
                dchcom(lch+1:icr)])
        end
      end
      dch(icr)=' '; dchcom(icr)=' '; lch=icr;
      lineno=lineno+1;
    end %while
    data=data(1:datalno,:);
  elseif strcmp(ASCIItype,'string')
    data=''; lch=0;
    if nargout>1, datline=zeros(length(ind),1); end
    while lch<length(dch)
      while any(dch(lch+1)==[' ',tab]), lch=lch+1; end
      nfch=lch+1; %first character of number
      if any(dch(lch+1)=='-+'), lch=lch+1; end
      while any(dch(lch+1)==['0':'9']), lch=lch+1; end
      if dch(lch+1)=='.', lch=lch+1; end
      while any(dch(lch+1)==['0':'9']), lch=lch+1; end
      if any(dch(lch+1)=='eE'), lch=lch+1; end
      if any(dch(lch+1)=='-+'), lch=lch+1; end
      while any(dch(lch+1)==['0':'9']), lch=lch+1; end
      if lch>=nfch
        data=str2mat(data,dch(nfch:lch));
        if nargout>1, datline(size(data,1)-1)=lineno; end
      end
      if dch(lch+1)==cr, lch=lch+1; lineno=lineno+1; end
      if lch<nfch, error('endless loop in loadasc'), end
    end %while
    data(1,:)='';
    datalno=size(data,1);
  end
  if nargout>1, datline=datline(1:datalno); end
  %if (nargout>2)&~isempty(datline), header=comments(1:datline(1)-1,:); end
elseif strcmp(ASCIItype,'flat')
  if nargout>2
    header=''; comments=''; com2dat=[];
    disp('Warning! Header cannot be taken from flat ASCII file by loadasc')
  end
  load(filename)
  if exist('filevarsave') %the given file name is just 'filevar'
    eval(['data=',filevarsave,';']) %move loaded vector into 'data'
  else
    eval(['data=',filevar,';']) %move loaded vector into 'data'
  end
else %unknown value of ASCIItype
  error(['''',ASCIItype,''' is not allowed for ASCIItype'])
end
%%%%%%%%%%%%%%%%%%%%%%%% end of loadasc %%%%%%%%%%%%%%%%%%%%%%%%
