package scenes.game.display;

import constraints.ConstraintGraph;
import constraints.ConstraintScoringConfig;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
//import flash.errors.ScriptTimeoutError;
import utils.XObject;
import constraints.Constraint;
import display.NineSliceBatch;
import display.TextBubble;
import events.EdgeContainerEvent;
import events.ToolTipEvent;
import graph.Edge;
import graph.Port;
import graph.PropDictionary;
import networking.Achievements;
import particle.ErrorParticleSystem;
import scenes.game.PipeJamGameScene;

class GameEdgeContainer extends GameComponent
{
    public var plug(get, never) : Sprite;
    public var socket(get, never) : Sprite;
    public var globalStart(get, never) : Point;
    public var globalEnd(get, never) : Point;

    public var m_fromNode : GameNode;
    public var m_toNode : GameNode;
    public var m_fromPortID : Int = -1;
    public var m_toPortID : Int = -1;
    
    private var m_dir : String;
    public var edgeArray : Array<Dynamic>;
    
    private var m_edgeSegments : Array<GameEdgeSegment> = new Array<GameEdgeSegment>();
    private var m_edgeJoints : Array<GameEdgeJoint> = new Array<GameEdgeJoint>();
    
    //save start and end points, so we can remake line
    public var m_startPoint : Point;
    public var m_endPoint : Point;
    public var m_startJoint : GameEdgeJoint;
    public var m_endJoint : GameEdgeJoint;
    public var m_markerJoint : GameEdgeJoint;
    
    public var hasChanged : Bool;
    public var restoreEdge : Bool;
    
    //used to record current position for both undoing and port tracking (snap back to original)
    public var undoObject : Dynamic = {};
    
    public var innerFromBoxSegment : InnerBoxSegment;
    public var innerToBoxSegment : InnerBoxSegment;
    
    public var m_jointPoints : Array<Point>;
    
    public var incomingEdgePosition : Float;
    public var outgoingEdgePosition : Float;
    
    public var graphConstraint : Constraint;
    
    public var errorContainer : Sprite = new Sprite();
    private var m_errorParticleSystem : ErrorParticleSystem;
    public var errorTextBubbleContainer : Sprite = new Sprite();
    public var errorTextBubble : TextBubble;
    
    public var m_errorProps : PropDictionary;
    private var m_hidingErrorText : Bool = false;
    public var initialized : Bool = false;
    public var hideSegments : Bool;
    
    public static var EDGES_OVERLAPPING_JOINTS : Bool = true;
    public static var WIDE_WIDTH : Float = .3 * Constants.GAME_SCALE;
    public static var NARROW_WIDTH : Float = .1 * Constants.GAME_SCALE;
    public static var ERROR_WIDTH : Float = .6 * Constants.GAME_SCALE;
    
    public static var DIR_FROM : String = "DIR_FROM";
    public static var DIR_TO : String = "DIR_TO";
    
    public static inline var NUM_JOINTS : Int = 6;
    public static var DEBUG_BOUNDING_BOX : Bool = false;
    public static var DEBUG_LARGE_LEVELS : Bool = false;
    
    public function new(_id : String, _edgeArray : Array<Dynamic>,
            fromComponent : GameNode, toComponent : GameNode,
            _graphConstraint : Constraint, _draggable : Bool,
            _hideSegments : Bool = false)
    {
        super(_id);
        draggable = _draggable;
        edgeArray = XObject.clonePointArray(_edgeArray);
        m_fromNode = fromComponent;
        m_toNode = toComponent;
        graphConstraint = _graphConstraint;
        hideSegments = _hideSegments;
        m_isEditable = fromComponent.isEditable();
        m_isWide = fromComponent.isWide();
        
        //mark these as undefined
        outgoingEdgePosition = -1;
        incomingEdgePosition = -1;
        
        setupPoints();
        
        fromComponent.setOutgoingEdge(this);  // this also sets m_fromPortID  
        toComponent.setIncomingEdge(this);  // this also sets m_toPortID  
        
        updateInnerSegments();
        updateOutsideEdgeComponents();
        onWidgetChange();
        
        m_isDirty = true;
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    override public function getProps() : PropDictionary
    {
        return graphConstraint.lhs.getProps();
    }
    
    /**
		 * Update the parameters used to draw innerBoxSegment and recreate using updated params
		 */
    public function updateInnerSegments() : Void
    {
        var fromBoxHeight : Float = m_fromNode.boundingBox.height + 0.5;
        var fromInnerBoxPt : Point = new Point(m_startPoint.x, m_startPoint.y - fromBoxHeight / 2.0);
        if (innerFromBoxSegment != null)
        {
            innerFromBoxSegment.removeFromParent(true);
        }
        innerFromBoxSegment = new InnerBoxSegment(fromInnerBoxPt, fromBoxHeight / 2.0, DIR_FROM, m_fromNode.isWide(), m_fromNode.isWide(), m_fromNode.isEditable(), true, false, m_isWide, true, draggable, hideSegments);
        if (hideSegments)
        {
            innerFromBoxSegment.visible = false;
        }
        
        var toBoxHeight : Float = m_toNode.boundingBox.height + 0.5;
        var toInnerBoxPt : Point = new Point(m_endPoint.x, m_endPoint.y + toBoxHeight / 2.0);
        if (innerToBoxSegment != null)
        {
            innerToBoxSegment.removeFromParent(true);
        }
        innerToBoxSegment = new InnerBoxSegment(toInnerBoxPt, toBoxHeight / 2.0, DIR_TO, m_isWide, m_toNode.isWide(), m_toNode.isEditable(), true, !hideSegments, m_isWide, m_isEditable, draggable, hideSegments);
        if (hideSegments)
        {
            innerToBoxSegment.visible = false;
        }
        
        positionChildren();
    }
    
    private function onAddedToStage(evt : Event) : Void
    {
        if (!initialized)
        {
            initialized = true;
            buildLine();
            
            addEventListener(EdgeContainerEvent.CREATE_JOINT, onCreateJoint);
            addEventListener(EdgeContainerEvent.SEGMENT_DELETED, onSegmentDeleted);
            addEventListener(EdgeContainerEvent.RUBBER_BAND_SEGMENT, onRubberBandSegment);
            addEventListener(EdgeContainerEvent.HOVER_EVENT_OVER, onHoverOver);
            addEventListener(EdgeContainerEvent.HOVER_EVENT_OUT, onHoverOut);
            addEventListener(EdgeContainerEvent.SAVE_CURRENT_LOCATION, onSaveLocation);
            addEventListener(EdgeContainerEvent.RESTORE_CURRENT_LOCATION, onRestoreLocation);
            addEventListener(EdgeContainerEvent.INNER_SEGMENT_CLICKED, onInnerBoxSegmentClicked);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    }
    
    public function setupPoints(newEdgeArray : Array<Dynamic> = null) : Void
    {
        if (newEdgeArray != null)
        {
            edgeArray = newEdgeArray;
        }
        var startPt : Point = edgeArray[0];
        var endPt : Point = edgeArray[edgeArray.length - 1];
        var minXedge : Float = Math.min(startPt.x, endPt.x);
        var minYedge : Float = Math.min(startPt.y, endPt.y);
        this.x = minXedge;
        this.y = minYedge;
        if (newEdgeArray == null)
        {
        //adjust by min
            
            for (i0 in 0...edgeArray.length)
            {
                edgeArray[i0].x -= minXedge;
                edgeArray[i0].y -= minYedge;
            }
        }
        
        m_startPoint = edgeArray[0];
        m_endPoint = edgeArray[edgeArray.length - 1];
        
        if (edgeArray.length == 2)
        {
            createJointPointsArray(m_startPoint, m_endPoint);
            //fix up edge array also
            edgeArray = new Array<Dynamic>();
            for (i in 0...m_jointPoints.length)
            {
                var pt : Point = m_jointPoints[i];
                edgeArray.push(pt.clone());
            }
        }
        //trace("creating joint points for " + m_id);
        else
        {
            
            m_jointPoints = new Array<Point>();
            for (i1 in 0...edgeArray.length)
            {
            //trace("joint pt " + m_edgeArray[i1]);
                
                var pt1 : Point = edgeArray[i1];
                m_jointPoints.push(pt1.clone());
            }
            correctJointPointDiagonals();
            updateOutsideEdgeComponents();
            updateBoundingBox();
        }
    }
    
    override public function componentMoved(delta : Point) : Void
    {
        super.componentMoved(delta);
        updateOutsideEdgeComponents();
    }
    
    private var m_debugBoundingBox : Quad = new Quad(1, 1, 0xff00ff);
    private function updateBoundingBox() : Void
    {
        var minX : Float = Math.POSITIVE_INFINITY;
        var maxX : Float = Math.NEGATIVE_INFINITY;
        var minY : Float = Math.POSITIVE_INFINITY;
        var maxY : Float = Math.NEGATIVE_INFINITY;
        for (i1 in 0...m_jointPoints.length)
        {
            var pt1 : Point = m_jointPoints[i1];
            minX = Math.min(minX, pt1.x - WIDE_WIDTH);
            maxX = Math.max(maxX, pt1.x + WIDE_WIDTH);
            minY = Math.min(minY, pt1.y - WIDE_WIDTH);
            maxY = Math.max(maxY, pt1.y + WIDE_WIDTH);
        }
        boundingBox = new Rectangle(minX + this.x, minY + this.y, maxX - minX, maxY - minY);
        m_debugBoundingBox.width = boundingBox.width;
        m_debugBoundingBox.height = boundingBox.height;
        m_debugBoundingBox.x = boundingBox.x - this.x;
        m_debugBoundingBox.y = boundingBox.y - this.y;
        m_debugBoundingBox.alpha = 0.2;
        m_debugBoundingBox.touchable = false;
    }
    
    /**
		 * Create visuals
		*/
    public function buildLine() : Void
    {
        createChildren();
        positionChildren();
        
        updateSize();
    }
    
    public function onWidgetChange(widgetChanged : GameNode = null) : Void
    {
        var force : Bool = (widgetChanged == null);
        var newIsWide : Bool = m_fromNode.isWide();
        var oldIsWide : Bool = m_isWide;
        if ((widgetChanged == m_fromNode) || force)
        {
            setWidths(newIsWide);
            innerFromBoxSegment.setIsWide(m_isWide);
            innerFromBoxSegment.updateBorderWidth(m_isWide);
            innerToBoxSegment.setPlugIsWide(m_isWide);
            updateFromProps();
        }
        if ((widgetChanged == m_toNode) || force)
        {
            innerToBoxSegment.updateBorderWidth(m_toNode.isWide());
            updateToProps();
        }
        // Inner To Segment (under the socket) only wide if both the incoming plug and toWidget are wide
        innerToBoxSegment.setIsWide(m_fromNode.isWide() && m_toNode.isWide());
        refreshConflicts(true);
        if (oldIsWide != newIsWide)
        {
            m_isDirty = true;
        }
    }
    
    override private function set_visible(value : Bool) : Bool
    {
        super.visible = value;
        errorContainer.visible = value;
        errorTextBubbleContainer.visible = value;
        if (plug != null)
        {
            plug.visible = !hideSegments && value;
        }
        if (socket != null)
        {
            socket.visible = !hideSegments && value;
        }
        return value;
    }
    
    override public function removeFromParent(dispose : Bool = false) : Void
    {
        super.removeFromParent(dispose);
        //errorContainer.removeFromParent(dispose);
        if (plug != null)
        {
            plug.removeFromParent(dispose);
        }
        if (socket != null)
        {
            socket.removeFromParent(dispose);
        }
    }
    
    override public function dispose() : Void
    {
        if (m_disposed)
        {
            return;
        }
        
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        removeEventListener(EdgeContainerEvent.CREATE_JOINT, onCreateJoint);
        removeEventListener(EdgeContainerEvent.SEGMENT_DELETED, onSegmentDeleted);
        removeEventListener(EdgeContainerEvent.RUBBER_BAND_SEGMENT, onRubberBandSegment);
        removeEventListener(EdgeContainerEvent.HOVER_EVENT_OVER, onHoverOver);
        removeEventListener(EdgeContainerEvent.HOVER_EVENT_OUT, onHoverOut);
        removeEventListener(EdgeContainerEvent.SAVE_CURRENT_LOCATION, onSaveLocation);
        removeEventListener(EdgeContainerEvent.RESTORE_CURRENT_LOCATION, onRestoreLocation);
        removeEventListener(EdgeContainerEvent.INNER_SEGMENT_CLICKED, onInnerBoxSegmentClicked);
        if (errorTextBubble != null)
        {
            errorTextBubble.removeFromParent(true);
        }
        if (errorTextBubbleContainer != null)
        {
            errorTextBubbleContainer.removeFromParent(true);
        }
        if (errorContainer != null)
        {
            errorContainer.removeFromParent(true);
        }
        if (m_errorParticleSystem != null)
        {
            m_errorParticleSystem.removeFromParent(true);
        }
        m_errorParticleSystem = null;
        if (plug != null)
        {
            plug.removeFromParent(true);
        }
        if (socket != null)
        {
            socket.removeFromParent(true);
        }
        
        disposeChildren();
        m_edgeSegments = new Array<GameEdgeSegment>();
        m_edgeJoints = new Array<GameEdgeJoint>();
        if (hasEventListener(EdgeContainerEvent.CREATE_JOINT))
        {
            removeEventListener(EdgeContainerEvent.CREATE_JOINT, onCreateJoint);
        }
        super.dispose();
    }
    
    private function get_plug() : Sprite
    {
        if (innerToBoxSegment == null)
        {
            return null;
        }
        return innerToBoxSegment.plug;
    }
    
    private function get_socket() : Sprite
    {
        if (innerToBoxSegment == null)
        {
            return null;
        }
        return innerToBoxSegment.socket;
    }
    
    private function updateFromProps() : Void
    {
        if (innerFromBoxSegment.edgeSegment != null)
        {
            innerFromBoxSegment.edgeSegment.setProps(m_fromNode.constraintVar.getProps());
        }
        if (innerFromBoxSegment.innerCircleJoint != null)
        {
            innerFromBoxSegment.innerCircleJoint.setProps(m_fromNode.constraintVar.getProps());
        }
        if (innerFromBoxSegment != null)
        {
            innerFromBoxSegment.m_isDirty = true;
        }
    }
    
    private function updateToProps() : Void
    {
        if (innerToBoxSegment.edgeSegment != null)
        {
            innerToBoxSegment.edgeSegment.setProps(m_toNode.constraintVar.getProps());
        }
        if (innerToBoxSegment.innerCircleJoint != null)
        {
            innerToBoxSegment.innerCircleJoint.setProps(m_toNode.constraintVar.getProps());
        }
        if (innerToBoxSegment != null)
        {
            innerToBoxSegment.m_isDirty = true;
        }
    }
    
    public function refreshConflicts(userDriven : Bool = false) : Void
    {
        m_errorProps = new PropDictionary();
        var conflicts : Int = 0;
        var fromProps : PropDictionary = m_fromNode.constraintVar.getProps();
        var toProps : PropDictionary = m_toNode.constraintVar.getProps();
        for (toProp in Reflect.fields(toProps.iterProps()))
        {
            if (!fromProps.hasProp(toProp))
            {
                m_errorProps.setProp(toProp, true);
                conflicts++;
            }
        }
        if (conflicts > 0)
        {
            if (!m_hasError)
            {
                addError();
            }
            m_hasError = true;
        }
        else
        {
            removeError(userDriven);
            m_hasError = false;
        }
    }
    
    public function hideErrorText() : Void
    {
        m_hidingErrorText = true;
        if (errorTextBubble != null)
        {
            errorTextBubble.hideText();
        }
    }
    
    public function showErrorText() : Void
    {
        m_hidingErrorText = false;
        if (errorTextBubble != null)
        {
            errorTextBubble.showText();
        }
    }
    
    override public function hideComponent(hide : Bool) : Void
    {
        super.hideComponent(hide);
    }
    
    private function addError() : Void
    {
        if (m_errorParticleSystem != null)
        {
            m_errorParticleSystem.removeFromParent(true);
        }
        m_errorParticleSystem = new ErrorParticleSystem(m_errorProps);
        m_errorParticleSystem.touchable = false;
        m_errorParticleSystem.scaleX = m_errorParticleSystem.scaleY = 4.0 / Constants.GAME_SCALE;
        
        errorContainer.touchable = false;
        errorContainer.addChild(m_errorParticleSystem);
        
        if (errorTextBubble == null)
        {
            errorTextBubble = new TextBubble(Std.string(Math.round(graphConstraint.scoring.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY))), 16, GameComponent.ERROR_COLOR, errorContainer, null, NineSliceBatch.BOTTOM_RIGHT, NineSliceBatch.CENTER, null, true, 10, 2, 0.5, 1, false, GameComponent.ERROR_COLOR);
        }
        if (m_hidingErrorText)
        {
            errorTextBubble.hideText();
        }
        else
        {
            errorTextBubble.showText();
        }
        errorTextBubbleContainer.scaleX = errorTextBubbleContainer.scaleY = 0.5;
        errorTextBubbleContainer.addChild(errorTextBubble);
        
        if (innerToBoxSegment != null && !innerToBoxSegment.m_hasError)
        {
            innerToBoxSegment.m_hasError = true;
            innerToBoxSegment.m_isDirty = true;
            positionChildren();
        }
    }
    
    private function removeError(userDriven : Bool = false) : Void
    {
        if (m_errorParticleSystem != null)
        {
            m_errorParticleSystem.removeFromParent(true);
        }
        m_errorParticleSystem = null;
        if (errorTextBubble != null)
        {
            errorTextBubble.removeFromParent();
        }
        if (innerToBoxSegment != null && innerToBoxSegment.m_hasError)
        {
            innerToBoxSegment.m_hasError = false;
            innerToBoxSegment.m_isDirty = true;
            positionChildren();
        }
        
        if (userDriven && !PipeJamGameScene.inTutorial)
        {
            dispatchEventWith(Achievements.CLASH_CLEARED_ID, true);
        }
    }
    
    private function onHoverOver(event : EdgeContainerEvent) : Void
    {
        handleHover(true);
    }
    
    private function onHoverOut(event : EdgeContainerEvent) : Void
    {
        handleHover(false);
    }
    
    //these next 4 functions deal with moving internal to node segments, or the extension pieces
    public function onSaveLocation(event : EdgeContainerEvent) : Void
    {
        saveLocation();
    }
    
    private function saveLocation() : Void
    //hasChanged = false;
    {
        
        restoreEdge = true;
        
        undoObject = {};
        undoObject.m_savedJointPoints = new Array<Dynamic>();
        
        undoObject.m_savedStartPoint = m_startPoint.clone();
        undoObject.m_savedEndPoint = m_endPoint.clone();
        
        for (pt in m_jointPoints)
        {
            undoObject.m_savedJointPoints.push(pt.clone());
        }
        
        undoObject.initialOutgoingEdgePosition = outgoingEdgePosition;
        undoObject.initialIncomingEdgePosition = incomingEdgePosition;
        
        undoObject.m_savedInnerBoxSegmentLocation = new Point(innerFromBoxSegment.interiorPt.x, innerFromBoxSegment.interiorPt.y);
    }
    
    public function onRestoreLocation(event : EdgeContainerEvent) : Void
    {
        restoreLocation();
    }
    
    private function restoreLocation() : Void
    {
        if (restoreEdge)
        {
            m_jointPoints = undoObject.m_savedJointPoints;
            m_startPoint = undoObject.m_savedStartPoint;
            m_endPoint = undoObject.m_savedEndPoint;
            positionChildren();
            innerFromBoxSegment.interiorPt.x = undoObject.m_savedInnerBoxSegmentLocation.x;
            innerFromBoxSegment.interiorPt.y = undoObject.m_savedInnerBoxSegmentLocation.y;
        }
        else
        {
            m_startPoint = undoObject.m_savedStartPoint;
            m_endPoint = undoObject.m_savedEndPoint;
            rubberBandEdge(new Point(), true);  //just force a redrawing  
            updateBoundingBox();
        }
        m_isDirty = true;
    }
    
    private function handleHover(turnHoverOn : Bool) : Void
    {
        for (j in 0...m_edgeJoints.length)
        {
            var joint : GameEdgeJoint = m_edgeJoints[j];
            joint.isHoverOn = turnHoverOn;
            joint.m_isDirty = true;
        }
        
        var segment : GameEdgeSegment;
        for (segIndex in 0...m_edgeSegments.length)
        {
            segment = m_edgeSegments[segIndex];
            segment.isHoverOn = turnHoverOn;
            segment.m_isDirty = true;
        }
        
        innerFromBoxSegment.isHoverOn = turnHoverOn;
        innerFromBoxSegment.m_isDirty = true;
        
        if (turnHoverOn)
        {
        //reorder to place on top
            
            parent.setChildIndex(this, parent.numChildren);
        }
    }
    
    private function onSegmentDeleted(event : EdgeContainerEvent) : Void
    {
        var segment : GameEdgeSegment = event.segment;
        var segmentIndex : Int = event.segmentIndex;
        if (segment == null)
        {
            return;
        }
        if (Math.isNaN(segmentIndex))
        {
            return;
        }
        if (segmentIndex - 1 < 0)
        {
            return;
        }
        if (segmentIndex + 2 > m_jointPoints.length - 1)
        {
            return;
        }
        if (m_jointPoints.length <= 4)
        {
            return;
        }
        // Remove pt1, pt2. Update pt0, pt3
        var pt0 : Point = m_jointPoints[segmentIndex - 1];
        var pt1 : Point = m_jointPoints[segmentIndex];
        var pt2 : Point = m_jointPoints[segmentIndex + 1];
        var pt3 : Point = m_jointPoints[segmentIndex + 2];
        var isHoriz : Bool;
        // 0: vert, 1:horiz, 2: vert, etc. abort if this alternating pattern is untrue
        if (pt1.x == pt2.x)
        {
            if (segmentIndex % 2 != 0)
            {
                return;
            }
            isHoriz = false;
        }
        else if (pt1.y == pt2.y)
        {
            if (segmentIndex % 2 != 1)
            {
                return;
            }
            isHoriz = true;
        }
        else
        {
            return;
        }
        if (isHoriz)
        {
            if (segmentIndex + 2 == m_jointPoints.length - 1)
            {
            // If pt3 is endpoint
                
                pt0.x = pt3.x;
            }
            else
            {
                pt3.x = pt0.x;
            }
        }
        else if (segmentIndex + 2 == m_jointPoints.length - 1)
        {
        // If pt3 is endpoint
            
            pt0.y = pt3.y;
        }
        else
        {
            pt3.y = pt0.y;
        }
        // Remove pt1, pt2
        m_jointPoints.splice(segmentIndex, 2);
        createChildren();
        updateOutsideEdgeComponents();
        positionChildren();
    }
    
    //called when a segment is double-clicked on
    private function onCreateJoint(event : EdgeContainerEvent) : Void
    //get the segment index as a guide to where to add the joint
    {
        
        var segment : GameEdgeSegment = event.segment;
        var segmentIndex : Int = event.segmentIndex;
        var startingJointIndex : Int = segmentIndex;
        var newJointPt : Point = segment.currentTouch.getLocation(this);
        //if this is a horizontal line, use the y coordinate of the current joints, else visa-versa
        if (m_jointPoints[startingJointIndex].x != m_jointPoints[startingJointIndex + 1].x)
        {
            newJointPt.y = m_jointPoints[startingJointIndex].y;
        }
        else
        {
            newJointPt.x = m_jointPoints[startingJointIndex].x;
        }
        
        var secondJointPt : Point = newJointPt.clone();
		m_jointPoints.insert(startingJointIndex + 1, secondJointPt);
		m_jointPoints.insert(startingJointIndex + 1, newJointPt);
        
        //trace("inserted to " + m_jointPoints.indexOf(newJointPt) + " , " + m_jointPoints.indexOf(secondJointPt) + " of " + m_jointPoints.length);
        createChildren();
        positionChildren();
    }
    
    //create edge segments and joints from simple point list (m_jointPoints)
    public function createChildren() : Void
    //make sure we remove the old ones
    {
        
        removeChildren();
        
        m_edgeSegments = new Array<GameEdgeSegment>();
        m_edgeJoints = new Array<GameEdgeJoint>();
        
        if (hideSegments)
        {
            return;
        }
        
        //create start joint, and then create rest when we create connecting segment
        m_startJoint = new GameEdgeJoint(0, m_isWide, m_isEditable, draggable, getProps(), m_propertyMode);
        m_startJoint.visible = !hideSegments;
        m_edgeJoints.push(m_startJoint);
        
        //now create segments and joints for second position to n
        var numJoints : Int = m_jointPoints.length;
        for (index in 1...numJoints)
        {
            var isLastSegment : Bool = false;
            var isFirstSegment : Bool = false;
            if (index + 1 == numJoints)
            {
                isLastSegment = true;
            }
            else if (index == 1)
            {
                isFirstSegment = true;
            }
            var segment : GameEdgeSegment = new GameEdgeSegment(m_dir, false, isFirstSegment, isLastSegment, m_isWide, m_isEditable, draggable, getProps(), m_propertyMode);
            segment.visible = !hideSegments;
            m_edgeSegments.push(segment);
            
            //add joint at end of segment
            var jointType : Int = GameEdgeJoint.STANDARD_JOINT;
            if (index + 2 == numJoints)
            {
                jointType = GameEdgeJoint.MARKER_JOINT;
            }
            var joint : GameEdgeJoint;
            if (index + 1 != numJoints)
            {
                joint = new GameEdgeJoint(jointType, m_isWide, m_isEditable, draggable, getProps(), m_propertyMode);
                joint.visible = !hideSegments;
                m_edgeJoints.push(joint);
                if (jointType == GameEdgeJoint.MARKER_JOINT)
                {
                    m_markerJoint = joint;
                }
            }
        }
        m_endJoint = new GameEdgeJoint(GameEdgeJoint.END_JOINT, m_isWide, m_isEditable, draggable, getProps(), m_propertyMode);
        m_endJoint.visible = !hideSegments;
        m_edgeJoints.push(m_endJoint);
    }
    
    public function positionChildren() : Void
    {
        if (!initialized)
        {
            return;
        }
        var innerBoxPt : Point;
        var boxHeight : Float;
        if (innerFromBoxSegment != null)
        {
            boxHeight = m_fromNode.boundingBox.height + 0.5;
            innerBoxPt = new Point(m_startPoint.x, m_startPoint.y - boxHeight / 2.0);
            innerFromBoxSegment.interiorPt = innerBoxPt;
            innerFromBoxSegment.m_isDirty = true;
        }
        if (innerToBoxSegment != null)
        {
            boxHeight = m_toNode.boundingBox.height + 0.5;
            innerBoxPt = new Point(m_endPoint.x, m_endPoint.y + boxHeight / 2.0);
            innerToBoxSegment.interiorPt = innerBoxPt;
            innerToBoxSegment.m_isDirty = true;
        }
        
        //move each segment to where they should be, and add them, then add front joint
        var a : Int = 0;
        var b : Int = 1;
        var segment : GameEdgeSegment;
        if (m_edgeSegments.length + 1 != m_jointPoints.length)
        {
            if (!hideSegments)
            {
                trace("Warning! " + m_id + "m_edgeSegments:" + m_edgeSegments.length + " m_jointPoints:" + m_jointPoints.length + ". Calling createChildren");
            }
            createChildren();
            return;
        }
        for (segIndex in 0...m_edgeSegments.length)
        {
            segment = m_edgeSegments[segIndex];
            var prevPoint : Point = ((segIndex > 0)) ? m_jointPoints[segIndex - 1].clone() : null;
            var startPoint : Point = m_jointPoints[segIndex].clone();
            var endPoint : Point = m_jointPoints[segIndex + 1].clone();
            
            // For plugs, make the end segment stop in the center of the plug rather than
            // connecting all the way to the box
            if (segment.m_isLastSegment && innerToBoxSegment != null && (innerToBoxSegment.getPlugYOffset() != 0))
            {
                endPoint.y -= innerToBoxSegment.getPlugYOffset() - 0.65 * InnerBoxSegment.PLUG_HEIGHT;
                updateOutsideEdgeComponents();
            }
            
            segment.updateSegment(startPoint, endPoint);
            var diff : Point = endPoint.subtract(startPoint);
            var dx : Float = 0;
            var dy : Float = 0;
            if (!EDGES_OVERLAPPING_JOINTS)
            {
                var lineSize : Float = (isWide()) ? WIDE_WIDTH : NARROW_WIDTH;
                if (diff.x != 0)
                {
                    dx = ((diff.x > 0)) ? (lineSize / 2.0) : (-lineSize / 2.0);
                }
                else
                {
                    dy = ((diff.y > 0)) ? (lineSize / 2.0) : (-lineSize / 2.0);
                }
            }
            segment.x = m_jointPoints[segIndex].x + dx;
            segment.y = m_jointPoints[segIndex].y + dy;
            
            addChildAt(segment, 0);
            
            var joint : GameEdgeJoint = m_edgeJoints[segIndex];
            if (prevPoint != null)
            {
                joint.setIncomingPoint(prevPoint.subtract(m_jointPoints[segIndex]));
            }
            joint.setOutgoingPoint(endPoint.subtract(m_jointPoints[segIndex]));
            joint.x = m_jointPoints[segIndex].x;
            joint.y = m_jointPoints[segIndex].y;
            
            if (segIndex > 0)
            {
                if (!DEBUG_LARGE_LEVELS)
                {
                    addChild(joint);
                }
            }
        }
        
        //deal with last joint special, since it's at the end of a segment
        var lastJoint : GameEdgeJoint = m_edgeJoints[m_edgeSegments.length];
        //add joint at end
        lastJoint.x = m_jointPoints[m_edgeSegments.length].x;
        lastJoint.y = m_jointPoints[m_edgeSegments.length].y;
        if (m_edgeSegments.length - 1 >= 0)
        {
            var inPoint : Point = m_jointPoints[m_edgeSegments.length - 1].clone();
            lastJoint.setIncomingPoint(inPoint.subtract(m_jointPoints[m_edgeSegments.length]));
        }
        //addChildAt(lastJoint, 0);
        
        if (!DEBUG_LARGE_LEVELS)
        {
            addChild(innerFromBoxSegment);
        }  // inner segment topmost  
        if (!DEBUG_LARGE_LEVELS)
        {
            addChild(innerToBoxSegment);
        }  // inner segment topmost  
        if (DEBUG_BOUNDING_BOX)
        {
            addChild(m_debugBoundingBox);
        }
    }
    
    private function updateOutsideEdgeComponents() : Void
    {
        var offX : Float = m_jointPoints != null && m_jointPoints.length > 0 ? m_jointPoints[m_jointPoints.length - 1].x : 0;
        var offY : Float = m_jointPoints != null && m_jointPoints.length > 0 ? m_jointPoints[m_jointPoints.length - 1].y : 0;
        var newX : Float = this.x + offX;
        var newY : Float = this.y + offY;
        
        errorContainer.x = newX;
        errorContainer.y = newY;
        
        if (plug != null)
        {
            plug.x = newX;
            plug.y = newY;
        }
        if (socket != null)
        {
            socket.x = newX;
            socket.y = newY;
        }
    }
    
    public function rubberBandEdge(deltaPoint : Point, isOutgoing : Bool) : Void
    {
        if (!isSelected)
        {
            if (isOutgoing)
            {
                m_startPoint.x = m_startPoint.x + deltaPoint.x;
                m_startPoint.y = m_startPoint.y + deltaPoint.y;
            }
            else
            {
                m_endPoint.x = m_endPoint.x + deltaPoint.x;
                m_endPoint.y = m_endPoint.y + deltaPoint.y;
            }
            var prevPoints : Int = (m_jointPoints != null) ? m_jointPoints.length : 0;
            createJointPointsArray(m_startPoint, m_endPoint);
        }
        positionChildren();
    }
    
    private function onRubberBandSegment(event : EdgeContainerEvent) : Void
    {
        if (event.segment != null)
        {
            rubberBandEdgeSegment(event.segment.updatePoint, event.segment);
            dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.SEGMENT_MOVED, event.segment, event.joint));
        }
    }
    
    public function rubberBandEdgeSegment(deltaPoint : Point, segment : GameEdgeSegment) : Void
    //update both end joints, and then redraw
    {
        
        var segmentIndex : Int = Lambda.indexOf(m_edgeSegments, segment);
        //not a innerbox segment or end segment
        if (segmentIndex != -1 && segmentIndex != 0 && segmentIndex != m_edgeSegments.length - 1)
        {
        //check for horizontal or vertical
            
            if (m_jointPoints[segmentIndex].x != m_jointPoints[segmentIndex + 1].x)
            {
                m_jointPoints[segmentIndex].y += deltaPoint.y;
                m_jointPoints[segmentIndex + 1].y += deltaPoint.y;
                if (m_jointPoints.length >= NUM_JOINTS)
                {
                // Enforce minimum length on input/output segments
                    
                    m_jointPoints[1].y = m_jointPoints[2].y = Math.max(m_jointPoints[1].y, m_jointPoints[0].y + InnerBoxSegment.PLUG_HEIGHT);
                    m_jointPoints[m_jointPoints.length - 2].y = m_jointPoints[m_jointPoints.length - 3].y = Math.min(m_jointPoints[m_jointPoints.length - 2].y, m_jointPoints[m_jointPoints.length - 1].y - InnerBoxSegment.PLUG_HEIGHT);
                }
            }
            else
            {
                m_jointPoints[segmentIndex].x += deltaPoint.x;
                m_jointPoints[segmentIndex + 1].x += deltaPoint.x;
            }
            
            //check for any really short segments, and if found, remove them. Start at the end and work backwards
            //don't do if we just added a segment
            //!!Interesting idea, but there are flaws, in that you can now create diagonal lines
            //			if(!m_recreateEdge)
            //				for(var i:int = m_jointPoints.length - 2; i >= 0; i--)
            //				{
            //					trace(Math.abs(m_jointPoints[i].x-m_jointPoints[i+1].x) + Math.abs(m_jointPoints[i].y-m_jointPoints[i+1].y));
            //					if(Math.abs(m_jointPoints[i].x-m_jointPoints[i+1].x) + Math.abs(m_jointPoints[i].y-m_jointPoints[i+1].y) < .1)
            //					{
            //						m_jointPoints.splice(i, 1);
            //						m_recreateEdge = true;
            //						trace("remove " + i);
            //					}
            //				}
            updateOutsideEdgeComponents();
            updateBoundingBox();
            positionChildren();
            m_isDirty = true;
        }
        //handle innerBoxSegment/connectionSegment updating
        else
        {
            
            {
                trackConnector(deltaPoint, segmentIndex, segment);
            }
        }
    }
    
    private function trackConnector(deltaPoint : Point, segmentIndex : Int, segment : GameEdgeSegment) : Void
    {
        var totalScaleXFactorNumber : Float = 1;
        var currentObj : DisplayObjectContainer = this;
        while (currentObj != null)
        {
            totalScaleXFactorNumber *= currentObj.scaleX;
            currentObj = currentObj.parent;
        }
        
        var containerComponent : GameNodeBase;
        
        var jointPoint : Point = new Point();
        if (segmentIndex == -1)
        {
            if (segment.m_dir == GameEdgeContainer.DIR_TO)
            {
            // innerToSegment
                
                {
                    jointPoint.x = m_edgeJoints[m_jointPoints.length - 1].x;
                    containerComponent = m_toNode;
                }
            }
            // innerFromSegment
            else
            {
                
                {
                    jointPoint.x = m_edgeJoints[0].x;
                    containerComponent = m_fromNode;
                }
            }
        }
        else if (segmentIndex == 0)
        {
            jointPoint.x = m_edgeJoints[0].x;
            containerComponent = m_fromNode;
        }
        else
        {
            jointPoint.x = m_edgeJoints[m_jointPoints.length - 1].x;
            containerComponent = m_toNode;
        }
        
        //find global coordinates of container, subtracting off joints height and width
        var containerPt : Point = new Point(containerComponent.x, containerComponent.y);
        var containerGlobalPt : Point = containerComponent.parent.localToGlobal(containerPt);
        var boundsGlobalPt : Point = containerComponent.parent.localToGlobal(new Point(containerComponent.x + containerComponent.width, 
                containerComponent.y + containerComponent.height));
        var jointGlobalPt : Point = localToGlobal(jointPoint);
        
        //make sure we are in bounds
        var lineSize : Float = (isWide()) ? GameEdgeContainer.WIDE_WIDTH : GameEdgeContainer.NARROW_WIDTH;
        var newDeltaX : Float = deltaPoint.x;
        if (containerGlobalPt.x > jointGlobalPt.x + deltaPoint.x - totalScaleXFactorNumber * lineSize)
        {
            if (deltaPoint.x < 0)
            {
                newDeltaX = 0;
            }
        }
        else if (boundsGlobalPt.x < jointGlobalPt.x + deltaPoint.x + totalScaleXFactorNumber * lineSize)
        {
            if (deltaPoint.x > 0)
            {
                newDeltaX = 0;
            }
        }
        //always take the smallest delta
        if (Math.abs(newDeltaX) < Math.abs(deltaPoint.x))
        {
            deltaPoint.x = newDeltaX;
        }
        deltaPoint.y = 0;
        //need to rubber band edges and extension edges, if they exist
        var segmentOutgoing : Bool = (segmentIndex == 0);
        if (segmentIndex == -1)
        {
            if (segment.m_dir == GameEdgeContainer.DIR_FROM)
            {
                segmentOutgoing = true;
            }
        }
        
        rubberBandEdge(deltaPoint, segmentOutgoing);
        
        if (deltaPoint.x != 0)
        {
            var movingRight : Bool = (deltaPoint.x > 0) ? true : false;
            containerComponent.organizePorts(this, movingRight);
        }
    }
    
    public function increaseInputHeight(_heightOffset : Float) : Void
    {
        createJointPointsArray(m_startPoint, m_endPoint, _heightOffset, 0.0);
        positionChildren();
        m_isDirty = true;
    }
    
    public function increaseOutputHeight(_heightOffset : Float) : Void
    {
        createJointPointsArray(m_startPoint, m_endPoint, 0.0, _heightOffset);
        positionChildren();
        m_isDirty = true;
    }
    
    //create 6 joints
    //  	beginning connection
    //		end of outgoing port extension
    //		middle point 1
    //		middle point 2
    //		start of incoming port extension
    //		end connection
    private function createJointPointsArray(startPoint : Point, endPoint : Point, inputHeightOffset : Float = 0.0, outputHeightOffset : Float = 0.0) : Void
    {
        var newEdgesNeeded : Bool = false;
        //recreate if we have a non-initialized line
        if (m_jointPoints == null)
        {
            m_jointPoints = new Array<Point>();
        }
        if (m_jointPoints.length == 0)
        {
            m_jointPoints = new Array<Point>();
            newEdgesNeeded = true;
        }
        
        //makeInitialNodesAndExtension
        if (((try cast(m_jointPoints[0], Point) catch(e:Dynamic) null) != null) && ((try cast(m_jointPoints[1], Point) catch(e:Dynamic) null) != null))
        {
            var inputHeight : Float = (try cast(m_jointPoints[1], Point) catch(e:Dynamic) null).y - (try cast(m_jointPoints[0], Point) catch(e:Dynamic) null).y;
            inputHeight += inputHeightOffset;
            inputHeight = Math.max(inputHeight, InnerBoxSegment.PLUG_HEIGHT);
            m_jointPoints[0] = startPoint.clone();
            m_jointPoints[1] = new Point(startPoint.x, startPoint.y + inputHeight);
        }
        else
        {
            m_jointPoints[0] = startPoint.clone();
            m_jointPoints[1] = new Point(startPoint.x, startPoint.y + InnerBoxSegment.PLUG_HEIGHT + outgoingEdgePosition * 0.2);
        }
        var LNGTH : Int = m_jointPoints.length;
        if (((try cast(m_jointPoints[LNGTH - 1], Point) catch(e:Dynamic) null) != null) && ((try cast(m_jointPoints[LNGTH - 2], Point) catch(e:Dynamic) null) != null))
        {
            var outputHeight : Float = (try cast(m_jointPoints[LNGTH - 1], Point) catch(e:Dynamic) null).y - (try cast(m_jointPoints[LNGTH - 2], Point) catch(e:Dynamic) null).y;
            outputHeight += outputHeightOffset;
            outputHeight = Math.max(outputHeight, InnerBoxSegment.PLUG_HEIGHT);
            m_jointPoints[LNGTH - 1] = endPoint.clone();
            m_jointPoints[LNGTH - 2] = new Point(endPoint.x, endPoint.y - outputHeight);
        }
        else
        {
            m_jointPoints[LNGTH - 1] = endPoint.clone();
            m_jointPoints[LNGTH - 2] = new Point(endPoint.x, endPoint.y - InnerBoxSegment.PLUG_HEIGHT - incomingEdgePosition * 0.2);
        }
        
        //setBottomWallOutputConnection
        if (LNGTH == NUM_JOINTS)
        {
            var xDistance : Float = m_jointPoints[LNGTH - 2].x - m_jointPoints[1].x;
            m_jointPoints[2] = new Point(m_jointPoints[1].x + .5 * xDistance, m_jointPoints[1].y);
            m_jointPoints[LNGTH - 3] = new Point(m_jointPoints[2].x, m_jointPoints[LNGTH - 2].y);
        }
        else if (m_jointPoints.length > NUM_JOINTS)
        {
        // Leave other interconnecting joints/segments alone, but
            
            // need to update the next joints' y to match the changes above
            m_jointPoints[2].y = m_jointPoints[1].y;
            m_jointPoints[LNGTH - 3].y = m_jointPoints[LNGTH - 2].y;
        }
        
        newEdgesNeeded = newEdgesNeeded || correctJointPointDiagonals();
        // If there are more joint points now than when the method began, create the edge segements
        // for those new joints
        if (newEdgesNeeded)
        {
            createChildren();
        }
        updateOutsideEdgeComponents();
        updateBoundingBox();
    }
    
    /**
		 * Add extra joints where needed such that there are only alternating vertical and horizontal edges,
		 * no edges where we're going from p1->pt2 where pt1.x != pt2.x AND pt1.y != pt2.y
		 * @return
		 */
    private function correctJointPointDiagonals() : Bool
    {
        var newJointsCreated : Bool = false;
        var previousSegmentVertical : Bool = false;
		var i : Int = 1;
        while (i < m_jointPoints.length)
        {
            var xmismatch : Bool = ((try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).x != (try cast(m_jointPoints[i], Point) catch(e:Dynamic) null).x);
            var ymismatch : Bool = ((try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).y != (try cast(m_jointPoints[i], Point) catch(e:Dynamic) null).y);
            var newPt1 : Point;
            var newPt2 : Point;
            if (xmismatch && ymismatch)
            {
                if (previousSegmentVertical)
                {
                // Make horizonal->vertical->horizonal segments
                    
                    var midx : Float = ((try cast(m_jointPoints[i], Point) catch(e:Dynamic) null).x + (try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).x) / 2.0;
                    newPt1 = new Point(midx, (try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).y);
                    newPt2 = new Point(midx, (try cast(m_jointPoints[i], Point) catch(e:Dynamic) null).y);
                    previousSegmentVertical = false;
                }
                // Make vertical->horizonal->vertical segments
                else
                {
                    
                    var midy : Float = ((try cast(m_jointPoints[i], Point) catch(e:Dynamic) null).y + (try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).y) / 2.0;
                    newPt1 = new Point((try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).x, midy);
                    newPt2 = new Point((try cast(m_jointPoints[i], Point) catch(e:Dynamic) null).x, midy);
                    previousSegmentVertical = true;
                }
				m_jointPoints.insert(i, newPt2);
				m_jointPoints.insert(i, newPt1);
                newJointsCreated = true;
                i += 2;  // we've just filled in m_jointPoints[i] and m_jointPoints[i+1] so move to i+3, i+2 check  
                continue;
            }
            else if ((ymismatch && previousSegmentVertical) || (xmismatch && !previousSegmentVertical))
            {
            // Don't want two vertical or horizontal segments in a row, duplicate prev joint
                
                newPt1 = (try cast(m_jointPoints[i - 1], Point) catch(e:Dynamic) null).clone();
				m_jointPoints.insert(i, newPt1);
                newJointsCreated = true;
            }
			i++;
            previousSegmentVertical = !previousSegmentVertical;
        }
        return newJointsCreated;
    }
    
    override private function onTouch(event : TouchEvent) : Void
    {
        if (event.target == null)
        {
            return;
        }
        if (Std.is(event.target, DisplayObject))
        {
            var doc : DisplayObject = try cast(event.target, DisplayObject) catch(e:Dynamic) null;
            while (doc.parent != null)
            {
                if (Std.is(doc.parent, InnerBoxSegment))
                {
                    return;
                }
                doc = doc.parent;
            }
        }
        super.onTouch(event);
    }
    
    private function onInnerBoxSegmentClicked(event : EdgeContainerEvent) : Void
    {
        var touchClick : Touch = null;
        for (i in 0...event.touches.length)
        {
            if (event.touches[i].phase == TouchPhase.ENDED)
            {
                touchClick = event.touches[i];
                break;
            }
        }
        var touchPoint : Point = (touchClick != null) ? new Point(touchClick.globalX, touchClick.globalY) : null;
        if (event.segment.m_dir == DIR_FROM)
        {
            m_fromNode.onClicked(touchPoint);
        }
        else if (Std.is(m_toNode, GameNode))
        {
            m_toNode.onClicked(touchPoint);
        }
    }
    
    override public function componentSelected(_isSelected : Bool) : Void
    {
        m_isDirty = true;
        isSelected = _isSelected;
    }
    
    //only use if the container it's self draws specific items.
    public function draw() : Void
    {
        for (i in 0...m_edgeSegments.length)
        {
            m_edgeSegments[i].m_isDirty = true;
        }
        for (j in 0...m_edgeJoints.length)
        {
            m_edgeJoints[j].m_isDirty = true;
        }
        innerFromBoxSegment.m_isDirty = true;
        innerToBoxSegment.m_isDirty = true;
    }
    
    public function onEnterFrame() : Void
    {
        if (m_isDirty)
        {
            draw();
            m_isDirty = false;
        }
    }
    
    public function setStartPosition(newPoint : Point) : Void
    {
        m_startPoint = newPoint.clone();
        createJointPointsArray(m_startPoint, m_endPoint);
        if (m_edgeSegments != null && m_edgeJoints != null)
        {
            positionChildren();
            m_isDirty = true;
        }
    }
    
    public function setEndPosition(newPoint : Point) : Void
    {
        m_endPoint = newPoint.clone();
        createJointPointsArray(m_startPoint, m_endPoint);
        if (m_edgeSegments != null && m_edgeJoints != null)
        {
            positionChildren();
            m_isDirty = true;
        }
    }
    
    public function getSegment(indx : Int) : GameEdgeSegment
    {
        if ((indx >= 0) && (indx < m_edgeSegments.length))
        {
            return m_edgeSegments[indx];
        }
        return null;
    }
    
    public function getSegmentIndex(segment : GameEdgeSegment) : Int
    {
        return Lambda.indexOf(m_edgeSegments, segment);
    }
    
    public function getJointIndex(joint : GameEdgeJoint) : Int
    {
        return Lambda.indexOf(m_edgeJoints, joint);
    }
    
    public static function sortOutgoingXPositions(x : GameEdgeContainer, y : GameEdgeContainer) : Int
    {
        if (x.globalStart.x < y.globalStart.x)
        {
            return -1;
        }
        else
        {
            return 1;
        }
    }
    
    public static function sortIncomingXPositions(x : GameEdgeContainer, y : GameEdgeContainer) : Int
    {
        if (x.globalEnd.x < y.globalEnd.x)
        {
            return -1;
        }
        else
        {
            return 1;
        }
    }
    
    private function get_globalStart() : Point
    {
        var start : Point = ((m_jointPoints.length > 0)) ? m_jointPoints[0].clone() : (new Point());
        return localToGlobal(start);
    }
    
    private function get_globalEnd() : Point
    {
        var end : Point = ((m_jointPoints.length > 0)) ? m_jointPoints[m_jointPoints.length - 1].clone() : (new Point());
        return localToGlobal(end);
    }
    
    // set widths of all edge segments based on ball size from Simulator
    private function setWidths(_isWide : Bool) : Void
    {
        if (m_isWide == _isWide)
        {
            return;
        }
        m_isWide = _isWide;
        if (m_edgeSegments != null)
        {
            for (segIndex in 0...m_edgeSegments.length)
            {
                var segment : GameEdgeSegment = m_edgeSegments[segIndex];
                if (segment.isWide() != _isWide)
                {
                    segment.setIsWide(_isWide);
                    segment.m_isDirty = true;
                }
            }
        }
        if (m_edgeJoints != null)
        {
            for (jointIndex in 0...this.m_edgeJoints.length)
            {
                var joint : GameEdgeJoint = m_edgeJoints[jointIndex];
                if (joint.isWide() != _isWide)
                {
                    joint.setIsWide(_isWide);
                    joint.m_isDirty = true;
                }
            }
        }
    }
    
    override public function setProps(props : PropDictionary) : Void
    {
        super.setProps(props);
        var i : Int;
        for (i in 0...m_edgeJoints.length)
        {
            try
            {
                m_edgeJoints[i].setProps(props);
            }
            catch (e : Dynamic)
            {
            }
        }
        for (i in 0...m_edgeSegments.length)
        {
            try
            {
                m_edgeSegments[i].setProps(props);
            }
            catch (e : Dynamic)
            {
            }
        }
    }
    
    override public function setPropertyMode(prop : String) : Void
    {
        super.setPropertyMode(prop);
        var i : Int;
        for (i in 0...m_edgeJoints.length)
        {
            m_edgeJoints[i].setPropertyMode(prop);
        }
        for (i in 0...m_edgeSegments.length)
        {
            m_edgeSegments[i].setPropertyMode(prop);
        }
        if (innerFromBoxSegment != null)
        {
            if (innerFromBoxSegment.edgeSegment != null)
            {
                innerFromBoxSegment.edgeSegment.setPropertyMode(prop);
            }
            if (innerFromBoxSegment.innerCircleJoint != null)
            {
                innerFromBoxSegment.innerCircleJoint.setPropertyMode(prop);
            }
        }
    }
    
    override private function getToolTipEvent() : ToolTipEvent
    // TODO: Edges appear to have isEditable == false that shouldn't, until this is fixed don't display "Locked" text
    {
        
        var lockedTxt : String = "";  //isEditable() ? "" : "Locked ";  
        var widthTxt : String = (isWide()) ? "Wide " : "Narrow ";
        var jamTxt : String = (hasError()) ? "\nwith Jam" : "";
        return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, lockedTxt + widthTxt + "Link" + jamTxt, 8);
    }
}

