import os
import constraints2grid

files = [f for f in os.listdir('.') if os.path.isfile(f)]
for fname in files:
	if fname[-5:] == '.json' and not fname[-16:] == 'Assignments.json' and not fname[-11:] == 'Layout.json':
		fprefix = fname[:-5]
		constraints2grid.constraints2grid(fprefix, fprefix)
