#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import cgi
import sys
import pycurl
import cStringIO
import json

print "Content-Type: text/html;charset=utf-8"
print

print 'Saved:'
form = cgi.FieldStorage()

name = form.getvalue('name')
description = form.getvalue('description')
link = form.getvalue('link')

buf = cStringIO.StringIO()
c = pycurl.Curl()
c.setopt(c.WRITEFUNCTION, buf.write)
c.setopt(c.POSTFIELDS, '[{"name": "'+name+'", "description": "'+description+'", "referenceLink": "'+link +'"}]')
c.setopt(c.HTTPHEADER, ['Content-Type:application/json'])
raURL = 'http://api.pipejam.verigames.com/api/cwes'
c.setopt(c.URL, raURL)
c.perform()
print buf.getvalue()
buf.close()


print '<br>'
print '<br>'
print '<a href="/cgi-bin/CreateCWEItemForm.py">Create More Items</a>'
print '<br>'
print '<a href="/cgi-bin/ViewCWEItemForm.py">View Current List</a>'
