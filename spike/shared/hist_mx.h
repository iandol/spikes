/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
/* Histograms and estimates */
extern mxArray *AllocHist1D(int M,struct hist1d *hist_c,int *P_vec,int N);
extern void WriteHist1D(int M,struct hist1d *hist_c,mxArray *hist_mx);
extern struct hist1d *ReadHist1D(int M,mxArray *hist_mx,struct options_entropy *opts_ent);
extern mxArray *AllocEst(struct estimate *est_c,struct options_entropy *opts_ent);
extern mxArray *AllocMessage(struct message *msg_c);
extern mxArray *AllocNameValuePair(struct nv_pair *nv_c,char name_list[][MAXCHARS],int *name_idx,int N);
extern void WriteHist1DAgain(int M,struct hist1d *hist_c,mxArray *hist_mx);
extern void WriteEst(struct estimate *est,mxArray *est_mx);
extern void WriteMessage(struct message *msg_c,mxArray *msg_mx);
extern void WriteExtras(int X,struct nv_pair *ext_c,int e,mxArray *ext_mx);
extern void WriteNameValuePair(int N,struct nv_pair *nv_c,mxArray *nv_mx);

extern mxArray *AllocHist2D(struct hist2d *hist_c,int P_total,int N);
extern void WriteHist2D(struct hist2d *hist_c,mxArray *hist_mx);
extern struct hist2d *ReadHist2D(mxArray *hist_mx,struct options_entropy *opts_ent);
extern void WriteHist2DAgain(struct hist2d *hist_c,mxArray *hist_mx);

extern mxArray *AllocHistCond(int M,struct histcond *hist_c,int P_total,int *P_vec,int N);
extern void WriteHistCond(struct histcond *hist_c,mxArray *hist_mx);
extern struct histcond *ReadHistCond(mxArray *hist_mx,struct options_entropy *opts_ent);
extern void WriteHistCondAgain(struct histcond *hist_c,mxArray *hist_mx);

extern mxArray *AllocHist1DVec(int M,struct hist1dvec *hist_c,int P_total,int *P_vec,int N);
extern void WriteHist1DVec(struct hist1dvec *hist_c,mxArray *hist_mx);
extern struct hist1dvec *ReadHist1DVec(mxArray *hist_mx,struct options_entropy *opts_ent);
extern void WriteHist1DVecAgain(struct hist1dvec *hist_c,mxArray *hist_mx);

