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
  struct options_binless *opts;
  double **warped;
  double **embedded;
  double *embedded_temp;
  int *n_vec;
  int n,N,r,R;
  mxArray *mxwarped;
  int status;

  if( (nrhs<1) | (nrhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:binlessembed:numArgs","2 input arguments required.");
  if( (nlhs<1) | (nlhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:binlessembed:numArgs","1 or 2 output argument required.");

  if(nrhs<2)
    opts = ReadOptionsBinless(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsBinless(mxCreateEmptyStruct());
  else
    opts = ReadOptionsBinless(prhs[1]);

  ReadOptionsEmbedRange(opts);

  N = mxGetM(prhs[0]);

  warped = (double **)mxCalloc(N,sizeof(double *));
  n_vec = (int *)mxCalloc(N,sizeof(int));

  /* Read in warped cell array */
  for(n=0;n<N;n++)
  {
    mxwarped = mxGetCell(prhs[0],n);
    n_vec[n] = mxGetN(mxwarped);
    warped[n] = mxGetPr(mxwarped);

    if(IsSortedDouble(n_vec[n],warped[n])==0)
      mexErrMsgIdAndTxt("STAToolkit:binlessembed:outOfOrder","Spike times out of order.");
  }

  R = (*opts).D_max+1;

  plhs[0] = mxCreateDoubleMatrix(N,R,mxREAL);
  embedded_temp = mxGetData(plhs[0]);
  embedded = mxMatrixDouble(N,R);

  /* Do computation */
  status = BinlessEmbedComp(opts,warped,n_vec,N,embedded);

  /* vectorize and transpose */
  for(n=0;n<N;n++)
    for(r=0;r<R;r++)
      embedded_temp[r*N+n]=embedded[n][r];
  
  if(nrhs<2)
    plhs[1] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsBinless(prhs[1],opts);

  mxFree(warped);
  mxFree(n_vec);
  mxFree(embedded);

  return;
}
