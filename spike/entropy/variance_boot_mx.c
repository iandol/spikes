/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"
#include "../shared/toolkit_mx.h"

void read_options_variance_boot(const mxArray *in,struct options_entropy *opts)
{
  opts->boot_random_seed_flag = ReadOptionsIntMember(in,"boot_random_seed",&(opts->boot_random_seed));
  opts->boot_num_samples_flag = ReadOptionsIntMember(in,"boot_num_samples",&(opts->boot_num_samples));

  if(opts->boot_random_seed_flag==0)
    {
      opts->boot_random_seed = (unsigned int)DEFAULT_BOOT_RANDOM_SEED;
      opts->boot_random_seed_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing parameter boot_random_seed. Using default value %d.\n",(*opts).boot_random_seed);
    }
  
  if(opts->boot_num_samples_flag==0)
    {
      opts->boot_num_samples = (unsigned int)DEFAULT_BOOT_NUM_SAMPLES;
      opts->boot_num_samples_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing parameter boot_num_samples. Using default value %d.\n",(*opts).boot_num_samples);
    }
  
  if(opts->boot_num_samples<=0)
    mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","Number of bootstrap samples must be postive. The current value is %d.\n",opts->boot_num_samples);
}

mxArray *write_options_variance_boot(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsIntMember(out,"boot_random_seed",opts->boot_random_seed,opts->boot_random_seed_flag);
  WriteOptionsIntMember(out,"boot_num_samples",opts->boot_num_samples,opts->boot_num_samples_flag);

  return out;
}

