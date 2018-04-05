package constraints;

import flash.errors.Error;
import constraints.events.ErrorEvent;
import flash.utils.Dictionary;
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
    private static inline var GROUPS : String = "groups";
    private static inline var VARIABLES : String = "variables";
    private static inline var CONSTRAINTS : String = "constraints";
    // Constraint fields:
    private static inline var CONSTRAINT : String = "constraint";
    private static inline var LHS : String = "lhs";
    private static inline var RHS : String = "rhs";
    // Variable fields:
    private static inline var DEFAULT : String = "default";
    private static inline var SCORE : String = "score";
    private static inline var POSSIBLE_KEYFORS : String = "possible_keyfor";
    public static inline var TYPE_VALUE : String = "type_value";
    public static inline var KEYFOR_VALUES : String = "keyfor_value";
    private static inline var CONSTANT : String = "constant";
    // Constraint side types:
    private static inline var VAR : String = "var";
    private static inline var TYPE : String = "type";
    private static inline var GRP : String = "grp";
    
    private static var NULL_SCORING : ConstraintScoringConfig = new ConstraintScoringConfig();
    
    public var variableDict : Dictionary = new Dictionary();
    public var constraintsDict : Dictionary = new Dictionary();
    public var unsatisfiedConstraintDict : Dictionary = new Dictionary();
    public var graphScoringConfig : ConstraintScoringConfig = new ConstraintScoringConfig();
    
    public var startingScore : Int = Math.NaN;
    public var currentScore : Int = 0;
    public var prevScore : Int = 0;
    public var oldScore : Int = 0;
    
    public var qid : Int = -1;
    
    public function updateScore(varIdChanged : String = null, propChanged : String = null, newPropValue : Bool = false) : Void
    {
        oldScore = prevScore;
        prevScore = currentScore;
        trace("updateScore currentScore ", currentScore, " varIdChanged:", varIdChanged);
        var constraintId : String;
        var lhsConstraint : Constraint;
        var rhsConstraint : Constraint;
        var newUnsatisfiedConstraints : Dictionary = new Dictionary();
        var newSatisfiedConstraints : Dictionary = new Dictionary();
        if (varIdChanged != null && propChanged != null)
        {
            var varChanged : ConstraintVar = try cast(Reflect.field(variableDict, varIdChanged), ConstraintVar) catch(e:Dynamic) null;
            if (varChanged.getValue() != null && varChanged.scoringConfig != null)
            {
                var prevBonus : Int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
                var prevConstraintPoints : Int = 0;
                // Recalc incoming/outgoing constraints
                var i : Int;
                for (i in 0...varChanged.lhsConstraints.length)
                {
                    lhsConstraint = varChanged.lhsConstraints[i];
                    if (lhsConstraint.isSatisfied())
                    {
                        prevConstraintPoints += lhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                    }
                }
                for (i in 0...varChanged.rhsConstraints.length)
                {
                    rhsConstraint = varChanged.rhsConstraints[i];
                    if (rhsConstraint.isSatisfied())
                    {
                        prevConstraintPoints += rhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                    }
                }
                // Recalc incoming/outgoing constraints
                varChanged.setProp(propChanged, newPropValue);
                var newBonus : Int = varChanged.scoringConfig.getScoringValue(varChanged.getValue().verboseStrVal);
                var newConstraintPoints : Int = 0;
                for (i in 0...varChanged.lhsConstraints.length)
                {
                    lhsConstraint = varChanged.lhsConstraints[i];
                    if (lhsConstraint.isSatisfied())
                    {
                        newConstraintPoints += lhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                        newSatisfiedConstraints[lhsConstraint.id] = lhsConstraint;
                    }
                    else
                    {
                        newUnsatisfiedConstraints[lhsConstraint.id] = lhsConstraint;
                    }
                }
                for (i in 0...varChanged.rhsConstraints.length)
                {
                    rhsConstraint = varChanged.rhsConstraints[i];
                    if (rhsConstraint.isSatisfied())
                    {
                        newConstraintPoints += rhsConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                        newSatisfiedConstraints[rhsConstraint.id] = rhsConstraint;
                    }
                    else
                    {
                        newUnsatisfiedConstraints[rhsConstraint.id] = rhsConstraint;
                    }
                }
                // Offset score by change in bonus and new constraints satisfied/not
                trace("newBonus ", newBonus, " prevBonus ", prevBonus, " newConstraintPoints ", newConstraintPoints, " prevConstraintPoints ", prevConstraintPoints);
                currentScore += as3hx.Compat.parseInt((newBonus - prevBonus) + (newConstraintPoints - prevConstraintPoints));
                trace("new currentScore ", currentScore);
            }
        }
        else
        {
            currentScore = 0;
            for (varId in Reflect.fields(variableDict))
            {
                var thisVar : ConstraintVar = try cast(Reflect.field(variableDict, varId), ConstraintVar) catch(e:Dynamic) null;
                if (thisVar.getValue() != null && thisVar.scoringConfig != null)
                
                // If there is a bonus for the current value of thisVar, add to score{
                    
                    currentScore += thisVar.scoringConfig.getScoringValue(thisVar.getValue().verboseStrVal);
                }
            }
            for (constraintId in Reflect.fields(constraintsDict))
            {
                var thisConstr : Constraint = try cast(Reflect.field(constraintsDict, constraintId), Constraint) catch(e:Dynamic) null;
                if (thisConstr.isSatisfied())
                {
                    currentScore += thisConstr.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
                    Reflect.setField(newSatisfiedConstraints, constraintId, thisConstr);
                }
                else
                {
                    Reflect.setField(newUnsatisfiedConstraints, constraintId, thisConstr);
                }
            }
        }
        for (constraintId in Reflect.fields(newSatisfiedConstraints))
        {
            if (unsatisfiedConstraintDict.exists(constraintId))
            {
                This is an intentional compilation error. See the README for handling the delete keyword
                delete unsatisfiedConstraintDict[constraintId];
                dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_REMOVED, Reflect.field(newSatisfiedConstraints, constraintId)));
            }
        }
        for (constraintId in Reflect.fields(newUnsatisfiedConstraints))
        {
            if (!unsatisfiedConstraintDict.exists(constraintId))
            {
                Reflect.setField(unsatisfiedConstraintDict, constraintId, Reflect.field(newUnsatisfiedConstraints, constraintId));
                dispatchEvent(new ErrorEvent(ErrorEvent.ERROR_ADDED, Reflect.field(newUnsatisfiedConstraints, constraintId)));
            }
        }
        if (Math.isNaN(startingScore))
        {
            startingScore = currentScore;
        }
        trace("Score: " + currentScore);
    }
    
    public function resetScoring() : Void
    {
        updateScore();
        oldScore = prevScore = currentScore;
    }
    
    public static function fromString(_json : String) : ConstraintGraph
    {
        var levelObj : Dynamic = haxe.Json.parse(_json);
        return fromJSON(levelObj);
    }
    
    public static function fromJSON(levelObj : Dynamic) : ConstraintGraph
    {
        var graph : ConstraintGraph = new ConstraintGraph();
        var ver : String = Reflect.field(levelObj, VERSION);
        var defaultValue : String = Reflect.field(levelObj, DEFAULT_VAR);
        graph.qid = as3hx.Compat.parseInt(Reflect.field(levelObj, QID));
        switch (ver)
        {
            case "1":  // Version 1  
                // No "default" specified in json, use game default
                var graphDefaultVal : ConstraintValue;
                if (defaultValue == ConstraintScoringConfig.TYPE_0_VALUE_KEY)
                {
                    graphDefaultVal = new ConstraintValue(0);
                }
                else if (defaultValue == ConstraintScoringConfig.TYPE_1_VALUE_KEY)
                {
                    graphDefaultVal = new ConstraintValue(1);
                }
                else
                {
                    graphDefaultVal = GAME_DEFAULT_VAR_VALUE;
                }
                // Build Scoring
                var scoringObj : Dynamic = Reflect.field(levelObj, SCORING);
                var groupsObj : Dynamic = Reflect.field(levelObj, GROUPS);
                var constraintScore : Int = Reflect.field(scoringObj, Std.string(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY));
                var variableScoreObj : Dynamic = Reflect.field(scoringObj, VARIABLES);
                var type0Score : Int = Reflect.field(variableScoreObj, Std.string(ConstraintScoringConfig.TYPE_0_VALUE_KEY));
                var type1Score : Int = Reflect.field(variableScoreObj, Std.string(ConstraintScoringConfig.TYPE_1_VALUE_KEY));
                graph.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY, constraintScore);
                graph.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY, type0Score);
                graph.graphScoringConfig.updateScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY, type1Score);
                
                // Build variables (if any specified, this section is optional)
                var variablesObj : Dynamic = Reflect.field(levelObj, VARIABLES);
                if (variablesObj != null)
                {
                    for (varId in Reflect.fields(variablesObj))
                    {
                        var idParts : Array<Dynamic> = varId.split(":");
                        var formattedId : String = idParts[0] + "_" + idParts[1];
                        var varParamsObj : Dynamic = Reflect.field(variablesObj, varId);
                        var isConstant : Bool = false;
                        if (varParamsObj.exists(CONSTANT))
                        {
                            isConstant = XString.stringToBool(Std.string(Reflect.field(varParamsObj, CONSTANT)));
                        }
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
                        var mergedVarScoring : ConstraintScoringConfig = ConstraintScoringConfig.merge(graph.graphScoringConfig, varScoring);
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
                        var possibleKeyfors : Array<String> = new Array<String>();
                        var possibleKeyforsArr : Array<Dynamic> = Reflect.field(varParamsObj, POSSIBLE_KEYFORS);
                        if (possibleKeyforsArr != null)
                        {
                            for (i in 0...possibleKeyforsArr.length)
                            {
                                possibleKeyfors.push(possibleKeyforsArr[i]);
                            }
                        }
                        var keyforVals : Array<String> = new Array<String>();
                        var keyforValsArr : Array<Dynamic> = Reflect.field(varParamsObj, KEYFOR_VALUES);
                        if (keyforValsArr != null)
                        {
                            for (j in 0...keyforValsArr.length)
                            {
                                keyforVals.push(keyforValsArr[j]);
                            }
                        }
                        var newVar : ConstraintVar = new ConstraintVar(formattedId, typeVal, defaultVal, isConstant, (isConstant) ? NULL_SCORING : mergedVarScoring, possibleKeyfors, keyforVals);
                        graph.variableDict[formattedId] = newVar;
                    }
                }
                
                // Build constraints (and add any uninitialized variables to graph.variableDict)
                var constraintsArr : Array<Dynamic> = Reflect.field(levelObj, CONSTRAINTS);
                for (c in 0...constraintsArr.length)
                {
                    var newConstraint : Constraint;
                    if (Type.getClassName(constraintsArr[c]) == "String")
                    
                    // process as String, i.e. "var:1 <= var:2"{
                        
                        newConstraint = parseConstraintString(Std.string(constraintsArr[c]), graph.variableDict, graphDefaultVal, graph.graphScoringConfig.clone());
                    }
                    // process as json object i.e. {"rhs": "type:1", "constraint": "subtype", "lhs": "var:9"}
                    else
                    {
                        
                        newConstraint = parseConstraintJson(try cast(constraintsArr[c], Dynamic) catch(e:Dynamic) null, graph.variableDict, graphDefaultVal, graph.graphScoringConfig.clone());
                    }
                    if (Std.is(newConstraint, EqualityConstraint))
                    
                    // For equality, convert to two separate equality constaints (one for each edge) and put in constraintsDict{
                        
                        // Scoring: take same scoring for now, any conflict on EITHER subtype constraint will cause -100 (or whatever conflict penalty is for the equality constrtaint)
                        var constr1 : SubtypeConstraint = new SubtypeConstraint(newConstraint.lhs, newConstraint.rhs, newConstraint.scoring);
                        var constr2 : SubtypeConstraint = new SubtypeConstraint(newConstraint.rhs, newConstraint.lhs, newConstraint.scoring);
                        graph.constraintsDict[constr1.id] = constr1;
                        graph.constraintsDict[constr2.id] = constr2;
                    }
                    else if (Std.is(newConstraint, SubtypeConstraint))
                    {
                        graph.constraintsDict[newConstraint.id] = newConstraint;
                    }
                }
            default:
                throw new Error("ConstraintGraph.fromJSON:: Unknown version encountered: " + ver);
        }
        graph.updateScore();
        return graph;
    }
    
    private static function parseConstraintString(_str : String, _variableDictionary : Dictionary, _defaultVal : ConstraintValue, _defaultScoring : ConstraintScoringConfig) : Constraint
    {
        var pattern : as3hx.Compat.Regex = new as3hx.Compat.Regex('(var|type|grp):(.*) (<|=)= (var|type|grp):(.*)', "i");
        var result : Dynamic = pattern.exec(_str);
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
        
        var lsuffix : String = "";
        var rsuffix : String = "";
        if (lhsType == VAR && rhsType == TYPE)
        {
            rsuffix = "__" + VAR + "_" + lhsId;
        }
        else if (lhsType == GRP && rhsType == TYPE)
        {
            rsuffix = "__" + GRP + "_" + lhsId;
        }
        else if (rhsType == VAR && lhsType == TYPE)
        {
            lsuffix = "__" + VAR + "_" + rhsId;
        }
        else if (rhsType == GRP && lhsType == TYPE)
        {
            lsuffix = "__" + GRP + "_" + rhsId;
        }
        else if (rhsType == TYPE && lhsType == TYPE)
        {
            trace("WARNING! Constraint found between two types (no var): " + haxe.Json.stringify(_str));
        }
        
        var lhs : ConstraintVar = parseConstraintSide(lhsType, lhsId, lsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
        var rhs : ConstraintVar = parseConstraintSide(rhsType, rhsId, rsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
        
        var newConstraint : Constraint;
        switch (constType)
        {
            case "<":
                newConstraint = new SubtypeConstraint(lhs, rhs, _defaultScoring.clone());
            case "=":
                newConstraint = new EqualityConstraint(lhs, rhs, _defaultScoring.clone());
            default:
                throw new Error("Invalid constraint type found ('" + constType + "') in string: " + _str);
        }
        return newConstraint;
    }
    
    private static function parseConstraintJson(_constraintJson : Dynamic, _variableDictionary : Dictionary, _defaultVal : ConstraintValue, _defaultScoring : ConstraintScoringConfig) : Constraint
    {
        var type : String = Reflect.field(_constraintJson, CONSTRAINT);
        var lhsStr : String = Reflect.field(_constraintJson, LHS);
        var rhsStr : String = Reflect.field(_constraintJson, RHS);
        var pattern : as3hx.Compat.Regex = new as3hx.Compat.Regex('(var|type|grp):(.*)', "i");
        var lhsResult : Dynamic = pattern.exec(lhsStr);
        var rhsResult : Dynamic = pattern.exec(rhsStr);
        if (lhsResult == null || rhsResult == null)
        {
            throw new Error("Error parsing constraint json for lhs:'" + lhsStr + "' rhs:'" + rhsStr + "'");
        }
        if (lhsResult.length != 3 || rhsResult.length != 3)
        {
            throw new Error("Error parsing constraint json for lhs:'" + lhsStr + "' rhs:'" + rhsStr + "'");
        }
        
        var lsuffix : String = "";
        var rsuffix : String = "";
        if ((Std.string(Reflect.field(lhsResult, Std.string(1)))) == VAR && (Std.string(Reflect.field(rhsResult, Std.string(1)))) == TYPE)
        {
            rsuffix = "__" + VAR + "_" + (Std.string(Reflect.field(lhsResult, Std.string(2))));
        }
        else if ((Std.string(Reflect.field(lhsResult, Std.string(1)))) == GRP && (Std.string(Reflect.field(rhsResult, Std.string(1)))) == TYPE)
        {
            rsuffix = "__" + GRP + "_" + (Std.string(Reflect.field(lhsResult, Std.string(2))));
        }
        else if ((Std.string(Reflect.field(rhsResult, Std.string(1)))) == VAR && (Std.string(Reflect.field(lhsResult, Std.string(1)))) == TYPE)
        {
            lsuffix = "__" + VAR + "_" + (Std.string(Reflect.field(rhsResult, Std.string(2))));
        }
        else if ((Std.string(Reflect.field(rhsResult, Std.string(1)))) == GRP && (Std.string(Reflect.field(lhsResult, Std.string(1)))) == TYPE)
        {
            lsuffix = "__" + GRP + "_" + (Std.string(Reflect.field(rhsResult, Std.string(2))));
        }
        else if ((Std.string(Reflect.field(lhsResult, Std.string(1)))) == TYPE && (Std.string(Reflect.field(rhsResult, Std.string(1)))) == TYPE)
        {  //trace("WARNING! Constraint found between two types (no var): " + JSON.stringify(_constraintJson));  
            
        }
        
        var lhs : ConstraintVar = parseConstraintSide(Std.string(Reflect.field(lhsResult, Std.string(1))), Std.string(Reflect.field(lhsResult, Std.string(2))), lsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
        var rhs : ConstraintVar = parseConstraintSide(Std.string(Reflect.field(rhsResult, Std.string(1))), Std.string(Reflect.field(rhsResult, Std.string(2))), rsuffix, _variableDictionary, _defaultVal, _defaultScoring.clone());
        
        var newConstraint : Constraint;
        switch (type)
        {
            case Constraint.SUBTYPE:
                newConstraint = new SubtypeConstraint(lhs, rhs, _defaultScoring.clone());
            case Constraint.EQUALITY:
                newConstraint = new EqualityConstraint(lhs, rhs, _defaultScoring.clone());
            default:
                throw new Error("Invalid constraint type found ('" + type + "') in parseConstraintJson()");
        }
        return newConstraint;
    }
    
    private static function parseConstraintSide(_type : String, _type_num : String, _typeSuffix : String, _variableDictionary : Dictionary, _defaultVal : ConstraintValue, _defaultScoring : ConstraintScoringConfig) : ConstraintVar
    {
        var constrVar : ConstraintVar;
        var fullId : String = _type + "_" + _type_num + _typeSuffix;
        if (_variableDictionary.exists(fullId))
        {
            constrVar = try cast(Reflect.field(_variableDictionary, fullId), ConstraintVar) catch(e:Dynamic) null;
        }
        else
        {
            if (_type == VAR)
            {
                constrVar = new ConstraintVar(fullId, _defaultVal, _defaultVal, false, _defaultScoring);
            }
            else if (_type == GRP)
            {
                constrVar = new ConstraintVar(fullId, _defaultVal, _defaultVal, false, _defaultScoring);
            }
            else if (_type == TYPE)
            {
                var constrVal : ConstraintValue = ConstraintValue.fromStr(_type_num);
                constrVar = new ConstraintVar(fullId, constrVal, constrVal, true, NULL_SCORING);
            }
            else
            {
                throw new Error("Invalid constraint var/type found: ('" + _type + "'). Expecting 'var' or 'type'");
            }
            Reflect.setField(_variableDictionary, fullId, constrVar);
        }
        return constrVar;
    }

    public function new()
    {
        super();
    }
}

