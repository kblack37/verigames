import networkx as nx
import cPickle, sys, copy, json
import _util

VAR = 'var'
CONSTR = 'clause'

def isolate_nodes_by_type(G, node_type):
    # Assign weighted_edges based on common edges between other type, weight = dist^2 between
    weighted_edges = {}
    if node_type == VAR:
        other_type = CONSTR
    else:
        other_type = VAR
    for n in G.nodes():
        if n.startswith(other_type):
            all_edges = G.in_edges([n]) + G.out_edges([n])
            # Make edges between every incoming or outgoing node and every other incoming or outgoing node
            for i in range(len(all_edges) - 1):
                for j in range(i + 1, len(all_edges)):
                    # Create weighted edges between nodes of the desired type
                    edge1 = all_edges[i]
                    edge2 = all_edges[j]
                    if edge1[0] == n:
                        node1 = edge1[1]
                    elif edge1[1] == n:
                        node1 = edge1[0]
                    else:
                        print 'Unexpected edge: %s coming to/from %s' % (edge1, n)
                        continue
                    if edge2[0] == n:
                        node2 = edge2[1]
                    elif edge2[1] == n:
                        node2 = edge2[0]
                    else:
                        print 'Unexpected edge: %s coming to/from %s' % (edge2, n)
                        continue
                    if node1 == node2:
                        continue #avoid circular references
                    new_edge = (node1, node2)
                    new_edge_back = (node2, node1)
                    if weighted_edges.has_key(new_edge) or weighted_edges.has_key(new_edge_back): # skip if computed already
                        continue
                    # Store edge weight = dist^2 between nodes
                    node1_xy = [G.node[node1].get('x'), G.node[node1].get('y')]
                    if node1_xy[0] is None or node1_xy[1] is None:
                        print 'NO NODE LAYOUT INFO FOR %s' % node1
                        continue
                    node2_xy = [G.node[node2].get('x'), G.node[node2].get('y')]
                    if node2_xy[0] is None or node2_xy[1] is None:
                        print 'NO NODE LAYOUT INFO FOR %s' % node2
                        continue
                    dx = node1_xy[0] - node2_xy[0]
                    dy = node1_xy[1] - node2_xy[1]
                    weighted_edges[new_edge] = dx * dx + dy * dy
    return weighted_edges

def get_group(node_id, G):
    while G.node[node_id].get('group') is not None:
        if G.node[node_id].get('group') == node_id:
            return node_id
        prev_node_checked = node_id
        node_id = G.node[prev_node_checked].get('group', prev_node_checked)
    return node_id

def group_node_into(node1_id, node2_id, node_group_dict, G, G_copy): # group node1 into node2
    node_group_dict[node1_id] = node2_id
    node_group_dict[node2_id] = node2_id
    node1 = G.node[node1_id]
    node2 = G.node[node2_id]
    node1['group'] = node2_id
    node2['group'] = node2_id
    #print 'Grouping %s -> %s' % (node1_id, node2_id)
    # Add any edges coming to/from node being removed
    for e in G_copy.in_edges([node1_id]):
        other_node_id = get_group(e[0], G)
        if other_node_id == node2_id:
            continue
        #print 'Reconnecting edge: %s -> %s' % (e[0], e[1])
        #print 'New          edge: %s -> %s' % (other_node_id, node2_id)
        G_copy.add_edge(other_node_id, node2_id)
    for e in G_copy.out_edges([node1_id]):
        other_node_id = get_group(e[1], G)
        if other_node_id == node2_id:
            continue
        #print 'Reconnecting edge: %s -> %s' % (e[0], e[1])
        #print 'New          edge: %s -> %s' % (node2_id, other_node_id)
        G_copy.add_edge(node2_id, other_node_id)
    # Remove node1 and any connected edges from copy of graph
    G_copy.remove_node(node1_id)

def run(infile, outfile, node_min, node_max):
    _util.print_step('loading')

    with open(infile, 'rb') as read_in:
        Gs = cPickle.load(read_in)

    _util.print_step('grouping graph nodes')

    for Gi, G in enumerate(sorted(Gs)):
        n_vars = len([n for n in G.nodes() if n.startswith(VAR)])

        # Limit the number of nodes in a graph
        if n_vars < node_min or n_vars > node_max:
            continue

        print 'Processing %s...' % G.graph.get('id', 'unknown id')
        previous_num_edges_grouped = 0
        num_edges_grouped = 1
        current_node_type = VAR
        level_of_detail_groupings = []
        G_copy = G.copy() # to be used to trim nodes/edges as they are grouped
        while num_edges_grouped > 0 or previous_num_edges_grouped > 0:
            current_order = len(level_of_detail_groupings)
            # 1. Create new (undirected) graph using only variable nodes (or only constraint nodes).
            # 2. Connect nodes of new graph if they share a constraint (or variable, in the case of constraints).
            # 3. Calculate a weighting = (inverse) distance between nodes for each edge.
            weighted_edges = isolate_nodes_by_type(G_copy, current_node_type)
            # 4. Compute a set of edges, use a greedy algorithm: choose the edge with the minimum distance first
            # Order edges: smallest dist^2 to largest
            weighted_edge_arr = [[weighted_edges[e], e] for e in weighted_edges]
            sorted_edges = sorted(weighted_edge_arr)
            previous_num_edges_grouped = num_edges_grouped
            num_edges_grouped = 0
            _util.print_step('current_order: %s Edges to examine for merging: %s' % (current_order, len(sorted_edges)))
            nodes_grouped_this_round = {}
            for ne in range(len(sorted_edges)):
                edge_to_merge = sorted_edges[ne][1]
                node1_id = edge_to_merge[0]
                node2_id = edge_to_merge[1]
                if nodes_grouped_this_round.get(node1_id) is not None or nodes_grouped_this_round.get(node2_id) is not None:
                    continue # if either node already grouped this round, ignore this edge
                node1 = G.node[node1_id]
                node2 = G.node[node2_id]
                if node1.get('order') is None:
                    node1['order'] = current_order
                if node2.get('order') is None:
                    node2['order'] = current_order
                node1_order = node1.get('order')
                node2_order = node2.get('order')
                # 5. Add direction to those edges, using the degree and magnitude of the nodes from the original graph (from lower degree to higher, from lower magnitude to higher)
                # 6. Using those directed edges, merge the 'from' nodes into the 'to' nodes
                if node1_order > node2_order or current_order == 0:
                    group_node_into(node1_id, node2_id, nodes_grouped_this_round, G, G_copy) # group 1 into 2
                elif node1_order < node2_order:
                    group_node_into(node2_id, node1_id, nodes_grouped_this_round, G, G_copy) # group 2 into 1
                else: # same order, check respective group sizes
                    node1_group_size = len(level_of_detail_groupings[-1].get(node1_id, []))
                    node2_group_size = len(level_of_detail_groupings[-1].get(node2_id, []))
                    if node1_group_size >= node2_group_size:
                        group_node_into(node1_id, node2_id, nodes_grouped_this_round, G, G_copy) # group 1 into 2
                    else:
                        group_node_into(node2_id, node1_id, nodes_grouped_this_round, G, G_copy) # group 2 into 1
                num_edges_grouped += 1
            # 7. Switch from using variables or constraints as the basis for the new graph, if enough nodes of the other type remain.
            if current_node_type == VAR:
                current_node_type = CONSTR
            else:
                current_node_type = VAR
            # 8. Repeat from #1 as long as nodes remain to be merged.
            # If any groupings created (dict is not empty), save off groupings
            if nodes_grouped_this_round:
                # Initialize using last round's groupings
                if current_order == 0:
                    node_groups = {}
                else:
                    node_groups = copy.deepcopy(level_of_detail_groupings[-1])
                num_nodes_grouped = 0
                for node_being_grouped in nodes_grouped_this_round:
                    node_group = nodes_grouped_this_round[node_being_grouped]
                    if node_group == node_being_grouped:
                        continue
                    if node_groups.get(node_group) is None:
                        node_groups[node_group] = []
                    node_groups[node_group].append(node_being_grouped)
                    # If node being grouped was also a group, add grouped nodes as well
                    if node_groups.get(node_being_grouped) is not None:
                        node_groups[node_group] += node_groups[node_being_grouped]
                        node_groups.pop(node_being_grouped)
                    num_nodes_grouped += 1
                #print 'Saving off groupings:\n%s' % json.dumps(node_groups)
                _util.print_step('Nodes grouped this round: %s' % num_nodes_grouped)
                level_of_detail_groupings.append(node_groups)
                nodes_grouped_this_round = {}
        # Save groupings to graph
        G.graph['groups'] = copy.deepcopy(level_of_detail_groupings)
        #with open('%s_%s.json' % (G.graph.get('id', 'tmp'), current_order), 'w') as json_out:
        #    json_out.write(json.dumps(level_of_detail_groupings, indent=2, separators=(',', ': ')))

    # Save graphs
    _util.print_step('saving graph groups')
    with open(infile, 'wb') as write_out:
        cPickle.dump(Gs, write_out, cPickle.HIGHEST_PROTOCOL)

### Command line interface ###
if __name__ == "__main__":
    if len(sys.argv) != 5:
        print 'Usage: %s graphs_infile grouped_outfile node_min node_max' % sys.argv[0]
        quit()
    infile = sys.argv[1]
    outfile = sys.argv[2]
    node_min = sys.argv[3]
    node_max = sys.argv[4]
    run(infile, outfile, node_min, node_max)
