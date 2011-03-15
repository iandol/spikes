/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#define DEFAULT_SUM_SPIKE_TRAINS 0
#define DEFAULT_PERMUTE_SPIKE_TRAINS 0
#define DEFAULT_WORDS_PER_TRAIN 1
#define DEFAULT_LEGACY_BINNING 0
#define DEFAULT_LETTER_CAP 0

struct options_direct{
  double t_start; int t_start_flag;
  double t_end; int t_end_flag;
  double Delta; int Delta_flag;
  int sum_spike_trains; int sum_spike_trains_flag;
  int permute_spike_trains; int permute_spike_trains_flag;
  int words_per_train; int words_per_train_flag;
  int legacy_binning; int legacy_binning_flag;
  int letter_cap; int letter_cap_flag;
};

extern void ReadOptionsDirectTimeRange(struct options_direct *opts,struct input *X);

extern void BinTimes(double *t,int q_start,int q_end,int *binned,double Delta, double t_start,int letter_cap);
extern int GetWindowSize(struct options_direct *opts);
extern void Merge(int **sorted1,int *sort_idx1,int P_total,int N,
		  int M,int *P_vec,
		  int **sorted2, int *sort_idx2);
extern int CompWords(int *a,int *b,int N);

extern int DirectBinComp(struct input *X,struct options_direct *opts,int P_total,int W,int *P_vec,int **binned);
extern int GetNumWords(struct input *X,struct options_direct *opts);
extern int DirectCountCondComp(int **binned,int P_total,int N,
			       int *P_vec,int M,
			       struct histcond *cond_hist);
extern int DirectCountClassComp(int **binned,int **hashed,int P_total,int N,int S,
				int *P_vec,int M,
				struct hist1dvec *class_hist,
				int **sorted1,int *sort_idx1);
extern int DirectCountTotal2Comp(int **binned,int P_total,int N,int S,
				 int *P_vec,int M,
				 struct hist1d *total_hist,
				 int **sorted1,int *sort_idx1);
extern int DirectCountTotalComp(int **binned,int **hashed,int P_total,int N,int S,struct hist1d *hist);
extern void GetBSL(int **binned,int P_total,int N,int *B_ptr,int *S_ptr,int *L_ptr);
extern void HashWords(int **binned,int P,int N,int B,int S,int L,int **hashed);
