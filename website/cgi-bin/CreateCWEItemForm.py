#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import pycurl
import cStringIO
import json

print "Content-Type: text/html;charset=utf-8"
print

print '<p>To add a CWE Item, enter the data for the CWE:</p>'

print '<form name="input" action="/cgi-bin/CreateCWEItem.py" method="post">'
print '<table>'
print '<tr><th>Name</th><th>Description</th><th>Reference Link</th></tr>'
print '<tr><td><input type="text" name="name"/></td><td><input type="text" name="description"/></td><td><input type="text" name="link"/></td></tr>'
print '<tr><td></td><td></td><td align="right"><input type="submit" value="Add"></td></tr>'
print '</table>'
print '</form>'
