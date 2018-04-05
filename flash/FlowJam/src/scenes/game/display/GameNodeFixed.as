package scenes.game.display 
{
	import constraints.ConstraintVar;
	import graph.PropDictionary;
	
	public class GameNodeFixed extends GameNode 
	{
		public function GameNodeFixed(_layoutObj:Object, _constraintVar:ConstraintVar, _draggable:Boolean = true) 
		{
			super(_layoutObj, _constraintVar, _draggable);
			m_isEditable = false;
			m_isWide = !constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW);
		}
		
		override public function isWide():Boolean
		{
			return m_isWide;
		}
	}

}