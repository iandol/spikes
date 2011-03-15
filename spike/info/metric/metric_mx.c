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

struct options_metric *ReadOptionsMetric(const mxArray *in)
{
  mxArray *tmp;
  struct options_metric *opts;

  opts = (struct options_metric *)mxMalloc(sizeof(struct options_metric));

  opts->t_start_flag = ReadOptionsDoubleMember(in,"start_time",&(opts->t_start));
  opts->t_end_flag = ReadOptionsDoubleMember(in,"end_time",&(opts->t_end));

  /* shift cost */
  tmp = mxGetField(in,0,"shift_cost");
  if((tmp==NULL) || mxIsEmpty(tmp))
    opts->num_q = 0;
  else
    {
      opts->num_q = mxGetNumberOfElements(tmp);
      opts->q = (double *)mxMalloc((opts->num_q)*sizeof(double));
      memcpy(opts->q,mxGetPr(tmp),(opts->num_q)*sizeof(double));
    }

  /* shift cost */
  tmp = mxGetField(in,0,"label_cost");
  if((tmp==NULL) || mxIsEmpty(tmp))
    opts->num_k = 0;
  else
    {
      opts->num_k = mxGetNumberOfElements(tmp);
      opts->k = (double *)mxMalloc((opts->num_k)*sizeof(double));
      memcpy(opts->k,mxGetPr(tmp),(opts->num_k)*sizeof(double));
    }

  opts->parallel_flag = ReadOptionsIntMember(in,"parallel",&(opts->parallel));
  opts->metric_flag = ReadOptionsIntMember(in,"metric_family",&(opts->metric));
  opts->z_flag = ReadOptionsDoubleMember(in,"clustering_exponent",&(opts->z));

  return opts;
}

mxArray *WriteOptionsMetric(const mxArray *in,struct options_metric *opts)
{
  mxArray *out,*tmp;

  out = mxDuplicateArray(in);

  WriteOptionsDoubleMember(out,"start_time",opts->t_start,opts->t_start_flag);
  WriteOptionsDoubleMember(out,"end_time",opts->t_end,opts->t_end_flag);

  if((opts->num_q)>0)
    {
      tmp = mxCreateDoubleMatrix(1,opts->num_q,mxREAL);
      memcpy(mxGetPr(tmp),opts->q,(opts->num_q)*sizeof(double));
      mxAddAndSetField(out,0,"shift_cost",tmp);
      mxFree(opts->q);
    }

  if((opts->num_k)>0)
    {
      tmp = mxCreateDoubleMatrix(1,opts->num_k,mxREAL);
      memcpy(mxGetPr(tmp),opts->k,(opts->num_k)*sizeof(double));
      mxAddAndSetField(out,0,"label_cost",tmp);
      mxFree(opts->k);
    }

  WriteOptionsIntMember(out,"parallel",opts->parallel,opts->parallel_flag);
  WriteOptionsIntMember(out,"metric_family",opts->metric,opts->metric_flag);
  WriteOptionsDoubleMember(out,"clustering_exponent",opts->z,opts->z_flag);
 
  mxFree(opts);

  return out;
}

void ReadOptionsMetricTimeRange(struct options_metric *opts,struct input *X)
{
  if(opts->t_start_flag==0)
    {
      opts->t_start = GetStartTime(X);
      opts->t_start_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsTimeRange:missingParameter","Missing parameter start_time. Extracting from input: %f.\n",opts->t_start);
    }

  if(opts->t_end_flag==0)
    {
      opts->t_end = GetEndTime(X);
      opts->t_end_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsTimeRange:missingParameter","Missing parameter end_time. Extracting from input: %f.\n",opts->t_end);
    }

  if((opts->t_start)>(opts->t_end))
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsTimeRange:badRange","Lower limit greater than upper limit for start_time and end_time.\n");
}

