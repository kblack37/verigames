package scenes.game.display;

import flash.geom.Point;
import assets.AssetsFont;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import utils.XSprite;

class TextPopup extends Sprite
{
    public function new(str : String, color : Int)
    {
        super();
        var textField : TextFieldWrapper = TextFactory.getInstance().createTextField(str, AssetsFont.FONT_UBUNTU, 100, 25, 8, color);
        TextFactory.getInstance().updateAlign(textField, TextFactory.HCENTER, TextFactory.VCENTER);
        if (!PipeJam3.DISABLE_FILTERS)
        {
            TextFactory.getInstance().updateFilter(textField, OutlineFilter.getOutlineFilter());
        }
        XSprite.setPivotCenter(textField);
        addChild(textField);
    }
    
    public static function popupText(container : DisplayObjectContainer, _pos : Point, str : String, color : Int) : Void
    {
        var text : TextPopup = new TextPopup(str, color);
        var pos : Point = container.globalToLocal(_pos);
        text.x = pos.x;
        text.y = pos.y - 8;
        
        container.addChild(text);
        
        //find current scale, and reverse it
        var totalScale : Float = 1;
        var currentItem : DisplayObjectContainer = container;
        while (currentItem != null)
        {
            totalScale *= currentItem.scaleX;
            currentItem = currentItem.parent;
        }
        text.scaleX = text.scaleY = 1 / totalScale;
        
        Starling.current.juggler.tween(text, 1.5, {
                    y : pos.y - 20,
                    alpha : 0.2,
                    onComplete : function() : Void
                    {
                        text.removeFromParent();
                    }
                });
    }
}

