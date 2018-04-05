package dialogs
{
	import display.NineSliceBatch;
	
	import scenes.BaseComponent;
	import starling.display.Quad;
	
	/** handles creating a standard background frame, and disables rest of screen elements. */
	public class BaseDialog extends BaseComponent
	{
		protected var background:NineSliceBatch;
		
		protected var paddingWidth:int = 3;
		protected var paddingHeight:int = 2;
		protected var buttonHeight:int = 16;
		protected var buttonWidth:int = 36;
		
		public function BaseDialog(_width:Number, _height:Number)
		{
			super();
			
			//add sprite to disable all other controls
			var coverSprite:Quad = new Quad(480, 320, 0x000000);
			coverSprite.alpha = .2;
			addChild(coverSprite);
			
			//multiplying by two and then scaling seems to give the best result
			//but it does mean we can't add the buttons to the background.
			background = new NineSliceBatch(_width*2, _height*2, 64, 64, "Game", "DialogWindowPNG", "DialogWindowXML", "DialogWindow");
			background.scaleX = background.scaleY = .5;
			
			addChild(background);
			background.x = (480 - background.width)/2;
			background.y = (320 - background.height)/2 - 20;
		}
		
	}
}