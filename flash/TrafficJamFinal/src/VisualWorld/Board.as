package VisualWorld
{
	import Events.PipeChangeEvent;
	
	import NetworkGraph.*;
	
	import System.*;
	
	import UserInterface.*;
	import UserInterface.Components.ImageButton;
	import UserInterface.Components.RectangularObject;
	import UserInterface.Components.ScrollButton;
	import UserInterface.Components.StampSelector;
	
	import Utilities.Animation;
	import Utilities.DebugTimer;
	import Utilities.Fonts;
	
	import VisualWorld.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.Image;
	
	/**
	 * Board object representing a network of pipes, a board has succeeded when all balls can successfully travel through pipes without trouble points.
	 */
	public class Board extends RectangularObject
	{
		
		/** Original X coordinate given */
		public var original_x:int;
		
		/** Original Y coordinate given */
		public var original_y:int;
		
		/** Original width given */
		public var original_width:uint;
		
		/** Original height given */
		public var original_height:uint;
		
		/** Original scaleX given */
		public var original_scaleX:Number;
		
		/** Original scaleY given */
		public var original_scaleY:Number;
		
		/** True if this is the zoomed in board being viewd by the player */
		public var active:Boolean = true;
		
		/** Balls contained on the board. They appear above START_*_BALL and INCOMING ports */
		public var all_balls:Vector.<Ball> = new Vector.<Ball>();
		
		/** Size of board title font when board is active (Title is at the bottom of the board) */
		public static const ACTIVE_FONT_SIZE:uint = 42;
		
		/** Size of board title font when board is inactive (Title is in the center of the board) */
		protected const INACTIVE_FONT_SIZE:uint = 82;
		
		/** Size of board title font for subnetwork boards */
		protected const CLONE_FONT_SIZE:uint = 102;
		
		/** For scrolling boards, this is the space between the bottom of the board and the balls when dropping */
		protected const AUTO_SCROLL_HEIGHT:uint = 150;
		
		/** Width of a wide pipe */
		public const WIDE_PIPE_WIDTH:uint = 40;//TODO: just copied from Pipe
		
		/** True to animate any subnetworks on this board along with the balls on the board itself */
		protected const ANIMATING_SUBBOARDS:Boolean = false;
		
		/** All of the pipes associated with this board (not including any pipes within subnetworks/board clones) */
		protected var _pipes:Vector.<Pipe>;
		
		/** Transparent sprite over the board, used to restrict mouse events when board is inactive */
		public var overlay:Sprite;
		
		/** True if a light border is drawn around the board (if being moused over while inactive, for example) */
		public var highlight:Boolean = false;
		
		/** What t value to start ball animation with (usually 0 for regular boards, something > 0 for subnetwork/clone boards) */
		public var start_t:Number;
		
		/** Level that this board belongs to */
		public var level:Level;
		
		/** Parent VerigameSystem instance */
		public var m_gameSystem:VerigameSystem;
		
		/** Function to call when the inactive board is clicked */
		public var click_callback:Function;
	
		/** True if there are currently balls being dropped/animated */
		public var dropping:Boolean = false;
		
		/** True if all balls are at the top of each pipe */
		public var reset:Boolean = true;
		
	/** Used for assigning unique pipe ids to new pipes (unique on a board level) */
		public var next_pipe_unique_id:uint = 0;
		
		/** Text to display the name of this board */
		public var title:TextField;
		
		/** Any subnetwork boards contained in this board */
		public var subnet_boards:Vector.<Board>;
		
		/** Any MapGet objects, these are displayed on the subboard_pane */
		public var mapgets:Vector.<MapGet>;
		
		/** Any linking incoming/outgoing pipe connections that allow the user to click on this board to change pipe widths on the subnetwork board without navigation to the board */
		private var subnet_links:Vector.<SubnetworkPipeLink>;
		
		/** This corresponds to the actual board that was cloned to make this (if this board is a subnetwork board) */
		public var clone_parent:Board;
		
		/** This corresponds to clones (subnetwork boards) made from this board that this board may want to update when this board changes (for example, when failed) */
		public var clone_children:Vector.<Board>;
		
		/** This corresponds to the board which contains this sub_board (if this is a subnetwork board, the sub_board_parent is the board that this board appears on) */
		public var sub_board_parent:Board;
		
		/** All circles/rectangles indicating spots where the balls are failing */
		public var trouble_points:Vector.<TroublePoint>;
		
		/** These are the nodes that were input from XML and converted to Node / Edge objects to create this board */
		public var m_boardNodes:BoardNodes;
		
		/** All subnetwork boards on this board that are currently being animated/dropped */
		public var dropping_subboards:Vector.<Board>;
		
		/** The scaleX used for subnetwork boards (if this is a subnetwork board, it will use this) */
		public var clone_scaleX:Number = 0.3;
		
		/** The scaleY used for subnetwork boards (if this is a subnetwork board, it will use this) */
		public var clone_scaleY:Number = 0.2;
		
		/** Normal boards have a clone_level of 0, a subnetwork board that appears in another board has a clone level of 1, 
		 * any subnetwork board appearing within a subnetwork board has clone level of 2, etc. */
		public var clone_level:uint = 0;
		
		/** Multiple board backgrounds used to make a background of arbitrary dimensions */
		public var board_background_tiles:RectangularObject;
		
		/** The bitmap information of the board background, read from the array of system backgrounds */
		public var board_background_bmp:Bitmap;
		
		/** The graphical layer containing all the pipes in the board */
		public var pipe_pane:RectangularObject;
		
		/** The graphical layer containing all the pipes in the board */
		public var pipe_top_layer_pane:RectangularObject;
		
		/** The graphical layer containing all the subnetwork links (above pipes, behind subnets) */
		public var subnet_link_pane:RectangularObject;
		
		/** The graphical layer containing all the pinch points in the board */
		public var pinch_point_pane:RectangularObject;
		
		/** The graphical layer containing all the balls in the board */
		public var ball_pane:RectangularObject;
		
		/** The graphical layer containing all the sub boards in the board (above pipes and balls) */
		public var sub_board_pane:RectangularObject;
		
		/** The graphical layer containing any node identifying art (such as traffic signs) */
		public var node_theme_art_pane:RectangularObject;
		
		/** The graphical layer containing all buzzsaws */
		public var buzzsaw_pane:RectangularObject;
		
		/** The graphical layer containing all the trouble points in the board (above sub_boards, balls, and pipes) */
		public var trouble_point_pane:RectangularObject;
		
		/** The graphical layer containing any stamp selector UI on the board */
		public var stamp_selector_pane:RectangularObject;
		
		/** The graphical layer used to scroll around the board (like a window) */
		public var scrolling_pane:RectangularObject;
		
		/** The maximum Y value of any pipe on this board */
		public var max_pipe_height:Number = 0.0;
		
		/** The maximum X value of any pipe on this board */
		public var max_pipe_width:Number = 0.0;
		
		/** The minimum t value for any pipe on this board */
		public var min_pipe_t:Number = 0.0;
		
		/** The maximum t value for any pipe on this board */
		public var max_pipe_t:Number = 0.0;
		
		/** True when all board pipes have been created, the board is ready to draw/play */
		public var board_pipes_constructed:Boolean = false;
		
		/** True if this board instance is simply used as the thumbnail for another (active) board to use for scrolling */
		public var is_board_navigation_map:Boolean = false;
				
		// Scroll rectangle vars
		/** True if the board is currently being scrolled automatically */
		protected var scrolling:Boolean = false;
		
		/** True if scrolling is needed for the board */
		protected var scrollable:Boolean = false;
		
		/** Current viewing area of the board */
		public var scroll_rect:Rectangle;
		
		/** Current vertival position of viewed area of the board, changed when view is automatically changed during a ball drop */
		protected var scroll_y:int = 0;
		
		/** The min value desired for scrolling */
		protected var scroll_min_y:int;
		
		/** The max value desired for scrolling */
		protected var scroll_max_y:int;
		
		/** Vertical scrolling direction used for automatic scrolling: 1=down, -1=up */
		protected var scroll_dir:int = 1;
		
		/** Button at the top of the board to enable scrolling up when moused over (not currently in use) */
		protected var scroll_up_button:ScrollButton;
		
		/** Button at the top of the board to enable scrolling down when moused over (not currently in use) */
		protected var scroll_down_button:ScrollButton;
		
		/** Speed of automatic scrolling in pixels per frame */
		protected const SCROLL_SPEED:uint = 10;
		
		/** Timer controlling automatic scrolling */
		protected var scrollTimer:Timer;
		
		/** True for user with mouse button down to allow click-drag of the board navigation bar to change view */
		protected var clicking:Boolean = false;
		
		/** Name of the board to be displayed below or on top */
		public var board_name:String = "";
				
		/** If this board is a normal (clone_level = 0) board, it will have an associated navigation map board (thumbnail used to navigate) */
		public var navigation_map_clone:Board;
		
		/** The background image used behind bitmaps/snapshots of clones (need only be drawn once) */
		private var clone_background:Bitmap;
			
		/** Map from edge set id to edges on this board */
		public var outgoingEdgeDictionary:Dictionary = new Dictionary();
		
		/** View of the board shown while the board is active, just a Bitmap snapshot of the board, pipes, subboards, and trouble points */
		public var board_snapshot:Bitmap;
		
		/** View of snapshot plus a background image */
		public var board_static_view:Sprite = new Sprite();
		
		/** True to prevent the static_board_view from being shown, used during the animation bringing up the active board, then showing the static view at the end of the animation */
		private var hide_static_view:Boolean = false;
		
		/** Starting point when user is mouse-dragging (with button down) the background to scroll around the board, null when not dragging */
		public var background_dragging_start_pt:Point;
		
		/** UI to activate/deactivate stamps on a pipe */
		private var stamp_selector:StampSelector;
		
		public var unallocated_node_ids:Vector.<String>;
		
		/**
		 * Board object representing a network of pipes, a board has succeeded when all balls can successfully travel through pipes without trouble points.
		 * @param	_x X coordinate of board (this is used for the inactive board location)
		 * @param	_y Y coordinate of board (this is used for the inactive board location)
		 * @param	_width Width of board (this is used for the inactive board width)
		 * @param	_height Height of board (this is used for the inactive board height)
		 * @param	_name Board name
		 * @param	_start_t Beginning t value (mostly likely 0 for normal boards, > 0 for subnetwork boards)
		 * @param	_level Level that this board is contained within
		 * @param	_system Parent VerigameSystem instance
		 * @param	_click_callback Function to be called when the inactive version of the board is clicked
		 * @param	_clone_parent Board that was used to clone this board (if any)
		 */
		public function Board(_x:int, _y:int, _width:uint, _height:uint, _name:String, _start_t:Number, _level:Level, _system:VerigameSystem, _click_callback:Function, _clone_parent:Board = null, _clone_level:int = 0)
		{
			super(_x, _y, _width, _height);
			original_x = _x;
			original_y = _y;
			original_width = _width;
			original_height = _height;
			board_name = _name;
			name = "Board:" + board_name;
			start_t = _start_t;
			level = _level;
			m_gameSystem = _system;
			click_callback = _click_callback;
			clone_parent = _clone_parent;
			clone_level = _clone_level;
			overlay = new Sprite();
			overlay.buttonMode = true;
			overlay.addEventListener(MouseEvent.CLICK, boardClick);
			overlay.addEventListener(MouseEvent.ROLL_OVER, boardRollOver);
			overlay.addEventListener(MouseEvent.ROLL_OUT, boardRollOut);
			overlay.name = "overlay";
			
			var tf:TextFormat = new TextFormat(Fonts.FONT_DEFAULT, ACTIVE_FONT_SIZE, 0xFFFF00, true, false, false, null, null, TextFormatAlign.CENTER);
			title = new TextField();
			title.embedFonts = true;
			title.text = board_name;
			title.setTextFormat(tf);
			title.wordWrap = true;
			title.width = width;
			title.x = 0;
			//title.background = true;
			//title.backgroundColor = 0x26A9E0;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.y = height + 20;
			//title.width = title.textWidth;
			title.selectable = false;
			//title.y = 0.5 * (m_height - title.textHeight);
			title.name = "title";
			
			if (clone_parent == null) {
				_pipes = new Vector.<Pipe>();
				
				pipe_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				pipe_top_layer_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				subnet_link_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				pinch_point_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				ball_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				sub_board_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				node_theme_art_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				buzzsaw_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				trouble_point_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				stamp_selector_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				scrolling_pane = new RectangularObject( -20, -20, _width + 40, _height + 40 );
				
				pipe_pane.name = "pipe_pane";
				pipe_top_layer_pane.name = "pipe_top_layer_pane";
				subnet_link_pane.name = "subnet_link_pane";
				pinch_point_pane.name = "pinch_point_pane";
				ball_pane.name = "ball_pane";
				sub_board_pane.name = "sub_board_pane";
				node_theme_art_pane.name = "node_theme_art_pane";
				buzzsaw_pane.name = "buzzsaw_pane";
				trouble_point_pane.name = "trouble_point_pane";
				stamp_selector_pane.name = "stamp_selector_pane";
				scrolling_pane.name = "scrolling_pane";
				board_static_view.name = "board_static_view";
				
				if (level.world.worldBoardNameDictionary[board_name]) {
					throw new Error("Duplicate board name found in a given world, these must be unique! Name: " + board_name);
				}
				level.world.worldBoardNameDictionary[board_name] = this;
				original_scaleX = 1.0;
				original_scaleY = 1.0;
				
				var level_indx:int = Math.max(0, level.world.levels.indexOf(level));
				if (m_gameSystem.level_background_images[level_indx % m_gameSystem.level_background_images.length] != null) {
					board_background_bmp = new Bitmap((m_gameSystem.level_background_images[level_indx % m_gameSystem.level_background_images.length] as Bitmap).bitmapData);
					board_background_bmp.name = "board_background_bmp";
				} else {
					board_background_bmp = null;
				}
				subnet_boards = new Vector.<Board>();
				mapgets = new Vector.<MapGet>();
				subnet_links = new Vector.<SubnetworkPipeLink>();
				clone_children = new Vector.<Board>();
				trouble_points = new Vector.<TroublePoint>();
				dropping_subboards = new Vector.<Board>();
				
				scroll_min_y = 40 - 18;// Pipe.WIDE_BALL_RADIUS;
				scroll_max_y = 40 - 18;// Pipe.WIDE_BALL_RADIUS;
				scroll_rect = new Rectangle(-40, -40, _width + 40, _height + 40); 
				scrolling_pane.scrollRect = scroll_rect;
				
			} else {
				scrolling_pane = new RectangularObject( -20, -20, _width + 40, _height + 40);
				scrolling_pane.name = "scrolling_pane";
				original_scaleX = clone_scaleX;
				original_scaleY = clone_scaleY;
				scaleX = original_scaleX;
				scaleY = original_scaleY;
				var tf2:TextFormat = title.getTextFormat();
				tf2.size = CLONE_FONT_SIZE;
				title.setTextFormat(tf2);
				title.y = 0.5 * (height - title.textHeight * title.numLines);
				title.background = false;
			}
		}
		
		public function createBoard(original_subboard_nodes:Vector.<Node>):void
		{
			var next_nodes_to_process:Vector.<Node> = new Vector.<Node>();
			for each (var beg_node:Node in m_boardNodes.beginningNodes) {
				next_nodes_to_process.push(beg_node);
			}
			var first_node_checked_in_loop:Node;
			while (unallocated_node_ids.length > 0) {
				var my_node_to_create:Node;
				if (next_nodes_to_process.length > 0) {
					my_node_to_create = next_nodes_to_process.shift();
					var all_incoming_nodes_complete:Boolean = true;
					for each (var in_port:Port in my_node_to_create.incoming_ports) {
						if (unallocated_node_ids.indexOf(in_port.edge.from_node.node_id) > -1) {
							all_incoming_nodes_complete = false;
							break;
						}
					}
					if (!all_incoming_nodes_complete) {
						if (first_node_checked_in_loop == my_node_to_create) {
							throw new Error("Loop detected where next nodes to be processed all have at least on incoming edge that has not been processed");
						} else {
							//update only if current first node checked is not null and no longer in unallocated nodes
							if (first_node_checked_in_loop == null || unallocated_node_ids.indexOf(first_node_checked_in_loop.node_id) == -1)
								first_node_checked_in_loop = my_node_to_create;
						}
						next_nodes_to_process.push(my_node_to_create);
						continue;
					}
				} else {
					throw new Error("Nodes found that were not traversed using top-down method in board: " + board_name);
				}
				first_node_checked_in_loop = null;
				if (unallocated_node_ids.indexOf(my_node_to_create.node_id) == -1) {
					throw new Error("Node traversed twice during loading " + my_node_to_create.node_id);
				}
				
				unallocated_node_ids.splice(unallocated_node_ids.indexOf(my_node_to_create.node_id), 1);
				if (my_node_to_create.node_board == null) {
					my_node_to_create.node_board = this;
				}
				switch (my_node_to_create.kind) {
					case NodeTypes.INCOMING:
						VerigameSystem.printDebug("Processing "+NodeTypes.INCOMING+" node with id: " + my_node_to_create.node_id);
						for (var oe_indx:uint = 0; oe_indx < my_node_to_create.outgoing_ports.length; oe_indx++) {
							// TODO URGENT: what should the is_wide property be? probably set in XML
							var my_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * (my_node_to_create.x + Number(my_node_to_create.outgoing_ports[oe_indx].edge.from_port_id)), 
								VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, my_node_to_create.outgoing_ports[oe_indx].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[oe_indx].edge.linked_edge_set.id), 
								this, false, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, -1, true, -1, my_node_to_create.outgoing_ports[oe_indx].edge);
							m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[oe_indx].edge, my_node_to_create.outgoing_ports[oe_indx].edge.linked_edge_set.id);
							my_node_to_create.associated_pipes.push(my_pipe);
							my_node_to_create.outgoing_ports[oe_indx].edge.associated_pipe = my_pipe;
							addPipe(my_pipe);
						}
						break;
					case NodeTypes.SPLIT:
					case NodeTypes.BALL_SIZE_TEST:
						if (my_node_to_create.kind == NodeTypes.SPLIT) {
							VerigameSystem.printDebug("Processing " + NodeTypes.SPLIT + " node with id: " + my_node_to_create.node_id);
						} else {
							VerigameSystem.printDebug("Processing " + NodeTypes.BALL_SIZE_TEST + " node with id: " + my_node_to_create.node_id);
						}
						if (my_node_to_create.incoming_ports.length != 1) {
							VerigameSystem.printDebug("WARNING! '"+my_node_to_create.kind+"' node found with number of incoming edges != 1...");
							break;
						}
						if (my_node_to_create.outgoing_ports.length != 2) {
							VerigameSystem.printDebug("WARNING! '"+my_node_to_create.kind+"' node found with number of outgoing edges != 2...");
							break;
						}
						var adjustable:Boolean = (my_node_to_create.kind == NodeTypes.SPLIT);
						var color0:Number = level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id);
						var color1:Number = level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[1].edge.linked_edge_set.id);
						var width0:Boolean = my_node_to_create.outgoing_ports[0].edge.starting_is_wide;
						var width1:Boolean = my_node_to_create.outgoing_ports[1].edge.starting_is_wide;
						if (!adjustable) {
							if (my_node_to_create.outgoing_ports[0].edge.editable) {
								VerigameSystem.printWarning("Edge id " + my_node_to_create.outgoing_ports[0].edge.edge_id + " is editable, but coming from a "+NodeTypes.BALL_SIZE_TEST+" node. This is unexpected behavior.");
							}
							if (my_node_to_create.outgoing_ports[1].edge.editable) {
								VerigameSystem.printWarning("Edge id " + my_node_to_create.outgoing_ports[1].edge.edge_id + " is editable, but coming from a "+NodeTypes.BALL_SIZE_TEST+" node. This is unexpected behavior.");
							}
							color0 = VerigameSystem.UNADJUSTABLE_PIPE_COLOR;
							color1 = VerigameSystem.UNADJUSTABLE_PIPE_COLOR;
							width0 = my_node_to_create.outgoing_ports[0].edge.starting_is_wide;
							width1 = my_node_to_create.outgoing_ports[1].edge.starting_is_wide;
						}
						var my_split_pipe1:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, 
							width0, color0, this, false, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, my_node_to_create.incoming_ports[0].edge.associated_pipe.pipe_depth, adjustable, -1, my_node_to_create.outgoing_ports[0].edge);
						
						var my_split_pipe2:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, 
							width1, color1, this, false, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, my_node_to_create.incoming_ports[0].edge.associated_pipe.pipe_depth, adjustable, -1, my_node_to_create.outgoing_ports[1].edge);
						
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = my_split_pipe1;
						my_node_to_create.outgoing_ports[1].edge.associated_pipe = my_split_pipe2;
						my_node_to_create.associated_pipes.push(my_split_pipe1);
						my_node_to_create.associated_pipes.push(my_split_pipe2);
						
						addPipe(my_split_pipe1);
						addPipe(my_split_pipe2);
						break;
					case NodeTypes.CONNECT:
						VerigameSystem.printDebug("Processing "+NodeTypes.CONNECT+" node with id: " + my_node_to_create.node_id);
						if (my_node_to_create.incoming_ports.length != 1) {
							VerigameSystem.printDebug("WARNING! '"+NodeTypes.CONNECT+"' node found with number of incoming edges != 1...");
							break;
						}
						if (my_node_to_create.outgoing_ports.length != 1) {
							VerigameSystem.printDebug("WARNING! '"+NodeTypes.CONNECT+"' node found with number of outgoing edges != 1...");
							break;
						}
						
						var new_connect_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, my_node_to_create.outgoing_ports[0].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id), 
							this, false, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, -1, true, -1, my_node_to_create.outgoing_ports[0].edge);
						// Add this to starting edge dictionary if not linked edges (though I think they ought to be linked if they are connected
						if (my_node_to_create.incoming_ports[0].edge.linked_edge_set.id != my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id) {
							m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[0].edge, my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id);
						}
						my_node_to_create.associated_pipes.push(my_node_to_create.incoming_ports[0].edge.associated_pipe);
						my_node_to_create.associated_pipes.push(new_connect_pipe);
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = new_connect_pipe;
						addPipe(new_connect_pipe);
						break;
					case NodeTypes.MERGE:
						VerigameSystem.printDebug("Processing "+NodeTypes.MERGE+" node with id: " + my_node_to_create.node_id);
						if (my_node_to_create.incoming_ports.length != 2) {
							VerigameSystem.printDebug("WARNING! '"+NodeTypes.MERGE+"' node found with number of incoming edges != 2...");
							break;
						}
						if (my_node_to_create.outgoing_ports.length != 1) {
							VerigameSystem.printDebug("WARNING! '"+NodeTypes.MERGE+"' node found with number of outgoing edges != 1...");
							break;
						}
						
						var my_merge_pipe_child:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, my_node_to_create.outgoing_ports[0].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id), 
							this, false, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_node_to_create.y, -1, true, -1, my_node_to_create.outgoing_ports[0].edge);
						// For outgoing merge edge that is not associated with either incoming edge (different color), add this to starting edge dictionary
						if ( (my_node_to_create.incoming_ports[0].edge.linked_edge_set.id != my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id) && (my_node_to_create.incoming_ports[1].edge.linked_edge_set.id != my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id) ) {
							m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[0].edge, my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id);
						}
						
						my_node_to_create.associated_pipes.push(my_node_to_create.incoming_ports[0].edge.associated_pipe);
						my_node_to_create.associated_pipes.push(my_node_to_create.incoming_ports[1].edge.associated_pipe);
						my_node_to_create.associated_pipes.push(my_merge_pipe_child);
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = my_merge_pipe_child;
						addPipe(my_merge_pipe_child);
						break;
					case NodeTypes.SUBBOARD:
						VerigameSystem.printDebug("Processing " + NodeTypes.SUBBOARD + " node with id: " + my_node_to_create.node_id);
						original_subboard_nodes.push(my_node_to_create);
						my_node_to_create.orderEdgesByPort();
						for (var ie_indx:uint = 0; ie_indx < my_node_to_create.incoming_ports.length; ie_indx++) {
							my_node_to_create.associated_pipes.push(my_node_to_create.incoming_ports[ie_indx].edge.associated_pipe);
						}
						
						// Look up port of current outgoing edge
						for (var oe_indx1:uint = 0; oe_indx1 < my_node_to_create.outgoing_ports.length; oe_indx1++) {

							var subnetwork_outgoing_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * (my_node_to_create.x + Number(oe_indx1)), 
								VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y + 0.0), my_node_to_create.outgoing_ports[oe_indx1].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[oe_indx1].edge.linked_edge_set.id),
								this, false, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y + 0.0), -1, true, -1, my_node_to_create.outgoing_ports[oe_indx1].edge);
							
							m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[oe_indx1].edge, my_node_to_create.outgoing_ports[oe_indx1].edge.linked_edge_set.id);
							
							my_node_to_create.associated_pipes.push(subnetwork_outgoing_pipe);
							
							my_node_to_create.outgoing_ports[oe_indx1].edge.associated_pipe = subnetwork_outgoing_pipe;
							addPipe(subnetwork_outgoing_pipe);
						}
						break;
					case NodeTypes.GET:
						//for some reason, the y value gets set to 0 before here, although it was created correctly, so reset
						my_node_to_create.y = my_node_to_create.metadata.xml.layout.y;
						VerigameSystem.printDebug("Processing " + NodeTypes.GET + " node with id: " + my_node_to_create.node_id);
						if (my_node_to_create.incoming_ports.length != 4) {
							VerigameSystem.printWarning("WARNING! '"+NodeTypes.GET+"' node found with number of incoming edges != 4...");
							break;
						}
						if (my_node_to_create.outgoing_ports.length != 1) {
							VerigameSystem.printWarning("WARNING! '"+NodeTypes.GET+"' node found with number of outgoing edges != 1...");
							break;
						}
						var my_edge:Edge = my_node_to_create.outgoing_ports[0].edge;
						if (my_edge.spline_control_points == null) {
							VerigameSystem.printWarning("WARNING! '" + NodeTypes.GET + "' node found with outgoing edge containing no spline_control_points..."); 
							break;
						}
						if (my_edge.spline_control_points.length == 0) {
							VerigameSystem.printWarning("WARNING! '" + NodeTypes.GET + "' node found with outgoing edge containing no spline_control_points...");
							break;
						}
						var my_mapget_output_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_edge.spline_control_points[0].x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_edge.spline_control_points[0].y, my_node_to_create.outgoing_ports[0].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id), 
							this, true, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * my_edge.spline_control_points[0].y, -1, true, -1, my_node_to_create.outgoing_ports[0].edge);
						my_node_to_create.associated_pipes.push(my_mapget_output_pipe);
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = my_mapget_output_pipe;
						addPipe(my_mapget_output_pipe);
						
						var my_mapget:MapGet = new MapGet( VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y), 4 * VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE, VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE + 2 * Pipe.WIDE_BALL_RADIUS + 10, (my_node_to_create as MapGetNode), this);
						(my_node_to_create as MapGetNode).associated_mapget = my_mapget;
						mapgets.push(my_mapget);
						
						break;
					case NodeTypes.START_SMALL_BALL:
					case NodeTypes.START_NO_BALL:
						var my_start_white_ball_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y - 0.0), my_node_to_create.outgoing_ports[0].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id), 
							this, true, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y - 0.0), -1, true, -1, my_node_to_create.outgoing_ports[0].edge);
						
						m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[0].edge, my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id);
						
						my_node_to_create.associated_pipes.push(my_start_white_ball_pipe);
						
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = my_start_white_ball_pipe;
						addPipe(my_start_white_ball_pipe);
						break;
					case NodeTypes.START_LARGE_BALL:
						var my_start_black_ball_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y - 0.0), true, VerigameSystem.UNADJUSTABLE_PIPE_COLOR, this, true, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y - 0.0), -1, false, -1, my_node_to_create.outgoing_ports[0].edge);
						// TODO: Re-evaluate using a pipe id of -1 above, but keeping track of set index starting point here
						m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[0].edge, my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id);
						
						my_node_to_create.associated_pipes.push(my_start_black_ball_pipe);
						
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = my_start_black_ball_pipe;
						addPipe(my_start_black_ball_pipe);
						break;
					case NodeTypes.START_PIPE_DEPENDENT_BALL:
						var my_start_pipe_dependent_ball_pipe:Pipe = new Pipe(VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * my_node_to_create.x, 
							VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y - 0.0), my_node_to_create.outgoing_ports[0].edge.starting_is_wide, level.getColorByEdgeSetId(my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id), 
							this, true, VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * (my_node_to_create.y - 0.0), -1, true, -1, my_node_to_create.outgoing_ports[0].edge);
						
						m_boardNodes.addStartingEdgeToDictionary(my_node_to_create.outgoing_ports[0].edge, my_node_to_create.outgoing_ports[0].edge.linked_edge_set.id);
						
						my_node_to_create.associated_pipes.push(my_start_pipe_dependent_ball_pipe);
						
						my_node_to_create.outgoing_ports[0].edge.associated_pipe = my_start_pipe_dependent_ball_pipe;
						addPipe(my_start_pipe_dependent_ball_pipe);
						break;
					case NodeTypes.END:
						VerigameSystem.printDebug("Processing "+NodeTypes.END+" node with id: " + my_node_to_create.node_id);
						if (my_node_to_create.incoming_ports.length != 1) {
							VerigameSystem.printWarning("WARNING! '"+NodeTypes.END+"' node found with number of incoming edges != 1...");
							break;
						}
						my_node_to_create.associated_pipes.push(my_node_to_create.incoming_ports[0].edge.associated_pipe);
						break;
					case NodeTypes.OUTGOING:
						VerigameSystem.printDebug("Processing "+NodeTypes.OUTGOING+" node with id: " + my_node_to_create.node_id);
						for (var ie_indx2:uint = 0; ie_indx2 < my_node_to_create.incoming_ports.length; ie_indx2++) {
							addOutgoingEdgeToDictionary(my_node_to_create.incoming_ports[ie_indx2].edge, my_node_to_create.incoming_ports[ie_indx2].edge.linked_edge_set.id);
							my_node_to_create.associated_pipes.push(my_node_to_create.incoming_ports[ie_indx2].edge.associated_pipe);
						}
						break;
					case "LAYOUT": // Deprecated: This was used to force pipes to certain locations for layout purposes - GraphViz doesn't use this
						VerigameSystem.printWarning("WARNING! \"LAYOUT\" nodes have been deprecated.");
						break;
					default:
						VerigameSystem.printWarning("WARNING! NODE KIND NOT FOUND: " + my_node_to_create.kind);
				}
				// Queue outgoing nodes (if not already queued)
				for each (var outgoing_ports_to_process:Port in my_node_to_create.outgoing_ports) {
					if (next_nodes_to_process.indexOf(outgoing_ports_to_process.edge.to_node) == -1) {
						next_nodes_to_process.push(outgoing_ports_to_process.edge.to_node);
					}
				}
			}
			deactivate();
			scaleX = NavigationPanel.INACTIVE_BOARD_SCALEX;
			scaleY = NavigationPanel.INACTIVE_BOARD_SCALEY;
		}
		
		/**
		 * Called after pipes have been added to the board to update min/max values of the pipes on the board (which determines board dimensions) and draw the background
		 */
		public function finishBoard():void {
			var max_height:Number = Number.NEGATIVE_INFINITY;
			var max_width:Number = Number.NEGATIVE_INFINITY;
			//var max_t:Number = Number.NEGATIVE_INFINITY;
			var min_t:Number = Number.POSITIVE_INFINITY;
			
			
			if (clone_level == 0) {
				for each (var pipe_done_constructing:Pipe in _pipes) {
					pipe_done_constructing.interpolateSpline();
					if (pipe_done_constructing.max_spline_x > max_width) {
						max_width = pipe_done_constructing.max_spline_x;
					}
					if (pipe_done_constructing.max_spline_y > max_height) {
						max_height = pipe_done_constructing.max_spline_y;
					}
					if (pipe_done_constructing.min_spline_y < min_t) {
						min_t = pipe_done_constructing.min_spline_y;
					}
					pipe_done_constructing.finishPipe();
					if (pipe_done_constructing.max_spline_y - height + Pipe.WIDE_BALL_RADIUS > scroll_max_y) {
						scroll_max_y = pipe_done_constructing.max_spline_y - height + Pipe.WIDE_BALL_RADIUS;
					}
					if (pipe_done_constructing.parent == pipe_pane) {
						pipe_pane.setChildIndex(pipe_done_constructing, 0);
					} else {
						pipe_pane.addChildAt(pipe_done_constructing, 0);
					}
					if (pipe_done_constructing.top_layer.parent == pipe_top_layer_pane) {
						pipe_top_layer_pane.setChildIndex(pipe_done_constructing.top_layer, pipe_top_layer_pane.numChildren - 1);
					} else {
						pipe_top_layer_pane.addChild(pipe_done_constructing.top_layer);
					}
					// Add associated pipes nubs to subnetwork nodes at connection points
					if (clone_level == 0) {
						// Pipes that lead INTO a subnet
						if (pipe_done_constructing.associated_edge.to_node.kind == NodeTypes.SUBBOARD) {
							var subnet_edge:Edge = (pipe_done_constructing.associated_edge.to_port as SubnetworkPort).linked_subnetwork_edge;
							if (subnet_edge) {
								var new_subnet_link:SubnetworkPipeLink = new SubnetworkPipeLink(pipe_done_constructing, subnet_edge, true);
								subnet_links.push(new_subnet_link);
							} else {
								throw new Error("Corresponding edge linked to incoming Subnetwork edge id " + pipe_done_constructing.associated_edge.edge_id + " not found. Check linkage.");
							}
						}
						// Pipes that lead OUT OF a subnet
						if (pipe_done_constructing.associated_edge.from_node.kind == NodeTypes.SUBBOARD) {
							var subnet_edge2:Edge = (pipe_done_constructing.associated_edge.from_port as SubnetworkPort).linked_subnetwork_edge;
							if (subnet_edge2) {
								var new_subnet_link2:SubnetworkPipeLink = new SubnetworkPipeLink(pipe_done_constructing, subnet_edge2, false);
								subnet_links.push(new_subnet_link2);
							} else {
								throw new Error("Corresponding edge linked to outgoing Subnetwork edge id " + pipe_done_constructing.associated_edge.edge_id + " not found. Check linkage.");
							}
						}
					}
				}
				//trace("Max w/h for " + board_name + " : " + max_width + ", " + max_height);
				max_pipe_height = max_height;
				max_pipe_width = max_width;
				max_pipe_t = max_height;
				min_pipe_t = min_t;
			} else if (clone_parent != null) {
				max_pipe_height = clone_parent.max_pipe_height;
				max_pipe_width = clone_parent.max_pipe_width;
				max_pipe_t = clone_parent.max_pipe_t;
				min_pipe_t = clone_parent.min_pipe_t;
			} else {
				throw new Error("Attempting to call finishBoard() on board clone with clone_parent == null");
			}
			
			
			if (max_pipe_height - Number(height) > 40.0) {
				scrollable = true;
				/*
				if (scroll_up_button.parent == this)
					removeChild(scroll_up_button);
				addChild(scroll_up_button);
				if (scroll_down_button.parent == this)
					removeChild(scroll_down_button);
				addChild(scroll_down_button);
				*/
			}
			if (clone_level == 0) {
				var nav_board:Board = createClone(NavigationPanel.NAVIGATION_BOARD_WIDTH, NavigationPanel.NAVIGATION_BOARD_HEIGHT, 1, true);

			}
			// Mark all pipes as finished constructing and store the max_pipe_height and max_pipe_width
			board_pipes_constructed = true;
			drawTiledBackgrounds();
			for each (var sb:Board in subnet_boards) {
				if (sb.parent == sub_board_pane) {
					sub_board_pane.removeChild(sb);
				}
				sub_board_pane.addChild(sb);
			}
			
			for each (var mg:MapGet in mapgets) {
				if (mg.parent == sub_board_pane) {
					sub_board_pane.removeChild(mg);
				}
				sub_board_pane.addChild(mg);
			}
			
			for each (var sl:SubnetworkPipeLink in subnet_links) {
				if (sl.parent == subnet_link_pane) {
					subnet_link_pane.removeChild(sl);
				}
				subnet_link_pane.addChild(sl);
			}

			updateCloneChildrenToMatch();
		}
		
		public function drawBoardView(forceDraw:Boolean = false):void {
			if (!forceDraw) {
				// Only redraw this when necessary, drawBoardView will be called when redraw is needed
				var drawLater:Boolean = false;
				if ( ((clone_level == 0) && !active)
					|| (is_board_navigation_map && !clone_parent.active)
					|| (sub_board_parent && !sub_board_parent.active) ) {
					drawLater = true;
				}
				var drawNow:Boolean = false;
				if ( ((clone_level == 0) && active)
					|| (is_board_navigation_map && clone_parent.active)
					|| (sub_board_parent && sub_board_parent.active) ) {
					drawNow = true;
				}
				if (drawNow || drawLater) {
					if (board_snapshot) {
						if (board_snapshot.parent) {
							board_snapshot.parent.removeChild(board_snapshot);
						}
						board_snapshot = null;
					}
					if (drawLater) {
						return;
					}
				}
				if (board_snapshot && board_snapshot.bitmapData) {
					// No need to redraw
					return;
				}
			}
			
			drawBoardImages();
		}
		
		//draws the two views of the board, active (large - play) and static (small - navigation)
		public function drawBoardImages():void
		{
			if (clone_level == 1) {
				// For visible clone boards (subboards on boards or the navigation map, both with clone_level == 1)
				// this method will redraw the updated view of the clone_parent onto this board.
				if (clone_parent) {
					if (!(clone_parent.board_snapshot && clone_parent.board_snapshot.bitmapData)) {
						clone_parent.drawBoardImages();
					}
					if (is_board_navigation_map) {
						if (!clone_background && clone_parent.board_background_bmp && clone_parent.board_background_bmp.bitmapData) {
							clone_background = new Bitmap(clone_parent.board_background_bmp.bitmapData, PixelSnapping.ALWAYS, false);
							clone_background.width = overlay.width - 20;
							clone_background.height = overlay.height - 20;
							clone_background.x = -10;
							clone_background.y = -10;
							scrolling_pane.addChildAt(clone_background, 0);
						}
					}
					board_snapshot = new Bitmap(clone_parent.board_snapshot.bitmapData, PixelSnapping.ALWAYS, false);
					board_snapshot.width = overlay.width - 20;
					board_snapshot.height = overlay.height - 20;
					//	scrolling_pane.addChild(board_snapshot);
				} else {
					throw new Error("No clone_parent board snapshot found for board: " + board_name + " (clone_level: " + clone_level + ")");
				}
				return;
			} else if (clone_level > 1) {
				return;
			}
			var snapshot_bitmap_data:BitmapData = new BitmapData(Math.min(4095, NavigationPanel.INACTIVE_BOARD_SCALEX * Math.max(width, max_pipe_width + 2 * WIDE_PIPE_WIDTH)), Math.min(4095, NavigationPanel.INACTIVE_BOARD_SCALEY * Math.max(height, max_pipe_height)), true, 0xFFFFFF);
			
			var background_bmd:BitmapData;
			if (!clone_background) {
				if ((board_background_bmp != null) && (board_background_bmp.bitmapData != null)) {
					clone_background = new Bitmap(board_background_bmp.bitmapData, PixelSnapping.ALWAYS, false);
					clone_background.width = NavigationPanel.INACTIVE_BOARD_SCALEX * VerigameSystem.GAME_WIDTH;
					clone_background.height = NavigationPanel.INACTIVE_BOARD_SCALEY * VerigameSystem.GAME_HEIGHT;
					board_static_view.addChildAt(clone_background, 0);
				} else {
					throw new Error("No board background bitmap data found for board: " + board_name + " (clone_level: " + clone_level + ")");
				}
			}
			
			var highlight_pipes:Vector.<Pipe> = new Vector.<Pipe>();
			if (active) {
				for each (var p:Pipe in _pipes) {
					if (p.highlight) {
						highlight_pipes.push(p);
						p.highlight = false;
						p.draw();
					}
				}
			}
			
			var mat:Matrix = new Matrix();
			//TEST//mat.scale(VerigameSystem.INACTIVE_BOARD_SCALEX, VerigameSystem.INACTIVE_BOARD_SCALEY);
			mat.scale(original_width * NavigationPanel.INACTIVE_BOARD_SCALEX / scrolling_pane.width, original_height * NavigationPanel.INACTIVE_BOARD_SCALEY / scrolling_pane.height);
			snapshot_bitmap_data.draw(pipe_pane, mat);
			
			for each (var hp:Pipe in highlight_pipes) {
				hp.highlight = true;
				hp.draw();
			}
			
			snapshot_bitmap_data.draw(pinch_point_pane, mat);
			snapshot_bitmap_data.draw(sub_board_pane, mat);
			snapshot_bitmap_data.draw(subnet_link_pane, mat);
			snapshot_bitmap_data.draw(node_theme_art_pane, mat);
			snapshot_bitmap_data.draw(buzzsaw_pane, mat);
			snapshot_bitmap_data.draw(trouble_point_pane, mat);
			board_snapshot = new Bitmap(snapshot_bitmap_data, PixelSnapping.ALWAYS, false);
			board_snapshot.name = "board_snapshot";
			board_snapshot.width = NavigationPanel.INACTIVE_BOARD_SCALEX * VerigameSystem.GAME_WIDTH;
			board_snapshot.height = NavigationPanel.INACTIVE_BOARD_SCALEY * VerigameSystem.GAME_HEIGHT;
			board_static_view.addChild(board_snapshot);
			board_static_view.graphics.clear();
			board_static_view.graphics.lineStyle(20 * NavigationPanel.INACTIVE_BOARD_SCALEX, lineColor);
			board_static_view.graphics.drawRect( -10 * NavigationPanel.INACTIVE_BOARD_SCALEX, -10 * NavigationPanel.INACTIVE_BOARD_SCALEX, NavigationPanel.INACTIVE_BOARD_SCALEX * (VerigameSystem.GAME_WIDTH + 20), NavigationPanel.INACTIVE_BOARD_SCALEY * VerigameSystem.GAME_HEIGHT + 20 * NavigationPanel.INACTIVE_BOARD_SCALEX);
		}
		
		public function showStaticView():void {
			if (clone_level > 0) {
				return;
			}
			hide_static_view = false;
			if (active) {
				m_gameSystem.addChild(board_static_view);
			}
		}
		
		public function hideStaticView():void {
			if (clone_level > 0) {
				return;
			}
			hide_static_view = true;
			if (board_static_view.parent) {
				board_static_view.parent.removeChild(board_static_view);
			}
		}
		
		/**
		 * Adds the input edge and edge set index id pair to the outgoingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	id An edge set id to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
		public function addOutgoingEdgeToDictionary(e:Edge, id:String, checkIfExists:Boolean = true):void {
			if (outgoingEdgeDictionary[id] == null) {
				outgoingEdgeDictionary[id] = new Vector.<Edge>();
			}
			if ((!checkIfExists) || (outgoingEdgeDictionary[id].indexOf(e) == -1)) {
				outgoingEdgeDictionary[id].push(e);
			}
		}
		
		//add the pipe to the pipe vector and hook up a listener to listen for changes
		public function addPipe(p:Pipe):void
		{
			_pipes.push(p);
		}
		
		public function get pipes():Vector.<Pipe>
		{
			return _pipes;
		}
		
		protected function updatePipes():void
		{
			for each (var pipe:Pipe in _pipes)
			{
				pipe.finishPipe();
				pipe.draw();
			}
			updateCloneChildrenToMatch();
			m_gameSystem.game_control_panel.updateScore();
		}
		

		

		
		/**
		 * Draws the board including green/red outlines for succeeded/failed
		 */
		public function draw():void {
			graphics.clear();
			if (clone_level > 0) {
				graphics.beginFill(0xAAAAAA);
				graphics.drawRect(0, 0, width, height);
			} else {
				if (board_background_tiles != null) {
					if (board_background_bmp != null) {
						if (board_background_bmp.parent == this) {
							removeChild(board_background_bmp);
						}
					}
					if (board_background_tiles.parent != scrolling_pane) {
						scrolling_pane.addChildAt(board_background_tiles, 0);
					} else {
						scrolling_pane.setChildIndex(board_background_tiles, 0);
					}
				} else if (board_pipes_constructed) {
					drawTiledBackgrounds();
				}
				board_static_view.graphics.clear();
				board_static_view.graphics.lineStyle(20 * NavigationPanel.INACTIVE_BOARD_SCALEX, lineColor);
				board_static_view.graphics.drawRect( -10 * NavigationPanel.INACTIVE_BOARD_SCALEX, -10 * NavigationPanel.INACTIVE_BOARD_SCALEX, NavigationPanel.INACTIVE_BOARD_SCALEX * (VerigameSystem.GAME_WIDTH + 20), NavigationPanel.INACTIVE_BOARD_SCALEY * VerigameSystem.GAME_HEIGHT + 20 * NavigationPanel.INACTIVE_BOARD_SCALEX);
			}
			
			if (!is_board_navigation_map) {
				graphics.lineStyle(20, lineColor);
		//		graphics.drawRect(-10, -10, width+20, height+20);
			}
			
			overlay.graphics.clear();
			if (highlight) {
				overlay.graphics.beginFill(0xFFFFFF, 0.3);//highlighting lightens for added emphasis
			} else {
				overlay.graphics.beginFill(0x000000, 0.4);
			}
			if (clone_level == 0) {
				overlay.graphics.lineStyle(20, lineColor);
			} else {
				if ((trouble_points && trouble_points.length) || (clone_parent.trouble_points && clone_parent.trouble_points.length)) {
					overlay.graphics.lineStyle(40, 0xFF0000);
				} else
				{
					overlay.graphics.lineStyle(20, 0x00FF00);
				}
			}
			if (is_board_navigation_map) {
				overlay.graphics.lineStyle(20, 0x444444);
				overlay.graphics.beginFill(0xFFFFFF, 0);
				overlay.graphics.drawRect(-10, -10, Math.max(width, max_pipe_width + 2*WIDE_PIPE_WIDTH) + 20, Math.max(height, max_pipe_height) + 20);
			} else {
				overlay.graphics.drawRect(-10, -10, width + 20, height + 20);
			}
			overlay.graphics.endFill();
			
			switch (clone_level) {
				case 0:
					for each (var tp:Sprite in trouble_points) {
						if (tp.parent == trouble_point_pane) {
							trouble_point_pane.setChildIndex(tp, trouble_point_pane.numChildren - 1);
						} else {
							trouble_point_pane.addChild(tp);
						}
					}
					if (pipe_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(pipe_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(pipe_pane);
					}
					if (pipe_top_layer_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(pipe_top_layer_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(pipe_top_layer_pane);
					}
					if (sub_board_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(sub_board_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(sub_board_pane);
					}
					if (subnet_link_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(subnet_link_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(subnet_link_pane);
					}
					if (pinch_point_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(pinch_point_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(pinch_point_pane);
					}
					if (ball_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(ball_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(ball_pane);
					}
					if (node_theme_art_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(node_theme_art_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(node_theme_art_pane);
					}
					if (buzzsaw_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(buzzsaw_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(buzzsaw_pane);
					}
					if (trouble_point_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(trouble_point_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(trouble_point_pane);
					}
					if (stamp_selector_pane.parent == scrolling_pane) {
						scrolling_pane.setChildIndex(stamp_selector_pane, scrolling_pane.numChildren - 1);
					} else {
						scrolling_pane.addChild(stamp_selector_pane);
					}
					if (scrolling_pane.parent == this) {
						setChildIndex(scrolling_pane, numChildren - 1);
					} else {
						addChild(scrolling_pane);
					}
				break;
				case 1:
					//while (scrolling_pane.numChildren > 0) { pipe_pane.removeChildAt(0); }
					if (scrolling_pane.parent == this) {
						setChildIndex(scrolling_pane, numChildren - 1);
					} else {
						addChild(scrolling_pane);
					}
					if (board_snapshot) {
						scrolling_pane.addChild(board_snapshot);
					}
				break;
			}
			
			if (title && title.parent == this) {
				removeChild(title);
			}
			// no title if sub_board of an inactive board
			if (is_board_navigation_map) {
				// no title

			} else if (sub_board_parent == null && title) {
				addChild(title);
			} else if (sub_board_parent && sub_board_parent.active && title) {
				addChild(title);
			}
			
			/*
			if (scroll_up_button.parent == this) {
				removeChild(scroll_up_button);
			}
			addChild(scroll_up_button);
			if (scroll_down_button.parent == this) {
				removeChild(scroll_down_button);
			}
			addChild(scroll_down_button);
			*/
			
			if (active && !is_board_navigation_map) {
				if (overlay.parent == this) {
					removeChild(overlay);
				}
			} else {
				if (overlay.parent == this) {
					setChildIndex(overlay, numChildren - 1);
				} else {
					addChild(overlay);
				}
			}
			
			// Update the navigation map (and draw it)
			if (active && m_boardNodes.changed_since_last_sim) {
				updateCloneChildrenToMatch(true);
			}
			
			if (active) {
				m_gameSystem.navigation_control_panel.updateBoard(this);
				if (navigation_map_board) {
					m_gameSystem.navigation_control_panel.replaceActiveBoardNavigationMap();
				}
			}
		}
		
		private function get lineColor():Number {
			if (trouble_points == null || trouble_points.length == 0) {
				return 0x009900;
			} else
			{
				return 0x990000;
			}
		}
		
		/**
		 * Randomly places tiles of backgrounds such that the offset of the backgrounds is different for every board
		 */
		public function drawTiledBackgrounds():void {
			var level_indx:int = Math.max(0, level.world.levels.indexOf(level));
			if (m_gameSystem.level_background_images[level_indx % m_gameSystem.level_background_images.length] != null) {
				board_background_tiles = new RectangularObject(0, 0, Math.max(original_width, max_pipe_width), Math.max(original_height, max_pipe_height));
				if (is_board_navigation_map) {
					board_background_tiles.scrollRect = new Rectangle(0, 0, Math.max(original_width, max_pipe_width + 2*WIDE_PIPE_WIDTH + 10), Math.max(original_height, max_pipe_height));
				} else {
					if (false) { // user dragging board to scroll code, not quite robust enough yet
						board_background_tiles.buttonMode = true;
						board_background_tiles.addEventListener(MouseEvent.MOUSE_DOWN, tileMouseDown);
						board_background_tiles.addEventListener(MouseEvent.MOUSE_UP, tileMouseUp);
					}
					board_background_tiles.x = -20;
					board_background_tiles.y = -20;
					board_background_tiles.scrollRect = new Rectangle(0, 0, Math.max(original_width, max_pipe_width + 2*WIDE_PIPE_WIDTH + 10), Math.max(original_height, max_pipe_height));
					//board_background_tiles.scrollRect = new Rectangle(0, 0, original_width, original_height);
				}
				var cur_x:Number = Math.floor(-50 - ((original_width - 150) * Math.random()));
				var cur_y:Number = Math.floor(-50 - ((original_height - 150) * Math.random()));
				var orig_y:Number = cur_y;
				var bmpWidth:Number;
				var bmpHeight:Number;
				while (cur_x < Math.max(original_width, max_pipe_width) + 3*WIDE_PIPE_WIDTH) {
					while (cur_y < Math.max(original_height, max_pipe_height) + 3*WIDE_PIPE_WIDTH) {
						var b_bmp:Bitmap = new Bitmap((m_gameSystem.level_background_images[level_indx % m_gameSystem.level_background_images.length] as Bitmap).bitmapData);
						bmpWidth = b_bmp.width;
						bmpHeight = b_bmp.height;
						b_bmp.x = cur_x;
						b_bmp.y = cur_y;
						board_background_tiles.addChild(b_bmp);
						cur_y += bmpHeight - 1;
					}
					cur_x += bmpWidth - 1;
					cur_y = orig_y;
				}
			}
		}
		
		private function tileMouseDown(e:MouseEvent):void {
			if (scrolling_pane.scrollRect != null) {
				var mousePt:Point = new Point(e.localX + scrolling_pane.scrollRect.x + this.x, e.localY + scrolling_pane.scrollRect.y + this.y);
				background_dragging_start_pt = mousePt.clone();
			}
		}
		
		private function tileMouseUp(e:MouseEvent):void {
			background_dragging_start_pt = null;
		}
		
		/**
		 * Redraws any subnetwork boards that appear on this board
		 */
		public function drawSubBoards():void {
			for each (var sb:Board in subnet_boards) {
				sb.draw();
			}
		}
		
		/**
		 * When the board is clicked while inactive, the click_callback is called
		 * @param	e Assocated MouseEvent
		 */
		public function boardClick(e:MouseEvent):void {
			if (m_gameSystem.buzzing) {
				return;
			}
			if (clone_parent == null) {
				click_callback(this);
			} else {
				click_callback(clone_parent);
			}
		}
		
		/**
		 * When the user rolls over this board when inactive, this board is highlighted
		 * @param	e Assocated MouseEvent
		 */
		public function boardRollOver(e:MouseEvent):void {
			if (m_gameSystem.buzzing) {
				return;
			}
			highlight = true;
			draw();
			if ((clone_parent != null) && (e != null)) {
				clone_parent.boardRollOver(null);
			}
			for each (var my_clone_board:Board in clone_children) {
				my_clone_board.boardRollOver(null);
			}
		}
		
		/**
		 * When a user rolls out of the board when inactive, the board is un-highlighted
		 * @param	e Assocated MouseEvent
		 */
		public function boardRollOut(e:MouseEvent):void {
			if (m_gameSystem.buzzing)
				return;
			highlight = false;
			draw();
			if ((clone_parent != null) && (e != null)) {
				clone_parent.boardRollOut(null);
			}
			for each (var my_clone_board:Board in clone_children) {
				my_clone_board.boardRollOut(null);
			}
		}
		
		/**
		 * To make the board appear as active instead of inactive (title goes to bottom and overpane is removed (when the draw method is called)
		 */
		public function activate():void {
			active = true;
			removeStampSelector();
			if(title)
			{
				if (clone_parent != null) {
					var tf2:TextFormat = title.getTextFormat();
					tf2.size = CLONE_FONT_SIZE;
					title.setTextFormat(tf2);
				} else {
					titleFontSize(ACTIVE_FONT_SIZE);
				}
			}
			m_gameSystem.navigation_control_panel.updateBoard(this);
			updateCloneChildrenToMatch(true);
			for each (var my_board:Board in subnet_boards) {
				m_gameSystem.navigation_control_panel.updateBoard(my_board);
			}
			for each (var my_pipe:Pipe in _pipes) {
				my_pipe.activate();
			}
		}
		
		/**
		 * The board is made drawn in a deactive state, title in the center and the overlay is added
		 */
		public function drawDeactivated():void {
			for each (var my_pipe:Pipe in _pipes) {
				my_pipe.playConstantDropAnimations(false);
			}
			draw();
		}
		
		/**
		 * The board is made inactive
		 */
		public function deactivate():void {
			if(stamp_selector)
				removeStampSelector();
			if (clone_parent != null) {
				var tf2:TextFormat = title.getTextFormat();
				tf2.size = CLONE_FONT_SIZE;
				title.setTextFormat(tf2);
			} else {
				titleFontSize(INACTIVE_FONT_SIZE);
			}
			active = false;
			drawDeactivated();
		}
		

		/**
		 * Update any subnetwork boards that are copies of this board to have the same trouble points and red/green border as this board
		 * @param	_navigation_map_only True if only the thumbnail of this board should be updates, not other subnetwork versions of this board
		 */
		public function updateCloneChildrenToMatch(_navigation_map_only:Boolean = false):void {
			for each (var cc:Board in clone_children) {
				if (_navigation_map_only && (!cc.is_board_navigation_map)) {
					continue;
				}
				if (cc.clone_level < 2) {
					cc.reset = reset;
					cc.m_boardNodes.simulated = m_boardNodes.simulated;
					cc.draw();
				}
			}
		}
		
		/**
		 * Changes the font size of the board name
		 * @param	fs Desired font size
		 */
		public function titleFontSize(fs:uint):void {
			var tf:TextFormat = title.getTextFormat();
			tf.size = original_scaleY * fs;
			title.setTextFormat(tf);
		}
		
		/**
		 * Places a subnetwork board on this board (graphically) and associates the two
		 * @param	_b
		 */
		public function appendSubBoard(_b:Board):void {
			subnet_boards.push(_b);
			_b.sub_board_parent = this;
			//draw();
		}
		
		/**
		 * Used for retrieving the next unique pipe id for this board, called every time a new pipe is created for this board
		 * @return
		 */
		public function getNextPipeUniqueId():uint {
			next_pipe_unique_id++;
			return next_pipe_unique_id - 1;
		}
		
		/**
		 * Returns the pipe on this board that matches the desired unique id (if any)
		 * @param	_uid Id of the pipe desired
		 * @return Pipe whose unique Id matches the input _uid
		 */
		public function getPipeByUniqueId(_uid:uint):Pipe {
			for each (var p:Pipe in _pipes) {
				if (p.unique_id == _uid)
					return p;
			}
			return null;
		}
		
		/**
		 * Function to get the incoming Edge object that corresponds to the port desired
		 * @param	_port Desired pipe's input port
		 * @return Edge corresponding to the input _port
		 */
		public function getIncomingEdgeByPort(_port:String):Edge 
		{
			for (var node_id:String in m_boardNodes.nodeDictionary) {
				var n:Node = (m_boardNodes.nodeDictionary[node_id] as Node);
				if (n.kind == NodeTypes.INCOMING) {
					for (var oe_index:uint = 0; oe_index < n.outgoing_ports.length; oe_index++) {
						if (n.outgoing_ports[oe_index].port_id == _port) {
							return n.outgoing_ports[oe_index].edge;
						}
					}
				}
			}
			return null;
		}
		
		/**
		 * Function to get the outgoing Edge object that corresponds to the port desired
		 * @param	_port Desired pipe's output port
		 * @return Edge corresponding to the input _port
		 */
		public function getOutgoingEdgeByPort(_port:String):Edge {
			// TODO: use dictionary/lookup instead, for now just loop over all nodes
			//-//for each (var n:Node in original_board_nodes) {
			for (var node_id:String in m_boardNodes.nodeDictionary) {
				var n:Node = (m_boardNodes.nodeDictionary[node_id] as Node);
				if (n.kind == NodeTypes.OUTGOING) {
					for (var ie_index:uint = 0; ie_index < n.incoming_ports.length; ie_index++) {
						if (n.incoming_ports[ie_index].port_id == _port) {
							return n.incoming_ports[ie_index].edge;
						}
					}
				}
			}
			return null;
		}
		
		public function createStampSelector(_x:Number, _y:Number, _pipe:Pipe):StampSelector {
			if (stamp_selector) {
				if (stamp_selector.parent == stamp_selector_pane) {
					stamp_selector_pane.removeChild(stamp_selector);
				}
			}
			if (_pipe.associated_edge.linked_edge_set.num_stamps == 0) {
				return null;
			}
			stamp_selector = new StampSelector(_x, _y, _pipe);
			stamp_selector_pane.addChild(stamp_selector);
			stamp_selector.openDisplay();
			
			return stamp_selector;
		}
		
		public function removeStampSelector():void {
			if (stamp_selector) {
				if (stamp_selector.parent == stamp_selector_pane) {
					stamp_selector.onClose();
					stamp_selector_pane.removeChild(stamp_selector);
				}
				stamp_selector.onClose();
				
				//cause a resimulation
				PipeJamController.mainController.resimulatePipe(stamp_selector.pipe);
			}
			stamp_selector = null;
		}
		
		/**
		 * Removes any trouble points on this level
		 * @param tp Current list of trouble points (if any) to append to
		 * @return Updated list of all trouble points removed
		 */
		public function removeAllTroublePoints():void {
			if (clone_level > 0) {
				return;
			}

			trouble_point_pane.removeChildren();
			
			trouble_points = new Vector.<TroublePoint>;
		}
		
		/**
		 * Add a circular trouble point to the edge's associated pipe's board at the CENTER of the edge (for pinch point)
		 * @param	radius (Optional) Radius of the new TroublePoint 
		 */
		public function insertCircularTroublePoint(associated_pipe:Pipe, radius:Number = 110):void {
			
			var tp_y_off:Number = 0.0;
			switch (Theme.CURRENT_THEME) {
				case Theme.PIPES_THEME:
					tp_y_off = 0.0;
					break;
				case Theme.TRAFFIC_THEME:
					tp_y_off = -1.5 * Pipe.WIDE_BALL_RADIUS;
					break;
			}
			var my_pt:Point = associated_pipe.getXYbyT(0.5 + tp_y_off / associated_pipe.interpolated_spline_length);
			
			var tp:TroublePoint = new TroublePoint(my_pt.x, my_pt.y, radius, radius, true);
			if (associated_pipe) {
				tp.buttonMode = true;
				associated_pipe.assignCallbacks(tp);
			}
			trouble_points.push(tp);
			trouble_point_pane.addChild(tp);
			
			if (TroublePoint.USE_ANIMATED_VERSIONS) {
				tp.scaleX = 2.0;
				tp.scaleY = 2.0;
			} else {
				tp.scaleX = 0.7;
				tp.scaleY = 0.7;
			}
			tp.x = my_pt.x;
			tp.y = my_pt.y;	
		}
		

		/**
		 * Return the board navigation clone child (thumbnail of this board used for navigation)
		 */
		public function get navigation_map_board():Board {
			for each (var cc:Board in clone_children) {
				if (cc.is_board_navigation_map) {
					return cc;
				}
			}
			return null;
		}
		
		/**
		 * Creates an identical instance of this board, used for creating a subnetwork board of this board to be place inside another board (or as a thumbnail board navigation map)
		 * @param	_width Width of the clone
		 * @param	_height Height of the clone
		 * @param	_clone_level Clone level, 0 for original board, 1 for clone of original board, 2 for clone of a clone, etc
		 * @param	_is_navigation_map True if clone will be a board navigation map (thumbnail of original)
		 * @return Clone that was created
		 */
		public function createClone(_width:int = -1, _height:int = -1, _clone_level:uint = 1, _is_navigation_map:Boolean = false):Board {
			// IMPORTANT! BECAUSE THIS IS DONE BY HAND, ANY NEW/CHANGED/REMOVED PARAMETERS WITHIN BOARD CLASS MUST BE UPDATED HERE AS WELL
			var clone:Board = new Board(original_x, original_y, original_width, original_height, board_name, start_t, level, m_gameSystem, click_callback, this, _clone_level);
			clone.m_boardNodes = m_boardNodes;
			clone.is_board_navigation_map = _is_navigation_map;
			if (_is_navigation_map) {
				navigation_map_clone = clone;
			}
			clone_children.push(clone);
			clone.active = active;
			
			// TODO: unclear whether these need to be copied...
			clone.dropping = dropping;
			clone.reset = reset;
			clone.m_boardNodes.simulated = m_boardNodes.simulated;
			
			if (_width != -1) {
				clone.clone_scaleX = Number(_width) / Number(Math.max(original_width, max_pipe_width));
				clone.original_scaleX = Number(_width) / Number(Math.max(original_width, max_pipe_width));
				clone.scaleX = Number(_width) / Number(Math.max(original_width, max_pipe_width));
			}
			if (_height != -1) {
				clone.clone_scaleY = Number(_height) / Number(Math.max(original_height, max_pipe_height));
				clone.original_scaleY = Number(_height) / Number(Math.max(original_height, max_pipe_height));
				clone.scaleY = Number(_height) / Number(Math.max(original_height, max_pipe_height));
			}
			clone.finishBoard();
		//	clone.draw();
			return clone;
		}
		
		public function gameTimerInterval():void
		{
			for each(var pipe:Pipe in pipes)
			{
				pipe.gameTimerInterval();
			}
			
		}
	}
}

import flash.display.Sprite;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.geom.Point;
import Events.PipeChangeEvent;
import flash.events.MouseEvent;
import VisualWorld.Pipe;
import NetworkGraph.Edge;
import VisualWorld.Board;
import VisualWorld.VerigameSystem;
/**
 * This provides the nubs attached to each incoming/outgoing edge to/from a subnetwork node to adjust the width of the inner pipe (if possible).
 * If _linked_edge is null or its pipe is null or if the pipe and this board are on different levels, the link will be gray and unadjustable.
 */
class SubnetworkPipeLink extends Sprite {
	public static const LINK_HEIGHT:Number = 20.0;
	private var top_x:Number;
	private var top_y:Number;
	private var pipe_attached_to_link:Pipe;
	private var leading_into_subnet:Boolean;
	private var link_width:Number = Pipe.WIDE_PIPE_WIDTH;
	private var linked_edge:Edge;
	private var main_color:Number;
	private var darker_accent_color:Number;
	private var mouse_over:Boolean = false;
	private var highlight_glow_filter:GlowFilter;
	
	public function SubnetworkPipeLink(_pipe_attached_to_link:Pipe, _linked_edge:Edge, _leading_into_subnet:Boolean) {
		pipe_attached_to_link = _pipe_attached_to_link;
		linked_edge = _linked_edge;
		leading_into_subnet = _leading_into_subnet;
		if (leading_into_subnet) {
			var pipe_end_pt:Point = _pipe_attached_to_link.getXYbyT(1.0);
			top_x = pipe_end_pt.x;
			top_y = pipe_end_pt.y;
		} else {
			var pipe_beg_pt:Point = _pipe_attached_to_link.getXYbyT(0.0);
			top_x = pipe_beg_pt.x;
			top_y = pipe_beg_pt.y - LINK_HEIGHT;
		}
		var adjustable:Boolean = true;
		if (_linked_edge == null) {
			adjustable = false;
		} else if (_linked_edge.associated_pipe == null) {
			adjustable = false;
		} else {
			if ((_linked_edge.associated_pipe.board.level != _pipe_attached_to_link.board.level) || (!_linked_edge.associated_pipe.adjustable)) {
				adjustable = false;
			}
			link_width = _linked_edge.associated_pipe.pipe_width;
			_linked_edge.associated_pipe.addEventListener(PipeChangeEvent.PIPE_CHANGE, onSubnetworkPipeLinkChange);
		}
		if (!leading_into_subnet) {
			pipe_attached_to_link.addEventListener(PipeChangeEvent.PIPE_CHANGE, function redraw(e:PipeChangeEvent):void { draw(); } );
		}
		if (adjustable) {
			main_color = _linked_edge.associated_pipe.main_color;
			darker_accent_color = _linked_edge.associated_pipe.darker_accent_color;
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseover);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseout);
		} else {
			main_color = VerigameSystem.UNADJUSTABLE_PIPE_COLOR;
			var r:Number = main_color >> 16 & 0xFF;
			var g:Number = main_color >> 8 & 0xFF;
			var b:Number = main_color & 0xFF;
			darker_accent_color = Math.round(r * 0.75) << 16 ^ Math.round(g * 0.75) << 8 ^ Math.round(b * 0.75);
		}
		highlight_glow_filter = new GlowFilter(0xFFFFFF, 1.0, 10, 10, 3, BitmapFilterQuality.LOW);
		draw();
	}
	
	private function onClick(e:MouseEvent):void {
		linked_edge.associated_pipe.pipeClick(e);
	}
	
	private function onMouseover(e:MouseEvent):void {
		filters = [highlight_glow_filter];
		draw();
	}
	
	private function onMouseout(e:MouseEvent):void {
		filters = [];
	}
	
	private function draw():void {
		graphics.clear();
		// If this is a link coming out of a subnetwork node and the width is different from the connecting pipe, draw a funnel - otherwise draw a straight line
		if (!leading_into_subnet && (link_width != pipe_attached_to_link.pipe_width)) {
			var current_width:Number = link_width;
			for (var dy:Number = 1.0; dy <= LINK_HEIGHT; dy += 1.0) {
				graphics.moveTo(top_x, top_y - 1.0);
				graphics.lineStyle(current_width + 4, darker_accent_color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
				graphics.lineTo(top_x, top_y + dy);
				current_width = (1.0 - dy / LINK_HEIGHT) * link_width + (dy / LINK_HEIGHT) * pipe_attached_to_link.pipe_width;
			}
			current_width = link_width;
			for (var dy1:Number = 1.0; dy1 <= LINK_HEIGHT; dy1 += 1.0) {
				graphics.moveTo(top_x, top_y - 1.0);
				graphics.lineStyle(current_width - 4, main_color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
				graphics.lineTo(top_x, top_y + dy1);
				current_width = (1.0 - dy1 / LINK_HEIGHT) * link_width + (dy1 / LINK_HEIGHT) * pipe_attached_to_link.pipe_width;
			}
		} else {
			graphics.lineStyle(link_width + 4, darker_accent_color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
			graphics.moveTo(top_x, top_y);
			graphics.lineTo(top_x, top_y + LINK_HEIGHT);
			graphics.lineStyle(link_width - 4, main_color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
			graphics.moveTo(top_x, top_y);
			graphics.lineTo(top_x, top_y + LINK_HEIGHT);
		}
	}
	
	private function onSubnetworkPipeLinkChange(e:PipeChangeEvent):void {
		link_width = e.pipe.width;
		draw();
		if (leading_into_subnet) {
			pipe_attached_to_link.updateOutgoingWidths();
			pipe_attached_to_link.draw();
		}
	}
	
}