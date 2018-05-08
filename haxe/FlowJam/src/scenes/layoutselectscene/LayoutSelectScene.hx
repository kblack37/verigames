package scenes.layoutselectscene;

import assets.AssetInterface;
import assets.AssetsFont;
import display.BasicButton;
import display.NineSliceBatch;
import display.NineSliceButton;
import display.NineSliceToggleButton;
import events.MenuEvent;
import events.NavigationEvent;
import openfl.Assets;
//import feathers.controls.List;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.ByteArray;
import networking.*;
import particle.ErrorParticleSystem;
import scenes.Scene;
import scenes.game.PipeJamGameScene;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;
//import utils.Base64Decoder;

class LayoutSelectScene extends Scene
{
    private var background : Image;
    
    private var levelSelectBackground : NineSliceBatch;
    private var levelSelectInfoPanel : NineSliceBatch;
    
    private var tutorial_levels_button : NineSliceToggleButton;
    private var new_levels_button : NineSliceToggleButton;
    private var saved_levels_button : NineSliceToggleButton;
    
    private var select_button : NineSliceButton;
    private var cancel_button : NineSliceButton;
    
    private var allLayoutslListBox : SelectLayoutList;
    private var currentVisibleListBox : SelectLayoutList;
    
    //for the info panel
    private var infoLabel : TextFieldWrapper;
    private var nameText : TextFieldWrapper;
    private var descriptionText : TextFieldWrapper;
    
    private var thumbnailViewer : Sprite;
    private var thumbActualWidth : Int;
    private var thumbActualHeight : Int;
    
    private var m_layouts : Array<Dynamic>;
    
    private var labelHeight : Float;
    
    
    public function new(game : PipeJamGame = null)
    {
        super(game);
    }
    
    override private function addedToStage(event : starling.events.Event) : Void
    {
        super.addedToStage(event);
        
		background = new Image(AssetInterface.getTexture("img/Backgrounds", "FlowJamBackground0.jpg"));
        background.scaleX = stage.stageWidth / background.width;
        background.scaleY = stage.stageHeight / background.height;
        background.blendMode = BlendMode.NONE;
        addChild(background);
        
        var levelSelectWidth : Float = 305;
        var levelSelectHeight : Float = 300;
        levelSelectBackground = new NineSliceBatch(levelSelectWidth, levelSelectHeight, levelSelectWidth / 6.0, levelSelectHeight / 6.0, "atlases", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml", "LevelSelectWindow");
        levelSelectBackground.x = 10;
        levelSelectBackground.y = 10;
        addChild(levelSelectBackground);
        
        //select side widgets
        var buttonPadding : Int = 7;
        var buttonWidth : Float = (levelSelectWidth - 2 * buttonPadding) / 3 - buttonPadding;
        var buttonHeight : Float = 25;
        var buttonY : Float = 30;
        
        var label : TextFieldWrapper = TextFactory.getInstance().createTextField("Select Layout", "_sans", 120, 30, 24, 0xFFFFFF);
        TextFactory.getInstance().updateAlign(label, 1, 1);
        addChild(label);
        label.x = (levelSelectWidth - label.width) / 2 + levelSelectBackground.x;
        label.y = 10;
        
        select_button = ButtonFactory.getInstance().createDefaultButton("Select", 50, 18);
        select_button.addEventListener(starling.events.Event.TRIGGERED, onSelectButtonTriggered);
        addChild(select_button);
        select_button.x = levelSelectWidth - 50 - buttonPadding;
        select_button.y = levelSelectHeight - select_button.height - 6;
        
        cancel_button = ButtonFactory.getInstance().createDefaultButton("Cancel", 50, 18);
        cancel_button.addEventListener(starling.events.Event.TRIGGERED, onCancelButtonTriggered);
        addChild(cancel_button);
        cancel_button.x = select_button.x - cancel_button.width - buttonPadding;
        cancel_button.y = select_button.y;
        
        allLayoutslListBox = new SelectLayoutList(levelSelectWidth - 3 * buttonPadding, 198);
        allLayoutslListBox.y = buttonY + label.y + buttonHeight + buttonPadding;
        allLayoutslListBox.x = (levelSelectWidth - allLayoutslListBox.width) / 2 + levelSelectBackground.x;
        addChild(allLayoutslListBox);
        
        labelHeight = buttonY + label.y;
        
        drawInfoPanel();
        
        initialize();
    }
    
    private function drawInfoPanel() : Void
    {
        var levelSelectInfoWidth : Float = 150;
        var levelSelectInfoHeight : Float = 300;
        levelSelectInfoPanel = new NineSliceBatch(levelSelectInfoWidth, levelSelectInfoHeight, levelSelectInfoWidth / 6.0, levelSelectInfoHeight / 6.0, "atlases", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml", "LevelSelectWindow");
        levelSelectInfoPanel.x = width - levelSelectInfoWidth - 10;
        levelSelectInfoPanel.y = 10;
        addChild(levelSelectInfoPanel);
        
        infoLabel = TextFactory.getInstance().createTextField("Layout Info", "_sans", 80, 24, 18, 0xFFFFFF);
        TextFactory.getInstance().updateAlign(infoLabel, 1, 1);
        addChild(infoLabel);
        infoLabel.x = (levelSelectInfoWidth - infoLabel.width) / 2 + levelSelectInfoPanel.x;
        infoLabel.y = labelHeight;
    }
    
    override private function removedFromStage(event : Event) : Void
    {
        removeEventListener(Event.TRIGGERED, updateSelectedLevelInfo);
    }
    
    public function initialize() : Void
    {
        allLayoutslListBox.setClipRect();
        
        if (m_layouts != null)
        {
            allLayoutslListBox.setButtonArray(m_layouts, false);
        }
        
        onAllButtonTriggered(null);
        
        addEventListener(Event.TRIGGERED, updateSelectedLevelInfo);
        
        dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, false);
    }
    
    private function onAllButtonTriggered(e : Event) : Void
    {
        allLayoutslListBox.visible = true;
        
        currentVisibleListBox = allLayoutslListBox;
        updateSelectedLevelInfo();
    }
    
    
    
    public function updateSelectedLevelInfo(e : Event = null, drawThumbnail : Bool = true) : Void
    {
        var nextTextBoxYPos : Float = allLayoutslListBox.y;
        if (currentVisibleListBox.currentSelection != null && currentVisibleListBox.currentSelection.data != null)
        {
            var currentSelectedLayout : Dynamic = currentVisibleListBox.currentSelection.data;
            
            removeChild(nameText);
            if (Reflect.hasField(currentSelectedLayout, "name"))
            {
                nameText = TextFactory.getInstance().createTextField("Name: " + currentSelectedLayout.name, "_sans", 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(nameText, 0, 1);
                addChild(nameText);
                nameText.x = levelSelectInfoPanel.x + 10;
                nameText.y = nextTextBoxYPos;  //line up with list box  
                nextTextBoxYPos += 20;
            }
            
            removeChild(descriptionText);
            //				removeChild(numEdgesText);
            //				removeChild(numConflictsText);
            //				removeChild(scoreText);
            //
            if (Reflect.hasField(currentSelectedLayout, "description"))
            {
                if (currentSelectedLayout.description.length > 0)
                {
                    descriptionText = TextFactory.getInstance().createTextField("Description:\r\t" + currentSelectedLayout.description, "_sans", 140, 60, 12, 0xFFFFFF, true);
                    TextFactory.getInstance().updateAlign(descriptionText, 0, 1);
                    addChild(descriptionText);
                    descriptionText.x = levelSelectInfoPanel.x + 10;
                    descriptionText.y = nextTextBoxYPos;
                    nextTextBoxYPos += 68;
                }
            }
            
            if (drawThumbnail)
            {
                thumbnailViewer = new Sprite();
                thumbnailViewer.x = levelSelectInfoPanel.x;
                thumbnailViewer.y = nextTextBoxYPos;
                addChild(thumbnailViewer);
                
                if (!Reflect.hasField(currentSelectedLayout, "layoutFile"))
                {
                    GameFileHandler.getFileByID(currentSelectedLayout.layoutID, getNewLayout);
                }
                else
                {
                    showThumbnail();
                }
            }
        }
    }
    
    //get layout and display thumbnail. Also attach xml to object so I don't have to get again if choosen
    private function getNewLayout(layoutFile : FastXML) : Void
    //unpack xml, find correct object, attach to it, and if object == current selection, show thumb
    {
        
        var currentSelectedLayout : Dynamic = currentVisibleListBox.currentSelection.data;
        
        for (obj in m_layouts)
        {
            if (obj.name == layoutFile.att.id)
            {
                obj.layoutFile = layoutFile;
                if (obj == currentSelectedLayout)
                {
                    showThumbnail();
                    break;
                }
            }
        }
    }
    
    private function onCancelButtonTriggered(e : Event) : Void
    {
        dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, true);
        this.parent.removeChild(this);
    }
    
    private function onSelectButtonTriggered(ev : Event) : Void
    {
        var dataObj : Dynamic = currentVisibleListBox.currentSelection.data;
        if (dataObj != null)
        {
            var layoutID : String = dataObj.layoutID;
            
            var data : Dynamic = {};
            data.name = dataObj.name;
            data.layoutFile = dataObj.layoutFile;
            dispatchEvent(new MenuEvent(MenuEvent.SET_NEW_LAYOUT, data));
        }
        dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, true);
        this.parent.removeChild(this);
    }
    
    private function setNewLayout(byteArray : ByteArray) : Void
    {
        var name : String = PipeJamGame.levelInfo.layoutName;
        var layoutFile : FastXML = new FastXML(Xml.parse(byteArray.toString()));
        var data : Dynamic = {};
        data.name = name;
        data.layoutFile = layoutFile;
        dispatchEvent(new MenuEvent(MenuEvent.SET_NEW_LAYOUT, data));
    }
    
    public function setLayouts(layoutList : Array<Dynamic>) : Void
    {
        m_layouts = new Array<Dynamic>();
        for (obj in layoutList)
        {
            m_layouts.push(obj);
            obj.unlocked = true;
            var namePlusDescription : String = obj.name;
            var index : Int = namePlusDescription.indexOf("::");
            if (index != -1)
            {
                obj.name = namePlusDescription.substring(0, index);
                obj.description = namePlusDescription.substring(index + 2);
            }
            else
            {
                obj.name = namePlusDescription;
                obj.description = "No Description";
            }
        }
        
        if (allLayoutslListBox != null)
        {
            allLayoutslListBox.setButtonArray(m_layouts, false);
        }
    }
    
    public function showThumbnail() : Void
    {
        var currentSelectedLayout : Dynamic = currentVisibleListBox.currentSelection.data;
        if (Reflect.hasField(currentSelectedLayout, "layoutFile"))
        {
            if (Reflect.hasField(currentSelectedLayout.layoutFile, "thumb"))
            {
                var thumbByteArray : ByteArray = new ByteArray();
                //var dec : Base64Decoder = new Base64Decoder();
                //dec.decode(Std.string(Reflect.field(currentSelectedLayout.layoutFile, "thumb")));
                //thumbByteArray = dec.toByteArray();
                
                thumbByteArray.uncompress();
                var thumbActualWidth : Int = thumbByteArray.readUnsignedInt();
                var thumbActualHeight : Int = as3hx.Compat.parseInt(((thumbByteArray.length - 4) / 4) / thumbActualWidth);
                var smallBMD : BitmapData = new BitmapData(thumbActualWidth, thumbActualHeight);
                smallBMD.setPixels(smallBMD.rect, thumbByteArray);
                var bmp : Bitmap = new Bitmap(smallBMD, PixelSnapping.ALWAYS, true);
                var texture : Texture = Texture.fromBitmap(bmp, false);
                var im : Image = new Image(texture);
                //now want the image with a max width of 130, and the height proportional, but not over 130.
                var imageWidth : Float;
                var imageHeight : Float;
                var scale : Float;
                if (thumbActualWidth > thumbActualHeight)
                {
                    imageWidth = 130;
                    scale = 130 / thumbActualWidth;
                    imageHeight = thumbActualHeight * scale;
                }
                else
                {
                    imageHeight = 130;
                    scale = 130 / thumbActualHeight;
                    imageWidth = thumbActualWidth * scale;
                }
                im.width = imageWidth;
                im.height = imageHeight;
                im.x = (150 - imageWidth) / 2;
                thumbnailViewer.addChild(im);
                addChild(thumbnailViewer);
            }
            else
            {
                thumbnailViewer.removeChildren();
                removeChild(levelSelectInfoPanel);
                drawInfoPanel();
                updateSelectedLevelInfo(null, false);
            }
        }
    }
    
    public function rotateAroundCenter(ob : Dynamic, angleDegrees : Float) : Void
    {
        var point : Point = new Point(ob.x, ob.y);
        var m : Matrix = ob.transform.matrix;
        m.tx -= point.x;
        m.ty -= point.y;
        m.rotate(angleDegrees * (Math.PI / 180));
        m.tx += point.x;
        m.ty += point.y;
        ob.transform.matrix = m;
    }
}
