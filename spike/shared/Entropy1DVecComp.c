/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "toolkit_c.h"

int Entropy1DVecComp(struct hist1dvec *in,struct options_entropy *opts)
{
  struct estimate *temp2;
  struct hist1d *vec;
  int m;
  int status;
 
  vec = (*in).vec;

  status = Entropy1DComp((*in).M,vec,opts);

  /* Calculation information from histograms */
  temp2 = CAllocEst(opts);
  ZeroEst((*in).entropy,opts);
  for(m=0;m<(*in).M;m++)
    {
      ScaleEst(vec[m].entropy,((double)vec[m].P)/((double)(*in).P),temp2,opts);
      IncEst((*in).entropy,temp2,opts);
    }
  
  CFreeEst(temp2,opts);

  return EXIT_SUCCESS;
}

