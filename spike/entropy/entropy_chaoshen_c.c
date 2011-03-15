/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

#include "../shared/toolkit_c.h"

int entropy_chaoshen(struct hist1d *in,struct options_entropy *opts,struct estimate *entropy)
{
	int *f;
	double n;
	int S;
	int i;
	double pihat,pitilde,Chat,H;

	n = (double)(*in).P;
	S = (*in).C;

	/* Get counts of counts */
	f = (int *)calloc((*in).P+1,sizeof(int));
	for(i=0;i<S;i++)
		f[(int)(*in).wordcnt[i]]++;

	Chat = 1 - (f[1]/n);

	/* Then compute entropy */
	H = 0;
	for(i=0;i<S;i++)
	{
		pihat = (*in).wordcnt[i]/n;
		pitilde = pihat*Chat;
		if((*in).wordcnt[i]>0)
			H -= (pitilde*log(pitilde))/(1-pow(1-pitilde,n));
	}  
	entropy->value = NAT2BIT(H);
	
	free(f);

	return EXIT_SUCCESS;
}
