/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#define ENT_EST_METHS 7
#define SPEC_VAR_EST_METHS 0
#define GEN_VAR_EST_METHS 2
#define DEFAULT_UNOCCUPIED_BINS_STRATEGY -1
#define DEFAULT_TPMC_POSSIBLE_WORDS_STRATEGY 0
#define DEFAULT_BUB_POSSIBLE_WORDS_STRATEGY 2
#define DEFAULT_BUB_LAMBDA_0 0
#define DEFAULT_BUB_K 11
#define DEFAULT_BUB_COMPAT 0
#define DEFAULT_WW_POSSIBLE_WORDS_STRATEGY 0
#define DEFAULT_WW_BETA 1
#define DEFAULT_BOOT_NUM_SAMPLES 100
#define DEFAULT_BOOT_RANDOM_SEED 1

struct options_entropy{
  int **var_est_meth; int var_est_meth_flag; int *V;
  int *ent_est_meth; int E;
  int useall; int useall_flag;
  int tpmc_possible_words_strategy; int tpmc_possible_words_strategy_flag;
  int bub_possible_words_strategy; int bub_possible_words_strategy_flag;
  double bub_lambda_0; int bub_lambda_0_flag;
  int bub_K; int bub_K_flag;
  int bub_compat; int bub_compat_flag;
  int ww_possible_words_strategy; int ww_possible_words_strategy_flag;
  double ww_beta; int ww_beta_flag;
  int boot_num_samples; int boot_num_samples_flag;
  int boot_random_seed; int boot_random_seed_flag;
};

struct nv_pair{
  double value;
  char name[MAXCHARS];
};

struct estimate{
  char name[MAXCHARS];
  double value;
  struct nv_pair *ve;
};

struct hist1d{
  int P;       /* Number of words used to generate the estimate */
  int C;       /* Number of unique words */
  int N;       /* Number of subwords */
  int **wordlist; /* List of words that appear (C long) */
  double *wordcnt; /* Number of times each word occurs (C long) */
  struct estimate *entropy;
};

extern int Entropy1DComp(int M,struct hist1d *in,struct options_entropy *opts);
extern double EntropyPlugin(struct hist1d *in);
extern double max_possible_words(struct hist1d *in);

extern double entropy_null(struct hist1d *in,struct options_entropy *opts);
extern double variance_null(struct hist1d *in,struct options_entropy *opts);

extern double entropy_plugin(struct hist1d *in,struct options_entropy *opts);
extern double entropy_tpmc(struct hist1d *in,struct options_entropy *opts);
extern double entropy_jack(struct hist1d *in,struct options_entropy *opts);
extern double entropy_ma(struct hist1d *in,struct options_entropy *opts);
extern double entropy_bub(struct hist1d *in,struct options_entropy *opts);
extern double entropy_chaoshen(struct hist1d *in,struct options_entropy *opts);
extern double entropy_ww(struct hist1d *in,struct options_entropy *opts);

extern double variance_jack(struct hist1d *in,double (*entropy_fun)(),struct options_entropy *opts);
extern double variance_boot(struct hist1d *in,double (*entropy_fun)(),struct options_entropy *opts);

