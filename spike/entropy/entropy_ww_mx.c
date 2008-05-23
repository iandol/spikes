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

void read_options_entropy_ww(const mxArray *in,struct options_entropy *opts)
{
  opts->ww_possible_words_strategy_flag = ReadOptionsIntMember(in,"ww_possible_words_strategy",&(opts->ww_possible_words_strategy));
  opts->ww_beta_flag = ReadOptionsDoubleMember(in,"ww_beta",&(opts->ww_beta));

  if(opts->ww_possible_words_strategy_flag==0)
    {
      opts->ww_possible_words_strategy = (int)DEFAULT_WW_POSSIBLE_WORDS_STRATEGY;
      opts->ww_possible_words_strategy_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing ww_possible_words_strategy. Using default value %d.\n",(*opts).ww_possible_words_strategy);
    }

  if((opts->ww_possible_words_strategy!=0) & (opts->ww_possible_words_strategy!=1) & (opts->ww_possible_words_strategy!=2))
    {
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","ww_possible_words_strategy must be 0, 1, or 2. The current value is %d.\n",(*opts).ww_possible_words_strategy);
    }

  if(opts->ww_beta_flag==0)
    {
      opts->ww_beta = (double)DEFAULT_WW_BETA;
      opts->ww_beta_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing ww_beta. Using default value %f.\n",(*opts).ww_beta);
    }
  
  if(opts->ww_beta<0)
    mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","ww_beta must be greater than or equal to zero. The current value is %d.\n",opts->ww_beta);
}

mxArray *write_options_entropy_ww(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsIntMember(out,"ww_possible_words_strategy",opts->ww_possible_words_strategy,opts->ww_possible_words_strategy_flag);
  WriteOptionsIntMember(out,"ww_beta",opts->ww_beta,opts->ww_beta_flag);

  return out;
}

