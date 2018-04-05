'''
Takes the assignments file created by the autosolve_wcnf.py process, and an optional folder 
containing game assignment files in case there are some levels that can't be auto-solved
or that you just want to use game files for.

Creates a standard game assignments file that contains all given assignments and also an array of all _exists variables that are true.
'''
import json
import os, sys


def readAutoSolvedAssignmentsFile(autosolvedFileNameWithPath):
	
	print autosolvedFileNameWithPath
	with open(autosolvedFileNameWithPath, 'r') as content_file:
		assignmentFile = content_file.read()
		assignmentDict = json.loads(assignmentFile)
		existsArray = []
		for nodeKey, nodeAssignment in assignmentDict.items():
			if 'exists' in nodeKey:
				del assignmentDict[nodeKey]
				if int(nodeAssignment[5:]) == 1:
					existsArray.append(nodeKey[:-7])
			else:
				typeDict = {}
				typeDict["type_value"] = nodeAssignment
				assignmentDict[nodeKey] = typeDict
				
		return assignmentDict, existsArray
		
def readGameAssignmentFiles(gameFileDirectory, globalAssignmentDict, existsArray):
	cmd = os.popen('ls %s' % gameFileDirectory) #find Assignments files in an attempt to find unique named files for each level
	
	for filename in cmd:
		print gameFileDirectory + filename.strip()
		with open(gameFileDirectory + filename.strip(), 'r') as content_file:
			assignmentFile = content_file.read()
			assignmentFileJSON = json.loads(assignmentFile)
			fileAssignmentDictionary = assignmentFileJSON["assignments"]
			for nodeKey, nodeAssignmentDict in fileAssignmentDictionary.items():
				for k, v in nodeAssignmentDict.items():
					if 'exists' in nodeKey:
						if int(v[5:]) == 1:
							existsArray.append(nodeKey[:-7])
					else:
						globalAssignmentDict[nodeKey] = v
					
		return globalAssignmentDict, existsArray
		
def outputAssignmentsFile(assignmentDict, existsArray, outputFileName):
	
	outputDict = {}
	outputDict['enabled_vars'] = existsArray
	outputDict['variables'] = assignmentDict
	
	with open(outputFileName, 'w') as f:
		f.write(json.dumps(outputDict))
		

#Better would be for there to be -a and -g flags, so you could do one OR both. Maybe later I'll fix that.
#for the time being, if it's a one char string, assume it's a null path
autosolvedFileName = sys.argv[1]
gameSolvedDirectory = sys.argv[2]
outputFileName = sys.argv[3]	

assignmentDict = None

if len(autosolvedFileName) > 1:
	assignmentDict, existsArray = readAutoSolvedAssignmentsFile(autosolvedFileName)
else:
	assignmentDict = {}
	existsArray = []
	
if len(gameSolvedDirectory) > 1:	
	assignmentDict, existsArray = readGameAssignmentFiles(gameSolvedDirectory, assignmentDict, existsArray)
elif assignmentDict == None:
	assignmentDict = {}
	existsArray = []
	
outputAssignmentsFile(assignmentDict, existsArray, outputFileName)