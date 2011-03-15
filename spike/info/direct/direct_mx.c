/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Supports direct method gateway routines.
 * This file contains C code that supports the direct method
 * MEX-file gateway routines, but which is not directly compiled.
 * @see directbin.c, directcondcat.c, directcondformal.c,
 * directcondtime.c, directcountclass.c, directcountcond.c,
 * directcounttotal.c.
 */

#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "direct_c.h"
#include "direct_mx.h"

/**
 * @brief Read direct method options.
 * This function reads options for direct method routines from a
 * Matlab struct (*in), and returns a pointer to a C struct
 * options_direct (see direct_c.h).
 */
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
  opts->legacy_binning_flag = ReadOptionsIntMember(in,"legacy_binning",&(opts->legacy_binning));
  opts->letter_cap_flag = ReadOptionsIntMember(in,"letter_cap",&(opts->letter_cap));
  if((opts->letter_cap_flag) && (opts->letter_cap==(int)mxGetInf()))
    opts->letter_cap = 0; 

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
  WriteOptionsIntMember(out,"legacy_binning",opts->legacy_binning,opts->legacy_binning_flag);
  if((opts->letter_cap_flag) && (opts->letter_cap==0))
    WriteOptionsDoubleMember(out,"letter_cap",mxGetInf(),opts->letter_cap_flag);
  else
    WriteOptionsIntMember(out,"letter_cap",opts->letter_cap,opts->letter_cap_flag);

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


