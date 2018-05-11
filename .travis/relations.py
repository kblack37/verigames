'''
This program iterates through all modules in some directory and determines
for each what other modules it uses are.

Output File Format:
- The first line contains all modules, separated by spaces. Each module is in
  the form "moduleName:lineCount".
- Each remaining line contains a list of space separated modules. The first
  is some module, the others are modules the first module uses
'''

import os

# Get all modules
modules = set()
for root, dirs, files in os.walk("./haxe/FlowJam/src"):
    for f in files:
        module_name = f.split(".")[0]
        modules.add(module_name)


# Determine file relations
relations = {}
line_count = {}
for root, dirs, files in os.walk("./haxe/FlowJam/src"):
    for f in files:
        module_name = f.split(".")[0]
        path = root + "/" + f
        relations[module_name] = set()
        with open(path) as infile:
            num_lines = 0
            for line in infile:
                num_lines += 1
                for module in modules:
                    if(module != module_name and module in line):
                        relations[module_name].add(module)
            line_count[module_name] = num_lines

# Print to data file
outfile = open("./fj_relation_data.txt", "w")

# Print module names
for module in relations:
    outfile.write(module + ":" + str(line_count[module]) + " ")
outfile.write("\n")
# Print modules and their used modules
for module in relations:
    outfile.write(module)
    for related in relations[module]:
        outfile.write(" " + related)
    outfile.write("\n")
outfile.close()
