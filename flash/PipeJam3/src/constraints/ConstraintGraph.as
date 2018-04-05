package constraints 
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import constraints.events.ErrorEvent;
	
	import starling.events.EventDispatcher;
	
	import utils.XString;
	
	public class ConstraintGraph extends EventDispatcher
	{
		public static const GAME_DEFAULT_VAR_VALUE:ConstraintValue = new ConstraintValue(1);
		
		private static const VERSION:String = "version";
		private static const DEFAULT_VAR:String = "default";
		private static const QID:String = "qid";
		// Sections:
		private static const SCORING:String = "scoring";
		private static const VARIABLES:String = "variables";
		private static const CONSTRAINTS:String = "constraints";
		private static const GROUPS:String = "groups";
		// Variable fields:
		private static const DEFAULT:String = "default";
		private static const SCORE:String = "score";
		public static const TYPE_VALUE:String = "type_value";
		// Constraint side types:
		private static const VAR:String = "var";
		private static const C:String = "c";
		
		private static const NULL_SCORING:ConstraintScoringConfig = new ConstraintScoringConfig();
		
		public var variableDict:Dictionary = new Dictionary();
		public var nVars:uint = 0;
		public var constraintsDict:Dictionary = new Dictionary();
		public var nConstraints:uint = 0;
		public var clauseDict:Dictionary = new Dictionary();
		public var nClauses:uint = 0;
		public var groupsArr:Array = new Array();
		public var groupSizes:Vector.<uint> = new Vector.<uint>();
		public var unsatisfiedConstraintDict:Dictionary = new Dictionary();
		public var m_conflictCount:int;
		public var graphScoringConfig:ConstraintScoringConfig = new ConstraintScoringConfig();
		
		protected var m_UnsatisfiedConstraints:Dictionary = new Dictionary();
		protected var m_SatisfiedConstraints:Dictionary = new Dictionary();
		
		public var startingScore:int = NaN;
		public var currentScore:int = 0;	
		public var prevScore:int = 0;
		public var oldScore:int = 0;
		public var maxPossibleScore:int = 0;
		public var qid:int = -1;
		
		static protected var updateCount:int = 0;
		
		public function updateScore(varIdChanged:String = null, propChanged:String = null, newPropValue:Boolean = false):void
		{
			var clauseID:String;
			var constraint:ConstraintEdge;
			
			oldScore = prevScore;
			prevScore = currentScore;
			//			if(updateCount++ % 200 == 0)
			//				trace("updateScore currentScore ", currentScore, " varIdChanged:",varIdChanged);
			var constraintId:String;
			var lhsConstraint:Constraint, rhsConstraint:Constraint;
			var newUnsatisfiedConstraints:Dictionary = new Dictionary();
			var currentConstraints:Dictionary = new Dictionary();
			var newSatisfiedConstraints:Dictionary = new Dictionary();
			if (varIdChanged != null && propChanged != null) {
				var varChanged:ConstraintVar = variableDict[varIdChanged] as ConstraintVar;
				
				var prevBonus:int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
				var prevConstraintPoints:int = 0;
				// Recalc incoming/outgoing constraints
				var i:int;
				for (i = 0; i < varChanged.lhsConstraints.length; i++) {
					lhsConstraint = varChanged.lhsConstraints[i];
					if(lhsConstraint is ConstraintEdge && currentConstraints[lhsConstraint.id] == null)
					{
						constraint = lhsConstraint as ConstraintEdge;
						currentConstraints[constraint.id] = lhsConstraint;
						if (constraint.isClauseSatisfied(varIdChanged, !newPropValue)) prevConstraintPoints += lhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
					}
				}
				for (i = 0; i < varChanged.rhsConstraints.length; i++) {
					rhsConstraint = varChanged.rhsConstraints[i];
					if(rhsConstraint is ConstraintEdge && currentConstraints[rhsConstraint.id] == null)
					{
						constraint = rhsConstraint as ConstraintEdge;
						currentConstraints[rhsConstraint.id] = rhsConstraint;
						if (constraint.isClauseSatisfied(varIdChanged, !newPropValue)) prevConstraintPoints += rhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
					}
				}
				// Recalc incoming/outgoing constraints
				varChanged.setProp(propChanged, newPropValue);
				var newBonus:int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
				var newConstraintPoints:int = 0;
				for each(constraint in currentConstraints) {
					if(constraint.lhs.id.indexOf('c') != -1)
						clauseID = constraint.lhs.id;
					else
						clauseID = constraint.rhs.id;
					if (constraint.isClauseSatisfied(varIdChanged, newPropValue)) { 
						newConstraintPoints += constraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
						newSatisfiedConstraints[clauseID] = constraint;
					} else {
						newUnsatisfiedConstraints[clauseID] = constraint;
					}
				}
				// Offset score by change in bonus and new constraints satisfied/not
				//				trace("newBonus ", newBonus, " prevBonus ", prevBonus, " newConstraintPoints ", newConstraintPoints, " prevConstraintPoints ", prevConstraintPoints);
				currentScore += newConstraintPoints - prevConstraintPoints;
			}
			else {
				currentScore = 0;
				//				for (var varId:String in variableDict) {
				//					var thisVar:ConstraintVar = variableDict[varId] as ConstraintVar;
				//					if (thisVar.getValue() != null && thisVar.scoringConfig != null) {
				//						// If there is a bonus for the current value of thisVar, add to score
				//						currentScore += thisVar.scoringConfig.getScoringValue(thisVar.getValue().verboseStrVal);
				//					}
				//				}
				var scoredConstraints:Dictionary = new Dictionary;
				for (constraintId in constraintsDict) { // TODO: we are recalculating each clause for every edge, need only traverse clauses once
					//old style - scoring per constraint
					//new style - scoring per satisfied clause (might be multiple unsatisfied constraints per clause, but one satisfied one is enough)
					var thisConstr:Constraint = constraintsDict[constraintId] as Constraint;
					if(thisConstr is ConstraintEdge)
					{
						constraint = thisConstr as ConstraintEdge;
						if(thisConstr.lhs.id.indexOf('c') != -1)
							clauseID = thisConstr.lhs.id;
						else
							clauseID = thisConstr.rhs.id;
						if (constraint.isClauseSatisfied(null, false)) {
							//get clauseID
							if(newSatisfiedConstraints[clauseID] == null)
							{
								if(scoredConstraints[clauseID] == null)
								{
									currentScore += thisConstr.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
									scoredConstraints[clauseID] = thisConstr;
								}
								if(m_SatisfiedConstraints[clauseID] == null)
								{
									newSatisfiedConstraints[clauseID] = thisConstr;
									m_SatisfiedConstraints[clauseID] = thisConstr;
									delete m_UnsatisfiedConstraints[clauseID];
								}
							}
						} else {
							if(m_UnsatisfiedConstraints[clauseID] == null)
							{
								newUnsatisfiedConstraints[clauseID] = thisConstr;
								m_UnsatisfiedConstraints[clauseID] = thisConstr;
								delete m_SatisfiedConstraints[clauseID];
							}
						}
					} 
				}
			}

			for (clauseID in newSatisfiedConstraints) {
				if (unsatisfiedConstraintDict.hasOwnProperty(clauseID)) {
					delete unsatisfiedConstraintDict[clauseID];
					m_conflictCount--;
				}
			}
			for (clauseID in newUnsatisfiedConstraints) {
				if (!unsatisfiedConstraintDict.hasOwnProperty(clauseID)) {
					unsatisfiedConstraintDict[clauseID] = newUnsatisfiedConstraints[clauseID];
					m_conflictCount++;
				}
			}
			
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_REMOVED, newSatisfiedConstraints));
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_ADDED, newUnsatisfiedConstraints));
			if (isNaN(startingScore)) startingScore = currentScore;
		}
		
		public function resetScoring():void
		{
			updateScore();
			oldScore = prevScore = currentScore;
		}
		
		public static function fromString(_json:String):ConstraintGraph
		{
			var levelObj:Object = JSON.parse(_json);
			return initFromJSON(levelObj);
		}
		
		public function buildVar(varId:String):void
		{
			var idParts:Array = varId.split(":");
			var formattedId:String = idParts[0] + "_" + idParts[1];
			var varParamsObj:Object = variablesToBuildObj[varId];
			var typeValStr:String = varParamsObj[TYPE_VALUE];
			var varScoring:ConstraintScoringConfig = new ConstraintScoringConfig();
			var scoreObj:Object = varParamsObj[SCORE];
			if (scoreObj) {
				var type0VarScore:int = scoreObj[ConstraintScoringConfig.TYPE_0_VALUE_KEY];
				var type1VarScore:int = scoreObj[ConstraintScoringConfig.TYPE_1_VALUE_KEY];
				varScoring.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0VarScore);
				varScoring.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1VarScore);
			}
			var mergedVarScoring:ConstraintScoringConfig = ConstraintScoringConfig.merge(graphScoringConfig, varScoring);
			var defaultValStr:String = varParamsObj[DEFAULT];
			var defaultVal:ConstraintValue;
			if (defaultValStr) defaultVal = ConstraintValue.fromVerboseStr(defaultValStr);
			var typeVal:ConstraintValue;
			if (typeValStr) {
				typeVal = ConstraintValue.fromVerboseStr(typeValStr);
			} else if (defaultVal) {
				typeVal = defaultVal.clone();
			} else {
				typeVal = graphDefaultVal.clone();
			}
			var newVar:ConstraintVar = new ConstraintVar(formattedId, typeVal, defaultVal, mergedVarScoring);
			variableDict[formattedId] = newVar;
			delete variablesToBuildObj[varId];
		}
		
		public function buildNextCompleteGroup():void
		{
			if (nextGroupToBuild < 0 || nextGroupToBuild >= groupsArr.length) return;
			currentGroupDict = new Dictionary();
			var groupSize:uint = 0;
			for (var groupId:String in groupsArr[nextGroupToBuild]) {
				var groupIdParts:Array = groupId.split(":");
				if (groupIdParts[0] == "clause") groupIdParts[0] = "c";
				var formattedGroupId:String = groupIdParts[0] + "_" + groupIdParts[1];
				var groupedIds:Array = groupsArr[nextGroupToBuild][groupId] as Array;
				for each (var groupedId:String in groupedIds) {
					var groupedIdParts:Array = groupedId.split(":");
					if (groupedIdParts[0] == "clause") groupedIdParts[0] = "c";
					var formattedGroupedId:String = groupedIdParts[0] + "_" + groupedIdParts[1];
					currentGroupDict[formattedGroupedId] = formattedGroupId;
				}
				groupSize++;
			}
			groupSizes.push(groupSize);
			groupsArrComplete.push(currentGroupDict);
			nextGroupToBuild++;
		}
		
		public function buildNextConstraint():void
		{
			if (constraintsToBuildArr.length == 0) return;
			var newConstraint:Constraint;
			
			if (getQualifiedClassName(constraintsToBuildArr[0]) == "String") {
				// process as String, i.e. "var:1 <= c:2"
				var constrString:String = constraintsToBuildArr.shift() as String;
				newConstraint = parseConstraintString(constrString, this, graphDefaultVal, graphScoringConfig);
			} else {
				throw new Error("Unknown constraint format: " + constraintsToBuildArr[0]);
			}
			if (newConstraint is ConstraintEdge) {
				nConstraints++;
				constraintsDict[newConstraint.id] = newConstraint;
				maxPossibleScore++;
				// Attach any groups
				if (groupsArr && totalGroups) {
					var fillLeft:Boolean = (newConstraint.lhs.groups == null);
					var fillRight:Boolean = (newConstraint.rhs.groups == null);
					if (fillLeft) newConstraint.lhs.groups = new Vector.<String>();
					if (fillRight) newConstraint.rhs.groups = new Vector.<String>();
					if (fillLeft || fillRight) {
						for (var g1:int = 0; g1 < totalGroups; g1++) {
							if (fillLeft) {
								var leftGroupId:String = groupsArrComplete[g1].hasOwnProperty(newConstraint.lhs.id) ? groupsArrComplete[g1][newConstraint.lhs.id] : "";
								newConstraint.lhs.groups.push(leftGroupId);
								if (newConstraint.lhs.id != "" && 
									newConstraint.lhs.id != leftGroupId && 
									newConstraint.lhs.rank == 0) {
									// If grouped for the first time this round, rank = group depth
									newConstraint.lhs.rank = newConstraint.lhs.groups.length;
								}
							}
							if (fillRight) {
								var rightGroupId:String = groupsArrComplete[g1].hasOwnProperty(newConstraint.rhs.id) ? groupsArrComplete[g1][newConstraint.rhs.id] : "";
								newConstraint.rhs.groups.push(rightGroupId);
								if (newConstraint.rhs.id != "" && 
									newConstraint.rhs.id != rightGroupId && 
									newConstraint.rhs.rank == 0) {
									// If grouped for the first time this round, rank = group depth
									newConstraint.rhs.rank = newConstraint.rhs.groups.length;
								}
							}
						}
					}
				}
			} else {
				throw new Error("Unknown constraint type:" + newConstraint);
			}
		}
		
		public var version:String;
		public var variablesToBuildObj:Object;
		public var constraintsToBuildArr:Array;
		public var nextGroupToBuild:int = -1;
		public var totalGroups:uint;
		public var groupsArrComplete:Array;
		public var currentGroupDict:Dictionary
		public var graphDefaultVal:ConstraintValue = GAME_DEFAULT_VAR_VALUE;
		
		public static function initFromJSON(levelObj:Object):ConstraintGraph
		{
			//with the inclusion of the import graph.PropDictionary, FlashBuilder confuses the graph package with this var when 
			//just named 'graph'. Add the one so things compile.
			var graph1:ConstraintGraph = new ConstraintGraph();
			var ver:String = levelObj[VERSION];
			graph1.version = levelObj[VERSION];
			var defaultValue:String = levelObj[DEFAULT_VAR];
			graph1.maxPossibleScore = 0;
			graph1.qid = parseInt(levelObj[QID]);
			switch (graph1.version) {
				case "1": // Version 1
				case "2": // Version 2
					// No "default" specified in json, use game default
					if (defaultValue == ConstraintScoringConfig.TYPE_0_VALUE_KEY) {
						graph1.graphDefaultVal = new ConstraintValue(0);
					} else if (defaultValue == ConstraintScoringConfig.TYPE_1_VALUE_KEY) {
						graph1.graphDefaultVal = new ConstraintValue(1);
					} else {
						graph1.graphDefaultVal = GAME_DEFAULT_VAR_VALUE;
					}
					
					// Build Scoring
					var scoringObj:Object = levelObj[SCORING];
					var constraintScore:int = scoringObj ? scoringObj[ConstraintScoringConfig.CONSTRAINT_VALUE_KEY] : 100;
					var variableScoreObj:Object = scoringObj ? scoringObj[VARIABLES] : {"type:0": 0, "type:1": 1};
					var type0Score:int = variableScoreObj[ConstraintScoringConfig.TYPE_0_VALUE_KEY];
					var type1Score:int = variableScoreObj[ConstraintScoringConfig.TYPE_1_VALUE_KEY];
					graph1.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY, constraintScore);
					graph1.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0Score);
					graph1.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1Score);
					
					// Build variables (if any specified, this section is optional)
					graph1.variablesToBuildObj = levelObj[VARIABLES];
					
					// Build constraints, add any uninitialized variables to graph.variableDict, and process groups
					//the process eats the array, so create a copy
					graph1.constraintsToBuildArr = new Array;
					for each(var constraintStr:String in levelObj[CONSTRAINTS])
						graph1.constraintsToBuildArr.push(constraintStr);
					graph1.groupsArr = levelObj.hasOwnProperty(GROUPS) ? levelObj[GROUPS] : new Array();
					graph1.totalGroups = graph1.groupsArr ? graph1.groupsArr.length : 0;
					/**
					 * "groups": [
					 * 			{"var:1":["var:2"], "var:5":["var:7"],...},    <-- stage 1 of grouping
					 * 			{"var:1":["var:2","var:8"], "var:5":["var:7","var:9"],...}, <-- stage 2 of grouping
					 * 			{"var:1":["var:2","var:5","var:7","var:9"],...}, <-- stage 3 of grouping
					 * 		... ]
					 */
					
					graph1.groupSizes = new Vector.<uint>();
					graph1.nextGroupToBuild = -1;
					if (graph1.groupsArr) {
						graph1.groupsArrComplete = new Array();
						graph1.nextGroupToBuild = 0;
						// B
					}
					
					graph1.nVars = graph1.nClauses = graph1.nConstraints = 0;
					// C
					
					break;
				default:
					throw new Error("ConstraintGraph.initFromJSON:: Unknown version encountered: " + graph1.version);
					break;
			}
			
			return graph1;
		}
		
		/**
		 * Incrementally continues to build graph to avoid freezing the game
		 * @return complete: True if graph is completely constructed
		 */
		public function buildNextPartOfGraph():Boolean
		{
			switch (version) {
				case "1": // Version 1
				case "2": // Version 2
					// A. Build any variables left to build
					if (variablesToBuildObj) {
						for (var varId:String in variablesToBuildObj) {
							buildVar(varId);
							return false;
						}
					}
					
					// B. Build any groups left to build
					if (groupsArr) {
						while (nextGroupToBuild < groupsArr.length) {
							buildNextCompleteGroup();
							return false;
						}
					}
					
					// C. Build any remaining constraints
					while (constraintsToBuildArr.length > 0) {
						buildNextConstraint();
						return false;
					}
					
					break;
					
				default:
					throw new Error("ConstraintGraph.buildNextPartOfGraph: Unknown version encountered: " + version);
					break;
			}
			return true;
		}
		
		private static function parseConstraintString(_str:String, _graph:ConstraintGraph, _defaultVal:ConstraintValue, _defaultScoring:ConstraintScoringConfig):Constraint
		{
			var pattern:RegExp = /(var|c):(.*) (<|=)= (var|c):(.*)/i;
			var result:Object = pattern.exec(_str);
			if (result == null) throw new Error("Invalid constraint string found: " + _str);
			if (result.length != 6) throw new Error("Invalid constraint string found: " + _str);
			var lhsType:String = result[1];
			var lhsId:String = result[2];
			var constType:String = result[3];
			var rhsType:String = result[4];
			var rhsId:String = result[5];
			var typeNumArray:Array;
			
			var lsuffix:String = "";
			var rsuffix:String = "";
			if (rhsType == VAR && lhsType == C) {
				typeNumArray = lhsId.split("_");
			} else if (rhsType == C && lhsType == VAR) {
				typeNumArray = rhsId.split("_");
			} else {
				trace("WARNING! Constraint found between two types (no var): " + JSON.stringify(_str));
			}
			
			var lhs:ConstraintSide = parseConstraintSide(lhsType, lhsId, lsuffix, _graph, _defaultVal, _defaultScoring.clone());
			var rhs:ConstraintSide = parseConstraintSide(rhsType, rhsId, rsuffix, _graph, _defaultVal, _defaultScoring.clone());
			
			var newConstraint:Constraint;
			if(rhsType == 'c' || lhsType == 'c')
			{
				newConstraint = new ConstraintEdge(lhs, rhs, _defaultScoring);
			}
			else
			{
				throw new Error("Invalid constraint type found ('"+constType+"') in string: " + _str);
			}
			return newConstraint;
		}
		
		private static function parseConstraintSide(_type:String, _type_num:String, _typeSuffix:String, _graph:ConstraintGraph, _defaultVal:ConstraintValue, _defaultScoring:ConstraintScoringConfig):ConstraintSide
		{
			var fullId:String = _type + "_" + _type_num + _typeSuffix;
			var constrSide:ConstraintSide;
			if (_type == VAR) {
				if (_graph.variableDict.hasOwnProperty(fullId)) {
					constrSide = _graph.variableDict[fullId] as ConstraintVar;
				} else {
					constrSide = new ConstraintVar(fullId, _defaultVal, _defaultVal, _defaultScoring);
					_graph.variableDict[fullId] = constrSide;
					_graph.nVars++;
				}
			} else if (_type == C) {
				fullId = _type + "_" + _type_num;
				if (_graph.clauseDict.hasOwnProperty(fullId)) {
					constrSide = _graph.clauseDict[fullId] as ConstraintClause;
				} else {
					constrSide = new ConstraintClause(fullId, _defaultScoring);
					_graph.clauseDict[fullId] = constrSide;
					_graph.nClauses++;
				}
			} else {
				throw new Error("Invalid constraint element found: ('" + _type + "'). Expecting 'var' or 'c'");
			}
			return constrSide;
		}
		
		public function dispatchUpdateEvents():void
		{
			updateScore();
		}
	}
}