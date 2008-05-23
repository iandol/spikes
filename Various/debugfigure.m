% DEBUGFIGURE Script
% Repairs 'uneditable' figures recreated from saved 'fig'-files

% Author: Boyko Stoimenov
% E-mail: boyko@tribo.mech.tohoku.ac.jp
% Revision:1.0
% Date: 14-Sep-2001

% Specify a figure handle
debug_fig_handle = input('Specify a figure handle. Type ''gcf'' for current figure, -> ');

%Get the 'ApplicationData' property of current figure
debug_fig_AppData = get(debug_fig_handle, 'ApplicationData');

%Get the cell array which is in ScribeClearModeCallback-field
debug_fig_ScribeClearCB = debug_fig_AppData.ScribeClearModeCallback;

% Repair the handle to point to the selected figure's handle
debug_fig_ScribeClearCB{2} = debug_fig_handle;


% Write this new info to 'Read-only' 'ApplicationData' property
setappdata(gcf,'ScribeClearModeCallback',debug_fig_ScribeClearCB);

% Clear the variables used in this script from the workspace
clear debug_fig_handle debug_fig_AppData debug_fig_ScribeClearCB