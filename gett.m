%*---------------GETT--(Rowland Sillito, July 2001)-----------------*
%|                                                                  |
%|  gett(objtag,'PropertyName') returns the value of 'PropertyName' |
%|                             for all objects with the tag objtag. |
%|                                                                  |
%*------------------------------------------------------------------*
function output=gett(tag,setting)
if nargin==2
   output=get(findobj('tag',tag),setting);
elseif nargin==1
   output=get(findobj('tag',tag));
elseif nargin<1 | nargin>2
   disp('Invalid syntax');
   help gett;
end
   

