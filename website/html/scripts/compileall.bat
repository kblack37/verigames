import sys, os, classic2grid

inputpath = sys.argv[1]
outputpath = sys.argv[2]

cmd = os.popen('ls %s*.xml' % inputpath)
for filename in cmd.xreadlines():
	filein = filename.strip().rstrip('.xml')
	fileout = outputpath + filename.strip().lstrip(inputpath).rstrip('.xml')
	print 'Converting %s  -->  %s ...' % (filein, fileout)
	classic2grid.classic2grid(filein, fileout)	
cmd.close()