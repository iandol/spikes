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

/** @file
 * @brief Parse options for TPMC entropy method.
 * Reads, writes, and checks options required for the TPMC entropy method.
 * @see entropy_mx.c
 */

/**
 * @brief Read and check options for TPMC entropy method.
 * Reads and checks options required for the TPMC entropy method.
 */
void read_options_entropy_tpmc(const mxArray *in,struct options_entropy *opts)
{
	opts->tpmc_possible_words_strategy_flag = ReadOptionsIntMember(in,"tpmc_possible_words_strategy",&(opts->tpmc_possible_words_strategy));

	if(opts->possible_words_flag==0)
	{
		if(opts->tpmc_possible_words_strategy_flag==0)
		{
			opts->possible_words = (double)DEFAULT_POSSIBLE_WORDS;
			opts->possible_words_flag = 1;
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing possible_words. Using default value \"recommended\".\n");
		}
		else
		{
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:deprecatedUsage","Using deprecated option tpmc_possible_words_strategy. Recommended to use possible_words instead.\n");
			if((opts->tpmc_possible_words_strategy!=0) && (opts->tpmc_possible_words_strategy!=1) && (opts->tpmc_possible_words_strategy!=2))
				mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","tpmc_possible_words_strategy must be 0, 1, or 2. The current value is %d.\n",(*opts).tpmc_possible_words_strategy);
		}
	}
	else if(opts->tpmc_possible_words_strategy_flag!=0)
		mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:deprecatedUsage","Ignoring deprecated option tpmc_possible_words_strategy. Using possible_words.\n");
}

/**
 * @brief Write options for TPMC entropy method.
 * Writes options used by the TPMC entropy method.
 */
mxArray *write_options_entropy_tpmc(const mxArray *in,struct options_entropy *opts)
{
	mxArray *out;

	out = mxDuplicateArray(in);

	WriteOptionsIntMember(out,"tpmc_possible_words_strategy",opts->tpmc_possible_words_strategy,opts->tpmc_possible_words_strategy_flag);

	return out;
}

