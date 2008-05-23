function [s]=getspikesb(x,mit,mxt,wrapped)

% Will get all the spikes in a lsd file and return them in a single vector
% Modified to load only burst spikes

mit=mit*10;
mxt=mxt*10;

s=[];

if wrapped==1       %wrapped is ON
   l=1;           
   for j=1:x.numtrials            
      for k=1:x.nummods
         m=x.btrial(j).mod{k}-x.trial(j).modtimes(k);   %because it is wrapped
         m=m(find(m>mit & m<=mxt));
         s=[s;m];
         val(l)=length(m);
         l=l+1;
      end
   end
   
elseif wrapped==0   %wrapped is OFF
   l=1;
   a=[];      
   for j=1:x.numtrials                 
      for k=1:x.nummods
         m=x.btrial(j).mod{k}-0;   %not wrapped
         m=m(find(m>mit & m<=mxt));
         s=[s;m];
         val(l)=length(m);
         l=l+1;
      end
   end
end 

s=sort(s);