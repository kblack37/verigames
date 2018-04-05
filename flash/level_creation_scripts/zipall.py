import sys, os

inputpath = sys.argv[1]

cmd = os.popen('ls %s*.json' % inputpath)
for filename in cmd:
	startfilenameindex = filename.rfind('/')
	endfilenameindex = filename.rfind('.')
	fileout = filename.strip()[startfilenameindex+1:endfilenameindex]
	print('%s %s' % (inputpath + '/' + fileout, fileout))
	os.popen('zip %s.zip %s' % (inputpath + '/' + fileout, filename))
	