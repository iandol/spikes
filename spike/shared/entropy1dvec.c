/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "toolkit_c.h"
#include "toolkit_mx.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  struct hist1dvec *in;
  int M;
  struct options_entropy *opts;
  int status;

  if( (nrhs<1) | (nrhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:entropy1dvec:numArgs","1 or 2 input arguments required.");
  if( (nlhs<1) | (nlhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:entropy1dvec:numArgs","1 or 2 output arguments required.");

  if(nrhs<2)
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else
    opts = ReadOptionsEntropy(prhs[1]);

  M = mxGetM(prhs[0]);

  plhs[0] = mxDuplicateArray(prhs[0]);

  in = ReadHist1DVec(plhs[0],opts);

  status = Entropy1DVecComp(in,opts);
  
  /* Augment the mx histogram with the new info */
  WriteHist1DVecAgain(in,plhs[0]);

  if(nrhs<2)
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsEntropy(prhs[1],opts);

  mxFree(in);

  return;
}

