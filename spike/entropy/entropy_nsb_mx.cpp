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
 * @brief Parse options for NSB entropy method.
 * Reads, writes, and checks options required for the NSB entropy method.
 * @see entropy_mx.c
 */

/**
 * @brief Read and check options for NSB entropy method.
 * Reads and checks options required for the NSB entropy method.
 */
void read_options_entropy_nsb(const mxArray *in,struct options_entropy *opts)
{
	opts->nsb_precision_flag = ReadOptionsDoubleMember(in,"nsb_precision",&(opts->nsb_precision));

	if(opts->possible_words_flag==0)
		{
			opts->possible_words = (double)DEFAULT_POSSIBLE_WORDS;
			opts->possible_words_flag = 1;
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing possible_words. Using default value \"recommended\".\n");
		}

	if(opts->nsb_precision_flag==0)
		{
			opts->nsb_precision = (double)DEFAULT_NSB_PRECISION;
			opts->nsb_precision_flag = 1;
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing nsb_precision. Using default value %f.\n",(*opts).nsb_precision);
		}
	
	if(opts->nsb_precision<=0)
		mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","nsb_precision must be greater than zero. The current value is %d.\n",opts->nsb_precision);
}

/**
 * @brief Write options for NSB entropy method.
 * Writes options used by the NSB entropy method.
 */
mxArray *write_options_entropy_nsb(const mxArray *in,struct options_entropy *opts)
{
	mxArray *out;

	out = mxDuplicateArray(in);

	WriteOptionsDoubleMember(out,"nsb_precision",opts->nsb_precision,opts->nsb_precision_flag);

	return out;
}

