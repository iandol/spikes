%*------------------------------------------*
%|   .mpg export options GUI function       |
%|    (Rowland Sillito January 2001)        |        
%|------------------------------------------|
%|       created as an accessory            |
%| for use with Mathworks mpgwrite.dll file |  
%*------------------------------------------*

function [options]=mpgoptions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Variable Declaration %%%%%%%%%%%%%%%%%%%


%declare variables
persistent psearchs
persistent bsearchs
persistent refframes
persistent iframes
persistent pframes
persistent bframes

persistent mpgloops
persistent psearch
persistent bsearch
persistent refframe
persistent pixrange
persistent iframe
persistent pframe
persistent bframe
global choice

%%%%%%%%%%%%%%%% End of Variable Declaration %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Main Program%%%%%%%%%%%%%%%%%%%%%%%%

%%initialisation

%loads GUI
mpgoptionbox;

%choice is only set to 1 when user clicks on one of the buttons
choice=0;

%sets callbacks for exit and continue buttons
set(ghft('ContinueButton'),'Callback','global choice; choice=1;');
set(ghft('ExitButton'),'Callback','global choice; close(gcf); choice=1;');

%prepares cell arrays to give to the GUI dropdown menus
psearchs={'logarithmic (fastest)';'subsample';'exhaustive (slowest/best)'};
bsearchs={'simple (fastest)';'cross2 (slightly slower)';'exhaustive (v. slow)'};
refframes={'original (fastest)';'decoded (slower/better)'};
iframes=nums2strs([1:1:31]);
pframes=nums2strs([1:1:31]);
bframes=nums2strs([1:1:31]);

%sets up GUI menus with default options selected
set(ghft('EditMpgLoops'),'String','1');
mpgloops=1;

set(ghft('EditPixRange'),'String','10');
pixrange=10;

set(ghft('PSearch'),'String',psearchs);
set(ghft('PSearch'),'Value',1);
psearch=0;

set(ghft('BSearch'),'String',bsearchs);
set(ghft('BSearch'),'Value',2);
bsearch=1;

set(ghft('RefFrame'),'String',refframes);
set(ghft('PSearch'),'Value',1);
refframe=0;

set(ghft('IFrame'),'String',iframes);
set(ghft('IFrame'),'Value',8);
iframe=8;

set(ghft('PFrame'),'String',pframes);
set(ghft('PFrame'),'Value',10);
pframe=8;

set(ghft('BFrame'),'String',iframes);
set(ghft('BFrame'),'Value',25);
bframe=25;

%%waits until the user has clicked on continue or exit
while choice==0
   pause(0.5);
end   

%gets the chosen values from GUI
psearch=(get(ghft('PSearch'),'Value')-1);
bsearch=(get(ghft('BSearch'),'Value')-1);
refframe=(get(ghft('RefFrame'),'Value')-1);
iframe=get(ghft('IFrame'),'Value');   
pframe=get(ghft('PFrame'),'Value');   
bframe=get(ghft('BFrame'),'Value');
options=[mpgloops,psearch,bsearch,refframe,pixrange,iframe,pframe,bframe];
close(gcf);

%%%%%%%%%%%%%%%%%%%%% End of Main Switch %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%Extra Function Declarations %%%%%%%%%%%%%%%%%%%

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
%%%%%%%%%%%%%%%%%%%% End of Declarations %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  