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
  struct options_entropy *opts_ent;
  double **embedded,*embedded_temp;
  int *n_vec,*a_vec;
  int N,R,S;
  int n,r;
  struct estimate *I_part,*I_count,*I_total;
  double *I_cont;
  int status;
  mxArray *temp;

  if( (nrhs<4) | (nrhs>5) )
    mexErrMsgIdAndTxt("STAToolkit:binlessinfo:numArgs","4 or 5 input arguments required.");
  if((nlhs<4) | (nlhs>5))
    mexErrMsgIdAndTxt("STAToolkit:binlessinfo:numArgs","4 or 5 output arguments required.");

  if(nrhs<5)
    {
      opts = ReadOptionsBinless(mxCreateEmptyStruct());
      opts_ent = ReadOptionsEntropy(mxCreateEmptyStruct());
    }  
  else if(mxIsEmpty(prhs[4]))
    {
      opts = ReadOptionsBinless(mxCreateEmptyStruct());
      opts_ent = ReadOptionsEntropy(mxCreateEmptyStruct());
    }
  else
    {
      opts = ReadOptionsBinless(prhs[4]);
      opts_ent = ReadOptionsEntropy(prhs[4]);
    }

  ReadOptionsEmbedRange(opts);

  /* SINGLETON */
  if(opts[0].single_strat_flag==0)
    {
      (*opts).single_strat = (int)DEFAULT_SINGLETON_STRATEGY;
      (*opts).single_strat_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:missingParameter","Missing parameter singleton_strategy. Using default value %d.",(*opts).single_strat);
    }

  if( ((*opts).single_strat!=0) & ((*opts).single_strat!=1) )
    {
      (*opts).single_strat = (int)DEFAULT_SINGLETON_STRATEGY;
      (*opts).single_strat_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:invalidValue","Option singleton_strategy set to an invalid value. Must be 0 or 1. Using default value %d.",(*opts).single_strat);
    }

  /* STRATIFICATION */
  if(opts[0].strat_strat_flag==0)
    {
      (*opts).strat_strat = (opts->rec_tag_flag && (opts->rec_tag==1)) ? 0 : (int)DEFAULT_STRATIFICATION_STRATEGY;
      (*opts).strat_strat_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:missingParameter","Missing parameter stratification_strategy. Using default value %d.",(*opts).strat_strat);
    }

  if( ((*opts).strat_strat!=0) & ((*opts).strat_strat!=1) & ((*opts).strat_strat!=2) )
    {
      (*opts).strat_strat = (opts->rec_tag_flag && (opts->rec_tag==1)) ? 0 : (int)DEFAULT_STRATIFICATION_STRATEGY;
      (*opts).strat_strat_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:invalidValue","Option stratification_strategy set to an invalid value. Must be 0, 1, or 2. Using default value %d.",(*opts).strat_strat);
    }

  /* USEALL */
  if(opts_ent[0].useall_flag==0)
    {
      (*opts_ent).useall=(int) DEFAULT_UNOCCUPIED_BINS_STRATEGY;
      opts_ent[0].useall_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:matrix2hist2d:missingOption","Missing option unoccupied_bins_strategy. Using default value %d.\n",(*opts_ent).useall);
    }

  if( (opts_ent[0].useall!=-1) & (opts_ent[0].useall!=0) & (opts_ent[0].useall!=1) )
   {
     (*opts_ent).useall=(int) DEFAULT_UNOCCUPIED_BINS_STRATEGY;
      opts_ent[0].useall_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:matrix2hist2d:invalidValue","Option unoccupied_bins_strategy set to an invalid value. Must be -1, 0, or 1. Using default value %d.\n",(*opts_ent).useall);
   }

  /* Estimates */
  if(opts_ent->E==0)
    {
      opts_ent->E=1;
      opts_ent->ent_est_meth[0] = 1;
    }

  N = mxGetM(prhs[0]);
  R = mxGetN(prhs[0]);
  embedded_temp = mxGetData(prhs[0]);
  embedded = mxMatrixDouble(N,R);
  for(n=0;n<N;n++)
    for(r=0;r<R;r++)
      embedded[n][r] = embedded_temp[r*N+n];
  
  if(mxGetNumberOfElements(prhs[1])!=N)
    {
      mxFree(opts);
      if((opts_ent->E)>0) 
        mxFree(opts_ent->ent_est_meth);
      if((opts_ent->var_est_meth_flag)>0) 
        mxFreeMatrixInt(opts_ent->var_est_meth);
      mxFree(opts_ent->V);
      mxFree(opts_ent);
      mxFree(embedded);
      mexErrMsgIdAndTxt("STAToolkit:binlessinfo:sizeMismatch","The number of elements in COUNTS must match the number of rows in X.");
    }

  if(mxIsClass(prhs[1],"int32")==0)
    mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:wrongType","COUNTS is not int32.");
  n_vec = (int *)mxMalloc(N*sizeof(int));
  memcpy(n_vec,mxGetPr(prhs[1]),N*sizeof(int));

  if(mxGetNumberOfElements(prhs[2])!=N)
    {
      mxFree(opts);
      if((opts_ent->E)>0) 
        mxFree(opts_ent->ent_est_meth);
      if((opts_ent->var_est_meth_flag)>0) 
        mxFreeMatrixInt(opts_ent->var_est_meth);
      mxFree(opts_ent->V);
      mxFree(opts_ent);
      mxFree(embedded);
      mxFree(n_vec);
      mexErrMsgIdAndTxt("STAToolkit:binlessinfo:sizeMismatch","The number of elements in CATEGORIES must match the number of rows in X.");
    }

  if(mxIsClass(prhs[2],"int32")==0)
    mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:wrongType","CATEGORIES is not int32.");
  a_vec = (int *)mxGetPr(prhs[2]);

  /* Have to put in a check about the number of categories not exceeding M */

  if(mxIsClass(prhs[3],"int32")==0)
    mexWarnMsgIdAndTxt("STAToolkit:binlessinfo:wrongType","M is not int32.");
  S = (int)mxGetScalar(prhs[3]);

  I_part = (struct estimate *)mxMalloc((*opts_ent).E*sizeof(struct estimate));
  plhs[0] = AllocEst(I_part,opts_ent);

  plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
  I_cont = mxGetData(plhs[1]);

  I_count = (struct estimate *)mxMalloc((*opts_ent).E*sizeof(struct estimate));
  plhs[2] = AllocEst(I_count,opts_ent);

  I_total = (struct estimate *)mxMalloc((*opts_ent).E*sizeof(struct estimate));
  plhs[3] = AllocEst(I_total,opts_ent);

  /* Do computation */
  status = BinlessInfoComp(opts,opts_ent,embedded,N,S,n_vec,a_vec,I_part,I_cont,I_count,I_total);

  WriteEst(I_part,plhs[0]);
  mxFree(I_part);

  WriteEst(I_count,plhs[2]);
  mxFree(I_count);

  WriteEst(I_total,plhs[3]);
  mxFree(I_total);

  if(nrhs<5)
    temp = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[4]))
    temp = WriteOptionsBinless(mxCreateEmptyStruct(),opts);
  else
    temp = WriteOptionsBinless(prhs[4],opts);
  plhs[4] = WriteOptionsEntropy(temp,opts_ent);

  mxFree(embedded);
  mxFree(n_vec);

  return;
}
