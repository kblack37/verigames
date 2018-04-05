package scenes.game.display
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import constraints.ConstraintGraph;
	import constraints.ConstraintSide;
	import constraints.ConstraintVar;
	
	import starling.events.Event;
	
	import utils.PropDictionary;
	
	public class Node extends GridChild // TODO: implements INodeProps
	{
		public var graphConstraintSide:ConstraintSide;
		public var isClause:Boolean = false;
		public var solved:Boolean = false;
		public var solverSelected:Boolean;
		public var solverSelectedColor:int;
		
		public function Node(_id:String, _bb:Rectangle, _graphConstraintSide:ConstraintSide)
		{
			super(_id, _bb);
			graphConstraintSide = _graphConstraintSide;
		}
		
		public override function createSkin():void
		{
			if (skin == null) skin = NodeSkin.getNextSkin();
			if (skin == null) return;
			setupSkin();
			skin.draw();
			skin.x = centerPoint.x;
			skin.y = centerPoint.y;
		}
		
		public override function setupSkin():void
		{
			if (skin != null) skin.setNodeProps(false, isNarrow, isSelected, solved, false, false);
		}
		
		public override function removeSkin():void
		{
			super.removeSkin();
			if (skin) (skin as NodeSkin).disableSkin();
			for each(var gameEdgeID:String in connectedEdgeIds)
			{
				var edgeObj:Object = World.m_world.active_level.edgeLayoutObjs[gameEdgeID];
				if (edgeObj) edgeObj.isDirty = true;
			}
		}
		
		public override function skinIsDirty():Boolean
		{
			if (skin == null) return false;
			if (skin.isDirty) return true;
			if (skin.isNarrow() != isNarrow) return true;
			if (skin.isSelected() != isSelected) return true;
			if (skin.isSolved() != solved) return true;
			return false;
		}
		
		public override function draw():void
		{
			if (animating) return;
			if (backgroundIsDirty())
			{
				if (backgroundSkin == null) createSkin();
				if (backgroundSkin != null)
				{
					setupBackgroundSkin();
					backgroundSkin.draw();
				}
			}
			if (skinIsDirty())
			{
				if (skin == null) createSkin();
				if (skin != null)
				{
					setupSkin();
					skin.draw();
				}
			}
		}
		
		// TODO: move to VariableNode
		public override function updateSelectionAssignment(_isWide:Boolean, levelGraph:ConstraintGraph):void
		{
			super.updateSelectionAssignment(_isWide, levelGraph);
			var constraintVar:ConstraintVar = levelGraph.variableDict[id];
			if (constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW) == _isWide) constraintVar.setProp(PropDictionary.PROP_NARROW, !_isWide);
		}
	}
}