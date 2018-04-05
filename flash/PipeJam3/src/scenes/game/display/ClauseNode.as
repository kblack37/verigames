package scenes.game.display
{
	import flash.geom.Rectangle;	
	import constraints.ConstraintClause;
	
	public class ClauseNode extends Node
	{
		
		private var _hasError:Boolean = false;
		private var _hadError:Boolean = false;
		
		public function ClauseNode(_id:String, _bb:Rectangle, _graphClause:ConstraintClause)
		{
			super(_id, _bb, _graphClause);
			
			isClause = true;
		}
		
		public function get graphClause():ConstraintClause { return graphConstraintSide as ConstraintClause; }
		
		public function hasError():Boolean
		{
			return _hasError;
		}
		
		public function get hadError():Boolean
		{
			return _hadError;
		}
		
		public function set hadError(_val:Boolean):void
		{
			_hadError = _val;
		}
		
		public function addError(_error:Boolean):void
		{
			if(isClause && _hasError != _error)
			{
				_hasError = _error;
			}			
		}
		
		public override function createSkin():void
		{
		//	trace('create node skin', id);
			if (skin == null) skin = NodeSkin.getNextSkin();
			if (skin != null)
			{
				setupSkin();
				skin.draw();
				skin.x = centerPoint.x;
				skin.y = centerPoint.y;
			}
			
			//create background
			if (backgroundSkin == null) backgroundSkin = NodeSkin.getNextSkin();
			if (backgroundSkin != null)
			{
				setupBackgroundSkin();
				backgroundSkin.draw();
				backgroundSkin.x = centerPoint.x;
				backgroundSkin.y = centerPoint.y;
			}
		}
		
		public override function setupSkin():void
		{
			if (skin != null) skin.setNodeProps(true, false, isSelected, solved, hasError(), false);
		}
		
		public override function setupBackgroundSkin():void
		{
			if (backgroundSkin != null) backgroundSkin.setNodeProps(true, false, isSelected, false, hasError(), true);
		}
		
		public override function skinIsDirty():Boolean
		{
			if (skin == null) return false;
			if (skin.isDirty) return true;
			if (skin.hasError() != hasError()) return true;
			return false;
		}
		
		public override function backgroundIsDirty():Boolean
		{
			if (backgroundSkin == null) return false;
			if (backgroundSkin.isDirty) return true;
			if (backgroundSkin.hasError() != hasError()) return true;
			return false;
		}
		
	}
}