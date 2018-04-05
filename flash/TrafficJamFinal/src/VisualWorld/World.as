package VisualWorld
{
	import NetworkGraph.*;
	import NetworkGraph.Network;
	
	import System.*;
	
	import UserInterface.*;
	import UserInterface.Components.RectangularObject;
	
	import Utilities.*;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * World that contains levels that each contain boards that each contain pipes
	 */
	public class World extends RectangularObject
	{
		
		/** All the levels in this world */
		public var levels:Vector.<Level> = new Vector.<Level>();
		
		/** Name of this world */
		public var world_name:String;
				
		/** Original XML used for this world */
		public var world_xml:XML;
		
		/** The parent VerigameSystem instance */
		public var m_gameSystem:VerigameSystem;
		
		/** True if at least one level on this board has not succeeded */
		public var failed:Boolean = false;
		
		/** True if all levels on this board have succeeded */
		public var succeeded:Boolean = false;
		
		/** True if this World has been solves and fireworks displayed, setting this will prevent euphoria from being displayed more than once */
		public var world_has_been_solved_before:Boolean = false;
		
		/** Set to true to only include pipes on normal boards in pipeIdDictionary, not pipes that appear on subboard clones */
		public static const ONLY_INCLUDE_ORIGINAL_PIPES_IN_PIPE_ID_DICTIONARY:Boolean = true;
		
		/** Map from board name to board */
		public var worldBoardNameDictionary:Dictionary = new Dictionary();
		
		/**
		 * World that contains levels that each contain boards that each contain pipes
		 * @param	_x X coordinate, this is currently unused
		 * @param	_y Y coordinate, this is currently unused
		 * @param	_width Width, this is currently unused
		 * @param	_height Height, this is currently unused
		 * @param	_name Name of the level
		 * @param	_system The parent VerigameSystem instance
		 */
		public function World(_x:int, _y:int, _width:uint, _height:uint, _name:String, _system:VerigameSystem, _world_xml:XML)
		{
			super(_x, _y, _width, _height);
			world_name = _name;
			name = "World:" + world_name;
			m_gameSystem = _system;
			world_xml = _world_xml;
		}
		
		public function createWorld(worldNodesDictionary:Dictionary, gameArea:RectangularObject):void
		{
			var original_subboard_nodes:Vector.<Node> = new Vector.<Node>();

			var level_index:uint = 0;
			for (var my_level_name:String in worldNodesDictionary) {
				if (worldNodesDictionary[my_level_name] == null) {
					// This is true if there are no edges in the level, skip this level
					VerigameSystem.printDebug("No edges found on level " + my_level_name + " skipping this level and not creating...");
					continue;
				}
				var my_levelNodes:LevelNodes = (worldNodesDictionary[my_level_name] as LevelNodes);
				VerigameSystem.printDebug("Creating level: " + my_level_name);
				
				var my_level:Level = new Level(0, 0, width, height, my_level_name, m_gameSystem, this, my_levelNodes);
				levels.push(my_level);
				
				my_level.createLevel(original_subboard_nodes, gameArea);
				level_index++;
			}
			//This has to happen after we read in all the nodes and created all the levels (and the boards that we need to clone...)
			createSubnetClonedBoards(original_subboard_nodes);

			
			// finally, finish all boards
			for (var my_level_index:uint = 0; my_level_index < levels.length; my_level_index++) {
				var level_to_finish:Level = levels[my_level_index];
				level_to_finish.finishLevel();
			}				

		}
		
		public function findLevel(index:uint):Level
		{
			for (var my_level_index:uint = 0; my_level_index < levels.length; my_level_index++) {
				var level:Level = levels[my_level_index];
				if(level.levelNodes.metadata["index"] == index)
					return level;
			}	
			
			return null;
		}
		
		public function createSubnetClonedBoards(original_subboard_nodes:Vector.<Node>):void
		{
			// Now take the step of actually creating the board clones and adding them to the appropriate boards and update subboard ids for each pipe
			for (var i:int = 0; i < original_subboard_nodes.length; i++) {
				var original_node:Node = original_subboard_nodes[i];
				var my_board_to_be_cloned:Board = PipeJamController.mainController.getBoardByName(m_gameSystem.m_gameScene, this, (original_node as SubnetworkNode).subboard_name);
				if (my_board_to_be_cloned == null) {
					throw new Error("Subnetwork board not found (not defined in XML): " + original_node.metadata.data.name + " aborting...");
				}
				var my_subnet_clone:Board = my_board_to_be_cloned.createClone(VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * Math.max(original_node.incoming_ports.length, original_node.outgoing_ports.length), VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE + 2*Pipe.WIDE_BALL_RADIUS + 10);
				my_subnet_clone.x =VerigameSystem. PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * original_node.x;
				my_subnet_clone.original_x = VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * (original_node.x - 0.5);
				my_subnet_clone.y = VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * original_node.y;
				my_subnet_clone.original_y = VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * original_node.y - Pipe.WIDE_BALL_RADIUS - 5;
				my_subnet_clone.deactivate();
				original_node.node_board.appendSubBoard(my_subnet_clone);
				(original_node as SubnetworkNode).associated_board = my_subnet_clone;
				for each (var in_port1:Port in original_node.incoming_ports) {
					(in_port1 as SubnetworkPort).linked_subnetwork_edge = my_board_to_be_cloned.getIncomingEdgeByPort(in_port1.port_id);
					if ((in_port1 as SubnetworkPort).linked_subnetwork_edge == null) {
						throw new Error("Corresponding edge for Subnetwork port not found: Node " + original_node.node_id + " Input Port " + in_port1.port_id + " aborting...");
					}
					if ((in_port1 as SubnetworkPort).linked_subnetwork_edge.associated_pipe == null) {
						throw new Error("Corresponding pipe for Subnetwork port not found: Node " + original_node.node_id + " Input Port " + in_port1.port_id + " aborting...");
					}
				}
				for each (var out_port:Port in original_node.outgoing_ports) {
					(out_port as SubnetworkPort).linked_subnetwork_edge = my_board_to_be_cloned.getOutgoingEdgeByPort(out_port.port_id);
					if ((out_port as SubnetworkPort).linked_subnetwork_edge == null) {
						throw new Error("Corresponding edge for Subnetwork port not found: Node " + original_node.node_id + " Output Port " + out_port.port_id + " aborting...");
					}
					if ((out_port as SubnetworkPort).linked_subnetwork_edge.associated_pipe == null) {
						throw new Error("Corresponding pipe for Subnetwork port not found: Node " + original_node.node_id + " Output Port " + out_port.port_id + " aborting...");
					}
				}
			}
		}
		
		/**
		 * To be used if a graphical representation of the Level is implemented
		 */
		public function draw():void {
			
		}
		
		/**
		 * If all the levels in this world have succeeded then lots of fireworks are displayed
		 * @param	_simulation True if this was called from a simulation, false if from dropping balls
		 */
		public function checkWorldForSuccess(_simulation:Boolean):void {
			var at_least_one_level_not_succeeded:Boolean = false;
			for each (var my_level:Level in levels) {
				if (my_level.failed) {
					at_least_one_level_not_succeeded = true;
				}
			}
			if (!at_least_one_level_not_succeeded) {
				if (_simulation && Level.DROP_WHEN_SUCCEEDED) {
					return;
				} else {
					succeeded = true;
					outputXmlToJavascript();
					if (!world_has_been_solved_before) {
						m_gameSystem.worldCompleteEuphoria();
					}
					world_has_been_solved_before = true;
				}
			} else {
				succeeded = false;
			}
			//system.draw();
		}
		
		public function outputXmlToJavascript(_quit:Boolean = false):void {
			var output_xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE world SYSTEM \"world.dtd\">\n" + String(getUpdatedXML());
			if (ExternalInterface.available) {
				var reply:String = ExternalInterface.call("receiveUpdatedXML", output_xml, _quit);
			}
		}
		
		public function getUpdatedXML():XML {
			// TODO: Save level_index in each Level class instance to avoid unnecessary loops that this code uses
			var output_xml:XML = new XML(world_xml);
			for each (var my_level:Level in levels) {
				// Find this level in XML
				if (my_level.levelNodes == null) {
					continue;
				}
				var my_level_xml_indx:int = -1;
				for (var level_indx:uint = 0; level_indx < output_xml["level"].length(); level_indx++) {
					if (output_xml["level"][level_indx].attribute("name").toString() == my_level.levelNodes.original_level_name) {
						my_level_xml_indx = level_indx;
						break;
					}
				}
				if (my_level_xml_indx > -1) {
					//for each (var my_board:Board in my_level.boards) {
						// Loop over boards, edges
						for (var board_index:uint = 0; board_index < output_xml["level"][my_level_xml_indx]["boards"][0]["board"].length(); board_index++) {
							for (var edge_index:uint = 0; edge_index < output_xml["level"][my_level_xml_indx]["boards"][0]["board"][board_index]["edge"].length(); edge_index++) {
								var my_edge_id:String = output_xml["level"][my_level_xml_indx]["boards"][0]["board"][board_index]["edge"][edge_index].attribute("id").toString();
								var my_pipe:Pipe = my_level.pipeIdDictionary[my_edge_id];
								if (my_pipe) {
									var my_width:String = "narrow";
									if (my_pipe.is_wide) {
										my_width = "wide";
									}
									if (my_pipe.has_buzzsaw) {
										var debug:int = 0;
									}
									output_xml["level"][my_level_xml_indx]["boards"][0]["board"][board_index]["edge"][edge_index].@width = my_width;
									output_xml["level"][my_level_xml_indx]["boards"][0]["board"][board_index]["edge"][edge_index].@buzzsaw = my_pipe.has_buzzsaw.toString();
									
								} else {
									throw new Error("World.getUpdatedXML(): Edge pipe not found for edge id: " + my_edge_id);
								}
							}
						}
				} else {
					throw new Error("World.getUpdatedXML(): Level not found: " + my_level.level_name);
				}
				//Update the xml with the stamp state information. Currently updating all stamp states, changed or not.
				var numEdgeSets:uint = output_xml["level"][my_level_xml_indx]["linked-edges"][0]["edge-set"].length();
				for(var edgeSetIndex:uint = 0; edgeSetIndex<numEdgeSets; edgeSetIndex++) {
					
					var edgeID:String = output_xml["level"][my_level_xml_indx]["linked-edges"][0]["edge-set"][edgeSetIndex].attribute("id").toString();
					var pipeVector:Vector.<Pipe> = my_level.pipeEdgeSetDictionary[edgeID];
					for each (var currentPipe:Pipe in pipeVector) {
					var linkedEdgeSet:EdgeSetRef =  currentPipe.associated_edge.linked_edge_set;
						var stampLength:uint = linkedEdgeSet.num_stamps;
						for(var stampIndex:uint = 0; stampIndex < stampLength; stampIndex++) {
							var stampID:String = output_xml["level"][my_level_xml_indx]["linked-edges"][0]["edge-set"][edgeSetIndex]["stamp"][stampIndex].@id;
							output_xml["level"][my_level_xml_indx]["linked-edges"][0]["edge-set"][edgeSetIndex]["stamp"][stampIndex].@active
																	= linkedEdgeSet.hasActiveStampOfEdgeSetId(stampID).toString();
						}
					}
				}

			}	
			return output_xml;
		}
		
		public function updateLinkedPipes(p:Pipe, isWide:Boolean):void
		{
			for each (var level:Level in levels)
			{
				level.updateLinkedPipes(p, isWide);
			}
		}
		
		public function restartCars():void
		{
			
		}
		
		public function pauseCars():void
		{
			
		}
		
		public function simulateAllLevels():Vector.<BoardNodes>
		{
			var boards_to_update:Vector.<BoardNodes> = new Vector.<BoardNodes>;
			PipeJamController.mainController.simulator = new Simulator(this);
			
			for (var level_index1:uint = 0; level_index1 < levels.length; level_index1++) {
				if(levels[level_index1].levelNodes != null) //will for home level
				{
					var new_boards_to_update:Vector.<BoardNodes> = PipeJamController.mainController.simulator.updateOnPipeClickFlowSens("", levels[level_index1].levelNodes.boardNodesDictionary);
				
					for each(var board:BoardNodes in new_boards_to_update)
					if(boards_to_update.indexOf(board) == -1)
						boards_to_update.push(board);
				}
			}
			
			return boards_to_update;
		}
		
		public function simulateLinkedPipes(mainPipe:Pipe, simulator:Simulator):Vector.<BoardNodes> {
			var boards_to_update:Vector.<BoardNodes> = new Vector.<BoardNodes>;
			if (simulator != null) {
				//var levels_to_update:Vector.<Level> = board.system.simulator.updateOnPipeClick(edge_set_index);
				//board.system.simulatorUpdateTroublePoints(levels_to_update);
				var boards_affected:Dictionary = new Dictionary;
				boards_affected[mainPipe.board.m_boardNodes.board_name] = mainPipe.board.m_boardNodes;
				// Add any boards where this board appears as a subnetwork, they need to be re-checked
				for each (var subnet_clone:Board in mainPipe.board.clone_children) {
					if (subnet_clone.sub_board_parent) {
						if (subnet_clone.sub_board_parent.clone_level == 0) {
							if (boards_affected[subnet_clone.sub_board_parent.name] == null) {
								boards_affected[subnet_clone.sub_board_parent.name] = subnet_clone.sub_board_parent.m_boardNodes;
							}
						}
					}
				}
				boards_to_update = simulator.updateOnPipeClickFlowSens(mainPipe.edge_set_id, boards_affected);
			}
			return boards_to_update;
		}
		
		public function simulatorUpdateTroublePointsFS(simulator:Simulator, nodes_to_traverse:Vector.<BoardNodes> = null):void {
			if (simulator == null) {
				return;
			}
			
			var boards_to_redraw:Vector.<Board> = new Vector.<Board>;
			var levels_to_redraw:Vector.<Level> = new Vector.<Level>;
			
			//Gather all interesting boards
			var boards_to_traverse:Vector.<Board> = new Vector.<Board>;
			// Defaults to traversing all levels
			if (nodes_to_traverse == null) {
				boards_to_traverse = new Vector.<BoardNodes>();
				for each (var lev:Level in levels) {
					for each (var my_board:Board in lev.boards) {
						boards_to_traverse.push(my_board.m_boardNodes);
					}
				}
			}
			else
			{
				for each(var boardNode:BoardNodes in nodes_to_traverse)
				{
					boards_to_traverse.push(worldBoardNameDictionary[boardNode.board_name]);
				}
			}
			
			var tpCount:uint = updateTroublePoints(simulator, boards_to_traverse);
					
			var boards_to_check_for_success:Vector.<Board> = new Vector.<Board>();
			for each (var sim_board1:Board in boards_to_traverse) {
				sim_board1.level.failed = false;
			}
			for each (var sim_board:Board in boards_to_traverse) {
					if (tpCount > 0) {
						// If we haven't already failed this board, fail it and any other boards that it appears on
						if (sim_board.trouble_points.length != 0) {
							// If not already failed, fail this board's level
							if (!sim_board.level.failed) {
								sim_board.level.failed = true;
								if(levels_to_redraw.indexOf(sim_board.level) != -1)
									levels_to_redraw.push(sim_board.level); 
							}
							// Queue up any un-failed boards that this board appears on to be failed
							var queue:Vector.<Board> = new Vector.<Board>();
							for each (var my_board1:Board in sim_board.clone_children) {
								if (my_board1.trouble_points == null || my_board1.trouble_points.length == 0) {
									if (my_board1.sub_board_parent) {
										if (my_board1.sub_board_parent.clone_level == 0) {
											if (queue.indexOf(my_board1.sub_board_parent) == -1) {
												queue.push(my_board1.sub_board_parent);
											}
										}
									}
								}
							}
							//var boards_checked:Vector.<Board> = new Vector.<Board>();
							while (queue.length > 0) {
								var board_to_fail:Board = queue.shift();
								//boards_checked.push(board_to_fail);
								if(boards_to_redraw.indexOf(board_to_fail) == -1)
									boards_to_redraw.push(board_to_fail);
								board_to_fail.updateCloneChildrenToMatch();
								if (!board_to_fail.level.failed) {
									board_to_fail.level.failed = true;
									if(levels_to_redraw.indexOf(board_to_fail.level) == -1)
										levels_to_redraw.push(board_to_fail.level); 
								}
								// Queue up any boards that THIS board appears on (this shouldn't be subject to infinite loops)
								for each (var new_fail_board:Board in board_to_fail.clone_children) {
									if (new_fail_board.sub_board_parent) {
										if (new_fail_board.sub_board_parent.clone_level == 0) {
											if (new_fail_board.sub_board_parent.trouble_points.length == 0) {
												if ((new_fail_board != board_to_fail) && queue.indexOf(new_fail_board.sub_board_parent) == -1) {
													queue.push(new_fail_board.sub_board_parent);
												}
											}
										}
									}
								}
							}
							if(boards_to_redraw.indexOf(sim_board) == -1)
								boards_to_redraw.push(sim_board); 
							sim_board.updateCloneChildrenToMatch();
						}
					} else {
						// If no trouble points and hasn't been marked by failed by previous board, mark as succeeded for now and check any sub boards in the next loop
						if (boards_to_check_for_success.indexOf(sim_board) == -1) {
							boards_to_check_for_success.push(sim_board);
						}
					}
				if (sim_board.trouble_points.length == 0) {
					// If no trouble points and hasn't been marked by failed by previous board, mark as succeeded for now and check any sub boards in the next loop
					if (boards_to_check_for_success.indexOf(sim_board) == -1) {
						boards_to_check_for_success.push(sim_board);
					}
				}
			}
			
			// Now traverse updated boards to see if they were subsequently failed, if not mark as succeeded and check levels
			var levels_to_check_for_success:Vector.<Level> = new Vector.<Level>();
			for each (var my_success_board:Board in boards_to_check_for_success) {
				if (my_success_board.trouble_points.length == 0) {
					my_success_board.updateCloneChildrenToMatch();
					if (levels_to_check_for_success.indexOf(my_success_board.level) == -1) {
						levels_to_check_for_success.push(my_success_board.level);
						if(boards_to_redraw.indexOf(my_success_board) == -1)
							boards_to_redraw.push(my_success_board); 
					}
				}
			}
			// Now traverse levels with at least one newly succeeded board to check for success
			for each (var my_success_level:Level in levels_to_check_for_success) {
				my_success_level.checkLevelForSuccess(true);
			}
			m_gameSystem.checkForCelebration();
	//		m_gameSystem.draw(); just drew in checkLevelForSuccess above
			for each(var level:Level in levels_to_redraw)
				level.draw();
			for each(var board:Board in boards_to_redraw)
			{
				board.draw();
				m_gameSystem.navigation_control_panel.updateBoard(board);
			}
			m_gameSystem.navigation_control_panel.initializeBoardNavigationBar();
		}
		
		public function updateTroublePoints(simulator:Simulator, boards_to_traverse:Vector.<Board> = null):uint
		{	
			var tpCount:uint = 0;
			for each (var sim_board:Board in boards_to_traverse) 
			{
				//clean the board
				sim_board.removeAllTroublePoints();
				
				// Get new trouble points from simulator
				var trouble_pointsContainers:Dictionary = simulator.getAllTroublePointsByBoardName(sim_board.board_name);
				
				if (trouble_pointsContainers) {
					for each (var port:Port in trouble_pointsContainers["port"]) {
						tpCount++;
						sim_board.insertCircularTroublePoint(port.edge.associated_pipe);
						// Mark failed = succeeded = false to force pipe to recompute this during the draw() call
						port.edge.associated_pipe.failed = false;
						port.edge.associated_pipe.draw();
						// Mark the board failed = succeeded = false to force pipe to recompute this after all trouble points dealt with
					}
					for each (var edge:Edge in trouble_pointsContainers["edge"]) {
						tpCount++;
						sim_board.insertCircularTroublePoint(edge.associated_pipe);
						// Mark failed = succeeded = false to force pipe to recompute this during the draw() call
						edge.associated_pipe.failed = false;
						edge.associated_pipe.draw();
						// Mark the board failed = succeeded = false to force pipe to recompute this after all trouble points dealt with
					}
					
				}
			}
			return tpCount;
		}
	}
}