/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
/* Input data structure */
extern struct input *ReadInput(const mxArray *in);
extern void mxFreeInput(struct input *X);
extern mxArray *WriteInput(struct input *X,int L);

