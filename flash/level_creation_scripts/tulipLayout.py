import sys
from tulip import tlp
import networkx as nx
import gv


# process args
filename = sys.argv[1]
scale = 1.0
max_path_len = 0
if len(sys.argv) >= 3:
    scale = float(sys.argv[2])
if len(sys.argv) >= 4:
    max_path_len = max(1, int(sys.argv[3]))


# load in dot file
sys.stderr.write('loading dot file\n')
gv_graph = gv.read(filename)


# convert dot graph to networkx graph
sys.stderr.write('building graph\n')
nx_graph = nx.Graph()
nh = gv.firstnode(gv_graph)
while nh:
    nx_graph.add_node(gv.nameof(nh))
    nh = gv.nextnode(gv_graph, nh)
eh = gv.firstedge(gv_graph)
while eh:
    nx_graph.add_edge(gv.nameof(gv.tailof(eh)), gv.nameof(gv.headof(eh)))
    eh = gv.nextedge(gv_graph, eh)


# get mst
if max_path_len == 0:
    sys.stderr.write('skipping mst\n')
    nx_use_graph = nx_graph

else:
    sys.stderr.write('computing mst\n')
    nx_mst_graph = nx.minimum_spanning_tree(nx_graph)

    nx_use_graph = nx_graph.copy()

    for edge in nx_graph.edges():
        path = nx.shortest_path(nx_mst_graph, edge[0], edge[1])
        if len(path) - 1 > max_path_len:
            nx_use_graph.remove_edge(edge[0], edge[1])


# convert to tulip
sys.stderr.write('converting to tulip\n')
tlp_graph = tlp.newGraph()
tlp_name_to_id = {}
tlp_id_to_name = {}
for node in nx_use_graph.nodes():
    id = tlp_graph.addNode()
    tlp_name_to_id[node] = id
    tlp_id_to_name[id] = node
for edge in nx_use_graph.edges():
    tlp_graph.addEdge(tlp_name_to_id[edge[0]], tlp_name_to_id[edge[1]])


# do layout
sys.stderr.write('doing layout\n')
layout_alg = 'MMM Example Fast Layout (OGDF)'
view_layout = tlp_graph.getLayoutProperty('viewLayout')
tlp_graph.applyLayoutAlgorithm(layout_alg, view_layout)
for node in tlp_graph.getNodes():
    name = tlp_id_to_name[node]
    pos = '%f,%f!' % (scale * view_layout[node][0], scale * view_layout[node][1])
    nh = gv.findnode(gv_graph, name)
    gv.setv(nh, 'pos', pos)

# print new dot graph
sys.stderr.write('writing\n')
gv.write(gv_graph, 'out.dot')
