package State 
{
	import VisualWorld.VerigameSystem;
	
	public class VerigameState extends GenericState 
	{
		
		private var system:VerigameSystem;
		
		public function VerigameState(_system:VerigameSystem) 
		{
			system = _system;
		}
		
		public override function stateLoad():void {
			super.stateLoad();
			addChild(system);
		}
		
		public override function stateUnload():void {
			super.stateUnload();
			system = null;
		}
		
	}

}