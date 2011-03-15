function stawrite(X,filebase)
%STAWRITE Write STAD and STAM files from an input data structure. 
%   STAWRITE(X,BASE) writes STAD and STAM files from an input
%   data structure X. BASE is the path and filename (without
%   the .stad and .stam extension) of the output files. 
% 
%   See also STAREAD.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
metafile = sprintf('%s.stam',filebase);
datfile = sprintf('%s.stad',filebase);

meta_id = fopen(metafile,'w');
dat_id = fopen(datfile,'w');

%%%%%%%%%%%%%%%%%%

% Strip off the path, leaving only the name of the file
% the filename is the string that follows the last slash
curdir=pwd;
[t,r]=strtok(fliplr(datfile),filesep);
datfilename = fliplr(t);
datfiledir = fliplr(r);
if(isempty(datfiledir))
  datfiledir = '.';
end
cd(datfiledir);
absdir = pwd;

fprintf(meta_id,'# Data filename\n');
fprintf(meta_id,'datafile=%s%s%s;\n',absdir,filesep,datfilename);

fprintf(meta_id,'#\n# Site metadata\n');
for n=1:X.N
  if isfield(X.sites(n),'si_unit')
      si_unit = X.sites(n).si_unit;
      si_prefix = X.sites(n).si_prefix;
  else
      si_unit = 'none';
      si_prefix = 1;
  end
  fprintf(meta_id,'site=%d; label=%s; recording_tag=%s; time_scale=%.15f; time_resolution=%.15f; si_unit=%s; si_prefix=%.15f;\n', ...
          n,char(X.sites(n).label),char(X.sites(n).recording_tag),X.sites(n).time_scale,X.sites(n).time_resolution,si_unit,si_prefix);
end

%%%%%%%%%%%%%%%%%%

fprintf(meta_id,'#\n# Category metadata\n');
for m=1:X.M
  fprintf(meta_id,'category=%d; label=%s;\n',m,char(X.categories(m).label));
end
 
%%%%%%%%%%%%%%%%%%

fprintf(meta_id,'#\n# Trace metadata\n');
p_total=1;
for m=1:X.M
  for p=1:X.categories(m).P
    for n=1:X.N
      fprintf(meta_id,'trace=%d; catid=%d; trialid=%d; siteid=%d; start_time=%.15f; end_time=%.15f;\n', ...
              p_total,m,p,n,X.categories(m).trials(p,n).start_time,X.categories(m).trials(p,n).end_time);
      
      for q=1:X.categories(m).trials(p,n).Q
        fprintf(dat_id,'%.15f ',X.categories(m).trials(p,n).list(q));
      end
      fprintf(dat_id,'\n');
      p_total = p_total+1;
    end
  end
end
  
fclose(meta_id);
fclose(dat_id);

cd(curdir);
