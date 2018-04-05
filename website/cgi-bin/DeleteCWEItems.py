#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import cgi
import sys
import pycurl
import cStringIO
import json

print "Content-Type: text/html;charset=utf-8"
print

form = cgi.FieldStorage()

row = 1
numToDelete = 0
idString = '{"ids":['
while row != -1:
	#make sure row exists by getting the name value
	id = form.getvalue('id_'+str(row))
	if id != None:
		checked = form.getvalue('deletecheckbox_'+str(row))
		if checked == 'true':
			if numToDelete > 0:
				idString = idString + ',' + '"' + id+ '"'
			else:
				idString = idString + '"' + id+ '"'
			numToDelete = numToDelete + 1
		row = row + 1;
	else:	
		row = - 1

idString = idString + ']}'

print idString


buf = cStringIO.StringIO()
c = pycurl.Curl()
print '1'
c.setopt(c.WRITEFUNCTION, buf.write)
c.setopt(c.POSTFIELDS, idString)
print '2'
c.setopt(c.CUSTOMREQUEST, 'DELETE');
print '3'
c.setopt(c.HTTPHEADER, ['Content-Type:application/json'])
raURL = 'http://api.pipejam.verigames.com/api/cwes'
c.setopt(c.URL, raURL)
c.perform()
print buf.getvalue()
buf.close()


print '<br>'
print '<br>'
print '<a href="/cgi-bin/DeleteCWEItemsForm.py">Delete More Items</a>'
print '<br>'
print '<a href="/cgi-bin/ViewCWEItemForm.py">View Current List</a>'