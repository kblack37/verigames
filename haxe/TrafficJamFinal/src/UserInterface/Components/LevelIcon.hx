package userInterface.components;

import haxe.Constraints.Function;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import visualWorld.Level;
import visualWorld.World;
import utilities.Fonts;
import userInterface.components.RectangularObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.text.*;
import mx.controls.Image;
import utilities.XSprite;

/**
	 * An icon used to navigate to an associated level in the game. The icon and the name of the level are displayed.
	 */
class LevelIcon extends ImageButtonCircle
{
    public var isHome(get, never) : Bool;

    public var level : Level;
    public var home_level : Level;
    
    private var level_title_mouseover : TextField;
    private var title_scale : Float;
    private var m_textFormat : TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 40, 0xFFFF00, true, false, false, null, null, TextFormatAlign.CENTER);
    private var m_lockedTextFormat : TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 40, 0xAAAAAA, true, false, false, null, null, TextFormatAlign.CENTER);
    private var glow_filter : GlowFilter = new GlowFilter(0x0, 1, 6, 6, 5);
    
    public function new(_x : Int, _y : Int, _radius : Int, _level : Level, _image : DisplayObject, _rollover_image : DisplayObject, _click_callback : Function)
    {
        level = _level;
        name = "LevelIcon:" + level.level_name;
        level_title_mouseover = new TextField();
        level_title_mouseover.embedFonts = true;
        level_title_mouseover.text = level.level_name;
        level_title_mouseover.setTextFormat(m_textFormat);
        level_title_mouseover.wordWrap = true;
        level_title_mouseover.width = 500;
        level_title_mouseover.x = -250;
        level_title_mouseover.autoSize = TextFieldAutoSize.CENTER;
        level_title_mouseover.y = 1.0 * _radius;
        level_title_mouseover.selectable = false;
        level_title_mouseover.filters = new Array<Dynamic>(glow_filter);
        title_scale = 3 * _radius / level_title_mouseover.textWidth;
        level_title_mouseover.scaleX = title_scale;
        level_title_mouseover.scaleY = title_scale;
        
        super(_x, _y, _radius, _image, _rollover_image, _click_callback);
        
        _level.level_icon = this;
    }
    
    private function get_isHome() : Bool
    {
        return level == home_level;
    }
    
    override public function buttonRollOver(e : Event) : Void
    {
        m_mouseOver = true;
        draw();
    }
    
    override public function buttonRollOut(e : Event) : Void
    {
        m_mouseOver = false;
        draw();
    }
    
    override public function draw() : Void
    {
        if (level.unlocked || Level.UNLOCK_ALL_LEVELS_FOR_DEBUG)
        {
            if (!m_enabled)
            {
                enable();
            }
        }
        else if (m_enabled)
        {
            disable();
        }
        
        graphics.clear();
        while (numChildren)
        {
            removeChildAt(0);
        }
        if (level.world.m_gameSystem.current_level == level)
        {
            graphics.beginFill(0xFFFF00, 0.75);
        }
        else if (!level.unlocked && !isHome)
        {
            graphics.beginFill(0x888888, 1.0);
        }
        if (!level.unlocked)
        {
            graphics.lineStyle(0.2 * m_radius, 0x444444);
        }
        else if (buttonMode && m_mouseOver)
        {
            graphics.lineStyle(0.2 * m_radius, 0xFFFFFF);
        }
        else if (!level.failed)
        {
            graphics.lineStyle(0.2 * m_radius, 0x00FF00);
        }
        else if (level.failed)
        {
            graphics.lineStyle(0.2 * m_radius, 0xFF0000);
        }
        else
        {
            graphics.lineStyle(0, 0xFFFFFF, 0.0);
        }
        graphics.drawCircle(0, 0, m_radius);
        if (level.world.m_gameSystem.current_level == level)
        {
            graphics.endFill();
        }
        var image_alpha : Float = 1.0;
        level_title_mouseover.setTextFormat(m_textFormat);
        if (!level.unlocked && !isHome)
        {
            image_alpha = 0.5;
            level_title_mouseover.setTextFormat(m_lockedTextFormat);
        }
        if (m_rollover_image != null && m_mouseOver)
        {
            m_rollover_image.alpha = image_alpha;
            addChild(m_rollover_image);
        }
        else
        {
            m_image.alpha = image_alpha;
            addChild(m_image);
        }
        if (level_title_mouseover.parent != this)
        {
            addChild(level_title_mouseover);
        }
        else
        {
            setChildIndex(level_title_mouseover, numChildren - 1);
        }
        
        if (m_mouseOver)
        {
            if (parent != null)
            {
                level_title_mouseover.scaleX = 1.0 / parent.scaleX;
                level_title_mouseover.scaleY = 1.0 / parent.scaleY;
                level_title_mouseover.x = -250 / parent.scaleX;
                // Place this icon on top of world map, but below pawn
                parent.setChildIndex(this, Math.max(0, parent.numChildren - 2));
            }
        }
        else
        {
            level_title_mouseover.scaleX = title_scale;
            level_title_mouseover.scaleY = title_scale;
            level_title_mouseover.x = -250 * title_scale;
        }
        if (m_coverSprite.parent != this)
        {
            addChild(m_coverSprite);
        }
        else
        {
            setChildIndex(m_coverSprite, numChildren - 1);
        }
    }
}
