/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"

double entropy_tpmc(struct hist1d *in,struct options_entropy *opts)
{
  double H_corr,H_raw;
  double N,*cnt,m;

  N = (double) (*in).P;

  if((*opts).tpmc_possible_words_strategy==0)
    m = (double)(*in).C; 
  else if((*opts).tpmc_possible_words_strategy==1)
    m = (double)(*in).N; 
  else if((*opts).tpmc_possible_words_strategy==2)
    m = max_possible_words(in);
  else
    m = (double)(*in).C; 

  cnt = (*in).wordcnt;

  H_raw = EntropyPlugin(in);
  H_corr = H_raw + ((m-1)/(2*N*log(2)));
  
  return H_corr;
}

