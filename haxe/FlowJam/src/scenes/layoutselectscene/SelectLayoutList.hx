package scenes.layoutselectscene;

import haxe.Constraints.Function;
import assets.AssetInterface;
import assets.AssetsFont;
import flash.geom.Point;
import flash.geom.Rectangle;
import networking.GameFileHandler;
import openfl.Assets;
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

class SelectLayoutList extends SelectList
{
    public function new(_width : Float, _height : Float)
    {
        super(_width, _height);
    }
    
    
    override private function makeDocState(label : String, labelSz : Int, iconTexName : String, bgTexName : String, deleteButtonName : String = null, deleteIconCallback : Function = null) : DisplayObject
    {
        var ICON_SZ : Float = 40;
        var DOC_WIDTH : Float = 128;
        var DOC_HEIGHT : Float = 50;
        var PAD : Float = 6;
        
        var icon : Image = new Image(levelAtlas.getTexture(iconTexName));
        icon.width = icon.height = ICON_SZ;
        icon.x = PAD;
        icon.y = DOC_HEIGHT / 2 - ICON_SZ / 2;
        
        var bg : NineSliceBatch = new NineSliceBatch(DOC_WIDTH * 4, DOC_HEIGHT * 4, 16, 16, "Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML", bgTexName);
        bg.scaleX = bg.scaleY = 0.25;
        
        var textField : TextFieldWrapper = TextFactory.getInstance().createTextField(label, "_sans", DOC_WIDTH - ICON_SZ - 3 * PAD, DOC_HEIGHT - 2 * PAD, labelSz, 0x243079);
        textField.x = ICON_SZ + 2 * PAD;
        textField.y = PAD;
        
        
        var st : Sprite = new Sprite();
        st.addChild(bg);
        st.addChild(icon);
        st.addChild(textField);
        
        if (deleteIconCallback != null)
        {
            var deleteButtonImage : Image = new Image(levelAtlas.getTexture(deleteButtonName));
            deleteButtonImage.scaleX = deleteButtonImage.scaleY = 0.5;
            deleteButtonImage.x = st.width - deleteButtonImage.width - 2;
            deleteButtonImage.y = 2;
            st.addChild(deleteButtonImage);
            if (deleteIconCallback != null)
            {
                deleteButtonImage.addEventListener(TouchEvent.TOUCH, deleteIconCallback);
            }
        }
        
        return st;
    }
    
    override private function reallyDeleteSavedGame(answer : Int) : Void
    {
        if (answer == 2)
        {
        //remove button from dialog
            
            var index : Int = buttonPaneArray.indexOf(currentDeleteTarget);
            if (index != -1)
            {
                buttonPaneArray.splice(index, 1);
                
                buttonPane.removeChildren();
                
                var xpos : Float = width - scrollbarBackground.width;
                var widthSpacing : Float = xpos / 2;
                var heightSpacing : Float = 60;
                
                for (ii in 0...buttonPaneArray.length)
                {
                    buttonPaneArray[ii].x = (widthSpacing) * (ii % 2);
                    buttonPaneArray[ii].y = Math.floor(ii / 2) * (heightSpacing);
                    buttonPane.addChild(buttonPaneArray[ii]);
                }
                
                if (buttonPaneArray.length > 0)
                {
                    currentSelection = buttonPaneArray[0];
                    currentSelection.setStatePosition(BasicButton.DOWN_STATE);
                }
                else
                {
                    currentSelection = null;
                }
                
                if (buttonPane.height < initialHeight)
                {
                    thumb.enabled = false;
                }
                else
                {
                    thumb.enabled = true;
                }
                
                //and then remove level
                var levelID : String = currentDeleteTarget.data._id.__DOLLAR__oid;
                GameFileHandler.deleteSavedLevel(levelID);
            }
        }
    }
}

