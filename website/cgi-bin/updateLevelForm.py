#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import pymongo
from pymongo import Connection
from pymongo import database
from bson import BSON

import pipejamDB

print "Content-Type: text/html;charset=utf-8"
print


client = Connection('pipejam.verigames.com', 27017)
db = client.gameapi
collection = db.Level
print '<form name="input" action="/cgi-bin/updateLevels.py" method="post">'
print '<table border="1">'
print '<tr><th>Level ID</th><th>Name</th><th>Priority</th><th>Active</th><th>Update</th></tr>'

row = 1
for level in collection.find():
	print '<tr><td>'
	levelID = str(level["levelId"])
	print levelID
	print '<input type="hidden" name="id_'+str(row)+'" value="'
	print levelID+'">'

	print '</td><td>'

	raResponse = pipejamDB.getLevelInfo(levelID)
	print level['name']
	print '<input type="hidden" name="name_'+str(row)+'" value="'
	print level['name']+'">'
	print '</td><td>'
	print '<input type="text" name="priority_'+str(row)+'" value="'
	priority = int(raResponse['metadata']['priority'])
	print priority
	print '"></td>'
	isActive = str(pipejamDB.isLevelActive(levelID))
	if isActive == "True":
		print '<td><input type="checkbox" name="activecheckbox_'+str(row)+'" checked="true"></td>'
	else:
		print '<td><input type="checkbox" name="activecheckbox_'+str(row)+'"></td>'

	print '<td><input type="checkbox" name="updatecheckbox_'+str(row)+'"></td></tr>'
	row = row+1

print '</table>'
print '<input type="submit" value="Update">'
print '</form>'