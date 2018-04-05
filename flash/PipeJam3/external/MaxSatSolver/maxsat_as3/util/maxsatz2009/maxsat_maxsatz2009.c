#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

//#include <sys/times.h>
#include <sys/types.h>
#include <limits.h>

//#include <unistd.h>

#include "../maxsatz.h"

int setupMaxSatz(char* input_file)
{
	int i;
  long begintime, endtime, mess;
//  struct tms *a_tms;
  FILE *fp_time;
  
  callback_function = callbackFunction;
  
//  a_tms = ( struct tms *) malloc( sizeof (struct tms));
//  mess=times(a_tms); begintime = a_tms->tms_utime;

  printf("c ----------------------------\n");
  printf("c - Weighted Partial MaxSATZ -\n");
  printf("c ----------------------------\n");
#ifdef DEBUG
  printf("c DEBUG mode ON\n");
#endif
  
  build_simple_sat_instance(input_file);
  UB = HARD_WEIGHT;
    printf("o %lli\n", UB);
      init();
      dpl();
	  do_callback(0);
    
 // mess=times(a_tms); endtime = a_tms->tms_utime;
  
  printf("c Learned clauses = %i\n", INIT_BASE_NB_CLAUSE - BASE_NB_CLAUSE);
  printf("c NB_MONO= %lli, NB_BRANCHE= %lli, NB_BACK= %lli \n", 
	 NB_MONO, NB_BRANCHE, NB_BACK);
  if (UB >= HARD_WEIGHT) {
    printf("s UNSATISFIABLE\n");
  } else {
    printf("s OPTIMUM FOUND\nc Optimal Solution = %lli\n", UB);
    printf("v");
    for (i = 0; i < NB_VAR; i++) {
      if (var_best_value[i] == FALSE)
	printf(" -%i", i + 1);
      else
	printf(" %i", i + 1);
    }
    printf(" 0\n");
  }

 // printf ("Program terminated in %5.3f seconds.\n",
//	  ((double)(endtime-begintime)/CLK_TCK));

//  fp_time = fopen("resulttable", "a");
//  fprintf(fp_time, "wpmsz-2.5 %s %5.3f %lld %lld %lld %d %d %d %d\n", 
//	  input_file, ((double)(endtime-begintime)/CLK_TCK), 
//	  NB_BRANCHE, NB_BACK,  
//	  UB, NB_VAR, INIT_NB_CLAUSE, NB_CLAUSE-INIT_NB_CLAUSE, CMTR[0]+CMTR[1]);
//  printf("wpmsz-2.5 %s %5.3f %lld %lld %lld %d %d %d %d\n", 
//	 	 input_file, ((double)(endtime-begintime)/CLK_TCK), 
//	 NB_BRANCHE, NB_BACK,
//	 UB, NB_VAR, INIT_NB_CLAUSE, NB_CLAUSE-INIT_NB_CLAUSE, CMTR[0]+CMTR[1]);
//  fclose(fp_time);
}

void
runMaxSatz(int * clauses, int nclauses)
{

  int nclauses_processed = 0;
  const int * clauses_ptr = clauses;
  int i = BASE_NB_CLAUSE;
  int j;
  int weight = 0;
  int lits[10000];
  int length = 0; 
  int next_is_weight = 1;

  NB_VAR = 0;
  while (nclauses_processed < nclauses) {
    int entry = *clauses_ptr;

    if (entry == 0) {
      next_is_weight = 1;
      ++ nclauses_processed;
    } else {
      if (next_is_weight) {
	next_is_weight = 0;
      } else {
	if (abs(entry) > NB_VAR) {
	  NB_VAR = abs(entry);
	}
      }
    }
    ++ clauses_ptr;
  }

  NB_CLAUSE = nclauses;

  if (NB_VAR > tab_variable_size ||
      NB_CLAUSE > tab_clause_size - INIT_BASE_NB_CLAUSE) {
    return;
  }

  NB_CLAUSE = NB_CLAUSE + BASE_NB_CLAUSE;
  INIT_NB_CLAUSE = NB_CLAUSE;

  instance_type = 1;
  partial = 0;





  nclauses_processed = 0;
  clauses_ptr = clauses;

  while (nclauses_processed < nclauses) {
    int entry = *clauses_ptr;

    if (entry == 0) {
      sat[i] = (int *)malloc((length+1) * sizeof(int));
      for (j=0; j<length; j++) {
	if (lits[j] < 0) 
	  sat[i][j] = abs(lits[j]) - 1 + NB_VAR;
	else 
	  sat[i][j] = lits[j]-1;
      }
      sat[i][length] = NONE;
      clause_length[i] = length;
      clause_weight[i] = weight;
      if (partial == 0)
	HARD_WEIGHT += weight;
      clause_state[i] = ACTIVE;

      ++ i;
      weight = 0;
      length = 0;
      ++ nclauses_processed;
    } else {
      if (weight == 0) {
	weight = entry;
      } else {
	lits[length] = entry;
	++ length;
      }
    }
    ++ clauses_ptr;
  }

  build_structure();
  eliminate_redundance();
  if (clean_structure() == FALSE) {
    return;
  }

  UB = HARD_WEIGHT;

  init();
  dpl();
}

void getCurrentSolutionMaxSatz(int* output)
{
	int i;
	for (i = 0; i < num_vars; i++) {
	  if (var_best_value[i] == FALSE)
		 output[i] = var_best_value[i];
	}
}
