%DIRECTCONDTIME Condition data on time slice.
%   Y = DIRECTCONDTIME(X,OPTS) reorganizes a 2-D cell array (such as
%   is given by the output of DIRECTBIN) into a 1-D cell column vector
%   where each element corresponds to a time slice through the spike
%   trains.
%
%   There are currently no user-specified options or parameters for
%   this function. Therefore OPTS is ignored.
%
%   Y = DIRECTCONDTIME(X) has exactly the same behavior as above.
%
%   [Y,OPTS_USED] = DIRECTCONDTIME(X,OPTS) copies OPTS into OPTS_USED.
% 
%   See also DIRECTBIN, DIRECTCONDCAT, DIRECTCONDFORMAL,
%   DIRECTCOUNTCLASS, DIRECTCOUNTCLASS, DIRECTCOUNTCOND.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
