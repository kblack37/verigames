#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import pycurl
import cStringIO
import json

print "Content-Type: text/html;charset=utf-8"
print

print '<h4>Current CWE Items</h4>'

buf = cStringIO.StringIO()
c = pycurl.Curl()
c.setopt(c.WRITEFUNCTION, buf.write)
raURL = 'http://api.pipejam.verigames.com/api/cwes'
c.setopt(c.URL, raURL)
c.perform()
raObj = json.loads(buf.getvalue())
buf.close()

print '<table border="1">'
print '<tr><th>Name</th><th>Description</th><th>Reference Link</th><th>View Members</th></tr>'

for item in raObj:
	print '<tr><td>'
	print item['name']
	print '</td><td>'
	print item['description']
	print '</td><td>'
	print item['referenceLink']
	print '</td></tr>'
print '</table>'

print '<br>'
print '<a href="/cgi-bin/CreateCWEItemForm.py">Create More Items</a>'
print '<br>'
print '<a href="/cgi-bin/DeleteCWEItemForm.py">Delete Items</a>'