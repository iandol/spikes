/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#define DEFAULT_CLUSTERING_EXPONENT -2
#define DEFAULT_PARALLEL_ALL 1
#define DEFAULT_PARALLEL_SINGLE 0
#define DEFAULT_METRIC 0
#define DEFAULT_LABEL_COST 0

struct options_metric{
  double t_start; int t_start_flag;
  double t_end; int t_end_flag;
  double *q; /**< shift cost (Matlab's meshgrid style) - used by jni toolkit. */
  int num_q; /**< Number of shift cost (Matlab's meshgrid style) - used by jni toolkit. */
  double *k; /**< label cost (Matlab's meshgrid style) - used by jni toolkit. */
  int num_k; /**< number of label cost (Matlab's meshgrid style) - used by jni toolkit. */
  double *temp_q; /**< temporarily holds q values - used by jni toolkit */
  int temp_num_q; /**< temporarily holds number of q values - used by jni toolkit */
  double *temp_k; /**< temporarily holds k values - used by jni toolkit */
  int temp_num_k; /**< temporarily holds number of k values - used by jni toolkit */
  double z; int z_flag;
  int metric; int metric_flag;
  int parallel; int parallel_flag;
};

/* General */

extern void ReadOptionsMetricTimeRange(struct options_metric *opts,struct input *X);

extern int MetricOpenComp(struct input *X,
			  struct options_metric *opts,
			  int P_total,
			  double **times,
			  int **labels,
			  int *counts,
			  int *categories);
extern int MetricClustComp(struct options_metric *opts,
			   double **d_in,
			   int *m_list,
			   int M,
			   int P,
			   double **cm_in);

extern void MakeSubtrains(double *b,int *s,int N,int L,double **b_sub);
extern void MakeIndex(int prod_n,int L,int *n,int **j_mat,int **j_mat_sorted,int **j_prev_mat_sorted,int *j_sum_sorted);

/* Single Q */

extern int MetricDistSingleQComp(struct options_metric *opts,
				 int P_total,
				 int *counts,
				 double **times,
				 double ***d);
extern int MetricDistSingleQKComp(struct options_metric *opts,
				  int N,
				  int P_total,
				  int *counts,
				  double **times,
				  int **labels,
				  double ***d);
extern double DistSingleQ(double *a,double *b,int M,int N,double q,int metric_type);
extern double DistSingleQK(
			   double *a,  /* a: vector of spike times in S_a */
			   double *b,  /* b: vector of spike times in S_b */
			   int *r,     /* r: vector of labels in S_a */
			   int *s,     /* s: vector of labels in S_b */
			   int M,      /* M: number of spikes in S_a */
			   int N,      /* N: number of spikes in S_b */
			   int L,      /* Number of labels */
			   double q,
			   double k);
extern double ComputeDist(int prod_n,int M,int L,int *j_sum_sorted,int **j_mat_sorted,int **j_prev_mat_sorted,int *r,double *a,double **b_sub,double k,double q);

/* All Q */

extern int MetricDistAllQComp(struct options_metric *opts,
			      int P_total,
			      int *counts,
			      double **times,
			      double ***d);

extern void DistAllQCritical(double *a,int M,
			     double *b,int N,
			     int R,double *lcrits,int metric_type);
extern void DistAllQFinal(int M,
			  int N,
			  int R,
			  double *lcrits,
			  double *q, int num_q,
			  double *d);
extern int MetricDistAllQKComp(struct options_metric *opts,
			       int L,
			       int P_total,
			       int *counts,
			       double **times,
			       int **labels,
			       double ***d);
extern void DistAllQK(
			double *a,  /* a: vector of spike times in S_a */
			double *b,  /* b: vector of spike times in S_b */
			int *r,     /* r: vector of labels in S_a */
			int *s,     /* s: vector of labels in S_b */
			int M,      /* M: number of spikes in S_a */
			int N,      /* N: number of spikes in S_b */
			int L,     /* Number of labels */
			double *q,
			double *k,
			int num_q,
			double *d
			);
extern void DistAllQKCritical(
			double *sa,  /* times for each spike in a */
			int *la, /* labels for each spike in a */
			int na,      /* Number of spikes in a */
			double **sub, /* times for each spike b, arranged by subtrains */
			int bsize, /* Number of subtrain combos */ 
			int L,      /* Number of labels */
			int R,     /* Maximum number of matched links */
			int S,     /* Maximum number of unmatched links */
			int *sum_bv_sorted,
			int **bv_mat,
			int **jbrec_mat,
			double **clast
			);
extern void DistAllQKFinal(
		    int M,
		    int N,
		    int R,
		    int S,
		    double **clast,
		    double *q,
		    double *k,
		    int num_q,
		    double *d);
