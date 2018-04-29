package display;

import haxe.Constraints.Function;
import assets.AssetInterface;
import assets.AssetsFont;
import dialogs.SimpleTwoButtonDialog;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Vector;
import scenes.BaseComponent;
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

class SelectList extends BaseComponent
{
    private var mainAtlas : TextureAtlas;
    private var levelAtlas : TextureAtlas;
    
    private var icon : Texture;
    
    private var background : NineSliceBatch;
    
    private var scrollbarBackground : Image;
    private var upArrow : Image;
    private var downArrow : Image;
    private var thumb : ScrollBarThumb;
    
    //remember passed in height, as # of child objects could expand content pane
    //and we want the clip rect to be this size
    private var initialHeight : Float;
    
    private var thumbTrackDistance : Float;
    private var thumbTrackTop : Float;
    private var thumbTrackBottom : Float;
    
    //store width early in case it changes...
    private var storedWidth : Float;
    
    //used by page up/down to multipy standard arrow key scroll distance
    private var scrollMultiplier : Float = 1.0;
    
    private var buttonPane : BaseComponent;
    private var buttonPaneArray : Array<Dynamic>;
    public var currentSelection : BasicButton;
    
    public function new(_width : Float, _height : Float)
    {
        super();
        initialHeight = _height;
        
        var scrollbarWidth : Float = 10.0;
        
        mainAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        levelAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
        
        upArrow = new Image(levelAtlas.getTexture(AssetInterface.PipeJamSubTexture_MenuArrowVertical));
        addChild(upArrow);
        upArrow.scaleX = .5;
        upArrow.scaleY = .5;
        upArrow.x = _width - upArrow.width - 3.5;
        upArrow.addEventListener(TouchEvent.TOUCH, onTouchUpArrow);
        
        downArrow = new Image(levelAtlas.getTexture(AssetInterface.PipeJamSubTexture_MenuArrowVertical));
        addChild(downArrow);
        downArrow.scaleX = .5;
        downArrow.scaleY = -.5;
        downArrow.x = _width - downArrow.width - 3.5;
        downArrow.y = _height;
        downArrow.addEventListener(TouchEvent.TOUCH, onTouchDownArrow);
        
        scrollbarBackground = new Image(levelAtlas.getTexture(AssetInterface.PipeJamSubTexture_ScrollBarTrack));
        addChild(scrollbarBackground);
        scrollbarBackground.x = _width - scrollbarWidth - 4;
        scrollbarBackground.y = upArrow.height + 1;
        scrollbarBackground.height = _height - upArrow.height - downArrow.height - 2;
        scrollbarBackground.width = scrollbarWidth;
        scrollbarBackground.addEventListener(TouchEvent.TOUCH, onTouchScrollbar);
        
        thumb = new ScrollBarThumb(scrollbarBackground.y, scrollbarBackground.y + scrollbarBackground.height);
        thumb.addEventListener(starling.events.Event.TRIGGERED, onThumbTriggered);
        addChild(thumb);
        thumb.x = scrollbarBackground.x + scrollbarWidth / 2 - thumb.width / 2;
        thumb.y = scrollbarBackground.y;
        
        thumbTrackTop = thumb.y;
        thumbTrackBottom = scrollbarBackground.height + scrollbarBackground.y - thumb.height;
        thumbTrackDistance = thumbTrackBottom - thumbTrackTop;
        
        
        buttonPane = new BaseComponent();
        buttonPane.x = 0;
        buttonPane.y = 0;
        addChild(buttonPane);
    }
    
    private function onTouchUpArrow(event : TouchEvent) : Void
    {
        if (thumb.enabled == false)
        {
            return;
        }
        
        var touches : Vector<Touch> = event.touches;
        if (touches.length == 0)
        {
            return;
        }
        var touch : Touch = event.getTouch(upArrow);
        if (touch == null)
        {
            return;
        }
        
        var currentPosition : Point = touch.getLocation(scrollbarBackground.parent);
        storedMouseY = currentPosition.y;
        if (event.getTouches(this, TouchPhase.BEGAN).length > 0)
        {
            this.addEventListener(Event.ENTER_FRAME, updateUpArrowScroll);
        }
        else if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            this.removeEventListener(Event.ENTER_FRAME, updateUpArrowScroll);
        }
    }
    
    private function onTouchDownArrow(event : TouchEvent) : Void
    {
        if (thumb.enabled == false)
        {
            return;
        }
        
        var touches : Vector<Touch> = event.touches;
        if (touches.length == 0)
        {
            return;
        }
        var touch : Touch = event.getTouch(downArrow);
        if (touch == null)
        {
            return;
        }
        
        var currentPosition : Point = touch.getLocation(scrollbarBackground.parent);
        storedMouseY = currentPosition.y;
        if (event.getTouches(this, TouchPhase.BEGAN).length > 0)
        {
            this.addEventListener(Event.ENTER_FRAME, updateDownArrowScroll);
        }
        else if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            this.removeEventListener(Event.ENTER_FRAME, updateDownArrowScroll);
        }
    }
    
    private function updateUpArrowScroll(e : Event) : Void
    {
        if (thumb.y <= thumbTrackTop)
        {
            this.removeEventListener(Event.ENTER_FRAME, updateUpArrowScroll);
        }
        else
        {
            scrollPanel(-3);
        }
    }
    
    private function updateDownArrowScroll(e : Event) : Void
    {
        if (thumb.y >= thumbTrackBottom)
        {
            this.removeEventListener(Event.ENTER_FRAME, updateDownArrowScroll);
        }
        else
        {
            scrollPanel(3);
        }
    }
    
    private function updatePageDownScroll(e : Event) : Void
    {
        if (storedMouseY < thumb.y + thumb.height / 2)
        {
            this.removeEventListener(Event.ENTER_FRAME, updatePageDownScroll);
        }
        else
        {
            scrollPanel(3);
        }
    }
    
    private function updatePageUpScroll(e : Event) : Void
    {
        if (storedMouseY > thumb.y + thumb.height / 2)
        {
            this.removeEventListener(Event.ENTER_FRAME, updatePageUpScroll);
        }
        //	trace(storedMouseY, thumb.y, thumb.height/2);
        else
        {
            
            scrollPanel(-3);
        }
    }
    
    private var directionUp : Bool = true;
    private var storedMouseY : Float = -1;
    private function onTouchScrollbar(event : TouchEvent) : Void
    {
        if (thumb.enabled == false)
        {
            return;
        }
        
        var touches : Vector<Touch> = event.touches;
        if (touches.length == 0)
        {
            return;
        }
        
        var touch : Touch = event.getTouch(scrollbarBackground);
        if (touch == null)
        {
            return;
        }
        
        var currentPosition : Point = touch.getLocation(scrollbarBackground.parent);
        
        if (event.getTouches(this, TouchPhase.BEGAN).length > 0)
        {
            storedMouseY = currentPosition.y;
            scrollMultiplier = 5.0;
            if (currentPosition.y < thumb.y)
            {
                directionUp = true;
                this.addEventListener(Event.ENTER_FRAME, updatePageUpScroll);
            }
            else
            {
                directionUp = false;
                this.addEventListener(Event.ENTER_FRAME, updatePageDownScroll);
            }
        }
        else if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            scrollMultiplier = 1.0;
            if (directionUp)
            {
                this.removeEventListener(Event.ENTER_FRAME, updatePageUpScroll);
            }
            else
            {
                this.removeEventListener(Event.ENTER_FRAME, updatePageDownScroll);
            }
        }
    }
    
    public function setClipRect() : Void
    {
        if (buttonPane.clipRect == null)
        {
            var globalPoint : Point = this.localToGlobal(new Point(0, 0));
            buttonPane.clipRect = new Rectangle(globalPoint.x, globalPoint.y, width - scrollbarBackground.width, initialHeight);
        }
    }
    
    private function onThumbTriggered(e : Event) : Void
    {
        if (e.data != null)
        {
            var ratioScrolled : Float = as3hx.Compat.parseFloat(e.data);
            
            if (buttonPane.height > initialHeight)
            {
                buttonPane.y = -(buttonPane.height - initialHeight) * ratioScrolled;
            }
        }
    }
    
    public function scrollPanel(percentScrolled : Float) : Void
    //remove false events
    {
        
        if (thumb.enabled == false)
        {
            return;
        }
        else if (percentScrolled > 0 && thumb.y >= thumbTrackBottom)
        {
            return;
        }
        else if (percentScrolled < 0 && thumb.y <= thumbTrackTop)
        {
            return;
        }
        
        var currentPercent : Float = buttonPane.y / -(buttonPane.height - initialHeight);
        percentScrolled = percentScrolled * scrollMultiplier;
        var totalNewScrollDistance : Float = currentPercent + percentScrolled / 100;
        totalNewScrollDistance = XMath.clamp(totalNewScrollDistance, 0, 1);
        
        buttonPane.y = -(buttonPane.height - initialHeight) * totalNewScrollDistance;
        thumb.setThumbPercent(totalNewScrollDistance * 100);
    }
    
    private function makeDocState(label : String, labelSz : Int, iconTexName : String, bgTexName : String, deleteButtonName : String = null, deleteIconCallback : Function = null) : DisplayObject
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
        
        var textField : TextFieldWrapper = TextFactory.getInstance().createTextField(label, AssetsFont.FONT_UBUNTU, DOC_WIDTH - ICON_SZ - 3 * PAD, DOC_HEIGHT - 2 * PAD, labelSz, 0xFFFFFF);
        textField.x = ICON_SZ + 2 * PAD;
        textField.y = PAD;
        
        
        var st : Sprite = new Sprite();
        st.addChild(bg);
        st.addChild(icon);
        st.addChild(textField);
        
        if (deleteIconCallback != null)
        {
            var deleteButtonImage : Image = new Image(levelAtlas.getTexture(deleteButtonName));
            deleteButtonImage.scaleX = deleteButtonImage.scaleY = 0.6;
            deleteButtonImage.x = st.width - deleteButtonImage.width - 2;
            deleteButtonImage.y = 3;
            st.addChild(deleteButtonImage);
            if (deleteIconCallback != null)
            {
                deleteButtonImage.addEventListener(TouchEvent.TOUCH, deleteIconCallback);
            }
        }
        
        return st;
    }
    
    public function setButtonArray(objArray : Array<Dynamic>, addDeleteButton : Bool) : Void
    {
        buttonPaneArray = new Array<Dynamic>();
        
        storedWidth = width;
        
        var xpos : Float = width - scrollbarBackground.width;
        var widthSpacing : Float = xpos / 2;
        var heightSpacing : Float = 60;
        
        var deleteCallback : Function = null;
        if (addDeleteButton)
        {
            deleteCallback = deleteSavedGame;
        }
        
        for (ii in 0...objArray.length)
        {
            var label : String = objArray[ii].name;
            var labelSz : Int = 12;
            var newButton : BasicButton;
            
            if (objArray[ii].unlocked)
            {
                var upstate : DisplayObject = makeDocState(label, labelSz, "DocumentIcon", "DocumentBackground", "DeleteButton", deleteCallback);
                var downstate : DisplayObject = makeDocState(label, labelSz, "DocumentIconClick", "DocumentBackgroundClick", "DeleteButtonClick", deleteCallback);
                var overstate : DisplayObject = makeDocState(label, labelSz, "DocumentIconMouseover", "DocumentBackgroundMouseover", "DeleteButtonMouseover", deleteCallback);
                newButton = new BasicButton(upstate, overstate, downstate);
                newButton.data = objArray[ii];
                
                if (objArray[ii].checked)
                {
                    var checkmarkTexture : Texture = AssetInterface.getTexture("Game", "CheckmarkClass");
                    var checkmark : Image = new Image(checkmarkTexture);
                    checkmark.x = checkmark.y = 10;
                    newButton.addChild(checkmark);
                }
            }
            else
            {
                var lockstate : DisplayObject = makeDocState(label, labelSz, "DocumentIconLocked", "DocumentBackgroundLocked");
                newButton = new BasicButton(lockstate, lockstate, lockstate);
                newButton.enabled = false;
            }
            
            newButton.x = (widthSpacing) * (ii % 2);
            newButton.y = Math.floor(ii / 2) * (heightSpacing);
            
            newButton.addEventListener(Event.TRIGGERED, onLevelButtonTouched);
            buttonPaneArray.push(newButton);
            buttonPane.addChild(newButton);
        }
        
        currentSelection = buttonPaneArray[0];
        if (currentSelection != null)
        {
            currentSelection.setStatePosition(BasicButton.DOWN_STATE);
        }
        
        if (buttonPane.height < initialHeight)
        {
            thumb.enabled = false;
        }
        else
        {
            thumb.enabled = true;
        }
    }
    
    private var currentDeleteTarget : BasicButton;
    private function deleteSavedGame(event : TouchEvent) : Void
    {
        var dialogWidth : Float = 160;
        var dialogHeight : Float = 60;
        
        if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
        //find parent button
            
            var displayObject : DisplayObject = try cast(event.target, DisplayObject) catch(e:Dynamic) null;
            while (displayObject != null && !(Std.is(displayObject, BasicButton)))
            {
                displayObject = displayObject.parent;
            }
            
            if (displayObject == null)
            {
                return;
            }
            
            currentDeleteTarget = try cast(displayObject, BasicButton) catch(e:Dynamic) null;
            
            var simpleTwoButtonDialog : SimpleTwoButtonDialog = new SimpleTwoButtonDialog("Delete Saved Game?", "Yes", "No", dialogWidth, dialogHeight, reallyDeleteSavedGame);
            //				simpleTwoButtonDialog.x = (width - dialogWidth)/2;
            //				simpleTwoButtonDialog.y = 50;
            addChild(simpleTwoButtonDialog);
        }
    }
    
    private function reallyDeleteSavedGame(answer : Int) : Void
    {
    }
    
    private function onLevelButtonTouched(event : Event) : Void
    {
        if (currentSelection != event.target)
        {
            currentSelection.setStatePosition(BasicButton.UP_STATE);
        }
        currentSelection = try cast(event.target, BasicButton) catch(e:Dynamic) null;
        currentSelection.setStatePosition(BasicButton.DOWN_STATE);
        dispatchEventWith(Event.TRIGGERED);
    }
}

