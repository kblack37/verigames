import json, sys, os
from load_constraints_graph import *

MERGE_INTO_TO_NODE = 1
MERGE_INTO_FROM_NODE = -1

group_indx = 0
nodes = {}
groups = {}
node2group = {}

def merge_node_to_group(node, group):
	global nodes
	global groups
	global node2group
	for input_id in node.inputs:
		group.addinput(node.inputs[input_id]) # this will also update the edge to reference this group node
	for output_id in node.outputs:
		group.addoutput(node.outputs[output_id]) # this will also update the edge to reference this group node
	if groups.get(node.id) is None: # node is not group
		node2group[node.id] = group
		group.grouped_nodes[node.id] = node
		if nodes.get(node.id) is not None:
			del nodes[node.id]

def merge_group_to_group(group_to_merge, group_to_remain):
	global node2group
	global groups
	merge_node_to_group(node=group_to_merge, group=group_to_remain)
	if groups.get(group_to_merge.id) is not None:
		del groups[group_to_merge.id]
	for grouped_node_id in group_to_merge.grouped_nodes:
		group_to_remain.grouped_nodes[grouped_node_id] = group_to_merge.grouped_nodes[grouped_node_id]
		node2group[grouped_node_id] = group_to_remain
	group_to_merge.grouped_nodes = {}

def merge_nodes(edge, merge_dir):
	global group_indx
	global groups
	global node2group
	from_node = edge.fromnode
	to_node = edge.tonode
	from_group = node2group.get(from_node.id)
	if from_node.id[:4] == 'grp_':
		from_group = from_node
	to_group = node2group.get(to_node.id)
	if to_node.id[:4] == 'grp_':
		to_group = to_node
	if (merge_dir == MERGE_INTO_TO_NODE and to_group is None) or (merge_dir == MERGE_INTO_FROM_NODE and from_group is None):
		# Create new group
		group = Node('grp_%s' % group_indx, False)
		group_indx += 1
		groups[group.id] = group
		if merge_dir == MERGE_INTO_TO_NODE:
			to_group = group
			node_to_merge = to_node
		else:
			from_group = group
			node_to_merge = from_node
		# Update all input/output edges to point to this new group, rather than the node
		merge_node_to_group(node=node_to_merge, group=group)
	if merge_dir == MERGE_INTO_TO_NODE:
		to_group.removeinput(edge) # no-op for new groups
		if from_group is not None:
			merge_group_to_group(group_to_merge=from_group, group_to_remain=to_group)
		else:
			merge_node_to_group(node=from_node, group=to_group)
	elif merge_dir == MERGE_INTO_FROM_NODE:
		from_group.removeoutput(edge) # no-op for new groups
		if to_group is not None:
			merge_group_to_group(group_to_merge=to_group, group_to_remain=from_group)
		else:
			merge_node_to_group(node=to_node, group=from_group)
	else:
		print 'WARNING: Invalid merge direction: %s' % merge_dir

def optimize_graph(infilename, outfilename):
	global group_indx
	global nodes
	global groups
	global node2group
	version, default_var_type, scoring, nodes, edges, groups, assignments = load_constraints_graph(infilename)
	group_indx = 0
	node2group = {}
	n_edges_reduced = 0
	pass_num = 1
	while pass_num == 1 or n_edges_reduced > 0:
		n_edges_reduced = 0
		removed_edges = {}
		for edge_id in edges:
			edge = edges[edge_id]
			from_node = edge.fromnode
			to_node = edge.tonode
			if from_node.isconstant or to_node.isconstant:
				continue # don't merge fixed nodes for now
			# Remove edges group nodes together into one group node
			if from_node.noutputs == 1 and to_node.ninputs == 1:
				# Case 1: Two nodes connected by one edge with no other edges coming in/out (respectively)
				merge_nodes(edge=edge, merge_dir=MERGE_INTO_TO_NODE)
			elif from_node.ninputs == 0 and from_node.noutputs == 1: #zzz and to_node.ninputs == 1:
				# Case 2: For nodes with no inputs, eliminate edges where to_node's only incoming edge is this one
				merge_nodes(edge=edge, merge_dir=MERGE_INTO_FROM_NODE)
			elif to_node.noutputs == 0 and to_node.ninputs == 1: #zzz and from_node.noutputs == 1:
				# Case 3: For nodes with no outputs, eliminate edges where from_nodes's only outgoing edge is this one
				merge_nodes(edge=edge, merge_dir=MERGE_INTO_TO_NODE)
			else:
				continue
			n_edges_reduced += 1
			removed_edges[edge_id] = True
			#print 'removed %s' % edge_id
		# Remove edges from dict
		for edge_id in removed_edges:
			del edges[edge_id]
		print 'Pass %s removed %s edges' % (pass_num, n_edges_reduced)
		pass_num += 1
	# Reload graph, use original edges
	original_version, original_default_var_type, original_scoring, original_nodes, original_edges, original_groups, original_assignments = load_constraints_graph(infilename)
	with open('%s_OPT.json' % outfilename, 'w') as fout:
		fout.write('{"version": %s,\n' % version)
		# fout.write('"default_var_type": %s,\n' % default_var_type)
		# fout.write('"scoring": %s,\n' % json.dumps(scoring))
		# fout.write('"assignments": %s,\n' % json.dumps(assignments))
		# fout.write('"variables": {},\n')
		# fout.write('"id": "%s",\n' % infilename)
		fout.write('"groups": {\n')
		first = True
		for group_id in groups:
			if not first:
				fout.write(',\n')
			first = False
			fout.write('"%s": [' % groups[group_id].outputvarsimple())
			first_n = True
			for grouped_node_id in groups[group_id].grouped_nodes:
				if not first_n:
					fout.write(',')
				if grouped_node_id[:5] == 'type_':
					fout.write('"type:%s"' % grouped_node_id[5])
				else:
					fout.write('"%s"' % grouped_node_id.replace('_', ':'))
				first_n = False
			fout.write(']')
		fout.write('},\n')
		fout.write('"constraints": [\n')
		first = True
		for edge_id in original_edges:
			if not first:
				fout.write(',\n')
			first = False
			fout.write('"%s <= %s"' % (original_edges[edge_id].fromnode.outputvarsimple(), original_edges[edge_id].tonode.outputvarsimple()))
		fout.write(']}')


### Command line interface ###
if __name__ == "__main__":
	if len(sys.argv) != 2 and len(sys.argv) != 3:
		print ('\n\nUsage: %s input_file [output_file]\n\n'
		'  input_file: name of INPUT constraint .json to be optimized,\n'
		'    omitting ".json" extension\n\n'
		'  output_file: (optional) OUTPUT .json \n'
		'    file name prefix, if none provided use input_file name'
		'\n' % sys.argv[0])
		quit()
	infile = sys.argv[1]
	if len(sys.argv) == 2:
		outfile = sys.argv[1]
	optimize_graph(infile, outfile)