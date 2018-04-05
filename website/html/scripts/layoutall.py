import sys, os, layoutgrid

inputpath = sys.argv[1]
outputpath = sys.argv[2]
cmd = os.popen('ls %s*Layout.xml' % inputpath)
for filename in cmd.xreadlines():
	filein = filename.strip().rstrip('.xml')
	fileout = outputpath + filename.strip().lstrip(inputpath).rstrip('.xml')
	print 'Converting %s  -->  %s ...' % (filein, fileout)
	layoutgrid.layoutboxes(filein, fileout, False)
	print 'Laying out %s ...' % fileout
	
cmd.close()