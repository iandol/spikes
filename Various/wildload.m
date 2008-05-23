% WILDLOAD.M
%
% Use wildcards to load DOS data files -- prompts for path and file descriptor string
%   Prompted input string example: c:\data\ab??rd.*
%
%   Structure array "WILDCARDd" is left in the workspace to be used in 
%   addressing the data which was loaded 
%   (WILDCARDd(i).name returns the variable name for the ith-loaded file)
%
% Don Clare - clare@us.ibm.com
WILDCARDp=[];
%Prompt user for string
WILDCARDs = input('Path (if required) and name (with wildcards) of files to be loaded: ','s');
%Generate a structure array for all files meeting the user inputted criteria
WILDCARDd=dir(WILDCARDs);
WILDCARDfdelim=find(WILDCARDs == '\');
%Separate the path from the user inputted string
if size(WILDCARDfdelim > 0),
   WILDCARDp=WILDCARDs(1:WILDCARDfdelim(max(size(WILDCARDfdelim))));
end
%Load the files using the path information and the structure array generated from dir
for WILDCARDi=1:max(size(WILDCARDd)),
   load([WILDCARDp WILDCARDd(WILDCARDi).name])
end
%Clean up (Leave WILDCARDd, which can be used to address the loaded data)
clear WILDCARDp WILDCARDi WILDCARDs WILDCARDfdelim 