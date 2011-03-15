/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Bin spike trains for direct method analysis.
 * This file contains C code that is compiled into the MEX-file
 * directbin.mex*. Its functionality may be accessed in Matlab
 * by calling the function directbin. Additional documentation
 * resides in directbin.m, and can be found by typing "help
 * directbin" at the Matlab command prompt.
 * @see DirectBinComp.c.
 */

#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "direct_c.h"
#include "direct_mx.h"

/**
 * @brief Interfaces C and Matlab data.
 * This function is the MEX-file gateway routine. Please see the Matlab
 * MEX-file documentation (http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f43721.html)
 * for more information.
 */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  /* allocate variables */
  struct input *X;
  struct options_direct *opts;
  int m,p,n,z;
  int p_total,P_total;
  int W;
  int *P_vec;
  mxArray *mxbinned;
  int **binned,*binned_temp;
  int cur_P;
  int status;
  int temp_N;

  /* check number of inputs (nargin) and outputs (nargout) */
  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directbin:numArgs","1 or 2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directbin:numArgs","1 or 2 output arguments required.");

  X = ReadInput(prhs[0]);

  /* get or set options */
  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  /* Read in time range */
  ReadOptionsDirectTimeRange(opts,X);
  
  /* check options */
  if(opts->Delta_flag==0)
    {
      opts[0].Delta = (*opts).t_end-(*opts).t_start;
      opts[0].Delta_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:directbin:missingParameter","Missing parameter counting_bin_size. Using default value end_time-start_time=%f.\n",opts[0].Delta);
    }
  
  if(opts->Delta <= 0)
    {
      mxFree(opts);
      mxFreeInput(X); 
      mexErrMsgIdAndTxt("STAToolkit:directbin:invalidValue","counting_bin_size must be positive. It is currently set to %f.\n",opts[0].Delta);
    }

  if(opts->words_per_train_flag==0)
    {
      opts[0].words_per_train = (int)DEFAULT_WORDS_PER_TRAIN;
      opts[0].words_per_train_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:directbin:missingParameter","Missing parameter words_per_train. Using default value %d.\n",opts[0].words_per_train);
    }

  if(opts->words_per_train <= 0)
    {
      mxFree(opts);
      mxFreeInput(X); 
      mexErrMsgIdAndTxt("STAToolkit:directbin:invalidValue","words_per_train must be positive. It is currently set to %d.\n",opts[0].words_per_train);
    }

 if(opts->legacy_binning_flag==0)
    {
      opts[0].legacy_binning = (int)DEFAULT_LEGACY_BINNING;
      opts[0].legacy_binning_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:directbin:missingParameter","Missing parameter legacy_binning. Using default value %d.\n",opts[0].legacy_binning);
    }

  if((opts->legacy_binning!=0) & (opts->legacy_binning!=1))
    {
      mxFree(opts);
      mxFreeInput(X); 
      mexErrMsgIdAndTxt("STAToolkit:directbin:invalidValue","Option legacy_binning set to an invalid value. Must be 0 or 1. It is currently set to %d.\n",opts[0].legacy_binning);
    }

 if(opts->letter_cap_flag==0)
    {
      opts[0].letter_cap = (int)DEFAULT_LETTER_CAP;
      opts[0].letter_cap_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:directbin:missingParameter","Missing parameter letter_cap. Using default value %d.\n",opts[0].letter_cap);
    }

  if(opts->letter_cap<0)
    {
      mxFree(opts);
      mxFreeInput(X); 
      mexErrMsgIdAndTxt("STAToolkit:directbin:invalidValue","Option letter_cap set to an invalid value. Must be a positive integer or Inf. It is currently set to %d.\n",opts[0].letter_cap);
    }

  if((*X).N>1)
    {
      if(opts->sum_spike_trains_flag==0)
	{
	  opts[0].sum_spike_trains = (int)DEFAULT_SUM_SPIKE_TRAINS;
	  opts[0].sum_spike_trains_flag=1;
	  mexWarnMsgIdAndTxt("STAToolkit:directbin:missingParameter","Missing parameter sum_spike_trains. Using default value %d.\n",opts[0].sum_spike_trains);
	}

      if((opts->sum_spike_trains!=0) & (opts->sum_spike_trains!=1))
        {
          mxFree(opts);
          mxFreeInput(X); 
	  mexErrMsgIdAndTxt("STAToolkit:directbin:invalidValue","Option sum_spike_trains set to an invalid value. Must be 0 or 1. It is currently set to %d.\n",(*opts).sum_spike_trains);
        }
      
      if(opts->permute_spike_trains_flag==0)
	{
	  opts[0].permute_spike_trains = (int)DEFAULT_PERMUTE_SPIKE_TRAINS;
	  opts[0].permute_spike_trains_flag=1;
	  mexWarnMsgIdAndTxt("STAToolkit:directbin:missingParameter","Missing parameter permute_spike_trains. Using default value %d.\n",opts[0].permute_spike_trains);
	}

      if((opts->permute_spike_trains!=0) & (opts->permute_spike_trains!=1))
        {
          mxFree(opts);
          mxFreeInput(X); 
	  mexErrMsgIdAndTxt("STAToolkit:directbin:invalidValue","Option permute_spike_trains set to an invalid value. Must be 0 or 1. It is currently set to %d.\n",(*opts).permute_spike_trains);
        }
    }

  P_total = GetNumTrials(X);
  /* W is the number of letters in a word */
  W=GetWindowSize(opts);

  /* Allocate memory for pointers to pointers */
  if(opts[0].sum_spike_trains)
    temp_N = 1;
  else
    temp_N = X[0].N;
  binned = mxMatrixInt((*opts).words_per_train*P_total,temp_N*W);

  /* Allocate memory for P_vec */
  P_vec = (int *)mxMalloc((*X).M*sizeof(int));

  /* Do computation */
  status = DirectBinComp(X,opts,(*opts).words_per_train*P_total,W,P_vec,binned);
  if(status==EXIT_FAILURE)
    {
      mxFree(opts);
      mxFreeInput(X); 
      mxFreeMatrixInt(binned);
      mxFree(P_vec);
      mexErrMsgIdAndTxt("STAToolkit:directbin:failure","directbin failed.");
    }

  /* Create binned cell array */
  plhs[0] = mxCreateCellMatrix((*X).M,(*opts).words_per_train);
  p_total = 0;

  for(m=0;m<(*X).M;m++)
    {
      cur_P = (*X).categories[m].P;
      for(z=0;z<(*opts).words_per_train;z++)
	{
	  /* vectorize and transpose this matrix */
	  binned_temp = (int *)mxMalloc(W*temp_N*cur_P*sizeof(int));
	  
	  for(p=0;p<cur_P;p++)
	    for(n=0;n<temp_N*W;n++)
	      binned_temp[n*cur_P + p]=binned[p_total+p][n];
	  
	  p_total += cur_P;
      
	  mxbinned = mxCreateNumericMatrix(cur_P,temp_N*W,mxINT32_CLASS,mxREAL);
	  memcpy(mxGetData(mxbinned),binned_temp,cur_P*temp_N*W*sizeof(int));

	  mxSetCell(plhs[0],z*(*X).M+m,mxbinned);
	  
	  mxFree(binned_temp);
	}
    }

  /* output options used */
  if(nrhs<2)
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsDirect(prhs[1],opts);

  /* free memory */
  mxFreeInput(X); 
  mxFreeMatrixInt(binned);
  mxFree(P_vec);

  return;
}

