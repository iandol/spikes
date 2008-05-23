/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"
/* #define DEBUG */

double variance_jack(struct hist1d *in,
		     double (*entropy_fun)(struct hist1d *, struct options_entropy *),
		     struct options_entropy *opts)
{
  double *H_j,H_bar,var_H;
  double N;
  int j;
  struct hist1d *jack;
#ifdef DEBUG
  int jj,n;
#endif

  N = (double) (*in).P;

  if((*in).P==1)
    var_H=0;
  else
    {
      /* If useall variable is not set, set it to ignore */
      if((*opts).useall_flag==0)
	(*opts).useall=-1;

      jack = (struct hist1d *)malloc(sizeof(struct hist1d));
      (*jack).P = (*in).P-1;
      (*jack).N = (*in).N;
      (*jack).wordcnt = (double *)malloc((*in).C*sizeof(double));
      (*jack).wordlist = MatrixInt((*in).C,(*jack).N);

       /* Find H_j and H_bar */
      H_bar = 0;
      H_j = (double *)malloc((*in).C*sizeof(double));

      /* Do jackknife replications. */
      for(j=0;j<(*in).C;j++)
	{
	  /* If we remove the only one in the bin AND 
	     we're ignoring empty bins */
	  if( ((*in).wordcnt[j]<2) & ((*opts).useall==-1) )
	    {
	      (*jack).C = (*in).C-1;
	      
	      /* The current bin's index is j.
		 There are j bins before this bin.
		 There are (*in).C-(j+1) bins after this bin. */
	      
	      /* If we're not on the first bin, copy the first part */
	      if(j>0)
		{
		  /* printf("Copying bins 0-%d to bins 0-%d (%d bins total)\n",j-1,j-1,j); */
		  memcpy((*jack).wordcnt,(*in).wordcnt,j*sizeof(double));
		  memcpy((*jack).wordlist[0],(*in).wordlist[0],j*(*jack).N*sizeof(int));
		}
	      
	      /* If we're not on the last bin, copy the rest */
	      if(j<(*in).C-1)
		{
		  /* printf("Copying bins %d-%d to bins %d-%d (%d bins total)\n",j+1,(*in).C-1,j,(*in).C-2,(*in).C-(j+1)); */
		  memcpy(&(jack->wordcnt[j]),&(in->wordcnt[j+1]),((*in).C-(j+1))*sizeof(double));
		  memcpy(&((*jack).wordlist[j][0]),&((*in).wordlist[j+1][0]),((*in).C-(j+1))*(*jack).N*sizeof(int));
		}
	    }
	  /* Else we're removing a word from a bin that has multiple words 
	     OR we are keeping empty bins */
	  else
	    {
	      (*jack).C = (*in).C;
	      
	      memcpy((*jack).wordcnt,(*in).wordcnt,(*in).C*sizeof(double));
	      memcpy(&((*jack).wordlist[0][0]),&((*in).wordlist[0][0]),(*jack).C*(*jack).N*sizeof(int));
	      
	      if((*in).wordcnt[j]>0)
		(*jack).wordcnt[j]--;
	    }
	  
#ifdef DEBUG
	  printf("\n");
	  for(jj=0;jj<(*jack).C;jj++)
	    {
	      printf("wordlist[%d]=",jj);
	      for(n=0;n<(*jack).N;n++)
		printf("%d ",(*jack).wordlist[jj][n]);
	      printf("wordcnt[%d]=%f\n",jj,(*jack).wordcnt[jj]);
	    }
#endif
	  
	  H_j[j] = entropy_fun(jack,opts);
	  H_bar += (*in).wordcnt[j]*H_j[j];
	}
      FreeMatrixInt((*jack).wordlist);
      free((*jack).wordcnt);
      free(jack);
      
      /* Compute the mean of the jackknife samples */
      H_bar /= N;
      
      /* Compute the variance of the jackknife samples */
      var_H = 0;
      for(j=0;j<(*in).C;j++)
	var_H += (*in).wordcnt[j]*(H_j[j]-H_bar)*(H_j[j]-H_bar);
      
      var_H *= ((N-1)/N);

      free(H_j);
    }
  
  return(var_H);
}
