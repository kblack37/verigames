package constraints;

import flash.utils.Dictionary;

class ConstraintScoringConfig
{
    public static inline var CONSTRAINT_VALUE_KEY : String = "constraints";
    public static inline var TYPE_0_VALUE_KEY : String = "type:0";
    public static inline var TYPE_1_VALUE_KEY : String = "type:1";
    
    public var scoringDict : Dictionary = new Dictionary();
    
    public function new()
    {
    }
    
    public function updateScoringValue(key : String, val : Float) : Void
    {
        Reflect.setField(scoringDict, key, val);
    }
    
    public function getScoringValue(key : String) : Int
    {
        if (scoringDict.exists(key))
        {
            return as3hx.Compat.parseInt(Reflect.field(scoringDict, key));
        }
        return 0;
    }
    
    public function removeScoringValue(key : String) : Void
    {
        if (scoringDict.exists(key))
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete scoringDict[key];
        }
    }
    
    public static function merge(parentScoringConfig : ConstraintScoringConfig, childScoringConfig : ConstraintScoringConfig) : ConstraintScoringConfig
    {
        var mergedScoring : ConstraintScoringConfig = new ConstraintScoringConfig();
        for (parentKey in Reflect.fields(parentScoringConfig.scoringDict))
        {
            mergedScoring.updateScoringValue(parentKey, parentScoringConfig.getScoringValue(parentKey));
        }
        // Child overrides parent values
        for (childKey in Reflect.fields(childScoringConfig.scoringDict))
        {
            mergedScoring.updateScoringValue(childKey, childScoringConfig.getScoringValue(childKey));
        }
        return mergedScoring;
    }
    
    public function clone() : ConstraintScoringConfig
    {
        var cloneScoring : ConstraintScoringConfig = new ConstraintScoringConfig();
        for (key in Reflect.fields(scoringDict))
        {
            cloneScoring.updateScoringValue(key, getScoringValue(key));
        }
        return cloneScoring;
    }
}

