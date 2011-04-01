%*-------------------------------------------*
%|   FFT Calculation options GUI function    |
%|    (Rowland Sillito September 2001)       |        
%|-------------------------------------------|
%|       created as an accessory             |
%| for use with Computefft function & Spikes |  
%*-------------------------------------------*

function [options]=fftoptions(tf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------ Variable Declaration ------------------%


%declare variables
persistent harmn1
persistent harmn2
persistent infpoint
persistent zeropoint
persistent acceptable
global choice

%--------------- End of Variable Declaration ---------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------- Main Program ----------------------%

%%initialisation

%loads GUI
fftoptionbox;
set(ghft('TempFreqBox'),'String',num2str(tf));

%choice is only set to 1 when user clicks on one of the buttons
choice=0;
acceptable=0;

%sets callbacks for exit and continue buttons
set(ghft('FFTContinueButton'),'Callback','global choice; choice=1;');

while acceptable==0 %acceptable values in the box???
   %%waits until the user has clicked on continue
   while choice==0
      pause(0.5);
   end
   if get(ghft('SingleHarmonic'),'Value')==1
      v=str2num(get(ghft('SingHarmnBox'),'String'));
      if (~isempty(v) && v>=0)
         harmn1=v;
         harmn2=inf;
         infpoint=inf;
         zeropoint=0;
         acceptable=1;
      else
         Errordlg('Harmonic must be >=0','Incorrect values entered!');
         choice=0;
      end
   else
      v=str2num(get(ghft('Harmn1Box'),'String')); 
      w=str2num(get(ghft('Harmn2Box'),'String'));
      inp=str2num(get(ghft('InfPointBox'),'String'));
      zep=str2num(get(ghft('ZeroPointBox'),'String'));
      if (~isempty(v) & v>=0) & (~isempty(w) & w>=0) & (v~=w)
         harmn1=v;
         harmn2=w;
         acceptable=1;
         if get(ghft('SetInfPoint'),'Value')==1 & ~isempty(inp) & ~isempty(zep)
            infpoint=inp;
            zeropoint=zep;
         else
            infpoint=inf;
            zeropoint=0;
         end
      else
         Errordlg('Harmonics must be >=0, and where 2 are specified for calculating a ratio, they must be different.','Incorrect values entered!');
         choice=0;
      end
   end
end


options=[harmn1,harmn2,infpoint,zeropoint];
close(gcf);

%-------------------- End of Main Switch -------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------ Extra Function Declarations ------------------%

%GHFT GetsHandleFromTag
function [handle] = ghft(tag)
	handle=findobj('tag',tag);
%End of handle getting routine%

%Converts array of numbers to a cell array of strings   
function [cellout]=nums2strs(arrayin)
	for n=1:length(arrayin)
  	   cellout{n}=num2str(arrayin(n));
   end
%End of function
   
%------------------- End of Declarations -------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  