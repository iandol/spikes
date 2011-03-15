/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

#include "../../shared/toolkit_c.h"
#include "binless_c.h"

int BinlessEmbedComp(struct options_binless *opts,
		      double **warped,
		      int *n_vec,
		      int N,
		      int R,
		      double **embedded)
{
  int idx,q,h;
  double temp;

  for(idx=0;idx<N;idx++)
    for(h=0;h<R;h++)
      {
	temp=0;
        if(opts->rec_tag==0) /* episodic data */
	  for(q=0;q<n_vec[idx];q++)
	    temp+=legendreP(h,warped[idx][q]);
        else if(opts->rec_tag==1) /* continuous data */
	  for(q=0;q<n_vec[idx];q++)
            temp += warped[idx][q]*legendreP(h,opts->w_start+q*(opts->w_end-opts->w_start)/(n_vec[idx]-1));
	embedded[idx][h] = sqrt(2*h+1)*temp;
      }
  return EXIT_SUCCESS;
}

/* Computes Legendre polynomial with a recurrence relation */
/* See http://mathworld.wolfram.com/LegendrePolynomial.html Eq. 43 */
double legendreP(int l,double x)
{
  double Pl,Pl1,Pl2;
  int ll;

  Pl2 = 1;
  Pl1 = x;
  if(l==0)
    return Pl2;
  else if(l==1)
    return Pl1;
  else
    {
      for(ll=2;ll<=l;ll++)
	{
	  Pl = ((2*ll-1)*x*Pl1 - (ll-1)*Pl2)/ll;
	  Pl2 = Pl1;
	  Pl1 = Pl;
	}
      return Pl;
    }
}
