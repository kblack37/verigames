'''
Note: before running this script,
download:
	http://home.mis.u-picardie.fr/~cli/maxsatz2009.c
	http://www.laria.u-picardie.fr/~cli/maxsatz.tar.gz
build:
	gcc maxsatz2009.c -o maxsatz2009
	gcc maxsatz.c -o maxsatz
'''
import os, json, sys
import time

all_assignments = {}
n_autosolve_levels = 0
n_total_levels = 0
n_autosolve_nodes = 0
n_total_nodes = 0
n_autosolve_constraints = 0
n_total_constraints = 0
current = 0

def handleFile(fname):
	global n_total_levels, n_autosolve_levels, current, n_autosolve_nodes, n_autosolve_constraints, n_total_constraints, n_total_nodes
	is_sat = False
	is_weighted = False
	if fname[-5:] == '.json' or fname[-5:] == '.wcnf':
		ext = fname[-4:]
		n_total_levels += 1
		n_autosolve_levels += 1
		fprefix = fname[:-5]
		is_sat = True
		is_weighted = True
	elif fname[-4:] == '.cnf':
		n_total_levels += 1
		fprefix = fname[:-4]
		is_sat = True
	if is_sat:
		if is_weighted:
			#ext = 'json'
			#print '%s (weighted)' % fprefix
			None
		else:
			ext = 'cnf'
			print fprefix
		# Get mapping of sat var ids (1->n) to original constraint vars (var:12452, etc) from comment in wcnf
		keys = []
		with open(sys.argv[1] + '/%s.%s' % (fprefix, ext), 'r') as sat_in:
			if current % 100 == 0:
				print sys.argv[1] + '\%s.%s' % (fprefix, ext)
			current = current + 1
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
			path = '%s/maxsatz/maxsatz %s/%s.%s'
		with os.popen(path % (SCRIPT_PATH, sys.argv[1], fprefix, ext)) as sat_cmd:
			lines = sat_cmd.readlines()
			print '%s/maxsatz/maxsatz %s/%s.%s' % (SCRIPT_PATH, sys.argv[1], fprefix, ext)
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
		with open('out/%s.out' % fprefix, 'w') as cnf_out:
			for line in lines:
				cnf_out.write(line)
				if "Optimal" in line and not "= 0" in line:
					print "Unoptimal", fprefix
					

if __name__ == "__main__":					
	SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))
	files = os.listdir(sys.argv[1])
	for fname in files:
		print (time.strftime("%H:%M:%S"))
		handleFile(fname)
		print (time.strftime("%H:%M:%S"))
		
	with open('AllAssignments.json', 'w') as asg_out:
		asg_out.write(json.dumps(all_assignments))
	print 'Levels: %s autosolved / %s total = %s' % (n_autosolve_levels, n_total_levels, (n_autosolve_levels / n_total_levels))
	print 'Nodes: %s autosolved / %s total = %s' % (n_autosolve_nodes, n_total_nodes, (n_autosolve_nodes / n_total_nodes))
	print 'constraints: %s autosolved / %s total = %s' % (n_autosolve_constraints, n_total_constraints, (n_autosolve_constraints / n_total_constraints))

