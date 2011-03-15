/*
 *  Copyright 2010, Weill Medical College of Cornell University
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
  double **times;
  double **warped;
  int *n_vec;
  int N;
  int n;
  mxArray *mxtimes, *mxwarped;
  int status;

  if( (nrhs<1) | (nrhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:binlesswarp:numArgs","3 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:binlesswarp:numArgs","1 or 2 output arguments required.");

  if(nrhs<2)
    opts = ReadOptionsBinless(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsBinless(mxCreateEmptyStruct());
  else
    opts = ReadOptionsBinless(prhs[1]);

  ReadOptionsWarpRange(opts);

  /* WARPING STRATEGY */
  if((*opts).warp_strat_flag==0)
    {
      (*opts).warp_strat = (opts->rec_tag_flag && (opts->rec_tag==1)) ? 0 : (int)DEFAULT_WARPING_STRATEGY;
      (*opts).warp_strat_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:binlesswarp:missingOption","Missing option warping_strategy. Using default value %d.\n",(*opts).warp_strat);
    }

  if( ((*opts).warp_strat!=0) & ((*opts).warp_strat!=1) )
    {
      (*opts).warp_strat = (opts->rec_tag_flag && (opts->rec_tag==1)) ? 0 : (int)DEFAULT_WARPING_STRATEGY;
      (*opts).warp_strat_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:binlesswarp:invalidValue","Option warping_strategy set to an invalid value. Must be 0 or 1. Using default value %d.\n",(*opts).warp_strat);
    }

  /* handle continuous data (if known to exist) */
  if(opts->rec_tag_flag && (opts->rec_tag==1))
    {
      if(opts->warp_strat!=0)
        {
          opts->warp_strat = 0;
          mexWarnMsgIdAndTxt("STAToolkit:binlesswarp:invalidValue","Option warping_strategy must be set to 0 when recording_tag='continuous'.\n");
        }

      plhs[0] = mxDuplicateArray(prhs[0]);
      if((nrhs<2) || mxIsEmpty(prhs[1]))
        plhs[1] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
      else
        plhs[1] = WriteOptionsBinless(prhs[1],opts);

      return;
    }

  N = mxGetM(prhs[0]);

  times = (double **)mxCalloc(N,sizeof(double *));
  n_vec = (int *)mxCalloc(N,sizeof(int));

  /* Read in times cell array */
  for(n=0;n<N;n++)
  {
    mxtimes = mxGetCell(prhs[0],n);
    n_vec[n] = mxGetN(mxtimes);
    times[n] = mxGetPr(mxtimes);

    if(IsSortedDouble(n_vec[n],times[n])==0)
    {
      mxFree(opts);
      mxFree(times);
      mxFree(n_vec);
      mexErrMsgIdAndTxt("STAToolkit:binlesswarp:outOfOrder","Spike times out of order.");
    }
  }

  /* Create warped matrix */
  plhs[0] = mxCreateCellMatrix(N,1);
  warped = (double **)mxCalloc(N,sizeof(double *));
  for(n=0;n<N;n++)
    {
      mxwarped = mxCreateDoubleMatrix(1,n_vec[n],mxREAL);
      warped[n] = mxGetPr(mxwarped);
      mxSetCell(plhs[0],n,mxwarped);
    }

  /* Do computation */
  status = BinlessWarpComp(opts,times,n_vec,N,warped);

  if(nrhs<2)
    plhs[1] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsBinless(prhs[1],opts);

  mxFree(times);
  mxFree(warped);
  mxFree(n_vec);

  return;
}
