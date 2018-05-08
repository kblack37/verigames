package scenes.game.components;

import flash.display.BitmapData;
import flash.display.StageDisplayState;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceButton;
import display.ToolTipText;
import events.MenuEvent;
import events.MiniMapEvent;
import events.MouseWheelEvent;
import events.MoveEvent;
import events.NavigationEvent;
import events.PropertyModeChangeEvent;
import events.TutorialEvent;
import events.UndoEvent;
import flash.system.System;
import flash.utils.Dictionary;
import graph.PropDictionary;
import networking.TutorialController;
import openfl.Assets;
import openfl.Vector;
import particle.FanfareParticleSystem;
import scenes.BaseComponent;
import scenes.game.PipeJamGameScene;
import scenes.game.display.GameComponent;
import scenes.game.display.GameEdgeContainer;
import scenes.game.display.GameNode;
import scenes.game.display.Level;
import scenes.game.display.OutlineFilter;
import scenes.game.display.TutorialManagerTextInfo;
import scenes.game.display.World;
import starling.animation.DelayedCall;
import starling.animation.Transitions;
//import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.rendering.Painter;
import starling.textures.Texture;
import utils.XMath;

//GamePanel is the main game play area, with a central sprite and right and bottom scrollbars.
class GridViewPanel extends BaseComponent
{
    public static var WIDTH : Float = Constants.GameWidth;
    public static var HEIGHT : Float = Constants.GameHeight;
    
    private var m_currentLevel : Level;
    private var inactiveContent : Sprite;
    private var contentBarrier : Quad;
    private var content : BaseComponent;
    private var errorBubbleContainer : Sprite;
    private var currentMode : Int;
    private var continueButton : NineSliceButton;
    private var m_border : Image;
    private var m_tutorialText : TutorialText;
    private var m_persistentToolTips : Array<ToolTipText> = new Array<ToolTipText>();
    private var m_continueButtonForced : Bool = false;  //true to force the continue button to display, ignoring score  
    private var m_spotlight : Image;
    private var m_errorTextBubbles : Dynamic = {};
    private var m_nodeLayoutQueue : Array<Dynamic> = new Array<Dynamic>();
    private var m_edgeLayoutQueue : Array<Dynamic> = new Array<Dynamic>();
    
    
    private var m_lastVisibleRefreshViewRect : Rectangle;
    
    private static inline var VISIBLE_BUFFER_PIXELS : Float = 60.0;  // make objects within this many pixels visible, only refresh visible list when we've moved outside of this buffer  
    private static inline var NORMAL_MODE : Int = 0;
    private static inline var MOVING_MODE : Int = 1;
    private static inline var SELECTING_MODE : Int = 2;
    private static inline var RELEASE_SHIFT_MODE : Int = 3;
    public static var MIN_SCALE : Float = 1.0 / Constants.GAME_SCALE;
    private static var MAX_SCALE : Float = 50.0 / Constants.GAME_SCALE;
    private static var STARTING_SCALE : Float = 22.0 / Constants.GAME_SCALE;
    // At scales less than this value (zoomed out), error text is hidden - but arrows remain
    private static var MIN_ERROR_TEXT_DISPLAY_SCALE : Float = 15.0 / Constants.GAME_SCALE;
    
    public function new(world : World)
    {
        super();
        this.alpha = .999;
        
        currentMode = NORMAL_MODE;
        
        
        inactiveContent = new Sprite();
        addChild(inactiveContent);
        
        content = new BaseComponent();
        addChild(content);
        
        errorBubbleContainer = new Sprite();
        addChild(errorBubbleContainer);
        
        var borderTexture : Texture = AssetInterface.getTexture("Game", "BorderVignetteClass");
        m_border = new Image(borderTexture);
        m_border.width = WIDTH;
        m_border.height = HEIGHT;
        m_border.touchable = false;
        addChild(m_border);
        
        contentBarrier = new Quad(width, height, 0x00);
        contentBarrier.alpha = 0.01;
        contentBarrier.visible = true;
        addChildAt(contentBarrier, 0);
        
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    
    private function onAddedToStage() : Void
    {
        addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
        //create a clip rect for the window
        clipRect = new Rectangle(x, y, WIDTH, HEIGHT);
        
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(TouchEvent.TOUCH, onTouch);
        addEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
        if (PipeJam3.REPLAY_DQID == null)
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }
        Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    private function onEnterFrame(evt : EnterFrameEvent) : Void
    {
        if (m_currentLevel == null)
        {
            return;
        }
        var currentViewRect : Rectangle = getViewInContentSpace();
        var movingSelectedComponents : Bool = ((currentMode == MOVING_MODE) && ((m_currentLevel.totalMoveDist.x != 0) || (m_currentLevel.totalMoveDist.y != 0)));
        var offLeft : Float = -VISIBLE_BUFFER_PIXELS;
        var offRight : Float = VISIBLE_BUFFER_PIXELS;
        var offTop : Float = -VISIBLE_BUFFER_PIXELS;
        var offBottom : Float = VISIBLE_BUFFER_PIXELS;
        if (movingSelectedComponents)
        {
        // Take account the distance we've dragged objects, if we may have
            
            // dragged them into the current viewspace, recompute the visibility
            if (m_currentLevel.totalMoveDist.x > 0)
            {
                offLeft += m_currentLevel.totalMoveDist.x;
            }
            else
            {
                offRight += m_currentLevel.totalMoveDist.x;
            }
            if (m_currentLevel.totalMoveDist.y > 0)
            {
                offTop += m_currentLevel.totalMoveDist.y;
            }
            else
            {
                offBottom += m_currentLevel.totalMoveDist.y;
            }
        }
        if (m_lastVisibleRefreshViewRect != null &&
            (currentViewRect.left >= m_lastVisibleRefreshViewRect.left + offLeft) &&
            (currentViewRect.right <= m_lastVisibleRefreshViewRect.right + offRight) &&
            (currentViewRect.top >= m_lastVisibleRefreshViewRect.top + offTop) &&
            (currentViewRect.bottom <= m_lastVisibleRefreshViewRect.bottom + offBottom))
        {  // No need to refresh  
            
        }
        else
        {  //trace("Viewspace changed, refresh needed");  
            
        }
        // Update visible objects
        //if (m_lastVisibleRefreshViewRect) trace("dl:" + int(currentViewRect.left - m_lastVisibleRefreshViewRect.left) +
        //" dr:" + int(currentViewRect.right - m_lastVisibleRefreshViewRect.right) +
        //" dt:" + int(currentViewRect.top - m_lastVisibleRefreshViewRect.top) +
        //" db:" + int(currentViewRect.bottom - m_lastVisibleRefreshViewRect.bottom));
        
        // Create any nodes/edges that need creating
        var NODES_PER_FRAME : Int = 100;
        var i : Int = 0;
        var iters : Int = Std.int(Math.min(NODES_PER_FRAME, m_nodeLayoutQueue.length));
        for (i in 0...iters)
        {
            var nodeLayout : Dynamic = m_nodeLayoutQueue.shift();
        }
        var newNodes : Int = i;
        //if (newNodes > 0) trace("created " + newNodes + " GameNodes");
        var EDGES_PER_FRAME : Int = 50;
        iters = Std.int(Math.min(Math.min(EDGES_PER_FRAME, NODES_PER_FRAME - i), m_edgeLayoutQueue.length));
        for (i in 0...iters)
        {
            var edgeLayout : Dynamic = m_edgeLayoutQueue.shift();
        }
        var newEdges : Int = i;
        //if (newEdges > 0) trace("created " + newEdges + " GameEdgeContainers");
        if (newNodes + newEdges > 0)
        {
            m_currentLevel.draw();
        }
        
        var redraw : Bool = false;
        for (varId in Reflect.fields(m_currentLevel.nodeLayoutObjs))
        {
            var varBB : Rectangle = Reflect.field(Reflect.field(m_currentLevel.nodeLayoutObjs, varId), "bb");
            if (PipeJamGameScene.inTutorial || isOnScreen(varBB, currentViewRect))
            {
                if (m_currentLevel.getNode(varId) == null)
                {
                    m_currentLevel.createNodeFromJsonObj(Reflect.field(m_currentLevel.nodeLayoutObjs, varId));
                    //trace("made " + varId);
                    redraw = true;
                }
            }
            else if (m_currentLevel.getNode(varId) != null)
            {
                m_currentLevel.destroyGameNode(varId);
                //trace("destroyed " + varId);
                redraw = true;
            }
        }
        for (constraintId in Reflect.fields(m_currentLevel.edgeLayoutObjs))
        {
            var edgeBB : Rectangle = Reflect.field(Reflect.field(m_currentLevel.edgeLayoutObjs, constraintId), "bb");
            if (PipeJamGameScene.inTutorial || isOnScreen(edgeBB, currentViewRect))
            {
                if (m_currentLevel.getEdgeContainer(constraintId) == null)
                {
                    m_currentLevel.createEdgeFromJsonObj(Reflect.field(m_currentLevel.edgeLayoutObjs, constraintId));
                    //trace("made " + constraintId);
                    redraw = true;
                }
            }
            else if (m_currentLevel.getEdgeContainer(constraintId) != null)
            {
                m_currentLevel.destroyGameEdge(constraintId);
                //trace("destroyed " + constraintId);
                redraw = true;
            }
        }
        if (redraw)
        {
            m_currentLevel.draw();
        }
        System.gc();
        if ((newEdges > 0 || newNodes > 0) && m_nodeLayoutQueue.length == 0 && m_edgeLayoutQueue.length == 0)
        {
            onGameComponentsCreated();
        }
        // Reset total move dist, now that we've updated the visible objects around this view
        m_currentLevel.totalMoveDist = new Point();
        m_lastVisibleRefreshViewRect = currentViewRect;
    }
    
    private function onGameComponentsCreated() : Void
    {
        var gameEdges : Dynamic = m_currentLevel.getEdges();
        for (edgeId in Reflect.fields(gameEdges))
        {
            var gameEdge : GameEdgeContainer = try cast(Reflect.field(gameEdges, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
            if (!Reflect.hasField(m_errorTextBubbles, edgeId))
            {
                Reflect.setField(m_errorTextBubbles, edgeId, gameEdge.errorTextBubbleContainer);
                errorBubbleContainer.addChild(gameEdge.errorTextBubbleContainer);
            }
        }
        
        var toolTips : Array<TutorialManagerTextInfo> = m_currentLevel.getLevelToolTipsInfo();
        for (i in 0...toolTips.length)
        {
            var tip : ToolTipText = new ToolTipText(toolTips[i].text, m_currentLevel, true, toolTips[i].pointAtFn, toolTips[i].pointFrom, toolTips[i].pointTo);
            addChild(tip);
            m_persistentToolTips.push(tip);
        }
        
        var levelTextInfo : TutorialManagerTextInfo = m_currentLevel.getLevelTextInfo();
        if (levelTextInfo != null)
        {
            m_tutorialText = new TutorialText(m_currentLevel, levelTextInfo);
            addChild(m_tutorialText);
        }
        
        recenter();
    }
    
    private static function isOnScreen(bb : Rectangle, view : Rectangle) : Bool
    {
        if (bb.right < view.left - VISIBLE_BUFFER_PIXELS)
        {
            return false;
        }
        if (bb.left > view.right + VISIBLE_BUFFER_PIXELS)
        {
            return false;
        }
        if (bb.bottom < view.top - VISIBLE_BUFFER_PIXELS)
        {
            return false;
        }
        if (bb.top > view.bottom + VISIBLE_BUFFER_PIXELS)
        {
            return false;
        }
        return true;
    }
    
    private function onPropertyModeChange(evt : PropertyModeChangeEvent) : Void
    {
        if (evt.prop == PropDictionary.PROP_NARROW)
        {
            contentBarrier.visible = false;
        }
        else
        {
            contentBarrier.visible = true;
        }
    }
    
    private function endSelectMode() : Void
    {
        if (m_currentLevel != null)
        {
            m_currentLevel.handleMarquee(null, null);
        }
    }
    
    private function beginMoveMode() : Void
    {
        startingPoint = new Point(content.x, content.y);
    }
    
    private function endMoveMode() : Void
    //did we really move?
    {
        
        if (content.x != startingPoint.x || content.y != startingPoint.y)
        {
            var startPoint : Point = startingPoint.clone();
            var endPoint : Point = new Point(content.x, content.y);
            var eventToUndo : Event = new MoveEvent(MoveEvent.MOUSE_DRAG, null, startPoint, endPoint);
            var eventToDispatch : UndoEvent = new UndoEvent(eventToUndo, this);
            eventToDispatch.addToSimilar = true;
            dispatchEvent(eventToDispatch);
        }
    }
    
    private var startingPoint : Point;
    override private function onTouch(event : TouchEvent) : Void
    //	trace("Mode:" + event.type);
    {
        
        if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            if (currentMode == SELECTING_MODE)
            {
                endSelectMode();
            }
            else if (currentMode == MOVING_MODE)
            {
                endMoveMode();
            }
            if (currentMode != NORMAL_MODE)
            {
                currentMode = NORMAL_MODE;
            }
            else if (m_currentLevel != null && event.target == contentBarrier && World.changingFullScreenState == false)
            {
                m_currentLevel.unselectAll();
                var evt : PropertyModeChangeEvent = new PropertyModeChangeEvent(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, PropDictionary.PROP_NARROW);
                m_currentLevel.onPropertyModeChange(evt);
            }
            else
            {
                World.changingFullScreenState = false;
            }
        }
        else if (event.getTouches(this, TouchPhase.MOVED).length > 0)
        {
            var touches : Vector<Touch> = event.getTouches(this, TouchPhase.MOVED);
            if (event.shiftKey)
            {
                if (currentMode != SELECTING_MODE)
                {
                    if (currentMode == MOVING_MODE)
                    {
                        endMoveMode();
                    }
                    currentMode = SELECTING_MODE;
                    startingPoint = touches[0].getPreviousLocation(this);
                }
                if (m_currentLevel != null)
                {
                    var currentPoint : Point = touches[0].getLocation(this);
                    var globalStartingPt : Point = localToGlobal(startingPoint);
                    var globalCurrentPt : Point = localToGlobal(currentPoint);
                    m_currentLevel.handleMarquee(globalStartingPt, globalCurrentPt);
                }
            }
            else
            {
                if (currentMode != MOVING_MODE)
                {
                    if (currentMode == SELECTING_MODE)
                    {
                        endSelectMode();
                    }
                    currentMode = MOVING_MODE;
                    beginMoveMode();
                }
                if (touches.length == 1)
                {
                // one finger touching -> move
                    
                    if (touches[0].target == contentBarrier)
                    {
                        if (getPanZoomAllowed())
                        {
                            var delta : Point = touches[0].getMovement(parent);
                            var viewRect : Rectangle = getViewInContentSpace();
                            var newX : Float = viewRect.x + viewRect.width / 2 - delta.x / content.scaleX;
                            var newY : Float = viewRect.y + viewRect.height / 2 - delta.y / content.scaleY;
                            moveContent(newX, newY);
                        }
                    }
                }
                else if (touches.length == 2)
                {  /*
						// TODO: Need to take a look at this if we reactivate multitouch - hasn't been touched in a while 
						// two fingers touching -> rotate and scale
						var touchA:Touch = touches[0];
						var touchB:Touch = touches[1];
						
						var currentPosA:Point  = touchA.getLocation(parent);
						var previousPosA:Point = touchA.getPreviousLocation(parent);
						var currentPosB:Point  = touchB.getLocation(parent);
						var previousPosB:Point = touchB.getPreviousLocation(parent);
						
						var currentVector:Point  = currentPosA.subtract(currentPosB);
						var previousVector:Point = previousPosA.subtract(previousPosB);
						
						var currentAngle:Number  = Math.atan2(currentVector.y, currentVector.x);
						var previousAngle:Number = Math.atan2(previousVector.y, previousVector.x);
						var deltaAngle:Number = currentAngle - previousAngle;
						
						// update pivot point based on previous center
						var previousLocalA:Point  = touchA.getPreviousLocation(this);
						var previousLocalB:Point  = touchB.getPreviousLocation(this);
						pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
						pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
						
						// update location based on the current center
						x = (currentPosA.x + currentPosB.x) * 0.5;
						y = (currentPosA.y + currentPosB.y) * 0.5;
						
						// rotate
						//	rotation += deltaAngle;
						
						// scale
						var sizeDiff:Number = currentVector.length / previousVector.length;
						
						scaleContent(sizeDiff);
						m_currentLevel.updateVisibleList();
	//					var currentCenterPt:Point = new Point((currentPosA.x+currentPosB.x)/2 +content.x, (currentPosA.y+currentPosB.y)/2+content.y);
	//					content.x = currentCenterPt.x - previousCenterPt.x;
	//					content.y = currentCenterPt.y - previousCenterPt.y;
						*/  
                    
                }
            }
        }
    }
    
    private function onMouseWheel(evt : MouseEvent) : Void
    {
        var delta : Float = evt.delta;
        var localMouse : Point = this.globalToLocal(new Point(evt.stageX, evt.stageY));
        handleMouseWheel(delta, localMouse);
    }
    
    private function handleMouseWheel(delta : Float, localMouse : Point = null, createUndoEvent : Bool = true) : Void
    {
		var mousePoint : Point = null;
        if (!getPanZoomAllowed())
        {
            return;
        }
        if (localMouse == null)
        {
            localMouse = new Point(WIDTH / 2, HEIGHT / 2);
        }
        else
        {
            mousePoint = localMouse.clone();
            
            var native2Starling : Point = new Point(Starling.current.stage.stageWidth / Starling.current.nativeStage.stageWidth, 
            Starling.current.stage.stageHeight / Starling.current.nativeStage.stageHeight);
            
            localMouse.x *= native2Starling.x;
            localMouse.y *= native2Starling.y;
        }
        
        // Now localSpace is in local coordinates (relative to this instance of GridViewPanel).
        // Next, we'll convert to content space
        var prevMouse : Point = new Point(localMouse.x - content.x, localMouse.y - content.y);
        prevMouse.x /= content.scaleX;
        prevMouse.y /= content.scaleY;
        
        // Now we have the mouse location in current content space.
        // We want this location to not move after scaling
        
        // Scale content
        scaleContent(1.00 + 2 * delta / 100.0, 1.00 + 2 * delta / 100.0);
        
        // Calculate new location of previous mouse
        var newMouse : Point = new Point(localMouse.x - content.x, localMouse.y - content.y);
        newMouse.x /= content.scaleX;
        newMouse.y /= content.scaleY;
        
        // Move by offset so that the point the mouse is centered on remains in same place
        // (scaling is performed relative to this location)
        var viewRect : Rectangle = getViewInContentSpace();
        var newX : Float = viewRect.x + viewRect.width / 2 + (prevMouse.x - newMouse.x);  // / content.scaleX;  
        var newY : Float = viewRect.y + viewRect.height / 2 + (prevMouse.y - newMouse.y);  // / content.scaleY;  
        moveContent(newX, newY);
        
        //turn this off if in an undo event
        if (createUndoEvent)
        {
            var eventToUndo : MouseWheelEvent = new MouseWheelEvent(mousePoint, delta, Date.now().getTime());
            var eventToDispatch : UndoEvent = new UndoEvent(eventToUndo, this);
            eventToDispatch.addToSimilar = true;
            dispatchEvent(eventToDispatch);
        }
    }
    
    private function moveContent(newX : Float, newY : Float) : Void
    {
        newX = XMath.clamp(newX, m_currentLevel.m_boundingBox.x, m_currentLevel.m_boundingBox.x + m_currentLevel.m_boundingBox.width);
        newY = XMath.clamp(newY, m_currentLevel.m_boundingBox.y, m_currentLevel.m_boundingBox.y + m_currentLevel.m_boundingBox.height);
        
        panTo(newX, newY);
    }
    
    public function atMinZoom(scale : Point = null) : Bool
    {
        if (scale == null)
        {
            scale = new Point(content.scaleX, content.scaleY);
        }
        return ((scale.x <= MIN_SCALE) || (scale.y <= MIN_SCALE));
    }
    
    public function atMaxZoom(scale : Point = null) : Bool
    {
        if (scale == null)
        {
            scale = new Point(content.scaleX, content.scaleY);
        }
        return ((scale.x >= MAX_SCALE) || (scale.y >= MAX_SCALE));
    }
    
    /**
		 * Scale the content by the given scale factor (sizeDiff of 1.5 = 150% the original size)
		 * @param	sizeDiff Size difference factor, 1.5 = 150% of original size
		 */
    private function scaleContent(sizeDiffX : Float, sizeDiffY : Float) : Void
    {
        var oldScaleX : Float = content.scaleX;
        var oldScaleY : Float = content.scaleY;
        var newScaleX : Float = XMath.clamp(content.scaleX * sizeDiffX, MIN_SCALE, MAX_SCALE);
        var newScaleY : Float = XMath.clamp(content.scaleY * sizeDiffY, MIN_SCALE, MAX_SCALE);
        
        //if one of these got capped, scale the other proportionally
        if (newScaleX == MAX_SCALE || newScaleY == MAX_SCALE)
        {
            if (newScaleX > newScaleY)
            {
                sizeDiffX = newScaleX / content.scaleX;
                newScaleY = content.scaleY * sizeDiffX;
            }
            else
            {
                sizeDiffX = newScaleX / content.scaleX;
                newScaleY = content.scaleY * sizeDiffX;
            }
        }
        
        var origViewCoords : Rectangle = getViewInContentSpace();
        // Perform scaling
        var oldScale : Point = new Point(content.scaleX, content.scaleY);
        content.scaleX = newScaleX;
        content.scaleY = newScaleY;
        inactiveContent.scaleX = content.scaleX;
        inactiveContent.scaleY = content.scaleY;
        onContentScaleChanged(oldScale);
        
        var newViewCoords : Rectangle = getViewInContentSpace();
        
        // Adjust so that original centered point is still in the middle
        var dX : Float = origViewCoords.x + origViewCoords.width / 2 - (newViewCoords.x + newViewCoords.width / 2);
        var dY : Float = origViewCoords.y + origViewCoords.height / 2 - (newViewCoords.y + newViewCoords.height / 2);
        
        content.x -= dX * content.scaleX;
        content.y -= dY * content.scaleY;
        inactiveContent.x = content.x;
        inactiveContent.y = content.y;
    }
    
    private function onContentScaleChanged(prevScale : Point) : Void
    {
        if (atMaxZoom())
        {
            if (!atMaxZoom(prevScale))
            {
                dispatchEvent(new MenuEvent(MenuEvent.MAX_ZOOM_REACHED));
            }
        }
        else if (atMinZoom())
        {
            if (!atMinZoom(prevScale))
            {
                dispatchEvent(new MenuEvent(MenuEvent.MIN_ZOOM_REACHED));
            }
        }
        else if (atMaxZoom(prevScale) || atMinZoom(prevScale))
        {
            dispatchEvent(new MenuEvent(MenuEvent.RESET_ZOOM));
        }
        
        if (m_currentLevel == null)
        {
            return;
        }
        if ((content.scaleX < MIN_ERROR_TEXT_DISPLAY_SCALE) || (content.scaleY < MIN_ERROR_TEXT_DISPLAY_SCALE))
        {
            m_currentLevel.hideErrorText();
        }
        else
        {
            m_currentLevel.showErrorText();
        }
    }
    
    //returns a point containing the content scale factors
    public function getContentScale() : Point
    {
        return new Point(content.scaleX, content.scaleY);
    }
    
    private function getViewInContentSpace() : Rectangle
    {
        return new Rectangle(-content.x / content.scaleX, -content.y / content.scaleY, clipRect.width / content.scaleX, clipRect.height / content.scaleY);
    }
    
    private function onRemovedFromStage() : Void
    {
        removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
    }
    
    override public function dispose() : Void
    {
        if (m_disposed)
        {
            return;
        }
        if (m_tutorialText != null)
        {
            m_tutorialText.removeFromParent(true);
            m_tutorialText = null;
        }
        for (i in 0...m_persistentToolTips.length)
        {
            m_persistentToolTips[i].removeFromParent(true);
        }
        m_persistentToolTips = new Array<ToolTipText>();
        if (Starling.current != null && Starling.current.nativeStage != null)
        {
            Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        content.removeEventListener(TouchEvent.TOUCH, onTouch);
        removeEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
        if (stage != null)
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }
        super.dispose();
    }
    
    public function zoomInDiscrete() : Void
    {
        handleMouseWheel(5);
    }
    
    public function zoomOutDiscrete() : Void
    {
        handleMouseWheel(-5);
    }
    
    private function onKeyDown(event : KeyboardEvent) : Void
    {
        var viewRect : Rectangle;
        var newX : Float;
        var newY : Float;
        var MOVE_PX : Float = 5.0;  // pixels to move when arrow keys pressed  
        var _sw0_ = (event.keyCode);        

        switch (_sw0_)
        {
            case Keyboard.TAB:
                if (getPanZoomAllowed() && m_currentLevel != null)
                {
                    var conflict : DisplayObject = m_currentLevel.getNextConflict(!event.shiftKey);
                    if (conflict != null)
                    {
                        centerOnComponent(conflict);
                    }
                }
            case Keyboard.UP, Keyboard.W, Keyboard.NUMPAD_8:
                if (getPanZoomAllowed())
                {
                    viewRect = getViewInContentSpace();
                    newX = viewRect.x + viewRect.width / 2;
                    newY = viewRect.y + viewRect.height / 2 - MOVE_PX / content.scaleY;
                    moveContent(newX, newY);
                }
            case Keyboard.DOWN, Keyboard.S, Keyboard.NUMPAD_2:
                if (getPanZoomAllowed())
                {
                    viewRect = getViewInContentSpace();
                    newX = viewRect.x + viewRect.width / 2;
                    newY = viewRect.y + viewRect.height / 2 + MOVE_PX / content.scaleY;
                    moveContent(newX, newY);
                }
            case Keyboard.LEFT, Keyboard.A, Keyboard.NUMPAD_4:
                if (getPanZoomAllowed())
                {
                    viewRect = getViewInContentSpace();
                    newX = viewRect.x + viewRect.width / 2 - MOVE_PX / content.scaleX;
                    newY = viewRect.y + viewRect.height / 2;
                    moveContent(newX, newY);
                }
            case Keyboard.RIGHT, Keyboard.D, Keyboard.NUMPAD_6:
                if (getPanZoomAllowed())
                {
                    viewRect = getViewInContentSpace();
                    newX = viewRect.x + viewRect.width / 2 + MOVE_PX / content.scaleX;
                    newY = viewRect.y + viewRect.height / 2;
                    moveContent(newX, newY);
                }
            case Keyboard.C:
                if (event.ctrlKey)
                {
                    World.m_world.solverDoneCallback("");
                }
            case Keyboard.EQUAL, Keyboard.NUMPAD_ADD:
                zoomInDiscrete();
            case Keyboard.MINUS, Keyboard.NUMPAD_SUBTRACT:
                zoomOutDiscrete();
            case Keyboard.SPACE:
                recenter();
            case Keyboard.DELETE:
                if (m_currentLevel != null)
                {
                    m_currentLevel.onDeletePressed();
                }
            case Keyboard.QUOTE:
                if (m_currentLevel != null)
                {
                    if (event.shiftKey)
                    {
                        m_currentLevel.onUseSelectionPressed(MenuEvent.MAKE_SELECTION_WIDE);
                    }
                    else
                    {
                        m_currentLevel.onUseSelectionPressed(MenuEvent.MAKE_SELECTION_NARROW);
                    }
                }
        }
    }
    
    private function onKeyUp(event : KeyboardEvent) : Void
    // Release shift, temporarily enter this mode until next touch
    {
        
        // (this prevents the user from un-selecting when they perform
        // a shift + click + drag + unshift + unclick sequence
        if (currentMode == SELECTING_MODE && !event.shiftKey)
        {
            endSelectMode();
            currentMode = RELEASE_SHIFT_MODE;
        }
    }
    
    private var m_boundingBoxDebug : Quad;
    private static var DEBUG_BOUNDING_BOX : Bool = false;
    public function setupLevel(level : Level) : Void
    {
        m_continueButtonForced = false;
        removeFanfare();
        hideContinueButton();
        removeSpotlight();
        if (m_currentLevel != level)
        {
            if (m_currentLevel != null)
            {
                m_currentLevel.removeEventListener(TouchEvent.TOUCH, onTouch);
                m_currentLevel.removeEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onLevelViewChanged);
                content.removeChild(m_currentLevel);
                if (m_currentLevel.tutorialManager != null)
                {
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.SHOW_CONTINUE, displayContinueButton);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.HIGHLIGHT_BOX, onHighlightTutorialEvent);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.HIGHLIGHT_EDGE, onHighlightTutorialEvent);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.HIGHLIGHT_PASSAGE, onHighlightTutorialEvent);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.HIGHLIGHT_CLASH, onHighlightTutorialEvent);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.HIGHLIGHT_SCOREBLOCK, onHighlightTutorialEvent);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.NEW_TUTORIAL_TEXT, onTutorialTextChange);
                    m_currentLevel.tutorialManager.removeEventListener(TutorialEvent.NEW_TOOLTIP_TEXT, onPersistentToolTipTextChange);
                }
            }
            m_currentLevel = level;
        }
        
        inactiveContent.removeChildren();
        inactiveContent.addChild(m_currentLevel.inactiveLayer);
        
        // Remove old error text containers and place new ones
        for (errorEdgeId in Reflect.fields(m_errorTextBubbles))
        {
            var errorSprite : Sprite = Reflect.field(m_errorTextBubbles, errorEdgeId);
            errorSprite.removeFromParent();
        }
        m_errorTextBubbles = {};
        
        if (m_tutorialText != null)
        {
            m_tutorialText.removeFromParent(true);
            m_tutorialText = null;
        }
        for (i in 0...m_persistentToolTips.length)
        {
            m_persistentToolTips[i].removeFromParent(true);
        }
        m_persistentToolTips = new Array<ToolTipText>();
        
        content.addChild(m_currentLevel);
    }
    
    public function loadLevel() : Void
    {
        m_currentLevel.addEventListener(TouchEvent.TOUCH, onTouch);
        m_currentLevel.addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onLevelViewChanged);
        if (m_currentLevel.tutorialManager != null)
        {
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.SHOW_CONTINUE, displayContinueButton);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.HIGHLIGHT_BOX, onHighlightTutorialEvent);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.HIGHLIGHT_EDGE, onHighlightTutorialEvent);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.HIGHLIGHT_PASSAGE, onHighlightTutorialEvent);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.HIGHLIGHT_CLASH, onHighlightTutorialEvent);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.HIGHLIGHT_SCOREBLOCK, onHighlightTutorialEvent);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.NEW_TUTORIAL_TEXT, onTutorialTextChange);
            m_currentLevel.tutorialManager.addEventListener(TutorialEvent.NEW_TOOLTIP_TEXT, onPersistentToolTipTextChange);
        }
        
        // Queue all nodes/edges to add (later we can refine to only on-screen
        for (nodeId in Reflect.fields(m_currentLevel.nodeLayoutObjs))
        {
            var nodeLayoutObj : Dynamic = Reflect.field(m_currentLevel.nodeLayoutObjs, nodeId);
            m_nodeLayoutQueue.push(nodeLayoutObj);
        }
        var edgeId : String;
        for (edgeId in Reflect.fields(m_currentLevel.edgeLayoutObjs))
        {
            var edgeLayoutObj : Dynamic = Reflect.field(m_currentLevel.edgeLayoutObjs, edgeId);
            m_edgeLayoutQueue.push(edgeLayoutObj);
        }
    }
    
    public function onTutorialTextChange(evt : TutorialEvent) : Void
    {
        if (m_tutorialText != null)
        {
            m_tutorialText.removeFromParent(true);
            m_tutorialText = null;
        }
        
        var levelTextInfo : TutorialManagerTextInfo = ((evt.newTextInfo.length == 1)) ? evt.newTextInfo[0] : null;
        if (levelTextInfo != null)
        {
            m_tutorialText = new TutorialText(m_currentLevel, levelTextInfo);
            addChild(m_tutorialText);
        }
    }
    
    public function onPersistentToolTipTextChange(evt : TutorialEvent) : Void
    {
        var i : Int;
        for (i in 0...m_persistentToolTips.length)
        {
            m_persistentToolTips[i].removeFromParent(true);
        }
        m_persistentToolTips = new Array<ToolTipText>();
        
        var toolTips : Array<TutorialManagerTextInfo> = m_currentLevel.getLevelToolTipsInfo();
        for (i in 0...toolTips.length)
        {
            var tip : ToolTipText = new ToolTipText(toolTips[i].text, m_currentLevel, true, toolTips[i].pointAtFn, toolTips[i].pointFrom, toolTips[i].pointTo);
            addChild(tip);
            m_persistentToolTips.push(tip);
        }
    }
    
    private function onLevelViewChanged(evt : MiniMapEvent) : Void
    {
        dispatchEvent(new MiniMapEvent(MiniMapEvent.VIEWSPACE_CHANGED, content.x, content.y, content.scaleX, m_currentLevel));
    }
    
    public function recenter() : Void
    {
        content.x = 0;
        content.y = 0;
        inactiveContent.x = inactiveContent.y = 0;
        var oldScale : Point = new Point(content.scaleX, content.scaleY);
        content.scaleX = content.scaleY = STARTING_SCALE;
        inactiveContent.scaleX = inactiveContent.scaleY = STARTING_SCALE;
        onContentScaleChanged(oldScale);
        content.addChild(m_currentLevel);
        
        if (DEBUG_BOUNDING_BOX)
        {
            if (m_boundingBoxDebug == null)
            {
                m_boundingBoxDebug = new Quad(m_currentLevel.m_boundingBox.width, m_currentLevel.m_boundingBox.height, 0xFFFF00);
                m_boundingBoxDebug.alpha = 0.2;
                m_boundingBoxDebug.touchable = false;
                content.addChild(m_boundingBoxDebug);
            }
            else
            {
                m_boundingBoxDebug.width = m_currentLevel.m_boundingBox.width;
                m_boundingBoxDebug.height = m_currentLevel.m_boundingBox.height;
            }
            m_boundingBoxDebug.x = m_currentLevel.m_boundingBox.x;
            m_boundingBoxDebug.y = m_currentLevel.m_boundingBox.y;
        }
        else if (m_boundingBoxDebug != null)
        {
            m_boundingBoxDebug.removeFromParent(true);
        }
        
        var i : Int;
        var centerPt : Point;
        var globPt : Point;
        var localPt : Point;
        var VIEW_HEIGHT : Float = HEIGHT - GameControlPanel.OVERLAP;
        if ((m_currentLevel.m_boundingBox.width * content.scaleX < MAX_SCALE * WIDTH) && (m_currentLevel.m_boundingBox.height * content.scaleX < MAX_SCALE * VIEW_HEIGHT))
        {
        // If about the size of the window, just center the level
            
            centerPt = new Point(m_currentLevel.m_boundingBox.left + m_currentLevel.m_boundingBox.width / 2, m_currentLevel.m_boundingBox.top + m_currentLevel.m_boundingBox.height / 2);
            globPt = m_currentLevel.localToGlobal(centerPt);
            localPt = content.globalToLocal(globPt);
            moveContent(localPt.x, localPt.y);
        }
        // Otherwise center on the first visible box
        else
        {
            
            var nodes : Dynamic = m_currentLevel.getNodes();
            var foundNode : GameNode = null;
            for (nodeId in Reflect.fields(nodes))
            {
                var gameNode : GameNode = try cast(Reflect.field(nodes, nodeId), GameNode) catch(e:Dynamic) null;
                if (gameNode.visible && (gameNode.alpha > 0) && gameNode.parent != null)
                {
                    foundNode = gameNode;
                    break;
                }
            }
            if (foundNode != null)
            {
                centerOnComponent(foundNode);
            }
        }
        var BUFFER : Float = 1.5;
        var newScale : Float = Math.min(WIDTH / (BUFFER * m_currentLevel.m_boundingBox.width * content.scaleX), 
                VIEW_HEIGHT / (BUFFER * m_currentLevel.m_boundingBox.height * content.scaleY)
        );
        scaleContent(newScale, newScale);
        
        if (m_currentLevel != null && m_currentLevel.tutorialManager != null)
        {
            var startPtOffset : Point = m_currentLevel.tutorialManager.getStartPanOffset();
            content.x += startPtOffset.x * content.scaleX;
            content.y += startPtOffset.y * content.scaleY;
            inactiveContent.x = content.x;
            inactiveContent.y = content.y;
            newScale = m_currentLevel.tutorialManager.getStartScaleFactor();
            scaleContent(newScale, newScale);
        }
        
        dispatchEvent(new MiniMapEvent(MiniMapEvent.VIEWSPACE_CHANGED, content.x, content.y, content.scaleX, m_currentLevel));
    }
    
    private var m_fanfareContainer : Sprite = new Sprite();
    private var m_fanfare : Array<FanfareParticleSystem> = new Array<FanfareParticleSystem>();
    private var m_fanfareTextContainer : Sprite = new Sprite();
    private var m_stopFanfareDelayedCallId : Int;
    public function displayContinueButton(permanently : Bool = false) : Void
    {
        if (permanently)
        {
            m_continueButtonForced = true;
        }
        if (continueButton == null)
        {
            continueButton = ButtonFactory.getInstance().createDefaultButton("Next Level", 128, 32);
            continueButton.addEventListener(Event.TRIGGERED, onNextLevelButtonTriggered);
            continueButton.x = WIDTH - continueButton.width - 5;
            continueButton.y = HEIGHT - continueButton.height - 20 - GameControlPanel.OVERLAP;
        }
        
        if (!m_currentLevel.targetScoreReached)
        {
            m_currentLevel.targetScoreReached = true;
            if (PipeJamGameScene.inTutorial)
            {
                addChild(continueButton);
            }
            
            // Fanfare
            removeFanfare();
            addChild(m_fanfareContainer);
            m_fanfareContainer.x = m_fanfareTextContainer.x = WIDTH / 2 - continueButton.width / 2;
            m_fanfareContainer.y = m_fanfareTextContainer.y = continueButton.y - continueButton.height;
            
            var levelCompleteText : String = (PipeJamGameScene.inTutorial) ? "Level Complete!" : "Great work!\nBut keep playing to further improve your score.";
            var textWidth : Float = (PipeJamGameScene.inTutorial) ? continueButton.width : 208;
            
            var i : Int = 5;
            while (i <= textWidth - 5)
            {
                var fanfare : FanfareParticleSystem = new FanfareParticleSystem();
                fanfare.x = i;
                fanfare.y = continueButton.height / 2;
                fanfare.scaleX = fanfare.scaleY = 0.4;
                m_fanfare.push(fanfare);
                m_fanfareContainer.addChild(fanfare);
                i += 10;
            }
            
            startFanfare();
            var LEVEL_COMPLETE_TEXT_MOVE_SEC : Float = (PipeJamGameScene.inTutorial) ? 2.0 : 0.0;
            var LEVEL_COMPLETE_TEXT_FADE_SEC : Float = (PipeJamGameScene.inTutorial) ? 0.0 : 1.0;
            var LEVEL_COMPLETE_TEXT_PAUSE_SEC : Float = (PipeJamGameScene.inTutorial) ? 1.0 : 5.0;
            var textField : TextFieldWrapper = TextFactory.getInstance().createTextField(levelCompleteText, "_sans", textWidth, continueButton.height, 16, 0xFFEC00);
            if (!PipeJam3.DISABLE_FILTERS)
            {
                TextFactory.getInstance().updateFilter(textField, OutlineFilter.getOutlineFilter());
            }
            m_fanfareTextContainer.addChild(textField);
            m_fanfareTextContainer.alpha = 1;
            addChild(m_fanfareTextContainer);
            
            if (PipeJamGameScene.inTutorial)
            {
            // For tutorial, move text and button off to the side
                
                var origX : Float = m_fanfareTextContainer.x;
                var origY : Float = m_fanfareTextContainer.y;
                for (i in 0...m_fanfare.length)
                {
                    Starling.current.juggler.tween(m_fanfare[i], LEVEL_COMPLETE_TEXT_MOVE_SEC, {
                                delay : LEVEL_COMPLETE_TEXT_PAUSE_SEC,
                                particleX : (continueButton.x - origX),
                                particleY : (continueButton.y - continueButton.height - origY),
                                transition : Transitions.EASE_OUT
                            });
                }
                Starling.current.juggler.tween(m_fanfareTextContainer, LEVEL_COMPLETE_TEXT_MOVE_SEC, {
                            delay : LEVEL_COMPLETE_TEXT_PAUSE_SEC,
                            x : continueButton.x,
                            y : continueButton.y - continueButton.height,
                            transition : Transitions.EASE_OUT
                        });
            }
            // For real levels, gradually fade out text
            else
            {
                
                Starling.current.juggler.tween(m_fanfareTextContainer, LEVEL_COMPLETE_TEXT_FADE_SEC, {
                            delay : LEVEL_COMPLETE_TEXT_PAUSE_SEC,
                            alpha : 0,
                            transition : Transitions.EASE_IN
                        });
            }
            m_stopFanfareDelayedCallId = Starling.current.juggler.delayCall(stopFanfare, LEVEL_COMPLETE_TEXT_PAUSE_SEC + LEVEL_COMPLETE_TEXT_MOVE_SEC + LEVEL_COMPLETE_TEXT_FADE_SEC - 0.5);
        }
        
        if (PipeJamGameScene.inTutorial)
        {
            TutorialController.getTutorialController().addCompletedTutorial(m_currentLevel.m_tutorialTag, true);
        }
    }
    
    private function startFanfare() : Void
    {
        for (i in 0...m_fanfare.length)
        {
            m_fanfare[i].start();
        }
    }
    
    private function stopFanfare() : Void
    {
        for (i in 0...m_fanfare.length)
        {
            m_fanfare[i].stop();
        }
    }
    
    public function removeFanfare() : Void
    {
        if (m_stopFanfareDelayedCallId != null)
        {
            Starling.current.juggler.removeByID(m_stopFanfareDelayedCallId);
        }
        for (i in 0...m_fanfare.length)
        {
            m_fanfare[i].removeFromParent(true);
        }
        m_fanfare = new Array<FanfareParticleSystem>();
        if (m_fanfareContainer != null)
        {
            m_fanfareContainer.removeFromParent();
        }
        if (m_fanfareTextContainer != null)
        {
            Starling.current.juggler.removeTweens(m_fanfareTextContainer);
            m_fanfareTextContainer.removeFromParent();
        }
    }
    
    public function hideContinueButton(forceOff : Bool = false) : Void
    {
        if (forceOff)
        {
            m_continueButtonForced = false;
        }
        if (continueButton != null && !m_continueButtonForced)
        {
            continueButton.removeFromParent();
        }
    }
    
    private function onNextLevelButtonTriggered(evt : Event) : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.SWITCH_TO_NEXT_LEVEL));
    }
    
    public function moveToPoint(percentPoint : Point) : Void
    {
        var contentX : Float = m_currentLevel.m_boundingBox.x / scaleX + percentPoint.x * m_currentLevel.m_boundingBox.width / scaleX;
        var contentY : Float = m_currentLevel.m_boundingBox.y / scaleY + percentPoint.y * m_currentLevel.m_boundingBox.height / scaleY;
        moveContent(contentX, contentY);
    }
    
    /**
		 * Pans the current view to the given point (point is in content-space)
		 * @param	panX
		 * @param	panY
		 */
    public function panTo(panX : Float, panY : Float, createUndoEvent : Bool = true) : Void
    {
        content.x = (-panX * content.scaleX + clipRect.width / 2);
        inactiveContent.x = content.x;
        content.y = (-panY * content.scaleY + clipRect.height / 2);
        inactiveContent.y = content.y;
        dispatchEvent(new MiniMapEvent(MiniMapEvent.VIEWSPACE_CHANGED, content.x, content.y, content.scaleX, m_currentLevel));
    }
    
    /**
		 * Centers the current view on the input component
		 * @param	component
		 */
    public function centerOnComponent(component : DisplayObject) : Void
    {
        startingPoint = new Point(content.x, content.y);
        
        var centerPt : Point = new Point(component.width / 2, component.height / 2);
        var globPt : Point = component.localToGlobal(centerPt);
        var localPt : Point = content.globalToLocal(globPt);
        moveContent(localPt.x, localPt.y);
        
        var startPoint : Point = startingPoint.clone();
        var endPoint : Point = new Point(content.x, content.y);
        var eventToUndo : MoveEvent = new MoveEvent(MoveEvent.MOUSE_DRAG, null, startPoint, endPoint);
        var eventToDispatch : UndoEvent = new UndoEvent(eventToUndo, this);
        dispatchEvent(eventToDispatch);
    }
    
    public function onHighlightTutorialEvent(evt : TutorialEvent) : Void
    {
        if (!evt.highlightOn)
        {
            removeSpotlight();
            return;
        }
        if (m_currentLevel == null)
        {
            return;
        }
        var edge : GameEdgeContainer;
        var _sw1_ = (evt.type);        

        switch (_sw1_)
        {
            case TutorialEvent.HIGHLIGHT_BOX:
                var node : GameNode = m_currentLevel.getNode(evt.componentId);
                if (node != null)
                {
                    spotlightComponent(node);
                }
            case TutorialEvent.HIGHLIGHT_EDGE:
                edge = m_currentLevel.getEdgeContainer(evt.componentId);
                if (edge != null)
                {
                    spotlightComponent(edge, 3.0, 1.75, 1.2);
                }
            case TutorialEvent.HIGHLIGHT_PASSAGE:
                edge = m_currentLevel.getEdgeContainer(evt.componentId);
                if (edge != null && edge.innerFromBoxSegment != null)
                {
                    spotlightComponent(edge.innerFromBoxSegment, 3.0, 3, 2);
                }
            case TutorialEvent.HIGHLIGHT_CLASH:
                edge = m_currentLevel.getEdgeContainer(evt.componentId);
                if (edge != null && edge.errorContainer != null)
                {
                    spotlightComponent(edge.errorContainer, 3.0, 1.3, 1.3);
                }
        }
    }
    
    private function removeSpotlight() : Void
    {
        if (m_spotlight != null)
        {
            m_spotlight.removeFromParent();
        }
    }
    
    public function spotlightComponent(component : DisplayObject, timeSec : Float = 3.0, widthScale : Float = 1.75, heightScale : Float = 1.75) : Void
    {
        if (m_currentLevel == null)
        {
            return;
        }
        startingPoint = new Point(content.x, content.y);
        var bounds : Rectangle = component.getBounds(component);
        var centerPt : Point = new Point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
        var globPt : Point = component.localToGlobal(centerPt);
        var localPt : Point = content.globalToLocal(globPt);
        
        if (m_spotlight == null)
        {
			//var spotlightTexture : Texture = AssetInterface.getTexture("Game", "SpotlightClass");TODO remove if works
            var spotlightTexture : Texture = AssetInterface.getTexture("Game", "Spotlight");
            m_spotlight = new Image(spotlightTexture);
            m_spotlight.touchable = false;
            m_spotlight.alpha = 0.3;
        }
        m_spotlight.width = component.width * widthScale;
        m_spotlight.height = component.height * heightScale;
        m_spotlight.x = m_currentLevel.m_boundingBox.x - Constants.GameWidth / 2;
        m_spotlight.y = m_currentLevel.m_boundingBox.y - Constants.GameHeight / 2;
        content.addChild(m_spotlight);
        var destX : Float = localPt.x - m_spotlight.width / 2;
        var destY : Float = localPt.y - m_spotlight.height / 2;
        Starling.current.juggler.removeTweens(m_spotlight);
        Starling.current.juggler.tween(m_spotlight, 0.9 * timeSec, {
                    delay : 0.1 * timeSec,
                    x : destX,
                    transition : Transitions.EASE_OUT_ELASTIC
                });
        Starling.current.juggler.tween(m_spotlight, timeSec, {
                    delay : 0,
                    y : destY,
                    transition : Transitions.EASE_OUT_ELASTIC
                });
    }
    
    override public function handleUndoEvent(undoEvent : Event, isUndo : Bool = true) : Void
    {
        if (Std.is(undoEvent, MouseWheelEvent))
        {
            var wheelEvt : MouseWheelEvent = try cast(undoEvent, MouseWheelEvent) catch(e:Dynamic) null;
            var delta : Float = wheelEvt.delta;
            var localMouse : Point = wheelEvt.mousePoint;
            if (isUndo)
            {
                handleMouseWheel(-delta, localMouse, false);
            }
            else
            {
                handleMouseWheel(delta, localMouse, false);
            }
        }
        else if ((Std.is(undoEvent, MoveEvent)) && (undoEvent.type == MoveEvent.MOUSE_DRAG))
        {
            var moveEvt : MoveEvent = try cast(undoEvent, MoveEvent) catch(e:Dynamic) null;
            var startPoint : Point = moveEvt.startLoc;
            var endPoint : Point = moveEvt.endLoc;
            if (isUndo)
            {
                content.x = startPoint.x;
                content.y = startPoint.y;
            }
            else
            {
                content.x = endPoint.x;
                content.y = endPoint.y;
            }
            inactiveContent.x = content.x;
            inactiveContent.y = content.y;
        }
    }
    
    public function getPanZoomAllowed() : Bool
    {
        if (m_currentLevel != null)
        {
            return m_currentLevel.getPanZoomAllowed();
        }
        return true;
    }
    
    //returns ByteArray that contains bitmap that is the same aspect ratio as view, with maxwidth or maxheight (or both, if same as aspect ratio) respected
    //byte array is compressed and contains it's width as as unsigned int at the start of the array
    public function getThumbnail(_maxwidth : Float, _maxheight : Float) : ByteArray
    {
        var backgroundColor : Int = 0x262257;
        //save current state
        var savedClipRect : Rectangle = clipRect;
        var currentX : Float = content.x;
        var currentY : Float = content.y;
        var currentXScale : Float = content.scaleX;
        var currentYScale : Float = content.scaleY;
        recenter();
        this.clipRect = null;
        //remove these to help with compression
        removeChild(m_border);
        
        var bmpdata : BitmapData = customDrawToBitmapData(backgroundColor);
        
        var scaleWidth : Float = _maxwidth / bmpdata.width;
        var scaleHeight : Float = _maxheight / bmpdata.height;
        var newWidth : Float;
        var newHeight : Float;
        if (scaleWidth < scaleHeight)
        {
            scaleHeight = scaleWidth;
            newWidth = _maxwidth;
            newHeight = bmpdata.height * scaleHeight;
        }
        else
        {
            scaleWidth = scaleHeight;
            newHeight = _maxheight;
            newWidth = bmpdata.width * scaleWidth;
        }
        
        //crashes on my machine in debug, even though should be supported in 11.3
        //		var byteArray:ByteArray = new ByteArray;
        //		bmpdata.encode(new Rectangle(0,0,640,480), new flash.display.JPEGEncoderOptions(), byteArray);
        
        var m : Matrix = new Matrix();
        m.scale(scaleWidth, scaleHeight);
        var smallBMD : BitmapData = new BitmapData(Std.int(newWidth), Std.int(newHeight));
        smallBMD.draw(bmpdata, m);
        
        //restore state
        content.x = currentX;
        content.y = currentY;
        inactiveContent.x = content.x;
        inactiveContent.x = content.y;
        content.scaleX = currentXScale;
        content.scaleY = currentYScale;
        inactiveContent.scaleX = content.scaleX;
        inactiveContent.scaleY = content.scaleY;
        clipRect = savedClipRect;
        addChildAt(this.m_border, 0);
        
        var bytes : ByteArray = new ByteArray();
        bytes.writeUnsignedInt(smallBMD.width);
        //fix bottom to be above score area
        var fixedRect : Rectangle = smallBMD.rect.clone();
        fixedRect.height = Math.floor(smallBMD.height * (clipRect.height / 320));
        bytes.writeBytes(smallBMD.getPixels(fixedRect));
        bytes.compress();
        
        return bytes;
    }
    
    public function customDrawToBitmapData(_backgroundColor : Int = 0x00000000, destination : BitmapData = null) : BitmapData
    {
        var star : Starling = Starling.current;
		var painter : Painter = star.painter;
        
        if (destination == null)
        {
            destination = new BitmapData(480, 320);
        }
        
		painter.pushState();
		painter.state.setProjectionMatrix(0, 0, 960, 640);
		painter.clear(_backgroundColor, 1);
		render(painter);
        painter.finishFrame();
        
        star.context.drawToBitmapData(destination);
		painter.popState();
        //	Starling.current.context.present(); // required on some platforms to avoid flickering
        
        return destination;
    }
    
    
    public function adjustSize(newWidth : Float, newHeight : Float) : Void
    {
        clipRect = new Rectangle(x, y, width, height);
        
        if (contentBarrier != null)
        {
            removeChild(contentBarrier);
        }
        
        contentBarrier = new Quad(width, height, 0x00);
        contentBarrier.alpha = 0.01;
        contentBarrier.visible = true;
        addChildAt(contentBarrier, 0);
    }
}

