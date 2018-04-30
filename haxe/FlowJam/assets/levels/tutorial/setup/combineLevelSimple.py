import sys

FILES = [
	'IntroWidget',
	'WidgetPractice',
	'LockedWidget',
	'Links',
	'Jams',
	'Widen',
	'Optimize',
	'ZoomPan',
	'Layout',
	'GroupSelect',
	'CreateJoint',
	'SkillsA',
	'SkillsB',
]

def combineLevels(files):
	lines = '{"levels":[\n'
	for i, file in enumerate(files):
		if i > 0:
			lines += ',\n'
		for line in open(file):
			linestr = line.rstrip()
			lines += linestr + '\n'
	lines += ']}'
	return lines

open('../tutorial.json', 'w').writelines(combineLevels([fn + '.json' for fn in FILES]))
open('../tutorialAssignments.json', 'w').writelines(combineLevels([fn + 'Assignments.json' for fn in FILES]))
open('../tutorialLayout.json', 'w').writelines(combineLevels([fn + 'Layout.json' for fn in FILES]))
