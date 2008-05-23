%*---------------GETT--(Rowland Sillito, July 2001)-----------------*
%|                                                                  |
%|  gett(objtag,'PropertyName') returns the value of 'PropertyName' |
%|                             for all objects with the tag objtag. |
%|                                                                  |
%*------------------------------------------------------------------*
function output=gett(tag,setting)
output=get(findobj('tag',tag),setting);