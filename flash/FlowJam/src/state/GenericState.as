package state 
{
	import flash.events.Event;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class GenericState extends Sprite
	{
		
		public static var display:Sprite;
		
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
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
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