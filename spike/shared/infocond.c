/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Information and entropies from conditional and total histograms.
 * This file contains C code that is compiled into the MEX-file
 * infocond.mex*. Its functionality may be accessed in Matlab by calling
 * the function infocond. Additional documentation resides in infocond.m,
 * and can be found by typing "help infocond" at the Matlab command prompt.
 * @see InfoCondComp.c.
 */

#include "toolkit_c.h"
#include "toolkit_mx.h"

/**
 * @brief Interfaces C and Matlab data.
 * This function is the MEX-file gateway routine. Please see the Matlab
 * MEX-file documentation (http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f43721.html)
 * for more information.
 */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  /* allocate variables */
  struct histcond *in;
  struct options_entropy *opts;
  int status;

  /* check number of inputs (nargin) and outputs (nargout) */
  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:infocond:numArgs","1 or 2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:infocond:numArgs","1 or 2 outputs argument required.");

  /* get or set options */
  if(nrhs<2)
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else
    opts = ReadOptionsEntropy(prhs[1]);

  plhs[0] = mxDuplicateArray(prhs[0]);

  in = ReadHistCond(plhs[0],opts);

  status = InfoCondComp(in,opts);
  if(status!=EXIT_SUCCESS)
    mexWarnMsgIdAndTxt("STAToolkit:infocond:failure","Function infocond returned with errors. Please check messages.");

  /* Augment the mx histogram with the new info */
  WriteHistCondAgain(in,plhs[0]);

  /* output options used */
  if(nrhs<2)
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsEntropy(prhs[1],opts);

  mxFree(in);

  return;
}

