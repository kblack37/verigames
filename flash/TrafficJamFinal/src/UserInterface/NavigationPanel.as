package UserInterface
{
	import UserInterface.Components.RectangularObject;
	
	import VisualWorld.*;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	public class NavigationPanel extends RectangularObject
	{
		/** composed of upper navigation bar area, lower navigation panel area, and rightmost navigation_map_area. */
		private var board_navigation_bar_area:RectangularObject;
		private var navigation_content_area:RectangularObject;
		private var navigation_map_area:RectangularObject;
		
		/** The thumbnail of the active board used to scroll around */
		public var navigation_map_board:Board = null;
		
		/** The drawing area for the current board navigation map */
		public var navigation_map_drawing_area:RectangularObject;
		
		/** If a board navigation map, this rectangle indicates the currently viewed area of the board (yellow rectangle) */
		public var board_navigation_scroll_rect_indication:RectangularObject;

		
		/** Horizontal sprite indicating all boards for this level and their status (reg/green) allowing user to click to visit any board */
		private var board_navigation_bar:RectangularObject;
		
		/** Portion of the board_navigation_bar that highlights which boards are shown below (parentheses-looking bookends and lighter portion) */
		private var board_navigation_bar_viewable_area:Sprite = new Sprite();
		
		private var board_navigation_bar_square_board_icons:Sprite = new Sprite();
		
		/** Clickable area associated with board_navigation_bar */
		protected var board_navigation_bar_click_area:RectangularObject;
		
		/** Maximum width of the board_navigation_bar */
		protected const BOARD_NAV_MAX_BOARD_WIDTH:Number = 30.0;
		
		/** Maximum spacing of the board_navigation_bar so levels with 2, 3 board aren't spread far far apart */
		protected const BOARD_NAV_MAX_BOARD_SPACING:Number = 30.0;
		
		/** Minimum number of pixels that a single board icon can be on the board_navigation_bar */
		protected const BOARD_NAV_MIN_BOARD_WIDTH:Number = 2.0;
		
		/** Minimum spacing of the board_navigation_bar so levels with many board aren't on top of one another */
		protected const BOARD_NAV_MIN_BOARD_SPACING:Number = 1.0;
		
		/** Width of the entire area used to display boards, used to calculate viewable area marker */
		private static var BOARD_NAV_UI_WIDTH:Number;
		
		/** Number of board thumbnails that are visible at a given time used to calculate viewable area marker */
		private static var BOARD_NAV_VISIBLE_BOARDS:uint;
		
		//the pane holds all the nav boards, the window is the current view port onto the pane
		protected var boardDisplayScrollPane:RectangularObject;
		protected var boardDisplayScrollPaneWindow:RectangularObject;
		protected var boardDisplayScrollPaneOverlay:RectangularObject;
		
		//spacing between nav boards
		protected var NAV_BOARD_SPACING:uint = 15;
		
		//amount to scroll
		protected var NAV_BOARD_SCROLL_AMOUNT:uint;
		
		/** Current width of the board_navigation_bar */
		protected var board_nav_width:Number;
		
		/** Current X coordinate of theboard_navigation_bar*/
		protected var board_nav_x:Number;
		
		/** Current width of each of the boards on the board_navigation_bar */
		protected var board_nav_board_width:Number;
		
		/** Current spacing of the boards on the board_navigation_bar */
		protected var board_nav_board_spacing:Number;
		
		/** Button to scroll left to other inactive boards */		
		private var left_side_scroll_simplebutton:SimpleButton;
		/** Button to scroll right to other inactive boards */
		private var right_side_scroll_simplebutton:SimpleButton;
		
		/** Ideal width of the thumbnail copy of the board used to scroll around */
		static public var NAVIGATION_BOARD_WIDTH:uint;
		
		/** Ideal height of the thumbnail copy of the board used to scroll around */
		static public var NAVIGATION_BOARD_HEIGHT:uint;
		
		/** The scaleX to use for any non-zoomed-in (inactive) boards */
		public static var INACTIVE_BOARD_SCALEX:Number = 0.15;
		
		/** The scaleY to use for any non-zoomed-in (inactive) boards */
		public static var INACTIVE_BOARD_SCALEY:Number = 0.15;
						
		protected var m_gameSystem:VerigameSystem;
		
		protected var m_initialized:Boolean = false;

		protected var m_boardCount:uint = 0;
		
		protected var clicking:Boolean = false;
		
		public function NavigationPanel(_x:int, _y:int, _width:uint, _height:uint, gameSystem:VerigameSystem)
		{
			super(_x, _y, _width, _height);
			
			m_gameSystem = gameSystem;
		}
		
		public function init():void
		{
		
			BOARD_NAV_VISIBLE_BOARDS = 4;
			
			var navigationBorder:uint = 10; //10 pixel border around map
			NAVIGATION_BOARD_WIDTH = INACTIVE_BOARD_SCALEX * width;
			NAVIGATION_BOARD_HEIGHT = INACTIVE_BOARD_SCALEX * width;
			var navigationBoardContainerX:uint = width - NAVIGATION_BOARD_WIDTH - 2*navigationBorder; 

			board_navigation_bar_area = new RectangularObject(0, 0, navigationBoardContainerX, 30);
			navigation_content_area = new RectangularObject(0, board_navigation_bar_area.height, navigationBoardContainerX, height - board_navigation_bar_area.height);
			navigation_map_area = new RectangularObject(navigationBoardContainerX, height - NAVIGATION_BOARD_HEIGHT - 2*navigationBorder, 
																				width - navigationBoardContainerX, NAVIGATION_BOARD_HEIGHT+2*navigationBorder);
			BOARD_NAV_UI_WIDTH = navigationBoardContainerX;
			board_navigation_bar = new RectangularObject(20, 0, board_navigation_bar_area.width, board_navigation_bar_area.height - 15);
			board_navigation_bar_area.addChild(board_navigation_bar);
			board_navigation_bar.name = "board_navigation_bar";
			board_navigation_bar_area.addChild(board_navigation_bar);
						
			left_side_scroll_simplebutton = new Art_ArrowLeft();
			left_side_scroll_simplebutton.addEventListener(MouseEvent.CLICK, clickScrollRight);
			left_side_scroll_simplebutton.x = 0.5*left_side_scroll_simplebutton.width;
			left_side_scroll_simplebutton.y = navigation_content_area.height/2;
			left_side_scroll_simplebutton.name = "board_scroll_left_simplebutton";
			right_side_scroll_simplebutton = new Art_ArrowRight();
			right_side_scroll_simplebutton.addEventListener(MouseEvent.CLICK, clickScrollLeft);
			right_side_scroll_simplebutton.x = BOARD_NAV_UI_WIDTH - 15 - 0.5*right_side_scroll_simplebutton.width;
			right_side_scroll_simplebutton.y = navigation_content_area.height/2;
			right_side_scroll_simplebutton.name = "board_scroll_right_simplebutton";
						
			boardDisplayScrollPaneWindow = new RectangularObject(0,10,BOARD_NAV_UI_WIDTH-15, height);
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0);
			mask.graphics.drawRect(0, 0, boardDisplayScrollPaneWindow.width, boardDisplayScrollPaneWindow.height);
			mask.graphics.endFill();
			boardDisplayScrollPaneWindow.mask = mask;
			boardDisplayScrollPaneWindow.addChild(mask);
			navigation_content_area.addChild(boardDisplayScrollPaneWindow);	
			
			navigation_map_area.graphics.lineStyle(10, 0x545B91, 1);
			navigation_map_area.graphics.beginFill(0x22253B, 1);
			navigation_map_area.graphics.drawRoundRect(-10, -10, navigation_map_area.width + 20, navigation_map_area.height + 50, 10, 10);
			navigation_map_area.graphics.endFill();
			navigation_map_drawing_area = new RectangularObject(15, 15,navigation_map_area.width - 30, navigation_map_area.height - 30);
			
			//set full size and resize later as needed
			board_navigation_scroll_rect_indication = new RectangularObject( -10, -10, navigation_map_drawing_area.width+20, navigation_map_drawing_area.height+20);
			var nav_glow:GlowFilter = new GlowFilter(0xFFFF00, 1.0, 6, 6, 6);
			board_navigation_scroll_rect_indication.filters = [nav_glow];
			navigation_map_drawing_area.addChild(board_navigation_scroll_rect_indication);
			navigation_map_area.addChild(navigation_map_drawing_area);
			
			
			m_initialized = true;
		}
		
		
		public function isInitialized():Boolean
		{
			return m_initialized;
		}
		
		public function update():void
		{
			if(boardDisplayScrollPane)
			{
				//level calls parent.removeChild on each board, so we don't need to, but remove other stuff
				boardDisplayScrollPane.removeChildren();
				boardDisplayScrollPane.removeEventListener(MouseEvent.CLICK, onBoardDisplayClick);
				boardDisplayScrollPaneWindow.removeChild(boardDisplayScrollPane);
			}

			if(m_gameSystem.current_level.boards.length > 0)
			{
				//update board, get spacing, then add to panel
				boardDisplayScrollPane = new RectangularObject(0,0,m_gameSystem.current_level.boards.length*NAV_BOARD_SCROLL_AMOUNT, height);
				boardDisplayScrollPaneOverlay = new RectangularObject(0,0,m_gameSystem.current_level.boards.length*NAV_BOARD_SCROLL_AMOUNT, height);
				boardDisplayScrollPaneOverlay.addEventListener(MouseEvent.CLICK, onBoardDisplayClick);
				m_boardCount = 0;	
				for each (var board:Board in m_gameSystem.current_level.boards)
				{
					updateBoard(board);
				}
				NAV_BOARD_SCROLL_AMOUNT = m_gameSystem.current_level.boards[0].board_static_view.width+NAV_BOARD_SPACING;
				
				//reset both width and height
				boardDisplayScrollPaneOverlay.width = 0;
				boardDisplayScrollPaneOverlay.height = boardDisplayScrollPane.height;
				for each (var board1:Board in m_gameSystem.current_level.boards)
				{
					addBoardToPanel(board1);
				}
				boardDisplayScrollPaneWindow.addChild(boardDisplayScrollPane);
				initializeBoardNavigationBar();
				updateNavigationMapArea();
				checkToRemoveScrollButtons();
				drawNavBarViewableArea();

				boardDisplayScrollPane.addChild(boardDisplayScrollPaneOverlay);
				boardDisplayScrollPaneOverlay.graphics.beginFill(0x000000, 0.0);
				boardDisplayScrollPaneOverlay.graphics.drawRect(0,0,boardDisplayScrollPaneOverlay.width, boardDisplayScrollPaneOverlay.height);
				boardDisplayScrollPaneOverlay.graphics.endFill();
			}
		}
		
		protected function onBoardDisplayClick(e:MouseEvent):void
		{
			//find the right index, and then select that board
			var globalPt:Point = e.currentTarget.localToGlobal(new Point(e.localX, e.localY));
			var localPt:Point = boardDisplayScrollPane.globalToLocal(globalPt);
			var index:uint = Math.floor(e.localX/NAV_BOARD_SCROLL_AMOUNT);
			selectBoard(index);
		}
		
		protected function onNavBarClick(e:MouseEvent):void
		{
			//find the right index, and then select that board
			var globalPt:Point = e.target.localToGlobal(new Point(e.localX, e.localY));
			var localPt:Point = board_navigation_bar_square_board_icons.globalToLocal(globalPt);
			var index:uint = Math.floor((localPt.x - (board_nav_x+0.5*board_nav_board_spacing))/(board_nav_board_spacing+board_nav_board_width));
			selectBoard(index);
			
			//scroll pane to center selection (if possible), and that will update visible nav bar selection
			var maxScrollPosition:int = -((m_gameSystem.current_level.boards.length - 4)*NAV_BOARD_SCROLL_AMOUNT);

			var new_x:int = Math.max(maxScrollPosition,-(index-3)*NAV_BOARD_SCROLL_AMOUNT);
			if(new_x > 0)
				new_x = 0;
			
			TweenLite.to(boardDisplayScrollPane, VerigameSystem.BOARD_TRANSITION_TIME/2, { x:new_x,  onComplete:scrollEnded} );
		}
		
		
		protected function selectBoard(index:uint):void
		{
			var lastActiveBoard:Board = m_gameSystem.active_board;
			
			m_gameSystem.selectBoard(m_gameSystem.current_level.boards[index]);
			
			if(m_gameSystem.active_board)
			{
				//draw nav bar selected rect
				for (var bint:int = 0; bint < m_gameSystem.current_level.boards.length; bint++) {
					var my_alpha:Number = 1.0;
					if ( (m_gameSystem.current_level.boards[bint].original_x <= 0.025*width) || (m_gameSystem.current_level.boards[bint].original_x >= BOARD_NAV_UI_WIDTH - INACTIVE_BOARD_SCALEX*width - 0.025*width) ) {
						my_alpha = 0.6;
					}
					
					//erase current border, since white selection border is wider than regular
					board_navigation_bar_square_board_icons.graphics.lineStyle(2.0, 0x26A9E0, 1.0);
					board_navigation_bar_square_board_icons.graphics.drawRect(board_nav_x + bint*board_nav_board_width + (bint + 1)*board_nav_board_spacing, 0, board_nav_board_width, board_navigation_bar.height);

					if (m_gameSystem.active_board == m_gameSystem.current_level.boards[bint]) 
					{
						board_navigation_bar_square_board_icons.graphics.lineStyle(2.0, 0xFFFFFF, 1.0);
					}
					else
					{
						board_navigation_bar_square_board_icons.graphics.lineStyle(1.0, 0x005500, my_alpha);
						board_navigation_bar_square_board_icons.graphics.beginFill(0x00FF00, my_alpha);
					} 
					board_navigation_bar_square_board_icons.graphics.drawRect(board_nav_x + bint*board_nav_board_width + (bint + 1)*board_nav_board_spacing, 0, board_nav_board_width, board_navigation_bar.height);
					board_navigation_bar_square_board_icons.graphics.endFill();
				}
				
				var boardIndex:int = m_gameSystem.current_level.boards.indexOf(m_gameSystem.active_board);
				addBoardToPanel(m_gameSystem.active_board, boardIndex);
				
				if(lastActiveBoard)
				{
					boardIndex =  m_gameSystem.current_level.boards.indexOf(lastActiveBoard);
					addBoardToPanel(lastActiveBoard, boardIndex);
				}
			}
		}
		
		public function updateBoard(board:Board):void
		{
			if(m_initialized)
				board.drawBoardImages();
		}
		
		protected function addBoardToPanel(board:Board, boardIndex:int = -1):void
		{
			if(boardIndex < 0)
				boardIndex = m_boardCount;
			
			if(board.active)
			{
				board.board_static_view.x = (boardIndex*NAV_BOARD_SCROLL_AMOUNT) + NAV_BOARD_SPACING;
				boardDisplayScrollPane.addChild(board.board_static_view);
			}
			else
			{
				board.deactivate();
				board.x = (boardIndex*NAV_BOARD_SCROLL_AMOUNT) + NAV_BOARD_SPACING;
				board.y = 0;
				board.scaleX = board.board_static_view.width/board.width;
				board.scaleY = board.board_static_view.height/board.height;
				board.draw();
				boardDisplayScrollPane.addChild(board);
			}
			
			//make sure this remains on top and the right width (increase width to max needed)
			if(boardDisplayScrollPaneOverlay.width < ((boardIndex+1)*NAV_BOARD_SCROLL_AMOUNT) + NAV_BOARD_SPACING)
				boardDisplayScrollPaneOverlay.width = ((boardIndex+1)*NAV_BOARD_SCROLL_AMOUNT) + NAV_BOARD_SPACING;
			if(boardDisplayScrollPaneOverlay.parent == boardDisplayScrollPane)
				boardDisplayScrollPane.removeChild(boardDisplayScrollPaneOverlay);
			boardDisplayScrollPane.addChild(boardDisplayScrollPaneOverlay);
			
			m_boardCount++;
		}
		
		/**
		 * Called when the left side scroll button is clicked to scroll right to see more boards
		 * @param	e Associated mouseEvent
		 */
		public function clickScrollRight(e:MouseEvent):void {
			var new_x:Number = boardDisplayScrollPane.x + NAV_BOARD_SCROLL_AMOUNT*4;
			
			if(new_x>0)
				new_x=0;
				
			TweenLite.to(boardDisplayScrollPane, VerigameSystem.BOARD_TRANSITION_TIME, { x:new_x,  onComplete:scrollEnded} );
		}
		
		/**
		 * Called when the right side scroll button is clicked to scroll left to see more boards
		 * @param	e Associated mouseEvent
		 */
		public function clickScrollLeft(e:MouseEvent):void {
			var new_x:Number = boardDisplayScrollPane.x - NAV_BOARD_SCROLL_AMOUNT*4;
			
			if(new_x+boardDisplayScrollPane.width<boardDisplayScrollPaneWindow.width)
				new_x=boardDisplayScrollPaneWindow.width-boardDisplayScrollPane.width;
			
			if(new_x>0)
				new_x=0;
			
			TweenLite.to(boardDisplayScrollPane, VerigameSystem.BOARD_TRANSITION_TIME, { x:new_x, onComplete:scrollEnded} );
			

		}
		
		//called after scrolling ends, so accessories can be updated
		protected function scrollEnded():void
		{
			checkToRemoveScrollButtons();
			drawNavBarViewableArea();	
		}
		
		/**
		 * Called after a scroll to determine whether there are more boards to the left/right and removes appropriate scroll buttons if not
		 */
		public function checkToRemoveScrollButtons():void {
			
			if(!m_initialized)
				return;
			
			var boards_to_the_left:Boolean = false;
			var boards_to_the_right:Boolean = false;
			if (boardDisplayScrollPane.x < 0)
				boards_to_the_left = true;
			if (boardDisplayScrollPane.x+boardDisplayScrollPane.width > boardDisplayScrollPaneWindow.width)
				boards_to_the_right = true;
			
			if(left_side_scroll_simplebutton.parent)
				left_side_scroll_simplebutton.parent.removeChild(left_side_scroll_simplebutton);
			if(right_side_scroll_simplebutton.parent)
				right_side_scroll_simplebutton.parent.removeChild(right_side_scroll_simplebutton);
			if (boards_to_the_left)
				boardDisplayScrollPaneWindow.addChild(left_side_scroll_simplebutton);
			if (boards_to_the_right)
				boardDisplayScrollPaneWindow.addChild(right_side_scroll_simplebutton);
		}
		
		/**
		 * Creates the horizontal bar used to view the status of all boards
		 */
		public function initializeBoardNavigationBar():void {
			if (m_gameSystem.current_level == null) {
				return;
			}
			if (m_gameSystem.current_level.boards.length*BOARD_NAV_MAX_BOARD_WIDTH + (m_gameSystem.current_level.boards.length + 1)*BOARD_NAV_MAX_BOARD_SPACING < board_navigation_bar.width) {
				// in this case, the nav bar needs to be scaled down and centered
				board_nav_width = m_gameSystem.current_level.boards.length*BOARD_NAV_MAX_BOARD_WIDTH + (m_gameSystem.current_level.boards.length + 1)*BOARD_NAV_MAX_BOARD_SPACING;
				board_nav_x = 0.5*(board_navigation_bar.width - board_nav_width);
				board_nav_board_width = BOARD_NAV_MAX_BOARD_WIDTH;
				board_nav_board_spacing = BOARD_NAV_MAX_BOARD_SPACING;
			} else {
				// in this case the nav bar will stretch the whole width - 100 and icons
				board_nav_width = board_navigation_bar.width;
				board_nav_x = 0.0;
				board_nav_board_width = Math.max( BOARD_NAV_MIN_BOARD_WIDTH, board_nav_width / (2*m_gameSystem.current_level.boards.length + 1) );
				board_nav_board_spacing = Math.max( BOARD_NAV_MIN_BOARD_SPACING, board_nav_width / (2*m_gameSystem.current_level.boards.length + 1) );
			}
			
			board_navigation_bar.graphics.clear();
			board_navigation_bar.graphics.lineStyle(4.0, 0x96CDCD, 0.4);
			//board_navigation_bar.graphics.beginFill(0x5F9F9F, 0.4);
			board_navigation_bar.graphics.beginFill(0x26A9E0, 1.0);
			board_navigation_bar.graphics.drawRoundRect(board_nav_x, -5, board_nav_width, board_navigation_bar.height + 10, 6, 6);
			board_navigation_bar.graphics.endFill();
			
			if (m_gameSystem.current_level.boards.length == 0) {
				return;
			}
			
			
			board_navigation_bar_square_board_icons.x = board_navigation_bar.x;
			board_navigation_bar_square_board_icons.y = board_navigation_bar.y;
			
			board_navigation_bar_click_area = new RectangularObject(board_navigation_bar_square_board_icons.x, 
																		board_navigation_bar_square_board_icons.y,
																		board_navigation_bar_square_board_icons.width, 
																		board_navigation_bar_square_board_icons.height);
			board_navigation_bar_click_area.graphics.clear();
			board_navigation_bar_click_area.graphics.lineStyle(0.0, 0x0, 0.0);
			board_navigation_bar_click_area.graphics.beginFill(0x0, 0.0);
			board_navigation_bar_click_area.graphics.drawRoundRect(board_navigation_bar.x, board_navigation_bar.y - 5, board_nav_width, board_navigation_bar.height + 10, 6, 6);
			board_navigation_bar_click_area.graphics.endFill();
			board_navigation_bar_click_area.buttonMode = true;

			
			board_navigation_bar_square_board_icons.graphics.clear();
			
			for (var bint:int = 0; bint < m_gameSystem.current_level.boards.length; bint++) {
				var my_alpha:Number = 1.0;
				if ( (m_gameSystem.current_level.boards[bint].original_x <= 0.025*width) || (m_gameSystem.current_level.boards[bint].original_x >= BOARD_NAV_UI_WIDTH - INACTIVE_BOARD_SCALEX*width - 0.025*width) ) {
					my_alpha = 0.6;
				}
				
				if (m_gameSystem.current_level.boards[bint].trouble_points.length == 0) {
					board_navigation_bar_square_board_icons.graphics.lineStyle(1.0, 0x005500, my_alpha);
					board_navigation_bar_square_board_icons.graphics.beginFill(0x00FF00, my_alpha);
				} else {
					board_navigation_bar_square_board_icons.graphics.lineStyle(1.0, 0x550000, my_alpha);
					board_navigation_bar_square_board_icons.graphics.beginFill(0xFF0000, my_alpha);
				}
				if (m_gameSystem.active_board != null) {
					if (m_gameSystem.active_board == m_gameSystem.current_level.boards[bint]) {
						board_navigation_bar_square_board_icons.graphics.lineStyle(2.0, 0xFFFFFF, 1.0);
					}
				}
				board_navigation_bar_square_board_icons.graphics.drawRect(board_nav_x + bint*board_nav_board_width + (bint + 1)*board_nav_board_spacing, 0, board_nav_board_width, board_navigation_bar.height);
				board_navigation_bar_square_board_icons.graphics.endFill();
			}
			board_navigation_bar_area.addEventListener(MouseEvent.CLICK, onNavBarClick);
			board_navigation_bar_square_board_icons.addChild(board_navigation_bar_viewable_area);
			
			board_navigation_bar_area.addChild(board_navigation_bar_square_board_icons);
			board_navigation_bar_area.addChild(board_navigation_bar_click_area);
		}
		
		private function drawNavBarViewableArea():void {

			board_navigation_bar_viewable_area.graphics.clear();
			
			
			if (m_gameSystem.current_level.boards.length == 0) {
				return;
			}
			
			var visible_board_area_begin_x:Number;
			var visible_board_area_end_x:Number;
			
			var currentScrollCount:Number = Math.ceil(-boardDisplayScrollPane.x/NAV_BOARD_SCROLL_AMOUNT);
			//start, plus half of spacing, + number of boards*width+spacing
			visible_board_area_begin_x = board_nav_x+0.5*board_nav_board_spacing+currentScrollCount*(board_nav_board_spacing+board_nav_board_width);
			visible_board_area_end_x = visible_board_area_begin_x + (board_nav_board_spacing+board_nav_board_width)*BOARD_NAV_VISIBLE_BOARDS;

			board_navigation_bar_viewable_area.x = 0;
			board_navigation_bar_viewable_area.y = 0;
			
			board_navigation_bar_viewable_area.graphics.lineStyle(0.0, 0x0, 0.0);
			board_navigation_bar_viewable_area.graphics.beginFill(0xFFFFFF, 0.3);
			board_navigation_bar_viewable_area.graphics.moveTo(visible_board_area_begin_x, -5);
			board_navigation_bar_viewable_area.graphics.lineTo(visible_board_area_end_x, -5);
			board_navigation_bar_viewable_area.graphics.curveTo(visible_board_area_end_x + 10, 0.5*board_navigation_bar.height, visible_board_area_end_x, board_navigation_bar.height + 5);
			board_navigation_bar_viewable_area.graphics.lineTo(visible_board_area_begin_x, board_navigation_bar.height + 5);
			board_navigation_bar_viewable_area.graphics.curveTo(visible_board_area_begin_x - 10, 0.5*board_navigation_bar.height, visible_board_area_begin_x, -5);
			board_navigation_bar_viewable_area.graphics.endFill();
			
			board_navigation_bar_viewable_area.graphics.lineStyle(4.0, 0x003F87, 1.0);
			board_navigation_bar_viewable_area.graphics.moveTo(visible_board_area_begin_x, -15);
			board_navigation_bar_viewable_area.graphics.curveTo(visible_board_area_begin_x - 10, 0.5*board_navigation_bar.height, visible_board_area_begin_x, board_navigation_bar.height + 15);
			board_navigation_bar_viewable_area.graphics.moveTo(visible_board_area_end_x, -15);
			board_navigation_bar_viewable_area.graphics.curveTo(visible_board_area_end_x + 10, 0.5*board_navigation_bar.height, visible_board_area_end_x, board_navigation_bar.height + 15);
		}
		
		/**
		 * When the nav bar is clicked, this determines which board icon is closest, and visits that board
		 * @param	e Associated mouseEvent
		 */
		private function clickBoardNavigationBar(e:MouseEvent):void {
			//trace("clicked: " + e.localX + "px / " + board_navigation_bar_click_area.width + "px");
			// Find which board is nearest to the place that was clicked
			// Remember, each board's center is at X = 0.5*board_nav_board_width + BOARD_INDEX*board_nav_board_width + (BOARD_INDEX + 1)*board_nav_board_spacing
			var board_clicked_index:int = Math.max(0, Math.min(m_gameSystem.current_level.boards.length - 1, int( Math.round( ((e.localX - board_navigation_bar.x - board_nav_board_spacing - 0.5*board_nav_board_width) / (board_nav_board_width + board_nav_board_spacing))) ) ));
			if (m_gameSystem.current_level.boards.length > 5) {
				// If there are more boards than fit on the bottom, adjust the view area and board locations as needed
				var current_x:Number = m_gameSystem.current_level.boards[board_clicked_index].original_x;
				var view_index:Number = 2;
				if (board_clicked_index < 2) {
					view_index = board_clicked_index;
				} else if (m_gameSystem.current_level.boards.length - board_clicked_index < 3) {
					view_index = 5 - (m_gameSystem.current_level.boards.length - board_clicked_index);
				}
				
				var new_board_clicked_x:Number = (view_index + 0.5) * (INACTIVE_BOARD_SCALEX * width + 0.025 * width);
				if (Math.abs(new_board_clicked_x - current_x) > 5.0) {
					var new_dx:Number = new_board_clicked_x - current_x;
					for (var my_b:uint = 0; my_b < m_gameSystem.current_level.boards.length; my_b++) {
						if ((!m_gameSystem.current_level.boards[my_b].active) && (my_b != board_clicked_index)) {
							var to_x:Number = m_gameSystem.current_level.boards[my_b].x + new_dx;
							TweenLite.to(m_gameSystem.current_level.boards[my_b], VerigameSystem.BOARD_TRANSITION_TIME, { x:to_x } );
							//m_gameSystem.current_level.boards[my_b].x += new_dx;
						}
						m_gameSystem.current_level.boards[my_b].original_x += new_dx;
					}
				}
			}
			checkToRemoveScrollButtons();
		}
		
		public function replaceActiveBoardNavigationMap():void
		{
			if (navigation_map_board && navigation_map_board.parent != null) {
				navigation_map_board.overlay.removeEventListener(MouseEvent.MOUSE_UP, boardNavigationMapRollOut);
				navigation_map_board.parent.removeChild(navigation_map_board);
			}

			navigation_map_board = m_gameSystem.active_board.navigation_map_board;
			navigation_map_board.drawBoardView(true);
			
			if(navigation_map_board.scaleX*navigation_map_board.width > navigation_map_drawing_area.width)
			{
				navigation_map_board.scaleX = navigation_map_drawing_area.width/navigation_map_board.width;
			}
			
			if(navigation_map_board.scaleY*navigation_map_board.height > navigation_map_drawing_area.height)
			{
				navigation_map_board.scaleY = navigation_map_drawing_area.height/navigation_map_board.height;
			}
			
			navigation_map_drawing_area.addChildAt(navigation_map_board, 0);
			var overlay:Sprite = navigation_map_board.overlay;
			overlay.removeEventListener(MouseEvent.CLICK, navigation_map_board.boardClick );
			overlay.removeEventListener(MouseEvent.ROLL_OVER, navigation_map_board.boardRollOver);
			overlay.removeEventListener(MouseEvent.ROLL_OUT, navigation_map_board.boardRollOut);
			overlay.addEventListener(MouseEvent.MOUSE_DOWN, boardNavigationMapClick);
			overlay.addEventListener(MouseEvent.MOUSE_UP, boardNavigationMapRollOut);
			updateNavigationMapArea();
		}
		
		public function draw():void
		{
			if(!m_initialized || (m_gameSystem.current_level == null))
				return;
			
			if (navigation_content_area)
			{
				if (navigation_content_area.parent == this) {
					removeChild(navigation_content_area);
				}
				addChild(navigation_content_area);
			}
			
			if (navigation_map_area)
			{
				if (navigation_map_area.parent == this) {
					removeChild(navigation_map_area);
				}
				addChild(navigation_map_area);
			}
			
			if(board_navigation_bar_area)
			{
				if (board_navigation_bar_area.parent == this) {
					removeChild(board_navigation_bar_area);
				}
				addChild(board_navigation_bar_area);
			}	
		}
		
		protected function updateNavigationMapArea():void
		{
			if(m_gameSystem.active_board)
			{
				navigation_map_board = m_gameSystem.active_board.navigation_map_board;
				
				//height of shown game is proportional to width scale
				var gameBoardHeight:int = Math.max(navigation_map_board.height, navigation_map_board.max_pipe_height)*navigation_map_board.clone_parent.scaleY;
				var indicatorHeightPercent:Number = m_gameSystem.game_panel.m_gameSurface.height/gameBoardHeight;
				board_navigation_scroll_rect_indication.width = navigation_map_drawing_area.width;
				board_navigation_scroll_rect_indication.height = navigation_map_drawing_area.height*indicatorHeightPercent;
				
				board_navigation_scroll_rect_indication.x = board_navigation_scroll_rect_indication.y = 0;
				board_navigation_scroll_rect_indication.graphics.clear();
				board_navigation_scroll_rect_indication.graphics.lineStyle(5.0, 0xFFFF00, 1.0);
				board_navigation_scroll_rect_indication.graphics.drawRoundRect(-10, -10, board_navigation_scroll_rect_indication.width+20, board_navigation_scroll_rect_indication.height+20,5,5);
				board_navigation_scroll_rect_indication.graphics.endFill();
				
				//make sure indicator and overlay are on top
				if (navigation_map_drawing_area)
				{
					if (board_navigation_scroll_rect_indication.parent == navigation_map_drawing_area)
						navigation_map_drawing_area.removeChild(board_navigation_scroll_rect_indication);
						
					navigation_map_drawing_area.addChild(board_navigation_scroll_rect_indication);
				}
			}
		}
		
		/**
		 * Called when the user clicks on this board (if this board is a board navigation map)
		 * @param	e Assocated MouseEvent
		 */
		public function boardNavigationMapClick(e:MouseEvent):void {
			navigation_map_board.overlay.addEventListener(MouseEvent.MOUSE_MOVE, boardNavigationMapRollOver);
			if (navigation_map_board.clone_parent == null) {
				VerigameSystem.printWarning("WARNING: boardNavigationMapClick() called despite the board having no clone_parent...");
				return;
			}
			//clone_parent scroll rect gets these coordinates
			shiftBoardViewAndMapIndicator(e.localX, e.localY);
		}
		
		public function set boardScrollX(_x:Number):void {
			shiftBoardViewAndMapIndicator(_x, navigation_map_board.scroll_rect.y);
		}
		
		public function get boardScrollX():Number {
			return navigation_map_board.scroll_rect.x;
		}
		
		public function set boardScrollY(_y:Number):void {
			shiftBoardViewAndMapIndicator(navigation_map_board.scroll_rect.x + 0.5*navigation_map_board.width + 40, _y);
		}
		
		public function get boardScrollY():Number {
			return navigation_map_board.scroll_rect.y;
		}
		
		/**
		 * Changes the section of the actual board being viewed, this is only called if this board is a board navigation map
		 * @param	_x New board X coordinate to view
		 * @param	_y New board Y coordinate to view
		 */
		public function shiftBoardViewAndMapIndicator(_x:Number, _y:Number):void {
			navigation_map_board.clone_parent.scroll_rect = new Rectangle(Math.max(0, Math.min(Math.max(width, navigation_map_board.max_pipe_width + 2*navigation_map_board.WIDE_PIPE_WIDTH + 10) - navigation_map_board.clone_parent.width,
																					_x - 0.5*navigation_map_board.clone_parent.width)) - 40,
																		Math.max(0, Math.min(Math.max(height, navigation_map_board.max_pipe_height) - navigation_map_board.clone_parent.height, 
																					_y - 0.5*navigation_map_board.clone_parent.height)) - 40,
																		navigation_map_board.clone_parent.width + 40,
																		navigation_map_board.clone_parent.height + 40);
			
			navigation_map_board.clone_parent.scrolling_pane.scrollRect = navigation_map_board.clone_parent.scroll_rect;

			var globalPt:Point = navigation_map_board.overlay.localToGlobal(new Point(_x, _y));
			var localPt:Point = navigation_map_drawing_area.globalToLocal(globalPt);
			
			if(localPt.x + board_navigation_scroll_rect_indication.width > navigation_map_drawing_area.width)
				localPt.x = navigation_map_drawing_area.width - board_navigation_scroll_rect_indication.width;

			if(localPt.y + board_navigation_scroll_rect_indication.height > navigation_map_drawing_area.height)
				localPt.y = navigation_map_drawing_area.height - board_navigation_scroll_rect_indication.height;
			board_navigation_scroll_rect_indication.x = localPt.x;
			board_navigation_scroll_rect_indication.y = localPt.y;
			if (board_navigation_scroll_rect_indication.parent == this) {
				removeChild(board_navigation_scroll_rect_indication);
			}
			navigation_map_drawing_area.addChild(board_navigation_scroll_rect_indication);
			if (navigation_map_board.overlay.parent != this) {
				navigation_map_board.addChild(navigation_map_board.overlay);
			} else {
				navigation_map_board.setChildIndex(navigation_map_board.overlay, numChildren - 1);
			}
			clicking = true;
		}
		
		/**
		 * Changes the section of THIS board being viewed, and updates the board_navigation_clone as needed to match.
		 * @param	_x New board X coordinate to view
		 * @param	_y New board Y coordinate to view
		 */
		public function scrollThisBoardTo(_x:Number, _y:Number):void {
			//trace("scroll to : " + _x + ", " + _y);
			navigation_map_board.clone_parent.scroll_rect = new Rectangle(Math.max(0, Math.min(Math.max(width, navigation_map_board.max_pipe_width + 2*navigation_map_board.WIDE_PIPE_WIDTH) - width + 0, _x - 0.5*width)) - 40, Math.max(0, Math.min(Math.max(height, navigation_map_board.max_pipe_height) - height, _y - 0.5*height)) - 40, width + 40, height + 40);
			navigation_map_board.clone_parent.scrolling_pane.scrollRect = navigation_map_board.clone_parent.scroll_rect;
			if (navigation_map_board) {
				board_navigation_scroll_rect_indication.x = navigation_map_board.clone_parent.scroll_rect.x + 40;
				board_navigation_scroll_rect_indication.y = navigation_map_board.clone_parent.scroll_rect.y + 40;
				if (board_navigation_scroll_rect_indication.parent == navigation_map_board) {
					navigation_map_board.removeChild(board_navigation_scroll_rect_indication);
				}
				navigation_map_board.addChild(board_navigation_scroll_rect_indication);
				if (navigation_map_board.overlay.parent == navigation_map_board) {
					navigation_map_board.removeChild(navigation_map_board.overlay);
				}
				navigation_map_board.addChild(navigation_map_board.overlay);
			}
		}
		
		/**
		 * Called when user mouses over this board if this board is a navigation map, and moves the focus of the board if the user is click-dragging
		 * @param	e Assocated MouseEvent
		 */
		public function boardNavigationMapRollOver(e:MouseEvent):void {
			if (clicking) {
				//system.printDebug("ROLLOVER (clicking = true)");
				shiftBoardViewAndMapIndicator(e.localX, e.localY);
			} else {
				navigation_map_board.overlay.removeEventListener(MouseEvent.MOUSE_MOVE, boardNavigationMapRollOver);
				//system.printDebug("ROLLOVER (clicking = false)");
			}
		}
		
		/**
		 * Called when user mouses out of this board if this board is a navigation map
		 * @param	e Assocated MouseEvent
		 */
		public function boardNavigationMapRollOut(e:MouseEvent):void {
			//system.printDebug("ROLLOUT OR MOUSE_UP");
			// Decision: allow user to mouseout (by accident) and still scroll
			navigation_map_board.overlay.removeEventListener(MouseEvent.MOUSE_MOVE, boardNavigationMapRollOver);
			clicking = false;
		}
	}
}