import sys

file = sys.argv[1]
name = sys.argv[2]

inotherlevel = False

for line in open(file):
    if '<level' in line and name not in line:
        inotherlevel = True

    linestr = line.rstrip()
    if not inotherlevel and len(linestr) != 0:
        print linestr

    if '</level' in line:
        inotherlevel = False
