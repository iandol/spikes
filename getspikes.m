function [s,ss]=getspikes(x,mit,mxt,wrapped)

% Will get all the spikes in a lsd file and return them in a single vector

if ~exist('mit','var')
	mit=0;
end
if ~exist('mxt','var')
	mxt=Inf;
end
if ~exist('wrapped','var')
	wrapped=1;
end

mit=mit*10;
mxt=mxt*10;

s=[];
ss=[];
s2=[];

if wrapped==1       %wrapped is ON
   i=1;           
   for j=1:x.numtrials            
      for k=1:x.nummods
         m=x.trial(j).mod{k}-x.trial(j).modtimes(k);   %because it is wrapped
         m=m(find(m>mit & m<=mxt));
         s=[s;m];
		 ss(i).trial=m;
         i=i+1;
      end
   end
   
else 
   i=1;
   a=[];      
   for j=1:x.numtrials   
	   s2=[];
      for k=1:x.nummods		 
         m=x.trial(j).mod{k}-0;   %not wrapped
         m=m(find(m>mit & m<=mxt));
         s=[s;m];
		 s2=[s2;m];
	  end
	  ss(i).trial=s2
	  i=i+1;
   end
end 

s=sort(s);