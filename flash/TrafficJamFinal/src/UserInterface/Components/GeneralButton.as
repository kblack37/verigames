package UserInterface.Components

{
	import flash.events.Event;
	
	/**
	 * Generic clickable button
	 */
	public interface GeneralButton 
	{
		function draw():void;
		
		function buttonRollOver(e:Event):void;
		
		function buttonRollOut(e:Event):void;
		
		function select():void;
		
		function unselect():void;
		
		function get mouseOver():Boolean;

	}
	
}