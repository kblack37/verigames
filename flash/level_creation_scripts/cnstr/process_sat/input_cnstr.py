import networkx as nx
import cPickle, json, sys
import _util


def run(infile, outfile):
    _util.print_step('parsing')

    world = json.load(open(infile))
    version, constraints = _util.get_vals(world, ['version', 'constraints'])

    if version not in ['1', '2']:
        raise RuntimeError('JSON has unrecognized version ' + version)
    version = int(version)


    def process_constraint_block(clauses, constraints, lits):
        for constraint in constraints:
            if constraint.has_key('constraint'):
                cns = constraint['constraint']

                if cns == 'subtype':
                    if version == 1:
                        lhs, cns, rhs = _util.get_vals(constraint, ['lhs', 'constraint', 'rhs'])
                        clauses.append(lits + [(rhs, False), (lhs, True)])
                    elif version == 2:
                        sub, cns, sup = _util.get_vals(constraint, ['sub', 'constraint', 'sup'])
                        clauses.append(lits + [(sub, False), (sup, True)])
                elif cns == 'greaterthan':
                    sub, cns, sup = _util.get_vals(constraint, ['sub', 'constraint', 'sup'])
                    clauses.append(lits + [(sub, True), (sup, True)])
                elif cns == 'lessthan':
                    sub, cns, sup = _util.get_vals(constraint, ['sub', 'constraint', 'sup'])
                    clauses.append(lits + [(sub, False), (sup, False)])
                elif cns == 'equality':
                    lhs, cns, rhs = _util.get_vals(constraint, ['lhs', 'constraint', 'rhs'])
                    clauses.append(lits + [(rhs, False), (lhs, True)])
                    clauses.append(lits + [(rhs, True), (lhs, False)])

                elif cns == 'comparable':
                    continue

                elif version == 2 and cns == 'enabled_check':
                    id = constraint['id']
                    test_var = id + '_exists'

                    if constraint.has_key('then'):
                        process_constraint_block(clauses, constraint['then'], lits + [(test_var, False)])
                    if constraint.has_key('else'):
                        process_constraint_block(clauses, constraint['else'], lits + [(test_var, True)])
                        
                elif cns == 'clause':
                    cns, pos, neg = _util.get_vals(constraint, ['constraint', 'pos', 'neg'])
                    temp = []
                    for cl in pos:
                        temp.append((cl, True))
                    for cl in neg:
                        temp.append((cl, False))
                        
                    clauses.append(lits + temp)
                        

                else:
                    print 'UNRECOGNIZED CONSTRAINT KEY', cns
                    raise RuntimeError()

            else:
                print 'UNRECOGNIZED CONSTRAINT', constraint
                raise RuntimeError()

    clauses = []
    process_constraint_block(clauses, constraints, [])

    _util.print_step('constructing graph')

    G = nx.DiGraph()
    edges = {}
    for cc, clause in enumerate(clauses):
        cnode = 'clause:' + str(cc + 1)
        clause_always_true = False
        for sym, sense in clause:
            if sym.startswith('type:'):
                if (sym.startswith('type:0') and sense) or (sym.startswith('type:1') and not sense):
                    # 0 or not 1 will always be false, so omit this edge since it has no impact on solution
                    continue
                elif (sym.startswith('type:0') and not sense) or (sym.startswith('type:1') and sense):
                    # not 0 or 1 will always be true, so this clause will always be true, so omit edges in this clause
                    clause_always_true = True

            if sense:
                from_n = cnode
                to_n = sym
            else:
                from_n = sym
                to_n = cnode
            back = (to_n, from_n)
            if edges.has_key(back):
                # Edge exists in other direction, meaning the clause will always be satisfied (if x=0 or x=1)
                clause_always_true = True
            # If clause is always true, remove from graph and stop proccessing syms, senses
            if clause_always_true:
                try:
                    G.remove_node(cnode) #removes clause node and any connected edges
                except nx.exception.NetworkXError:
                    pass # if no edges were created for the clause, no clause node exists so no need to remove
                break
            G.add_edge(from_n, to_n)
            edges[(from_n, to_n)] = True

    _util.print_step('saving')

    cPickle.dump([G], open(outfile, 'wb'), cPickle.HIGHEST_PROTOCOL)

    _util.print_step(None)
    return version


### Command line interface ###
if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = sys.argv[2]
    version = run(infile, outfile)