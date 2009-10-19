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

struct options_binless *ReadOptionsBinless(const mxArray *in)
{
  struct options_binless *opts;

  opts = (struct options_binless *)mxMalloc(sizeof(struct options_binless));

  opts->t_start_flag = ReadOptionsDoubleMember(in,"start_time",&(opts->t_start));
  opts->t_end_flag = ReadOptionsDoubleMember(in,"end_time",&(opts->t_end));
  opts->w_start_flag = ReadOptionsDoubleMember(in,"start_warp",&(opts->w_start));
  opts->w_end_flag = ReadOptionsDoubleMember(in,"end_warp",&(opts->w_end));
  opts->D_min_flag = ReadOptionsIntMember(in,"min_embed_dim",&(opts->D_min));
  opts->D_max_flag = ReadOptionsIntMember(in,"max_embed_dim",&(opts->D_max));
  opts->warp_strat_flag = ReadOptionsIntMember(in,"warping_strategy",&(opts->warp_strat));
  opts->single_strat_flag = ReadOptionsIntMember(in,"singleton_strategy",&(opts->single_strat));
  opts->strat_strat_flag = ReadOptionsIntMember(in,"stratification_strategy",&(opts->strat_strat));

  return opts;
}

mxArray *WriteOptionsBinless(const mxArray *in,struct options_binless *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsDoubleMember(out,"start_time",opts->t_start,opts->t_start_flag);
  WriteOptionsDoubleMember(out,"end_time",opts->t_end,opts->t_end_flag);
  WriteOptionsDoubleMember(out,"start_warp",opts->w_start,opts->w_start_flag);
  WriteOptionsDoubleMember(out,"end_warp",opts->w_end,opts->w_end_flag);
  WriteOptionsIntMember(out,"min_embed_dim",opts->D_min,opts->D_min_flag);
  WriteOptionsIntMember(out,"max_embed_dim",opts->D_max,opts->D_max_flag);
  WriteOptionsIntMember(out,"warping_strategy",opts->warp_strat,opts->warp_strat_flag);
  WriteOptionsIntMember(out,"singleton_strategy",opts->single_strat,opts->single_strat_flag);
  WriteOptionsIntMember(out,"stratification_strategy",opts->strat_strat,opts->strat_strat_flag);

  mxFree(opts);

  return out;
}
void ReadOptionsWarpRange(struct options_binless *opts)
{
  if(opts->w_start_flag==0)
    {
      opts->w_start = (double)DEFAULT_START_WARP;
      opts->w_start_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsWarpRange:missingParameter","Missing parameter start_warp. Using default value %f.\n",(*opts).w_start);
    }

  if(opts->w_end_flag==0)
    {
      opts->w_end = (double)DEFAULT_END_WARP;
      opts->w_end_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsWarpRange:missingParameter","Missing parameter end_warp. Using default value %f.\n",(*opts).w_end);
    }

  if((*opts).w_start>(*opts).w_end)
     mexErrMsgIdAndTxt("STAToolkit:ReadOptionsWarpRange:badRange","Lower limit greater than upper limit for start_warp and end_warp.\n");
}

void ReadOptionsEmbedRange(struct options_binless *opts)
{
  if(opts->D_min_flag==0)
    {
      opts->D_min = (int)DEFAULT_MIN_EMBED_DIM;
      opts->D_min_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:missingParameter","Missing parameter min_embed_dim. Using default value %d.\n",(*opts).D_min);
    }

  if(opts->D_max_flag==0)
    {
      opts->D_max = (int)DEFAULT_MAX_EMBED_DIM;
      opts->D_max_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:missingParameter","Missing parameter max_embed_dim. Using default value %d.\n",(*opts).D_max);
    }

  if((*opts).D_min>(*opts).D_max)
    mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:badRange","Lower limit %d greater than upper limit %d for min_embed_dim and max_embed_dim.\n",(*opts).D_min,(*opts).D_max);
}

void ReadOptionsBinlessTimeRange(struct options_binless *opts,struct input *X)
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

