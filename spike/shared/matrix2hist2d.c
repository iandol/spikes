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
  struct hist2d *out;
  double **in_in;
  double *in;
  int m,n;
  int M,N;
  struct options_entropy *opts;
  int status;

  if( (nrhs<1) | (nrhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:matrix2hist2d:numArgs","1 or 2 input arguments required.");
  if( (nlhs<1) | (nlhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:matrix2hist2d:numArgs","1 or 2 output arguments required.");

  in = mxGetPr(prhs[0]);
  M = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);

  if(nrhs<2)
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsEntropy(mxCreateEmptyStruct());
  else
    opts = ReadOptionsEntropy(prhs[1]);

  if(opts[0].useall_flag==0)
    {
      (*opts).useall=(int) DEFAULT_UNOCCUPIED_BINS_STRATEGY;
      opts[0].useall_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:matrix2hist2d:missingOption","Missing option unoccupied_bins_strategy. Using default value %d.\n",(*opts).useall);
    }

  if( (opts[0].useall!=-1) & (opts[0].useall!=0) & (opts[0].useall!=1) )
   {
     (*opts).useall=(int) DEFAULT_UNOCCUPIED_BINS_STRATEGY;
      opts[0].useall_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:matrix2hist2d:invalidValue","Option unoccupied_bins_strategy set to an invalid value. Must be -1, 0, or 1. Using default value %d.\n",(*opts).useall);
   }

  in_in = mxMatrixDouble(M,N);
  for(m=0;m<M;m++)
    for(n=0;n<N;n++)
      in_in[m][n]=in[n*M+m];
  
  /* Allocate memory for hist2D */
  out = (struct hist2d *)mxMalloc(sizeof(struct hist2d));

  plhs[0] = AllocHist2D(out,M*N,1);

  status = MatrixToHist2DComp(in_in,M,N,out,opts);
  if(status!=EXIT_SUCCESS)
    mexWarnMsgIdAndTxt("STAToolkit:matrix2hist2d:failure","Function matrix2hist2d returned with errors. Please check messages.");

  WriteHist2D(out,plhs[0]);

  if(nrhs<2)
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsEntropy(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsEntropy(prhs[1],opts);

  mxFreeMatrixDouble(in_in);
  mxFree(out);

  return;
}
