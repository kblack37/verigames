package display
{
	import starling.display.DisplayObjectContainer;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class RadioButtonGroup extends DisplayObjectContainer
	{
		
		public function RadioButtonGroup()
		{
			super();
			
		}
		
		public override function addChild(_child:DisplayObject):DisplayObject
		{
			super.addChild(_child);
			return _child;
		}
		
		private function buttonClicked(event:Event):void
		{
			var button:NineSliceToggleButton = event.target as NineSliceToggleButton;
			makeActive(button);
		}
		
		public function makeActive(button:NineSliceToggleButton):void
		{
			button.setToggleState(true);
			for(var i:int = 0; i< numChildren; i++)
			{
				var childButton:NineSliceToggleButton = getChildAt(i) as NineSliceToggleButton;
				if(childButton && childButton != button)
					childButton.setToggleState(false);
			}
		}
		
		public function resetGroup():void
		{
			//set first visible button to on
			for(var i:int = 0; i< numChildren; i++)
			{
				var button:NineSliceToggleButton = getChildAt(i) as NineSliceToggleButton;
				if(button && button.visible)
				{
					makeActive(button);
					return;
				}
			}
		}
	}
}