package cgs.server.logging;

import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.dependencies.IRequestDependency;

class QuestActionLogContext extends LogData
{
    public var action(get, never) : QuestAction;

    public static inline var MULTIPLAYER_SEQUENCE_ID_KEY : String = "multi_seqid";
    
    //Reference to the action so that properties can be set.
    private var _action : QuestAction;
    
    public function new(action : QuestAction)
    {
        super();
        _action = action;
    }
    
    private function get_action() : QuestAction
    {
        return _action;
    }
    
    override public function setPropertyValue(key : String, value : Dynamic) : Void
    {
        _action.addProperty(key, value);
        
        super.setPropertyValue(key, value);
    }
}
