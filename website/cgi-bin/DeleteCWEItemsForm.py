#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import pycurl
import cStringIO
import json

print "Content-Type: text/html;charset=utf-8"
print

print '<h4>Current CWE Items</h4>'
print '<p>Check the items to delete, and then press the Delete Checked button.</p>'

buf = cStringIO.StringIO()
c = pycurl.Curl()
c.setopt(c.WRITEFUNCTION, buf.write)
raURL = 'http://api.pipejam.verigames.com/api/cwes'
c.setopt(c.URL, raURL)
c.perform()
raObj = json.loads(buf.getvalue())
buf.close()

print '<form name="input" action="/cgi-bin/DeleteCWEItems.py" method="post">'
print '<table border="1">'
print '<tr><th>ID</th><th>Name</th><th>Description</th><th>Reference Link</th><th>Delete?</th></tr>'

row = 1
for item in raObj:
	print '<tr><td>'
	print '<input type="hidden" name="id_'+str(row)+'" value="'+item['id']+'">'+item['id']
	print '</td><td>'
	print item['name']
	print '</td><td>'
	print item['description']
	print '</td><td>'
	print item['referenceLink']
	print '</td>'
	print '<td align="center"><input type="checkbox" name="deletecheckbox_'+str(row)+'" value="true"></td>'
	print '</tr>'
	row = row + 1
print '</table>'
print '<input type="submit" value="Delete Checked">'
print '</form>'

