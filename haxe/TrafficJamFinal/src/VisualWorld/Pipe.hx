package visualWorld;

import flash.errors.Error;
import events.CGSServerLocal;
import events.PipeChangeEvent;
import events.StampChangeEvent;
import networkGraph.*;
import system.*;
import userInterface.components.RectangularObject;
import userInterface.components.StampSelector;
import utilities.Fonts;
import utilities.Geometry;
import utilities.Metadata;
import utilities.XMath;
import utilities.XSprite;
import visualWorld.Board;
import cgs.server.logging.CGSServer;
import cgs.server.logging.actions.ClientAction;
import com.greensock.BlitMask;
import com.greensock.TimelineMax;
import com.greensock.TweenLite;
import com.greensock.easing.Linear;
import com.greensock.motionPaths.LinePath2D;
import com.greensock.motionPaths.PathFollower;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.*;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flashx.textLayout.operations.PasteOperation;
import mx.effects.Move;

/**
	 * Pipe object that graphically represents a single section of pipe that a balls travels down (splitting and merging, for example, involve multiple pipe objects) and assoicated information
	 * 
	 * NOTE: Pipe objects now represent exactly ONE EDGE from the input XML graph. This is stored as the associated_edge variable.
	 * 
	 * TODO: insert pinch points upon initialization using associated_edge
	 * TODO: Add a static method createPipeFromEdge(e:Edge):Pipe or refactor pipe initialization, there are too many parameters that aren't needed at this point.
	 * 
	 */
class Pipe extends Sprite
{
    public var edge_set_id(get, never) : String;
    public var interpolated_spline_length(get, never) : Float;

    
    /** If true, the edge id associated with this pipe will be displayed in the game for debugging */
    private static var DISPLAY_EDGE_IDS_FOR_DEBUG : Bool = false;
    
    /** Number of pixels the interpolated spline is allowed to be off by, a larger number means fewer points and a poorer fit (less smooth) */
    private static inline var SPLINE_ERROR_TOLERANCE : Float = 1.5;
    
    /** True to draw the pipe ends (mario style), false to only draw the sections of pipe (such as to use for roads in the TRAFFIC_THEME */
    private static var DRAW_PIPE_TOPS : Bool = true;
    private static var DRAW_PIPE_BOTTOMS : Bool = true;
    
    /** Control Vars for constant drop objects */
    public static var NUM_CAR_LENGTHS_IN_GROUP : Int = 1;
    //since we scale these, we need to make sure this is kept up by hand. Probably should find some other meaningful way to do this
    private static var CONSTANT_DROP_OBJECT_SEPARATION_DISTANCE : Float = 50.0 * NUM_CAR_LENGTHS_IN_GROUP;
    private static var CONSTANT_DROP_OBJECT_VELOCITY : Float = 30.0;
    
    /** time between drops in milliseconds */
    private static var DROP_OBJECT_NORMAL_FREQUENCY : Float = 4000;
    
    /** Time between rushed drops */
    private static var DROP_OBJECT_FAST_FREQUENCY : Float = 1500;
    
    private var currentDropFrequency : Float = DROP_OBJECT_NORMAL_FREQUENCY;
    
    /** Width of the pipes when wide */
    public static inline var WIDE_PIPE_WIDTH : Float = 40;
    
    /** Width of the pipes when narrow */
    public static inline var NARROW_PIPE_WIDTH : Float = 20;
    
    /** Width of the balls when wide */
    public static inline var WIDE_BALL_RADIUS : Float = 18;  // should be about 0.45 * WIDE_PIPE_WIDTH  
    
    /** Width of the balls when narrow */
    public static inline var NARROW_BALL_RADIUS : Float = 9;  // should be about 0.45 * NARROW_PIPE_WIDTH  
    
    /** Time until alternative pipe UI (color stamp picking) is displayed */
    private static inline var MOUSE_DOWN_UI_TIME : Float = 1.0;
    
    /** Length of segment to provide at top and bottom of pipe for adjoining pipes to follow for continuity */
    public static inline var ADJOINING_PIPE_SEGMENT_FOLLOW_DISTANCE : Float = 40.0;
    
    /** Size in pixels of the length of the entire bottom funnel section of pipes for transition from wide/narrow or narrow/wide */
    public static inline var FUNNEL_DISTANCE : Float = 45.0;
    
    /** Size in pixels of the length of each funneling step to be drawn, overlapping by half */
    public static inline var FUNNEL_INCREMENT_SIZE : Float = 2.0;
    
    /** Height for ball sitting above the pipe */
    public static inline var BALL_START_HEIGHT : Float = 25;
    
    public static var BUZZSAW_HEIGHT : Float;
    
    /** The first edge in the pipes */
    public var associated_edge : Edge;
    
    /** The points representing line segments that are used to approximate the spline representation of the path of this pipe */
    private var interpolated_spline_points : Array<Dynamic> = new Array<Dynamic>();
    
    /** The [0] and [1] terms are x,y respectively of the points to follow when drawing this pipe, the [2] term defines the percentage of
			this pipe to use, and (1.0 - [2]) is the percentage of width of the next pipe to use (use this for funneling) */
    private var spline_drawing_points : Array<Dynamic>;
    
    /* Similar to spline_drawing_points above, these specify the first and last segments for use by adjoining pipes to follow for continuity */
    private var top_adjoining_follow_points : Array<Dynamic>;
    private var bottom_adjoining_follow_points : Array<Dynamic>;
    
    /** The total length of the entire interpolated spline polyline */
    private var _interpolated_spline_length : Float;
    
    /** This is used for speedy lookup of getXbyY, it assumes that the function will be called in succession with increasing Y for ball drop. See definition of getXbyY for details. */
    private var last_interpolated_spline_index_accessed : Int = 0;
    
    /** Where the majority of the pipe is draw, and the glow filters are applied */
    private var main_pipe_sprite : Sprite = new Sprite();
    
    /** Used to display on top of merges/splits to avoid disconnected look, no glow filter applied */
    public var merge_sibling_sprite : Sprite = new Sprite();
    public var split_sibling_sprite : Sprite = new Sprite();
    private var bottom_joint_sprite : Sprite = new Sprite();
    private var next_joint_sprites : Array<Sprite> = new Array<Sprite>();
    
    /** Used to assign clicking actions to sprites drawn on siblings */
    private var adjoining_pipe_callbacks_assigned : Bool = false;
    
    /** Current width of the pipe */
    public var pipe_width : Float;
    
    /** Pipe width that the pipe finishes with after funneling - used for drawing the bottom section of the pipe */
    private var ending_pipe_width : Float;
    
    /** True if pipe is wide, false for narrow */
    public var is_wide : Bool;
    
    /** True if pipe is being highlighted (using a light border while being moused over, for example) */
    public var highlight : Bool = false;
    
    /** White outline indicating this pipe is currently selected */
    private var highlight_glow_filter : GlowFilter;
    
    /** White outline indicating this pipe is currently succeeded */
    private var succeeded_glow_filter : GlowFilter;
    
    /** White outline indicating this pipe is currently failed */
    private var failed_glow_filter : GlowFilter;
    
    /** True if the user is mousing over this very pipe */
    public var user_mousing_over : Bool = false;
    
    /** True if the pipe has been determined to have failed, with red outline */
    public var failed : Bool = false;
    
    /** If balls are currently dropping on this pipe */
    public var dropping : Bool = false;
    
    /** True if the balls are actively being animated using the greensock TweenLite library */
    public var animating_balls : Bool = false;
    
    /** True if balls are at top of pipe */
    public var balls_at_top_of_pipe : Bool = true;
    
    /** The pinch points drawn on this pipe (null if none) */
    public var pinch_point : PinchPoint;
    
    /** Starting X coordinate of this pipe */
    public var begin_x : Float;
    
    /** Starting Y coordinate of this pipe */
    public var begin_y : Float;
    
    /** The largest x value determined using interpolated spline_points */
    public var max_spline_x : Float;
    
    /** The smallest x value determined using interpolated spline_points */
    public var min_spline_x : Float;
    
    /** The largest y value determined using interpolated spline_points */
    public var max_spline_y : Float;
    
    /** The smallest y value determined using interpolated spline_points */
    public var min_spline_y : Float;
    
    /** Starting parametric coordinate of this pipe (0 is roughly the top of the board) */
    public var begin_t : Float;
    
    /** Unique within the board, used to link cloned board pipes to original board pipes */
    public var unique_id : Int;
    
    /** Current X coordinate of this pipe */
    public var current_x : Float;
    
    /** Current Y coordinate of this pipe */
    public var current_y : Float;
    
    /** Current parametric coordinate of this pipe */
    public var current_t : Float;
    
    /** True if a ball is being dropped into this pipe (as in START_* node kinds) */
    public var has_pipe_entrance : Bool;
    
    /** Color of the pipe */
    public var main_color : Float;
    
    /** Dark version of main_color */
    public var dark_accent_color : Float;
    
    /** Darker version of main_color */
    public var darker_accent_color : Float;
    
    /** Darkest version of main_color */
    public var darkest_accent_color : Float;
    
    /** Theme color of pipe (may be different from main_color) */
    public var theme_color : Float;
    
    /** Points used to draw the outline of the top of any START pipes */
    private var top_outline_drawing_points : Array<Dynamic>;
    
    /** Points used to draw the top of any START pipes */
    private var top_inner_drawing_points : Array<Dynamic>;
    
    /** Spline of outgoing pipe(s) used for drawing bottom section of the pipe */
    private var outgoing_polylines : Array<Array<Dynamic>>;
    
    /** Pipe color(s) of outgoing pipe(s) used for drawing bottom section of the pipe */
    private var outgoing_main_colors : Array<Dynamic>;
    
    /** Outline color(s) of outgoing pipe(s) used for drawing bottom section of the pipe */
    private var outgoing_darker_colors : Array<Dynamic>;
    
    /** Width(s) of outgoing pipe(s) used for drawing bottom section of the pipe */
    private var outgoing_widths : Array<Dynamic>;
    
    /** Most recently used values for drawing, used to determine if pipe redraw is necessary */
    private var last_drawn_width : Float;
    private var last_drawn_outgoing_widths : Array<Dynamic>;
    
    /** The entire array of drawing points used to draw the outline of a pipe with an END node, allowing for extra outline at the bottom of the pipe */
    private var end_outline_drawing_points : Array<Dynamic>;
    
    /** Desired graphics depth of the pipe (functionality not implemented) */
    public var pipe_depth : Int;
    
    /** Whether the user can click to adjust this pipe (false for gray pipes) */
    public var adjustable : Bool;
    
    /** The board instance that this pipe is drawn on */
    public var board : Board;
    
    /** Ball associated with this pipe either black (wide) or white (narrow) */
    private var ball : Ball;
    
    /** A ball visible to the user above the pipe indicating what ball will be dropped when not displayed (such as during/after a drop) */
    public var ghost_ball : Ball;
    
    /** True when the pipe has been fully created */
    public var finished_constructing : Bool = false;
    
    /** For showing the edge id for each pipe for debug, this is the textfield used */
    public var debug_edge_id_label : TextField;
    
    /** True if this pipe has a buzzsaw placed on it */
    public var has_buzzsaw : Bool = false;
    
    /** Stamps to display on the pipe (stars) indicating map keys */
    public var stamps : Array<MovieClip> = new Array<MovieClip>();
    
    /** The buzzsaws attached to the top of this pipe segment (if any) */
    public var buzzsaw_pair : BuzzsawPair;
    
    /** Timestamp that the user has clicked and held on the pipe */
    private var mouse_down_timer : Timer;
    
    /** True if user is mousing down */
    private var mousing_down : Bool = false;
    
    /** For continuation of CONNECT nodes, uses the offset of the previous pipe to specify a start delay, or how long each timeline should delay restart */
    private var constant_drop_repeat_delay : Float = 0.0;
    
    /** List of all sprites for dropping, this can be manipulated have large balls/double cars or single cars, etc */
    public var drop_objects : Array<DropObjectBase> = new Array<DropObjectBase>();
    
    public var numStoppedObjects : Int = 0;
    
    /** current stamp selector, or null */
    private var stampSelector : StampSelector = null;
    
    //used to control cars entering the pipe, so that they don't draw on top of each other
    private var dropObjectQueue : Array<DropObjectBase> = new Array<DropObjectBase>();
    private var lastDropTime : Float = 0;
    
    //position of the last stopped object, so the next can go behind it
    private var lastStoppedObject : Float;
    private var m_maxNumObjects : Float;
    
    //[Embed(source = '../../bin/assets/BuzzSaw.swf', symbol = 'BuzzSaw')]
    /** The embedded animated buzzsaw object created by Marianne (this one has a slower framerate, less distracting) */
    @:meta(Embed(source="/../lib/assets/buzz_saw_slow.swf",symbol="BuzzSawSlowMo"))

    
    public var BuzzSaw : Class<Dynamic>;
    
    public var top_layer : Sprite;
    
    public var m_onlyOneCar : Bool = false;
    public var m_onlyStartingPipes : Bool = true;
    public var m_repeatAnimation : Bool = false;
    public var m_animationsMoving : Bool = true;
    
    /**
		 * Pipe object that graphically represents a single section of pipe that a balls travels down (splitting and merging, for example, involve multiple pipe objects) and assoicated information
		 * @param	_begin_x Starting X coordinate in board space
		 * @param	_begin_y Starting Y coordinate in board space
		 * @param	_is_wide True if pipe is created as currently wide, false for narrow
		 * @param	_color Pipe color
		 * @param	_board Board instance that this pipe is drawn on
		 * @param	_has_pipe_entrance True if a ball drops into this pipe (as in START_* nodes)
		 * @param	_begin_t Starting parametric coordinate
		 * @param	_depth Desired drawing depth (functionality not implemented)
		 * @param	_adjustable True if the user can click to change widths
		 * @param	_unique_id Id unique to this pipe (unique by board) used for cloning purposes
		 * @param	_associated_edge The original XML node's outoing edge used to generate this pipe
		 */
    public function new(_begin_x : Float, _begin_y : Float, _is_wide : Bool, _color : Float, _board : Board, _has_pipe_entrance : Bool = false, _begin_t : Float = 0.0, _depth : Int = 0, _adjustable : Bool = true, _unique_id : Int = -1, _associated_edge : Edge = null)
    {
        super();
        addEventListener(PipeChangeEvent.PIPE_CHANGE, PipeJamController.mainController.pipeChanged);
        addEventListener(StampChangeEvent.STAMP_SET_CHANGE, updateMovingObjects);
        
        //super(_begin_x, _begin_y, WIDE_PIPE_WIDTH, WIDE_PIPE_WIDTH);
        if (!_associated_edge.editable)
        {
            _adjustable = false;
            _color = VerigameSystem.UNADJUSTABLE_PIPE_COLOR;
        }
        
        name = "Pipe:" + _associated_edge.edge_id;
        begin_x = _begin_x;
        begin_y = _begin_y;
        begin_t = _begin_t;
        is_wide = _is_wide;
        if (is_wide)
        {
            pipe_width = WIDE_PIPE_WIDTH;
        }
        else
        {
            pipe_width = NARROW_PIPE_WIDTH;
        }
        DISPLAY_EDGE_IDS_FOR_DEBUG = VerigameSystem.DEBUG_MODE;
        main_color = _color;
        pipe_depth = _depth;
        adjustable = _adjustable;
        board = _board;
        current_x = begin_x;
        current_y = begin_y;
        current_t = begin_t;
        
        has_pipe_entrance = _has_pipe_entrance;
        associated_edge = _associated_edge;
        
        highlight_glow_filter = new GlowFilter(0xFFFFFF, 1.0, 10, 10, 3, BitmapFilterQuality.MEDIUM);
        succeeded_glow_filter = new GlowFilter(0x00FF00, 1.0, 6, 6, 2, BitmapFilterQuality.MEDIUM);
        failed_glow_filter = new GlowFilter(0xFF0000, 1.0, 6, 6, 2, BitmapFilterQuality.MEDIUM);
        
        if (associated_edge == null)
        {
            VerigameSystem.printDebug("No starting edge for pipe " + this);
        }
        if (_unique_id < 0)
        {
            unique_id = board.getNextPipeUniqueId();
        }
        else
        {
            unique_id = _unique_id;
        }
        
        var js1 : Sprite = new Sprite();
        js1.name = "next_joint_sprites[0]";
        next_joint_sprites.push(js1);
        var js2 : Sprite = new Sprite();
        js2.name = "next_joint_sprites[1]";
        next_joint_sprites.push(js2);
        
        top_layer = new Sprite();
        assignCallbacks(top_layer);
        top_layer.name = "top_layer";
        
        assignCallbacks(main_pipe_sprite);
        main_pipe_sprite.name = "main_pipe_sprite";
        
        assignCallbacks(bottom_joint_sprite);
        bottom_joint_sprite.name = "bottom_joint_sprite";
        
        merge_sibling_sprite.name = "merge_sibling_sprite";
        split_sibling_sprite.name = "split_sibling_sprite";
        
        if (adjustable)
        {
            main_pipe_sprite.buttonMode = true;
            bottom_joint_sprite.buttonMode = true;
            top_layer.buttonMode = true;
        }
        
        var r : Float = as3hx.Compat.parseInt(main_color >> 16) & 0xFF;
        var g : Float = as3hx.Compat.parseInt(main_color >> 8) & 0xFF;
        var b : Float = as3hx.Compat.parseInt(main_color) & 0xFF;
        dark_accent_color = Math.round(r * 0.85) << 16 ^ Math.round(g * 0.85) << 8 ^ Math.round(b * 0.85);
        darker_accent_color = Math.round(r * 0.75) << 16 ^ Math.round(g * 0.75) << 8 ^ Math.round(b * 0.75);
        darkest_accent_color = Math.round(r * 0.20) << 16 ^ Math.round(g * 0.20) << 8 ^ Math.round(b * 0.20);
        
        if ((!World.ONLY_INCLUDE_ORIGINAL_PIPES_IN_PIPE_ID_DICTIONARY) ||
            (World.ONLY_INCLUDE_ORIGINAL_PIPES_IN_PIPE_ID_DICTIONARY && (_board.clone_level == 0)))
        {
            _board.level.addPipeToDictionaries(this, false);
        }
        //interpolateSpline();
        has_buzzsaw = associated_edge.starting_has_buzzsaw;
        
        var _sw8_ = (Theme.CURRENT_THEME);        

        switch (_sw8_)
        {
            case Theme.PIPES_THEME, Theme.TRAFFIC_THEME:
                BUZZSAW_HEIGHT = 5 * WIDE_BALL_RADIUS;
            default:
                BUZZSAW_HEIGHT = 5 * WIDE_BALL_RADIUS;
        }
        
        themeInit();
    }
    
    private function themeInit() : Void
    {
        theme_color = XSprite.scaleColor(main_color, 0.75);
        var end_point : Point;
        if (associated_edge.spline_control_points.length > 0)
        {
            end_point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[associated_edge.spline_control_points.length - 1]);
        }
        else
        {
            VerigameSystem.printWarning("Edge found without control points: " + associated_edge.edge_id);
            end_point = new Point(begin_x, begin_y);
        }
        var begin_point : Point;
        if (associated_edge.spline_control_points.length > 0)
        {
            begin_point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[0]);
        }
        else
        {
            VerigameSystem.printWarning("Edge found without control points: " + associated_edge.edge_id);
            begin_point = new Point(begin_x, begin_y);
        }
        var _sw9_ = (Theme.CURRENT_THEME);        

        switch (_sw9_)
        {
            case Theme.PIPES_THEME:
                DRAW_PIPE_TOPS = true;
                DRAW_PIPE_BOTTOMS = true;
            case Theme.TRAFFIC_THEME:
                DRAW_PIPE_TOPS = false;
                DRAW_PIPE_BOTTOMS = false;
                var _sw10_ = (associated_edge.from_node.kind);                

                switch (_sw10_)
                {
                    case NodeTypes.CONNECT, NodeTypes.MERGE:

                        switch (_sw10_)
                        {case NodeTypes.CONNECT:
                                var connect_sign : MovieClip = new ArtStreetConnect();
                                XSprite.applyColorTransform(connect_sign, theme_color);
                                assignCallbacks(connect_sign);
                                connect_sign.buttonMode = true;
                                var connect_width : Float = connect_sign.width;
                                var connect_height : Float = connect_sign.height;
                                connect_sign.scaleX = 0.6;
                                connect_sign.scaleY = 0.6;
                                connect_sign.x = begin_point.x;
                                connect_sign.y = begin_point.y;
                                //	board.node_theme_art_pane.addChild(connect_sign);
                                break;
                        }
                        var merge_sign : MovieClip = new ArtSignMerge();
                        var merge_width : Float = merge_sign.width;
                        var merge_height : Float = merge_sign.height;
                        merge_sign.scaleX = 0.6;
                        merge_sign.scaleY = 0.6;
                        merge_sign.x = begin_point.x;
                        merge_sign.y = begin_point.y;
                        board.node_theme_art_pane.addChild(merge_sign);
                    case NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.START_SMALL_BALL:
                        var start_sign : MovieClip = new ArtStreetStart();
                        XSprite.applyColorTransform(start_sign, theme_color);
                        assignCallbacks(start_sign);
                        start_sign.buttonMode = true;
                        var start_width : Float = start_sign.width;
                        var start_height : Float = start_sign.height;
                        start_sign.scaleX = 0.6;
                        start_sign.scaleY = 0.6;
                        start_sign.x = begin_point.x;
                        start_sign.y = begin_point.y;
                        board.node_theme_art_pane.addChild(start_sign);
                }
                var _sw11_ = (associated_edge.to_node.kind);                

                switch (_sw11_)
                {
                    case NodeTypes.BALL_SIZE_TEST:
                        var test_sign : MovieClip = new ArtSignRoundabout();
                        var left_wide : Bool = true;  // Assume the left outgoing edge is wide, test otherwise  
                        // DETERMINE IF WIDE PIPE GOES LEFT OR RIGHT!
                        if (associated_edge.to_node.outgoing_ports.length == 2)
                        {
                            if ((associated_edge.to_node.outgoing_ports[0].edge.spline_control_points.length > 0)
                                && (associated_edge.to_node.outgoing_ports[1].edge.spline_control_points.length > 0))
                            {
                                var shorter_edge : Edge = associated_edge.to_node.outgoing_ports[0].edge;
                                var longer_edge : Edge = associated_edge.to_node.outgoing_ports[1].edge;
                                if (shorter_edge.spline_control_points[shorter_edge.spline_control_points.length - 1].y
                                    > longer_edge.spline_control_points[longer_edge.spline_control_points.length - 1].y)
                                {
                                    var tmp_edge : Edge = shorter_edge;
                                    shorter_edge = longer_edge;
                                    longer_edge = tmp_edge;
                                    tmp_edge = null;
                                }
                                var long_edge_pt_index : Int = 0;
                                for (short_edge_pt/* AS3HX WARNING could not determine type for var: short_edge_pt exp: EField(EIdent(shorter_edge),spline_control_points) type: null */ in shorter_edge.spline_control_points)
                                {
                                    var long_edge_pt : Point = longer_edge.spline_control_points[long_edge_pt_index];
                                    if (long_edge_pt.x < short_edge_pt.x)
                                    {
                                        if (!longer_edge.starting_is_wide)
                                        {
                                            left_wide = false;
                                        }
                                        break;
                                    }
                                    if (long_edge_pt.x > short_edge_pt.x)
                                    {
                                        if (longer_edge.starting_is_wide)
                                        {
                                            left_wide = false;
                                        }
                                        break;
                                    }
                                    if (short_edge_pt.y > long_edge_pt.y)
                                    {
                                        if (long_edge_pt_index + 1 <= longer_edge.spline_control_points.length - 1)
                                        
                                        // Move to next point{
                                            
                                            long_edge_pt_index++;
                                        }
                                    }
                                }
                            }
                        }
                        if (left_wide)
                        {
                            test_sign.gotoAndStop(1);
                        }
                        else
                        {
                            test_sign.gotoAndStop(2);
                        }
                        var split_width : Float = test_sign.width;
                        var split_height : Float = test_sign.height;
                        test_sign.scaleX = 0.6;
                        test_sign.scaleY = 0.6;
                        test_sign.x = end_point.x + 0.0 * test_sign.scaleX * split_width;
                        test_sign.y = end_point.y + 0.25 * test_sign.scaleY * split_height;
                        board.node_theme_art_pane.addChild(test_sign);
                    case NodeTypes.END:
                        var end_sign : MovieClip = new ArtStreetEnd();
                        assignCallbacks(end_sign);
                        end_sign.buttonMode = true;
                        var end_width : Float = end_sign.width;
                        var end_height : Float = end_sign.height;
                        end_sign.scaleX = 0.6;
                        end_sign.scaleY = 0.6;
                        end_sign.x = end_point.x + 0.0 * end_sign.scaleX * end_width;
                        end_sign.y = end_point.y + 0.25 * end_sign.scaleY * end_height;
                        board.node_theme_art_pane.addChild(end_sign);
                    case NodeTypes.SPLIT:
                        var split_sign : MovieClip = new ArtSignSplit();
                        var split_width1 : Float = split_sign.width;
                        var split_height1 : Float = split_sign.height;
                        split_sign.scaleX = 0.6;
                        split_sign.scaleY = 0.6;
                        split_sign.x = end_point.x + 0.0 * split_sign.scaleX * split_width1;
                        split_sign.y = end_point.y + 0.25 * split_sign.scaleY * split_height1;
                        board.node_theme_art_pane.addChild(split_sign);
                }
        }
    }
    
    public function addMovingObject(continueObjAnimationFromLastPipe : Bool = false, removeCurrentChildren : Bool = true, previousFlowObject : FlowObject = null) : DropObjectBase
    {
        if (removeCurrentChildren)
        {
            top_layer.removeChildren();
        }
        var car_movieclip : MovieClip = new ArtCar();
        var car_bitmapdata : BitmapData = new BitmapData(car_movieclip.width, car_movieclip.height, true);
        car_bitmapdata.draw(car_movieclip);
        var _sw12_ = (Theme.CURRENT_THEME);        

        switch (_sw12_)
        {
            case Theme.PIPES_THEME, Theme.TRAFFIC_THEME:

                switch (_sw12_)
                {case Theme.PIPES_THEME:
                    //
                    break;
                }
                {
                    if (!continueObjAnimationFromLastPipe && m_onlyStartingPipes)
                    {
                        if (!associated_edge.isStartingEdge())
                        {
                            return null;
                        }
                    }
                    
                    var path_arr : Array<Dynamic> = interpolated_spline_points.copy();
                    var path : LinePath2D = new LinePath2D(path_arr);
                    var last_car_dist : Float = _interpolated_spline_length - CONSTANT_DROP_OBJECT_SEPARATION_DISTANCE
                    * Math.floor(_interpolated_spline_length / CONSTANT_DROP_OBJECT_SEPARATION_DISTANCE);
                    constant_drop_repeat_delay = Math.max(0.0, (CONSTANT_DROP_OBJECT_SEPARATION_DISTANCE / CONSTANT_DROP_OBJECT_VELOCITY) - last_car_dist) / CONSTANT_DROP_OBJECT_VELOCITY;
                    
                    var startPoint : Point = getXYbyT(0);
                    if (m_onlyOneCar == true)
                    {
                        m_maxNumObjects = 1;
                    }
                    else
                    {
                        m_maxNumObjects = Math.floor(path.height / 50);
                    }
                    var numStoppedObjects1 : Int = 0;
                    for (obj in drop_objects)
                    {
                        if (!obj.timeline.active)
                        {
                            numStoppedObjects1++;
                        }
                    }
                    //make sure my counting is correct
                    if (numStoppedObjects1 != numStoppedObjects)
                    {
                        numStoppedObjects = numStoppedObjects1;
                    }
                    if (numStoppedObjects > m_maxNumObjects)
                    {
                        return null;
                    }
                    
                    var my_timeline : TimelineMax = new TimelineMax({
                        yoyo : false,
                        repeatDelay : constant_drop_repeat_delay
                    });
                    //my_timeline.addLabel("buzz", Math.min(0.45 * _interpolated_spline_length, BUZZSAW_HEIGHT) / CONSTANT_DROP_OBJECT_VELOCITY);
                    
                    var flowObject : FlowObject = null;
                    if (previousFlowObject != null)
                    {
                        flowObject = associated_edge.findSimilarFlowObject(previousFlowObject);
                    }
                    var my_car_object : Car = new Car(associated_edge, my_timeline, flowObject);
                    my_car_object.begin_y = startPoint.y;
                    my_car_object.pathLength = path.height;
                    top_layer.addChild(my_car_object);
                    var my_follower : PathFollower = path.addFollower(my_car_object, 0, true);
                    
                    CONSTANT_DROP_OBJECT_SEPARATION_DISTANCE = my_car_object.height / 2;
                    var my_params : Array<Dynamic> = new Array<Dynamic>(my_car_object);
                    my_timeline.append(new TweenLite(my_follower, path.height / CONSTANT_DROP_OBJECT_VELOCITY, {
                                progress : 1.0,
                                ease : Linear.easeNone,
                                onStart : dropObjectStart,
                                onStartParams : my_params,
                                onUpdate : dropObjectUpdate,
                                onUpdateParams : my_params,
                                onComplete : dropObjectComplete,
                                onCompleteParams : my_params
                            }));
                    
                    drop_objects.push(my_car_object);
                    //in case it sits in the queue for awhile, we need to ensure it draws right
                    my_car_object.updateImage();
                    dropObjectQueue.push(my_car_object);
                    function dropObjectStart(obj : DropObjectBase) : Void
                    {
                        obj.reset();
                        if (obj.m_flowObject == null)
                        {
                            var newFlowObject : FlowObject = associated_edge.getCurrentFlowObject();
                            obj.setFlowObject(newFlowObject);
                        }
                        //						obj.initialize();
                        obj.updateImageAndFlow();
                    };
                    
                    function dropObjectComplete(obj : DropObjectBase) : Void
                    //find the end node, and start cars for each outgoing port
                    {
                        
                        var endNode : Node = obj.m_flowObject.associatedEdge.to_node;
                        
                        var portNumber : Int = 0;
                        var newObj : DropObjectBase = null;
                        if (endNode.kind == NodeTypes.SUBBOARD)
                        
                        //find the port number for this incoming edge, and then send car out on similarly numbered exit port, if it exists{
                            
                            while (obj.m_flowObject.associatedEdge != endNode.incoming_ports[portNumber].edge)
                            {
                                portNumber++;
                            }
                            
                            if (endNode.outgoing_ports.length > portNumber)
                            {
                                newObj = endNode.outgoing_ports[portNumber].edge.associated_pipe.addMovingObject(true, false, obj.m_flowObject);
                                if (newObj != null)
                                {
                                    newObj.timeline.stop();
                                }
                            }
                        }
                        if (endNode.kind == NodeTypes.GET)
                        
                        //find the port number for this incoming edge, and then send car out on similarly numbered exit port, if it exists{
                            
                            if ((try cast(endNode, MapGetNode) catch(e:Dynamic) null).associated_mapget.argumentHasMapStamp)
                            {
                                if (obj.m_flowObject.associatedEdge == endNode.incoming_ports[2].edge)
                                {
                                    newObj = endNode.outgoing_ports[portNumber].edge.associated_pipe.addMovingObject(true, false, obj.m_flowObject);
                                    if (newObj != null)
                                    {
                                        newObj.timeline.stop();
                                    }
                                }
                            }
                            else if (obj.m_flowObject.associatedEdge == endNode.incoming_ports[3].edge)
                            {
                                newObj = endNode.outgoing_ports[portNumber].edge.associated_pipe.addMovingObject(true, false, obj.m_flowObject);
                                if (newObj != null)
                                {
                                    newObj.timeline.stop();
                                }
                            }
                        }
                        else
                        {
                            for (outgoingPort/* AS3HX WARNING could not determine type for var: outgoingPort exp: EField(EIdent(endNode),outgoing_ports) type: null */ in endNode.outgoing_ports)
                            
                            //if(outgoingPort.associated_trouble_point == null){
                                
                                {
                                    newObj = outgoingPort.edge.associated_pipe.addMovingObject(true, false, obj.m_flowObject);
                                    
                                    if (newObj != null)
                                    {
                                        newObj.timeline.stop();
                                        newObj.previousObj = obj;
                                    }
                                }
                            }
                        }
                        
                        //if we aren't continuing it, kill it
                        if (newObj == null)
                        {
                            obj.visible = false;
                        }
                        
                        //remove from current drop_objects list
                        var position : Float = obj.m_flowObject.associatedEdge.associated_pipe.drop_objects.indexOf(obj);
                        if (position == 0)
                        {
                            obj.m_flowObject.associatedEdge.associated_pipe.drop_objects.shift();
                        }
                        
                        obj.onTimelineEnd();
                    };
                    
                    function dropObjectUpdate(obj : DropObjectBase) : Void
                    //wait till here to reduce flicker
                    {
                        
                        if (obj.previousObj && obj.previousObj.alpha > 0)
                        {
                            obj.previousObj.alpha -= .25;
                        }
                        
                        //try specific actions first, and then general callback
                        if (has_buzzsaw && buzzsaw_pair != null && obj.y > (buzzsaw_pair.y))
                        {
                            numStoppedObjects = 0;
                            obj.onBuzz();
                            obj.updateImageAndFlow();
                        }
                        // 50 ~= the length of the car in front
                        else if (pinch_point != null && obj.y > pinch_point.y - ((numStoppedObjects + 1) * 50))
                        {
                            if (obj.y > pinch_point.y)
                            {
                                obj.afterPinch();
                            }
                            
                            //if we aren't beyond the pinch point already...
                            if (obj.y < pinch_point.y && obj.m_flowObject.starting_ball_type != VerigameSystem.BALL_TYPE_NARROW)
                            {
                                if (!obj.m_after_buzz)
                                {
                                    numStoppedObjects++;
                                    obj.updateImageAndFlow(true);
                                }
                            }
                            else
                            {
                                obj.updateImageAndFlow();
                            }
                        }
                        else if (obj.y > obj.begin_y + obj.pathLength)
                        {
                            obj.onBelowPipe();
                        }
                        
                        //if we want to stop this sometime in the future (if we got buzzed, we are going to keep going)
                        if (obj.m_flowObject.exit_ball_type == VerigameSystem.BALL_TYPE_NONE && !obj.m_after_buzz)
                        
                        //check to see if there's an open port to travel through{
                            
                            var endNode : Node = obj.m_flowObject.associatedEdge.to_node;
                            var openPort : Bool = false;
                            //							for each(var port:Port in endNode.outgoing_ports)
                            //							{
                            //								if(port.associated_trouble_point == null)
                            //									openPort = true;
                            //							}
                            
                            if ((openPort == false) && obj.y > obj.begin_y + (obj.pathLength - ((numStoppedObjects + 1) * 50)))
                            {
                                numStoppedObjects++;
                                obj.updateImageAndFlow(true);
                            }
                        }
                    };
                }
        }
        return my_car_object;
    }
    
    public function activate() : Void
    {
        addMovingObject();
        drawStamps();
        draw(false);
        playConstantDropAnimations(true);
    }
    
    /**
		 * Causes all the moving objects in the pipe to update any stamps that they have drawn
		 * on them.  This will be called whenever the player chooses a new stamp from the 
		 * stamp selector.
		 * @param e StampChangeEvent passed implicitly by the event
		 */
    private function updateMovingObjects(e : StampChangeEvent) : Void
    {
        for (objects in 0...top_layer.numChildren)
        {
            var object : DisplayObject = top_layer.getChildAt(objects);
            var carObject : Car = try cast(object, Car) catch(e:Dynamic) null;
            carObject.updateStamps();
        }
    }
    
    public function gameTimerInterval() : Void
    //check if we are not moving (but want to be), and if not, check the time, to see if we should start
    {
        
        var currentTimeSeconds : Float = Date.now().time;  //time in milliseconds  
        var elapsedTime : Float = currentTimeSeconds - lastDropTime;
        
        if (elapsedTime > currentDropFrequency || (dropObjectQueue.length > 0 && elapsedTime > DROP_OBJECT_FAST_FREQUENCY))
        
        //drop a new one every so often{
            
            {
                //	trace(m_animationsMoving + " " + dropObjectQueue.length);
                if (m_animationsMoving)
                {
                    if (dropObjectQueue.length > 0)
                    {
                        lastDropTime = currentTimeSeconds;
                        var obj : DropObjectBase = dropObjectQueue.shift();
                        if (obj.m_flowObject.exit_ball_type != 0)
                        {
                            obj.timeline.play();
                        }
                        
                        
                        
                        //if still more in queue, speed up drops
                        if (dropObjectQueue.length > 0)
                        {
                            currentDropFrequency = DROP_OBJECT_FAST_FREQUENCY;
                        }
                        else if (currentDropFrequency == DROP_OBJECT_FAST_FREQUENCY)
                        {
                            currentDropFrequency = DROP_OBJECT_NORMAL_FREQUENCY;
                        }
                    }
                    else if (m_onlyOneCar == false)
                    
                    //nothing in the queue right now, start a new car if wanted{
                        
                        {
                            //only at starting pipes, don't remove current
                            if (associated_edge.isStartingEdge())
                            {
                                addMovingObject(false, false);
                                lastDropTime = currentTimeSeconds;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public function assignCallbacks(doc : DisplayObjectContainer) : Void
    {
        doc.addEventListener(MouseEvent.CLICK, pipeClick);
        doc.addEventListener(MouseEvent.ROLL_OVER, pipeRollOver);
        doc.addEventListener(MouseEvent.ROLL_OUT, pipeRollOut);
        doc.addEventListener(MouseEvent.MOUSE_DOWN, pipeMouseDown);
        doc.addEventListener(MouseEvent.MOUSE_UP, pipeMouseUp);
    }
    
    /**
		 * This is called in the Board.finishBoard() method when all pipes have hopefully been created and assigned to edges.
		 */
    public function assignAdjoiningClickCallbacks() : Void
    {
        if (adjoining_pipe_callbacks_assigned || (board.clone_level > 0))
        {
            return;
        }
        // Assign click callbacks to any merge siblings
        if (associated_edge.to_node.kind == NodeTypes.MERGE)
        {
            if (associated_edge.to_node.incoming_ports[0].edge.associated_pipe == this)
            
            // This pipe is incoming_ports[0], the other must be incoming_ports[1]{
                
                if (adjustable)
                {
                    associated_edge.to_node.incoming_ports[1].edge.associated_pipe.merge_sibling_sprite.buttonMode = true;
                }
                assignCallbacks(associated_edge.to_node.incoming_ports[1].edge.associated_pipe.merge_sibling_sprite);
            }
            else if (associated_edge.to_node.incoming_ports[0].edge.associated_pipe)
            
            // This pipe is incoming_ports[1], the other must be incoming_ports[0]{
                
                if (adjustable)
                {
                    associated_edge.to_node.incoming_ports[0].edge.associated_pipe.merge_sibling_sprite.buttonMode = true;
                }
                assignCallbacks(associated_edge.to_node.incoming_ports[0].edge.associated_pipe.merge_sibling_sprite);
            }
        }
        // Assign click callbacks to any split siblings
        if (associated_edge.from_node.kind == NodeTypes.SPLIT)
        {
            if (associated_edge.from_node.outgoing_ports[0].edge.associated_pipe == this)
            
            // This pipe is outgoing_ports[0], the other must be outgoing_ports[1]{
                
                if (adjustable)
                {
                    associated_edge.from_node.outgoing_ports[1].edge.associated_pipe.split_sibling_sprite.buttonMode = true;
                }
                assignCallbacks(associated_edge.from_node.outgoing_ports[1].edge.associated_pipe.split_sibling_sprite);
            }
            else if (associated_edge.to_node.incoming_ports[0].edge.associated_pipe)
            
            // This pipe is outgoing_ports[1], the other must be outgoing_ports[0]{
                
                if (adjustable)
                {
                    associated_edge.from_node.outgoing_ports[0].edge.associated_pipe.split_sibling_sprite.buttonMode = true;
                }
                assignCallbacks(associated_edge.from_node.outgoing_ports[0].edge.associated_pipe.split_sibling_sprite);
            }
        }
        // Assign click callbacks for any outgoing pipes
        if (associated_edge.to_node.outgoing_ports.length > 0)
        {
            if (associated_edge.to_node.outgoing_ports[0] != null)
            {
                if (associated_edge.to_node.outgoing_ports[0].edge.associated_pipe)
                {
                    if (associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.adjustable)
                    {
                        next_joint_sprites[0].buttonMode = true;
                    }
                    associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.assignCallbacks(next_joint_sprites[0]);
                }
            }
        }
        if (associated_edge.to_node.outgoing_ports.length > 1)
        {
            if (associated_edge.to_node.outgoing_ports[1] != null)
            {
                if (associated_edge.to_node.outgoing_ports[1].edge.associated_pipe)
                {
                    if (associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.adjustable)
                    {
                        next_joint_sprites[1].buttonMode = true;
                    }
                    associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.assignCallbacks(next_joint_sprites[1]);
                }
            }
        }
        adjoining_pipe_callbacks_assigned = true;
    }
    
    public function playConstantDropAnimations(start : Bool) : Void
    {
        startConstantDropObjects(start);
    }
    
    public function removeDropAnimations() : Void
    {
        for (index in 0...drop_objects.length)
        {
            var running_drop_object : DropObjectBase = drop_objects[index];
            running_drop_object.timeline.kill();
            if (running_drop_object.parent == top_layer)
            {
                top_layer.removeChild(running_drop_object);
            }
            //mark as null, and then compress array next pass
            drop_objects[index] = null;
        }
        //move everything down to fill in null spots, and then slice off the end
        var currentPosition : Int = 0;
        for (index1 in 0...drop_objects.length)
        {
            drop_objects[currentPosition] = drop_objects[index1];
            if (drop_objects[index1] != null)
            {
                currentPosition++;
            }
        }
        if (currentPosition > 0)
        {
            drop_objects.slice(0, currentPosition);
        }
        else
        {
            drop_objects = new Array<DropObjectBase>();
        }
        
        //and then kill everything queued
        dropObjectQueue = new Array<DropObjectBase>();
    }
    
    
    public function toggleConstantDropAnimations() : Void
    {
        m_animationsMoving = !m_animationsMoving;
        for (running_drop_object in drop_objects)
        {
            running_drop_object.startAnimation(m_animationsMoving);
        }
    }
    
    public function startConstantDropObjects(start : Bool) : Void
    {
        for (running_drop_object in drop_objects)
        {
            m_animationsMoving = start;
            running_drop_object.startAnimation(start);
        }
    }
    
    /**
		 * Called by Board.finishBoard() after all edges have had their pipes created/linked
		 */
    public function finishPipe() : Void
    {
        interpolateSpline();
        assignAdjoiningClickCallbacks();
        
        // For merge, specify polylines to follow upwards for continuity, for start specify points for wide opening
        var incoming_polylines : Array<Array<Dynamic>> = new Array<Array<Dynamic>>();
        top_outline_drawing_points = new Array<Dynamic>();
        top_inner_drawing_points = new Array<Dynamic>();
        if (associated_edge.from_node)
        {
            var _sw13_ = (associated_edge.from_node.kind);            

            switch (_sw13_)
            {
                case NodeTypes.MERGE:
                    incoming_polylines.push(associated_edge.from_node.incoming_ports[0].edge.associated_pipe.bottom_adjoining_follow_points);
                    incoming_polylines.push(associated_edge.from_node.incoming_ports[1].edge.associated_pipe.bottom_adjoining_follow_points);
                case NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_SMALL_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL:
                    var p1 : Point = getXYbyT(0.0);
                    var p2 : Point = getXYbyT(WIDE_BALL_RADIUS / _interpolated_spline_length);
                    var dx : Float = (p1.x - p2.x) / XMath.getDist(p1, p2);
                    var dy : Float = (p1.y - p2.y) / XMath.getDist(p1, p2);
                    var top_p0 : Point = new Point(p1.x + dx * (4 + BALL_START_HEIGHT - 0.5 * WIDE_BALL_RADIUS), 
                    p1.y + dy * (4 + BALL_START_HEIGHT - 0.5 * WIDE_BALL_RADIUS));
                    var top_p1 : Point = new Point(p1.x + dx * (BALL_START_HEIGHT - 0.5 * WIDE_BALL_RADIUS), 
                    p1.y + dy * (BALL_START_HEIGHT - 0.5 * WIDE_BALL_RADIUS));
                    var top_p2 : Point = new Point(p1.x + dx * 4, p1.y + dy * 4);
                    var top_pt_arr : Array<Dynamic> = getPolylineFromT(0.0, 2 * WIDE_BALL_RADIUS / _interpolated_spline_length);
                    for (j in 0...top_pt_arr.length)
                    {
                        if (j == 0)
                        {
                            top_outline_drawing_points.push(new Array<Dynamic>(top_pt_arr[j].x, top_pt_arr[j].y, 1.0));
                            top_inner_drawing_points.push(new Array<Dynamic>(top_pt_arr[j].x, top_pt_arr[j].y, 0.0));
                        }
                        else
                        {
                            top_outline_drawing_points.push(new Array<Dynamic>(top_pt_arr[j].x, top_pt_arr[j].y, 0.0));
                            top_inner_drawing_points.push(new Array<Dynamic>(top_pt_arr[j].x, top_pt_arr[j].y, 0.0));
                        }
                    }
                    top_outline_drawing_points.unshift(new Array<Dynamic>(top_p2.x, top_p2.y, 1.0));
                    top_outline_drawing_points.unshift(new Array<Dynamic>(top_p1.x, top_p1.y, 1.0));
                    top_outline_drawing_points.unshift(new Array<Dynamic>(top_p0.x, top_p0.y, 1.0));
                    top_inner_drawing_points.unshift(new Array<Dynamic>(top_p2.x, top_p2.y, 1.0));
                    top_inner_drawing_points.unshift(new Array<Dynamic>(top_p1.x, top_p1.y, 1.0));
            }
        }
        
        outgoing_polylines = new Array<Array<Dynamic>>();
        outgoing_main_colors = new Array<Dynamic>();
        outgoing_darker_colors = new Array<Dynamic>();
        end_outline_drawing_points = new Array<Dynamic>();
        
        // Gather outgoing pipe info to be used for drawing bottom pipe section
        if (associated_edge.to_node)
        {
            var _sw14_ = (associated_edge.to_node.kind);            

            switch (_sw14_)
            {
                case NodeTypes.CONNECT, NodeTypes.MERGE:
                    if (!associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.top_adjoining_follow_points)
                    {
                        associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.interpolateSpline();
                    }
                    if (associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.top_adjoining_follow_points)
                    {
                        outgoing_polylines.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.top_adjoining_follow_points);
                        outgoing_main_colors.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.main_color);
                        outgoing_darker_colors.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.dark_accent_color);
                    }
                case NodeTypes.SPLIT:
                    if (!associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.top_adjoining_follow_points)
                    {
                        associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.interpolateSpline();
                    }
                    if (associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.top_adjoining_follow_points)
                    {
                        outgoing_polylines.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.top_adjoining_follow_points);
                        //var split_spline0:Array = associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.spline_drawing_points.concat();
                        //for (var i:int = 0; i < split_spline0.length; i++) {
                        //	split_spline0[i][2] = 1.0 - split_spline0[i][2];
                        //}
                        //outgoing_polylines.push(split_spline0);
                        //outgoing_polylines.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.spline_drawing_points);
                        outgoing_main_colors.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.main_color);
                        outgoing_darker_colors.push(associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.dark_accent_color);
                    }
                    if (!associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.top_adjoining_follow_points)
                    {
                        associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.interpolateSpline();
                    }
                    if (associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.top_adjoining_follow_points)
                    {
                        outgoing_polylines.push(associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.top_adjoining_follow_points);
                        //var split_spline1:Array = associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.spline_drawing_points.concat();
                        //for (var i:int = 0; i < split_spline1.length; i++) {
                        //	split_spline1[i][2] = 1.0 - split_spline1[i][2];
                        //}
                        //outgoing_polylines.push(split_spline1);
                        //outgoing_polylines.push(associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.spline_drawing_points);
                        outgoing_main_colors.push(associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.main_color);
                        outgoing_darker_colors.push(associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.dark_accent_color);
                    }
                case NodeTypes.SUBBOARD, NodeTypes.END:

                    switch (_sw14_)
                    {case NodeTypes.SUBBOARD:
                            // For subnetworks, just have the pipe continue straight downwards
                            var downward_traj : Array<Dynamic> = new Array<Dynamic>();
                            downward_traj.push(new Array<Dynamic>(interpolated_spline_points[interpolated_spline_points.length - 1].x, interpolated_spline_points[interpolated_spline_points.length - 1].y, 0.0));
                            downward_traj.push(new Array<Dynamic>(interpolated_spline_points[interpolated_spline_points.length - 1].x, interpolated_spline_points[interpolated_spline_points.length - 1].y + ADJOINING_PIPE_SEGMENT_FOLLOW_DISTANCE, 0.0));
                            //outgoing_polylines.push(downward_traj);
                            break;
                    }
                    var ep1 : Point = getXYbyT(1.0);
                    var ep2 : Point = getXYbyT(1.0 - WIDE_BALL_RADIUS / _interpolated_spline_length);
                    var dx_e : Float = (ep1.x - ep2.x) / XMath.getDist(ep1, ep2);
                    var dy_e : Float = (ep1.y - ep2.y) / XMath.getDist(ep1, ep2);
                    var end_ext : Point = new Point(ep1.x + dx_e * 0.5 * WIDE_BALL_RADIUS, ep1.y + dy_e * 0.5 * WIDE_BALL_RADIUS);
                    var pipe_end_arr : Array<Dynamic> = new Array<Dynamic>(new Array<Dynamic>(end_ext.x, end_ext.y, 1.0));
                    end_outline_drawing_points = spline_drawing_points.concat(pipe_end_arr);
            }
        }
        finished_constructing = true;
        drawStamps();
        draw(false);
        associated_edge.linked_edge_set.addEventListener(StampChangeEvent.STAMP_ACTIVATION, onStampChange);
    }
    
    private function onStampChange(e : StampChangeEvent) : Void
    {
        if (VerigameSystem.LOGGING_ON)
        {
            var stampAction : ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_CHANGE_PIPE_STAMPS);
            stampAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_PIPE_EDGE_ID, associated_edge.edge_id);
            
            var stampDict : Dynamic = {};
            for (edge_set_id in Reflect.fields(associated_edge.linked_edge_set.stamp_dictionary))
            {
                Reflect.setField(stampDict, edge_set_id, Std.string(try cast(associated_edge.linked_edge_set.stamp_dictionary[edge_set_id], StampRef) catch(e:Dynamic) null));
            }
            stampAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_STAMP_DICTIONARY, stampDict);
            CGSServerLocal.logQuestAction(stampAction);
        }
        
        //forward event to those listening
        var changeEvent : StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_SET_CHANGE, null, associated_edge);
        dispatchEvent(changeEvent);
        
        board.level.updateLinkedPipes(this, this.is_wide);
        drawStamps();
        draw();
        board.updateCloneChildrenToMatch();
    }
    
    private var STAMP_DISTANCE(default, never) : Float = 40.0;
    public function drawStamps() : Void
    {
        for (stamp in stamps)
        {
            if (stamp.parent)
            {
                stamp.parent.removeChild(stamp);
            }
            stamp = null;
        }
        stamps = new Array<MovieClip>();
        var num_stamps : Int = associated_edge.linked_edge_set.num_active_stamps;
        if (num_stamps == 0)
        {
            return;
        }
        var step : Float = STAMP_DISTANCE / _interpolated_spline_length;
        var stamp_indx : Int = 0;
        var t : Float = step;
        while (t <= 1.0 - step)
        {
            var next_stamp_edge_id : String = associated_edge.linked_edge_set.getActiveStampEdgeSetIdAt(stamp_indx % num_stamps);
            var next_stamp_color : Float = board.level.getColorByEdgeSetId(next_stamp_edge_id);
            var my_stamp : MovieClip = new ArtStar();
            XSprite.applyColorTransform(my_stamp, next_stamp_color);
            var stamp_pt : Point = getXYbyT(t);
            my_stamp.mouseEnabled = false;
            my_stamp.x = stamp_pt.x;
            my_stamp.y = stamp_pt.y;
            my_stamp.scaleX = 0.75;
            my_stamp.scaleY = 0.75;
            stamps.push(my_stamp);
            stamp_indx++;
            t += step;
        }
    }
    
    public function getActiveStamps() : Array<MovieClip>
    {
        var stampVector : Array<MovieClip> = new Array<MovieClip>();
        
        var num_stamps : Int = associated_edge.linked_edge_set.num_active_stamps;
        
        for (stamp_indx in 0...num_stamps)
        {
            var next_stamp_edge_id : String = associated_edge.linked_edge_set.getActiveStampEdgeSetIdAt(stamp_indx);
            var color : Float = board.level.getColorByEdgeSetId(next_stamp_edge_id);
            var my_stamp : MovieClip = new ArtStar();
            XSprite.applyColorTransform(my_stamp, color);
            stampVector.push(my_stamp);
        }
        
        return stampVector;
    }
    
    public function updateOutgoingWidths() : Void
    {
        ending_pipe_width = pipe_width;
        outgoing_widths = new Array<Dynamic>(2);
        outgoing_widths[0] = pipe_width;
        outgoing_widths[1] = pipe_width;
        if (associated_edge.to_node)
        {
            var _sw15_ = (associated_edge.to_node.kind);            

            switch (_sw15_)
            {
                case NodeTypes.CONNECT, NodeTypes.MERGE:
                // Funnel to whatever the width of the outgoing pipe is
                if (associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.is_wide)
                {
                    ending_pipe_width = WIDE_PIPE_WIDTH;
                    outgoing_widths[0] = WIDE_PIPE_WIDTH;
                }
                else
                {
                    ending_pipe_width = NARROW_PIPE_WIDTH;
                    outgoing_widths[0] = NARROW_PIPE_WIDTH;
                }
                case NodeTypes.BALL_SIZE_TEST:
                    // For null test since at least one outgoing pipe is wide by definition, funnel to wide
                    ending_pipe_width = WIDE_PIPE_WIDTH;
                    outgoing_widths[0] = WIDE_PIPE_WIDTH;
                case NodeTypes.SPLIT:
                    // For splits, if either outgoing pipe is wide, funnel to wide - otherwise funnel to narrow
                    ending_pipe_width = NARROW_PIPE_WIDTH;
                    outgoing_widths[0] = NARROW_PIPE_WIDTH;
                    outgoing_widths[1] = NARROW_PIPE_WIDTH;
                    if (associated_edge.to_node.outgoing_ports[0].edge.associated_pipe.is_wide)
                    {
                        ending_pipe_width = WIDE_PIPE_WIDTH;
                        outgoing_widths[0] = WIDE_PIPE_WIDTH;
                    }
                    if (associated_edge.to_node.outgoing_ports[1].edge.associated_pipe.is_wide)
                    {
                        ending_pipe_width = WIDE_PIPE_WIDTH;
                        outgoing_widths[1] = WIDE_PIPE_WIDTH;
                    }
                case NodeTypes.SUBBOARD:
                // Funnel to whatever the width of the associated pipe inside the subnetwork is
                if ((try cast(associated_edge.to_port, SubnetworkPort) catch(e:Dynamic) null).linked_subnetwork_edge)
                {
                    if ((try cast(associated_edge.to_port, SubnetworkPort) catch(e:Dynamic) null).linked_subnetwork_edge.associated_pipe.is_wide)
                    {
                        ending_pipe_width = WIDE_PIPE_WIDTH;
                        outgoing_widths[0] = WIDE_PIPE_WIDTH;
                    }
                    else
                    {
                        ending_pipe_width = NARROW_PIPE_WIDTH;
                        outgoing_widths[0] = NARROW_PIPE_WIDTH;
                    }
                }
            }
        }
    }
    
    /**
		 * This function uses the interpolated spline polyline to return the given XY at an input _t (0.0 = top of pipe, 1.0 = bottom of pipe)
		 * @param	_t Input _t (0.0 = top of pipe, 1.0 = bottom of pipe)
		 * @return Point on pipe for given _t
		 */
    public function getXYbyT(_t : Float) : Point
    {
        if (interpolated_spline_points.length == 0)
        {
            interpolateSpline();
        }
        if (_interpolated_spline_length <= 0.0)
        {
            throw new Error("Negative/zero length spline found for edge " + associated_edge.edge_id);
            return null;
        }
        var next_i : Int = 1;
        var dist_traveled : Float = 0.0;
        while (interpolated_spline_points.length > next_i)
        {
            var dist1 : Float = XMath.getDist(interpolated_spline_points[next_i], interpolated_spline_points[next_i - 1]) / _interpolated_spline_length;
            if (dist_traveled + dist1 >= _t)
            {
                break;
            }
            else
            {
                dist_traveled += dist1;
            }
            next_i++;
        }
        if (next_i >= interpolated_spline_points.length)
        {
            return interpolated_spline_points[interpolated_spline_points.length - 1];
        }
        var dist : Float = XMath.getDist(interpolated_spline_points[next_i], interpolated_spline_points[next_i - 1]) / _interpolated_spline_length;
        if (dist <= 0.0)
        {
            return interpolated_spline_points[next_i - 1];
        }
        var new_x : Float = XMath.lerp((_t - dist_traveled) / dist, interpolated_spline_points[next_i - 1].x, interpolated_spline_points[next_i].x);
        var new_y : Float = XMath.lerp((_t - dist_traveled) / dist, interpolated_spline_points[next_i - 1].y, interpolated_spline_points[next_i].y);
        return new Point(new_x, new_y);
    }
    
    /**
		 * Get a polyline connected the given start and ending t values along the spline for this pipe
		 * @param	_begin_t T value to begin at (0.0 = top of pipe, 1.0 = bottom of pipe)
		 * @param	_end_t T value to end at (0.0 = top of pipe, 1.0 = bottom of pipe)
		 * @return An array of points representing the requested polyline
		 */
    public function getPolylineFromT(_begin_t : Float, _end_t : Float) : Array<Dynamic>
    {
        var polyline : Array<Dynamic> = new Array<Dynamic>();
        
        if (interpolated_spline_points.length == 0)
        {
            interpolateSpline();
        }
        if (_interpolated_spline_length <= 0.0)
        {
            throw new Error("Negative/zero length spline found for edge " + associated_edge.edge_id);
            return polyline;
        }
        var next_i : Int = 1;
        var dist_remaining : Float = _begin_t;
        while (interpolated_spline_points.length > next_i)
        {
            var dist2 : Float = XMath.getDist(interpolated_spline_points[next_i], interpolated_spline_points[next_i - 1]) / _interpolated_spline_length;
            if (dist_remaining - dist2 <= 0.0)
            {
                break;
            }
            else
            {
                dist_remaining -= dist2;
            }
            next_i++;
        }
        if (next_i >= interpolated_spline_points.length)
        {
            return polyline;
        }
        var dist : Float = XMath.getDist(interpolated_spline_points[next_i], interpolated_spline_points[next_i - 1]) / _interpolated_spline_length;
        if (dist <= 0.0)
        {
            return polyline;
        }
        var my_begin_x : Float = XMath.lerp(dist_remaining / dist, interpolated_spline_points[next_i - 1].x, interpolated_spline_points[next_i].x);
        var my_begin_y : Float = XMath.lerp(dist_remaining / dist, interpolated_spline_points[next_i - 1].y, interpolated_spline_points[next_i].y);
        var start_pt : Point = new Point(my_begin_x, my_begin_y);
        polyline.push(start_pt);
        var dist_to_next_point : Float = XMath.getDist(start_pt, interpolated_spline_points[next_i]) / _interpolated_spline_length;
        if (dist_to_next_point > _end_t - _begin_t)
        
        // If end_t is between the starting point we just found and the next polyline point, interpolate and return result{
            
            var end_x : Float = XMath.lerp((_end_t - _begin_t) / dist_to_next_point, start_pt.x, interpolated_spline_points[next_i].x);
            var end_y : Float = XMath.lerp((_end_t - _begin_t) / dist_to_next_point, start_pt.y, interpolated_spline_points[next_i].y);
            var end_pt : Point = new Point(end_x, end_y);
            polyline.push(end_pt);
            return polyline;
        }
        // Now find end_t
        next_i++;
        var dist_traveled : Float = dist_to_next_point;
        while (interpolated_spline_points.length > next_i)
        {
            var dist3 : Float = XMath.getDist(interpolated_spline_points[next_i], interpolated_spline_points[next_i - 1]) / _interpolated_spline_length;
            if (dist_traveled + dist3 >= _end_t - _begin_t)
            {
                break;
            }
            else
            {
                dist_traveled += dist3;
            }
            polyline.push(interpolated_spline_points[next_i].clone());
            next_i++;
        }
        if (next_i >= interpolated_spline_points.length)
        {
            return polyline;
        }
        var dist4 : Float = XMath.getDist(interpolated_spline_points[next_i], interpolated_spline_points[next_i - 1]) / _interpolated_spline_length;
        if (dist4 <= 0.0)
        {
            return polyline;
        }
        var new_x : Float = XMath.lerp((_end_t - _begin_t - dist_traveled) / dist4, interpolated_spline_points[next_i - 1].x, interpolated_spline_points[next_i].x);
        var new_y : Float = XMath.lerp((_end_t - _begin_t - dist_traveled) / dist4, interpolated_spline_points[next_i - 1].y, interpolated_spline_points[next_i].y);
        polyline.push(new Point(new_x, new_y));
        return polyline;
    }
    
    private function get_edge_set_id() : String
    {
        return associated_edge.linked_edge_set.id;
    }
    
    /**
		 * Function to perform vector drawing/redrawing or simply adding predrawn sprites to this pipe object
		 */
    public function draw(drawDropObjects : Bool = true) : Void
    {
        if (!finished_constructing)
        {
            return;
        }
        
        if (board.clone_level > 0)
        {
            return;
        }
        
        if (interpolated_spline_points.length == 0)
        {
            interpolateSpline();
        }
        
        if (is_wide)
        {
            pipe_width = WIDE_PIPE_WIDTH;
        }
        else
        {
            pipe_width = NARROW_PIPE_WIDTH;
        }
        
        if (associated_edge.has_pinch && (pinch_point == null))
        {
            var pinch_y_off : Float = 0.0;
            var _sw16_ = (Theme.CURRENT_THEME);            

            switch (_sw16_)
            {
                case Theme.PIPES_THEME:
                    pinch_y_off = 0.5 * WIDE_BALL_RADIUS;
                case Theme.TRAFFIC_THEME:
                    pinch_y_off = 1.5 * WIDE_BALL_RADIUS;
            }
            var loc1 : Point = getXYbyT(0.5 + pinch_y_off / _interpolated_spline_length);
            pinch_point = new PinchPoint(loc1.x, loc1.y, this);
            pinch_point.x = loc1.x;
            pinch_point.y = loc1.y;
            var loc2 : Point = getXYbyT(0.5 + (1.0 * WIDE_BALL_RADIUS + pinch_y_off) / _interpolated_spline_length);
            var rot_angle : Float = Math.atan2(loc2.y - loc1.y, loc2.x - loc1.x);
            pinch_point.rotation = -90 + 180 * rot_angle / Math.PI;
        }
        
        var add_ball : Bool = animating_balls;
        // Insert a ball on top if needed
        if (associated_edge.from_port)
        {
            if (associated_edge.from_port.node)
            {
                var _sw17_ = (associated_edge.from_port.node.kind);                

                switch (_sw17_)
                {
                    case NodeTypes.START_LARGE_BALL, NodeTypes.START_SMALL_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.INCOMING:
                        if (balls_at_top_of_pipe)
                        {
                            add_ball = true;
                        }
                }
            }
        }
        // Insert a ball on at the bottom if needed
        if (associated_edge.to_port)
        {
            if (associated_edge.to_port.node)
            {
                var _sw18_ = (associated_edge.to_port.node.kind);                

                switch (_sw18_)
                {
                    case NodeTypes.END, NodeTypes.OUTGOING:
                        if ((!balls_at_top_of_pipe) && (!dropping))
                        {
                            add_ball = true;
                        }
                }
            }
        }
        
        if (pinch_point != null)
        {
            if (pinch_point.parent == board.pinch_point_pane)
            {
                board.pinch_point_pane.removeChild(pinch_point);
            }
            board.pinch_point_pane.addChild(pinch_point);
        }
        
        if (has_buzzsaw && associated_edge != null)
        {
            var buzz_loc : Point = getXYbyT(Math.min(BUZZSAW_HEIGHT, 0.5 * _interpolated_spline_length) / _interpolated_spline_length);
            if (buzzsaw_pair == null)
            {
                buzzsaw_pair = new BuzzsawPair(buzz_loc.x, buzz_loc.y, removeBuzzsaws);
                var loc21 : Point = getXYbyT(Math.min(BUZZSAW_HEIGHT + 0.5 * WIDE_BALL_RADIUS, 0.51 * _interpolated_spline_length) / _interpolated_spline_length);
                var rot_angle1 : Float = Math.atan2(loc21.y - buzz_loc.y, loc21.x - buzz_loc.x);
                buzzsaw_pair.rotation = -90 + 180 * rot_angle1 / Math.PI;
            }
            board.buzzsaw_pane.addChild(buzzsaw_pair);
        }
        else if (buzzsaw_pair != null)
        {
            if (buzzsaw_pair.parent == board.buzzsaw_pane)
            {
                board.buzzsaw_pane.removeChild(buzzsaw_pair);
            }
        }
        if (DISPLAY_EDGE_IDS_FOR_DEBUG)
        {
            var MAX_EDGE_DEC_WIDTH : Float = 200.0;
            if (user_mousing_over || debug_edge_id_label == null)
            {
                if (debug_edge_id_label != null && debug_edge_id_label.parent)
                {
                    debug_edge_id_label.parent.removeChild(debug_edge_id_label);
                }
                debug_edge_id_label = new TextField();
                debug_edge_id_label.embedFonts = true;
                debug_edge_id_label.backgroundColor = 0x0;
                debug_edge_id_label.background = true;
                debug_edge_id_label.width = 65;
                debug_edge_id_label.height = 20;
                debug_edge_id_label.text = associated_edge.edge_id + " " + associated_edge.description;
                debug_edge_id_label.setTextFormat(new TextFormat(Fonts.FONT_DEFAULT, 16, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER));
                if (debug_edge_id_label.textWidth > MAX_EDGE_DEC_WIDTH)
                {
                    debug_edge_id_label.width = MAX_EDGE_DEC_WIDTH;
                    debug_edge_id_label.wordWrap = true;
                    debug_edge_id_label.setTextFormat(new TextFormat(Fonts.FONT_DEFAULT, 16, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER));
                    debug_edge_id_label.height = debug_edge_id_label.textHeight;
                }
                else
                {
                    debug_edge_id_label.width = debug_edge_id_label.textWidth;
                }
                var txt_pt : Point = new Point(begin_x, begin_y);
                if (associated_edge.spline_control_points.length > 0)
                {
                    txt_pt = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[0]);
                }
                debug_edge_id_label.x = (Math.random() - 0.5) * 40 + txt_pt.x;
                debug_edge_id_label.y = (Math.random()) * 40 + 10 + txt_pt.y;
                board.ball_pane.addChild(debug_edge_id_label);
            }
        }
        else if (debug_edge_id_label != null)
        {
            if (debug_edge_id_label.parent != null)
            {
                debug_edge_id_label.parent.removeChild(debug_edge_id_label);
            }
        }
        
        var new_filters : Array<Dynamic> = new Array<Dynamic>();
        // Add highlight filter
        if (highlight)
        {
            new_filters.push(highlight_glow_filter);
        }
        if (failed)
        {
            new_filters.push(failed_glow_filter);
        }
        else
        {
            new_filters.push(succeeded_glow_filter);
        }
        main_pipe_sprite.filters = new_filters;
        
        // Draw pipes if necessary
        if (!((last_drawn_width == pipe_width)
            && (last_drawn_outgoing_widths[0] == outgoing_widths[0])
            && (last_drawn_outgoing_widths[1] == outgoing_widths[1])))
        {
            main_pipe_sprite.graphics.clear();
            bottom_joint_sprite.graphics.clear();
            next_joint_sprites[0].graphics.clear();
            next_joint_sprites[1].graphics.clear();
            
            /*
				var bd:BitmapData = new BitmapData(1000, 1000, true, 0x0);
				bd.draw(this);
				pipe_wide_bmp = new Bitmap(bd);
				*/
            
            updateOutgoingWidths();
            last_drawn_width = pipe_width;
            last_drawn_outgoing_widths = new Array<Dynamic>();
            last_drawn_outgoing_widths[0] = outgoing_widths[0];
            last_drawn_outgoing_widths[1] = outgoing_widths[1];
            
            // Draw top of pipe for START nodes
            if (DRAW_PIPE_TOPS)
            {
                var _sw19_ = (associated_edge.from_node.kind);                

                switch (_sw19_)
                {
                    case NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_SMALL_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL:
                        drawFromPolyline(top_outline_drawing_points, 1.5 * pipe_width, pipe_width, 4, darker_accent_color, darker_accent_color, 1.0, main_pipe_sprite);
                        drawFromPolyline(top_inner_drawing_points, 1.5 * pipe_width, pipe_width, -4, main_color, main_color, 1.0, main_pipe_sprite);
                }
            }
            
            // Draw pipe outline (wider line)
            var outline_color : Float = darker_accent_color;
            var _sw20_ = (outgoing_polylines.length);            

            switch (_sw20_)
            {
                case 1, 2:

                    switch (_sw20_)
                    {case 1:
                            drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, 4, outline_color, outline_color, 1.0, main_pipe_sprite);
                            drawFromPolyline(bottom_adjoining_follow_points.concat(outgoing_polylines[0]), pipe_width, ending_pipe_width, 4, outline_color, outgoing_darker_colors[0], 1.0, bottom_joint_sprite);  // , next_joint_sprites[0]);  
                            break;
                    }
                    drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, 4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    drawFromPolyline(bottom_adjoining_follow_points.concat(outgoing_polylines[0]), pipe_width, outgoing_widths[0], 4, outline_color, outgoing_darker_colors[0], 1.0, bottom_joint_sprite);  //, next_joint_sprites[0]);  
                    drawFromPolyline(bottom_adjoining_follow_points.concat(outgoing_polylines[1]), pipe_width, outgoing_widths[1], 4, outline_color, outgoing_darker_colors[1], 1.0, bottom_joint_sprite);  //, next_joint_sprites[1]);  
                    break;
                    // Add an extra outline portion beyond the end for "END" nodes to indicate the pipe stopping
                    if ((associated_edge.to_node.kind == NodeTypes.END) && DRAW_PIPE_BOTTOMS)
                    {
                        drawFromPolyline(end_outline_drawing_points, pipe_width, ending_pipe_width, 4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    }
                    else
                    {
                        drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, 4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    }
                default:
                    // Add an extra outline portion beyond the end for "END" nodes to indicate the pipe stopping
                    if ((associated_edge.to_node.kind == NodeTypes.END) && DRAW_PIPE_BOTTOMS)
                    {
                        drawFromPolyline(end_outline_drawing_points, pipe_width, ending_pipe_width, 4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    }
                    else
                    {
                        drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, 4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    }
            }
            
            // Finally draw the interior of the pipe (thinnest line)
            outline_color = main_color;
            var _sw21_ = (outgoing_polylines.length);            

            switch (_sw21_)
            {
                case 1:
                    drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, -4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    drawFromPolyline(bottom_adjoining_follow_points.concat(outgoing_polylines[0]), pipe_width, ending_pipe_width, -4, outline_color, outgoing_main_colors[0], 1.0, bottom_joint_sprite, next_joint_sprites[0]);
                    // If this pipe is one of two merge pipes, draw this pipe's interior on the other pipe's sprite
                    if ((associated_edge.to_node.kind == NodeTypes.MERGE) && (board.clone_level == 0))
                    {
                        if (associated_edge.to_node.incoming_ports[0].edge.associated_pipe == this)
                        
                        // This pipe is incoming_ports[0], the other must be incoming_ports[1]{
                            
                            var otherPipe : Pipe = associated_edge.to_node.incoming_ports[1].edge.associated_pipe;
                            if (otherPipe.spline_drawing_points)
                            
                            //create a mask for the current pipe, remove old if it exists{
                                
                                if (otherPipe.merge_sibling_sprite.mask != null)
                                {
                                    otherPipe.merge_sibling_sprite.removeChild(otherPipe.merge_sibling_sprite.mask);
                                    otherPipe.merge_sibling_sprite.mask = null;
                                }
                                var newMask : Shape = new Shape();
                                drawMaskShapeFromPolyline(otherPipe.spline_drawing_points, otherPipe.pipe_width, 10, newMask);
                                //mask the image so the next drawing doesn't draw outside of current pipe bounds
                                otherPipe.merge_sibling_sprite.addChild(newMask);
                                otherPipe.merge_sibling_sprite.mask = newMask;
                            }
                            associated_edge.to_node.incoming_ports[1].edge.associated_pipe.merge_sibling_sprite.graphics.clear();
                            drawFromPolyline(spline_drawing_points.concat(outgoing_polylines[0]), pipe_width, ending_pipe_width, -4, outline_color, outgoing_main_colors[0], 1.0, associated_edge.to_node.incoming_ports[1].edge.associated_pipe.merge_sibling_sprite, next_joint_sprites[0]);
                        }
                        // This pipe is incoming_ports[1], the other must be incoming_ports[0]
                        else
                        {
                            
                            var otherPipe1 : Pipe = associated_edge.to_node.incoming_ports[0].edge.associated_pipe;
                            if (otherPipe1.spline_drawing_points)
                            {
                                if (otherPipe1.merge_sibling_sprite.mask != null)
                                {
                                    otherPipe1.merge_sibling_sprite.removeChild(otherPipe1.merge_sibling_sprite.mask);
                                    otherPipe1.merge_sibling_sprite.mask = null;
                                }
                                var newMask1 : Shape = new Shape();
                                drawMaskShapeFromPolyline(otherPipe1.spline_drawing_points, otherPipe1.pipe_width, 10, newMask1);
                                //mask the image so the next drawing doesn't draw outside of current pipe bounds
                                otherPipe1.merge_sibling_sprite.addChild(newMask1);
                                otherPipe1.merge_sibling_sprite.mask = newMask1;
                            }
                            
                            associated_edge.to_node.incoming_ports[0].edge.associated_pipe.merge_sibling_sprite.graphics.clear();
                            drawFromPolyline(spline_drawing_points.concat(outgoing_polylines[0]), pipe_width, ending_pipe_width, -4, outline_color, outgoing_main_colors[0], 1.0, associated_edge.to_node.incoming_ports[0].edge.associated_pipe.merge_sibling_sprite, next_joint_sprites[0]);
                        }
                    }
                case 2:
                    drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, -4, outline_color, outline_color, 1.0, main_pipe_sprite);
                    drawFromPolyline(bottom_adjoining_follow_points.concat(outgoing_polylines[0]), pipe_width, outgoing_widths[0], -4, outline_color, outgoing_main_colors[0], 1.0, bottom_joint_sprite, next_joint_sprites[0]);
                    drawFromPolyline(bottom_adjoining_follow_points.concat(outgoing_polylines[1]), pipe_width, outgoing_widths[1], -4, outline_color, outgoing_main_colors[1], 1.0, bottom_joint_sprite, next_joint_sprites[1]);
                default:
                    drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, -4, outline_color, outline_color, 1.0, main_pipe_sprite);
            }
            
            
            // If this is a split, draw this pipe onto the other split pipe's sprite
            if ((associated_edge.from_node.kind == NodeTypes.SPLIT) && (board.clone_level == 0))
            {
                if (associated_edge.from_node.outgoing_ports[0].edge.associated_pipe == this)
                {
                    var otherPipe2 : Pipe = associated_edge.from_node.outgoing_ports[1].edge.associated_pipe;
                    //create a mask for the current pipe, remove old if it exists
                    if (otherPipe2.split_sibling_sprite.mask != null)
                    {
                        otherPipe2.split_sibling_sprite.removeChild(otherPipe2.split_sibling_sprite.mask);
                        otherPipe2.split_sibling_sprite.mask = null;
                    }
                    var newMask2 : Shape = new Shape();
                    drawMaskShapeFromPolyline(otherPipe2.spline_drawing_points, otherPipe2.pipe_width, 10, newMask2);
                    //mask the image so the next drawing doesn't draw outside of current pipe bounds
                    otherPipe2.split_sibling_sprite.addChild(newMask2);
                    otherPipe2.split_sibling_sprite.mask = newMask2;
                    
                    // This pipe is outgoing_ports[0], the other must be outgoing_ports[1]
                    otherPipe2.split_sibling_sprite.graphics.clear();
                    drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, -4, outline_color, outline_color, 1.0, otherPipe2.split_sibling_sprite);
                }
                // This pipe is outgoing_ports[1], the other must be outgoing_ports[0]
                else
                {
                    
                    //mask the image so the next drawing doesn't draw outside of current pipe bounds
                    var otherPipe3 : Pipe = associated_edge.from_node.outgoing_ports[0].edge.associated_pipe;
                    if (otherPipe3.split_sibling_sprite.mask != null)
                    {
                        otherPipe3.split_sibling_sprite.removeChild(otherPipe3.split_sibling_sprite.mask);
                        otherPipe3.split_sibling_sprite.mask = null;
                    }
                    var newMask3 : Shape = new Shape();
                    drawMaskShapeFromPolyline(otherPipe3.spline_drawing_points, otherPipe3.pipe_width, 10, newMask3);
                    //mask the image so the next drawing doesn't draw outside of current pipe bounds
                    otherPipe3.split_sibling_sprite.addChild(newMask3);
                    otherPipe3.split_sibling_sprite.mask = newMask3;
                    otherPipe3.split_sibling_sprite.graphics.clear();
                    drawFromPolyline(spline_drawing_points, pipe_width, ending_pipe_width, -4, outline_color, outline_color, 1.0, otherPipe3.split_sibling_sprite);
                }
            }
            if (main_pipe_sprite.parent != this)
            {
                addChild(main_pipe_sprite);
            }
            else
            {
                setChildIndex(main_pipe_sprite, numChildren - 1);
            }
            if (bottom_joint_sprite.parent != this)
            {
                addChild(bottom_joint_sprite);
            }
            else
            {
                setChildIndex(bottom_joint_sprite, numChildren - 1);
            }
            
            if (split_sibling_sprite.parent != this)
            {
                addChild(split_sibling_sprite);
            }
            else
            {
                setChildIndex(split_sibling_sprite, numChildren - 1);
            }
            if (merge_sibling_sprite.parent != this)
            {
                addChild(merge_sibling_sprite);
            }
            else
            {
                setChildIndex(merge_sibling_sprite, numChildren - 1);
            }
            if (next_joint_sprites[0].parent != this)
            {
                addChild(next_joint_sprites[0]);
            }
            else
            {
                setChildIndex(next_joint_sprites[0], numChildren - 1);
            }
            if (next_joint_sprites[1].parent != this)
            {
                addChild(next_joint_sprites[1]);
            }
            else
            {
                setChildIndex(next_joint_sprites[1], numChildren - 1);
            }
        }
        
        //now add stars. Add to main pipe so that for merge or split cases we can copy them
        for (stamp in stamps)
        {
            if (stamp.parent != main_pipe_sprite)
            {
                main_pipe_sprite.addChild(stamp);
            }
            else
            {
                main_pipe_sprite.removeChild(stamp);
                main_pipe_sprite.addChild(stamp);
            }
        }
        
        //draw some identifying stuff
        if (0)
        {
            var text : TextField = new TextField();
            text.setTextFormat(new TextFormat(Fonts.FONT_DEFAULT, 32, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER));
            
            text.text = associated_edge.from_node.kind + " " + associated_edge.dropObjectFlowStateEdgeIDArray.length;
            addChild(text);
            text.x = begin_x - 20;
            text.y = begin_y;
            var count : Int = 1;
            for (dropObjID/* AS3HX WARNING could not determine type for var: dropObjID exp: EField(EIdent(associated_edge),dropObjectFlowStateEdgeIDArray) type: null */ in associated_edge.dropObjectFlowStateEdgeIDArray)
            {
                text = new TextField();
                text.setTextFormat(new TextFormat(Fonts.FONT_DEFAULT, 32, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER));
                var flowObj : FlowObject = associated_edge.dropObjectFlowStateCache[dropObjID];
                text.text = flowObj.starting_ball_type + " " + flowObj.exit_ball_type + " ";
                addChild(text);
                text.x = begin_x - 20;
                text.y = begin_y + 20 * count;
                count++;
            }
        }
        
        //do on setup or click, but not when just being rolled over
        if (drawDropObjects)
        {
            for (dropObj in drop_objects)
            {
                dropObj.updateImageAndFlow();
            }
        }
    }
    
    private function removeBuzzsaws() : Void
    {
        if (board.dropping || board.m_boardNodes.simulating)
        {
            return;
        }
        if (!adjustable)
        {
            highlight = false;
        }
        if (VerigameSystem.LOGGING_ON)
        {
            var buzzsawAction : ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_REMOVE_PIPE_BUZZSAW);
            buzzsawAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_PIPE_EDGE_ID, associated_edge.edge_id);
            CGSServerLocal.logQuestAction(buzzsawAction);
        }
        has_buzzsaw = false;
        balls_at_top_of_pipe = true;
        draw();
        var event : PipeChangeEvent = new PipeChangeEvent(this, false, true);
        dispatchEvent(event);
    }
    
    public static function drawFromPolyline(_polyline : Array<Dynamic>, _pipe_width : Float, _next_pipe_width : Float, _width_offset : Float, _color : Float, _next_color : Float, _alpha : Float, _sprite_to_use : Sprite, _next_sprite_to_use : Sprite = null) : Void
    {
        if (_next_sprite_to_use == null)
        {
            _next_sprite_to_use = _sprite_to_use;
        }
        var drawing_sprite : Sprite = _sprite_to_use;
        if (_polyline == null)
        {
            var debug : Int = 0;
        }
        
        drawing_sprite.graphics.moveTo(_polyline[0][0], _polyline[0][1]);
        var color_to_use : Float = _color;
        if (_polyline[0][2] == 0.0)
        {
            color_to_use = _next_color;
            drawing_sprite = _next_sprite_to_use;
        }
        drawing_sprite.graphics.lineStyle(_pipe_width + _width_offset, color_to_use, _alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        var prev_w : Float = _pipe_width;
        for (arr_indx in 0..._polyline.length)
        {
            var next_pt_arr : Array<Dynamic> = _polyline[arr_indx];
            
            if (prev_w != next_pt_arr[2] * _pipe_width)
            {
                if (next_pt_arr[2] == 0.0)
                {
                    color_to_use = _next_color;
                    drawing_sprite = _next_sprite_to_use;
                }
                drawing_sprite.graphics.lineStyle(next_pt_arr[2] * _pipe_width + (1.0 - next_pt_arr[2]) * _next_pipe_width + _width_offset, color_to_use, _alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
                if (arr_indx > 1)
                
                //var min_width:Number = Math.min(next_pt_arr[2] * _pipe_width + (1.0 - next_pt_arr[2]) * _next_pipe_width, _polyline[arr_indx - 1][2] * _pipe_width + (1.0 - _polyline[arr_indx - 1][2]) * _next_pipe_width);{
                    
                    //drawing_sprite.graphics.lineStyle(min_width + _width_offset, color_to_use, _alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
                    drawing_sprite.graphics.moveTo(_polyline[arr_indx - 2][0], _polyline[arr_indx - 2][1]);
                    drawing_sprite.graphics.lineTo(_polyline[arr_indx - 1][0], _polyline[arr_indx - 1][1]);
                }
            }
            drawing_sprite.graphics.lineTo(next_pt_arr[0], next_pt_arr[1]);
            prev_w = next_pt_arr[2] * _pipe_width;
        }
    }
    
    public static function drawMaskShapeFromPolyline(_polyline : Array<Dynamic>, _pipe_width : Float, _width_offset : Float, shape : Shape) : Void
    {
        shape.graphics.clear();
        shape.graphics.lineStyle(1);
        shape.graphics.beginFill(0xFFFFFF, 1);
        shape.graphics.moveTo(_polyline[0][0] - _pipe_width / 2 - _width_offset, _polyline[0][1]);
        //draw down one side
        for (arr_indx in 1..._polyline.length)
        {
            var next_pt_arr : Array<Dynamic> = _polyline[arr_indx];
            shape.graphics.lineTo(_polyline[arr_indx][0] - _pipe_width / 2 - _width_offset, _polyline[arr_indx][1]);
        }
        //and then back up the other, a pipe_width apart
        var arr_indx1 : Int = as3hx.Compat.parseInt((_polyline.length) - 1);
        while (arr_indx1 >= 0)
        {
            shape.graphics.lineTo(_polyline[arr_indx1][0] + _pipe_width / 2 + _width_offset, _polyline[arr_indx1][1]);
            arr_indx1--;
        }
        //finish the shape
        shape.graphics.lineTo(_polyline[0][0], _polyline[0][1]);
        shape.graphics.endFill();
    }
    
    /**
		 * Function to return the corresponding X value to this Y value.
		 * Presumption #1: The spline that this pipe follows never travels UP. This is supposed to be ensured by edge layout.
		 * Presumption #2: This method will be called frequently in succession with incrementally increasing Y-values (for
		 * 	when a ball is being animated and falling down the pipe). We will leverage this by keeping track of the latest
		 * 	accessed interpolated spline point and hopefully the y value will be slightly ahead of this.
		 * 
		 * @param	_y The y value used for interpolating x based on our spline approximation.
		 * @return The x value interpolated to meet the desired y based on our spline approximation.
		 */
    public function getXbyY(_y : Float) : Float
    {
        if (interpolated_spline_points.length == 0)
        {
            interpolateSpline();
        }
        if (interpolated_spline_points.length == 0)
        {
            throw new Error("Unable to process getXbyY() for pipe " + this + ". Not enough interpolated_spline_points");
        }
        if (interpolated_spline_points.length < 2)
        {
            throw new Error("Unable to process getXbyY() for pipe " + this + ". Not enough interpolated_spline_points");
        }
        if ((last_interpolated_spline_index_accessed < 0) || (last_interpolated_spline_index_accessed >= interpolated_spline_points.length))
        
        // Index out of bounds, reset to 0{
            
            last_interpolated_spline_index_accessed = 0;
        }
        if (_y == interpolated_spline_points[last_interpolated_spline_index_accessed].y)
        {
            return interpolated_spline_points[last_interpolated_spline_index_accessed].x;
        }
        else if (_y < interpolated_spline_points[last_interpolated_spline_index_accessed].y)
        {
            if (_y < interpolated_spline_points[0].y)
            
            // If _y is above the pipe, return the endpoint{
                
                return interpolated_spline_points[0].x;
            }
            // If desired _y is above the last accessed interpolated_spline_point, start over at 0 (presume we aren't traversing UP the pipe)
            last_interpolated_spline_index_accessed = 0;
        }
        
        var next_i : Int = as3hx.Compat.parseInt(last_interpolated_spline_index_accessed + 1);
        if (next_i >= interpolated_spline_points.length)
        
        // If we're over the end of the pipe, return the endpoint{
            
            return interpolated_spline_points[interpolated_spline_points.length - 1].x;
        }
        while (_y > interpolated_spline_points[next_i].y)
        {
            next_i++;
            if (next_i >= interpolated_spline_points.length)
            
            // If we're over the end of the pipe, return the endpoint{
                
                return interpolated_spline_points[interpolated_spline_points.length - 1].x;
            }
        }
        // At this point, we are assured that _y is between interpolated_spline_points[next_i - 1].y and interpolated_spline_points[next_i].y
        last_interpolated_spline_index_accessed = as3hx.Compat.parseInt(next_i - 1);
        // Check divide by zero
        if (Math.abs(interpolated_spline_points[next_i - 1].y - interpolated_spline_points[next_i].y) < 0.00000001)
        {
            return interpolated_spline_points[next_i - 1].x;
        }
        else if (interpolated_spline_points[next_i].y < interpolated_spline_points[next_i - 1].y)
        {
            throw new Error("Spline interpolation point found (i=" + (next_i - 1) + "-" + (next_i) + ")in pipe " + this + " where Y was found to be DECREASING (going up, when expected to go downwards).");
        }
        return (interpolated_spline_points[next_i].x * (_y - interpolated_spline_points[next_i - 1].y) / (interpolated_spline_points[next_i].y - interpolated_spline_points[next_i - 1].y) + interpolated_spline_points[next_i - 1].x * (interpolated_spline_points[next_i].y - _y) / (interpolated_spline_points[next_i].y - interpolated_spline_points[next_i - 1].y));
    }
    
    /**
		 * Function to make the call to recursively interpolate the spline control points until a suitable polyline is created.
		 */
    public function interpolateSpline() : Void
    {
        if (associated_edge == null)
        {
            return;
        }
        // We've already calculated this, no need to repeat
        if (interpolated_spline_points.length > 1)
        {
            return;
        }
        if (associated_edge.spline_control_points.length >= 4)
        {
            interpolated_spline_points = new Array<Dynamic>();
            // We must be receiving 4 + 3*n control points where n is a whole number
            var i : Int = 0;
            while (i + 3 <= associated_edge.spline_control_points.length - 1)
            {
                var pt1 : Point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[i]);
                var pt2 : Point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[i + 1]);
                var pt3 : Point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[i + 2]);
                var pt4 : Point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[i + 3]);
                interpolated_spline_points = Geometry.splineToLineSegments(pt1.x, pt1.y, pt2.x, pt2.y, pt3.x, pt3.y, pt4.x, pt4.y, SPLINE_ERROR_TOLERANCE, interpolated_spline_points);
                i = as3hx.Compat.parseInt(i + 3);
            }
            _interpolated_spline_length = 0.0;
            spline_drawing_points = new Array<Dynamic>();
            max_spline_x = Math.NEGATIVE_INFINITY;
            max_spline_y = Math.NEGATIVE_INFINITY;
            min_spline_x = Math.POSITIVE_INFINITY;
            min_spline_y = Math.POSITIVE_INFINITY;
            
            // Calculate the length of the whole pipe segment, and add create the spline_drawing_points from the interpolated points
            for (indx in 0...interpolated_spline_points.length)
            {
                if (indx > 0)
                {
                    _interpolated_spline_length += XMath.getDist(interpolated_spline_points[indx], interpolated_spline_points[indx - 1]);
                }
                spline_drawing_points.push(new Array<Dynamic>(interpolated_spline_points[indx].x, interpolated_spline_points[indx].y, 1.0));
                if (interpolated_spline_points[indx].x > max_spline_x)
                {
                    max_spline_x = interpolated_spline_points[indx].x;
                }
                if (interpolated_spline_points[indx].x < min_spline_x)
                {
                    min_spline_x = interpolated_spline_points[indx].x;
                }
                if (interpolated_spline_points[indx].y > max_spline_y)
                {
                    max_spline_y = interpolated_spline_points[indx].y;
                }
                if (interpolated_spline_points[indx].y < min_spline_y)
                {
                    min_spline_y = interpolated_spline_points[indx].y;
                }
            }
            if (_interpolated_spline_length <= 0.0)
            {
                throw new Error("Pipe _interpolated_spline_length calculated to be <= 0.0");
            }
            top_adjoining_follow_points = new Array<Dynamic>();
            var top_follow_segment : Array<Dynamic> = getPolylineFromT(0.0, ADJOINING_PIPE_SEGMENT_FOLLOW_DISTANCE / _interpolated_spline_length);
            for (ii in 0...top_follow_segment.length)
            {
                top_adjoining_follow_points.push(new Array<Dynamic>(top_follow_segment[ii].x, top_follow_segment[ii].y, 0.0));
            }
            bottom_adjoining_follow_points = new Array<Dynamic>();
            var bottom_follow_segment : Array<Dynamic> = getPolylineFromT(1.0 - FUNNEL_DISTANCE / _interpolated_spline_length, 1.0);
            for (ii2 in 0...bottom_follow_segment.length)
            {
                bottom_adjoining_follow_points.push(new Array<Dynamic>(bottom_follow_segment[ii2].x, bottom_follow_segment[ii2].y, 1.0));
            }
            // Now update drawing points from this if this pipe leads into another pipe to allow for funneling from wide/narrow or narrow/wide
            var funnel : Bool = false;
            if (associated_edge.to_node)
            {
                var _sw22_ = (associated_edge.to_node.kind);                

                switch (_sw22_)
                {
                    case NodeTypes.CONNECT, NodeTypes.MERGE, NodeTypes.BALL_SIZE_TEST, NodeTypes.SPLIT, NodeTypes.SUBBOARD:
                        funnel = true;
                }
            }
            if (funnel)
            {
                spline_drawing_points = new Array<Dynamic>();
                var funneling_dist_t : Float = XMath.clamp(FUNNEL_DISTANCE / _interpolated_spline_length, 0.0000000000000000001, 1.0);
                if (funneling_dist_t < 1.0)
                {
                    var top_section : Array<Dynamic> = getPolylineFromT(0.0, 1.0 - funneling_dist_t);
                    for (ii3 in 0...top_section.length)
                    {
                        spline_drawing_points.push(new Array<Dynamic>(top_section[ii3].x, top_section[ii3].y, 1.0));
                    }
                    var last_top_arr : Array<Dynamic> = spline_drawing_points.pop();
                }
                var funneling_dt : Float = XMath.clamp(FUNNEL_INCREMENT_SIZE / _interpolated_spline_length, funneling_dist_t / 100, 1.0);
                var current_t : Float = 1.0 - funneling_dist_t;
                var pct : Float;
                bottom_adjoining_follow_points = new Array<Dynamic>();
                while (current_t < 1.0)
                {
                    pct = 1.0 - (current_t - (1.0 - funneling_dist_t)) / funneling_dist_t;
                    //var increment_segment:Array = getPolylineFromT(current_t, Math.max(current_t + funneling_dt, 1.0));
                    var next_pt : Point = getXYbyT(current_t);
                    spline_drawing_points.push(new Array<Dynamic>(next_pt.x, next_pt.y, pct));
                    bottom_adjoining_follow_points.push(new Array<Dynamic>(next_pt.x, next_pt.y, pct));
                    current_t += funneling_dt;
                }
                if (spline_drawing_points.length == 1)
                {
                    spline_drawing_points.push(last_top_arr);
                }
            }
            if (interpolated_spline_points.length < 2)
            {
                throw new Error("Error calculating interpolated_spline_points, less than 2 points created");
            }
            // If pipe leads into or out of subnetwork, add a point vertically below/above respectively to allow pipe to join vertically
            if (associated_edge.from_node.kind == NodeTypes.SUBBOARD)
            {
                var upper_pt : Array<Dynamic> = new Array<Dynamic>(spline_drawing_points[0][0], spline_drawing_points[0][1] - 5.0, spline_drawing_points[0][2]);
                spline_drawing_points.unshift(upper_pt);
            }
            if (associated_edge.to_node.kind == NodeTypes.SUBBOARD)
            {
                var lower_pt : Array<Dynamic> = new Array<Dynamic>(spline_drawing_points[spline_drawing_points.length - 1][0], spline_drawing_points[spline_drawing_points.length - 1][1] + 5.0, spline_drawing_points[spline_drawing_points.length - 1][2]);
                spline_drawing_points.push(lower_pt);
            }
        }
        else
        {
            throw new Error("Couldn't interpolate spline for pipe with edge_id " + associated_edge.edge_id + ". Less than 4 spline control points found.");
            return;
        }
    }
    
    /**
		 * This function is called when the user clicks on the pipe either to change widths or add a buzzsaw.
		 * @param	e The associated mouseEvent
		 */
    public var clickCount : Int = 0;
    public function pipeClick(e : MouseEvent, logEvent : Bool = true) : Void
    {
        var buzzSawChange : Bool = false;
        var pipeWidthChange : Bool = false;
        
        if (this.associated_edge.metadata.xml)
        {
            var displayMetadata : FastXMLList = this.associated_edge.metadata.xml["display"];
            if (displayMetadata != null && displayMetadata.length() > 0)
            {
                var onclickList : FastXMLList = displayMetadata.get(0).get("onclick");
                if (onclickList.length() > clickCount)
                {
                    var clickXML : FastXML = onclickList.get(clickCount);
                    //only has text in them currently
                    this.board.level.m_gameSystem.game_panel.displayTextMetadata(clickXML);
                    this.board.level.m_gameSystem.game_panel.draw();
                }
            }
        }
        clickCount++;
        
        if (board.m_gameSystem.buzzing && !has_buzzsaw)
        
        //logEvent == false when this is a replay, and not a real event{
            
            if (VerigameSystem.LOGGING_ON && logEvent)
            {
                var pipeWidthAction : ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_ADD_PIPE_BUZZSAW);
                pipeWidthAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_PIPE_EDGE_ID, associated_edge.edge_id);
                CGSServerLocal.logQuestAction(pipeWidthAction);
            }
            has_buzzsaw = true;
            if (!adjustable)
            {
                highlight = false;
            }
            balls_at_top_of_pipe = true;
            buzzSawChange = true;
        }
        else if (!adjustable || board.dropping || board.m_boardNodes.simulating)
        {
        }
        else
        {
            if (VerigameSystem.LOGGING_ON && logEvent)
            {
                var pipeWidthAction2 : ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_CHANGE_PIPE_WIDTH);
                pipeWidthAction2.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_PIPE_EDGE_ID, associated_edge.edge_id);
                var widthValue : String = VerigameServerConstants.ACTION_VALUE_PIPE_WIDTH_NARROW;
                // NOTE: is_wide gets updated after simulation, but act like it's going to happen
                if (!is_wide)
                {
                    VerigameServerConstants.ACTION_VALUE_PIPE_WIDTH_WIDE;
                }
                pipeWidthAction2.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_PIPE_WIDTH, widthValue);
                CGSServerLocal.logQuestAction(pipeWidthAction2);
            }
            pipeWidthChange = true;
        }
        
        var event : PipeChangeEvent = new PipeChangeEvent(this, pipeWidthChange, buzzSawChange);
        dispatchEvent(event);
    }
    
    /**
		 * Setup drop animation and return final y value
		 * @return
		 */
    public function performDropAnimation() : Float
    /*	if (ball) {
				if (ball.parent) {
					ball.parent.removeChild(ball);
				}
				ball = null;
			}
	
			if (interpolated_spline_points.length == 0) {
				interpolateSpline();
			}
			
			//grab the first flow object to test, later need to do all...
			var edgeID:String = associated_edge.dropObjectFlowStateEdgeIDArray[getCurrentFlowObjectIndex()];
			var flowObject:FlowObject = associated_edge.dropObjectFlowStateCache[edgeID];

			
			var path:LinePath2D;
			ball = new Ball(associated_edge, flowObject);
			var begin_pt:Point = new Point(ball.begin_x, ball.begin_y);
			var delay_start_sec:Number = begin_pt.y / VerigameSystem.DROP_SPEED;
			var end_pt:Point = VerigameSystem.nodeSpaceToBoardSpace(associated_edge.spline_control_points[associated_edge.spline_control_points.length - 1]);
			var sec:Number = (end_pt.y - begin_pt.y) / VerigameSystem.DROP_SPEED;
			function shrinkBallBuzzsaw():void {
				if (ball) {
					ball.buzzed = true;
				}
			}
			var buzz_y_value:Number = begin_pt.y;
			if (buzzsaw_pair) {
				buzz_y_value = buzzsaw_pair.y;
			}
			switch (associated_edge.from_node.kind) {
				case NodeTypes.START_LARGE_BALL:
				case NodeTypes.START_SMALL_BALL:
				case NodeTypes.START_PIPE_DEPENDENT_BALL:
					var aug_path:Array = interpolated_spline_points.concat();
					aug_path.unshift(begin_pt.clone());
					path = new LinePath2D(aug_path);
					var new_delay:Number = delay_start_sec + (buzz_y_value - begin_pt.y + 0.25*WIDE_BALL_RADIUS) / VerigameSystem.DROP_SPEED;
					if (has_buzzsaw) {
						TweenLite.delayedCall(new_delay, shrinkBallBuzzsaw);
					}
				break;
				default:
					path = new LinePath2D(interpolated_spline_points);
					var new_delay1:Number = delay_start_sec + (buzz_y_value - begin_pt.y + 0.25*WIDE_BALL_RADIUS) / VerigameSystem.DROP_SPEED;
					if (has_buzzsaw) {
						TweenLite.delayedCall(new_delay1, shrinkBallBuzzsaw);
					}
				break;
			}
			
			dropping = true;
			succeeded = false;
			failed = false;
			draw();
			function onStartFunction():void {
				animating_balls = true;
				balls_at_top_of_pipe = false;
				if (!ball) {
					ball = new Ball(associated_edge, flowObject);
				}
				draw();
			}
			
			function onCompleteFunction():void {
				animating_balls = false;
				dropping = false;
				if ( (!associated_edge.associated_trouble_point && !associated_edge.to_port.associated_trouble_point)
						|| (associated_edge.has_pinch && (m_ball_type == VerigameSystem.BALL_TYPE_WIDE_AND_NARROW)) ) {
					if (associated_edge.to_node) {
						switch (associated_edge.to_node.kind) {
							case NodeTypes.END:
							case NodeTypes.OUTGOING:
								// leave ball where it is
							break;
							default:
								// otherwise remove it
								if (ball) {
									if (ball.parent) {
										ball.parent.removeChild(ball);
									}
									ball = null;// this forces a redraw of the ball at the top when needed
								}
							break;
						}
					} else {
						if (ball) {
							if (ball.parent) {
								ball.parent.removeChild(ball);
							}
							ball = null;// this forces a redraw of the ball at the top when needed
						}
					}
				}
				draw();
			}
			
			var follower:PathFollower = path.addFollower(ball);
			
			var prog:Number = 1.0;
			// Stop wide balls at pinch point
			if (associated_edge.has_pinch) {
				switch (m_ball_type) {
					case VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
						if (!has_buzzsaw) {
							TweenLite.delayedCall( delay_start_sec + 0.5 * sec, onWideNarrowHalfway, [this] );
						}
					break;
					case VerigameSystem.BALL_TYPE_WIDE:
						if (!has_buzzsaw) {
							prog = 0.5;
						}
					break;
				}
			}
			if (associated_edge.to_port.associated_trouble_point) {
				switch (m_ball_type) {
					case VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
						if (!has_buzzsaw) {
							TweenLite.delayedCall( delay_start_sec + (1.0 - 1.5 * Pipe.WIDE_BALL_RADIUS / _interpolated_spline_length) * sec, onWideNarrowBottom, [this] );
						}
					case VerigameSystem.BALL_TYPE_WIDE:
						if (!has_buzzsaw && (prog == 1.0)) {
							prog = 1.0 - 1.5 * Pipe.WIDE_BALL_RADIUS / _interpolated_spline_length;
						}
						break;
				}
			}
			TweenLite.to(follower, sec*prog, { progress:prog, ease:Linear.easeNone, delay:delay_start_sec, onStart:onStartFunction, onComplete:onCompleteFunction } );*/
    {
        
        return 1;
    }
    
    //private var stuck_wide_narrow_ball:Sprite = new Sprite();
    private function onWideNarrowHalfway(stuckObject : DropObjectBase) : Void
    {
        stuckObject.name = "stuck_wide_narrow_ball";
        stuckObject.graphics.clear();
        Ball.drawBall(true, stuckObject);
        stuckObject.x = associated_edge.midpoint.x;
        stuckObject.y = associated_edge.midpoint.y;
        if (stuckObject.parent != board.ball_pane)
        {
            board.ball_pane.addChildAt(stuckObject, 0);
        }
        else
        {
            board.ball_pane.setChildIndex(stuckObject, 0);
        }
    }
    
    private function onWideNarrowBottom(stuckObject : DropObjectBase) : Void
    {
        stuckObject.graphics.clear();
        Ball.drawBall(true, stuckObject);
        stuckObject.x = interpolated_spline_points[interpolated_spline_points.length - 1].x;
        stuckObject.y = interpolated_spline_points[interpolated_spline_points.length - 1].y - 1.5 * Pipe.WIDE_BALL_RADIUS;
        if (stuckObject.parent != board.ball_pane)
        {
            board.ball_pane.addChildAt(stuckObject, 0);
        }
        else
        {
            board.ball_pane.setChildIndex(stuckObject, 0);
        }
    }
    
    
    /**
		 * Reset the pipe to state where it has not marked as failed or succeeded and bring balls to top (do not draw yet though)
		 */
    public function resetPipe() : Void
    {
        board.m_boardNodes.simulated = false;
        board.m_boardNodes.simulating = false;
        failed = false;
    }
    
    /**
		 * Change the width of this pipe and redraw, reset any failed/succeeded results
		 * @param	_is_wide True if new with is wide, otherwise new width is narrow
		 */
    public function forceWidth(_is_wide : Bool) : Void
    {
        if (!this.adjustable || is_wide == _is_wide)
        {
            return;
        }
        is_wide = _is_wide;
        if (is_wide)
        {
            pipe_width = WIDE_PIPE_WIDTH;
        }
        else
        {
            pipe_width = NARROW_PIPE_WIDTH;
        }
        
        // Redraw pipes feeding into this
        if (associated_edge.from_node)
        {
            var _sw23_ = (associated_edge.from_node.kind);            

            switch (_sw23_)
            {
                case NodeTypes.SPLIT, NodeTypes.CONNECT, NodeTypes.MERGE:

                    switch (_sw23_)
                    {case NodeTypes.SPLIT:
                            for (sibling_ports/* AS3HX WARNING could not determine type for var: sibling_ports exp: EField(EField(EIdent(associated_edge),from_node),outgoing_ports) type: null */ in associated_edge.from_node.outgoing_ports)
                            {
                                if (sibling_ports.edge.associated_pipe != this)
                                {
                                    sibling_ports.edge.associated_pipe.updateOutgoingWidths();
                                    sibling_ports.edge.associated_pipe.draw();
                                }
                            }
                    }
                    for (feeding_ports/* AS3HX WARNING could not determine type for var: feeding_ports exp: EField(EField(EIdent(associated_edge),from_node),incoming_ports) type: null */ in associated_edge.from_node.incoming_ports)
                    {
                        feeding_ports.edge.associated_pipe.updateOutgoingWidths();
                        feeding_ports.edge.associated_pipe.draw();
                    }
            }
        }
        if (associated_edge.to_node)
        {
            if (associated_edge.to_node.kind == NodeTypes.MERGE)
            {
                for (parent_port/* AS3HX WARNING could not determine type for var: parent_port exp: EField(EField(EIdent(associated_edge),to_node),incoming_ports) type: null */ in associated_edge.to_node.incoming_ports)
                {
                    if (parent_port.edge.associated_pipe != this)
                    {
                        parent_port.edge.associated_pipe.draw();
                    }
                }
            }
        }
        //restart all cars if going narrow
        if (is_wide == false)
        {
            numStoppedObjects = 0;
        }
    }
    
    /**
		 * Processes mouse rollover event, highlights the pipe
		 * @param	e Associated mouseEvent
		 */
    private function pipeRollOver(e : MouseEvent) : Void
    {
        if (DISPLAY_EDGE_IDS_FOR_DEBUG)
        
        // allow users to mouse over non-adjustable pipes for debug{
            
            user_mousing_over = true;
            draw(false);
        }
        if (!adjustable && !board.m_gameSystem.buzzing)
        {
            return;
        }
        //addThisPipeAndMergeParentsToStage();
        if (board.m_gameSystem.mouseover_pipe != this)
        {
            board.m_gameSystem.mouseover_pipe = this;
        }
        if (!highlight && !board.dropping)
        {
            highlight = true;
            user_mousing_over = true;
            draw(false);
            if (!board.m_gameSystem.buzzing)
            
            // TODO: we are looping over all linked pipes in the level, we only need to do the pipes on this board{
                
                for (my_pipe/* AS3HX WARNING could not determine type for var: my_pipe exp: EArray(EField(EField(EIdent(board),level),pipeEdgeSetDictionary),EField(EField(EIdent(associated_edge),linked_edge_set),id)) type: null */ in board.level.pipeEdgeSetDictionary[associated_edge.linked_edge_set.id])
                {
                    if ((my_pipe.board == this.board) && my_pipe.adjustable)
                    {
                        my_pipe.highlight = true;
                        my_pipe.draw(false);
                    }
                }
            }
        }
    }
    
    /**
		 * Processes mouse rollout event, unhighlights the pipe
		 * @param	e Associated mouseEvent
		 */
    private function pipeRollOut(e : MouseEvent) : Void
    {
        mousing_down = false;
        if (DISPLAY_EDGE_IDS_FOR_DEBUG)
        
        // allow users to mouse over non-adjustable pipes for debug{
            
            user_mousing_over = false;
        }
        if (!adjustable && !board.m_gameSystem.buzzing)
        {
            return;
        }
        if (board.m_gameSystem.mouseover_pipe == this)
        {
            board.m_gameSystem.mouseover_pipe = null;
        }
        if (highlight && !board.dropping)
        {
            highlight = false;
            user_mousing_over = false;
            draw(false);
            // TODO: we are looping over all linked pipes in the level, we only need to do the pipes on this board
            for (my_pipe/* AS3HX WARNING could not determine type for var: my_pipe exp: EArray(EField(EField(EIdent(board),level),pipeEdgeSetDictionary),EField(EField(EIdent(associated_edge),linked_edge_set),id)) type: null */ in board.level.pipeEdgeSetDictionary[associated_edge.linked_edge_set.id])
            {
                if ((my_pipe.board == this.board) && my_pipe.adjustable)
                {
                    my_pipe.highlight = false;
                    my_pipe.draw(false);
                }
            }
        }
    }
    
    private function pipeMouseDown(e : MouseEvent) : Void
    {
        mousing_down = true;
        mouse_down_timer = new Timer(1000 * MOUSE_DOWN_UI_TIME, 1);
        mouse_down_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onMouseDownTimerComplete);
        mouse_down_timer.start();
    }
    
    private function pipeMouseUp(e : MouseEvent) : Void
    {
        mousing_down = false;
        if (mouse_down_timer != null)
        {
            mouse_down_timer.stop();
            mouse_down_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onMouseDownTimerComplete);
        }
    }
    
    private function onMouseDownTimerComplete(e : TimerEvent) : Void
    //if mouse is still over pipe, show stamp selector
    {
        
        if (user_mousing_over)
        {
            stampSelector = board.createStampSelector(mouseX, mouseY, this);
            // are there stamps?
            if (stampSelector != null)
            {
                stampSelector.addEventListener(StampChangeEvent.STAMP_ACTIVATION, onStampChange);
                stampSelector.addEventListener(StampChangeEvent.STAMP_SET_CHANGE, onStampSelectorClosing);
            }
        }
        mouse_down_timer.stop();
        mouse_down_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onMouseDownTimerComplete);
    }
    
    
    public function onStampSelectorClosing(e : StampChangeEvent) : Void
    {
        stampSelector.removeEventListener(StampChangeEvent.STAMP_ACTIVATION, onStampChange);
        stampSelector.removeEventListener(StampChangeEvent.STAMP_SET_CHANGE, onStampSelectorClosing);
        dispatchEvent(e);
    }
    
    // TODO: This is certainly out of date, check for attributes that are not being filled
    /**
		 * Create a clone of this pipe which has all the same variable values and drawn identically, must call completeClone() afterwards
		 * @param	_board New board to associate with the clone
		 * @return Clone of this pipe
		 */
    public function createClone(_board : Board = null) : Pipe
    {
        if (_board == null)
        {
            _board = board;
        }
        // IMPORTANT! BECAUSE THIS IS DONE BY HAND, ANY NEW/CHANGED/REMOVED PARAMETERS WITHIN PIPE CLASS MUST BE UPDATED HERE AS WELL
        var clone : Pipe = new Pipe(begin_x, begin_y, is_wide, main_color, _board, has_pipe_entrance, begin_t, pipe_depth, adjustable, unique_id, associated_edge);
        
        //clone.ball = ball.createClone();
        clone.highlight = highlight;
        clone.failed = failed;
        
        clone.dropping = dropping;
        clone.associated_edge = associated_edge;
        clone.current_x = current_x;
        clone.current_y = current_y;
        clone.current_t = current_t;
        
        // Copy over all spline related point arrays
        if (interpolated_spline_points.length == 0)
        {
            interpolateSpline();
        }
        clone.interpolated_spline_points = interpolated_spline_points.copy();
        clone._interpolated_spline_length = _interpolated_spline_length;
        clone.spline_drawing_points = spline_drawing_points.copy();
        clone.top_adjoining_follow_points = top_adjoining_follow_points.copy();
        clone.bottom_adjoining_follow_points = bottom_adjoining_follow_points.copy();
        
        clone.min_spline_x = min_spline_x;
        clone.max_spline_x = max_spline_x;
        clone.min_spline_y = min_spline_y;
        clone.max_spline_y = max_spline_y;
        
        clone.finishPipe();
        // for these, the pipes may not yet exist, so track the unique ids and fill the pipes with completeClone() below
        clone.draw();
        return clone;
    }
    
    private function get_interpolated_spline_length() : Float
    {
        return _interpolated_spline_length;
    }
}
