%*--------------SETT--(Rowland Sillito, July 2001)-----------------------*
%|                                                                       |
%|  sett(objtag,'PropertyName',objvalue) set the value of 'PropertyName' |
%|                                      as objvalue for all objects with |
%|                                      the tag objtag.                  |
%|                                                                       |
%*-----------------------------------------------------------------------*
function sett(tag,setting,value)
set(findobj('tag',tag),setting,value);