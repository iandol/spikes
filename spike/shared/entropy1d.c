/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Entropy from a 1-D histogram.
 * This file contains C code that is compiled into the MEX-file
 * entropy1d.mex*. Its functionality may be accessed in Matlab
 * by calling the function entropy1d. Additional documentation
 * resides in entropy1d.m, and can be found by typing "help
 * entropy1d" at the Matlab command prompt.
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
  struct hist1d *in;
  int M;
  struct options_entropy *opts;
  int status;

  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:entropy1d:numArgs","1 or 2 input arguments required.");
  if( (nlhs<1) | (nlhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:entropy1d:numArgs","1 or 2 output arguments required.");

  if(nrhs<2)
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else
    opts = ReadOptionsEntropy(prhs[1]);

  M = mxGetM(prhs[0]);

  plhs[0] = mxDuplicateArray(prhs[0]);

  in = ReadHist1D(M,plhs[0],opts);

  status = Entropy1DComp(M,in,opts);
  if(status!=EXIT_SUCCESS)
    mexWarnMsgIdAndTxt("STAToolkit:entropy1d:failure","Function entropy1d returned with errors. Please check messages.");

  /* Augment the mx histogram with the new info */
  WriteHist1DAgain(M,in,plhs[0]);

  if(nrhs<2)
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsEntropy(prhs[1],opts);

  mxFree(in);

  return;
}

