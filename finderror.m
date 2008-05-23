function errorval=finderror(x,type,mit,mxt,wrapped,burst)

% This function will find the error values for spike data
% generated by lsd (the 'RAW' data format)
% 
% errorval=finderror(x,type,mit,mxt,wrapped,burst)
%
% x = The data in 'raw' format (from lsd).
% type = The error type.
% mit,mxt = The times within which to find the error in milliseconds.
% wrapped = Whether the data is wrapped or not.
% burst = whether to look through all spikes or just burst spikes


mit=mit*10;   %need to define the limits
mxt=mxt*10-1;

if burst==0
   if wrapped==1 %wrapped is ON
      l=1;           
      for j=1:x.numtrials            
         for k=1:x.nummods
            s=x.trial(j).mod{k}-x.trial(j).modtimes(k);   %because it is wrapped
            m=find(s>mit & s<=mxt);
            val(l)=length(m);
            l=l+1;
         end
      end
      
   elseif wrapped==2   %wrapped is OFF
      l=1;
      a=[];      
      for j=1:x.numtrials                 
         for k=1:x.nummods
            s=x.trial(j).mod{k}-x.trial(j).modtimes(1);   %not wrapped
            m=find(s>mit & s<=mxt);
            a=[a;length(m)];
         end
         a=sum(a);
         val(l)=a;
         a=[];
         l=l+1;
      end
   end 
   
elseif burst==1
   if wrapped==1 %wrapped is ON
      l=1;           
      for j=1:x.numtrials            
         for k=1:x.nummods
            s=x.btrial(j).mod{k}-x.trial(j).modtimes(k);   %because it is wrapped
            m=find(s>mit & s<=mxt);
            val(l)=length(m);
            l=l+1;
         end
      end
      
   elseif wrapped==2   %wrapped is OFF
      l=1;
      a=[];      
      for j=1:x.numtrials                 
         for k=1:x.nummods
            s=x.btrial(j).mod{k}-x.trial(j).modtimes(1);   %not wrapped
            m=find(s>mit & s<=mxt);
            a=[a;length(m)];
         end
         a=sum(a);
         val(l)=a;
         a=[];
         l=l+1;
      end
   end 
end

 errorval=errorfun(val,type);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err = errorfun(edata,type)
% Computes the Error Data

switch(type)
   
case 'Standard Error' 
   err=std(edata)';
   err=sqrt((err.^2/length(edata)));  
case 'Standard Deviation'
   err=std(edata)';
case '2 StdDevs' 
   err=std(edata)'*2;
case '3 StdDevs' 
   err=std(edata)'*3;
case '2 StdErrs' 
   err=std(edata)';
   err=sqrt((err.^2/length(edata)))*2;   
case 'Variance'
   err=std(edata)'.^2;   
case 'Fano Factor' 
	if max(edata)==0
		err=0;
	else
		err=var(edata)/mean(edata);
	end
case 'Coefficient of Variation'
	if max(edata)==0
		err=0;
	else
		err=std(edata)/mean(edata);
	end
case 'Allan Factor'
	if max(edata)==0
		err=0;
	else
		err=var(diff(edata))/(2*mean(edata));
	end
end


               
      

