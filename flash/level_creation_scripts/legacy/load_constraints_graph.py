import ijson, json, re, os

NODE_HEIGHT = 1.0

NODE_RADIUS = 0.15
CLAUSE_RADIUS = 0.15

TYPE_0 = 'type:0'
TYPE_1 = 'type:1'
DEFAULT_TYPE = TYPE_1

class BaseNode:
	def __init__(self, id, rad):
		self.id = id
		self.width = rad
		self.height = rad
		self.pt = None
		self.score = None
		self._current_score = None
		self.grouped_nodes = {} # if this node is a group, member nodes are stored here

class Node(BaseNode):
	def __init__(self, id):
		BaseNode.__init__(self, id, NODE_RADIUS)
		self.type_value = None
		self.outputs = {}
		self.noutputs = 0
		self.keyfor_value = None
		self.possible_keyfor = None
		self.default = None
		self._current_value = None
		
	def addoutput(self, edge):
		if self.outputs.get(edge.id) is None:
			self.noutputs += 1
			self.outputs[edge.id] = edge
			edge.fromnode = self

	def removeoutput(self, edge):
		if self.outputs.get(edge.id) is not None:
			self.noutputs -= 1
			del self.outputs[edge.id]
			edge.tonode = None

	def outputvar(self):
		var_obj = {}
		if self.type_value is not None:
			var_obj["type_value"] = self.type_value
		if self.keyfor_value is not None:
			var_obj["keyfor_value"] = self.keyfor_value
		if self.possible_keyfor is not None:
			var_obj["possible_keyfor"] = self.keyfor_value
		if self.default is not None:
			var_obj["default"] = self.default
		if self.score is not None:
			var_obj["score"] = self.score
		return var_obj
	
	def outputvarsimple(self):
		return self.id.replace('_', ':')

	def get_current_value(self, graph_var_default=1):
		if self._current_value is not None:
			return self._current_value
		self._current_score = None # reset score
		current_val = graph_var_default
		if self.id[:6] == 'type_1':
			current_val = 1
		elif self.id[:6] == 'type_0':
			current_val = 0
		elif (self.id[:4] == 'var_' or self.id[:4] == 'grp_') and self.default is not None:
			if self.default == TYPE_0:
				current_val = 0
			elif self.default == TYPE_1:
				current_val = 1
		self._current_value = current_val
		return self._current_value

	def get_current_score(self, graph_var_default=1, graph_scoring=None):
		if self._current_score is not None:
			return self._current_score
		current_val = self.get_current_value(graph_var_default=graph_var_default)
		score = 0.0
		if self.score is not None and self.score.get('type:%s' % current_val) is not None:
			score = float(self.score['type:%s' % current_val])
		elif graph_scoring is not None and graph_scoring.get('variables') is not None and graph_scoring['variables'].get('type:%s' % current_val) is not None:
			score = float(graph_scoring['variables']['type:%s' % current_val])
		self._current_score = score
		return self._current_score

class Clause(BaseNode):
	def __init__(self, id):
		BaseNode.__init__(self, id, CLAUSE_RADIUS)
		self.inputs = {}
		self.ninputs = 0
		
	def addinput(self, edge):
		if self.inputs.get(edge.id) is None:
			self.ninputs += 1
			self.inputs[edge.id] = edge
			edge.tonode = self
	
	def removeinput(self, edge):
		if self.inputs.get(edge.id) is not None:
			self.ninputs -= 1
			del self.inputs[edge.id]
			edge.tonode = None

	def get_currently_satisfied(self, graph_var_default=1):
		return True # zzz

	def get_current_score(self, graph_var_default=1, graph_scoring=None):
		if self._current_score is not None:
			return self._current_score
		is_satisfied = self.get_currently_satisfied(graph_var_default=graph_var_default)
		score = 0.0
		if is_satisfied:
			if self.score is not None:
				score = float(self.score)
				#print 'self.score: %s' % score
			elif graph_scoring.get('constraints') is not None:
				score = float(graph_scoring['constraints'])
				#print 'graph score: %s' % score
		self._current_score = score
		if self.equality_constraint_twin is not None:
			self.equality_constraint_twin._current_score = score
		return self._current_score

class Edge:
	def __init__(self, id, negated):
		self.id = id
		self.negated = negated
		self.score = None
		self.fromnode = None
		self.tonode = None
		self._currently_satisfied = None

	def get_currently_satisfied(self, graph_var_default=1):
		if self._currently_satisfied is not None:
			return self._currently_satisfied
		is_satisfied = False
		if self.fromnode is not None:
			var_value = self.fromnode.get_current_value(graph_var_default=graph_var_default)
			is_satisfied = ((var_value == 1 and not self.negated) or (var_value == 0 and self.negated))
		else:
			raise Exception('Edge found with missing var, edge: %s to: %s from:%s' % (self, self.fromnode))
		self._currently_satisfied = is_satisfied
		#print 'satisfied=%s' % self._currently_satisfied
		return self._currently_satisfied


# Convert constraints (lhs and rhs) to nodes, clauses and edges suitable to graphviz
# Input: lhname:lhid <= rhname:rhid, i.e. type:0 <= var:23 ('type', '0', 'var', '23')
def constr2graph(lhname, lhid, rhname, rhid, score, oper, nodedict, edgedict, clausedict, clauseindx):
	lhconst = True
	rhconst = True
	if (lhname == 'var' or lhname == 'grp') and rhname == 'type':
		if rhid == '1':
			return None# var <= 1 is trivial (always true) so skip this constraint
		lhs = '%s_%s' % (lhname, lhid)
		lhconst = False
		rhs = '%s_%s__%s' % (rhname, rhid, lhs)
	elif (rhname == 'var' or rhname == 'grp') and lhname == 'type':
		if lhid == '0':
			return None# 0 <= var is trivial (always true) so skip this constraint
		rhs = '%s_%s' % (rhname, rhid)
		rhconst = False
		lhs = '%s_%s__%s' % (lhname, lhid, rhs)
	elif (lhname == 'var' or lhname == 'grp') and (rhname == 'var' or rhname == 'grp'):
		lhs = '%s_%s' % (lhname, lhid)
		rhs = '%s_%s' % (rhname, rhid)
		lhconst = False
		rhconst = False
	elif rhname == 'type' and lhname == 'type':
		return None # trivial constraint (either always true or always false) so skip
	else:
		print 'Warning! Unexpected constraint type (not var/grp <> var/grp or var/grp <> type) = "%s" / "%s". Ignoring...' % (lhname, rhname)
		return None
	# Get (or create) node(s)
	lhs_node = None
	rhs_node = None
	if not lhconst: # only create Node for vars, not const
		lhs_node = nodedict.get(lhs)
		if lhs_node is None:
			lhs_node = Node(lhs)
			nodedict[lhs] = lhs_node
	if not rhconst: # only create Node for vars, not const
		rhs_node = nodedict.get(rhs)
		if rhs_node is None:
			rhs_node = Node(rhs)
			nodedict[rhs] = rhs_node
	if not lhconst and not rhconst: # both var
		pass
	elif not lhconst: # lhs var, rhs const
		pass
	elif not rhconst: # rhs var, lhs const
		pass
	else: # both const, this shouldn't happen
		raise Exception('Constraint found between two consts %s %s %s %s %s' % (lhname, lhid, oper, rhname, rhid))
	# Get (or create) edge(s)
	id = '%s -> %s' % (lhs, rhs)
	edge = edgedict.get(id)
	if edge is None:
		edge = Edge(id, negated)
		edgedict[id] = edge
	# Connect edge to nodes
	lhs_node.addoutput(edge)
	rhs_node.addinput(edge)


def load_constraints_graph(infilename):
	regex1 = re.compile("(var|grp|type):(.*) ?(<|=)= ?(var|grp|type):(.*)", re.IGNORECASE)
	regex2 = re.compile("(var|grp|type):(.*)", re.IGNORECASE)
	clause_indx = 0
	nodes = {}
	edges = {}
	clauses = {}
	groups = {}
	assignments = {}
	parser = ijson.parse(open(infilename + '.json', 'r'))
	current_var_id = None
	current_var = None
	current_asg = None
	current_grp = None
	current_grp_formatted = None
	current_score_var_id = None
	current_var_score_key = None
	version = 1
	default_var_type = None
	scoring = None
	for prefix, event, value in parser:
		#print 'prefix: %s event: %s value: %s' % (prefix, event, value)
		# Version
		if (prefix, event) == ('version', 'number'):
			version = value
			#print version
		# Graph default var type
		elif (prefix, event) == ('default', 'string'):
			default_var_type = value
		# Groups
		elif (prefix, event) == ('groups', 'start_map'):
			current_grp = None
			current_grp_formatted = None
		elif (prefix, event) == ('groups', 'map_key'):
			current_grp = value
			current_grp_formatted = value.replace(':','_')
		elif current_grp is not None:
			if (prefix, event) == ('groups.%s' % current_grp, 'start_array'):
				if groups.get(current_grp_formatted) is not None:
					print 'Warning: multiple group definitions found for "%s"' % current_grp_formatted
				groups[current_grp_formatted] = []
			elif (prefix, event) == ('groups.%s.item' % current_grp, 'string'):
				groups[current_grp_formatted].append(value.replace(':','_'))
			elif (prefix, event) == ('groups.%s' % current_grp, 'end_array'):
				current_grp = None
				current_grp_formatted = None
		elif (prefix, event) == ('groups', 'end_map'):
			current_grp = None
			current_grp_formatted = None
		# Scoring
		elif (prefix, event) == ('scoring', 'start_map'):
			if scoring is not None:
				print 'Warning! Multiple scoring sections detected'
			scoring = {}
		elif (prefix, event) == ('scoring.constraints', 'number'):
			scoring['constraints'] = value
		elif (prefix, event) == ('scoring.variables', 'start_map'):
			if scoring.get('variables') is not None:
				print 'Warning! Multiple scoring.variables sections detected'
			scoring['variables'] = {}
		elif (prefix, event) == ('scoring.variables', 'map_key'):
			current_score_var_id = value
		elif current_score_var_id is not None:
			if (prefix, event) == ('scoring.variables.' + current_score_var_id, 'number'):
				if scoring['variables'].get(current_score_var_id) is not None:
					print 'Warning! Multiple scoring.variables.%s entries found' % current_score_var_id
				scoring['variables'][current_score_var_id] = value
			elif (prefix, event) == ('scoring.variables', 'end_map'):
				current_score_var_id = None
				#print 'scoring: %s' % json.dumps(scoring)
		elif (prefix, event) == ('scoring.variables', 'end_map'):
			current_score_var_id = None
		# Constraints
		elif (prefix, event) == ('constraints', 'start_array'):
			pass
		# Begin contraint array item processing
		# Format 1: "var:10 <= type:0"
		elif (prefix, event) == ('constraints.item', 'string'):
			try:
				matches = regex1.search(value).groups()
				lhname = matches[0].strip()
				lhid = matches[1].strip()
				rhname = matches[3].strip()
				rhid = matches[4].strip()
				constr_oper = matches[2].strip()
				constr2graph(lhname, lhid, rhname, rhid, None, constr_oper, nodes, edges, clauses, clause_indx)
			except Exception as e:
				print 'Error parsing constraint: %s -> %s' % (value, e)
				continue
		# Format 2:  { "constraint": "subtype", "lhs": "var:1", "rhs": "var:2", "score": 100 }
		elif (prefix, event) == ('constraints.item', 'start_map'):
			constr2 = {} # open dict for storing constraint info
		elif (prefix, event) == ('constraints.item.lhs', 'string'):
			constr2['lhs'] = value
		elif (prefix, event) == ('constraints.item.rhs', 'string'):
			constr2['rhs'] = value
		elif (prefix, event) == ('constraints.item.score', 'number'):
			constr2['score'] = value
		elif (prefix, event) == ('constraints.item.constraint', 'string'):
			constr2['constr_oper'] = value
			# TODO: Support "selection_check" (if node) and "enabled_check" (generics) and eventually "map.get"
			if value != 'subtype' and value != 'equality' and value != 'comparable':
				print 'Warning! Unsupported constraint type found: %s' % value
		elif (prefix, event) == ('constraints.item', 'end_map'):
			lhs = constr2.get('lhs')
			rhs = constr2.get('rhs')
			score = constr2.get('score')
			constr_oper = constr2.get('constr_oper')
			if constr_oper == 'comparable':
				# For current type systems, this will always be true so omit
				continue
			if lhs is not None and rhs is not None and constr_oper is not None:
				try:
					matches = regex2.search(lhs).groups()
					lhname = matches[0].strip()
					lhid = matches[1].strip()
					matches = regex2.search(rhs).groups()
					rhname = matches[0].strip()
					rhid = matches[1].strip()
				except Exception as e:
					print 'Error parsing constraint: %s %s %s -> %s' % (lhs, constr_oper, rhs, e)
					constr2 = None
					continue
				constr2graph(lhname, lhid, rhname, rhid, score, constr_oper, nodes, edges, clauses, clause_indx)
			else:
				print 'Error parsing constraint: %s %s %s' % (lhs, constr_oper, rhs)
			constr2 = None
		# End Format 2
		elif (prefix, event) == ('constraints', 'end_array'):
			pass
		# End constraint array item processing
		# Begin variables processing
		elif (prefix, event) == ('variables', 'start_map'):
			current_var_id = None
			current_var = None
		elif (prefix, event) == ('variables', 'map_key'):
			current_var_id = value
			formatted_var_id = value.replace(':','_')
			current_var = nodes.get(formatted_var_id)
			if current_var is None:
				current_var = Node(formatted_var_id)
				nodes[formatted_var_id] = current_var
		elif current_var is not None:
			if (prefix, event) == ('variables.%s' % current_var_id, 'start_map'):
				pass
			elif (prefix, event) == ('variables.%s.keyfor_value' % current_var_id, 'start_array'):
				if current_var.keyfor_value is not None:
					print 'Warning: multiple keyfor_value arrays found for var: "%s"' % current_var_id
				current_var.keyfor_value = []
			elif (prefix, event) == ('variables.%s.keyfor_value.item' % current_var_id, 'string'):
				current_var.keyfor_value.append(value)
			elif (prefix, event) == ('variables.%s.possible_keyfor' % current_var_id, 'start_array'):
				if current_var.possible_keyfor is not None:
					print 'Warning: multiple possible_keyfor arrays found for var: "%s"' % current_var_id
				current_var.possible_keyfor = []
			elif (prefix, event) == ('variables.%s.possible_keyfor.item' % current_var_id, 'string'):
				current_var.possible_keyfor.append(value)
			elif (prefix, event) == ('variables.%s.score' % current_var_id, 'start_map'):
				if current_var.score is not None:
					print 'Warning: multiple score dicts found for var: "%s"' % current_var_id
				current_var.score = {}
				current_var_score_key = None
			elif (prefix, event) == ('variables.%s.score' % current_var_id, 'map_key'):
				current_var_score_key = value
			elif current_var_score_key is not None and (prefix, event) == ('variables.%s.score.%s' % (current_var_id, current_var_score_key), 'number'):
				if current_var.score is None:
					current_var.score = {}
				elif current_var.score.get(current_var_score_key) is not None:
					print 'Warning: multiple score keys found for var: "%s" key:""' % (current_var_id, current_var_score_key)
				current_var.score[current_var_score_key] = value
			elif (prefix, event) == ('variables.%s.score' % current_var_id, 'end_map'):
				current_var_score_key = None
			elif (prefix, event) == ('variables.%s.default' % current_var_id, 'string'):
				if current_var.default is not None:
					print 'Warning: multiple defaults found for var: "%s"' % current_var_id
				current_var.default = value
			elif (prefix, event) == ('variables.%s.type_value' % current_var_id, 'string'):
				if current_var.type_value is not None:
					print 'Warning: multiple type_values found for var: "%s"' % current_var_id
				current_var.type_value = value
			elif (prefix, event) == ('variables.%s' % current_var_id, 'end_map'):
				current_var_id = None
				current_var = None
		elif (prefix, event) == ('variables', 'end_map'):
			current_var_id = None
			current_var = None
		# End variables processing
		# Begin assignments processing
		elif (prefix, event) == ('assignments', 'start_map'):
			current_asg = None
		elif (prefix, event) == ('assignments', 'map_key'):
			current_asg = value
		elif current_asg is not None:
			if (prefix, event) == ('assignments.%s' % current_asg, 'start_map'):
				if assignments.get(current_asg) is not None:
					print 'Warning: multiple assignments found for same var: "%s"' % current_asg
				assignments[current_asg] = {}
			elif (prefix, event) == ('assignments.%s.keyfor_value' % current_asg, 'start_array'):
				if assignments[current_asg].get('keyfor_value') is not None:
					print 'Warning: multiple keyfor_value arrays found for var: "%s"' % current_asg
				assignments[current_asg]['keyfor_value'] = []
			elif (prefix, event) == ('assignments.%s.keyfor_value.item' % current_asg, 'string'):
				assignments[current_asg]['keyfor_value'].append(value)
			elif (prefix, event) == ('assignments.%s.type_value' % current_asg, 'string'):
				assignments[current_asg]['type_value'] = value
			elif (prefix, event) == ('assignments.%s' % current_asg, 'end_map'):
				current_asg = None
		elif (prefix, event) == ('assignments', 'end_map'):
			current_asg = None
		# End assignments processing
	# if there are assignments (vars) that weren't involved in constraints, include them now
	for asgid in assignments:
		formattedid = asgid.replace(':', '_')
		if formattedid in nodes:
			continue
		nodes[formattedid] = Node(formattedid)
	# Determine a graph default if none based on scoring, or simply pick one
	if default_var_type is None:
		default_var_type = DEFAULT_TYPE
		if scoring is not None and scoring.get('variables') is not None:
			type0_score = float(scoring['variables'].get(TYPE_0, 0.0))
			type1_score = float(scoring['variables'].get(TYPE_1, 0.0))
			if type0_score > type1_score:
				default_var_type = TYPE_0
			elif type1_score > type0_score:
				default_var_type = TYPE_1
	return version, default_var_type, scoring, nodes, edges, clauses, assignments