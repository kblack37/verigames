import json, sys, os
import time
from cStringIO import StringIO

var_max = 0
clauses = {}
edge_clauses = {}
var_map = {}
reverse_var_map = {}

def print_wcnf(output_file):
    global var_max, clauses, var_map, reverse_var_map

    f = open(output_file,'w')
 
    f.write('c keys ')
    for var_num in range(1, var_max+1):
        f.write(reverse_var_map[var_num] + ' ')
        
    f.write("\n")
		
    f.write( 'p wcnf ' + str(var_max) + " " + str(len(clauses)) + '\n')

    for cls in clauses:
        f.write('1 ')
        for ll in clauses[cls]:
			f.write(ll + ' ')
        f.write("0\n")
		
    f.close()
	
def create_wcnf_string():
	global var_max, clauses, edge_clauses, var_map, reverse_var_map
 
	f_str = StringIO()
	f_str.write('c keys ')
	for var_num in range(1, var_max+1):
		f_str.write(reverse_var_map[var_num] + ' ')
		
	f_str.write("\n")
		
	f_str.write( 'p wcnf ' + str(var_max) + " " + str(len(clauses)) + '\n')

	for cls in clauses:
		f_str.write('1 ')
		for ll in clauses[cls]:
			f_str.write(ll + ' ')
		f_str.write("0\n")
		
	#make a clause for each var attached to this edge constraint
	for cls in edge_clauses:
		for ll in edge_clauses[cls]:
			f_str.write('100 ')
			f_str.write(ll + ' ')
			f_str.write("0\n")
		
	return f_str.getvalue()


def addConstraint(var, constraint, charSign):
	global clauses, var_max, reverse_var_map
	
	var_num = var[4:]
	constraint_num = constraint[2:]
	
	if var_map.has_key(var_num):
		var = var_map[var_num]
	else:
		var = var_max + 1
		var_max = var_max + 1
		var_map[var_num] = var
		reverse_var_map[var] = var_num
		
	if clauses.has_key(constraint_num):
		clause = clauses[constraint_num]
	else:
		clause = []
		clauses[constraint_num] = clause
		
	clause.append(charSign + str(var))
	
def addEdgeConstraint(var, constraint, charSign):
	global edge_clauses, var_max, reverse_var_map
	
	var_num = var[4:]
	constraint_num = constraint[2:]
	
	if var_map.has_key(var_num):
		var = var_map[var_num]
	else:
		var = var_max + 1
		var_max = var_max + 1
		var_map[var_num] = var
		reverse_var_map[var] = var_num
		
	if edge_clauses.has_key(constraint_num):
		clause = edge_clauses[constraint_num]
	else:
		clause = []
		edge_clauses[constraint_num] = clause
		
	clause.append(charSign + str(var))


#takes an array of constraints from the root game json file 
def process_constraint_block(constraints, lits):
	global var_max, reverse_var_map, clauses, var_map
	reverse_var_map = {}
	var_max = 0
	clauses = {}
	var_map = {}
	for constraint in constraints:
		var_array = constraint.split(" ")
		
		if "var" in var_array[0]:
			addConstraint(var_array[0], var_array[2], '')
		else:
			addConstraint(var_array[2], var_array[0], '-')

			
def process_edge_constraint_block(constraints, lits):
	global var_max, reverse_var_map, edge_clauses, var_map
	edge_clauses = {}
	for constraint in constraints:
		var_array = constraint.split(" ")
		
		if "var" in var_array[0]:
			addEdgeConstraint(var_array[0], var_array[2], '')
		else:
			addEdgeConstraint(var_array[2], var_array[0], '-')
			
def handleFile(file):
	world = json.load(open(file))
	constraints = world['constraints']

	process_constraint_block(constraints, [])

	
if __name__ == "__main__":	
	input_path = sys.argv[1]
	output_path = sys.argv[2]
	for dir_entry in os.listdir(input_path):
		if "Assignments" not in dir_entry and "Layout" not in dir_entry:
			dir_entry_path = os.path.join(input_path, dir_entry)
			if os.path.isfile(dir_entry_path):
				handleFile(dir_entry_path)
				if len(var_map) > 0:
					print_wcnf(os.path.join(output_path, dir_entry[:-5] + ".wcnf"))

