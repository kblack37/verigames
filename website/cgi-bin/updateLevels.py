#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import cgi
import sys
import pipejamDB

print "Content-Type: text/html;charset=utf-8"
print

form = cgi.FieldStorage()

row = 1

while row != -1:
	#make sure row exists by getting the name value
	val = form.getvalue('name_'+str(row))
 
	if val != None:
		update = form.getvalue('updatecheckbox_'+str(row)) 

		if update != None and update == 'on':
			levelID = form.getvalue('id_'+str(row)).strip()
			newPriority = form.getvalue('priority_'+str(row))
			newPriority = int(float(newPriority))
			prioritySuccess = pipejamDB.setLevelPriority(levelID, newPriority)
			print 'level ' + val + ' updated priority ' + str(prioritySuccess)
			print '<br>'
			active = form.getvalue('activecheckbox_'+str(row))
			if active != None and active == 'on':
				response = str(pipejamDB.setLevelActiveState(levelID, True))
				print 'level ' + val + ' made active ' + response
				print '<br>'
			else:
				response = str(pipejamDB.setLevelActiveState(levelID, False))
				print 'level ' + val + ' made inactive ' + response
				print '<br>'

		row = row + 1
	else:	
		row = - 1


print '<br>'
print '<br>'
print '<a href="/cgi-bin/updateLevelForm.py">Back</a>'