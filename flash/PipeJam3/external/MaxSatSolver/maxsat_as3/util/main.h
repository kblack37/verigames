//#define BUILD_LIB
#define borchers
//#define MAXSATZ2009
extern const int ALG_DPLL;
extern const int ALG_RAND;

#define WORD_LENGTH 1024
#define TRUE 1
#define FALSE 0
#define NONE -1
#define NEGATIVE 0
#define POSITIVE 1
#define PASSIVE 0
#define ACTIVE 1

//for borchars
#define MAX_CLAUSES 150000
#define MAX_VARS    150000

typedef struct entry *entry_ptr;

struct entry {
     int             clause_num;
     int             var_num;
     int             sense;
     entry_ptr       next_in_var;
     entry_ptr       next_in_clause;
};

extern int             num_clauses;
extern int             num_vars;
extern int             ub;
extern int             total_weight;
extern int             max_weight;
extern int             min_weight;
extern int             col_count[MAX_VARS];
extern int             row_count[MAX_CLAUSES];
extern int             clause_weights[MAX_CLAUSES];

extern entry_ptr       vars[MAX_VARS];
extern entry_ptr       clauses[MAX_CLAUSES];

typedef int(*CallbackFunction)(int * vars, int nvars, int unsat_weight);
extern int callbackFunction(int * vars, int nvars, int unsat_weight);

extern void
run(int algorithm, int * clauses, int nclauses, int * initvars, int ninitvars, int intermediate_callbacks, CallbackFunction callback);
extern const char *
check_problem(const int * clauses_ptr, int nclauses, int * nvars);
extern int setupMaxSatz(char* input_file);
extern void runMaxSatz(int * clauses, int nclauses);
extern void getCurrentSolutionMaxSatz(int* output);

extern int setupBorchers(char* input_file);
void runBorchers(int ninitvars, int nvars);
extern void getCurrentSolutionBorchers(int* output);

extern void do_callback(int new_best);

extern CallbackFunction callback_function;
