package constraints;

import flash.errors.Error;
import flash.utils.Dictionary;
import constraints.events.ErrorEvent;
import starling.events.EventDispatcher;
import utils.XString;

class ConstraintGraph extends EventDispatcher
{
    public static var GAME_DEFAULT_VAR_VALUE : ConstraintValue = new ConstraintValue(1);
    
    private static inline var VERSION : String = "version";
    private static inline var DEFAULT_VAR : String = "default";
    private static inline var QID : String = "qid";
    // Sections:
    private static inline var SCORING : String = "scoring";
    private static inline var VARIABLES : String = "variables";
    private static inline var CONSTRAINTS : String = "constraints";
    private static inline var GROUPS : String = "groups";
    // Variable fields:
    private static inline var DEFAULT : String = "default";
    private static inline var SCORE : String = "score";
    public static inline var TYPE_VALUE : String = "type_value";
    // Constraint side types:
    private static inline var VAR : String = "var";
    private static inline var C : String = "c";
    
    private static var NULL_SCORING : ConstraintScoringConfig = new ConstraintScoringConfig();
    
    public var variableDict : Dynamic = {};
    public var nVars : Int = 0;
    public var constraintsDict : Dynamic = {};
    public var nConstraints : Int = 0;
    public var clauseDict : Dynamic = {};
    public var nClauses : Int = 0;
    public var groupsArr : Array<Dynamic> = new Array<Dynamic>();
    public var groupSizes : Array<Int> = new Array<Int>();
    public var unsatisfiedConstraintDict : Dynamic = {};
    public var m_conflictCount : Int;
    public var graphScoringConfig : ConstraintScoringConfig = new ConstraintScoringConfig();
    
    private var m_UnsatisfiedConstraints : Dynamic = {};
    private var m_SatisfiedConstraints : Dynamic = {};
    
    public var startingScore : Float = Math.NaN;
    public var currentScore : Int = 0;
    public var prevScore : Int = 0;
    public var oldScore : Int = 0;
    public var maxPossibleScore : Int = 0;
    public var qid : Int = -1;
    
    private static var updateCount : Int = 0;
    
    public function updateScore(varIdChanged : String = null, propChanged : String = null, newPropValue : Bool = false) : Void
    {
        var clauseID : String;
        var constraint : ConstraintEdge;
        
        oldScore = prevScore;
        prevScore = currentScore;
        //			if(updateCount++ % 200 == 0)
        //				trace("updateScore currentScore ", currentScore, " varIdChanged:",varIdChanged);
        var constraintId : String;
        var lhsConstraint : Constraint;
        var rhsConstraint : Constraint;
        var newUnsatisfiedConstraints : Dynamic = {};
        var currentConstraints : Dynamic = {};
        var newSatisfiedConstraints : Dynamic = {};
        if (varIdChanged != null && propChanged != null)
        {
            var varChanged : ConstraintVar = try cast(Reflect.field(variableDict, varIdChanged), ConstraintVar) catch(e:Dynamic) null;
            
            var prevBonus : Int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
            var prevConstraintPoints : Int = 0;
            // Recalc incoming/outgoing constraints
            var i : Int;
            for (i in 0...varChanged.lhsConstraints.length)
            {
                lhsConstraint = varChanged.lhsConstraints[i];
                if (Std.is(lhsConstraint, ConstraintEdge) && Reflect.field(currentConstraints, lhsConstraint.id) == null)
                {
                    constraint = try cast(lhsConstraint, ConstraintEdge) catch(e:Dynamic) null;
                    Reflect.setField(currentConstraints, constraint.id, lhsConstraint);
                    if (constraint.isClauseSatisfied(varIdChanged, !newPropValue))
                    {
                        prevConstraintPoints += lhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                    }
                }
            }
            for (i in 0...varChanged.rhsConstraints.length)
            {
                rhsConstraint = varChanged.rhsConstraints[i];
                if (Std.is(rhsConstraint, ConstraintEdge) && Reflect.field(currentConstraints, rhsConstraint.id) == null)
                {
                    constraint = try cast(rhsConstraint, ConstraintEdge) catch(e:Dynamic) null;
                    Reflect.setField(currentConstraints, rhsConstraint.id, rhsConstraint);
                    if (constraint.isClauseSatisfied(varIdChanged, !newPropValue))
                    {
                        prevConstraintPoints += rhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                    }
                }
            }
            // Recalc incoming/outgoing constraints
            varChanged.setProp(propChanged, newPropValue);
            var newBonus : Int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
            var newConstraintPoints : Int = 0;
            for (constraintId in Reflect.fields(currentConstraints))
            {
				var constraint : Constraint = try cast (Reflect.field(currentConstraints, constraintId), Constraint) catch (e : Dynamic) null;
                if (constraint.lhs.id.indexOf("c") != -1)
                {
                    clauseID = constraint.lhs.id;
                }
                else
                {
                    clauseID = constraint.rhs.id;
                }
                if (constraint.isClauseSatisfied(varIdChanged, newPropValue))
                {
                    newConstraintPoints += constraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                    Reflect.setField(newSatisfiedConstraints, clauseID, constraint);
                }
                else
                {
                    Reflect.setField(newUnsatisfiedConstraints, clauseID, constraint);
                }
            }
            // Offset score by change in bonus and new constraints satisfied/not
            //				trace("newBonus ", newBonus, " prevBonus ", prevBonus, " newConstraintPoints ", newConstraintPoints, " prevConstraintPoints ", prevConstraintPoints);
            currentScore += newConstraintPoints - prevConstraintPoints;
        }
        else
        {
            currentScore = 0;
            //				for (var varId:String in variableDict) {
            //					var thisVar:ConstraintVar = variableDict[varId] as ConstraintVar;
            //					if (thisVar.getValue() != null && thisVar.scoringConfig != null) {
            //						// If there is a bonus for the current value of thisVar, add to score
            //						currentScore += thisVar.scoringConfig.getScoringValue(thisVar.getValue().verboseStrVal);
            //					}
            //				}
            var scoredConstraints : Dynamic = {};
            for (constraintId in Reflect.fields(constraintsDict))
            {
            // TODO: we are recalculating each clause for every edge, need only traverse clauses once
                
                //old style - scoring per constraint
                //new style - scoring per satisfied clause (might be multiple unsatisfied constraints per clause, but one satisfied one is enough)
                var thisConstr : Constraint = try cast(Reflect.field(constraintsDict, constraintId), Constraint) catch(e:Dynamic) null;
                if (Std.is(thisConstr, ConstraintEdge))
                {
                    constraint = try cast(thisConstr, ConstraintEdge) catch(e:Dynamic) null;
                    if (thisConstr.lhs.id.indexOf("c") != -1)
                    {
                        clauseID = thisConstr.lhs.id;
                    }
                    else
                    {
                        clauseID = thisConstr.rhs.id;
                    }
                    if (constraint.isClauseSatisfied(null, false))
                    {
                    //get clauseID
                        
                        if (Reflect.field(newSatisfiedConstraints, clauseID) == null)
                        {
                            if (Reflect.field(scoredConstraints, clauseID) == null)
                            {
                                currentScore += thisConstr.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                                Reflect.setField(scoredConstraints, clauseID, thisConstr);
                            }
                            if (Reflect.field(m_SatisfiedConstraints, clauseID) == null)
                            {
                                Reflect.setField(newSatisfiedConstraints, clauseID, thisConstr);
                                Reflect.setField(m_SatisfiedConstraints, clauseID, thisConstr);
								Reflect.deleteField(m_UnsatisfiedConstraints, clauseID);
                            }
                        }
                    }
                    else if (Reflect.field(m_UnsatisfiedConstraints, clauseID) == null)
                    {
                        Reflect.setField(newUnsatisfiedConstraints, clauseID, thisConstr);
                        Reflect.setField(m_UnsatisfiedConstraints, clauseID, thisConstr);
						Reflect.deleteField(m_SatisfiedConstraints, clauseID);
                    }
                }
            }
        }
        
        for (clauseID in Reflect.fields(newSatisfiedConstraints))
        {
            if (Reflect.hasField(unsatisfiedConstraintDict, clauseID))
            {
				Reflect.deleteField(unsatisfiedConstraintDict, clauseID);
                m_conflictCount--;
            }
        }
        for (clauseID in Reflect.fields(newUnsatisfiedConstraints))
        {
            if (!Reflect.hasField(unsatisfiedConstraintDict, clauseID))
            {
                Reflect.setField(unsatisfiedConstraintDict, clauseID, Reflect.field(newUnsatisfiedConstraints, clauseID));
                m_conflictCount++;
            }
        }
        
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_REMOVED, newSatisfiedConstraints));
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_ADDED, newUnsatisfiedConstraints));
        if (Math.isNaN(startingScore))
        {
            startingScore = currentScore;
        }
    }
    
    public function resetScoring() : Void
    {
        updateScore();
        oldScore = prevScore = currentScore;
    }
    
    public static function fromString(_json : String) : ConstraintGraph
    {
        var levelObj : Dynamic = haxe.Json.parse(_json);
        return initFromJSON(levelObj);
    }
    
    public function buildVar(varId : String) : Void
    {
        var idParts : Array<Dynamic> = varId.split(":");
        var formattedId : String = idParts[0] + "_" + idParts[1];
        var varParamsObj : Dynamic = Reflect.field(variablesToBuildObj, varId);
        var typeValStr : String = Reflect.field(varParamsObj, TYPE_VALUE);
        var varScoring : ConstraintScoringConfig = new ConstraintScoringConfig();
        var scoreObj : Dynamic = Reflect.field(varParamsObj, SCORE);
        if (scoreObj != null)
        {
            var type0VarScore : Int = Reflect.field(scoreObj, Std.string(ConstraintScoringConfig.TYPE_0_VALUE_KEY));
            var type1VarScore : Int = Reflect.field(scoreObj, Std.string(ConstraintScoringConfig.TYPE_1_VALUE_KEY));
            varScoring.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0VarScore);
            varScoring.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1VarScore);
        }
        var mergedVarScoring : ConstraintScoringConfig = ConstraintScoringConfig.merge(graphScoringConfig, varScoring);
        var defaultValStr : String = Reflect.field(varParamsObj, DEFAULT);
        var defaultVal : ConstraintValue;
        if (defaultValStr != null)
        {
            defaultVal = ConstraintValue.fromVerboseStr(defaultValStr);
        }
        var typeVal : ConstraintValue;
        if (typeValStr != null)
        {
            typeVal = ConstraintValue.fromVerboseStr(typeValStr);
        }
        else if (defaultVal != null)
        {
            typeVal = defaultVal.clone();
        }
        else
        {
            typeVal = graphDefaultVal.clone();
        }
        var newVar : ConstraintVar = new ConstraintVar(formattedId, typeVal, defaultVal, mergedVarScoring);
        Reflect.setField(variableDict, formattedId, newVar);
    }
    
    public function buildNextCompleteGroup() : Void
    {
        if (nextGroupToBuild < 0 || nextGroupToBuild >= groupsArr.length)
        {
            return;
        }
        currentGroupDict = {};
        var groupSize : Int = 0;
        for (groupId in Reflect.fields(groupsArr[nextGroupToBuild]))
        {
            var groupIdParts : Array<Dynamic> = groupId.split(":");
            if (groupIdParts[0] == "clause")
            {
                groupIdParts[0] = "c";
            }
            var formattedGroupId : String = groupIdParts[0] + "_" + groupIdParts[1];
            var groupedIds : Array<Dynamic> = try cast(Reflect.field(groupsArr[nextGroupToBuild], groupId), Array<Dynamic>) catch(e:Dynamic) null;
            for (groupedId in groupedIds)
            {
                var groupedIdParts : Array<Dynamic> = groupedId.split(":");
                if (groupedIdParts[0] == "clause")
                {
                    groupedIdParts[0] = "c";
                }
                var formattedGroupedId : String = groupedIdParts[0] + "_" + groupedIdParts[1];
                Reflect.setField(currentGroupDict, formattedGroupedId, formattedGroupId);
            }
            groupSize++;
        }
        groupSizes.push(groupSize);
        groupsArrComplete.push(currentGroupDict);
        nextGroupToBuild++;
    }
    
    public function buildNextConstraint() : Void
    {
        if (constraintsToBuildArr.length == 0)
        {
            return;
        }
        var newConstraint : Constraint;
        
        if (Type.getClassName(constraintsToBuildArr[0]) == "String")
        {
        // process as String, i.e. "var:1 <= c:2"
            
            var constrString : String = Std.string(constraintsToBuildArr.shift());
            newConstraint = parseConstraintString(constrString, this, graphDefaultVal, graphScoringConfig);
        }
        else
        {
            throw new Error("Unknown constraint format: " + constraintsToBuildArr[0]);
        }
        if (Std.is(newConstraint, ConstraintEdge))
        {
            nConstraints++;
            Reflect.setField(constraintsDict, newConstraint.id, newConstraint);
            maxPossibleScore++;
            // Attach any groups
            if (groupsArr != null && totalGroups > 0)
            {
                var fillLeft : Bool = (newConstraint.lhs.groups == null);
                var fillRight : Bool = (newConstraint.rhs.groups == null);
                if (fillLeft)
                {
                    newConstraint.lhs.groups = new Array<String>();
                }
                if (fillRight)
                {
                    newConstraint.rhs.groups = new Array<String>();
                }
                if (fillLeft || fillRight)
                {
                    for (g1 in 0...totalGroups)
                    {
                        if (fillLeft)
                        {
                            var leftGroupId : String = Reflect.hasField(groupsArrComplete[g1], newConstraint.lhs.id) ?
								Reflect.field(groupsArrComplete[g1], newConstraint.lhs.id) : "";
                            newConstraint.lhs.groups.push(leftGroupId);
                            if (newConstraint.lhs.id != "" &&
                                newConstraint.lhs.id != leftGroupId &&
                                newConstraint.lhs.rank == 0)
                            {
                            // If grouped for the first time this round, rank = group depth
                                
                                newConstraint.lhs.rank = newConstraint.lhs.groups.length;
                            }
                        }
                        if (fillRight)
                        {
                            var rightGroupId : String = Reflect.hasField(groupsArrComplete[g1], newConstraint.rhs.id) ?
								Reflect.field(groupsArrComplete[g1], newConstraint.rhs.id) : "";
                            newConstraint.rhs.groups.push(rightGroupId);
                            if (newConstraint.rhs.id != "" &&
                                newConstraint.rhs.id != rightGroupId &&
                                newConstraint.rhs.rank == 0)
                            {
                            // If grouped for the first time this round, rank = group depth
                                
                                newConstraint.rhs.rank = newConstraint.rhs.groups.length;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            throw new Error("Unknown constraint type:" + newConstraint);
        }
    }
    
    public var version : String;
    public var variablesToBuildObj : Dynamic;
    public var constraintsToBuildArr : Array<Dynamic>;
    public var nextGroupToBuild : Int = -1;
    public var totalGroups : Int;
    public var groupsArrComplete : Array<Dynamic>;
    public var currentGroupDict : Dynamic;
    public var graphDefaultVal : ConstraintValue = GAME_DEFAULT_VAR_VALUE;
    
    public static function initFromJSON(levelObj : Dynamic) : ConstraintGraph
    //with the inclusion of the import graph.PropDictionary, FlashBuilder confuses the graph package with this var when
    {
        
        //just named 'graph'. Add the one so things compile.
        var graph1 : ConstraintGraph = new ConstraintGraph();
        var ver : String = Reflect.field(levelObj, VERSION);
        graph1.version = Reflect.field(levelObj, VERSION);
        var defaultValue : String = Reflect.field(levelObj, DEFAULT_VAR);
        graph1.maxPossibleScore = 0;
        graph1.qid = Std.parseInt(Reflect.field(levelObj, QID));
        var _sw0_ = (graph1.version);        

        switch (_sw0_)
        {  // Version 1  
            case "1", "2":  // Version 2  
                // No "default" specified in json, use game default
                if (defaultValue == ConstraintScoringConfig.TYPE_0_VALUE_KEY)
                {
                    graph1.graphDefaultVal = new ConstraintValue(0);
                }
                else if (defaultValue == ConstraintScoringConfig.TYPE_1_VALUE_KEY)
                {
                    graph1.graphDefaultVal = new ConstraintValue(1);
                }
                else
                {
                    graph1.graphDefaultVal = GAME_DEFAULT_VAR_VALUE;
                }
                
                // Build Scoring
                var scoringObj : Dynamic = Reflect.field(levelObj, SCORING);
                var constraintScore : Int = (scoringObj != null) ? Reflect.field(scoringObj, Std.string(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY)) : 100;
                var variableScoreObj : Dynamic = (scoringObj != null) ? Reflect.field(scoringObj, VARIABLES) : {
                    type0 : 0,
                    type1 : 1
                };
                var type0Score : Int = Reflect.field(variableScoreObj, Std.string(ConstraintScoringConfig.TYPE_0_VALUE_KEY));
                var type1Score : Int = Reflect.field(variableScoreObj, Std.string(ConstraintScoringConfig.TYPE_1_VALUE_KEY));
                graph1.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY, constraintScore);
                graph1.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0Score);
                graph1.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1Score);
                
                // Build variables (if any specified, this section is optional)
                graph1.variablesToBuildObj = Reflect.field(levelObj, VARIABLES);
                
                // Build constraints, add any uninitialized variables to graph.variableDict, and process groups
                //the process eats the array, so create a copy
                graph1.constraintsToBuildArr = new Array<Dynamic>();
				var levelConstraints : Array<Dynamic> = Reflect.field(levelObj, CONSTRAINTS);
                for (constraintStr in levelConstraints)
                {
                    graph1.constraintsToBuildArr.push(constraintStr);
                }
                graph1.groupsArr = (levelObj.exists(GROUPS)) ? Reflect.field(levelObj, GROUPS) : new Array<Dynamic>();
                graph1.totalGroups = graph1.groupsArr != null ? graph1.groupsArr.length : 0;
                /**
					 * "groups": [
					 * 			{"var:1":["var:2"], "var:5":["var:7"],...},    <-- stage 1 of grouping
					 * 			{"var:1":["var:2","var:8"], "var:5":["var:7","var:9"],...}, <-- stage 2 of grouping
					 * 			{"var:1":["var:2","var:5","var:7","var:9"],...}, <-- stage 3 of grouping
					 * 		... ]
					 */
                
                graph1.groupSizes = new Array<Int>();
                graph1.nextGroupToBuild = -1;
                if (graph1.groupsArr != null)
                {
                    graph1.groupsArrComplete = new Array<Dynamic>();
                    graph1.nextGroupToBuild = 0;
                }
                
                graph1.nVars = graph1.nClauses = graph1.nConstraints = 0;
            default:
                throw new Error("ConstraintGraph.initFromJSON:: Unknown version encountered: " + graph1.version);
        }
        
        return graph1;
    }
    
    /**
		 * Incrementally continues to build graph to avoid freezing the game
		 * @return complete: True if graph is completely constructed
		 */
    public function buildNextPartOfGraph() : Bool
    {
        switch (version)
        {  // Version 1  
            case "1", "2":  // Version 2  
            // A. Build any variables left to build
            if (variablesToBuildObj != null)
            {
                for (varId in Reflect.fields(variablesToBuildObj))
                {
                    buildVar(varId);
                    return false;
                }
            }
            
            // B. Build any groups left to build
            if (groupsArr != null)
            {
                while (nextGroupToBuild < groupsArr.length)
                {
                    buildNextCompleteGroup();
                    return false;
                }
            }
            
            // C. Build any remaining constraints
            while (constraintsToBuildArr.length > 0)
            {
                buildNextConstraint();
                return false;
            }
            default:
                throw new Error("ConstraintGraph.buildNextPartOfGraph: Unknown version encountered: " + version);
        }
        return true;
    }
    
    private static function parseConstraintString(_str : String, _graph : ConstraintGraph, _defaultVal : ConstraintValue, _defaultScoring : ConstraintScoringConfig) : Constraint
    {
        var pattern : EReg = new EReg('(var|c):(.*) (<|=)= (var|c):(.*)', "ig");
        var result : Array<String> = pattern.split(_str);
        if (result == null)
        {
            throw new Error("Invalid constraint string found: " + _str);
        }
        if (result.length != 6)
        {
            throw new Error("Invalid constraint string found: " + _str);
        }
        var lhsType : String = Reflect.field(result, Std.string(1));
        var lhsId : String = Reflect.field(result, Std.string(2));
        var constType : String = Reflect.field(result, Std.string(3));
        var rhsType : String = Reflect.field(result, Std.string(4));
        var rhsId : String = Reflect.field(result, Std.string(5));
        var typeNumArray : Array<Dynamic>;
        
        var lsuffix : String = "";
        var rsuffix : String = "";
        if (rhsType == VAR && lhsType == C)
        {
            typeNumArray = lhsId.split("_");
        }
        else if (rhsType == C && lhsType == VAR)
        {
            typeNumArray = rhsId.split("_");
        }
        else
        {
            trace("WARNING! Constraint found between two types (no var): " + haxe.Json.stringify(_str));
        }
        
        var lhs : ConstraintSide = parseConstraintSide(lhsType, lhsId, lsuffix, _graph, _defaultVal, _defaultScoring.clone());
        var rhs : ConstraintSide = parseConstraintSide(rhsType, rhsId, rsuffix, _graph, _defaultVal, _defaultScoring.clone());
        
        var newConstraint : Constraint;
        if (rhsType == "c" || lhsType == "c")
        {
            newConstraint = new ConstraintEdge(lhs, rhs, _defaultScoring);
        }
        else
        {
            throw new Error("Invalid constraint type found ('" + constType + "') in string: " + _str);
        }
        return newConstraint;
    }
    
    private static function parseConstraintSide(_type : String, _type_num : String, _typeSuffix : String, _graph : ConstraintGraph, _defaultVal : ConstraintValue, _defaultScoring : ConstraintScoringConfig) : ConstraintSide
    {
        var fullId : String = _type + "_" + _type_num + _typeSuffix;
        var constrSide : ConstraintSide;
        if (_type == VAR)
        {
            if (_graph.variableDict.exists(fullId))
            {
                constrSide = try cast(Reflect.field(_graph.variableDict, fullId), ConstraintVar) catch(e:Dynamic) null;
            }
            else
            {
                constrSide = new ConstraintVar(fullId, _defaultVal, _defaultVal, _defaultScoring);
                Reflect.setField(_graph.variableDict, fullId, constrSide);
                _graph.nVars++;
            }
        }
        else if (_type == C)
        {
            fullId = _type + "_" + _type_num;
            if (Reflect.hasField(_graph.clauseDict, fullId))
            {
                constrSide = try cast(Reflect.field(_graph.clauseDict, fullId), ConstraintClause) catch(e:Dynamic) null;
            }
            else
            {
                constrSide = new ConstraintClause(fullId, _defaultScoring);
                Reflect.setField(_graph.clauseDict, fullId, constrSide);
                _graph.nClauses++;
            }
        }
        else
        {
            throw new Error("Invalid constraint element found: ('" + _type + "'). Expecting 'var' or 'c'");
        }
        return constrSide;
    }
    
    public function dispatchUpdateEvents() : Void
    {
        updateScore();
    }

    public function new()
    {
        super();
    }
}
