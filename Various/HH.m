function varargout = HH(varargin)
%
% Interactive real-time computer simulation of a single conductance-based single-compartment biophysical model neuron under
% synaptic deterministic/stochastic stimulation (Hodgkin-Huxley-like model neuron).
%
% Version 1.0, Bern, 23/6/2002 - (c) 2002, Michele Giugliano, Ph.D., Physiologisches Institut, Universitaet Bern, Switzerland.
% email: michi@cns.unibe.ch             url: http://www.giugliano.info
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation. This program is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
% License for more details. You should have received a copy of the GNU General Public License along with this program; if not, write
% to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
%
% Demo computer simulation of a single conductance based model neuron with stochastic/deterministic current injection and
% on-the-fly estimation of the mean firing rate and on the coefficient of variation of the interspike-interval distribution.
% This software takes advantage of the MATLAB visualization power, the easy and quick definition of a graphical user interface
% (GUI) and the interfacing with a 'mex' compiled c-source. It was developed for educational purpouses and to support with
% live-demos computer simulations, an invited oral presentation given by the author to a conference.
% It might also be conveniently employed as a development example for further exploring the advantages of MATLAB GUIs and MEX
% interfaces. All the source codes are included in the package.
%
% The biophysical model simulated in the current demo software, incorporates two active membrane currents, following the
% Hodgkin-Huxley-like kinetic equations: the fast-inactivating sodium inward and the delayed-rectifier potassium outward
% currents. Together with those voltage-dependent currents, the total membrane current includes a passive leakage current and a
% stochastic current, representing the overall incoming afferent excitatory and inhibitory synaptic current
% due to a large population of excitatory and inhibitory background presynaptic neurons, whose electrophysiological activity
% is not affected by the (postsynaptic) firing of the simulated neuron. The simulated synaptic current result from the superposition
% of incoming presynaptic spikes, arriving asynchronously and being modelled by instantaneous current (i.e. Dirac's
% Delta currents). As a result, the overal resulting synaptic current is a stochastic delta-correlated gaussian process
% whose infinitesimal moments ('mean' and 'sigma') can be selected arbitrarily by the user, acting on the GUI controls.
%
% Please report bugs and ask for literature pointers and other details to: michi@cns.unibe.ch.
% For further demos, scripts and software developed, please have a look at: www.giugliano.info .
%
%--------------------------------------------------------------------
if nargin == 0  % LAUNCH GUI
 fig = openfig(mfilename,'reuse');
 set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
 set(fig,'units','normalized','outerposition',[0 0 1 1],'visible','on'); 
 set(fig,'ButtonDownFcn','HH(''stop'',gcbo,[],guidata(gcbo))');
 handles = guihandles(fig);
 guidata(fig, handles);
%--------------------------------------------------------------------
global V;               % Instantaneous membrane voltage [mV].
global hhh;             % Sodium channels inactivation (the activation is assumed to be instantaneous).
global n;               % Potassium channels activation.
global dt;              % Forward Euler Method Integration time step [ms].
global mean;            % Mean current injected [uA/ms].
global sigma;           % Std. dev. current injected [uA^0.5/ms].
global K;               %
global VV;              %
global seed;            % Random number generation actual seed.
%--------------------------------------------------------------------
K     = 1;              %
VV    = [];             %
V     = -69.;           % Initial value for the membrane voltage [mV].
hhh   = 0.;             %
n     = 0.;             % Initial value for the Potassium channels activation.
mean  = 3.7605;         % Initial value for the Mean current injected [uA/ms].
sigma = 0.001;          % Initial value for the Std. dev. current injected [uA^0.5/ms].
dt    = 0.1;            % Integration time step [ms] (probably 0.1 ms is too large, but ok for a demo).
seed  = 353;            % Initalization of the seed for the random number generation routine.
set(fig,'Color',[0 0 0]);                   % Background color of the main (GUI) Figure.
set(fig,'doublebuffer','on');               % This reduces plot flickering and increases graphic performances.
set(handles.mean,'String',num2str(mean));   % This sets the initial value for the 'mean', to the GUI edit field.
set(handles.sigma,'String',num2str(sigma)); % This sets the initial value for the 'sigma', to the GUI edit field.
%--------------------------------------------------------------------
if nargout > 0
 varargout{1} = fig;
end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
try
if (nargout)
 [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
else
 feval(varargin{:}); % FEVAL switchyard
end
catch
 disp(lasterr);
end
end
%--------------------------------------------------------------------
%--------------------------------------------------------------------
%--------------------------------------------------------------------
function varargout = startstop_Callback(h, eventdata, handles, varargin)
% This function start/stop the real-time simulation, by toggling the state of the GUI
% button called 'startstop' (for further information please open the file HH.fig by GUIDE).
% This callback is associated to the button 'startstop'.
toggle = get(handles.startstop,'Value');
if (toggle == 1)
 simulate_Callback(h, eventdata, handles, varargin);
end % if

% --------------------------------------------------------------------
function varargout = mean_Callback(h, eventdata, handles, varargin)
% This function set the value inserted by the user via the GUI to the global variable 'mean'. 
% This callback is associated to the edit object 'mean'.
global mean;
mean = str2num(get(handles.mean,'String'));

% --------------------------------------------------------------------
function varargout = sigma_Callback(h, eventdata, handles, varargin)
% This function set the value inserted by the user via the GUI to the global variable 'sigma'. 
% This callback is associated to the edit object 'sigma'.
global sigma;
sigma = str2num(get(handles.sigma,'String'));

% --------------------------------------------------------------------
function varargout = simulate_Callback(h, eventdata, handles, varargin)
% This function is the main simulation routine and it is called when the user pushes the button
% 'startstop', by invoking it through its callback.
global V;               % Instantaneous membrane voltage [mV].
global hhh;             % Sodium channels inactivation (the activation is assumed to be instantaneous).
global n;               % Potassium channels activation.
global dt;              % Forward Euler Method Integration time step [ms].
global mean;            % Mean current injected [uA/ms].
global sigma;           % Std. dev. current injected [uA^0.5/ms].
global K;               %
global VV;              %
global seed;            % Random number generation actual seed.
global isi;             % Data structure containing the interspike intervals [ms].
global spike;           % Data structure containing the 'features' of each spike (see 'extract_spike.m')

COLOR = [1 1 1];        % White color, coded according to the RGB standard convention.

T = 0:dt:200;           % Simulation is not running and displaying its result at each time step, but at 200 ms steps.
N = size(T,2);          %
M = 10;                 %
T = N*M*dt*0.001;       % The global simulation data presented on the GUI is the result of M times the simulation over 200 ms.
X = 0:(0.001*dt):T;     %

while (get(handles.startstop,'Value'))   % Infinite-loop, set by the toggle-value associated with the 'startstop' button.
 Vout = [];                              % Data structure containing the entire simulation data point over T ms.
 for i=1:N,                                                       % For each data point to be simulated within the 200ms steps,
  [V, hhh, n, seed] = hh_step(V, hhh, n, mean, sigma, dt, seed);  % let's call the 'hh_step' function to have the next points.
  Vout(i) = V;                                                    % Put the newly computed value of V into Vout.
 end % for

 if (K==(M+1))                                                    % When M steps, each long 200 ms, were performed,
  [spike_shapes spike] = extract_spike(X, VV', VV', -10, 2,1,1);  % extract some information about the spike-train, such as
  size(spike);                                                    % the mean firing rate and if there are at least 3 spikes,
  if (size(spike,1)>3)                                            % then let's compute the CV of the interspike-interval
  [mean_isi, std_isi]  = computecv(h, eventdata, handles, varargin);% distribution by the appropriate function (see below).
  freq = size(spike,1)/T;                                            % By definition the mean firing rate is computed.
  cv   = std_isi/mean_isi;                                           % By definition the CV is computed.
  set(handles.freq,'String',sprintf('%.2f Hz',freq));
  set(handles.cv,'String',sprintf('%.2f',cv));
  else
  freq = size(spike,1)/T;
  cv   = 0.;
  set(handles.freq,'String',sprintf('%.2f Hz',freq));               % This updates the GUI frequency display (text object).
  set(handles.cv,'String',sprintf('%.2f',cv));                      % This updates the GUI cv display (text object).
  end %
  VV = [];                                                      % The data structure VV is reset and it is filled by
  VV = Vout;                                                    % the output data points resulting from the 200 ms step.
  K  = 1;                                                       % The counter over the M steps is reset to 1.
 else
  VV = [VV, Vout];                                              % Otherwise, accumulates everything inside VV.
 end
 K = K + 1;                                                     %
 axes(handles.display);                                           % This selects the current axes to plot waveforms to.
 p = plot(VV,'Color',COLOR,'LineWidth',1.2);                      % Plot the content of VV using the color 'COLOR'.
 q = line([(M-1)*N M*N],[-99 -99]); set(q,'Color',COLOR,'LineWidth',3); % Some legend and calibration bars are defined here.
 tt = text((M-1)*N,-94,sprintf('%.2f s',N*dt*0.001)); set(tt,'Color',COLOR,'FontName','Helvetica','FontSize',15);
 r = line([M*N M*N],[-99 -49]); set(r,'Color',COLOR,'LineWidth',3);
 s = line([0 M*N],[-69 -69]); set(s,'Color',COLOR,'LineWidth',1,'LineStyle',':');
 set(handles.display,'Color',[0 0 0 ],'XLim',[0 M*N],'YLim',[-100 70]);
 set(gca,'ButtonDownFcn','HH(''stop'',gcbo,[],guidata(gcbo))'); % This makes the simulation interruptible by clicking over the axes areas.
pause(0.1);                                                % This is a fundamental delay of 100 ms in the infinite-loop, absolutely needed.                                                            
end % while

% --------------------------------------------------------------------
function [mean_isi, std_isi] = computecv(h, eventdata, handles, varargin)
% This function compute on-the-fly, the mean firing rate and the coefficient of variation of the
% interspike interval distribution, if some consistency conditions are matched.

global isi;             % Data structure containing the interspike intervals [ms].
global spike;           % Data structure containing the 'features' of each spike (see 'extract_spike.m')

isi     = [];           % First of all, the 'isi' data structure is clean (initialized) from any previous content.
k       = 1;            % Similarly the current index over the isi number is (re)set to 1.

for i=2:size(spike,1),
 if ( (spike(i,1)-spike(i-1,1))==0 ) 
  %disp(sprintf('DEBUG WARNING: one spike has been counted as two (spike n. %d)\n',i));
  ;
 else
  isi(k,1)   = spike(i,1);
  isi(k,2)   = spike(i,1)-spike(i-1,1);
  k          = k + 1;
 end % if
end;

mean_isi = mean(isi(:,2));  % For the evaluation of the CV, the mean and the std deviation must be
std_isi  = std(isi(:,2));   % estimated from the sample isi distribution.

% --------------------------------------------------------------------
function varargout = stop(h, eventdata, handles, varargin)
% This function stops the execution of the current real-time demo simulation.
% It works by setting the internal toggle variable, associated to the toggle-button
% 'startstop', to 0 when it is found equal to 1.
if get(handles.startstop,'Value')
 set(handles.startstop,'Value',0);
else
 set(handles.startstop,'Value',1);
 simulate_Callback(h, eventdata, handles, varargin);
end % 

% --------------------------------------------------------------------
function [spike_shapes, spike] = extract_spike(time, data, ddata, threshold, width, Tpre, Tpost)

%   [SPIKE_SHAPES, SPIKE] = EXTRACT_SPIKE(TIME, DATA, DDATA, THRESHOLD, WIDTH, TPRE, TPOST)
%
%     Extract details on the occurrence, the amplitude, the shape etc. by simple (positive) peak detection on the time derivative.
%
%     This function performs a spike-detection, providing several details on the features of each spike.
%
%     The input argument TIME refers to the data time column [s] and it is used for many internal operations.
%     The input arguments DATA is the raw membrane voltage data trace [mV/s], while DDATA = diff(DATA,1)/dt. 
%      DDATA must be provided explicitly in order to maximize performances of the peak detection algorithm [mV/s].
%     The input argument THRESHOLD, specified in the units of DDATA, is the spike-detection threshold (e.g. 1.5E5 mV/s).
%     The input argument WIDTH is the minimal distance between two successive spikes [ms] (e.g. 2 ms).
%     The input arguments Tpre and Tpost specifies, in [ms], the observation window to retrieve the shape of the detected spike.
%
%     The output argument SPIKE_SHAPES is a cell array, containing the shape of each individual spike over a window specified
%     by Tpre and Tpost.
%
%     The output argument SPIKE is a (Nspikes x 4) numeric array, containing respectively:
%                       - the absolute time of occurrence of the detected peak [s]
%                       - the amplitude of the peak [mV]
%                       - the maximal upstroke slope of the peak [mV/s].
%                       - the maximal downstroke slipe of the peak [mV/s].
%
%     © 2002 - Michele Giugliano, PhD (http://www.giugliano.info) (Bern, Sunday May 5th, 2002 - 18:50)
%                               (bug-reports to michele@giugliano.info)
%

spike_shapes = {};                              % The output data structure is initialized.
spike        = [];                              % The output data structure is initialized.

if (isempty(time) | isempty(data) | isempty(ddata))
 %disp(sprintf('Extract_Spike: (Error) empty imput data structures'));        
 return;
end % if

if ((width <= 0) | (Tpre < 0.) | (Tpost < 0.))
 %disp(sprintf('Extract_Spike: (Error) Wrong spike width and/or window.'));        
 return;
end % if
    
dt        = time(2) - time(1);                  % The sampling interval is evaluated (hp: it is expressed in [s]).
min_index = 1;                                  % Minimum sample index.
max_index = length(time);                       % Maximal sample index.

Ipre      = round((Tpre/1000.)/dt);             % Number of samples before the threshold crossing.
Ipost     = round((Tpost/1000.)/dt);            % Number of samples after the threshold crossing.
Iw        = round((width/1000.)/dt);            % Minimal number of samples between two successive spike.


%
% Below, I take advantage of the matlab command 'find' to extract those part of the smoothed signal DATA whose time derivative is
% larger or lower than appropriately chosen threhsolds, defining the spikes in terms of the slope of the membrane voltage.
%

upstrokes                         = data;            %   I fill the vector upstrokes with the content of the DATA signal.
upstrokes(find(ddata<=threshold)) = nan;             %   Then I put to 'nan' those elements whose slope is lower than the threshold.
Nup                               = size(upstrokes,1); % Here the length of 'upstrokes' is determined.

if (Nup == 0)
 %disp(sprintf('Extract_Spike: (Warning) No threshold crossing detected!'));    
 return;
end % if

%---------------------------------------------------------------------------------------------------------------------------------------------------------
if (upstrokes(1)~=nan)                                 % If the very first element of upstrokes is not a NaN
    upstrokes(1) = nan;                                % I conventionally set it to NaN so that my algorithm will work anyway.
end % if                                               % (this is a pure conventional assumption)

temp       = [];                                       % Temporary structure containing the temporary spike waveform..
tmp        = [];                                       % Temporary structure containing the temporary spike waveform..
counts     = 0;                                        % Counter of the spike number. 
t_last     = -9999.;                                   % Last time a spike occurred [s] (initialized to a very remote time).

for J=2:Nup-1,                                         % I go through each element in 'upstrokes' to detect the threshold crossing. 
 if ( isnan(upstrokes(J-1)) & ~isnan(upstrokes(J)) )   % Here is the definition of threshold crossing, occurring at time t*.
    if ((J-Iw)>=min_index) & ((J+Iw)<=max_index)       % If there are enough samples to fully include at least one spike then proceed.
     counts = counts + 1;                              % Increase the current spike number counter.
     temp   = data(J-Iw:J+Iw);                         % Extract from the raw data, samples between t*-width and t*+width.
     hhh    = find(temp == max(temp));                 % Extract the time (t*) at which the maximal value of the depolarization is reached ('the' spike).
     spike(counts,1) = time( J -Iw + hhh(1) - 1);      % Write in the output data structure, the absolute time t*,
     spike(counts,2) = max(temp);                      % the amplitude of the spike (the depolarization at time t*),
     spike(counts,3) = max(diff(temp,1)/dt);           % the maximal positive derivative (max upstroke slope), within the specified window [t*-width ; t*+width]
     spike(counts,4) = min(diff(temp,1)/dt);           % the minimal derivative (max downstroke slope), within the specified window [t*-width ; t*+width]
     clear temp;                                       % Free some memory, as I don't need anymore the 'temp' data structure.
     K = J;
     if ((spike(counts,1) - t_last) < (width/1000.))   % When the detected spike is unrealistically close to the preceding one, let's discard it.
      counts = counts - 1;
     else
      t_last = spike(counts,1);
     end % if
     
    else
     %disp(sprintf('Extract_Spike: (Warning) Not enough samples to proceed.'));
     ;
    end % if    
 end % if
end % for

% --------------------------------------------------------------------
function varargout = freq_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = cv_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% --------------------------------------------------------------------
% --------------------------------------------------------------------
% --------------------------------------------------------------------