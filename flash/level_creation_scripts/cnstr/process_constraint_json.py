import sys, os
from process_sat import input_cnstr, connected, dot, output_dimacs, group, write_game_files

GROUP = False

### Command line interface ###
if __name__ == "__main__":
    usage = 'Usage: %s constraint_filename_prefix_omit_json_extension' % sys.argv[0]
    if len(sys.argv) != 2:
        print usage
        quit()
    file_pref = sys.argv[1]
    
    node_min = int(raw_input('Enter minimum number of vars required to process level (or -1 to process all levels): '))
    node_max = int(raw_input('Enter maximum number of vars required to process level (or -1 to process all levels): '))
    if GROUP:
        group_min = int(raw_input('Enter minimum number of vars required to perform grouping on a level (or -1 to process all levels): '))
    if node_max == -1:
        node_max = sys.maxsize
    
    constr_fn = '%s.json' % file_pref
    graph_fn = '%s.graph' % file_pref
    version = input_cnstr.run(constr_fn, graph_fn)

    graphs_fn = '%s.graphs' % file_pref
    connected.run(graph_fn, graphs_fn, node_min, node_max)
    
    dot_dirn = '%s_dot_files' % file_pref
    suf_i = 0
    while os.path.exists(dot_dirn):
        suf_i += 1
        dot_dirn = '%s_dot_files_%s' % (file_pref, suf_i)
    os.makedirs(dot_dirn)
    print 'Writing dot files to: %s' % dot_dirn
    #dot.run(graphs_fn, dot_dirn, node_min, node_max)
    
    if GROUP:
        groups_fn = '%s.groups' % file_pref
        group.run(graphs_fn, groups_fn, group_min, node_max)
    
    wcnf_dirn = '%s_wcnf_files' % file_pref
    suf_i = 0
    while os.path.exists(wcnf_dirn):
         suf_i += 1
         wcnf_dirn = '%s_wcnf_files_%s' % (file_pref, suf_i)
    os.makedirs(wcnf_dirn)
    print 'Writing wcnf files to: %s' % wcnf_dirn
    output_dimacs.run(graphs_fn, wcnf_dirn)

    game_files_dirn = '%s_game_files' % file_pref
    suf_i = 0
    while os.path.exists(game_files_dirn):
        suf_i += 1
        game_files_dirn = '%s_game_files%s' % (file_pref, suf_i)
    os.makedirs(game_files_dirn)
    print 'Writing game files to: %s' % game_files_dirn
    qids_start = int(raw_input('Enter qid to start with: '))
    write_game_files.run(graphs_fn, game_files_dirn, version, qids_start, node_min, node_max)

