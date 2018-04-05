package dialogs;

import assets.AssetInterface;
import display.NineSliceBatch;
import scenes.BaseComponent;
import starling.display.Quad;

/** handles creating a standard background frame, and disables rest of screen elements. */
class BaseDialog extends BaseComponent
{
    private var background : NineSliceBatch;
    
    private var paddingWidth : Int = 3;
    private var paddingHeight : Int = 2;
    private var buttonHeight : Int = 16;
    private var buttonWidth : Int = 36;
    
    public function new(_width : Float, _height : Float)
    {
        super();
        
        //add sprite to disable all other controls
        var coverSprite : Quad = new Quad(480, 320, 0x000000);
        coverSprite.alpha = .2;
        addChild(coverSprite);
        
        //multiplying by two and then scaling seems to give the best result
        //but it does mean we can't add the buttons to the background.
        background = new NineSliceBatch(_width * 2, _height * 2, 64, 64, AssetInterface.DialogWindowAtlas, "DialogWindow");
        background.scaleX = background.scaleY = .5;
        
        addChild(background);
        background.x = (480 - background.width) / 2;
        background.y = (320 - background.height) / 2 - 20;
    }
}
