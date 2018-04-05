#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os, sys, re
import fileinput
#import pipejamDB

nextNameAlias = 1
nameDict = {}

### Main function ###
def separateLevels(infile, outdirectory, fileMap, useRA, startNumber):
	print ('parsing xml')
	count = 1
	global nextNameAlias
	global nameDict
	writeLines = False
	writeNextLine = False
	isLevel = False
	nextID = startNumber
	readLinkedVarIDs = False
	inLinkedVarIDs = False
	linkedVarIDs = []
	#get levelID from RA
	if useRA:
		id = pipejamDB.getNewLevelID()
	else:
		id = str(nextID)
	nextID = nextID + 1
	levelFile = open(outdirectory + '/'+id+'.xml','w')
	levelFile.write('<world version="3" id="'+id+'">\n')

	for line in fileinput.input(infile):
			
		if line.find('linked-varIDs') != -1:
			inLinkedVarIDs = not inLinkedVarIDs;
			if inLinkedVarIDs == False:
				linkedVarIDs.append(line)
				readLinkedVarIDs = True
			
		if inLinkedVarIDs == True and readLinkedVarIDs == False:
			linkedVarIDs.append(line)
			
		if readLinkedVarIDs == False:
			continue
			
		levelName = ""
		if line.find('<level') != -1:
			for item in linkedVarIDs:
				levelFile.write("%s" % item)
			nameStart = line.find('name="') + 6
			nameEnd = line.find('"', nameStart)
			levelName = line[nameStart:nameEnd]
			fileMap.write('<level name="'+levelName+'" id="'+id+'">')
			writeLines = True
			writeNextLine = True

			print (levelName)

		if line.find('name=') != -1:
			nameStart = line.find('name="') + 6
			nameEnd = line.find('"', nameStart)
			name = line[nameStart:nameEnd]
			lineStart = line[:nameStart]
			lineEnd = line[nameEnd:]
			
			#name = name.replace(".", "_")

			nameAlias = str(nextNameAlias)
			if nameDict.has_key(name):
				nameAlias = nameDict[name]
			else:
				nameDict[name] = nameAlias
				nextNameAlias = nextNameAlias + 1
				
			line = lineStart + nameAlias + lineEnd
			
		elif line.find('<layout') != -1:
			writeLines = False
			writeNextLine = False

		elif line.find('</layout') != -1:
			writeNextLine = True

		elif line.find('</level') != -1:
			levelFile.write(line)
			writeLines = False
			levelFile.write('</world>')
			levelFile.flush()
			levelFile.close()
			count+=1
			#get levelID from RA
			if useRA:
				id = pipejamDB.getNewLevelID()
			else:
				id = str(nextID)
			nextID = nextID + 1
			nameStart = line.find('name="') + 6
			nameEnd = line.find('"', nameStart)
			name = line[nameStart:nameEnd]

			levelFile = open(outdirectory + '/'+id+'.xml','w')
			levelFile.write('<world version="3">\n')
		 
		if writeLines:
			levelFile.write(line)

		if writeNextLine:
			writeLines = True




	levelFile.close()


### Command line interface ###
if __name__ == "__main__":
	if (len(sys.argv) < 2) or (len(sys.argv) > 4):
		print ('\n\nUsage: %s input_directory output_directory (if useRA == false) setNumber\n\n  input_directory: input directory'
			'\n  output_directory: output directory. Must exist.\n  setNumber: The number of this library in the grand scheme of things.') % (sys.argv[0])
		quit()
	if len(sys.argv) > 2:
		outdirectory = sys.argv[2]
	else:
		outdirectory = sys.argv[1]
	infile = sys.argv[1]
	print ('calling separateLevels')
	fileMap = open(outdirectory + '/'+'filemap.xml','w')
	
	#change as needed
	useRA = False
	startNumber = 1
	if useRA == False and len(sys.argv) == 4:
		startNumber = int(sys.argv[3])*10000
	else:
		print("Missing set number")
		quit()
		
	fileMap.write('<levels>')
	separateLevels(infile, outdirectory, fileMap, useRA, startNumber)
	fileMap.write('</levels')
	
	fileMap.write('<namemaps>')
	for key, value in nameDict.items():
		fileMap.write('<namemap name="'+key+'" value="'+value+'"/>')
	fileMap.write('<namemaps>')