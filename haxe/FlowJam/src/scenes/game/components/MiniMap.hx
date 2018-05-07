package scenes.game.components;

import flash.errors.Error;
import assets.AssetInterface;
import constraints.Constraint;
import constraints.ConstraintVar;
import display.BasicButton;
import display.MapHideButton;
import display.MapShowButton;
import display.TextBubble;
import events.MiniMapEvent;
import events.MoveEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import graph.PropDictionary;
import openfl.Vector;
import particle.ErrorParticleSystem;
import scenes.BaseComponent;
import scenes.game.display.GameComponent;
import scenes.game.display.Level;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import utils.XMath;

class MiniMap extends BaseComponent
{
    private var visibleBB(get, never) : Rectangle;

    public static var WIDTH : Float = 0.8 * 140;
    public static var HEIGHT : Float = 0.8 * 134;
    
    public static var HIDDEN_Y : Float = HEIGHT * 60.0 / 268.0 - HEIGHT;
    public static inline var SHOWN_Y : Float = 0;
    
    public static var CLICK_AREA : Rectangle = new Rectangle(WIDTH * 44.0 / 280.0, 0.0, (1.0 - 44.0 / 280.0) * WIDTH, (1.0 - 62.0 / 268.0) * HEIGHT);
    public static var VIEW_AREA : Rectangle = CLICK_AREA.clone();
    
    public static var HIDE_SHOW_BUTTON_LOC : Point = new Point(CLICK_AREA.x + 0.5 * CLICK_AREA.width, CLICK_AREA.bottom + 2);
    private static inline var HIDE_SHOW_TIME_SEC : Float = 0.8;
    
    private static inline var MIN_ICON_SIZE : Float = 4;
    
    private var edgeErrorDict : Dynamic = {};
    private var nodeIconDict : Dynamic = {};
    private var currentLevel : Level;
    
    private var backgroundImage : Image;
    private var gameNodeLayer : Sprite;
    private var errorLayer : Sprite;
    private var viewRectLayer : Sprite;
    private var m_clickPane : Quad;  // clickable area  
    private var m_showButton : BasicButton;
    private var m_hideButton : BasicButton;
    private var m_hidden : Bool = true;
    private var m_hiding : Bool = false;  // true if animating up to hide  
    private var m_showing : Bool = false;  // true if animating down to show  
    
    private var m_viewSpaceIndicator : Sprite;
    private var m_viewSpaceQuads : Array<Quad>;
    
    private var m_contentX : Float;
    private var m_contentY : Float;
    private var m_contentScale : Float;
    public var isDirty : Bool;
    
    public function new()
    {
        super();
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml");
        var background : Texture = atlas.getTexture("MapMaximized");
        backgroundImage = new Image(background);
        addChild(backgroundImage);
        
        width = WIDTH;
        height = HEIGHT;
        
        this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
        this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
        
        gameNodeLayer = new Sprite();
        addChild(gameNodeLayer);
        errorLayer = new Sprite();
        addChild(errorLayer);
        viewRectLayer = new Sprite();
        addChild(viewRectLayer);
        m_clickPane = new Quad(CLICK_AREA.width / scaleX, CLICK_AREA.height / scaleY);
        m_clickPane.alpha = 0;
        m_clickPane.x = CLICK_AREA.x / scaleX;
        m_clickPane.y = CLICK_AREA.y / scaleY;
        addChild(m_clickPane);
        
        m_showButton = new MapShowButton();
        m_showButton.addEventListener(Event.TRIGGERED, showMap);
        m_hideButton = new MapHideButton();
        m_hideButton.addEventListener(Event.TRIGGERED, hideMap);
        m_showButton.x = m_hideButton.x = HIDE_SHOW_BUTTON_LOC.x / scaleX;
        m_showButton.y = m_hideButton.y = HIDE_SHOW_BUTTON_LOC.y / scaleY;
        addChild(m_showButton);
        
        isDirty = true;
    }
    
    public function hideMap(evt : Event) : Void
    {
        if (m_hiding)
        {
            return;
        }
        if (m_hidden && !m_showing)
        {
            return;
        }
        // Swap out hide button with show button
        if (m_showButton != null)
        {
            addChild(m_showButton);
        }
        if (m_hideButton != null)
        {
            m_hideButton.removeFromParent();
        }
        // Stop showing animation (if any) and animate this up to hide
        Starling.current.juggler.removeTweens(this);
        m_showing = false;
        m_hiding = true;
        Starling.current.juggler.tween(this, HIDE_SHOW_TIME_SEC, {
                    y : HIDDEN_Y,
                    transition : Transitions.EASE_OUT,
                    onComplete : onHideComplete
                });
    }
    
    private function onHideComplete() : Void
    {
        m_hiding = false;
        m_hidden = true;
    }
    
    public function showMap(evt : Event) : Void
    {
        if (m_showing)
        {
            return;
        }
        if (!m_hidden && !m_hiding)
        {
            return;
        }
        // Swap out show button with hide button
        if (m_hideButton != null)
        {
            addChild(m_hideButton);
        }
        if (m_showButton != null)
        {
            m_showButton.removeFromParent();
        }
        // Stop hiding animation (if any) and animate this down to show
        Starling.current.juggler.removeTweens(this);
        m_hiding = false;
        m_showing = true;
        Starling.current.juggler.tween(this, HIDE_SHOW_TIME_SEC, {
                    y : SHOWN_Y,
                    transition : Transitions.EASE_OUT,
                    onComplete : onShowComplete
                });
    }
    
    private function onShowComplete() : Void
    {
        m_showing = false;
        m_hidden = false;
    }
    
    public function addedToStage(event : starling.events.Event) : Void
    {
        if (m_clickPane != null)
        {
            m_clickPane.addEventListener(TouchEvent.TOUCH, onTouch);
        }
        addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
    }
    
    private function onEnterFrame(event : EnterFrameEvent) : Void
    {
        if (isDirty)
        {
            draw();
        }
    }
    
    public function removedFromStage(event : starling.events.Event) : Void
    {
        if (gameNodeLayer != null)
        {
            gameNodeLayer.removeChildren(0, -1, true);
        }
        if (errorLayer != null)
        {
            errorLayer.removeChildren(0, -1, true);
        }
        if (viewRectLayer != null)
        {
            viewRectLayer.removeChildren(0, -1, true);
        }
        if (m_clickPane != null)
        {
            m_clickPane.removeEventListener(TouchEvent.TOUCH, onTouch);
        }
        removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
    }
    
    override private function onTouch(event : TouchEvent) : Void
    {
        var touches : Vector<Touch> = event.touches;
        if (event.getTouches(this, TouchPhase.ENDED).length > 0 || event.getTouches(this, TouchPhase.MOVED).length > 0)
        {
            var mapPoint : Point = touches[0].getLocation(this);
            var levPct : Point = map2pct(mapPoint);
            trace("levPct:" + levPct);
            // clamp to 0->1
            levPct.x = XMath.clamp(levPct.x, 0.0, 1.0);
            levPct.y = XMath.clamp(levPct.y, 0.0, 1.0);
            dispatchEvent(new MoveEvent(MoveEvent.MOVE_TO_POINT, null, levPct, null));
        }
    }
    
    public function onViewspaceChanged(event : MiniMapEvent) : Void
    {
        m_contentX = event.contentX;
        m_contentY = event.contentY;
        m_contentScale = event.contentScale;
        setLevel(event.level);
    }
    
    public function setLevel(level : Level) : Void
    {
        currentLevel = level;
        drawViewSpaceIndicator();
    }
    
    private function draw() : Void
    {
        if (gameNodeLayer != null)
        {
            gameNodeLayer.removeChildren(0, -1, true);
        }
        if (errorLayer != null)
        {
            errorLayer.removeChildren(0, -1, true);
        }
        if (currentLevel == null)
        {
            return;
        }
        edgeErrorDict = {};
        for (errorId in Reflect.fields(currentLevel.errorConstraintDict))
        {
            var constraint : Constraint = Reflect.field(currentLevel.errorConstraintDict, errorId);
            if (!constraint.isSatisfied() && Reflect.hasField(currentLevel.edgeLayoutObjs, constraint.id))
            {
                var edgeLayout : Dynamic = Reflect.field(currentLevel.edgeLayoutObjs, constraint.id);
                errorConstraintAdded(edgeLayout, false);
            }
        }
        for (id in Reflect.fields(nodeIconDict))
        {
            (try cast(Reflect.field(nodeIconDict, id), Quad) catch(e:Dynamic) null).removeFromParent();
        }
        nodeIconDict = {};
        var nodeDict : Dynamic = currentLevel.nodeLayoutObjs;
        trace("minmap visibleBB:" + visibleBB);
        for (nodeId in Reflect.fields(nodeDict))
        {
            addWidget(Reflect.field(nodeDict, nodeId), false);
            if (nodeId == "var_2")
            {
                for (prop in Reflect.fields(Reflect.field(nodeDict, nodeId)))
                {
                    trace("var_2 " + prop + " = " + Reflect.field(Reflect.field(nodeDict, nodeId), prop));
                }
            }
        }
        drawViewSpaceIndicator();
        isDirty = false;
    }
    
    private function drawViewSpaceIndicator() : Void
    {
        if (m_viewSpaceIndicator == null)
        {
            m_viewSpaceIndicator = new Sprite();
            if (m_viewSpaceQuads == null)
            {
                m_viewSpaceQuads = new Array<Quad>();
                for (i in 0...8)
                {
                    var myq : Quad = new Quad(1, 1, TextBubble.GOLD);
                    m_viewSpaceQuads.push(myq);
                    m_viewSpaceIndicator.addChild(myq);
                }
            }
            viewRectLayer.addChild(m_viewSpaceIndicator);
        }
        
        var viewWidth : Float = (VIEW_AREA.width / scaleX) * (GridViewPanel.WIDTH / m_contentScale) / visibleBB.width;
        var viewHeight : Float = (VIEW_AREA.height / scaleY) * ((GridViewPanel.HEIGHT  /*- GameControlPanel.OVERLAP*/  ) / m_contentScale) / visibleBB.height;
        
        var viewTopLeftInLevelSpace : Point = new Point(-m_contentX / m_contentScale, -m_contentY / m_contentScale);
        var viewTopLeftInMapSpace : Point = level2map(viewTopLeftInLevelSpace);
        var viewX : Float = viewTopLeftInMapSpace.x;
        var viewY : Float = viewTopLeftInMapSpace.y;
        
        // Setup quad crosshairs/frame to indicate view:
        //           |2
        //     ------6-------
        //0----|4           5|------1
        //     ------7-------
        //           |3
        var THICK : Float = 3.0;
        var THIN : Float = 1.0;
        // Crosshairs
        m_viewSpaceQuads[0].x = CLICK_AREA.left / scaleX;
        m_viewSpaceQuads[0].width = Math.max(0, viewX - m_viewSpaceQuads[0].x);
        m_viewSpaceQuads[0].height = m_viewSpaceQuads[1].height = THIN / scaleY;
        m_viewSpaceQuads[0].y = m_viewSpaceQuads[1].y = viewY + 0.5 * viewHeight;
        m_viewSpaceQuads[1].x = viewX + viewWidth;
        m_viewSpaceQuads[1].width = Math.max(0, WIDTH / scaleX - m_viewSpaceQuads[1].x);
        m_viewSpaceQuads[2].y = 0;
        m_viewSpaceQuads[2].height = Math.max(0, viewY);
        m_viewSpaceQuads[2].x = m_viewSpaceQuads[3].x = viewX + 0.5 * viewWidth;
        m_viewSpaceQuads[2].width = m_viewSpaceQuads[3].width = THIN / scaleX;
        m_viewSpaceQuads[3].y = viewY + viewHeight;
        m_viewSpaceQuads[3].height = Math.max(0, CLICK_AREA.bottom / scaleY - m_viewSpaceQuads[3].y);
        m_viewSpaceQuads[0].alpha = m_viewSpaceQuads[1].alpha = m_viewSpaceQuads[2].alpha = m_viewSpaceQuads[3].alpha = 1;
        // Border
        m_viewSpaceQuads[4].x = viewX - 0.5 * THICK / scaleX;
        m_viewSpaceQuads[4].y = m_viewSpaceQuads[5].y = viewY + 0.5 * THICK / scaleY;
        m_viewSpaceQuads[4].width = m_viewSpaceQuads[5].width = THICK / scaleX;
        m_viewSpaceQuads[4].height = m_viewSpaceQuads[5].height = viewHeight - THICK / scaleY;
        m_viewSpaceQuads[5].x = viewX + viewWidth - 0.5 * THICK / scaleX;
        m_viewSpaceQuads[6].x = m_viewSpaceQuads[7].x = viewX - 0.5 * THICK / scaleX;
        m_viewSpaceQuads[6].y = viewY - 0.5 * THICK / scaleY;
        m_viewSpaceQuads[6].width = m_viewSpaceQuads[7].width = viewWidth + THICK / scaleX;
        m_viewSpaceQuads[6].height = m_viewSpaceQuads[7].height = THICK / scaleY;
        m_viewSpaceQuads[7].y = viewY + viewHeight - 0.5 * THICK / scaleY;
        m_viewSpaceQuads[4].alpha = m_viewSpaceQuads[5].alpha = m_viewSpaceQuads[6].alpha = m_viewSpaceQuads[7].alpha = 0.5;
    }
    
    private function get_visibleBB() : Rectangle
    {
        var levelBB : Rectangle = (currentLevel != null) ? currentLevel.m_boundingBox.clone() : new Rectangle();
        levelBB.inflate(0.5 * GridViewPanel.WIDTH / GridViewPanel.MIN_SCALE, 0.5 * GridViewPanel.HEIGHT / GridViewPanel.MIN_SCALE);
        return levelBB;
    }
    
    public function errorConstraintAdded(edgeLayout : Dynamic, flatten : Bool = true) : Void
    {
        if (errorLayer == null)
        {
            return;
        }
        
        var errImage : Image = new Image(ErrorParticleSystem.errorTexture);
        errImage.width = errImage.height = 80;
        errImage.alpha = 0.6;
        errImage.color = 0xFF0000;
        var edgeId : String = Reflect.field(edgeLayout, "id");
        var prevErrorImage : Image = try cast(Reflect.field(edgeErrorDict, edgeId), Image) catch(e:Dynamic) null;
        if (prevErrorImage != null)
        {
            prevErrorImage.removeFromParent(true);
        }
        Reflect.setField(edgeErrorDict, edgeId, errImage);
        
        var bb : Rectangle = try cast(Reflect.field(edgeLayout, "bb"), Rectangle) catch(e:Dynamic) null;
        if (bb == null)
        {
            throw new Error("Tried to add edge error to MiniMap but no bounding box found in edge layout information.");
        }
        var errorLevelPt : Point = new Point(bb.x + 0.5 * bb.width, bb.y + 0.5 * bb.height);
        var errPt : Point = level2map(errorLevelPt);
        
        errImage.x = errPt.x - 0.5 * errImage.width;
        errImage.y = errPt.y - 0.5 * errImage.height;
        
        errorLayer.addChild(errImage);
    }
    
    public function errorRemoved(edgeLayout : Dynamic) : Void
    {
        var edgeId : String = Reflect.field(edgeLayout, "id");
        var errorImage : Image = Reflect.field(edgeErrorDict, edgeId);
        if (errorImage != null)
        {
            errorImage.removeFromParent(true);
        }
		Reflect.deleteField(edgeErrorDict, edgeId);
    }
    
    public function addWidget(widgetLayout : Dynamic, flatten : Bool = true) : Void
    {
        if (gameNodeLayer == null)
        {
            return;
        }
        var id : String = Reflect.field(widgetLayout, "id");
        var bb : Rectangle = try cast(Reflect.field(widgetLayout, "bb"), Rectangle) catch(e:Dynamic) null;
        if (bb == null)
        {
            throw new Error("Tried to add widget to MiniMap but no bounding box found in layout information.");
        }
        var widgetTopLeft : Point = level2map(bb.topLeft);
        var widgetBotRight : Point = level2map(bb.bottomRight);
        var iconWidth : Float = Math.min(2 / scaleX, widgetBotRight.x - widgetTopLeft.x);
        var iconHeight : Float = bb.height / 2.0;  // keep constant height so widgets always visible  
        var constrVar : ConstraintVar = try cast(Reflect.field(widgetLayout, "var"), ConstraintVar) catch(e:Dynamic) null;
        var isNarrow : Bool = constrVar.getProps().hasProp(PropDictionary.PROP_NARROW);
        var icon : Quad = new Quad(Math.max(MIN_ICON_SIZE, iconWidth), Math.max(MIN_ICON_SIZE, iconHeight), (isNarrow) ? GameComponent.NARROW_COLOR : GameComponent.WIDE_COLOR);
        var widgetLevelPt : Point = new Point(bb.x + 0.5 * bb.width, bb.y + 0.5 * bb.height);
        var iconLoc : Point = level2map(widgetLevelPt);
        icon.x = iconLoc.x - 0.5 * icon.width;
        icon.y = iconLoc.y - 0.5 * icon.height;
        //trace("minimap " + id + " bb.topLeft:" + bb.topLeft +" widgetTopLeft:" + widgetTopLeft + " iconLoc:" + iconLoc + " widgetLevelPt:" + widgetLevelPt);
        var prevIcon : Quad = try cast(Reflect.field(nodeIconDict, id), Quad) catch(e:Dynamic) null;
        if (prevIcon != null)
        {
            prevIcon.removeFromParent(true);
        }
        Reflect.setField(nodeIconDict, id, icon);
        
        gameNodeLayer.addChild(icon);
    }
    
    private function level2pct(pt : Point) : Point
    {
        var pct : Point = new Point((pt.x - visibleBB.x) / visibleBB.width, 
        (pt.y - visibleBB.y) / visibleBB.height);
        //pct.x = XMath.clamp(pct.x, 0.0, 1.0);
        //pct.y = XMath.clamp(pct.y, 0.0, 1.0);
        return pct;
    }
    
    private function map2pct(pt : Point) : Point
    {
        var pct : Point = new Point((pt.x - VIEW_AREA.x / scaleX) / (VIEW_AREA.width / scaleX), 
        (pt.y - VIEW_AREA.y / scaleY) / (VIEW_AREA.height / scaleY));
        //pct.x = XMath.clamp(pct.x, 0.0, 1.0);
        //pct.y = XMath.clamp(pct.y, 0.0, 1.0);
        return pct;
    }
    
    private function pct2level(pct : Point) : Point
    {
        var pt : Point = new Point(visibleBB.width * pct.x + visibleBB.x, 
        visibleBB.height * pct.y + visibleBB.y);
        return pt;
    }
    
    private function pct2map(pct : Point) : Point
    {
        var pt : Point = new Point(pct.x * (VIEW_AREA.width / scaleX) + VIEW_AREA.x / scaleX, 
        pct.y * (VIEW_AREA.height / scaleY) + VIEW_AREA.y / scaleY);
        return pt;
    }
    
    private function level2map(pt : Point) : Point
    {
        var pct : Point = level2pct(pt);
        return pct2map(pct);
    }
    private static var MiniMap_static_initializer = {
        {
            VIEW_AREA.inflate(-15.0 * WIDTH / 280.0, -15.0 * HEIGHT / 268.0);
        };
        true;
    }

}
