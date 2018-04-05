package State 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import mx.core.UIComponent;
	
	public class GenericState extends UIComponent
	{
		
		public static var display:DisplayObjectContainer;
		
		public function GenericState() 
		{
			super();
		}
		
		private function onEnterFrame(e:Event):void {
			stateUpdate();
		}
		
		/** Called when State is initialized/added to the screen */
		public function stateLoad():void {
			if (display) {
				display.addChild(this);
			} else {
				throw new Error("Display parent not initialized, could not add State to stage: " + this);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/** Called when State is finished/to be removed from the screen */
		public function stateUnload():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			// Remove all children from stage
			while (numChildren > 0) { var disp:DisplayObject = getChildAt(0); removeChild(disp); disp = null; }
		}
		
		/** Called onEnterFrame */
		public function stateUpdate():void {
			// Implemeted by children
		}
		
	}

}