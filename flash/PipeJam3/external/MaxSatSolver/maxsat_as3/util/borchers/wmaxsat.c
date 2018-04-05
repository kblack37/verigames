/*
 * This program solves weighted max-sat problems in cnf format.  The code
 * uses the GSAT heuristic (with random walk) to find a good solution.  It
 * then does a Davis-Putnam like backtracking search to prove that the
 * solution is optimal.  (Of course, we might find a better solution during
 * the backtracking search, but this is unlikely.)  Note that the back
 * tracking is very simple, since there isn't any equivalent to the  unit
 * clause tracking that is useful in the weighted MAX-SAT problem.
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#ifndef BUILD_LIB
#include "../borchers.h"
#endif


/*
 * A constant used with the random number generator.
 */

#define BIG 077777l
int             rand();

/*
 * Allocate some important arrays for the problem data structure and for
 * information about the current solution.
 * 
 * the basic idea is that there is one entry for each literal.  The array
 * clauses contains pointers to chains of entries for the clauses 0, 1, ...
 * The array variables contains pointers to chains of entries for variables
 * 0, 1, ...
 * 
 * Note that we have variable and clause numbers run from 0 instead of 1.  The
 * routine for reading a problem will shift the variable numbers by 1.
 * 
 * For each entry,
 * next_in_clause        points to the next entry in the current clause.
 * next_in_var           points to the next entry with this variable.
 * clause_num            gives the number of the clause. 
 * var_num   		 gives the number of the variable. 
 * sense                 is 1 for true literals, 0 for false literals.
 * 
 * The array cur_soln gives the current solution, with 1's for True variables,
 * and 0's for False variables.  The array best_soln gives the best known
 * solution.
 * 
 * The array best_list contains a list of variables with the best improvement.
 * best_count gives the number of such variables.
 */

/*
 * Define true and false.
 */
#define TRUE 1
#define FALSE 0
#define UNDET -1

/*
 * Define a record type for the entries in the satisfiability problem data
 * structure.
 */


/*
 * Information about the variables.
 */
entry_ptr       vars[MAX_VARS];
int             num_vars;
int             cur_soln[MAX_VARS];
int             num_sat;
int             best_soln[MAX_VARS];
int             best_num_sat;
int             best_best_num_sat;
int             total_weight;
int             num_improve[MAX_VARS];
int             best_list[MAX_VARS];
int             best_count;
int             best_improve;
int             col_count[MAX_VARS];

/*
 * Information about the clauses.
 */
entry_ptr       clauses[MAX_CLAUSES];
int             num_clauses;
int             sat_count[MAX_CLAUSES];
int             row_count[MAX_CLAUSES];
int             clause_weights[MAX_CLAUSES];
int             max_weight = 0;
int             min_weight = 1000000;

/*
 * Data structure associated with the Davis-Putnam algorithm.
 */
typedef struct clause_rec *clause_ptr;

struct clause_rec {
     int             clause_num;
     clause_ptr      next;
     clause_ptr      prev;
};

/*
 * Information about variables for the Davis-Putnam algorithm.
 */
clause_ptr      undetermined_clauses;
clause_ptr      clause_records[MAX_CLAUSES];
int             done_flag;
int             cur_level;
int             unsat;
int             ub;
int             num_true[MAX_CLAUSES];
int             num_false[MAX_CLAUSES];
int             order[MAX_VARS];
int             btrackcount;

/*
 * Data structures and variables associated with picking the next variable.
 */
int             small_clauses[MAX_CLAUSES];
int             var_counts[MAX_VARS];
int             var_counts_iter[MAX_VARS];
int             pick_var_iter = 0;

/*
 * Data structures and variables associated with unit clause tracking.
 */
int             unit_fixed[MAX_VARS];
int             unit_vars[MAX_VARS];
int             unit_var_value[MAX_VARS];
int             track_iter = 0;

/*
 * WSAT Probability parameter.
 */
#define WALK_PROB 0.3


int             pick_first[MAX_VARS];
int pick_first_val(int ii) { if (pick_first[ii] == TRUE) return TRUE; else return FALSE; }
int pick_first_val_opp(int ii) { if (pick_first[ii] == TRUE) return FALSE; else return TRUE; }


/*
 * Read in the problem.
 */
int 
read_prob(char * filename)
{
     FILE           *fp;
     char            line[100];
     char            tempstr1[10];
     char            tempstr2[10];
     int             temp;
     int             i;
     entry_ptr       ptr;

     /*
      * First, open the file.
      */
     fp = fopen(filename, "r");

     /*
      * Read in the first few comment lines.
      */
     fgets(line, 100, fp);
     while (line[0] != 'p') {
	  fgets(line, 100, fp);
     };
     /*
      * Now, the p line is in the buffer.
      */
     sscanf(line, "%s %s %d %d", tempstr1, tempstr2, &num_vars, &num_clauses);
     /*
      * Initialize the arrays of pointers.
      */
     for (i = 0; i <= num_vars - 1; i++) {
	  vars[i] = (entry_ptr) NULL;
	  col_count[i] = 0;
     };
     for (i = 0; i <= num_clauses - 1; i++) {
	  clauses[i] = (entry_ptr) NULL;
	  row_count[i] = 0;
     };

     total_weight = 0;

     /*
      * Now, read in the clauses, one at a time.
      */
     for (i = 0; i <= num_clauses - 1; i++) {
	  fscanf(fp, "%d", &(clause_weights[i]));
	  if (clause_weights[i] > max_weight) {
	       max_weight = clause_weights[i];
          };
	  if (clause_weights[i] < min_weight) {
	       min_weight = clause_weights[i];
          };
	  total_weight = total_weight + clause_weights[i];
	  fscanf(fp, "%d", &temp);
	  while (temp != 0) {

	    /*
	      Make sure that this literal isn't already in the clause.
	      If it is, then just ignore it- keeping it in causes problems 
	      with the gsat heuristic.
	      */

	    ptr=clauses[i];
	    while (ptr != (entry_ptr) NULL)
	      {
		if (ptr->var_num == abs(temp)-1)
		  {
		    if ((ptr->sense == 1) && (temp > 0))
		      goto NEXT_LITERAL;
		    if ((ptr->sense == 0) && (temp < 0))
		      goto NEXT_LITERAL;
		  };
		ptr=ptr->next_in_clause;
	      };



	       /*
	        * Allocate an entry for this literal.
	        */
	       ptr = (entry_ptr) malloc(sizeof(struct entry));
	       ptr->clause_num = i;
	       ptr->var_num = abs(temp) - 1;
	       col_count[ptr->var_num] = col_count[ptr->var_num] + 1;
	       if (temp > 0) {
		    ptr->sense = 1;
	       } else {
		    ptr->sense = 0;
	       };
	       /*
	        * Now, link it into the data structure.
	        */
	       ptr->next_in_clause = clauses[i];
	       clauses[i] = ptr;
	       row_count[i] = row_count[i] + 1;

	       ptr->next_in_var = vars[ptr->var_num];
	       vars[ptr->var_num] = ptr;

	       /*
	        * Finally, get the next number out of the file.
	        */
	  NEXT_LITERAL:
	       fscanf(fp, "%d", &temp);
	  };
     };

	 return num_vars;
}


void getCurrentSolutionBorchers(int* output)
{
	int i;
	for (i = 0; i < num_vars; i++) {
	  output[i] = best_soln[i];
	}
}
	
/*
 * Produce a random solution.
 */

void 
rand_soln()
{
     int             j;
     double          r;

     for (j = 0; j <= num_vars - 1; j++) {
	  r = (rand() % (BIG + 1)) / ((float) BIG);
	  if (r > 0.5) {
	       cur_soln[j] = 1;
	  } else {
	       cur_soln[j] = 0;
          };
     };
}

/*
 * The SLM local search procedure.
 */
void 
slm(int max_flips)
{
     int             j;
     int             k;
     int             var;
     int             clause;
     int             sense;
     int             flipvar;
     entry_ptr       ptr;
     entry_ptr       ptr2;
//printf("slm");
     /*
      * Figure out how good the current solution is.  First, figure out how
      * many satisfying literals are in each clause.  Keep track of the
      * number of satisfied clauses as we do this.
      */
     num_sat = 0;
     for (j = 0; j <= num_clauses - 1; j++) {
	//	 printf("slm1");
	  ptr = clauses[j];
	  sat_count[j] = 0;
	  while (ptr != ((entry_ptr) NULL)) {
	       var = ptr->var_num;
	       if (cur_soln[var] == 1) {
		    if (ptr->sense == 1) {
			 sat_count[j] = sat_count[j] + 1;
        	    };
	       } else {
		    if (ptr->sense == 0) {
			 sat_count[j] = sat_count[j] + 1;
        	    };
	       };
	       ptr = ptr->next_in_clause;
	  };
	  if (sat_count[j] > 0) {
	       num_sat = num_sat + clause_weights[j];
          };
     };
     /*
      * Next, figure out how much improvement we would get by flipping each
      * variable.
      */

    for (j = 0; j <= num_vars - 1; j++) {
	  num_improve[j] = 0;
	  ptr = vars[j];
	  while (ptr != ((entry_ptr) NULL)) {
	       var = ptr->var_num;
	       clause = ptr->clause_num;
	       sense = ptr->sense;
	       switch (sat_count[clause]) {
	       case 0:
		    if ((sense == 1) && (cur_soln[j] == 0)) {
			 num_improve[j] = num_improve[j] + clause_weights[clause];
		    };
		    if ((sense == 0) && (cur_soln[j] == 1)) {
			 num_improve[j] = num_improve[j] + clause_weights[clause];
		    };
		    break;
	       case 1:
		    if ((sense == 1) && (cur_soln[j] == 1)) {
			 num_improve[j] = num_improve[j] - clause_weights[clause];
		    };
		    if ((sense == 0) && (cur_soln[j] == 0)) {
			 num_improve[j] = num_improve[j] - clause_weights[clause];
		    };
		    break;
	       };
	       ptr = ptr->next_in_var;
	  };
     };
     /*
      * Save the current solution as the best solution found so far.
      */
     for (j = 0; j <= num_vars - 1; j++) {
	  best_soln[j] = cur_soln[j];
     };
     best_num_sat = num_sat;

     /*
      * Next, loop through max_flips times, flipping a variable each time.
      */
     for (j = 1; j <= max_flips; j++) {
   //  if (max_flips > 0) 
     //  while (1) {
//printf("slm3");
	  if ((rand() % (BIG + 1)) / ((float) BIG) < WALK_PROB) {
	       /*
	        * In this case, do a random walk.
	        */
	       flipvar = rand() % num_vars;
	  } else {
	       /*
	        * Do a downhill move.
	        *
	        * First, get a list of the variables which give best
	        * improvement.
	        */
	       best_improve = -MAX_CLAUSES;
	       best_count = 0;
	       for (k = 0; k <= num_vars - 1; k++) {
		    if (num_improve[k] > best_improve) {
			 best_improve = num_improve[k];
			 best_count = 0;
		    };
		    if (num_improve[k] == best_improve) {
			 best_count++;
			 best_list[best_count] = k;
		    };
	       };

	       /*
	        * Next, pick a variable to flip.
	        */

	       flipvar = best_list[1 + (j % best_count)];

	  };


	  /*
	   * Next, flip the variables and compute changes to num_sat,
	   * sat_count, num_improve, and update best_soln if necessary.
	   */
	  num_sat = num_sat + num_improve[flipvar];
	  cur_soln[flipvar] = 1 - cur_soln[flipvar];
	  num_improve[flipvar] = -num_improve[flipvar];
	  ptr = vars[flipvar];
	  while (ptr != ((entry_ptr) NULL)) {
	       /*
	        * Check to see what will happen to the sat_count of the
	        * current clause. If it will change from n to n+1 or n-1,
	        * with n>2, then nothing significant has happened.  However,
	        * if will change sat_count from 1 to 0, or from 0 to 1, then
	        * we'll have to update num_improve for every variable in this
	        * clause.
	        */
	       var = ptr->var_num;
	       clause = ptr->clause_num;
	       sense = ptr->sense;
//printf("slm4");
	       if (sense == 1) {
		    if (cur_soln[flipvar] == 1) {
			 /*
			  * We just made a variable true in a true literal,
			  * increasing sat_count.
			  */
			 sat_count[clause] = sat_count[clause] + 1;
			 /*
			  * Now, if this just satisfied the clause, then we
			  * have to go through this clause, adjusting
			  * num_improve for each variable.
			  */
			 if (sat_count[clause] == 1) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if (ptr2->var_num != flipvar) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num]
								       - clause_weights[clause];
              			   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
			 /*
			  * Now, if we just increased sat_count to 2, then
			  * num_improve must be increased by 1 for the single
			  * variable that was keeping the clause satisfied.
			  */
			 if (sat_count[clause] == 2) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if ((ptr2->sense == cur_soln[ptr2->var_num]) &&
				       (ptr2->var_num != flipvar)) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num]
                                                                       + clause_weights[clause];
					break;
				   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
		    } else {
			 /*
			  * We just made a variable false in a true literal,
			  * decreasing sat_count.
			  */
			 sat_count[clause] = sat_count[clause] - 1;
			 /*
			  * Now, if this just unsatisfied the clause, then we
			  * have to go through this clause, adjusting
			  * num_improve for each variable.
			  */
			 if (sat_count[clause] == 0) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if (ptr2->var_num != flipvar) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num] 
								       + clause_weights[clause];
        			   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
			 /*
			  * Also, if this move just dropped sat_count down to
			  * 1, we need to go through the clause fixing up
			  * num_improve for the one variable that currently
			  * satisfies the clause.
			  */
			 if (sat_count[clause] == 1) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if (ptr2->sense == cur_soln[ptr2->var_num]) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num] 
								       - clause_weights[clause];
					break;
				   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
		    };
	       } else {
		    if (cur_soln[flipvar] == 1) {
			 /*
			  * We just made a variable true in a false literal,
			  * decreasing sat_count.
			  */
			 sat_count[clause] = sat_count[clause] - 1;
			 /*
			  * Now, if this just unsatisfied the clause, then we
			  * have to go through this clause, adjusting
			  * num_improve for each variable.
			  */
			 if (sat_count[clause] == 0) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if (ptr2->var_num != flipvar) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num] 
								       + clause_weights[clause];
				   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
			 /*
			  * Also, if this move just dropped sat_count down to
			  * 1, we need to go through the clause fixing up
			  * num_improve for the one variable that currently
			  * satisfies the clause.
			  */
			 if (sat_count[clause] == 1) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if (ptr2->sense == cur_soln[ptr2->var_num]) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num] 
								       - clause_weights[clause];
					break;
				   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
		    } else {
			 /*
			  * We just made a variable false in a false literal,
			  * increasing sat_count.
			  */
			 sat_count[clause] = sat_count[clause] + 1;
			 /*
			  * Now, if this just satisfied the clause, then we
			  * have to go through this clause, adjusting
			  * num_improve for each variable.
			  */
			 if (sat_count[clause] == 1) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if (ptr2->var_num != flipvar) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num] 
								       - clause_weights[clause];
				   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };
			 /*
			  * Now, if we just increased sat_count to 2, then
			  * num_improve must be increased by 1 for the single
			  * variable that was keeping the clause satisfied.
			  */
			 if (sat_count[clause] == 2) {
			      ptr2 = clauses[clause];
			      while (ptr2 != ((entry_ptr) NULL)) {
				   if ((ptr2->sense == cur_soln[ptr2->var_num]) &&
				       (ptr2->var_num != flipvar)) {
					num_improve[ptr2->var_num] = num_improve[ptr2->var_num] 
								       + clause_weights[clause];
					break;
				   };
				   ptr2 = ptr2->next_in_clause;
			      };
			 };

		    };
	       };
	       /*
	        * Move to next entry for this variable.
	        */
	       ptr = ptr->next_in_var;
	  };
	  /*
	   * Update best_soln if necessary.
	   */
	  if (num_sat > best_num_sat) {
	       best_num_sat = num_sat;
	       for (k = 0; k <= num_vars; k++) {
		    best_soln[k] = cur_soln[k];
	       }
	       do_callback(1);
	       if (best_num_sat == total_weight) {
		    break;
	       }
	  } else {
	    do_callback(0);
	  }
     };
}


/*
 * The Davis-Putnam backtracking search routine.
 */

/*
 * Update the best solution.
 * 
 * Take the current solution and put it into the array best_soln.
 * Any free variables are left fixed at FALSE.  
 */

void 
update_best_soln()
{
     int             i;
     int             j;

     for (i=0; i <= num_vars-1; i++) {
       best_soln[i]=FALSE;
     };
    for (i=0; i<= cur_level; i++) {
       best_soln[order[i]]=cur_soln[order[i]];
     };
     do_callback(1);
}

/*
 *  Print out the best solution.
 */
void 
print_best_solution()
{
     int             i;

     for (i=0; i<=num_vars-1; i++) {
       printf("%d %d \n",i+1,best_soln[i]);
     };
  
}


/*
 * Move a clause to the list of satisfied clauses.
 */
void
move_to_satisfied(int clause)
{
     clause_ptr      ptr;
     clause_ptr      ptrp;
     clause_ptr      ptrn;
     /*
      * Get a pointer to the record for this clause.
      */
     ptr = clause_records[clause];

     /*
      * First remove it from the list of undetermined clauses.
      */
     if (ptr->prev == (clause_ptr) NULL) {
	  undetermined_clauses = ptr->next;
	  if (undetermined_clauses != (clause_ptr) NULL) {
	       undetermined_clauses->prev = (clause_ptr) NULL;
	  };
     } else {
	  ptrp = ptr->prev;
	  ptrn = ptr->next;
	  ptrp->next = ptrn;
	  if (ptrn != (clause_ptr) NULL) {
	       ptrn->prev = ptrp;
          };
     };
}

/*
 * Move a clause to the list of satisfied clauses.
 */

void
move_to_undet(int clause)
{
     clause_ptr      ptr;

     /*
      * Get a pointer to the record for this clause.
      */
     ptr = clause_records[clause];

     /*
      * Next, add it to the list of undet clauses.
      */

     ptr->prev = (clause_ptr) NULL;
     ptr->next = undetermined_clauses;
     if (ptr->next != (clause_ptr) NULL) {
	  (ptr->next)->prev = ptr;
     };
     undetermined_clauses = ptr;
}

/*
 * Update the counts after fixing a variable at zero or one.
 */
void 
update_counts(int k, int val)
{
     entry_ptr       p;
     int             clause;

     p = vars[order[k]];

     while (p != ((entry_ptr) NULL)) {
	  clause = p->clause_num;

	  if (p->sense != val) {
	       num_false[clause]++;
	       if (num_false[clause] == row_count[clause]) {
		    unsat = unsat + clause_weights[clause];
	       };
	  } else {
	       num_true[clause]++;
	       if (num_true[clause] == 1) {
		    move_to_satisfied(clause);
	       };
	  };
	  p = p->next_in_var;
     };
}

/*
 * Undo the counts after unfixing a variable.
 */

void 
undo_counts(int k, int val)
{
     entry_ptr       p;
     int             clause;

     p = vars[order[k]];

     while (p != ((entry_ptr) NULL)) {
	  clause = p->clause_num;

	  if (p->sense != val) {
	       if (num_false[clause] == row_count[clause]) {
		    unsat = unsat - clause_weights[clause];
	       };
	       --num_false[clause];
	  } else {
	       --num_true[clause];
	       if (num_true[clause] == 0) {
		    move_to_undet(clause);
	       };
	  };
	  p = p->next_in_var;
     };
}

/*
 * Pick the next variable to branch on.  We pick a variable which appears in
 * the largest number of not-yet-satisfied clauses of the smallest size.
 * Thus if there are three clauses with only two variables left and these
 * clauses are not yet satisified, and there are no unit clauses, and
 * variable x5 appears in two of these clauses, then we will branch on x5.
 * 
 */

int 
pick_var()
{
     int             size;
     int             i;
     entry_ptr       p;
     int             var;
     int             best_var;
     int             count;
     int             small_count;
     clause_ptr      ptr;
     int             clause;

     do_callback(0);

     /*
      * Update the count of the number of times we've called pick_var.
      */
     pick_var_iter++;

     /*
      * First, determine the size of the smallest unsatisified clauses.
      */
     size = MAX_CLAUSES;

     small_count = 0;

     ptr = undetermined_clauses;

     while (ptr != (clause_ptr) NULL) {
	  i = ptr->clause_num;

	  if (row_count[i] - num_false[i] <= size) {
	       if (row_count[i] - num_false[i] != 0) {
		    if (row_count[i] - num_false[i] < size) {
			 size = row_count[i] - num_false[i];
			 small_clauses[0] = i;
			 small_count = 1;
		    } else {
			 small_clauses[small_count] = i;
			 small_count++;
		    };
	       };
	  };
	  ptr = ptr->next;
     };

     /*
      * If there are no clauses that are uncertain, then there's no real
      * point here  each clause is either satisfied or not, and it doesn't
      * matter what we do with the remaining variables.
      * 
      * If we get to this point, it means that we must have found a new best
      * solution (otherwise we would have fathomed the current solution.)
      * Thus we update ub at this point.
      * 
      * Because we need to return some variable, we pick the first unused
      * variable.  This is a bit of a kludge, but it is fast, and this will
      * only happen in rare circumstances.
      */
     if (small_count == 0) {
	  if (unsat < ub) {
	       ub = unsat;
	       printf("New Best Solution Found, %d \n", ub);
	       update_best_soln();
	  }

	  for (i = 0; i <= num_vars - 1; i++) {
	       if (cur_soln[i] == -1) {
		    return (i);
	       };
	  };
	  printf("Oops, we shouldn't be here!\n");
	  exit(1);
     };

     /*
      * Ok, now we know the size of the smallest unsatisfied clauses.
      * 
      * We could zero out an array of size num_vars and then keep the
      * count in this array.  However, this is rather expensive.  To
      * avoid this expense, we use a simple hack.  There are two 
      * arrays.  var_counts_iter[var] gives the iteration of pick_var
      * in which the count was last used.  If it doesn't match the 
      * current iteration, then we set the count to 1 and update 
      * var_counts_iter[var] to the current iteration.  
      *
      * Next, we look for the variable that appears in the most of these
      * clauses.
      * 
      */

     count = 0;

     for (i = 0; i <= small_count - 1; i++) {
	  clause = small_clauses[i];
	  p = clauses[clause];

	  while (p != ((entry_ptr) NULL)) {
	       var = p->var_num;

	       if (cur_soln[var] == -1) {
		    if (var_counts_iter[var] == pick_var_iter) {
			 var_counts[var] = var_counts[var] + clause_weights[clause];
			 if (var_counts[var] > count) {
			      count = var_counts[var];
			      best_var = var;
			 };
		    } else {
			 var_counts_iter[var] = pick_var_iter;
			 var_counts[var] = clause_weights[clause];
			 if (var_counts[var] > count) {
			      count = var_counts[var];
			      best_var = var;
			 };
		    };
	       };
	       p = p->next_in_clause;
	  };
     };


     /*
      * Now, return the selected variable.
      */
     return (best_var);
}

/*
 * Drop down a level in the search.
 */

void 
drop()
{

     cur_level++;

     order[cur_level] = pick_var();

     unit_fixed[order[cur_level]] = FALSE;

     if (done_flag == TRUE) {
	  return;
     };

     cur_soln[order[cur_level]] = pick_first_val(order[cur_level]);
     update_counts(cur_level, pick_first_val(order[cur_level]));
}

/*
 * Backtrack.
 */

void 
backtrack()
{

     btrackcount++;

     while (cur_level != -1) {
	  undo_counts(cur_level, cur_soln[order[cur_level]]);

	  if (unit_fixed[order[cur_level]] == TRUE) {
	       cur_soln[order[cur_level]] = -1;
	       unit_fixed[order[cur_level]] = FALSE;
	       --cur_level;
	  } else {
	       if (cur_soln[order[cur_level]] == pick_first_val(order[cur_level])) {
		    cur_soln[order[cur_level]] = pick_first_val_opp(order[cur_level]);
		    update_counts(cur_level, pick_first_val_opp(order[cur_level]));
		    return;
	       };

	       if (cur_soln[order[cur_level]] == pick_first_val_opp(order[cur_level])) {
		    cur_soln[order[cur_level]] = -1;
		    --cur_level;
	       };
	  };
     };

     /*
      * At this point, we've backtracked to the end, so stop.
      */
     done_flag = TRUE;
}


/*
 * A routine for unit clause tracking.
 * 
 * - loop through all undetermined clauses.
 * 
 * - For each unit clause, store the variable number.
 * 
 * - Go back through the list of unit clause variables and fix them as
 * appropriate.
 * 
 */

void 
unit_track()
{
     clause_ptr      clausep;
     entry_ptr       entryp;
     int             clause;
     int             var;
     int             var_count;
     int             i;


     track_iter++;

     /*
      * Repeat this procedure until there are no unit clauses.
      */

     while (1 == 1) {
	  /*
	   * Loop through the undetermined clauses.
	   */
	  var_count = 0;

	  clausep = undetermined_clauses;

	  while (clausep != (clause_ptr) NULL) {
	       clause = clausep->clause_num;

	       /*
	        * Only consider unit clauses that are still undetermined.
	        */
	       if (row_count[clause] - 1 == num_false[clause]) {
		    /*
		     * Now, loop through all variables associated with this
		     * clause, and find the unit clause variable.
		     */

		    entryp = clauses[clause];

		    while (entryp != (entry_ptr) NULL) {
			 if ((cur_soln[entryp->var_num] == -1) &
			     (unsat + clause_weights[clause] >= ub)) {
			      var = entryp->var_num;
			      unit_vars[var_count] = var;
			      unit_var_value[var_count] = entryp->sense;
			      var_count++;
			      break;
			 };
			 entryp = entryp->next_in_clause;
		    };
	       };
	       clausep = clausep->next;
	  };

	  /*
	   * If there are no variables in the list, then return.
	   */
	  if (var_count == 0) {
	       return;
	  };
	  /*
	   * Ok, we've now got a list of unit clause variables.  Go ahead and
	   * set them up.
	   */
	  for (i = 0; i < var_count; i++) {
	       var = unit_vars[i];
	       if (cur_soln[var] == -1) {
		    cur_level++;
		    order[cur_level] = var;
		    unit_fixed[order[cur_level]] = TRUE;

		    cur_soln[order[cur_level]] = unit_var_value[i];
		    update_counts(cur_level, unit_var_value[i]);
		    if (unsat >= ub) {
			 return;
		    };
	       };
	  };
     };
}


const char *
init_problem(int * initvars, int ninitvars, int nvars)
{
  int ii;

  // important to reset upper bound!
  best_num_sat = best_best_num_sat = 0;
  pick_var_iter = 0;

  // initialize all the variables
  if (initvars) {
    if (ninitvars != nvars) {
      return "Mismatch in variable initialization count.";
    }

    for (ii = 0; ii < nvars; ++ ii) {
      cur_soln[ii] = initvars[ii];
      pick_first[ii] = initvars[ii];
    }
  } else {
    for (ii = 0; ii < nvars; ++ ii) {
      cur_soln[ii] = FALSE;
      pick_first[ii] = FALSE;
    }
  }

  // this call to slm() and the following initializes the upper bound
  slm(0);
  if (best_num_sat > best_best_num_sat) {
    best_best_num_sat = best_num_sat;
  };
  if (best_best_num_sat == total_weight) {
    return NULL; // nothing to do, could skip optimization
  };
  
  return NULL;
}


/*
 * The main DP routine.
 */

void 
runBorchers(int ninitvars, int nvars)
{
     int             i;
     int             j;
     clause_ptr      ptr;
	 const char * error = NULL;
	 
	error = init_problem(NULL, ninitvars, nvars);
	  if (error) {
		printf("Error in problem setup: %s\n", error);
		return;
	  }
	   callbackFunction(best_soln, num_vars, ub);

     /*
      * First, initialize the counts.
      */
     for (i = 0; i <= num_clauses; i++) {
	  num_true[i] = 0;
	  num_false[i] = 0;
     };

     /*
      * Next, initialize the solution and a few other items. 
      */
     for (i = 0; i <= num_vars - 1; i++) {
	  cur_soln[i] = -1;
	  unit_fixed[i] = FALSE;
	  var_counts_iter[i] = 0;
     };

     /*
      * Initialize the list of satisfied and unsatisfied clauses.
      */
     undetermined_clauses = (clause_ptr) NULL;

     for (j = 0; j <= num_clauses - 1; j++) {
	  ptr = (clause_ptr) malloc(sizeof(struct clause_rec));
	  ptr->clause_num = j;
	  ptr->next = undetermined_clauses;
	  if (undetermined_clauses != (clause_ptr) NULL) {
	       undetermined_clauses->prev = ptr;
	  };
	  ptr->prev = (clause_ptr) NULL;
	  clause_records[j] = ptr;
	  undetermined_clauses = ptr;
     };

     /*
      * Finally, initialize the other variables.
      */

     unsat = 0;
     ub = total_weight - best_best_num_sat;
     cur_level = -1;
     done_flag = FALSE;
     btrackcount = 0;

     printf("ub is %d \n", ub);

     /*
      * Now, the main loop.
      */
     while (done_flag != TRUE) {

	  if (ub - unsat <= max_weight) {
	       unit_track();
          };
	  if ((cur_level == num_vars - 1) && (unsat < ub)) {
	       ub = unsat;
	       printf("New Best Solution Found, %d \n", ub);
	       update_best_soln();
	  };

	  /*
	   * We haven't found a new solution, so either backtrack or drop
	   * down another level.
	   */

	  if (unsat >= ub) {
	       backtrack();
	  } else {
	       drop();
	  };
     };

     /*
      * We're all done with the search.
      */
//	   update_best_soln();
     printf("The solution took %d backtracks \n", btrackcount);

}




/*
 * The main program.
 */
#ifdef borchers
void
main(argc, argv)
     int             argc;
     char           *argv[];
{
     int             max_tries;
     int             max_flips;
     int             seed;
     int             i;

     /*
      * Take the first argument as the name of the problem file to read.
      * Call read_prob() to read in the problem.
      */
     read_prob(*++argv);

     printf("The total weight of all clauses is %d \n", total_weight);

     /*
      * Now, call the slm routine to try to solve the problem.
      */
     max_tries = 10;
     max_flips = 100 * num_vars;
     printf("max_tries %d \n ", max_tries);
     printf("max_flips %d \n", max_flips);

     /*
      * Get a random number seed.
      */
     printf("Random number seed=1 \n");
     seed = 1;
     srand(seed);

     for (i = 1; i <= max_tries; i++) {
	  rand_soln();
	  slm(max_flips);
	  printf("Best weight of satisfied clauses is %d \n", best_num_sat);
	  if (best_num_sat > best_best_num_sat) {
	       best_best_num_sat = best_num_sat;
          };
	  if (best_best_num_sat == total_weight) {
	       break;
          };
     };
     /*
      * Next, print out information about the solution.
      */
     printf("Best GSAT solution: weight %d of satisfied clauses, out of a possible %d \n", best_best_num_sat, total_weight);

     /*
      * Now, call the Davis-Putnam routine.
      */

     runBorchers(num_vars, num_vars);
	 
	 callbackFunction(best_soln, num_vars, ub);

     printf("Done with Davis-Putnam.  The current solution is optimal!\n");
     printf("The best solution had weight %d of unsatisfied clauses \n", ub);
     printf("The solution took %d backtracks \n", btrackcount);
     exit(0);

}
#endif
