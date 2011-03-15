/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

#include "../shared/toolkit_c.h"

int variance_boot(struct hist1d *in, int (*entropy_fun)(struct hist1d *, struct options_entropy *, struct estimate *), struct options_entropy *opts, struct nv_pair *variance)
{
	double *H_b,var_H,H_bar;
	double B;
	int *cumcnt;
	int b,p,p1,c,c1,j;
	struct hist1d *boot;
	int e_status, status = EXIT_SUCCESS;
#ifdef DEBUG
	int n;
#endif
	int *boot_wordcnt;

	srand((unsigned int)(*opts).boot_random_seed);
	B = (double)(*opts).boot_num_samples;

	if((*in).P==1)
		var_H=0;
	else
	{
		/* If useall variable is not set, set it to ignore */
		if((*opts).useall_flag==0)
			(*opts).useall=-1;

		boot = (struct hist1d *)malloc(sizeof(struct hist1d));
		(*boot).P = (*in).P;
		(*boot).N = (*in).N;
		(*boot).wordlist = MatrixInt((*in).C,(*boot).N);
		(*boot).wordcnt = (double *)calloc((*in).C,sizeof(double));
		(*boot).entropy = CAllocEst(opts);
 
		/* Make cumulative word count */
		cumcnt = (int *)malloc((*in).C*sizeof(int));
		cumcnt[0] = (int)(*in).wordcnt[0];
		for(c=1; c<(*in).C; c++)
			cumcnt[c] = cumcnt[c-1]+(int)(*in).wordcnt[c];
		
		H_bar = 0;
		H_b = (double *)malloc((*opts).boot_num_samples*sizeof(double));
	 
		/*** Choose B bootstrap samples ***/
		for(b=0; b<(*opts).boot_num_samples; b++)
		{
			boot_wordcnt = (int *)calloc((*in).C,sizeof(int));

			/* Draw P samples with replacement */
			for(p=0; p<(*boot).P; p++)
			{
				/* Pick a number p1 between 0 and P-1. */
				p1 = rand()%(*boot).P;

				/* The first wordcnt[0] samples refer to wordlist[0], the next wordcnt[1] samples refer to wordlist[1], and so on. */
				/* Increment the cnt corresponding to the pth element. */
				c1=0;
				while(p1>=cumcnt[c1])
					c1++;
				boot_wordcnt[c1]++;
			}
			
			/* Scroll through the list and copy over the words */
			(*boot).C=0;
			for(j=0; j<(*in).C; j++)
			{
				/* Here's where we weed out the empty bins if we are told to do so */
				if((boot_wordcnt[j]>0) | ((*opts).useall>-1))
				{
					memcpy((*boot).wordlist[(*boot).C],(*in).wordlist[j],(*boot).N*sizeof(int));
					(*boot).wordcnt[(*boot).C] = (double)boot_wordcnt[j];
					(*boot).C++;
				}
			}
			free(boot_wordcnt);
			
#ifdef DEBUG
			printf("\n");
			for(j=0; j<(*boot).C; j++)
			{
				printf("wordlist[%d]=",j);
				for(n=0;n<(*boot).N;n++)
					printf("%d ",(*boot).wordlist[j][n]);
				printf("wordcnt[%d]=%f\n",j,(*boot).wordcnt[j]);
			}
#endif
			
			/* Now that we've got bootcnt, let's compute the entropy */
			e_status = entropy_fun(boot,opts,boot->entropy);
			if(e_status!=EXIT_SUCCESS)
				status = e_status;
			H_b[b] = boot->entropy[0].value;
			H_bar += H_b[b];
		}
		FreeMatrixInt((*boot).wordlist);
		free((*boot).wordcnt);
		CFreeEst(boot->entropy,opts);
		free(boot);
		free(cumcnt);

		/*** Compute the mean of the bootstrap samples ***/
		H_bar /= B;
		
		/*** Compute the variance of the bootstrap samples ***/
		var_H = 0;
		for(b=0; b<(*opts).boot_num_samples; b++)
			var_H += (H_b[b] - H_bar)*(H_b[b] - H_bar);

		var_H /= (B-1);
		
		free(H_b);
	}

	variance->value = var_H;
	return status;
}

