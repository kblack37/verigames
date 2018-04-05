import json, sys, os, io, time
import json_to_wcnf
import autosolve_wcnfs

#points at array of vars
clausesDict = {}
#points at an array, first value being value of var, second is an array of clauses
varsDict = {}

totalConflicts = 0
currentConflicts = []
clauseCount = 0
'''
The data structure is:

clausesDict has clauseIDs as keys, and a clause dict as values
	the clause dict has two entries:
		variables, which contains a dictionary of attached variables, with the value being
			the clause position(clausePos), i.e. if the clause comes first or second in the constraint
		constraints, which points at an array of constraints that contain this clause
varsDict has varIDs as keys, and its value is an array, the first entry being the value of the var (0,1)
	and the second entry being an dict with keys clauseIDs that var is contained in, and value clausePos
'''

def process_constraint_block(constraints):
    for constraint in constraints:
        var_array = constraint.split(" ")
		
        if "var" in var_array[0]:
			varID = var_array[0]
			clauseID = var_array[2]
			clausePos = 1
        else:
			varID = var_array[2]
			clauseID = var_array[0]
			clausePos = 0

        if varID in varsDict:
			varArray = varsDict[varID]
			varClauseDict = varArray[1]
			varClauseDict[clauseID] = clausePos
        else:
			varClauseDict = {}
			varClauseDict[clauseID] = clausePos
			varArray = [1, varClauseDict]
			varsDict[varID] = varArray
		
        if clauseID in clausesDict:
			clauseDict = clausesDict[clauseID]
			clauseDict['variables'][varID] = clausePos
			constraints = clauseDict['constraints']
			constraints.append(constraint)
        else:
			clauseDict = {}
			clauseDict['variables'] = {}
			clauseDict['variables'][varID] = clausePos
			clauseDict['constraints'] = [constraint]
			clausesDict[clauseID] = clauseDict
	
def countClausesInFile():
	return len(clausesDict)
	
def countConflictsInFile():
	global totalConflicts, currentConflicts
	unsatisfiedCount = 0
	currentConflicts = []
	for clause in clausesDict:
		statisfied = False
		varDict = clausesDict[clause]
		for var in varDict['variables']:
			position = varDict['variables'][var]
			
			varValue = varsDict[var][0]
			
			if position != varValue:
				statisfied = True
			
		if statisfied == False:
			unsatisfiedCount = unsatisfiedCount + 1
			currentConflicts.append(clause)
	
	#print file[-40:], unsatisfiedCount, clauseCount, "%.2f" % (100 -(float(unsatisfiedCount)/float(clauseCount))*100)
	totalConflicts = totalConflicts + unsatisfiedCount
		
	return unsatisfiedCount

		
def solveConflictsInFile(constraints, file):
	json_to_wcnf.process_constraint_block(constraints, [])
	constStr = json_to_wcnf.create_wcnf_string()
	assignments = autosolve_wcnfs.autosolveConstraintString(constStr)
	return assignments
	
	
def createConstraints(path):
	global file, clausesDict, varsDict
	
	clausesDict = {}
	varsDict = {}
	file = path
	world = json.load(open(path))
	return world['constraints']

def writeAssignmentsFile(assignments, path, filenameroot):
	fileDict = {"id":filenameroot,"target_score":0,"hash":[]}
	fileDict["assignments"] = assignments
	
	with open(path+filenameroot+"Assignments"+'.json', 'w') as f:
		f.write(unicode(json.dumps(fileDict, ensure_ascii=False)))

def solveConflicts():
	input_path = sys.argv[2]
	output_path = sys.argv[3]
	file = input_path

	totalConflicts = 0

	#output_path = sys.argv[2]
	if os.path.isfile(input_path):
		constraints = createConstraints(input_path)
		assignments = solveConflictsInFile(constraints, output_path + dir_entry)
		
		fileRootEndIndex = dir_entry.rfind('.')
		fileRootStartIndex = dir_entry.rfind('/')+1
		fileRoot = dir_entry[fileRootStartIndex:fileRootEndIndex]
		writeAssignmentsFile(assignments, output_path, fileRoot)
	else:
		for dir_entry in os.listdir(input_path):
			if "Assignments" not in dir_entry and "Layout" not in dir_entry:
				dir_entry_path = os.path.join(input_path, dir_entry)

				constraints = createConstraints(dir_entry_path)
				assignments = solveConflictsInFile(constraints, output_path + dir_entry)
				
				fileRootEndIndex = dir_entry.rfind('.')
				fileRootStartIndex = dir_entry.rfind('/')+1
				fileRoot = dir_entry[fileRootStartIndex:fileRootEndIndex]
				writeAssignmentsFile(assignments, output_path, fileRoot)
	
def countConflicts():
	input_path = sys.argv[2]
	output_path = sys.argv[3]
	file = input_path

	totalConflicts = 0

	if os.path.isfile(input_path):
		constraints = createConstraints(input_path)

		process_constraint_block(constraints)
		totalConflicts += countConflictsInFile()
	else:
		for dir_entry in os.listdir(input_path):
			if "Assignments" not in dir_entry and "Layout" not in dir_entry:
				dir_entry_path = os.path.join(input_path, dir_entry)

				constraints = createConstraints(dir_entry_path)

				process_constraint_block(constraints)
				totalConflicts += countConflictsInFile()
				
	print 'Total Conflicts: ', totalConflicts

def processClauses(clauseArray, clauseDict, clauseIDsToProcessArray, clauseIDsProcessedDict, maxCount):
	clauseID = clauseIDsToProcessArray.pop(0)
	if len(clauseArray) >= maxCount:
		return
	clauseArray.append(clauseID)	
	clauseDict[clauseID] = 1
	clauseIDsProcessedDict[clauseID] = 0

	clause = clausesDict[clauseID]
	for varID in clause['variables']:
		varClauseArray = varsDict[varID]
		varClauseDict = varClauseArray[1]

		for attachedClauseID in varClauseDict:
			if attachedClauseID not in clauseIDsProcessedDict:
				clauseIDsToProcessArray.append(attachedClauseID)
				clauseIDsProcessedDict[attachedClauseID] = 0
				
def processClausesByVar(clauseArray, clauseDict, clauseIDsToProcessArray, maxCount):
	clauseID = clauseIDsToProcessArray.pop(0)
	if len(clauseArray) >= maxCount:
		return
	clauseArray.append(clauseID)	
	clauseDict[clauseID] = 1

	clause = clausesDict[clauseID]
	for varID in clause['variables']:

		varClauseArray = varsDict[varID]
		varClauseDict = varClauseArray[1]
		for attachedClauseID in varClauseDict:
			if attachedClauseID not in clauseDict:
				clauseIDsToProcessArray.append(attachedClauseID)
			
def processEdgeVars(clauseArray, clauseDict, varDict, clauseIDsToProcessArray, maxCount):

	for clauseID in clauseArray:
		clause = clausesDict[clauseID]
		
		for varID in clause['variables']:
			varDict[varID] = 1

			
def buildConstraintArrayFromClauses(clauseIDArray):
	constraintArray = []
	constraintsProcessedDict = {}
	for clauseID in clauseIDArray:
		clause = clausesDict[clauseID]
		for constraint in clause['constraints']:
			if constraint not in constraintsProcessedDict:
				constraintArray.append(constraint)
				constraintsProcessedDict[constraint] = clause	
	return constraintArray, constraintsProcessedDict
	
def buildConstraintArrayFromClausesByVar(clauseIDArray, clauseIDDict):
	constraintArray = []
	constraintsProcessedDict = {}
	for clauseID in clauseIDArray:
		clause = clausesDict[clauseID]
		for varID in clause['variables']:
			var = varsDict[varID]
			varClauseDict = var[1]
			varSurrounded = True
			for varClauseID in varClauseDict:
				if varClauseID not in clauseIDDict:
					varSurrounded = False
			#if surrounded, find constraint and add to list
			if varSurrounded == True:
				for constraint in clause['constraints']:
					if constraint.find(varID) != -1:
						if constraint not in constraintsProcessedDict:
							constraintArray.append(constraint)
							constraintsProcessedDict[constraint] = clause	
					
	return constraintArray, constraintsProcessedDict
	
#find outer ring of clauses that surround this list, and add to 
def buildEdgeClauseArrayFromClauses(clauseIDDict, resultClauseArray):
	edgeRing = []
	for clauseID in clauseIDDict:
		clause = clausesDict[clauseID]
		
		for varID in clause['variables']:
			varClauseArray = varsDict[varID]
			varClauseDict = varClauseArray[1]

			for attachedClauseID in varClauseDict:
				if attachedClauseID not in clauseIDDict:
					edgeRing.append(attachedClauseID)
					resultClauseArray.append(attachedClauseID)
					
	return edgeRing

def buildEdgeConstraintArrayFromClauses(clauseIDArray, constraintDict):
	constraintArray = []
	#first step: loop through all saved clauses, and if they have a constraint not in the dictionary, add to array
	#second step, loop through array, adding a 
	for clauseID in clauseIDArray:
		clause = clausesDict[clauseID]
		for constraint in clause['constraints']:
			if constraint not in constraintDict:
				constraintArray.append(constraint)
	return constraintArray
				
def solveConflictsBySection(input_file, maxCount):
	global currentConflicts, clausesDict, varsDict
	constraints = createConstraints(input_file)
	process_constraint_block(constraints)
	countConflictsInFile()
	
	print 'Num Conflicts', len(currentConflicts)

	currentIndex = 0
	test = 0
	if len(currentConflicts) > 0 and len(currentConflicts) > currentIndex:
		resultClauseArray = []
		resultClauseDict = {}
		clauseIDsToProcessArray = []
		clauseIDsProcessedDict = {}
		clauseID = currentConflicts[currentIndex]
		clauseIDsToProcessArray.append(clauseID)
		while len(clauseIDsToProcessArray):
			processClauses(resultClauseArray, resultClauseDict, clauseIDsToProcessArray, clauseIDsProcessedDict, maxCount)
		print  'r',resultClauseArray

		preEdgeConstraintsToSolve, preEdgeConstraintDict = buildConstraintArrayFromClauses(resultClauseArray)
		edgeClauseArray = buildEdgeClauseArrayFromClauses(resultClauseDict, resultClauseArray)
		constraintsToSolve, constraintDict = buildConstraintArrayFromClauses(resultClauseArray)
		#print  'c',constraintsToSolve
		edgeConstraintsToSolve = buildEdgeConstraintArrayFromClauses(edgeClauseArray, preEdgeConstraintDict)
		json_to_wcnf.process_constraint_block(constraintsToSolve, [])
		print 'e',edgeConstraintsToSolve
		json_to_wcnf.process_edge_constraint_block(edgeConstraintsToSolve, [])
		constStr = json_to_wcnf.create_wcnf_string()
		print constStr
		assignments = autosolve_wcnfs.autosolveConstraintString(constStr)
		print assignments
		for varID in assignments:
			varValue = int(assignments[varID]['type_value'][5:6])
			varArray = varsDict[varID]
			varArray[0] = varValue
			
		oldCount = len(currentConflicts)
		countConflictsInFile()
		newCount = len(currentConflicts)
		print 'Num Conflicts', newCount, len(assignments)
		
		if oldCount == newCount:
			currentIndex += 1
		else:
			currentIndex = 0
			
def solveConflictsBySectionByVar(input_file, maxCount):
	global currentConflicts, clausesDict, varsDict, clauseCount
	constraints = createConstraints(input_file)
	process_constraint_block(constraints)
	currentMaxCount = maxCount
	clauseCount = float(countClausesInFile())
	countConflictsInFile()
	print 'Num Conflicts', len(currentConflicts)

	currentIndex = 0
	test = 0
	loopCount = 0
	startTime = time.strftime("%H:%M:%S")
	while loopCount != 250:
		try:
			resultClauseArray = []
			resultClauseDict = {}
			resultNodeDict = {}
			clauseIDsToProcessArray = []
			clauseID = currentConflicts[currentIndex]
			clauseIDsToProcessArray.append(clauseID)
			while len(clauseIDsToProcessArray):
				processClausesByVar(resultClauseArray, resultClauseDict, clauseIDsToProcessArray, currentMaxCount)
			
			constraintsToSolve, constraintDict = buildConstraintArrayFromClausesByVar(resultClauseArray, resultClauseDict)
			json_to_wcnf.process_constraint_block(constraintsToSolve, [])
			constStr = json_to_wcnf.create_wcnf_string()

			assignments = autosolve_wcnfs.autosolveConstraintString(constStr)
			for varID in assignments:
				varValue = int(assignments[varID]['type_value'][5:6])
				varArray = varsDict[varID]
				varArray[0] = varValue
				
			oldCount = len(currentConflicts)
			countConflictsInFile()
			newCount = len(currentConflicts)
			print newCount, currentIndex, currentMaxCount, "%.2f" % (100 -(float(newCount)/clauseCount)*100)
			
			if oldCount == newCount:
				currentIndex += 1

			loopCount += 1
		except:
			if len(currentConflicts) > 0 and newCount <= currentIndex:
				currentIndex = 0
				currentMaxCount += 5
			if len(currentConflicts) == 0:
				break
			
	endTime = time.strftime("%H:%M:%S")
	print startTime, endTime
	
def createAssignmentsFromCurrent():
	assignments = {}
	for varID in varsDict:
		assignments[varID] = {"type_value": "type:" + str(varsDict[varID][0])}
		
	return assignments
	
if __name__ == "__main__":	

	functionToCall = sys.argv[1]
	
	if functionToCall == "solveConflicts":
		solveConflicts()
	elif functionToCall == "countConflicts":
		countConflicts()
	elif functionToCall == "solveConflictsBySection":
		solveConflictsBySectionByVar(sys.argv[2], int(sys.argv[4]))
		fileRootEndIndex = sys.argv[2].rfind('.')
		fileRootStartIndex = sys.argv[2].rfind('/')+1
		fileRoot = sys.argv[2][fileRootStartIndex:fileRootEndIndex]
		assignments = createAssignmentsFromCurrent()
		writeAssignmentsFile(assignments, sys.argv[3], fileRoot+'-'+sys.argv[4])