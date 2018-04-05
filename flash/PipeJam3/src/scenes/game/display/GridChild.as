package scenes.game.display 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import constraints.ConstraintGraph;

	
	public class GridChild 
	{
		public var id:String;
		
		public var layoutObject:Object;
		
		public var bb:Rectangle;
		public var centerPoint:Point;
		
		public var isSelected:Boolean = false;
		public var isNarrow:Boolean;
		
		public var startingSelectionState:Boolean = false;
		
		public var connectedEdgeIds:Vector.<String> = new Vector.<String>();
		public var outgoingEdgeIds:Vector.<String> = new Vector.<String>();
		public var unused:Boolean = true;
		
		public var skin:NodeSkin;
		public var backgroundSkin:NodeSkin;
		public var currentGroupDepth:uint = 0;
		public var animating:Boolean = false;
		
		public function GridChild(_id:String, _bb:Rectangle) 
		{
			id = _id;
			bb = _bb;
			
			//calculate center point
			var xCenter:Number = bb.x + bb.width * .5;
			var yCenter:Number = bb.y + bb.height * .5;
			centerPoint = new Point(xCenter, yCenter);
			isNarrow = false;
		}
		
		public function createSkin():void
		{
			// implemented by children
		}
		
		public function removeSkin():void
		{
			if (skin) skin.removeFromParent();
			if (backgroundSkin) backgroundSkin.removeFromParent();
			skin = null;
			backgroundSkin = null;
		}
		
		public function setupSkin():void
		{
			// implemented by children
		}
		
		public function setupBackgroundSkin():void
		{
			// implemented by children
		}
		
		public function select():void
		{
			isSelected = true;
		}
		
		public function unselect():void
		{
			isSelected = false;
		}
		
		public function draw():void
		{
			// implemented by children
		}
		
		public function backgroundIsDirty():Boolean
		{
			return false; // implemented by children
		}
		
		public function skinIsDirty():Boolean
		{
			return false; // implemented by children
		}
		
		public function updateSelectionAssignment(_isWide:Boolean, levelGraph:ConstraintGraph):void
		{
			isNarrow = !_isWide;
		}
	}
	
}