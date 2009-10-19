/*
 *  Copyright 2009, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "binless_c.h"
#include "binless_mx.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  struct input *X;
  struct options_binless *opts;
  int n,N,max_Q;
  double **times;
  int *a,*n_vec;
  mxArray *mxtimes;
  int status;

  if( (nrhs<1) | (nrhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:binlessopen:numArgs","1 or 2 input arguments required.");
  if((nlhs<3) | (nlhs>4))
    mexErrMsgIdAndTxt("STAToolkit:binlessopen:numArgs","3 or 4 output arguments required.");

  X = ReadInput(prhs[0]);

  if((*X).N>1)
    mexErrMsgIdAndTxt("STAToolkit:binlessopen:multiSite","Cannot accomodate multi-site input.");

  if(nrhs<2)
    opts = ReadOptionsBinless(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsBinless(mxCreateEmptyStruct());
  else
    opts = ReadOptionsBinless(prhs[1]);

  ReadOptionsBinlessTimeRange(opts,X);

  /* Allocate memory for a, N_k, n_vec */
  N = GetNumTrials(X);
  max_Q = GetMaxSpikes(X);

  plhs[1] = mxCreateNumericMatrix(N,1,mxINT32_CLASS,mxREAL);
  n_vec = mxGetData(plhs[1]);

  plhs[2] = mxCreateNumericMatrix(N,1,mxINT32_CLASS,mxREAL);
  a = mxGetData(plhs[2]);

  /* Create times cell array */
  plhs[0] = mxCreateCellMatrix(N,1);
  times = (double **)mxCalloc(N,sizeof(double *));
  for(n=0;n<N;n++)
    {
      mxtimes = mxCreateDoubleMatrix(1,max_Q,mxREAL);
      times[n] = mxGetPr(mxtimes);
      mxSetCell(plhs[0],n,mxtimes);
    }

  /* Do computation */
  status = BinlessOpenComp(X,opts,N,n_vec,a,times);

  /* Shrink the times array */
  for(n=0;n<N;n++)
    {
      mxtimes = mxGetCell(plhs[0],n);
      mxSetN(mxtimes,n_vec[n]);
    }

  if(nrhs<2)
    plhs[3] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[3] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else
    plhs[3] = WriteOptionsBinless(prhs[1],opts);
  
  mxFreeInput(X);
  mxFree(times);

  return;
}

