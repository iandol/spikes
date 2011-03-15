/*
 *  Copyright 2010, Weill Medical College of Cornell University
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
	int v_status, e_status, status = EXIT_SUCCESS;
 
	class_hist = (*in).classcond;
	total_hist = (*in).total;

	v_status = Entropy1DVecComp(class_hist,opts);
	if(v_status!=EXIT_SUCCESS)
		status = v_status;
	e_status = Entropy1DComp(1,total_hist,opts);
	if(e_status!=EXIT_SUCCESS)
		status = e_status;
	SubtractEst(total_hist[0].entropy,class_hist[0].entropy,(*in).information,opts);

	return status;
}


