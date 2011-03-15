/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "toolkit_c.h"

int Info2DComp(struct hist2d *in,struct options_entropy *opts)
{
	struct estimate *temp;
	int j_status, r_status, c_status, status = EXIT_SUCCESS;
	
	j_status = Entropy1DComp(1,(*in).joint,opts);
	if(j_status!=EXIT_SUCCESS)
		status = j_status;
	r_status = Entropy1DComp(1,(*in).row,opts);
	if(r_status!=EXIT_SUCCESS)
		status = r_status;
	c_status = Entropy1DComp(1,(*in).col,opts);
	if(c_status!=EXIT_SUCCESS)
		status = c_status;

	temp = CAllocEst(opts);

	AddEst((*in).row[0].entropy,(*in).col[0].entropy,temp,opts);
	SubtractEst(temp,(*in).joint[0].entropy,(*in).information,opts);

	CFreeEst(temp,opts);

	return status;
}

