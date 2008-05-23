/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"
#include "../shared/toolkit_mx.h"

void read_options_entropy_bub(const mxArray *in,struct options_entropy *opts)
{
  opts->bub_possible_words_strategy_flag = ReadOptionsIntMember(in,"bub_possible_words_strategy",&(opts->bub_possible_words_strategy));
  opts->bub_lambda_0_flag = ReadOptionsDoubleMember(in,"bub_lambda_0",&(opts->bub_lambda_0));
  opts->bub_K_flag = ReadOptionsIntMember(in,"bub_K",&(opts->bub_K));
  opts->bub_compat_flag = ReadOptionsIntMember(in,"bub_compat",&(opts->bub_compat));

  if(opts->bub_possible_words_strategy_flag==0)
    {
      opts->bub_possible_words_strategy = (int)DEFAULT_BUB_POSSIBLE_WORDS_STRATEGY;
      opts->bub_possible_words_strategy_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing bub_possible_words_strategy. Using default value %d.\n",(*opts).bub_possible_words_strategy);
    }

  if((opts->bub_possible_words_strategy!=0) & (opts->bub_possible_words_strategy!=1) & (opts->bub_possible_words_strategy!=2))
    {
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","bub_possible_words_strategy must be 0, 1, or 2. The current value is %d.\n",(*opts).bub_possible_words_strategy);
    }

  if(opts->bub_lambda_0_flag==0)
    {
      opts->bub_lambda_0 = (double)DEFAULT_BUB_LAMBDA_0;
      opts->bub_lambda_0_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing bub_lambda_0. Using default value %f.\n",(*opts).bub_lambda_0);
    }
  
  if(opts->bub_lambda_0<0)
    mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","bub_lambda_0 must be greater than or equal to zero. The current value is %d.\n",opts->bub_lambda_0);
  
  if(opts->bub_K_flag==0)
    {
      opts->bub_K = (int)DEFAULT_BUB_K;
      opts->bub_K_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing parameter bub_K. Using default value %d.\n",(*opts).bub_K);
    }
  
  if(opts->bub_K<=0)
    mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","bub_K must be positive. The current value is %d.\n",opts->bub_K);
  
  if(opts->bub_compat_flag==0)
    {
      opts->bub_compat = (int)DEFAULT_BUB_COMPAT;
      opts->bub_compat_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing parameter bub_compat. Using default value %d.\n",(*opts).bub_compat);
    }
  
  if((opts->bub_compat_flag!=0) & (opts->bub_compat_flag!=1))
    {
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","bub_compat must be 0 or 1. The current value is %d.\n",(*opts).bub_compat);
    }
}

mxArray *write_options_entropy_bub(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsIntMember(out,"bub_possible_words_strategy",opts->bub_possible_words_strategy,opts->bub_possible_words_strategy_flag);
  WriteOptionsIntMember(out,"bub_lambda_0",opts->bub_lambda_0,opts->bub_lambda_0_flag);
  WriteOptionsIntMember(out,"bub_K",opts->bub_K,opts->bub_K_flag);
  WriteOptionsIntMember(out,"bub_compat",opts->bub_compat,opts->bub_compat_flag);

  return out;
}

