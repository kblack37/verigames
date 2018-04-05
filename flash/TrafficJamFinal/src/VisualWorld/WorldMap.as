package VisualWorld
{
	import GameScenes.*;
	
	import NetworkGraph.*;
	
	import UserInterface.Components.*;
	
	import Utilities.*;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	public class WorldMap  extends Game
	{
		/** True to draw dependency map as a circle rather than bottom to top */
		protected const DEPENDENCY_MAP_CIRCLE:Boolean = false;

		/** Scale of zoomed in world map */
		protected var WORLD_MAP_MAXIMIZED_SCALE:Number;
		
		/** Scale of zoomed out world map */
		protected var WORLD_MAP_MINIMIZED_SCALE:Number;
		
		/** X coordinate of zoomed out world map */
		protected var WORLD_MAP_MINIMIZED_X:Number;
		
		/** Y coordinate of zoomed out world map */
		protected var WORLD_MAP_MINIMIZED_Y:Number;
		
		/** X coordinate of zoomed in world map */
		protected var WORLD_MAP_MAXIMIZED_X:Number;
		
		/** Y coordinate of zoomed in world map */
		protected var WORLD_MAP_MAXIMIZED_Y:Number;
		
		/** Area on the world map background to draw/insert the level diagrams */
		protected var WORLD_MAP_DRAWING_AREA:Rectangle;
		
		/** Y value of the title of the world map */
		protected var WORLD_MAP_TITLE_Y:Number;
		
		/** All the clickable icons used to select a level */
		public var level_icons:Vector.<LevelIcon>;
		
		/** World map image container (island) */
		public var world_map_background:RectangularObject;
		
		/** Graphical object containing arrows indicating level dependencies */
		protected var world_map_dependencies:Sprite;
		
		/** Text showing the world map as a "World Map" */
		protected var worldmap_title:TextField;
		
		/** Text format for world map title */
		protected var worldmap_title_textFormat:TextFormat;
		
		/** Image used in level icon creation */
		private var level_icon_image:Bitmap;
		
		/** Image used in home icon creation */
		private var home_icon_image:Bitmap;

		/** Button to enlarge the world map */
		protected var world_plus_button:ImageButtonCircle;
		
		/** Button to shrink the world map */
		protected var world_minus_button:ImageButtonCircle;
		
		/** Image of the starting/home location/level for the user */
		protected var castle_image:Bitmap;
		
		/** The icon associated with the start level */
		protected var castle_icon:LevelIcon;
		
		/** Image of current location (level) of the user in the world */
		protected var pawn_image:Bitmap;
		
		
		/** The blank level associated with the start level (castle_icon) */
		public var home_level:Level;
		
		public var m_gameSystem:VerigameSystem;
		
		
		[Embed(source="../../lib/assets/world.png")]
		protected var WorldImageClass:Class;
		protected var world_map_background_img:Bitmap = new WorldImageClass();

		[Embed(source="../../lib/assets/castle.png")]
		protected var CastleImageClass:Class;
		
		[Embed(source="../../lib/assets/pawn.png")]
		protected var PawnImageClass:Class;
		
		[Embed(source="../../lib/assets/plus.png")]
		protected var PlusImageClass:Class;
		protected var plus_img:Bitmap = new PlusImageClass();
		
		[Embed(source="../../lib/assets/minus.png")]
		protected var MinusImageClass:Class;
		protected var minus_img:Bitmap = new MinusImageClass();


		public function WorldMap(gameSystem:VerigameSystem, current_world:World, _x:uint, _y:uint, _width:uint, _height:uint)
		{
			super(_x, _y, _width, _height);
			
			m_gameSystem = gameSystem;

			castle_image = new CastleImageClass();
			castle_image.x = 0;
			castle_image.y = 0;
			castle_image.width = 256;
			castle_image.height = 302;
			castle_image.scaleX = 0.75;
			castle_image.scaleY = 0.75;
			
			pawn_image = new PawnImageClass();
			pawn_image.width = 180;
			pawn_image.height = 270;
			pawn_image.scaleX = 0.5;
			pawn_image.scaleY = 0.5;
			
			var traffic_icon_mc:MovieClip = new Art_LevelSelectIcon2();
			var traffic_icon_sp:Sprite = new Sprite();
			traffic_icon_sp.addChild(traffic_icon_mc);
			var traffic_icon_bd:BitmapData = new BitmapData(traffic_icon_mc.width, traffic_icon_mc.height, true, 0x0);
			traffic_icon_mc.x = 0.5 * traffic_icon_mc.width;
			traffic_icon_mc.y = 0.5 * traffic_icon_mc.height;
			traffic_icon_bd.draw(traffic_icon_sp);
			level_icon_image = new Bitmap(traffic_icon_bd);
			var traffic_home_mc:MovieClip = new Art_LevelSelectIcon1();
			var traffic_home_sp:Sprite = new Sprite(); 
			traffic_home_sp.addChild(traffic_home_mc);
			var traffic_home_bd:BitmapData = new BitmapData(traffic_home_mc.width, traffic_home_mc.height, true, 0x0);
			traffic_home_mc.x = 0.5 * traffic_home_mc.width;
			traffic_home_mc.y = 0.5 * traffic_home_mc.height;
			traffic_home_bd.draw(traffic_home_sp);
			home_icon_image = new Bitmap(traffic_home_bd);
			
			var traffic_world_backg:MovieClip = new Art_LevelSelect();
			WORLD_MAP_MAXIMIZED_SCALE = Math.min(0.95 * width / traffic_world_backg.width, 0.95 *height / traffic_world_backg.height);
			WORLD_MAP_MINIMIZED_SCALE = 120.0 / traffic_world_backg.height;
			world_map_background = new RectangularObject(0, 0, WORLD_MAP_MAXIMIZED_SCALE*traffic_world_backg.width, WORLD_MAP_MAXIMIZED_SCALE*traffic_world_backg.height);
			traffic_world_backg.x = 0.5 * traffic_world_backg.width;
			traffic_world_backg.y = 0.5 * traffic_world_backg.height;
			world_map_background.addChild(traffic_world_backg);
			world_map_background.scaleX = WORLD_MAP_MAXIMIZED_SCALE;
			world_map_background.scaleY = WORLD_MAP_MAXIMIZED_SCALE;
			WORLD_MAP_TITLE_Y = 0;
			worldmap_title_textFormat = new TextFormat(Fonts.FONT_DEFAULT, 55, 0xFFFF00, true, false, false, null, null, TextFormatAlign.CENTER);
			WORLD_MAP_DRAWING_AREA = new Rectangle(0, 0.2 * WORLD_MAP_MAXIMIZED_SCALE * traffic_world_backg.height, WORLD_MAP_MAXIMIZED_SCALE * traffic_world_backg.width, 0.55 * WORLD_MAP_MAXIMIZED_SCALE * traffic_world_backg.height);
			WORLD_MAP_MAXIMIZED_X = 0.5 * (VerigameSystem.GAME_WIDTH - WORLD_MAP_MAXIMIZED_SCALE * traffic_world_backg.width);
			WORLD_MAP_MAXIMIZED_Y = 0.5 * (VerigameSystem.GAME_HEIGHT - WORLD_MAP_MAXIMIZED_SCALE * traffic_world_backg.height);
			WORLD_MAP_MINIMIZED_X = 164;
			WORLD_MAP_MINIMIZED_Y = 7;
			var left_x1:Number = 100;
			var top_y1:Number = 45;
			var right_x1:Number = world_map_background.width - 50;
			var bottom_y1:Number = world_map_background.height - 45;
			world_plus_button = new ImageButtonCircle(right_x1, bottom_y1, 90, plus_img, plus_img, function():void { maximizeWorldMap(function():void { } ); } );
			if (!gameSystem.world_map_maximized) {
				world_map_background.addChild(world_plus_button);
			}
			world_plus_button.x = right_x1;
			world_plus_button.y = bottom_y1;
			world_plus_button.borderWidth = 30.0;
			world_minus_button = new ImageButtonCircle(left_x1, top_y1, 60, minus_img, minus_img, function():void { minimizeWorldMap(function():void { } ); } );
			if (gameSystem.world_map_maximized) {
				world_map_background.addChild(world_minus_button);
			}
			world_minus_button.x = left_x1;
			world_minus_button.y = top_y1;
			world_minus_button.borderWidth = 12.0;

			level_icons = new Vector.<LevelIcon>();
			
			// compute level dependencies
			for (var level_index:uint = 0; level_index < current_world.levels.length; level_index++) {
				for each (var level_board_to_check_subboards:Board in current_world.levels[level_index].boards) {
					for (var my_node_id:String in level_board_to_check_subboards.m_boardNodes.nodeDictionary) {
						var board_node:Node = level_board_to_check_subboards.m_boardNodes.nodeDictionary[my_node_id];
						// TODO: INEFFICIENT: use a dictionary of only subboard nodes
						if (board_node.kind == NodeTypes.SUBBOARD) {
							var board_found:Board = PipeJamController.mainController.getBoardByName(gameSystem.m_gameScene, current_world, (board_node as SubnetworkNode).subboard_name);
							if (board_found) {
								if (board_found.level != level_board_to_check_subboards.level) {
									// a subboard from ANOTHER level was found, update dependecies
									if (level_board_to_check_subboards.level.levels_that_this_level_depends_on.indexOf(board_found.level) == -1) {
										level_board_to_check_subboards.level.levels_that_this_level_depends_on.push(board_found.level);
									}
									if (board_found.level.levels_that_depend_on_this_level.indexOf(level_board_to_check_subboards.level) == -1) {
										board_found.level.levels_that_depend_on_this_level.push(level_board_to_check_subboards.level);
									}
								}
							}
						}
					}
				}
			}
			
			// order levels from least # levels_that_depend_on_this_level to most
			var new_levels_ordered_by_dependency:Vector.<Level> = new Vector.<Level>();
			var old_levels:Vector.<Level> = current_world.levels;
			var least_dependent_index:int = -1;
			var least_number_dependencies:int = int.MAX_VALUE;
			while (old_levels.length > 0) {
				least_number_dependencies = int.MAX_VALUE;
				for (var level_dependency_check_index:uint = 0; level_dependency_check_index < old_levels.length; level_dependency_check_index++) {
					if (old_levels[level_dependency_check_index].levels_that_depend_on_this_level.length < least_number_dependencies) {
						least_number_dependencies = old_levels[level_dependency_check_index].levels_that_depend_on_this_level.length;
						least_dependent_index = level_dependency_check_index;
					}
				}
				new_levels_ordered_by_dependency.push(old_levels[least_dependent_index]);
				old_levels.splice(least_dependent_index, 1);
			}
			
			// Determine ranks for levels, if no dependencies: rank = 0, if depend on level that depends on a level, rank = 2, etc.
			var unranked_levels:Vector.<Level> = new Vector.<Level>();
			var prev_rank_levels:Vector.<Level> = new Vector.<Level>();
			var this_rank_levels:Vector.<Level> = new Vector.<Level>();
			var ranked_levels:Vector.<Level> = new Vector.<Level>();
			var at_least_one_level_promoted:Boolean = false;
			for each (var lev:Level in new_levels_ordered_by_dependency) {
				// while we're here, check whether the level depends on anything (take the first pass or rank determination), if not it is rank=0
				if (lev.levels_that_this_level_depends_on.length > 0) {
					unranked_levels.push(lev);
					at_least_one_level_promoted = true;
				} else {
					lev.rank = 0;
					ranked_levels.push(lev);
					this_rank_levels.push(lev);
				}
			}
			var current_rank:uint = 1; // we just did rank=0 above
			while (at_least_one_level_promoted) {
				at_least_one_level_promoted = false;
				prev_rank_levels = this_rank_levels;
				this_rank_levels = new Vector.<Level>();
				// Check all levels for dependence on the last rank group
				for each (var my_current_level:Level in new_levels_ordered_by_dependency) {
					for each (var level_that_i_depend_on:Level in my_current_level.levels_that_this_level_depends_on) {
						if (prev_rank_levels.indexOf(level_that_i_depend_on) > -1) {
							at_least_one_level_promoted = true;
							my_current_level.rank = current_rank;
							this_rank_levels.push(my_current_level);
							break;
						}
					}
				}
				for each (var my_lev_to_remove:Level in this_rank_levels) {
					if (unranked_levels.indexOf(my_lev_to_remove) > -1) {
						ranked_levels.push(unranked_levels.splice(unranked_levels.indexOf(my_lev_to_remove), 1)[0]);
					}
				}
				current_rank++;
			}
			// Now promote mutually dependent levels to highest rank of the two levels (if level rank 2 is mutually dependent with level rank 4, promote the first to rank 4)
			at_least_one_level_promoted = true;
			while (!at_least_one_level_promoted) {
				at_least_one_level_promoted = false;
				for each (var level_to_check_for_codependence:Level in ranked_levels) {
					for each (var other_level_to_check_for_codependence:Level in level_to_check_for_codependence.levels_that_this_level_depends_on) {
						if (other_level_to_check_for_codependence.levels_that_this_level_depends_on.indexOf(level_to_check_for_codependence) > -1) {
							if (level_to_check_for_codependence.rank > other_level_to_check_for_codependence.rank) {
								other_level_to_check_for_codependence.rank = level_to_check_for_codependence.rank;
								at_least_one_level_promoted = true;
							} else if (level_to_check_for_codependence.rank < other_level_to_check_for_codependence.rank) {
								level_to_check_for_codependence.rank = other_level_to_check_for_codependence.rank;
								at_least_one_level_promoted = true;
							}
						}
					}
				}
			}
			
			// Now cleanup any ranks that may have no levels left in them (and move higher ranks down, if so)
			var levels_in_each_rank:Array = new Array(current_rank);
			var check_rank:uint = 0;
			var done:Boolean = false;
			var highest_rank:uint = 0;
			while (!done) {
				var levels_in_rank:uint = 0;
				for each (var level_to_check_rank:Level in ranked_levels) {
					if (level_to_check_rank.rank == check_rank) {
						level_to_check_rank.rank_index = levels_in_rank;
						levels_in_rank++;
					}
				}
				if (levels_in_rank == 0) {
					var levels_moved:uint = 0;
					for each (var level_to_update_rank:Level in ranked_levels) {
						if (level_to_update_rank.rank > check_rank) {
							level_to_update_rank.rank = level_to_update_rank.rank - 1;
							levels_moved++;
						}
					}
					if (levels_moved == 0) {
						done = true;
					}
				} else {
					levels_in_each_rank[check_rank] = levels_in_rank;
					highest_rank = check_rank;
					check_rank++;
				}
				if (check_rank > current_rank - 1) {
					done = true;
				}
			}
			
			//now figure out which should be unlocked/failed
			for each (var my_lev:Level in ranked_levels) {
				my_lev.unlocked = true;
				for each (var level_that_i_depend_on1:Level in my_lev.levels_that_this_level_depends_on) {
					if (level_that_i_depend_on1.failed ||level_that_i_depend_on1.unlocked == false) {
						my_lev.unlocked = false;
						break;
					}
				}
			}
			current_world.levels = ranked_levels;
			
			while (world_map_background.numChildren > 1) { world_map_background.removeChildAt(1); }
			if (gameSystem.world_map_maximized) {
				if (world_minus_button.parent != world_map_background) {
					world_map_background.addChild(world_minus_button);
				}
			} else {
				if (world_plus_button.parent != world_map_background) {
					world_map_background.addChild(world_plus_button);
				}
			}
			world_map_dependencies = new Sprite();
			world_map_dependencies.x = WORLD_MAP_DRAWING_AREA.x + 0.5 * WORLD_MAP_DRAWING_AREA.width;// 0.47 * world_map_background.width;
			world_map_dependencies.y = WORLD_MAP_DRAWING_AREA.y + 0.5 * WORLD_MAP_DRAWING_AREA.height;//0.5*world_map_background.height;
			world_map_dependencies.graphics.clear();
			world_map_background.addChild(world_map_dependencies);
			
			var x1:Number, y1:Number, x2:Number, y2:Number, angle:Number;
			if (DEPENDENCY_MAP_CIRCLE) {
				// NOTE: THIS CODE NEEDS UPDATING, DRAWING CIRCLE TOO SMALL
				for (var level_index_to_layout:uint = 0; level_index_to_layout < current_world.levels.length; level_index_to_layout++) {
					//var my_level_icon_bmp:Bitmap = new Bitmap(level_icon_image.bitmapData.clone());
					var level_button:LevelIcon = new LevelIcon(0.5 * world_map_background.width + 0.25 * world_map_background.width*Math.sin(2 * Math.PI * level_index_to_layout / current_world.levels.length)
						, 0.5 * world_map_background.height - 0.25 * world_map_background.height * Math.cos(2 * Math.PI * level_index_to_layout / current_world.levels.length), 50
						, current_world.levels[level_index_to_layout], level_icon_image, null, current_world.levels[level_index_to_layout].selectMe );
					world_map_background.addChild(level_button);
					level_icons.push(level_button);
					for (var dep_level_index:uint = 0; dep_level_index < current_world.levels[level_index_to_layout].levels_that_depend_on_this_level.length; dep_level_index++) {
						x1 = 0.5 * world_map_background.width + 0.25 * world_map_background.width * Math.sin(2 * Math.PI * level_index_to_layout / current_world.levels.length);
						y1 = 0.5 * world_map_background.height - 0.25 * world_map_background.height * Math.cos(2 * Math.PI * level_index_to_layout / current_world.levels.length);
						x2 = 0.5 * world_map_background.width + 0.25 * world_map_background.width * Math.sin(2 * Math.PI * current_world.levels.indexOf(current_world.levels[level_index_to_layout].levels_that_depend_on_this_level[dep_level_index]) / current_world.levels.length);
						y2 = 0.5 * world_map_background.height - 0.25 * world_map_background.height * Math.cos(2 * Math.PI * current_world.levels.indexOf(current_world.levels[level_index_to_layout].levels_that_depend_on_this_level[dep_level_index]) / current_world.levels.length);
						angle = Math.atan2(y1 - y2, x1 - x2);
						world_map_dependencies.graphics.moveTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x2, y2);
						world_map_dependencies.graphics.lineTo(x2 + 80.0*Math.cos(angle + Math.PI / 10.0), y2 + 80.0*Math.sin(angle + Math.PI / 10.0));
						world_map_dependencies.graphics.moveTo(x2, y2);
						world_map_dependencies.graphics.lineTo(x2 + 80.0*Math.cos(angle - Math.PI / 10.0), y2 + 80.0*Math.sin(angle - Math.PI / 10.0));
					}
					level_button.draw();
				}
			} else {
				const ICON_RADIUS:Number = 50.0;
				const ICON_X_SPACING:Number = 180.0;
				const ICON_Y_SPACING:Number = 200.0;
				var min_icon_x:Number = Number.POSITIVE_INFINITY;
				var max_icon_x:Number = Number.NEGATIVE_INFINITY;
				var min_icon_y:Number = -0.5 * (highest_rank + 1) * ICON_Y_SPACING;
				var max_icon_y:Number =  0.5 * (highest_rank + 1) * ICON_Y_SPACING;
				var home_x:Number = 0;// 0.5 * world_map_background.width;
				var home_y:Number = max_icon_y;// 0.7 * world_map_background.height;
				//create the home level first
				home_level = new Level(0, 0, VerigameSystem.GAME_WIDTH, VerigameSystem.GAME_HEIGHT, "Start", m_gameSystem, current_world, null);
				home_level.failed = false;
				home_level.unlocked = false;
				
				for (var level_index_to_layout1:uint = 0; level_index_to_layout1 < current_world.levels.length; level_index_to_layout1++) {
					if (levels_in_each_rank[current_world.levels[level_index_to_layout1].rank] == 1) {
						x1 = 0.0;
					} else {
						var min_rank_x:Number = -0.5 * (levels_in_each_rank[current_world.levels[level_index_to_layout1].rank] - 1) * ICON_X_SPACING;
						x1 = min_rank_x + current_world.levels[level_index_to_layout1].rank_index * ICON_X_SPACING;
					}
					y1 = max_icon_y - (current_world.levels[level_index_to_layout1].rank + 1)*ICON_Y_SPACING;
					min_icon_x = Math.min(min_icon_x, x1);
					max_icon_x = Math.max(max_icon_x, x1);
					
					var my_level_icon_bmp1:Bitmap = new Bitmap(level_icon_image.bitmapData.clone());
					var level_button1:LevelIcon = new LevelIcon( x1, y1, ICON_RADIUS, current_world.levels[level_index_to_layout1], my_level_icon_bmp1, null, current_world.levels[level_index_to_layout1].selectMe );
					level_button1.x = x1;
					level_button1.y = y1;
					world_map_dependencies.addChild(level_button1);//world_map_background.addChild(level_button);
					level_icons.push(level_button1);
					
					for (var dep_level_index1:uint = 0; dep_level_index1 < current_world.levels[level_index_to_layout1].levels_that_depend_on_this_level.length; dep_level_index1++) {
						if (levels_in_each_rank[current_world.levels[level_index_to_layout1].levels_that_depend_on_this_level[dep_level_index1].rank] == 1) {
							x2 = 0.0;
						} else {
							var min_rank_x1:Number = -0.5 * (levels_in_each_rank[current_world.levels[level_index_to_layout1].levels_that_depend_on_this_level[dep_level_index1].rank] - 1) * ICON_X_SPACING;
							x2 = min_rank_x1 + current_world.levels[level_index_to_layout1].levels_that_depend_on_this_level[dep_level_index1].rank_index * ICON_X_SPACING;
						}
						y2 = max_icon_y - (current_world.levels[level_index_to_layout1].levels_that_depend_on_this_level[dep_level_index1].rank + 1)*ICON_Y_SPACING;
						
						angle = Math.atan2(y1 - y2, x1 - x2);
						// Draw thicker outline in black
						world_map_dependencies.graphics.lineStyle(24.0, 0x0, 1.0, false, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
						world_map_dependencies.graphics.moveTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x2, y2);
						world_map_dependencies.graphics.lineTo(x2 + 80.0*Math.cos(angle + Math.PI / 10.0), y2 + 80.0*Math.sin(angle + Math.PI / 10.0));
						world_map_dependencies.graphics.moveTo(x2, y2);
						world_map_dependencies.graphics.lineTo(x2 + 80.0 * Math.cos(angle - Math.PI / 10.0), y2 + 80.0 * Math.sin(angle - Math.PI / 10.0));
						// And same points in thinner foreground = white
						world_map_dependencies.graphics.lineStyle(16.0, 0xFFFFFF, 1.0, false, "normal", CapsStyle.ROUND, JointStyle.ROUND, 2);
						world_map_dependencies.graphics.moveTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x2, y2);
						world_map_dependencies.graphics.lineTo(x2 + 80.0*Math.cos(angle + Math.PI / 10.0), y2 + 80.0*Math.sin(angle + Math.PI / 10.0));
						world_map_dependencies.graphics.moveTo(x2, y2);
						world_map_dependencies.graphics.lineTo(x2 + 80.0 * Math.cos(angle - Math.PI / 10.0), y2 + 80.0 * Math.sin(angle - Math.PI / 10.0));
					}
					// Connect to the castle!
					if (current_world.levels[level_index_to_layout].rank == 0) {
						angle = Math.atan2(home_y - y1, home_x - x1);
						// Draw thicker outline in black
						world_map_dependencies.graphics.lineStyle(24.0, 0x0, 1.0, false, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
						world_map_dependencies.graphics.moveTo(home_x, home_y);
						world_map_dependencies.graphics.lineTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x1 + 80.0*Math.cos(angle + Math.PI / 10.0), y1 + 80.0*Math.sin(angle + Math.PI / 10.0));
						world_map_dependencies.graphics.moveTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x1 + 80.0 * Math.cos(angle - Math.PI / 10.0), y1 + 80.0 * Math.sin(angle - Math.PI / 10.0));
						// And same points in thinner foreground = white
						world_map_dependencies.graphics.lineStyle(16.0, 0xFFFFFF, 1.0, false, "normal", CapsStyle.ROUND, JointStyle.ROUND, 2);
						world_map_dependencies.graphics.moveTo(home_x, home_y);
						world_map_dependencies.graphics.lineTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x1 + 80.0*Math.cos(angle + Math.PI / 10.0), y1 + 80.0*Math.sin(angle + Math.PI / 10.0));
						world_map_dependencies.graphics.moveTo(x1, y1);
						world_map_dependencies.graphics.lineTo(x1 + 80.0 * Math.cos(angle - Math.PI / 10.0), y1 + 80.0 * Math.sin(angle - Math.PI / 10.0));
					}
					level_button1.home_level = this.home_level;
					level_button1.draw();
				}
				current_world.levels.push(home_level);

				
				var my_home_icon_bmp:Bitmap = new Bitmap(home_icon_image.bitmapData.clone());
				castle_icon = new LevelIcon( home_x, home_y, 0.5 * castle_image.scaleX * castle_image.width, home_level, my_home_icon_bmp, null, home_level.selectMe);
				castle_icon.m_image.x = -0.5 * castle_icon.m_image.width;
				castle_icon.m_image.y = -0.5 * castle_icon.m_image.height;
				//castle_icon.disable();
				castle_icon.x = home_x;
				castle_icon.y = home_y;
				level_icons.push(castle_icon);
				if (castle_icon.parent != world_map_dependencies) {
					world_map_dependencies.addChild(castle_icon);
				}
				castle_icon.draw();

				var minscale:Number = Math.min(WORLD_MAP_DRAWING_AREA.width / Math.max(1.0, (max_icon_x - min_icon_x)), WORLD_MAP_DRAWING_AREA.height / Math.max(1.0, (max_icon_y - min_icon_y)));
				world_map_dependencies.scaleX = Math.min(1.0, minscale);
				world_map_dependencies.scaleY = Math.min(1.0, minscale);
				worldmap_title = new TextField();
				worldmap_title.embedFonts = true;
				worldmap_title.text = current_world.world_name + " Map";// "World Map";
				worldmap_title.setTextFormat(worldmap_title_textFormat);
				worldmap_title.wordWrap = false;
				worldmap_title.width = WORLD_MAP_DRAWING_AREA.width;
				worldmap_title.x = WORLD_MAP_DRAWING_AREA.x;
				worldmap_title.autoSize = TextFieldAutoSize.CENTER;
				worldmap_title.y = WORLD_MAP_TITLE_Y;
				worldmap_title.selectable = false;
				world_map_background.addChild(worldmap_title);
			}
			pawn_image.x = home_x-40;
			pawn_image.y = home_y-100;
			
			world_map_dependencies.addChild(pawn_image);
		}
			
		/**
		 * Shrinks the world map (Ex: after a level has been selected or the zoom out button is clicked)
		 * @param	callback Function to call after the animation is complete
		 */
		public function minimizeWorldMap(callback:Function):void {
			if (!m_gameSystem.world_map_maximized) {
				callback();
				return;
			}
			if (world_minus_button.parent == world_map_background) {
				world_map_background.removeChild(world_minus_button);
			}
			if (world_plus_button.parent == world_map_background) {
				world_map_background.removeChild(world_plus_button);
			}
			var ani:Animation = new Animation();
			m_gameSystem.world_map_maximized = false;
			ani.translateAndZoom(world_map_background, WORLD_MAP_MINIMIZED_X, WORLD_MAP_MINIMIZED_Y, WORLD_MAP_MINIMIZED_SCALE, WORLD_MAP_MINIMIZED_SCALE, 0.4, function():void { world_map_background.addChild(world_plus_button); callback(); } );
		}
		
		/**
		 * Zooms into the world map as when the zoom (+) button has been clicked
		 * @param	callback Function to call after the animation is complete
		 */
		public function maximizeWorldMap(callback:Function):void {
			if (m_gameSystem.world_map_maximized) {
				callback();
				return;
			}
			if (world_map_background.parent == this) {
				setChildIndex(world_map_background, numChildren - 1);
			}
			if (world_minus_button.parent == world_map_background) {
				world_map_background.removeChild(world_minus_button);
			}
			if (world_plus_button.parent == world_map_background) {
				world_map_background.removeChild(world_plus_button);
			}
			var ani:Animation = new Animation();
			m_gameSystem.world_map_maximized = true;
			ani.translateAndZoom(world_map_background, WORLD_MAP_MAXIMIZED_X, WORLD_MAP_MAXIMIZED_Y, WORLD_MAP_MAXIMIZED_SCALE, WORLD_MAP_MAXIMIZED_SCALE, 0.8, function():void { world_map_background.addChild(world_minus_button); callback(); });
		}
		
		public function animatePawn(new_x:uint, new_y:uint, _auto_board_select:Boolean):void
		{
			if (pawn_image.parent != world_map_dependencies) {
				pawn_image.x = new_x - pawn_image.scaleX*pawn_image.width;
				pawn_image.y = new_y - 1.5*pawn_image.scaleY*pawn_image.height;
				world_map_dependencies.addChild(pawn_image);
				minimizeWorldMap(function ():void { m_gameSystem.selecting_level = false; } );
			} else {
				var ani:Animation = new Animation();
				ani.translateAndDecelerate(pawn_image, new_x - pawn_image.scaleX*pawn_image.width, new_y - 1.5*pawn_image.scaleY*pawn_image.height, 0.5, 
					function ():void { 
						minimizeWorldMap(function ():void { 
							m_gameSystem.selecting_level = false;
							if ((m_gameSystem.current_level.boards.length > 0) && _auto_board_select) {
								if (m_gameSystem.current_level.last_board_visited != null) {
									m_gameSystem.selectBoard(m_gameSystem.current_level.last_board_visited);
								} else {
									m_gameSystem.selectBoard(m_gameSystem.current_level.boards[0]);
								}
							}
						} ); 
					} );
			}
		}
		
	}
}