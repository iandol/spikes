/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "direct.h"

struct options_direct *ReadOptionsDirect(const mxArray *in)
{
  struct options_direct *opts;

  opts = (struct options_direct *)mxMalloc(sizeof(struct options_direct));

  opts->t_start_flag = ReadOptionsDoubleMember(in,"start_time",&(opts->t_start));
  opts->t_end_flag = ReadOptionsDoubleMember(in,"end_time",&(opts->t_end));
  opts->Delta_flag = ReadOptionsDoubleMember(in,"counting_bin_size",&(opts->Delta));
  opts->words_per_train_flag = ReadOptionsIntMember(in,"words_per_train",&(opts->words_per_train));
  opts->sum_spike_trains_flag = ReadOptionsIntMember(in,"sum_spike_trains",&(opts->sum_spike_trains));
  opts->permute_spike_trains_flag = ReadOptionsIntMember(in,"permute_spike_trains",&(opts->permute_spike_trains));

  return opts;
}

mxArray *WriteOptionsDirect(const mxArray *in,struct options_direct *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsDoubleMember(out,"start_time",opts->t_start,opts->t_start_flag);
  WriteOptionsDoubleMember(out,"end_time",opts->t_end,opts->t_end_flag);

  WriteOptionsDoubleMember(out,"counting_bin_size",opts->Delta,opts->Delta_flag);
  WriteOptionsIntMember(out,"sum_spike_trains",opts->sum_spike_trains,opts->sum_spike_trains_flag);
  WriteOptionsIntMember(out,"permute_spike_trains",opts->permute_spike_trains,opts->permute_spike_trains_flag);
  WriteOptionsIntMember(out,"words_per_train",opts->words_per_train,opts->words_per_train_flag);

  mxFree(opts);

  return out;
}

void ReadOptionsDirectTimeRange(struct options_direct *opts,struct input *X)
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


