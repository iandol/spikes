/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
extern struct options_binless *ReadOptionsBinless(const mxArray *in);
extern mxArray *WriteOptionsBinless(const mxArray *in,struct options_binless *opts);
