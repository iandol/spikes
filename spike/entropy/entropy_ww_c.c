/*
 *  Copyright 2006, Weill Medical College of Cornell University
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

double entropy_ww(struct hist1d *in,struct options_entropy *opts)
{
  double H=0;
  double N,m;
  int i;

  N = (double)(*in).P;
  
  if((*opts).ww_possible_words_strategy==0)
    m = (double)(*in).C; 
  else if((*opts).ww_possible_words_strategy==1)
    m = (double)(*in).N; 
  else if((*opts).ww_possible_words_strategy==2)
    m = max_possible_words(in);
  else
    m = (double)(*in).C; 

  for(i=0;i<(*in).C;i++)
    H -= (((*in).wordcnt[i]+(*opts).ww_beta)/(N+m*(*opts).ww_beta))*
	   dphi(1,(*in).wordcnt[i]+(*opts).ww_beta+1,N+m*(*opts).ww_beta+1);

  H = NAT2BIT(H);
  return H;
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
