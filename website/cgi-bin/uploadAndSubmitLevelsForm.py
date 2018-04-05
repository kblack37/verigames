#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import cgi
import sys, os
from xml.dom.minidom import parse, parseString
from xml.dom.minidom import getDOMImplementation
import pipejamDB

print "Content-Type: text/html;charset=utf-8"
print

print '<h4>Directions</h4>'

print '<p>Make changes and then click the Submit button.</p>'
print '<p>To activate the level, set the priority > 0 and click the activate checkbox.</p>'
print '<ul><li>Visible Nodes is the total number of nodes in chains with conflicts.</li>'
print '<li>Conflicts is the number of conflicts on the board.</li>'
print '<li>Display Name is the initially set to the fully-qualified class name. You probably want to change that.</li></ul>'


form = cgi.FieldStorage()

resultdir = form.getvalue('resultdir')
ratingsfile = '../html/uploads/'+resultdir+'/gamefiles/difficultyratings.xml'

filesxml = parse(ratingsfile)
filelist = filesxml.getElementsByTagName('file') 
len(filelist)

print '<form name="input" action="/cgi-bin/uploadAndSubmitLevels.py" method="post">'
print '<input type="hidden" name="resultdir" value="'+resultdir +'">'

row = 1
for file in filelist:
	print '<h4>'+str(file.getAttribute('name'))+'</h4>'
	print '<table border="1">'
	print '<tr><th>Level ID</th><th>Visible Nodes</th><th>Conflicts</th><th>Display Name</th><th>Priority</th><th>Active</th></tr>'
	print '<tr>'

	print '<td>'
	fileID = str(file.getAttribute('id'))
	print fileID 
	print '<input type="hidden" name="id_'+str(row)+'" value="'+ fileID +'">'
	print '</td>'

	print '<td align="center">'
	visible_nodes= str(file.getAttribute('visible_nodes'))
	print visible_nodes
	print '</td>'

	print '<td align="center">'
	conflicts= str(file.getAttribute('conflicts'))
	print conflicts
	print '</td>'

	print '<td>'
	displayname = str(file.getAttribute('name'))
	print '<input type="text" name="displayname_'+str(row)+'" value="'+displayname+'">'
	print '</td>'

	print '<td align="center">'
	priority = '0'
	print '<input type="text" name="priority_'+str(row)+'" value="'+priority +'">'
	print '</td>'

	print '<td align="center"><input type="checkbox" name="activecheckbox_'+str(row)+'" value="true"></td>'

	print '</tr></table>'
	row = row + 1

print '<input type="submit" value="Update">'
print '</form>'