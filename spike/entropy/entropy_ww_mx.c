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

void read_options_entropy_ww(const mxArray *in,struct options_entropy *opts)
{
	opts->ww_possible_words_strategy_flag = ReadOptionsIntMember(in,"ww_possible_words_strategy",&(opts->ww_possible_words_strategy));
	opts->ww_beta_flag = ReadOptionsDoubleMember(in,"ww_beta",&(opts->ww_beta));

	if(opts->possible_words_flag==0)
	{
		if(opts->ww_possible_words_strategy_flag==0)
		{
			opts->possible_words = (double)DEFAULT_POSSIBLE_WORDS;
			opts->possible_words_flag = 1;
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingParameter","Missing possible_words. Using default value \"recommended\".\n");
		}
		else
		{
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:deprecatedUsage","Using deprecated option ww_possible_words_strategy. Recommended to use possible_words instead.\n");
			if((opts->ww_possible_words_strategy!=0) && (opts->ww_possible_words_strategy!=1) && (opts->ww_possible_words_strategy!=2))
				mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidValue","ww_possible_words_strategy must be 0, 1, or 2. The current value is %d.\n",(*opts).ww_possible_words_strategy);
		}
	}
	else if(opts->ww_possible_words_strategy_flag!=0)
		mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:deprecatedUsage","Ignoring deprecated option ww_possible_words_strategy. Using possible_words.\n");

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
	WriteOptionsDoubleMember(out,"ww_beta",opts->ww_beta,opts->ww_beta_flag);

	return out;
}

