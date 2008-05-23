/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "toolkit_c.h"

int InfoCondComp(struct histcond *in,struct options_entropy *opts)
{
  struct hist1dvec *class_hist;
  struct hist1d *total_hist;
  int status;
 
  class_hist = (*in).class;
  total_hist = (*in).total;

  status = Entropy1DVecComp(class_hist,opts);
  status = Entropy1DComp(1,total_hist,opts);
  SubtractEst(total_hist[0].entropy,class_hist[0].entropy,(*in).information,opts);

  return EXIT_SUCCESS;
}


