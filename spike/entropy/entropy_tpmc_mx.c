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

void read_options_entropy_tpmc(const mxArray *in,struct options_entropy *opts)
{
  opts->tpmc_possible_words_strategy_flag = ReadOptionsIntMember(in,"tpmc_possible_words_strategy",&(opts->tpmc_possible_words_strategy));

  if(opts->tpmc_possible_words_strategy_flag==0)
    {
      opts->tpmc_possible_words_strategy = (int)DEFAULT_TPMC_POSSIBLE_WORDS_STRATEGY;
      opts->tpmc_possible_words_strategy_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing tpmc_possible_words_strategy. Using default value %d.\n",(*opts).tpmc_possible_words_strategy);
    }
  
  if((opts->tpmc_possible_words_strategy!=0) & (opts->tpmc_possible_words_strategy!=1) & (opts->tpmc_possible_words_strategy!=2))
    {
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","tpmc_possible_words_strategy must be 0, 1, or 2. The current value is %d.\n",(*opts).tpmc_possible_words_strategy);
    }
}

mxArray *write_options_entropy_tpmc(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsIntMember(out,"tpmc_possible_words_strategy",opts->tpmc_possible_words_strategy,opts->tpmc_possible_words_strategy_flag);

  return out;
}

