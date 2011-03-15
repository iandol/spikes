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
  struct options_metric *opts;
  int p,P_total,N;
  double *d,***d_in;
  int *d_dims;
  int i,j,k;
  double **times;
  int **labels,*counts;
  mxArray *mxtimes,*mxlabels;
  int status;

  /* prhs[0] = N */
  /* prhs[1] = times */
  /* prhs[2] = labels */
  /* prhs[3] = opts */

  if( (nrhs<3) | (nrhs>4) )
    mexErrMsgIdAndTxt("STAToolkit:metricdist:numArgs","3 or 4 input arguments required.");
  if( (nlhs<1) | (nlhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:metricdist:numArgs","1 or 2 output arguments required.");

  if(mxGetNumberOfElements(prhs[1]) != mxGetNumberOfElements(prhs[2]))
    mexErrMsgIdAndTxt("STAToolkit:metricdist:sizeMismatch","The dimensions of TIMES and LABELS must match.");

  if(nrhs<4)
    opts = ReadOptionsMetric(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[3]))
    opts = ReadOptionsMetric(mxCreateEmptyStruct());
  else
    opts = ReadOptionsMetric(prhs[3]);

  /**********************************************/
  /* Read in options */
  /**********************************************/

  /* Read in shift cost */
  if(opts->num_q==0)
    {
      opts->q = (double *)mxMalloc(sizeof(double));
      opts->q[0] = 1/((opts->t_end)-(opts->t_start));
      opts->num_q = 1;
      mexWarnMsgIdAndTxt("STAToolkit:metricdist:missingParameter","Missing parameter shift_cost. Using default value 1/(end_time-start_time)=%f.\n",opts->q[0]);
    }
  
  for(k=0;k<opts->num_q;k++)
    if(opts->q[k]<0)
      {
        mxFree(opts->q);
        mxFree(opts->k);
        mxFree(opts);
        mexErrMsgIdAndTxt("STAToolkit:metricdist:invalidValue","Values of shift_cost must not be negative. Element %d has a value of %f.\n",k,opts[k]);
      }
  
  /* Read in parallel_strategy */
  if(opts->parallel_flag==0)
    {
      if(opts->num_q==1)
	opts->parallel = (int) DEFAULT_PARALLEL_SINGLE;
      else
	opts->parallel = (int) DEFAULT_PARALLEL_ALL;
      opts->parallel_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:metricdist:missingParameter","Missing parameter parallel. Using default value %d.\n",(*opts).parallel);
    }

  if((opts->parallel < 0) | (opts->parallel > 1))
      mexWarnMsgIdAndTxt("STAToolkit:metricdist:invalidValue","Option parallel set to an invalid value. Must be 0 or 1. Using default value %d.\n",(*opts).parallel);

  /* Read in metric_family */
  if(opts->metric_flag==0)
    {
      opts->metric = (int) DEFAULT_METRIC;
      opts->metric_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:metricdist:missingParameter","Missing parameter metric_family. Using default value %d.\n",(*opts).metric);
    }

  if((opts->metric < 0) | (opts->metric > 1))
    mexWarnMsgIdAndTxt("STAToolkit:metricdist:invalidValue","Option metric_family set to an invalid value. Must be 0 or 1. Using default value %d.\n",(*opts).metric);

  N = (int)mxGetScalar(prhs[0]);
  
  if(N>1) /* If multineuron */
    {
      /* Read in label cost */
      if(opts->num_k==0)
	{
	  opts->k = (double *)mxMalloc((opts->num_q)*sizeof(double));
	  opts->num_k = opts->num_q;
	  for(k=0;k<opts->num_k;k++)
	    opts->k[k] = DEFAULT_LABEL_COST;
	  
	  mexWarnMsgIdAndTxt("STAToolkit:metricdist:missingParameter","Missing parameter label_cost. Using default value %f.\n",opts->k[0]);
	}

      if(opts->num_q!=opts->num_k)
        {
          mxFree(opts->q);
          mxFree(opts->k);
          mxFree(opts);
          mexErrMsgIdAndTxt("STAToolkit:metricdist:mismatchedParameter","Number of shift_cost parameters and number of label_cost parameters must be equal.\n");
        }

      for(k=0;k<opts->num_k;k++)
	if((opts->k[k]<0) | (opts->k[k]>2))
          {
            mxFree(opts->q);
            mxFree(opts->k);
            mxFree(opts);
            mexErrMsgIdAndTxt("STAToolkit:metricdist:invalidValue","Values of label cost must between 0 and 2. Element %d has a value of %f.\n",k,opts[k]);
          }

      if(opts->metric)
        {
          mxFree(opts->q);
          mxFree(opts->k);
          mxFree(opts);
          mexErrMsgIdAndTxt("STAToolkit:metricdist:multineuron","Interval metric not allowed for multisite data.");
        }
    }

  P_total = mxGetNumberOfElements(prhs[1]);

  counts = (int *)mxCalloc(P_total,sizeof(int));
  times = (double **)mxCalloc(P_total,sizeof(double *));
  labels = (int **)mxCalloc(P_total,sizeof(int *));

  /* Read in times cell array */
  for(p=0;p<P_total;p++)
  {
    mxtimes = mxGetCell(prhs[1],p);
    counts[p] = mxGetNumberOfElements(mxtimes);
    times[p] = mxGetPr(mxtimes);

    if(IsSortedDouble(counts[p],times[p])==0)
      {
        mxFree(opts->q);
        mxFree(opts->k);
        mxFree(opts);
        mxFree(counts);
        mxFree(times);
        mxFree(labels);
        mexErrMsgIdAndTxt("STAToolkit:metricdist:outOfOrder","Spike times out of order.");
      }

    mxlabels = mxGetCell(prhs[2],p);
    labels[p] = mxGetData(mxlabels);
    
    if(mxGetNumberOfElements(mxtimes)!=mxGetNumberOfElements(mxlabels))
      {
        mxFree(opts->q);
        mxFree(opts->k);
        mxFree(opts);
        mxFree(counts);
        mxFree(times);
        mxFree(labels);
        mexErrMsgIdAndTxt("STAToolkit:metricdist:sizeMismatch","The dimensions of TIMES and LABELS must match.");
      }
  }

  /* Allocate memory for d */
  d_dims = (int *)mxMalloc(3*sizeof(int));
  d_dims[0] = P_total;
  d_dims[1] = P_total;
  d_dims[2] = (*opts).num_q;
  plhs[0] = mxCreateNumericArray(3,d_dims,mxDOUBLE_CLASS,mxREAL);
  d = mxGetPr(plhs[0]);

  /* Make d_in into a 3-D array */
  d_in = mxMatrix3Double(P_total,P_total,(*opts).num_q);

  /* Do computation */
  if(N<2) /* If single neuron */
    { 
      if((*opts).parallel==0)
	status = MetricDistSingleQComp(opts,P_total,counts,times,d_in);
      else
	status = MetricDistAllQComp(opts,P_total,counts,times,d_in);
    }

  else /* Else multineuron */
    {
      if((*opts).parallel==0)
	status = MetricDistSingleQKComp(opts,N,P_total,counts,times,labels,d_in);
      else
	status = MetricDistAllQKComp(opts,N,P_total,counts,times,labels,d_in);
    }

  if(status==EXIT_FAILURE)
    {
      mxFree(opts->q);
      mxFree(opts->k);
      mxFree(opts);
      mxFree(counts);
      mxFree(times);
      mxFree(labels);
      mxFreeMatrix3Double(d_in);
      mxFree(d_dims);
      mexErrMsgIdAndTxt("STAToolkit:metricdist:failure","metricdist failed.");
    }
  
  for(i=0;i<P_total;i++)
    for(j=0;j<P_total;j++)
      for(k=0;k<(*opts).num_q;k++)
	d[k*P_total*P_total + j*P_total + i] = d_in[i][j][k];

  if(nrhs<4)
    plhs[1] = WriteOptionsMetric(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[3]))
    plhs[1] = WriteOptionsMetric(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsMetric(prhs[3],opts);

  mxFreeMatrix3Double(d_in);
  mxFree(d_dims);
  mxFree(counts);
  mxFree(times);
  mxFree(labels);
  
  return;
}

