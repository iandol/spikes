/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
extern struct options_ctwmcmc *ReadOptionsCTWMCMC(const mxArray *in);
extern mxArray *WriteOptionsCTWMCMC(const mxArray *in,struct options_ctwmcmc *opts);

extern mxArray *WriteCTWTree(struct ctwtree **pptree, int ntrees, int format);
extern void WriteCTWNode(mxArray *pstruct, struct ctwtree *ptree, struct ctwnode *pnode);
extern struct ctwtree **ReadCTWTree(const mxArray *pmx, int &ntrees, int format, double memory_expansion);
