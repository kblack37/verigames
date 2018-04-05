import networkx as nx
import pymetis
import cPickle, json, os, sys
import _util

MAX_GRAPH_NODE_COUNT = 7000
VAR = 'var:'

def nx_to_metis(G):
    vert_dict = {}
    metis_g = []
    for e in G.edges():
        vert0 = e[0]
        vert1 = e[1]
        if vert_dict.get(vert0) is None:
            vert_dict[vert0] = len(metis_g)
            metis_g.append([])
        if vert_dict.get(vert1) is None:
            vert_dict[vert1] = len(metis_g)
            metis_g.append([])
        metis_g[vert_dict[vert0]].append(vert_dict[vert1])
        metis_g[vert_dict[vert1]].append(vert_dict[vert0])
    return (metis_g, vert_dict)
        
def split_graph(G, existing_Gs):
    var_count = 0
    for node in G.nodes():
        if node.startswith('var:'):
            var_count += 1
    if var_count <= MAX_GRAPH_NODE_COUNT:
        existing_Gs += [G]
        print 'Graph with %s vars... DONE' % var_count
        return
    else:
        num_partitions = var_count / 5000
        print 'Graph with %s vars... splitting into %s paritions...' % (var_count, num_partitions)
        (metis_g, vert_dict) = nx_to_metis(G)
        (n_edges_cut, partitions_assigned) = pymetis.part_graph(num_partitions, metis_g)
        print 'Graph split, %s edges cut' % n_edges_cut
        # Form new subgraphs based on assigned partitions
        sub_Gs = []
        cut_edges = []
        for g_num in range(num_partitions):
            new_G = nx.DiGraph()
            sub_Gs.append(new_G)
            cut_edges.append([])
        # Place any previous cut_edges into appropriate partitions' graphs
        prev_cut_edges = G.graph.get('cut_edges', [])
        for e in prev_cut_edges:
            if vert_dict.get(e[0]) is not None:
                cut_edges[vert_dict[e[0]]].append(e)
            if vert_dict.get(e[1]) is not None:
                cut_edges[vert_dict[e[1]]].append(e)
        # Add edges from old graph to appropriate partitions
        for e in G.edges():
            from_part = partitions_assigned[vert_dict[e[0]]]
            to_part = partitions_assigned[vert_dict[e[1]]]
            if from_part != to_part:
                cut_edges[from_part].append(e)
                cut_edges[to_part].append(e)
            else:
                sub_Gs[from_part].add_edge(e[0], e[1])
        for i,new_G in enumerate(sub_Gs):
            new_G.graph['cut_edges'] = cut_edges[i]
            split_graph(new_G, existing_Gs)
        return


def run(infile, outfile, node_min, node_max):
    _util.print_step('loading')

    Gs = cPickle.load(open(infile, 'rb'))

    _util.print_step('computing weakly connected components')

    new_Gs = []
    for G in Gs:
        n_vars = len([n for n in G.nodes() if n.startswith(VAR)])

        # Limit the number of nodes in a graph
        if n_vars < node_min or n_vars > node_max:
            continue

        gen = nx.weakly_connected_component_subgraphs(G)
        for ge in gen:
            new_graphs = []
            split_graph(ge, new_graphs)
            for ng in new_graphs:
                new_Gs.append(ng)
    Gs = new_Gs

    if False:
        new_Gs = []
        for G in Gs:
            if G.number_of_nodes() >= 15000:
                new_Gs.append(G)
                break
        Gs = new_Gs

    if True:
        szs = []

        for G in Gs:
            var_count = 0
            for node in G.nodes():
                if node.startswith(VAR):
                    var_count += 1
            szs.append((var_count))

        szs = sorted(szs)

        for sz in szs:
            print sz
        print '', len(Gs)

    _util.print_step('saving')

    cPickle.dump(Gs, open(outfile, 'wb'), cPickle.HIGHEST_PROTOCOL)

    _util.print_step(None)


### Command line interface ###
if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = sys.argv[2]
    run(infile, outfile)
