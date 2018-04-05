import os, json, sys
import time


n_autosolve_levels = 0
n_total_levels = 0
n_autosolve_nodes = 0
n_total_nodes = 0
n_autosolve_constraints = 0
n_total_constraints = 0
current = 0
lines = ''

def autosolveConstraintString(fStr):
	global n_total_levels, n_autosolve_levels, n_autosolve_nodes, n_autosolve_constraints, n_total_nodes, n_total_constraints, lines
	n_total_levels += 1
	n_autosolve_levels += 1

	# Get mapping of sat var ids (1->n) to original constraint vars (var:12452, etc) from comment in wcnf
	keyStartIndex = fStr.find("keys")
	keyEndIndex = fStr.find("\n", keyStartIndex)
	keyString = fStr[keyStartIndex:keyEndIndex]
	keys = []
	keys = keyString[5:].strip().split(' ')
	path = './maxsatz 1 "%s"'
	all_assignments = {}
	with os.popen(path % (fStr)) as sat_cmd:
		lines = sat_cmd.readlines()
		max_score = None
		penalty = None
		assignments = {}
		for line in lines:
			if line[:2] == 'o ':
				if max_score is None:
					max_score = float(line[2:-1].strip())
				else:
					penalty = float(line[2:-1].strip())
			elif line[:2] == 'v ':
				assignments = line[2:-3].strip().split(' ')
		
		for sat_value_str in assignments:
			sat_value = int(sat_value_str)
			sat_id = abs(sat_value)
			constraint_value = {}
			if sat_id == sat_value: # if positive, set assignment to 1 = type:1
				constraint_value["type_value"] = "type:1"
			else:
				constraint_value["type_value"] = "type:0"
			constraint_id = 'var:%s' % keys[sat_id-1]
			if all_assignments.get(constraint_id) is not None:
				print 'Warning! Multiple assignments found for %s' % constraint_id
			else:
				all_assignments[constraint_id] = constraint_value
			
	return all_assignments
					
def autosolveFile(script_path, input_path, output_path, fname):
	global n_total_levels, n_autosolve_levels, n_autosolve_nodes, n_autosolve_constraints, n_total_nodes, n_total_constraints
	ext = fname[-4:]
	n_total_levels += 1
	n_autosolve_levels += 1
	fprefix = fname[:-5]
	all_assignments = {}
	# Get mapping of sat var ids (1->n) to original constraint vars (var:12452, etc) from comment in wcnf
	keys = []
	with open('%s%s.%s' % (input_path, fprefix, ext), 'r') as sat_in:
		for input_line in sat_in:
			input_line = input_line.strip()
			if input_line[:7] == 'c keys ':
				keys = input_line[7:].strip().split(' ')
			elif input_line[:9] == 'c offset ':
				score_offset = float(input_line[9:].strip())
			elif input_line[:7] == 'p wcnf ':
				nodes_constraints = input_line[7:].split(' ')
				n_autosolve_nodes += int(nodes_constraints[0])
				n_total_nodes += int(nodes_constraints[0])
				n_autosolve_constraints += int(nodes_constraints[1])
				n_total_constraints += int(nodes_constraints[1])
			elif input_line[:7] == 'p cnf ':
				nodes_constraints = input_line[7:].split(' ')
				n_total_nodes += int(nodes_constraints[0])
				n_total_constraints += int(nodes_constraints[1])
		path = script_path + 'maxsatz/maxsatz.exe 0 %s%s.%s'
	with os.popen(path % (input_path, fprefix, ext)) as sat_cmd:
		lines = sat_cmd.readlines()

		print path % (input_path, fprefix, ext)
		print lines
		max_score = None
		penalty = None
		assignments = {}
		for line in lines:
			if line[:2] == 'o ':
				if max_score is None:
					max_score = float(line[2:-1].strip())
				else:
					penalty = float(line[2:-1].strip())
			elif line[:2] == 'v ':
				assignments = line[2:-3].strip().split(' ')
		for sat_value_str in assignments:
			sat_value = int(sat_value_str)
			sat_id = abs(sat_value)
			if sat_id == sat_value: # if positive, set assignment to 1 = type:1
				constraint_value = 'type:1'
			else:
				constraint_value = 'type:0'
			#if sat_id > len(keys):
			#	print 'Warning! Found sat variable id out of range given in keys from .%s file: %s len(keys): %s' % (ext, sat_id, len(keys))
			#	continue
			constraint_id = 'var:%s' % keys[sat_id-1]
			if all_assignments.get(constraint_id) is not None:
				#print 'Warning! Multiple assignments found for %s' % constraint_id
				continue
			all_assignments[constraint_id] = constraint_value
	with open('%s%s.out' % output_path, fprefix, 'w') as cnf_out:
		for line in lines:
			cnf_out.write(line)
			if "Optimal" in line and not "= 0" in line:
				print "Unoptimal", fprefix
				
	return all_assignments
					
def outputAssignments(filename, assignments):
	with open(filename, 'w') as asg_out:
		asg_out.write(json.dumps(assignments))
		
if __name__ == "__main__":					
	SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))
	output_path = sys.argv[3]
	files = os.listdir(sys.argv[1])
	for fname in files:
		print (time.strftime("%H:%M:%S"))
		assignments = autosolveFile(SCRIPT_PATH, sys.argv[1], output_path, fname)
		print (time.strftime("%H:%M:%S"))

	output_file = sys.argv[2]		
	outputAssignments(output_file, assignments)
	
	print 'Levels: %s autosolved / %s total = %s' % (n_autosolve_levels, n_total_levels, (n_autosolve_levels / n_total_levels))
	print 'Nodes: %s autosolved / %s total = %s' % (n_autosolve_nodes, n_total_nodes, (n_autosolve_nodes / n_total_nodes))
	print 'constraints: %s autosolved / %s total = %s' % (n_autosolve_constraints, n_total_constraints, (n_autosolve_constraints / n_total_constraints))

