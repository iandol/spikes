/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

#include "../shared/toolkit_c.h"

int entropy_tpmc(struct hist1d *in,struct options_entropy *opts,struct estimate *entropy)
{
	double H_raw;
	double N,*cnt,m;

	N = (double)in->P;

	if(opts->possible_words_flag==0)
	{
		if(opts->tpmc_possible_words_strategy==0)
			m = (double)in->C; 
		else if(opts->tpmc_possible_words_strategy==1)
			m = (double)in->N; 
		else if(opts->tpmc_possible_words_strategy==2)
			m = max_possible_words(in,1);
		else
			m = (double)in->C;
	}
	else
		if(opts->possible_words>0)
			m = opts->possible_words;
		else
			switch((int)(opts->possible_words))
			{
				case 0: /* Inf */
					entropy->value = INFINITY;
					return EXIT_SUCCESS;
				case -1: /* recommended */
					m = (double)in->C;
					break;
				case -2: /* unique */
					m = (double)in->C;
					break;
				case -3: /* total */
					m = (double)in->P;
					break;
				case -4: /* possible */
					m = max_possible_words(in,0);
					break;
				case -5: /* min_tot_pos */
					m = max_possible_words(in,1);
					break;
				case -6: /* min_lim_tot_pos */
					m = MIN(1e5,max_possible_words(in,1));
					break;
			}

	cnt = in->wordcnt;

	H_raw = EntropyPlugin(in);
	entropy->value = H_raw + ((m-1)/(2*N*log(2)));

	return EXIT_SUCCESS;
}

