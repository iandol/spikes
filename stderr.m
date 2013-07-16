% Plots mean and error choosable by switches
%
% [mean,error] = stderr(data,type)
%
% Switches: SE 2SE SD 2SD 3SD V FF CV AF

function [avg,error] = stderr(data,type,onlyerror)

avg=nanmean(data);
if nargin<3
    onlyerror=0;
end
if nargin<2
    type='SE';
end

if size(type,1)>1
	type=reshape(type,1,size(type,1));
end

if size(data,1) > 1 && size(data,2) > 1
	nvals = size(data,1);
else
	nvals = length(data);
end

switch(type)
   
case 'SE'
   err=nanstd(data);
   error=sqrt(err.^2/nvals);  
case '2SE'
   err=nanstd(data);
   error=sqrt(err.^2/nvals);
   error = error*2;
case 'SD'
   error=nanstd(data);
case '2SD'
   error=(nanstd(data))*2;
case '3SD'
   error=(nanstd(data))*3;
case 'V'
   error=nanstd(data).^2;
case 'F' 
	if max(data)==0
		error=0;
	else
		error=nanvar(data)/nanmean(data);
	end
case 'C'
	if max(data)==0
		error=0;
	else
		error=nanstd(data)/nanmean(data);
	end
case 'A'
	if max(data)==0
		error=0;
	else
		error=nanvar(diff(data))/(2*nanmean(data));
	end
end

if onlyerror==1
	avg=error;
end