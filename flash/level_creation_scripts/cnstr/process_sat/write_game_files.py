import networkx as nx
import cPickle, json, sys, os
import _util

def run(graphs_infile, game_files_directory, version, qids_start, node_min, node_max):
    
    with open(graphs_infile, 'rb') as infile:
        Gs = cPickle.load(infile)
    constraints_name = os.path.basename(graphs_infile).split('.')[0]

    if not os.path.isdir(game_files_directory):
        raise RuntimeError('game_files_directory is not a directory/does not exist: %s' % game_files_directory)

    current_qid = qids_start
    for Gi, G in enumerate(sorted(Gs)):
        n_vars = len([n for n in G.nodes() if n.startswith('var')])

        # Limit the number of nodes in a graph
        if n_vars < node_min or n_vars > node_max:
            continue

        if not G.graph.has_key('id'):
            G.graph['id'] = 'p_%06d_%08d' % (n_vars, Gi)

        solved_if_wide = G.graph.get('solved_if_wide', False)
        solved_if_narrow = G.graph.get('solved_if_narrow', False)

        if solved_if_narrow:
          outfilename = game_files_directory + ('/SOLVED_NARROW_%s.json' % G.graph['id'])
          use_qid = -1
        elif solved_if_wide:
          outfilename = game_files_directory + ('/SOLVED_WIDE_%s.json' % G.graph['id'])
          use_qid = -1
        else:
          outfilename = game_files_directory + ('/%s.json' % G.graph['id'])
          use_qid = current_qid
        out = open(outfilename, 'w')
        out.write('''
{
  "id": "%s",
  "qid": %s,
  "version": "%s",
  "default": "type:1",
  "scoring": {
    "variables": {"type:0": 0, "type:1": 0},
    "constraints": 1
  },
  "groups":%s,
  "variables":{},
  "cut_edges":%s,
  "constraints":[
    ''' % (G.graph['id'], current_qid, version, json.dumps(G.graph.get('cut_edges',[]), json.dumps(G.graph.get('groups', []))))
        comma = ''
        for edge_parts in G.edges():
            from_n = edge_parts[0].replace('clause', 'c')
            to_n = edge_parts[1].replace('clause', 'c')
            out.write('%s"%s <= %s"' % (comma, from_n, to_n))
            comma = ',\n    '
        out.write(']\n}')
        out.close()

        if solved_if_narrow or solved_if_wide:
          continue

        asg_outfilename = game_files_directory + ('/%sAssignments.json' % G.graph['id'])
        out = open(asg_outfilename, 'w')
        out.write('''
{
  "id": "%s",
  "qid": %s,
  "assignments":{
  }
}''' % (G.graph['id'], current_qid))
        out.close()

        layout_outfilename = game_files_directory + ('/%sLayout.json' % G.graph['id'])
        out = open(layout_outfilename, 'w')
        out.write('''
{
  "id": "%s",
  "layout": {
    "bounds": [%s,%s,%s,%s],
    "vars": {
      ''' % (G.graph.get('id',''), 
        G.graph.get('min_x',0), 
        G.graph.get('min_y',0), 
        G.graph.get('max_x',0), 
        G.graph.get('max_y',0)))
        comma = ''
        for node_id in G.nodes():
            node = G.node[node_id]
            if node.get('x') is None or node.get('y') is None:
                print 'Warning! Node found without layout info: %s' % node_id
                continue
            node_id_ = node_id.replace(':', '_').replace('clause_', 'c_')
            out.write('%s"%s":{"x":%s,"y":%s}' % (comma, node_id_, node.get('x'), node.get('y')))
            comma = ',\n      '
        out.write('\n     }\n  }\n}')
        out.close()
        current_qid += 1



### Command line interface ###
if __name__ == "__main__":
    if len(sys.argv) != 7:
        print 'Usage: %s graphs_infile game_files_directory version qids_start node_min node_max' % sys.argv[0]
        quit()
    graphs_infile = sys.argv[1]
    game_files_directory = sys.argv[2]
    version = sys.argv[3]
    qids_start = sys.argv[4]
    node_min = sys.argv[5]
    node_max = sys.argv[6]
    run(graphs_infile, game_files_directory, version, qids_start, node_min, node_max)