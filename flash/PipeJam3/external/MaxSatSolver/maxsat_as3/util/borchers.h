#include "main.h"

extern int             cur_soln[MAX_VARS];
extern entry_ptr       vars[MAX_VARS];
extern int             num_vars;
extern int             best_soln[MAX_VARS];
extern int             ub;
extern entry_ptr       clauses[MAX_CLAUSES];
extern int             num_clauses;
extern int             total_weight;
extern int             num_improve[MAX_VARS];
extern int             best_list[MAX_VARS];
extern int             best_count;
extern int             best_improve;
extern int             col_count[MAX_VARS];
extern int             best_num_sat;
extern int             best_best_num_sat;
extern int             pick_var_iter;
/*
 * Information about the clauses.
 */
extern entry_ptr       clauses[MAX_CLAUSES];
extern int             num_clauses;
extern int             sat_count[MAX_CLAUSES];
extern int             row_count[MAX_CLAUSES];
extern int             clause_weights[MAX_CLAUSES];
extern int             max_weight;
extern int             min_weight;

extern int             pick_first[MAX_VARS];
extern int             btrackcount;

extern void print_best_solution();