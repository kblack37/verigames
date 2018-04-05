package state
{
	import VisualWorld.VerigameSystem;

	public class ParseReplayState extends ParseXMLState
	{
		protected var m_gameSystem:VerigameSystem;
		public function ParseReplayState(_world_xml:XML, gameSystem:VerigameSystem)
		{
			super(_world_xml);
			m_gameSystem = gameSystem;
		}
		
		public override function onTasksComplete():void {
			
			m_gameSystem.loadReplay(world_nodes);
			stateUnload();
		}
	}
}