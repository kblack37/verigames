package constraints 
{
	import constraints.events.ErrorEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
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
		private static const GROUPS:String = "groups";
		private static const VARIABLES:String = "variables";
		private static const CONSTRAINTS:String = "constraints";
		// Constraint fields:
		private static const CONSTRAINT:String = "constraint";
		private static const LHS:String = "lhs";
		private static const RHS:String = "rhs";
		// Variable fields:
		private static const DEFAULT:String = "default";
		private static const SCORE:String = "score";
		private static const POSSIBLE_KEYFORS:String = "possible_keyfor";
		public static const TYPE_VALUE:String = "type_value";
		public static const KEYFOR_VALUES:String = "keyfor_value";
		private static const CONSTANT:String = "constant";
		// Constraint side types:
		private static const VAR:String = "var";
		private static const TYPE:String = "type";
		private static const GRP:String = "grp";
		
		private static const NULL_SCORING:ConstraintScoringConfig = new ConstraintScoringConfig();
		
		public var variableDict:Dictionary = new Dictionary();
		public var constraintsDict:Dictionary = new Dictionary();
		public var unsatisfiedConstraintDict:Dictionary = new Dictionary();
		public var graphScoringConfig:ConstraintScoringConfig = new ConstraintScoringConfig();
		
		public var startingScore:int = NaN;
		public var currentScore:int = 0;
		public var prevScore:int = 0;
		public var oldScore:int = 0;
		
		public var qid:int = -1;
		
		public function updateScore(varIdChanged:String = null, propChanged:String = null, newPropValue:Boolean = false):void
		{
			oldScore = prevScore;
			prevScore = currentScore;
			trace("updateScore currentScore ", currentScore, " varIdChanged:",varIdChanged);
			var constraintId:String;
			var lhsConstraint:Constraint, rhsConstraint:Constraint;
			var newUnsatisfiedConstraints:Dictionary = new Dictionary();
			var newSatisfiedConstraints:Dictionary = new Dictionary();
			if (varIdChanged != null && propChanged != null) {
				var varChanged:ConstraintVar = variableDict[varIdChanged] as ConstraintVar;
				if (varChanged.getValue() != null && varChanged.scoringConfig != null) {
					var prevBonus:int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
					var prevConstraintPoints:int = 0;
					// Recalc incoming/outgoing constraints
					var i:int;
					for (i = 0; i < varChanged.lhsConstraints.length; i++) {
						lhsConstraint = varChanged.lhsConstraints[i];
						if (lhsConstraint.isSatisfied()) prevConstraintPoints += lhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
					}
					for (i = 0; i < varChanged.rhsConstraints.length; i++) {
						rhsConstraint = varChanged.rhsConstraints[i];
						if (rhsConstraint.isSatisfied()) prevConstraintPoints += rhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
					}
					// Recalc incoming/outgoing constraints
					varChanged.setProp(propChanged, newPropValue);
					var newBonus:int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
					var newConstraintPoints:int = 0;
					for (i = 0; i < varChanged.lhsConstraints.length; i++) {
						lhsConstraint = varChanged.lhsConstraints[i];
						if (lhsConstraint.isSatisfied()) {
							newConstraintPoints += lhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
							newSatisfiedConstraints[lhsConstraint.id] = lhsConstraint;
						} else {
							newUnsatisfiedConstraints[lhsConstraint.id] = lhsConstraint;
						}
					}
					for (i = 0; i < varChanged.rhsConstraints.length; i++) {
						rhsConstraint = varChanged.rhsConstraints[i];
						if (rhsConstraint.isSatisfied()) {
							newConstraintPoints += rhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
							newSatisfiedConstraints[rhsConstraint.id] = rhsConstraint;
						} else {
							newUnsatisfiedConstraints[rhsConstraint.id] = rhsConstraint;
						}
					}
					// Offset score by change in bonus and new constraints satisfied/not
					trace("newBonus ", newBonus, " prevBonus ", prevBonus, " newConstraintPoints ", newConstraintPoints, " prevConstraintPoints ", prevConstraintPoints);
					currentScore += (newBonus - prevBonus) + (newConstraintPoints - prevConstraintPoints);
					trace("new currentScore ", currentScore);
				}
			} else {
				currentScore = 0;
				for (var varId:String in variableDict) {
					var thisVar:ConstraintVar = variableDict[varId] as ConstraintVar;
					if (thisVar.getValue() != null && thisVar.scoringConfig != null) {
						// If there is a bonus for the current value of thisVar, add to score
						currentScore += thisVar.scoringConfig.getScoringValue(thisVar.getValue().verboseStrVal);
					}
				}
				for (constraintId in constraintsDict) {
					var thisConstr:Constraint = constraintsDict[constraintId] as Constraint;
					if (thisConstr.isSatisfied()) {
						currentScore += thisConstr.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
						newSatisfiedConstraints[constraintId] = thisConstr;
					} else {
						newUnsatisfiedConstraints[constraintId] = thisConstr;
					}
				}
			}
			for (constraintId in newSatisfiedConstraints) {
				if (unsatisfiedConstraintDict.hasOwnProperty(constraintId)) {
					delete unsatisfiedConstraintDict[constraintId];
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_REMOVED, newSatisfiedConstraints[constraintId]));
				}
			}
			for (constraintId in newUnsatisfiedConstraints) {
				if (!unsatisfiedConstraintDict.hasOwnProperty(constraintId)) {
					unsatisfiedConstraintDict[constraintId] = newUnsatisfiedConstraints[constraintId];
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_ADDED, newUnsatisfiedConstraints[constraintId]));
				}
			}
			if (isNaN(startingScore)) startingScore = currentScore;
			trace("Score: " + currentScore);
		}
		
		public function resetScoring():void
		{
			updateScore();
			oldScore = prevScore = currentScore;
		}
		
		public static function fromString(_json:String):ConstraintGraph
		{
			var levelObj:Object = JSON.parse(_json);
			return fromJSON(levelObj);
		}
		
		public static function fromJSON(levelObj:Object):ConstraintGraph
		{
			var graph:ConstraintGraph = new ConstraintGraph();
			var ver:String = levelObj[VERSION];
			var defaultValue:String = levelObj[DEFAULT_VAR];
			graph.qid = parseInt(levelObj[QID]);
			switch (ver) {
				case "1": // Version 1
					// No "default" specified in json, use game default
					var graphDefaultVal:ConstraintValue;
					if (defaultValue == ConstraintScoringConfig.TYPE_0_VALUE_KEY) {
						graphDefaultVal = new ConstraintValue(0);
					} else if (defaultValue == ConstraintScoringConfig.TYPE_1_VALUE_KEY) {
						graphDefaultVal = new ConstraintValue(1);
					} else {
						graphDefaultVal = GAME_DEFAULT_VAR_VALUE;
					}
					// Build Scoring
					var scoringObj:Object = levelObj[SCORING];
					var groupsObj:Object = levelObj[GROUPS];
					var constraintScore:int = scoringObj[ConstraintScoringConfig.CONSTRAINT_VALUE_KEY];
					var variableScoreObj:Object = scoringObj[VARIABLES];
					var type0Score:int = variableScoreObj[ConstraintScoringConfig.TYPE_0_VALUE_KEY];
					var type1Score:int = variableScoreObj[ConstraintScoringConfig.TYPE_1_VALUE_KEY];
					graph.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY, constraintScore);
					graph.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0Score);
					graph.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1Score);
					
					// Build variables (if any specified, this section is optional)
					var variablesObj:Object = levelObj[VARIABLES];
					if (variablesObj) {
						for (var varId:String in variablesObj) {
							var idParts:Array = varId.split(":");
							var formattedId:String = idParts[0] + "_" + idParts[1];
							var varParamsObj:Object = variablesObj[varId];
							var isConstant:Boolean = false;
							if (varParamsObj.hasOwnProperty(CONSTANT)) isConstant = XString.stringToBool(varParamsObj[CONSTANT] as String);
							var typeValStr:String = varParamsObj[TYPE_VALUE];
							var varScoring:ConstraintScoringConfig = new ConstraintScoringConfig();
							var scoreObj:Object = varParamsObj[SCORE];
							if (scoreObj) {
								var type0VarScore:int = scoreObj[ConstraintScoringConfig.TYPE_0_VALUE_KEY];
								var type1VarScore:int = scoreObj[ConstraintScoringConfig.TYPE_1_VALUE_KEY];
								varScoring.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0VarScore);
								varScoring.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1VarScore);
							}
							var mergedVarScoring:ConstraintScoringConfig = ConstraintScoringConfig.merge(graph.graphScoringConfig, varScoring);
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
							var possibleKeyfors:Vector.<String> = new Vector.<String>();
							var possibleKeyforsArr:Array = varParamsObj[POSSIBLE_KEYFORS];
							if (possibleKeyforsArr) {
								for (var i:int = 0; i < possibleKeyforsArr.length; i++) possibleKeyfors.push(possibleKeyforsArr[i]);
							}
							var keyforVals:Vector.<String> = new Vector.<String>();
							var keyforValsArr:Array = varParamsObj[KEYFOR_VALUES];
							if (keyforValsArr) {
								for (var j:int = 0; j < keyforValsArr.length; j++) keyforVals.push(keyforValsArr[j]);
							}
							var newVar:ConstraintVar = new ConstraintVar(formattedId, typeVal, defaultVal, isConstant, isConstant ? NULL_SCORING : mergedVarScoring, possibleKeyfors, keyforVals);
							graph.variableDict[formattedId] = newVar;
						}
					}
					
					// Build constraints (and add any uninitialized variables to graph.variableDict)
					var constraintsArr:Array = levelObj[CONSTRAINTS];
					for (var c:int = 0; c < constraintsArr.length; c++) {
						var newConstraint:Constraint;
						if (getQualifiedClassName(constraintsArr[c]) == "String") {
							// process as String, i.e. "var:1 <= var:2"
							newConstraint = parseConstraintString(constraintsArr[c] as String, graph.variableDict, graphDefaultVal, graph.graphScoringConfig.clone());
						} else {
							// process as json object i.e. {"rhs": "type:1", "constraint": "subtype", "lhs": "var:9"}
							newConstraint = parseConstraintJson(constraintsArr[c] as Object, graph.variableDict, graphDefaultVal, graph.graphScoringConfig.clone());
						}
						if (newConstraint is EqualityConstraint) {
							// For equality, convert to two separate equality constaints (one for each edge) and put in constraintsDict
							// Scoring: take same scoring for now, any conflict on EITHER subtype constraint will cause -100 (or whatever conflict penalty is for the equality constrtaint)
							var constr1:SubtypeConstraint = new SubtypeConstraint(newConstraint.lhs, newConstraint.rhs, newConstraint.scoring);
							var constr2:SubtypeConstraint = new SubtypeConstraint(newConstraint.rhs, newConstraint.lhs, newConstraint.scoring);
							graph.constraintsDict[constr1.id] = constr1;
							graph.constraintsDict[constr2.id] = constr2;
						} else if (newConstraint is SubtypeConstraint) {
							graph.constraintsDict[newConstraint.id] = newConstraint;
						}
					}
					
					break;
				default:
					throw new Error("ConstraintGraph.fromJSON:: Unknown version encountered: " + ver);
					break;
			}
			graph.updateScore();
			return graph;
		}
		
		private static function parseConstraintString(_str:String, _variableDictionary:Dictionary, _defaultVal:ConstraintValue, _defaultScoring:ConstraintScoringConfig):Constraint
		{
			var pattern:RegExp = /(var|type|grp):(.*) (<|=)= (var|type|grp):(.*)/i;
			var result:Object = pattern.exec(_str);
			if (result == null) throw new Error("Invalid constraint string found: " + _str);
			if (result.length != 6) throw new Error("Invalid constraint string found: " + _str);
			var lhsType:String = result[1];
			var lhsId:String = result[2];
			var constType:String = result[3];
			var rhsType:String = result[4];
			var rhsId:String = result[5];
			
			var lsuffix:String = "";
			var rsuffix:String = "";
			if (lhsType == VAR && rhsType == TYPE) {
				rsuffix = "__" + VAR + "_" + lhsId;
			} else if (lhsType == GRP && rhsType == TYPE) {
				rsuffix = "__" + GRP + "_" + lhsId;
			} else if (rhsType == VAR && lhsType == TYPE) {
				lsuffix = "__" + VAR + "_" + rhsId;
			} else if (rhsType == GRP && lhsType == TYPE) {
				lsuffix = "__" + GRP + "_" + rhsId;
			} else if (rhsType == TYPE && lhsType == TYPE) {
				trace("WARNING! Constraint found between two types (no var): " + JSON.stringify(_str));
			}
			
			var lhs:ConstraintVar = parseConstraintSide(lhsType, lhsId, lsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
			var rhs:ConstraintVar = parseConstraintSide(rhsType, rhsId, rsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
			
			var newConstraint:Constraint;
			switch (constType) {
				case "<":
					newConstraint = new SubtypeConstraint(lhs, rhs, _defaultScoring.clone());
					break;
				case "=":
					newConstraint = new EqualityConstraint(lhs, rhs, _defaultScoring.clone());
					break;
				default:
					throw new Error("Invalid constraint type found ('"+constType+"') in string: " + _str);
					break;
			}
			return newConstraint;
		}
		
		private static function parseConstraintJson(_constraintJson:Object, _variableDictionary:Dictionary, _defaultVal:ConstraintValue, _defaultScoring:ConstraintScoringConfig):Constraint
		{
			var type:String = _constraintJson[CONSTRAINT];
			var lhsStr:String = _constraintJson[LHS];
			var rhsStr:String = _constraintJson[RHS];
			var pattern:RegExp = /(var|type|grp):(.*)/i;
			var lhsResult:Object = pattern.exec(lhsStr);
			var rhsResult:Object = pattern.exec(rhsStr);
			if (!lhsResult || !rhsResult) throw new Error("Error parsing constraint json for lhs:'" + lhsStr + "' rhs:'" + rhsStr + "'");
			if (lhsResult.length != 3 || rhsResult.length != 3) throw new Error("Error parsing constraint json for lhs:'" + lhsStr + "' rhs:'" + rhsStr + "'");
			
			var lsuffix:String = "";
			var rsuffix:String = "";
			if ((lhsResult[1] as String) == VAR && (rhsResult[1] as String) == TYPE) {
				rsuffix = "__" + VAR + "_" + (lhsResult[2] as String);
			} else if ((lhsResult[1] as String) == GRP && (rhsResult[1] as String) == TYPE) {
				rsuffix = "__" + GRP + "_" + (lhsResult[2] as String);
			} else if ((rhsResult[1] as String) == VAR && (lhsResult[1] as String) == TYPE) {
				lsuffix = "__" + VAR + "_" + (rhsResult[2] as String);
			} else if ((rhsResult[1] as String) == GRP && (lhsResult[1] as String) == TYPE) {
				lsuffix = "__" + GRP + "_" + (rhsResult[2] as String);
			} else if ((lhsResult[1] as String) == TYPE && (rhsResult[1] as String) == TYPE) {
				//trace("WARNING! Constraint found between two types (no var): " + JSON.stringify(_constraintJson));
			}
			
			var lhs:ConstraintVar = parseConstraintSide(lhsResult[1] as String, lhsResult[2] as String, lsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
			var rhs:ConstraintVar = parseConstraintSide(rhsResult[1] as String, rhsResult[2] as String, rsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
			
			var newConstraint:Constraint;
			switch (type) {
				case Constraint.SUBTYPE:
					newConstraint = new SubtypeConstraint(lhs, rhs, _defaultScoring.clone());
					break;
				case Constraint.EQUALITY:
					newConstraint = new EqualityConstraint(lhs, rhs, _defaultScoring.clone());
					break;
				default:
					throw new Error("Invalid constraint type found ('"+type+"') in parseConstraintJson()");
					break;
			}
			return newConstraint;
		}
		
		private static function parseConstraintSide(_type:String, _type_num:String, _typeSuffix:String, _variableDictionary:Dictionary, _defaultVal:ConstraintValue, _defaultScoring:ConstraintScoringConfig):ConstraintVar
		{
			var constrVar:ConstraintVar;
			var fullId:String = _type + "_" + _type_num + _typeSuffix;
			if (_variableDictionary.hasOwnProperty(fullId)) {
				constrVar = _variableDictionary[fullId] as ConstraintVar;
			} else {
				if (_type == VAR) {
					constrVar = new ConstraintVar(fullId, _defaultVal, _defaultVal, false, _defaultScoring);
				} else if (_type == GRP) {
					constrVar = new ConstraintVar(fullId, _defaultVal, _defaultVal, false, _defaultScoring);
				} else if (_type == TYPE) {
					var constrVal:ConstraintValue = ConstraintValue.fromStr(_type_num);
					constrVar = new ConstraintVar(fullId, constrVal, constrVal, true, NULL_SCORING);
				} else {
					throw new Error("Invalid constraint var/type found: ('" + _type + "'). Expecting 'var' or 'type'");
				}
				_variableDictionary[fullId] = constrVar;
			}
			return constrVar;
		}
		
	}

}