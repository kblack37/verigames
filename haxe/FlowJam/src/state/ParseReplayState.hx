package state;

import visualWorld.VerigameSystem;

class ParseReplayState extends ParseXMLState
{
    private var m_gameSystem : VerigameSystem;
    public function new(_world_xml : FastXML, gameSystem : VerigameSystem)
    {
        super(_world_xml);
        m_gameSystem = gameSystem;
    }
    
    override public function onTasksComplete() : Void
    {
        m_gameSystem.loadReplay(world_nodes);
        stateUnload();
    }
}
