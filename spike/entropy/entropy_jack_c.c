/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

#include "../shared/toolkit_c.h"

int entropy_jack(struct hist1d *in,struct options_entropy *opts,struct estimate *entropy)
{
	double *H_j,H_bar,H_corr,H_raw;
	double N;
	int j;
	struct hist1d *jack;

	N = (double) (*in).P;

	if((*in).P==1)
		H_corr=0;
	else
	{
		jack = (struct hist1d *)malloc(sizeof(struct hist1d));
		(*jack).P = (*in).P-1;
		(*jack).C = (*in).C;
		(*jack).wordcnt = (double *)malloc((*jack).C*sizeof(double));

		H_j = (double *)malloc((*in).C*sizeof(double));

		/* Find H_j and H_bar */
		H_bar = 0;
		for(j=0;j<(*in).C;j++)
		{
			memcpy((*jack).wordcnt,(*in).wordcnt,(*in).C*sizeof(double));
			(*jack).wordcnt[j]--;
			H_j[j] = EntropyPlugin(jack);
			H_bar += (*in).wordcnt[j]*H_j[j];
		}
		H_bar/=N;

		free((*jack).wordcnt);
		free(jack);
		free(H_j);

		H_raw = EntropyPlugin(in);

		H_corr = N*H_raw - (N-1)*H_bar;
	}

	entropy->value = H_corr;
	return EXIT_SUCCESS;
}

