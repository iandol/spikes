function y = isoctave
%ISOCTAVE Returns true if running Octave, false otherwise.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

y = exist('OCTAVE_VERSION','builtin')>0;
