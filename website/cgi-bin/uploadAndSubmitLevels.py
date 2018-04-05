#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import cgi
import subprocess, sys, re
from xml.dom.minidom import parse, parseString
from xml.dom.minidom import getDOMImplementation
import pipejamDB

print "Content-Type: text/html;charset=utf-8"
print

form = cgi.FieldStorage()
row = 1
resultdir = form.getvalue('resultdir')
ratingsfile = '../html/uploads/'+resultdir+'/gamefiles/difficultyratings.xml'


while row != -1:
	#make sure row exists by getting the name value
	fileID = form.getvalue('id_'+str(row))
	if fileID != None:
		xmlfile = '../html/uploads/'+resultdir+'/gamefiles/'+str(fileID)+'.xml'
		layoutfile = '../html/uploads/'+resultdir+'/gamefiles/'+str(fileID)+'Layout.xml'
		constraintsfile = '../html/uploads/'+resultdir+'/gamefiles/'+str(fileID)+'Constraints.xml'
		
		newBaseName = form.getvalue('displayname_'+str(row))

		newxmlfile = '../html/uploads/'+resultdir+'/gamefiles/'+str(newBaseName)+'.xml'
		newlayoutfile = '../html/uploads/'+resultdir+'/gamefiles/'+str(newBaseName)+'Layout.xml'
		newconstraintsfile = '../html/uploads/'+resultdir+'/gamefiles/'+str(newBaseName)+'Constraints.xml'

		#for each of the three game files, rename the level name attribute to the newBaseName, mv each file to the new name and zip
		
		command = ['mv', xmlfile, newxmlfile]
		subprocess.Popen(command)
		zipxmlfilename = newxmlfile[:-3]+'zip'
		print zipxmlfilename + ' ' + newxmlfile
		zipcommand = ['zip', '-q', zipxmlfilename, newxmlfile]
		subprocess.Popen(zipcommand)

		command = ['mv', layoutfile, newlayoutfile]
		subprocess.Popen(command)
		ziplayoutfilename = newlayoutfile[:-3]+'zip'
		zipcommand = ['zip', '-q', ziplayoutfilename, newlayoutfile]
		subprocess.Popen(zipcommand)

		command = ['mv', constraintsfile, newconstraintsfile]
		subprocess.Popen(command)
		zipconstraintsfilename = newconstraintsfile[:-3]+'zip'
		zipcommand = ['zip', '-q', zipconstraintsfilename, newconstraintsfile]
		subprocess.Popen(zipcommand)

		priority = form.getvalue('priority_'+str(row))
		activate = form.getvalue('activecheckbox_'+str(row))
		
		#Upload levels, passing in path to xml zip file, the level id, the priority, and whether to activate or not 
		command = ['java', '-jar', '/var/www/html/java/UploadLevel.jar', str(zipxmlfilename), str(ratingsfile), str(fileID), str(priority), str(activate)]
		rateCmd = subprocess.Popen(command)
		
		print '<p>uploaded '+newBaseName+'</p>'
		row = row + 1
	else:	
		row = - 1
