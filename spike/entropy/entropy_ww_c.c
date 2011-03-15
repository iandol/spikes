/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include<gsl/gsl_sf.h>
#include "../shared/toolkit_c.h"

double phi(int k,double x);
double dphi(int k,double x1,double x2);

int entropy_ww(struct hist1d *in,struct options_entropy *opts,struct estimate *entropy)
{
	double H=0;
	double N,m;
	int i;

	N = (double)(*in).P;
	
	if(opts->possible_words_flag==0)
	{
		if(opts->ww_possible_words_strategy==0)
			m = (double)in->C; 
		else if(opts->ww_possible_words_strategy==1)
			m = (double)in->N; 
		else if(opts->ww_possible_words_strategy==2)
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
					return (double)(0.0);
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

	for(i=0;i<(*in).C;i++)
		H -= (((*in).wordcnt[i]+(*opts).ww_beta)/(N+m*(*opts).ww_beta))*dphi(1,(*in).wordcnt[i]+(*opts).ww_beta+1,N+m*(*opts).ww_beta+1);

	entropy->value = NAT2BIT(H);
	return EXIT_SUCCESS;
}

double phi(int k,double x)
{  
	double y;

	y = gsl_sf_psi_n(k-1,x);

	return y;
}

double dphi(int k,double x1,double x2)
{
	double y;

	y = phi(k,x1) - phi(k,x2);

	return y;
}
