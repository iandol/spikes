/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#define DEFAULT_START_WARP -1
#define DEFAULT_END_WARP 1
#define DEFAULT_WARPING_STRATEGY 1
#define DEFAULT_MIN_EMBED_DIM 1
#define DEFAULT_MAX_EMBED_DIM 2
#define DEFAULT_SINGLETON_STRATEGY 0
#define DEFAULT_STRATIFICATION_STRATEGY 2
#define DEFAULT_REC_TAG 0
#define DEFAULT_CONT_MIN_EMBED_DIM 0
#define DEFAULT_CONT_MAX_EMBED_DIM 2

struct options_binless{
  double t_start; int t_start_flag;
  double t_end; int t_end_flag;
  double w_start; int w_start_flag;
  double w_end; int w_end_flag;
  int warp_strat; int warp_strat_flag;
  int D_max; int D_max_flag;
  int D_min; int D_min_flag;
  int single_strat; int single_strat_flag;
  int strat_strat; int strat_strat_flag;
  int rec_tag; int rec_tag_flag;
  int D_max_cont; int D_max_cont_flag;
  int D_min_cont; int D_min_cont_flag;
};

extern void ReadOptionsWarpRange(struct options_binless *opts);
extern void ReadOptionsEmbedRange(struct options_binless *opts);
extern void ReadOptionsBinlessTimeRange(struct options_binless *opts,struct input *X);

extern int BinlessOpenComp(struct input *X,
			   struct options_binless *opts,
			   int N,
			   int *n_vec,
			   int *a,
			   double **times);
extern int BinlessWarpComp(struct options_binless *opts,
			   double **times,
			   int *n_vec,
			   int N,
			   double **tau_j);
extern int BinlessEmbedComp(struct options_binless *opts,
			    double **warped,
			    int *n_vec,
			    int N,
			    int R,
			    double **embedded);
extern int BinlessInfoComp(struct options_binless *opts,
			   struct options_entropy *opts_ent,
			   double **embedded,
			   int N, /* number of spike trains */
			   int S, /* number of stimulus classes */
			   int *n_vec_int, /* number of spikes in each train */
			   int *a_vec, /* class id for each train */
			   struct estimate *I_part,
			   double *I_cont,
			   struct estimate *I_count,
			   struct estimate *I_total);
extern double legendreP(int l,double x);
extern void segfun(int N_n,int r,int *n_list,int *a_list,int S,double **c_mat,
	    int *N_Z,int **N_Z_a,int *b,
	    int *N_C,int *N_C_a,int *C_a,double **C,
	    int **N_G_a,int *u,int *N_n_a,struct options_binless *opts);
extern double I_cont_calc(double **C,int N_C,int r,int *C_a,int *N_C_a,int S);
extern double dist(double *a,double *b,int N);
extern void countfun(int *list,int N,int *cnt);
extern int FindX(int *in,int M,int X,int *idx);


