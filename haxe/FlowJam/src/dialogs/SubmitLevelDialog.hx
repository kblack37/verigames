package dialogs;

import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceBatch;
import display.NineSliceButton;
import events.MenuEvent;
import feathers.controls.Label;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.TextFormat;
import networking.GameFileHandler;
import scenes.BaseComponent;
import scenes.game.display.Level;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.extensions.pixelmask.PixelMaskDisplayObject;
import starling.textures.Texture;

class SubmitLevelDialog extends BaseDialog
{
    /** Button to save the current layout */
    public var submit_button : NineSliceButton;
    
    /** Button to close the dialog */
    public var cancel_button : NineSliceButton;
    
    private var starScaleFactor : Float = .4;
    
    private var enjoymentQuad : Quad;
    private var difficultyQuad : Quad;
    
    private var enjoymentStarsBackground : Image;
    private var difficultyStarsBackground : Image;
    
    public var enjoymentRating : Float = 0.5;
    
    public function new(_width : Float, _height : Float)
    {
        super(_width, _height);
        
        cancel_button = ButtonFactory.getInstance().createButton("Cancel", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        cancel_button.addEventListener(starling.events.Event.TRIGGERED, onCancelButtonTriggered);
        cancel_button.x = background.width * .5 + background.x + 4;
        cancel_button.y = background.height - buttonHeight + background.y - 15;
        addChild(cancel_button);
        
        submit_button = ButtonFactory.getInstance().createButton("Submit", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        submit_button.addEventListener(starling.events.Event.TRIGGERED, onSubmitButtonTriggered);
        submit_button.x = background.width * .5 + background.x - 4 - submit_button.width;
        submit_button.y = cancel_button.y;
        addChild(submit_button);
        
        var label : TextFieldWrapper = TextFactory.getInstance().createTextField("Rate It!", AssetsFont.FONT_UBUNTU, _width - 30, 18, 18, 0xFFFFFF);
        TextFactory.getInstance().updateAlign(label, 1, 1);
        addChild(label);
        label.x = 15 + background.x;
        label.y = 10 + background.y;
        
        var label1 : TextFieldWrapper = TextFactory.getInstance().createTextField("Did you enjoy that level?", AssetsFont.FONT_UBUNTU, _width - 30, 32, 18, 0x243079);
        TextFactory.getInstance().updateAlign(label1, 1, 1);
        label1.x = 15 + background.x;
        label1.y = label.y + label.height - 6;
        addChild(label1);
        
        var enjoymentStarsMaskBackgroundTexture : Texture = AssetInterface.getTexture("Game", "RatingStarsClass");
        var enjoymentStarsMask : Image = new Image(enjoymentStarsMaskBackgroundTexture);
        enjoymentStarsMask.width *= starScaleFactor;
        enjoymentStarsMask.height *= starScaleFactor;
        
        var enjoymentStars : PixelMaskDisplayObject = new PixelMaskDisplayObject();
        enjoymentStars.width = enjoymentStarsMask.width;
        enjoymentStars.height = enjoymentStarsMask.height;
        enjoymentStars.x = background.x + .5 * background.width - .5 * enjoymentStarsMask.width;
        enjoymentStars.y = label1.y + label1.height - 3;
        enjoymentStars.addEventListener(TouchEvent.TOUCH, overEnjoymentStars);
        
        enjoymentQuad = new Quad(enjoymentStarsMask.width / 2, enjoymentStarsMask.height, 0x243079);
        enjoymentStars.mask = enjoymentStarsMask;
        
        var enjoymentBackgroundStarsTexture : Texture = AssetInterface.getTexture("Game", "RatingStarsClass");
        enjoymentStarsBackground = new Image(enjoymentBackgroundStarsTexture);
        enjoymentStarsBackground.x = enjoymentStars.x;
        enjoymentStarsBackground.y = enjoymentStars.y;
        enjoymentStarsBackground.width *= starScaleFactor;
        enjoymentStarsBackground.height *= starScaleFactor;
        enjoymentStarsBackground.addEventListener(TouchEvent.TOUCH, overEnjoymentStars);
        
        addChild(enjoymentStarsBackground);
        addChild(enjoymentStars);
        enjoymentStars.addChild(enjoymentQuad);
    }
    
    private function overEnjoymentStars(e : TouchEvent) : Void
    {
        var returnVal : Float = overStarsDelta(e, enjoymentStarsBackground, enjoymentQuad);
        
        if (returnVal != -1)
        {
            enjoymentRating = returnVal;
        }
    }
    
    private function overStarsDelta(e : TouchEvent, obj : Image, quad : Quad) : Float
    {
        if (e.getTouches(this, TouchPhase.ENDED).length)
        {
            var touch : Touch = e.getTouches(this, TouchPhase.ENDED)[0];
            if (touch.tapCount > 0)
            {
                var touchPoint : Point = touch.getLocation(this);
                var globalPoint : Point = localToGlobal(touchPoint);
                var localPoint : Point = obj.globalToLocal(globalPoint);
                quad.width = localPoint.x * starScaleFactor;
                return quad.width / obj.width;
            }
        }
        return -1;
    }
    
    
    private function onCancelButtonTriggered(e : starling.events.Event) : Void
    {
        visible = false;
    }
    
    private function onSubmitButtonTriggered(e : starling.events.Event) : Void
    {
        visible = false;
        var eRating : Float = this.enjoymentRating * 5.0;
        //round to two decimal places
        eRating *= 100;
        eRating = Math.round(eRating);
        eRating /= 100;
        if (PipeJamGame.levelInfo == null)
        {
            PipeJamGame.levelInfo = {};
        }
        PipeJamGame.levelInfo.enjoymentRating = eRating;
        
        GameFileHandler.reportPlayerPreference(Std.string(as3hx.Compat.parseInt(Math.round(eRating * 20))));  //0-100 scale  
        dispatchEvent(new MenuEvent(MenuEvent.SUBMIT_LEVEL));
        
        GameFileHandler.reportScore();
    }
}
