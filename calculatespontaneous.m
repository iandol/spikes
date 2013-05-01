function sp = calculatespontaneous(psth,time,mint,maxt)
%calculate spontaneous
sp = struct;

opsth = psth;

m=max(psth);
[m,trials]=converttotime(m);
if max(psth)>0;psth=(psth/max(psth))*m;end

mini=find(time==mint);
maxi=find(time==maxt);

psth=psth(mini:maxi);
opsth=opsth(mini:maxi);

%-------------------for firing rate version
[sp.mean,sp.sd]=stderr(psth,'SD'); %get mean and s.d.
[~,sp.se]=stderr(psth); %get mean and s.e.
%------this block gets confidence intervals from a poisson distribution
[sp.ci05]=poissinv([0.025 0.975],sp.mean);		%p=0.05
[sp.ci025]=poissinv([0.0125 0.9875],sp.mean);	%p=0.025
[sp.ci01]=poissinv([0.005 0.995],sp.mean);		%p=0.01
[sp.ci005]=poissinv([0.0025 0.9975],sp.mean);	%p=0.005
[sp.ci001]=poissinv([0.0005 0.9995],sp.mean);	%p=0.001
sp.bin1=sp.ci01(2); %sets defaults to p=0.01
sp.bin2=sp.ci01(2);
sp.bin3=sp.ci05(2);
%--------------------------------------------------------------

%-----------------for spikes/bin version
[sp.meano,sp.sdo]=stderr(opsth,'SD'); %get mean and s.d.
[~,sp.seo]=stderr(opsth); %get mean and s.e.
%------this block gets confidence intervals from a poisson distribution
[sp.ci05o]=poissinv([0.025 0.975],sp.meano);		%p=0.05
[sp.ci025o]=poissinv([0.0125 0.9875],sp.meano);	%p=0.025
[sp.ci01o]=poissinv([0.005 0.995],sp.meano);		%p=0.01
[sp.ci005o]=poissinv([0.0025 0.9975],sp.meano);	%p=0.005
[sp.ci001o]=poissinv([0.0005 0.9995],sp.meano);	%p=0.001
sp.bin1o=sp.ci01o(2); %sets defaults to p=0.01
sp.bin2o=sp.ci01o(2);
sp.bin3o=sp.ci05o(2);
%--------------------------------------------------------------

end

