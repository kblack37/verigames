package cgs.engine.view.mouseInteraction;

import cgs.engine.view.layering.ICGSLayer;
import cgs.engine.view.layering.LayerManager;
import cgs.utils.Error;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
	 * Class for computing mouse interaction at and below this layer in the game.
	 * @author Rich
	 */
class MouseInteractionLayer extends LayerManager implements ICGSLayer
{
    public var checkForMovement(get, set) : Bool;
    public var clickThroughSelectedObject(get, set) : Bool;
    public var displayObject(get, never) : DisplayObject;
    public var dragRadius(get, set) : Float;
    public var layerIndex(get, never) : Int;
    public var isStopped(get, never) : Bool;

    // Dragging Endings
    public static inline var END_DRAG_MOUSE_OUT : String = "endedDragFromMouseOut";
    public static inline var END_DRAG_STOP : String = "endedDragFromMouseLayerStop";
    public static inline var END_DRAG_DROP : String = "endedDragFromDrop";
    
    // State
    private var m_activeCatchLayer : Bool;
    private var m_catchLayer : Sprite;
    private var m_checkForMovement : Bool;
    private var m_clickThroughSelected : Bool;
    private var m_dragRadius : Float = 5;
    private var m_gameHeight : Float;
    private var m_gameWidth : Float;
    private var m_inputData : Array<MouseEvent>;
    private var m_isDragging : Bool;
    private var m_dragFromClick : Bool;
    private var m_mouseDown : Bool;  // Whether or not the mouse button is depressed  
    private var m_mouseDownStartPos : Point;
    private var m_mouseObject : IHighlightable;
    private var m_mouseX : Float;
    private var m_mouseY : Float;
    private var m_rootSprite : Sprite;
    private var m_selectedObject : ISelectable;  // The presently Selected object  
    private var m_selectedByClick : Bool;
    private var m_stopped : Bool = true;
    private var m_registeredWithRootSprite : Bool = false;
    private var m_targetObject : IClickable;  // The target object which the player recently clicked on  
    
    public function new(owner : LayerManager)
    {
        super();
        owner.addLayer(this);
        
        // Register for mouse events
        m_inputData = new Array<MouseEvent>();
    }
    
    /**
		 * Initializes the Mouse Layer. May be called multiple times.
		 * @param	rootSprite The sprite the mouse layer will use to register for
		 * 					all relevant mouse events.
		 * @param	gameWidth Width of the game.
		 * @param	gameHeight Height of the game.
		 */
    public function init(rootSprite : Sprite, gameWidth : Float, gameHeight : Float) : Void
    {
        // Update the root sprite
        var registered : Bool = m_registeredWithRootSprite;
        if (registered)
        {
            unregisterWithRoot();
        }
        m_rootSprite = rootSprite;
        if (registered)
        {
            registerWithRoot();
        }
        
        m_gameWidth = gameWidth;
        m_gameHeight = gameHeight;
    }
    
    /**
		 * Resets the mouse interaction layer.
		 */
    public function reset() : Void
    {
        if (m_mouseObject != null)
        {
            m_mouseObject.isMouseHighlighted = false;
            m_mouseObject.updateHighlight();
            m_mouseObject = null;
        }
        if (m_selectedObject != null)
        {
            m_selectedObject.deselect();
            m_selectedObject = null;
            m_selectedByClick = false;
        }
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns whether or not the mouse interaction layer should check for movement underneath the mouse.
		 */
    private function get_checkForMovement() : Bool
    {
        return m_checkForMovement;
    }
    
    /**
		 * Returns whether or not the mouse interaction layer should check for movement underneath the mouse
		 * to be the given value.
		 */
    private function set_checkForMovement(value : Bool) : Bool
    {
        m_checkForMovement = value;
        return value;
    }
    
    /**
		 * Returns whether or not the mouse interaction layer will look through the presently selected object
		 * to look for new objects to click on.
		 */
    private function get_clickThroughSelectedObject() : Bool
    {
        return m_clickThroughSelected;
    }
    
    /**
		 * Sets whether or not the mouse interaction layer will look through the presently selected object
		 * to look for new objects to click on to be the given value.
		 */
    private function set_clickThroughSelectedObject(value : Bool) : Bool
    {
        m_clickThroughSelected = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		**/
    private function get_displayObject() : DisplayObject
    {
        return this;
    }
    
    /**
		 * Returns the drag radius used by the mouse interaction layer.
		 */
    private function get_dragRadius() : Float
    {
        return m_dragRadius;
    }
    
    /**
		 * Sets the drag radius used by the mouse interaction layer to be the given value.
		 */
    private function set_dragRadius(value : Float) : Float
    {
        m_dragRadius = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		**/
    private function get_layerIndex() : Int
    {
        return 4;
    }
    
    /**
		 * Returns whether or not this Mouse Interaction Layer is presently stopped.
		**/
    private function get_isStopped() : Bool
    {
        return m_stopped;
    }
    
    /**
		 * 
		 * Event Listeners
		 * 
		**/
    
    /**
		 * Responds to mouse out event by ending any running drags.
		 * @param	event Mouse Event.
		 */
    private function onMouseOut(event : MouseEvent) : Void
    {
        if (!m_stopped && m_selectedObject != null && m_isDragging && (event.stageX > m_gameWidth || event.stageX < 0 || event.stageY > m_gameHeight || event.stageY < 0))
        {
            // End the drag
            (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).endDrag(END_DRAG_MOUSE_OUT);
            m_isDragging = false;
            m_dragFromClick = false;
            m_selectedObject.deselect();
            m_selectedObject = null;
            m_selectedByClick = false;
            m_mouseDownStartPos = null;
        }
        else
        {
            onStoppedMouseOut();
        }
    }
    
    /**
		 * Mouse layer's response to mouse out when the mouse layer is supposed to be "off".
		 */
    private function onStoppedMouseOut() : Void
    {
    }
    
    /**
		 * Responds to mouse down events by storing them until the next sychronized tick.
		 * @param	event Mouse Event.
		 */
    private function onMouseDown(event : MouseEvent) : Void
    {
        if (!m_stopped)
        {
            m_inputData.push(event);
        }
        else
        {
            onStoppedMouseDown();
        }
    }
    
    /**
		 * Mouse layer's response to mouse down when the mouse layer is supposed to be "off". For example, Tetra uses this
		 * to skip animations.
		 */
    private function onStoppedMouseDown() : Void
    {
    }
    
    /**
		 * Responds to mouse up events by storing them until the next sychronized tick.
		 * @param	event Mouse Event.
		 */
    private function onMouseUp(event : MouseEvent) : Void
    {
        if (!m_stopped)
        {
            m_inputData.push(event);
        }
        else
        {
            onStoppedMouseUp();
        }
    }
    
    /**
		 * Mouse layer's response to mouse up when the mouse layer is supposed to be "off".
		 */
    private function onStoppedMouseUp() : Void
    {
    }
    
    /**
		 * 
		 * Catch Layer
		 * 
		**/
    
    /**
		 * Activates the optional catch layer - an invisible Sprite the size of the game that
		 * stops all mouse events from reaching objects beneath it.
		 */
    public function activateCatchLayer() : Void
    {
        // Setup the Catch Layer which will catch all the relevant mouse events.
        m_catchLayer = new Sprite();
        m_catchLayer.graphics.beginFill(0xffffff, 0);
        m_catchLayer.graphics.drawRect(0, 0, m_gameWidth, m_gameHeight);
        m_catchLayer.graphics.endFill();
        addChild(m_catchLayer);
    }
    
    /**
		 * Deactivates and removes the optional catch layer.
		 */
    public function deactivateCatchLayer() : Void
    {
        if (m_catchLayer != null)
        {
            removeChild(m_catchLayer);
            m_catchLayer = null;
        }
    }
    
    /**
		 * 
		 * Mouse Actions
		 * 
		**/
    
    /**
		 * Returns the array of display objects the top object is a child of.
		 * @param	topObject
		 * @return
		 */
    private function getObjectsInDisplayStack(topObject : DisplayObject) : Array<Dynamic>
    {
        var result : Array<Dynamic> = new Array<Dynamic>();
        var latestObject : DisplayObject = topObject;
        if (Std.is(topObject, DisplayObjectContainer))
        {
            result.unshift(latestObject);
        }
        while (latestObject.parent != null)
        {
            latestObject = latestObject.parent;
            if (Std.is(latestObject, DisplayObjectContainer))
            {
                result.unshift(latestObject);
            }
        }
        return result;
    }
    
    /**
		 * Builds the array of potential display objects under the mouse that could be useful for this 
		 * Mouse Interaction Layer.
		 * @return
		 */
    private function getObjectsUnderMouse(x : Float, y : Float) : Array<Dynamic>
    {
        var result : Array<Dynamic>;
        var objectStack : Array<Dynamic> = m_rootSprite.getObjectsUnderPoint(new Point(x, y));
        
        // Process the array of objects under the mouse
        for (i in 0...objectStack.length)
        {
            // Build a temporary array of objects in the display stack until we hit an object we have seen before.
            var displayStack : Array<Dynamic> = getObjectsInDisplayStack(objectStack[i]);
            if (result == null)
            {
                result = displayStack;
                continue;
            }
            
            // Process the element in the display stack
            var rootOfDisplayStack : DisplayObjectContainer = displayStack.shift();
            var indexOfRoot : Int = Lambda.indexOf(result, rootOfDisplayStack);
            
            // Going throuh the display stack in order, building from the root object (which really should be Main.as, or whater the main class is)
            while (displayStack.length > 0)
            {
                var tObject1 : DisplayObjectContainer = displayStack.shift();
                // tObject1 is not already in the result meaning we need to find a home for it
                if (Lambda.indexOf(result, tObject1) < 0)
                {
                    // Get tObject1's parent, ensure it is in the result already
                    var parent : DisplayObjectContainer = tObject1.parent;
                    var parentIndex : Int = Lambda.indexOf(result, parent);
                    if (parentIndex < 0)
                    {
                        // WTF? How is this possible?
                        // I am convinced that there is an error in Flash starting with FP 11.2 which would cause this case to occur
                        // The error: returning something from getObjectsUnderPoint that is not a child of the DisplayObjectContainer
                        // In which case, we get invalid data and can just skip the result
                        //throw new Error("object's parent is not in the known stack")
                        break;
                    }
                    else
                    {
                        // Find tObject1's location in result
                        {
                            // Get all the children of the parent that are in the result
                            var indexOfTObject1 : Int = parent.getChildIndex(tObject1);
                            for (j in parentIndex + 1...result.length)
                            {
                                var child : DisplayObjectContainer = result[j];
                                try
                                {
                                    var childIndex : Int = parent.getChildIndex(child);
                                    // tObject1 goes first
                                    if (indexOfTObject1 < childIndex)
                                    {
                                        result = addObjectsIntoArray(tObject1, displayStack, childIndex, result);
                                        break;
                                    }
                                }
                                catch (err : Error)
                                {  // Do nothing, this try catch was to find the children of the parents  
                                    
                                }
                            }
                            
                            // If we come out the other side of the for loop, that means that we should add tObject1
                            // and the display stack to the end of result. Either tObject1 is the last child or it is
                            // the only child of the parent in the result.
                            result.push(tObject1);
                            while (displayStack.length > 0)
                            {
                                result.push(displayStack.shift());
                            }
                            break;
                        }
                    }
                }
                else
                {
                    rootOfDisplayStack = try cast(tObject1, DisplayObjectContainer) catch(e:Dynamic) null;
                    indexOfRoot = Lambda.indexOf(result, rootOfDisplayStack);
                }
            }
        }
        
        return result;
    }
    
    private function addObjectsIntoArray(object : DisplayObjectContainer, others : Array<Dynamic>, index : Int, targetArray : Array<Dynamic>) : Array<Dynamic>
    {
        var result : Array<Dynamic> = targetArray.slice(0, index);
        var result2 : Array<Dynamic> = targetArray.slice(index);
        result.push(object);
        if (others != null)
        {
            while (others.length > 0)
            {
                result.push(others.shift());
            }
        }
        while (result2.length > 0)
        {
            result.push(result2.shift());
        }
        return result;
    }
    
    /**
		 * Executes a syncronized mouse down.
		 * @param	event Mouse Event
		 */
    private function simulateMouseDown(event : MouseEvent, tObjects : Array<Dynamic>) : Void
    {
        // Keep track of when the mouse is down
        m_mouseDown = true;
        
        // Get all the objects under the mouse.
        //var tObjects:Array = getObjectsUnderMouse(event.stageX, event.stageY);
        if (tObjects != null)
        {
            // Search for an IClickable object
            var j : Int = as3hx.Compat.parseInt(tObjects.length - 1);
            while (j >= 0)
            {
                if (Std.is(tObjects[j], IClickable))
                {
                    // Skip it if it is what we are dragging
                    if (tObjects[j] == m_selectedObject)
                    {
                        if (m_clickThroughSelected)
                        {
                            {j--;continue;
                            }
                        }
                        else
                        {
                            break;
                        }
                    }
                    
                    m_targetObject = (try cast(tObjects[j], IClickable) catch(e:Dynamic) null);
                    m_targetObject.mouseDown(event);
                    break;
                }
                j--;
            }
        }
    }
    
    /**
		 * Executes a syncronized mouse move.
		 * @param	event Mouse Event
		 */
    private function simulateMouseMove(tObjects : Array<Dynamic>) : Void
    {
        // Process target object
        if (m_targetObject != null)
        {
            if (Std.is(m_targetObject, ISelectable) && (try cast(m_targetObject, ISelectable) catch(e:Dynamic) null).isSelectable)
            {
                if (m_selectedObject != null)
                {
                    m_selectedObject.deselect();
                    m_selectedObject = null;
                    m_selectedByClick = false;
                }
                (try cast(m_targetObject, ISelectable) catch(e:Dynamic) null).select();
                m_selectedObject = try cast(m_targetObject, ISelectable) catch(e:Dynamic) null;
                m_targetObject = null;
                m_selectedByClick = !(Std.is(m_selectedObject, IDraggable));  // If draggable, it was selected by a drag. If not draggable, that makes no sense, so it was selected by click  
                if (Std.is(m_selectedObject, IDraggable) && ((try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).isDraggable || (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).followMouseWhenSelected))
                {
                    m_mouseDownStartPos = new Point(m_mouseX, m_mouseY);
                }
            }
            else
            {
                if (Std.is(!m_targetObject, IClickable))
                {
                    m_targetObject = null;
                }
            }
        }
        
        // Process selected object
        if (m_selectedObject != null && Std.is(m_selectedObject, IDraggable) && ((try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).isDraggable || (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).followMouseWhenSelected))
        {
            checkForDrag();
        }
        
        // Get all the objects under the mouse.
        //var tObjects:Array = getObjectsUnderMouse(m_mouseX, m_mouseY);
        if (tObjects != null)
        {
            var highlightData : Dynamic = null;
            //check that we are dragging something.
            if (m_selectedObject != null && m_isDragging)
            {
                //we ARE dragging something, o let's create addidional data object.
                highlightData = {};
                highlightData.dragging = true;
                highlightData.draggedObject = m_selectedObject;
            }
            
            // Search for an IHighlightable object
            var found : Bool = false;
            var i : Int = as3hx.Compat.parseInt(tObjects.length - 1);
            while (i >= 0)
            {
                if (Std.is(tObjects[i], IHighlightable))
                {
                    // Skip it if it is what we are dragging
                    if (m_isDragging && tObjects[i] == m_selectedObject)
                    {
                        {i--;continue;
                        }
                    }
                    
                    found = true;
                    if (tObjects[i] != m_mouseObject)
                    {
                        // Roll out of previous object
                        if (m_mouseObject != null)
                        {
                            m_mouseObject.isMouseHighlighted = false;
                            m_mouseObject.updateHighlight();
                        }
                        
                        // Update object
                        m_mouseObject = try cast(tObjects[i], IHighlightable) catch(e:Dynamic) null;
                        
                        // Roll over new object
                        if (m_mouseObject.isHighlightable)
                        {
                            m_mouseObject.isMouseHighlighted = true;
                            m_mouseObject.updateHighlight(highlightData);
                        }
                    }
                    break;
                }
                i--;
            }
        }
        
        // Nothing is highlightable, so clear any object we are presently highlighting
        if (!found && m_mouseObject != null)
        {
            m_mouseObject.isMouseHighlighted = false;
            m_mouseObject.updateHighlight();
            if (m_mouseObject == m_targetObject)
            {
                m_targetObject = null;
            }
            m_mouseObject = null;
        }
    }
    
    /**
		 * Executes a syncronized mouse up.
		 * @param	event Mouse Event
		 */
    private function simulateMouseUp(event : MouseEvent, tObjects : Array<Dynamic>) : Void
    {
        // Keep track of when the mouse is down
        m_mouseDown = false;
        
        // Process the selected object
        if (m_selectedObject != null)
        {
            // We only want to process it if it should be deselected now. The time this may not be the case is if the object
            // is clickable but not draggable and this is the first mouse up, to select the object, but it was already selected
            // by mouse move. Yes, I know it is complicated, I do not really have the time to make this neater, sorry!
            if ((Std.is(m_selectedObject, IDraggable) && (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).isDraggable) || m_selectedByClick)
            {
                // Get all the objects under the mouse.
                //var tObjects:Array = getObjectsUnderMouse(event.stageX, event.stageY);
                var dZone : IDropZone;
                if (tObjects != null)
                {
                    // Search for an IDropZone object
                    var i : Int = as3hx.Compat.parseInt(tObjects.length - 1);
                    while (i >= 0)
                    {
                        if (Std.is(tObjects[i], IDropZone))
                        {
                            dZone = (try cast(tObjects[i], IDropZone) catch(e:Dynamic) null);
                            break;
                        }
                        i--;
                    }
                    
                    // Attempt to drop on the discovered drop zone
                    if (dZone != null)
                    {
                        if (dZone.canDrop(m_selectedObject, event.stageX, event.stageY))
                        {
                            dZone.dropObject(m_selectedObject, event.stageX, event.stageY);
                        }
                        
                        // Since we found a drop zone, we dont want to do anything with the target object
                        m_targetObject = null;
                    }
                }
                
                // End the drag
                if (m_isDragging)
                {
                    (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).endDrag(END_DRAG_DROP, {
                                dropZone : dZone
                            });
                    m_isDragging = false;
                    m_dragFromClick = false;
                }
                
                // Release the selected object
                if (m_selectedObject != null)
                {
                    m_selectedObject.deselect();
                    m_selectedObject = null;
                }
                m_selectedByClick = false;
                m_mouseDownStartPos = null;
            }
            else
            {
                m_selectedByClick = true;
            }
        }
        
        // Process target object
        if (m_targetObject != null)
        {
            // Attempt selection
            if (Std.is(m_targetObject, ISelectable))
            {
                if ((try cast(m_targetObject, ISelectable) catch(e:Dynamic) null).isSelectable)
                {
                    (try cast(m_targetObject, ISelectable) catch(e:Dynamic) null).select();
                    m_selectedObject = try cast(m_targetObject, ISelectable) catch(e:Dynamic) null;
                    m_selectedByClick = true;
                    if (Std.is(m_selectedObject, IDraggable) && ((try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).isDraggable || (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).followMouseWhenSelected))
                    {
                        m_mouseDownStartPos = new Point(m_mouseX, m_mouseY);
                    }
                }
            }
            else
            {
                // Attempt click
                {
                    if (m_targetObject.isClickable)
                    {
                        m_targetObject.click(event);
                    }
                }
            }
            m_targetObject = null;
        }
    }
    
    /**
		 * 
		 * Register and Unregister with root sprite
		 * 
		**/
    
    /**
		 * Register with the root sprite for mouse down/up/out
		 */
    private function registerWithRoot() : Void
    {
        if (!m_registeredWithRootSprite && m_rootSprite != null)
        {
            m_rootSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            m_rootSprite.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            m_rootSprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            m_registeredWithRootSprite = true;
        }
    }
    
    /**
		 * Unregister with the root sprite for mouse down/up/out
		 */
    private function unregisterWithRoot() : Void
    {
        if (m_registeredWithRootSprite && m_rootSprite != null)
        {
            m_rootSprite.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            m_rootSprite.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            m_rootSprite.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            m_registeredWithRootSprite = false;
        }
    }
    
    /**
		 * 
		 * Start and Stop
		 * 
		**/
    
    /**
		 * Turn on the mouse layer.
		 */
    public function start() : Void
    {
        m_stopped = false;
        registerWithRoot();
    }
    
    /**
		 * Turn off the mouse layer.
		 */
    public function stop() : Void
    {
        if (m_selectedObject != null)
        {
            if (m_isDragging)
            {
                (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).endDrag(END_DRAG_STOP);
                m_isDragging = false;
                m_dragFromClick = false;
            }
            m_selectedObject.deselect();
            m_selectedObject = null;
            m_selectedByClick = false;
            m_mouseDownStartPos = null;
        }
        if (m_mouseObject != null)
        {
            m_mouseObject.isMouseHighlighted = false;
            m_mouseObject.updateHighlight();
            m_mouseObject = null;
        }
        m_stopped = true;
        
        // Remove latest mouse clicks, if any.
        while (m_inputData.length > 0)
        {
            m_inputData.pop();
        }
    }
    
    /**
		 * 
		 * Update
		 * 
		**/
    
    /**
		 * Checks for dragging on the presently selected object. Starts dragging it,
		 * or continues dragging it, if dragging is triggered.
		 * @param	event Mouse Event
		 */
    private function checkForDrag() : Void
    {
        // Check for Dragging
        var followMouse : Bool = ((try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).isDraggable && m_mouseDown) || (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).followMouseWhenSelected;
        if (m_mouseDownStartPos != null && !m_isDragging && followMouse)
        {
            var newPos : Point = new Point(m_mouseX, m_mouseY);
            if (computeDistanceBetweenPoints(m_mouseDownStartPos, newPos) > m_dragRadius)
            {
                m_isDragging = true;
                if (!(try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).isDraggable)
                {
                    m_dragFromClick = true;
                }
                (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).beginDrag(m_mouseX, m_mouseY);
                if ((try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).addToDragLayerWhenDragged)
                {
                    addChildAt(try cast(m_selectedObject, DisplayObject) catch(e:Dynamic) null, 0);
                }
                (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).updateDrag(m_mouseX, m_mouseY);
            }
        }
        else
        {
            // Update Dragging
			if (m_isDragging)
            {
                (try cast(m_selectedObject, IDraggable) catch(e:Dynamic) null).updateDrag(m_mouseX, m_mouseY);
            }
        }
    }
    
    /**
		 * Computes the distance between the given points.
		 * @param	first First point
		 * @param	second Second point
		 * @return
		 */
    private function computeDistanceBetweenPoints(first : Point, second : Point) : Float
    {
        var deltaX : Float = first.x - second.x;
        var deltaY : Float = first.y - second.y;
        return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    }
    
    /**
		 * @inheritDoc
		 */
    override public function update(deltaT : Float, data : Dynamic = null) : Void
    {
        super.update(deltaT, data);
        
        // Dont compute anything if we are 'stopped'
        if (m_stopped)
        {
            return;
        }
        
        // Check for mouse movement
        var mouseMoved : Bool = m_checkForMovement;
        if (stage.mouseX != m_mouseX)
        {
            m_mouseX = stage.mouseX;
            mouseMoved = true;
        }
        if (stage.mouseY != m_mouseY)
        {
            m_mouseY = stage.mouseY;
            mouseMoved = true;
        }
        
        // Get objects under mouse, so we only have to do this once and all calls get the same data
        // but only when there is something to run (ie. the mouse moved)
        var tObjects : Array<Dynamic> = ((mouseMoved || m_inputData.length > 0)) ? getObjectsUnderMouse(m_mouseX, m_mouseY) : null;
        
        // Simulate the mouse movement
        if (mouseMoved)
        {
            simulateMouseMove(tObjects);
        }
        
        // Check for events
        while (m_inputData.length > 0)
        {
            var event : MouseEvent = m_inputData.shift();
            var _sw0_ = (event.type);            

            switch (_sw0_)
            {
                case MouseEvent.MOUSE_DOWN:
                    simulateMouseDown(event, tObjects);
                case MouseEvent.MOUSE_UP:
                    simulateMouseUp(event, tObjects);
                default:
            }
        }
    }
}

