/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"

double entropy_plugin(struct hist1d *in,struct options_entropy *opts)
{
  double H;
  
  H = EntropyPlugin(in);
  
  return H;
}

