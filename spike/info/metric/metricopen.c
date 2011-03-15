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
#include "metric_c.h"
#include "metric_mx.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  struct input *X;
  struct options_metric *opts;
  int p,P_total,max_Q;
  int *categories,*counts;
  double **times;
  int **labels;
  int status;
  mxArray *mxtimes,*mxlabels;

  if( (nrhs<1) | (nrhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:metricopen:numArgs","1 or 2 input argument required.");
  if( (nlhs<3) | (nlhs>4) )
    mexErrMsgIdAndTxt("STAToolkit:metricopen:numArgs","3 or 4 output arguments required.");

  X = ReadInput(prhs[0]);

  if(nrhs<2)
    opts = ReadOptionsMetric(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsMetric(mxCreateEmptyStruct());
  else
    opts = ReadOptionsMetric(prhs[1]);

  /* Read in time range */
  ReadOptionsMetricTimeRange(opts,X);

  P_total = GetNumTrials(X);
  max_Q = GetMaxSpikes(X);

  counts = (int *)mxCalloc(P_total,sizeof(int));

  plhs[0] = mxCreateNumericMatrix(P_total,1,mxINT32_CLASS,mxREAL);
  categories = mxGetData(plhs[0]);

  /* Create times cell array */
  plhs[1] = mxCreateCellMatrix(P_total,1);
  times = (double **)mxCalloc(P_total,sizeof(double *));

  /* Create labels cell array */
  plhs[2] = mxCreateCellMatrix(P_total,1);
  labels = (int **)mxCalloc(P_total,sizeof(int *));

  for(p=0;p<P_total;p++)
    {
      mxtimes = mxCreateDoubleMatrix(1,((*X).N)*max_Q,mxREAL);
      times[p] = mxGetPr(mxtimes);
      mxSetCell(plhs[1],p,mxtimes);

      mxlabels = mxCreateNumericMatrix(1,((*X).N)*max_Q,mxINT32_CLASS,mxREAL);
      labels[p] = mxGetData(mxlabels);
      mxSetCell(plhs[2],p,mxlabels);
    }

  /* Do computation */
  status = MetricOpenComp(X,opts,P_total,times,labels,counts,categories);

  /* Shrink the times array */
  for(p=0;p<P_total;p++)
    {
      mxtimes = mxGetCell(plhs[1],p);
      mxSetN(mxtimes,counts[p]);

      mxlabels = mxGetCell(plhs[2],p);
      mxSetN(mxlabels,counts[p]);
    }
  
  if(nlhs==4)
    if((nrhs<2) || mxIsEmpty(prhs[1]))
      plhs[3] = WriteOptionsMetric(mxCreateEmptyStruct(),opts);
    else
      plhs[3] = WriteOptionsMetric(prhs[1],opts);
  else
    {
      if(opts->num_q)
        mxFree(opts->q);
      if(opts->num_k)
        mxFree(opts->k);
      mxFree(opts);
    }

  mxFreeInput(X);
  mxFree(counts);
  mxFree(times);
  mxFree(labels);

  return;
}

