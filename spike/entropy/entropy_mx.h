/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
extern struct options_entropy *ReadOptionsEntropy(const mxArray *in);
extern mxArray *WriteOptionsEntropy(const mxArray *in,struct options_entropy *opts);

extern void read_options_entropy_null(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_entropy_null(const mxArray *in,struct options_entropy *opts);

extern void read_options_variance_null(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_variance_null(const mxArray *in,struct options_entropy *opts);

extern void read_options_entropy_tpmc(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_entropy_tpmc(const mxArray *in,struct options_entropy *opts);

extern void read_options_entropy_bub(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_entropy_bub(const mxArray *in,struct options_entropy *opts);

extern void read_options_entropy_ww(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_entropy_ww(const mxArray *in,struct options_entropy *opts);

extern void read_options_variance_boot(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_variance_boot(const mxArray *in,struct options_entropy *opts);

extern void read_options_entropy_nsb(const mxArray *in,struct options_entropy *opts);
extern mxArray *write_options_entropy_nsb(const mxArray *in,struct options_entropy *opts);

