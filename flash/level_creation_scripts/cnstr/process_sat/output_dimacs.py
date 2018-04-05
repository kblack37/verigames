import networkx as nx
import cPickle, json, os, sys
import _util

def run(infile, outfile, USE_PREF=True):
    out_is_folder = os.path.isdir(outfile)

    _util.print_step('loading')

    Gs = cPickle.load(open(infile, 'rb'))

    g_var_map = {}
    g_var_max = 0
    g_clauses = []
    g_offset = 0


    def reset_clauses():
        global g_var_map, g_var_max, g_clauses, g_offset

        g_var_map = {}
        g_var_max = 0
        g_clauses = []
        g_offset = 0

    def get_var(vv):
        global g_var_map, g_var_max, g_clauses, g_offset

        if vv.startswith('type:0'):
            return False
        elif vv.startswith('type:1'):
            return True
        elif vv.startswith('var:'):
            if not g_var_map.has_key(vv):
                g_var_max += 1
                g_var_map[vv] = g_var_max

            return g_var_map[vv]

    def print_wcnf(out):
        global g_var_map, g_var_max, g_clauses, g_offset

        if USE_PREF:
            out.write('p wcnf %d %d\n' % (g_var_max, len(g_clauses) + g_var_max))

            for ii in xrange(g_var_max):
                out.write('1 ')
                out.write('%d ' % (ii + 1))
                out.write('0\n')
        else:
            out.write('p wcnf %d %d\n' % (g_var_max, len(g_clauses)))

        for cls in g_clauses:
            if USE_PREF:
                out.write('20000 ')
            else:
                out.write('1 ')
            for ll in cls:
                out.write('%d ' % (ll))
            out.write('0\n')

        out.write('c offset %d\n' % (g_offset))

        arr = []
        for vv, id in g_var_map.iteritems():
            arr.append((id, vv))
        
        for id, vv in sorted(arr):
            out.write('c var %d %s\n' % (id, vv))

    def append_clause(lits):
        global g_var_map, g_var_max, g_clauses, g_offset

        already_sat = False
        new_cls = []
        for lit in lits:
            var = get_var(lit[0])
            sense = lit[1]

            if isinstance(var, bool):
                if var == sense:
                    already_sat = True
                else:
                    pass

            else:
                if sense:
                    new_lit = var
                else:
                    new_lit = -var

                if -new_lit in new_cls:
                    already_sat = True
                elif new_lit not in new_cls:
                    new_cls.append(new_lit)

        if len(new_cls) == 0:
            g_offset += 1
        elif not already_sat:
            g_clauses.append(new_cls)


    _util.print_step('outputting')

    for Gi, G in enumerate(Gs):
        if out_is_folder:
            reset_clauses()

        for node in G.nodes():
            if not node.startswith('clause:'):
                continue

            clause_vec = []
            for var in G.successors(node):
                clause_vec.append((var, True))
            for var in G.predecessors(node):
                clause_vec.append((var, False))

            append_clause(clause_vec)

        if out_is_folder:
            filename = outfile + ('/p_%06d_%08d.wcnf' % (g_var_max, Gi))

            print_wcnf(open(filename, 'wb'))

    if not out_is_folder:
        print_wcnf(open(outfile, 'wb'))

    _util.print_step(None)


### Command line interface ###
if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = sys.argv[2]
    run(infile, outfile)