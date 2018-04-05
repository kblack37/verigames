package scenes.game.display
{
	import flash.geom.Rectangle;
	
	import constraints.ConstraintVar;
	import utils.PropDictionary;
	
	public class VariableNode extends Node
	{
		
		public function VariableNode(_id:String, _bb:Rectangle, _graphVar:ConstraintVar)
		{
			super(_id, _bb, _graphVar);
			//this is only intesting for non-clause Nodes
			isNarrow = graphVar.getProps().hasProp(PropDictionary.PROP_NARROW);
		}
		
		public function get graphVar():ConstraintVar { return graphConstraintSide as ConstraintVar; }
		
	}
}