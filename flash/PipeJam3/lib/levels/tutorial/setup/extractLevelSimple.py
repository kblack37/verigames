import sys, json

TUT = 'tutorial.json'
LAY = 'tutorialLayout.json'
ASG = 'tutorialAssignments.json'

for file_name in [TUT, LAY, ASG]:
	with open('../' + file_name, 'r') as fin:
	    file_obj = json.load(fin)
	for level in file_obj.get('levels'):
		level_id = level.get('id')
		if not level_id:
			quit('Level found with no id, quitting...')
		with open('./%s%s' % (level_id, file_name[8:]), 'w') as fout:
			fout.write(json.dumps(level, indent=4))
			