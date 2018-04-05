package state;

import visualWorld.VerigameSystem;

class VerigameState extends GenericState
{
    
    private var system : VerigameSystem;
    
    public function new(_system : VerigameSystem)
    {
        super();
        system = _system;
    }
    
    override public function stateLoad() : Void
    {
        super.stateLoad();
        addChild(system);
    }
    
    override public function stateUnload() : Void
    {
        super.stateUnload();
        system = null;
    }
}

