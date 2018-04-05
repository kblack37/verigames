#include "main.h"

//for maxsatz
typedef signed char my_type;
typedef unsigned char my_unsigned_type;

typedef long long int lli_type;

#define tab_variable_size  30000
#define tab_clause_size 1000000
#define INIT_BASE_NB_CLAUSE (tab_clause_size / 2)
extern int BASE_NB_CLAUSE;
extern int INIT_NB_CLAUSE;
extern int NB_VAR;
extern int NB_CLAUSE;
extern lli_type UB;
extern lli_type NB_MONO;
extern lli_type NB_BRANCHE;
extern lli_type NB_BACK;
extern my_type var_best_value[tab_variable_size]; // Best assignment of variables
extern int instance_type;
extern int partial;
extern lli_type HARD_WEIGHT;
extern int *sat[tab_clause_size]; // Clauses [clause][literal]
extern int *var_sign[tab_clause_size]; // Clauses [clause][var,sign]
extern lli_type clause_weight[tab_clause_size]; // Clause weights
extern lli_type ini_clause_weight[tab_clause_size]; // Initial clause weights
extern my_type clause_state[tab_clause_size]; // Clause status
extern int clause_length[tab_clause_size]; // Clause length
extern int CMTR[2];



extern int             num_vars;
extern CallbackFunction callback_function;
