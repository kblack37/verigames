package scenes.layoutselectscene
{
	import assets.AssetInterface;
	import assets.AssetsFont;
	
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import networking.GameFileHandler;
	
	import scenes.BaseComponent;
	import dialogs.SimpleTwoButtonDialog;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.XMath;
	import display.BasicButton;
	import display.NineSliceBatch;
	import display.SelectList;
	
	public class SelectLayoutList extends SelectList
	{
		public function SelectLayoutList(_width:Number, _height:Number)
		{
			super(_width, _height);
		}
		
		
		protected override function makeDocState(label:String, labelSz:uint, iconTexName:String, bgTexName:String, deleteButtonName:String = null, deleteIconCallback:Function = null):DisplayObject
		{
			const ICON_SZ:Number = 40;
			const DOC_WIDTH:Number = 128;
			const DOC_HEIGHT:Number = 50;
			const PAD:Number = 6;
			
			var icon:Image = new Image(levelAtlas.getTexture(iconTexName));
			icon.width = icon.height = ICON_SZ;
			icon.x = PAD;
			icon.y = DOC_HEIGHT / 2 - ICON_SZ / 2;
			
			var bg:NineSliceBatch = new NineSliceBatch(DOC_WIDTH * 4, DOC_HEIGHT * 4, 16, 16, "Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML", bgTexName);
			bg.scaleX = bg.scaleY = 0.25;
			
			var textField:TextFieldWrapper = TextFactory.getInstance().createTextField(label, AssetsFont.FONT_UBUNTU, DOC_WIDTH - ICON_SZ - 3 * PAD, DOC_HEIGHT - 2 * PAD, labelSz, 0x243079);
			textField.x = ICON_SZ + 2 * PAD;
			textField.y = PAD;
			
			
			var st:Sprite = new Sprite();
			st.addChild(bg);
			st.addChild(icon);
			st.addChild(textField);
			
			if(deleteIconCallback != null)
			{
				var deleteButtonImage:Image = new Image(levelAtlas.getTexture(deleteButtonName));
				deleteButtonImage.scaleX = deleteButtonImage.scaleY = 0.5;
				deleteButtonImage.x = st.width - deleteButtonImage.width - 2;
				deleteButtonImage.y = 2;
				st.addChild(deleteButtonImage);
				if(deleteIconCallback != null)
					deleteButtonImage.addEventListener(TouchEvent.TOUCH, deleteIconCallback);
			}
			
			return st;
		}
		
		protected override function reallyDeleteSavedGame(answer:int):void
		{
			if(answer == 2)
			{
				//remove button from dialog
				var index:int = buttonPaneArray.indexOf(currentDeleteTarget);
				if(index != -1)
				{
					buttonPaneArray.splice(index, 1);
					
					buttonPane.removeChildren();
					
					var xpos:Number = width - scrollbarBackground.width;
					var widthSpacing:Number = xpos/2;
					var heightSpacing:Number = 60;
					
					for(var ii:int = 0; ii<buttonPaneArray.length; ii++)
					{
						buttonPaneArray[ii].x = (widthSpacing) * (ii%2);
						buttonPaneArray[ii].y = Math.floor(ii/2) * (heightSpacing);
						buttonPane.addChild(buttonPaneArray[ii]);
					}
					
					if(buttonPaneArray.length > 0)
					{
						currentSelection = buttonPaneArray[0];
						currentSelection.setStatePosition(BasicButton.DOWN_STATE);
					}
					else
					{
						currentSelection = null;
					}
					
					if(buttonPane.height<initialHeight)
						thumb.enabled = false;
					else
						thumb.enabled = true;
					
					//and then remove level
					var levelID:String = currentDeleteTarget.data._id.$oid;
					GameFileHandler.deleteSavedLevel(levelID);
				}
			}
		}
	}
}
