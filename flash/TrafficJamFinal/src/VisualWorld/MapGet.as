package VisualWorld 
{
	import Events.PipeChangeEvent;
	import Events.StampChangeEvent;
		
	import GameScenes.TrafficJamSceneController;	
	import NetworkGraph.*;	
	import State.*;
	import System.*;
	import GameScenes.*;
	import flash.utils.Dictionary;
	
	import Utilities.Geometry;
	import Utilities.XMath;
	import Utilities.XSprite;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.greensock.motionPaths.LinePath2D;
	import com.greensock.motionPaths.PathFollower;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import NetworkGraph.MapGetNode;
	
	public class MapGet extends Sprite 
	{
		private var large_ball_start_pt:Point;
		private var board:Board;
		private var large_ball:DropObjectBase;
		private var animating_ball:DropObjectBase;
		private var animating:Boolean = false;
		private var node:MapGetNode;
		private var m_width:Number;
		private var m_height:Number;
		private var true_spline_pts:Array; // Array of Points for ball to follow
		private var false_spline_pts:Array; // Array of Points for ball to follow
		private var true_pipe_pane:Sprite = new Sprite();
		private var false_pipe_pane:Sprite = new Sprite();
		private var arg_pipe_pane:Sprite = new Sprite();
		private var star_goal_icon:MovieClip;
		private var mouse_over:Boolean = false;
		private var false_mask:Sprite = new Sprite();
		private var true_mask:Sprite = new Sprite();
		
		public function MapGet(_x:Number, _y:Number, _width:Number, _height:Number, _node:MapGetNode, _board:Board) 
		{
			
			node = _node;

			large_ball = new Ball(node.valueEdge);
			animating_ball = new Ball(node.valueEdge);
			
			x = _x;
			y = _y;
			name = "MapGet";
			m_width = _width;
			m_height = _height;
			board = _board;
			init();
			draw();
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onClick);
			
			if (node.valueEdge.associated_pipe) {
				node.valueEdge.associated_pipe.addEventListener(PipeChangeEvent.PIPE_CHANGE, onValuePipeWidthChange);
			} else {
				VerigameSystem.printWarning("WARNING! MapGet object created before 'value' edge's Pipe was created, node id: " + node.node_id);
			}
			
			if (node.argumentEdge.associated_pipe) {
				node.argumentEdge.associated_pipe.addEventListener(PipeChangeEvent.PIPE_CHANGE, onArgumentPipeWidthChange);
			} else {
				VerigameSystem.printWarning("WARNING! MapGet object created before 'argument' edge's Pipe was created, node id: " + node.node_id);
			}
			
			node.argumentEdge.linked_edge_set.addEventListener(StampChangeEvent.STAMP_ACTIVATION, onArgumentStampChange);
			
			if (node.outgoing_ports[0].edge.associated_pipe) {
				node.outgoing_ports[0].edge.associated_pipe.addEventListener(PipeChangeEvent.PIPE_CHANGE, onOutgoingPipeWidthChange);
			} else {
				VerigameSystem.printWarning("WARNING! MapGet object created before outgoing edge's Pipe was created, node id: " + node.node_id);
			}
			
		}
		
		private static var ARGUMENT_X:Number = 280.0;
		private static var VALUE_X:Number = 200.0;
		private static var KEY_X:Number = 120.0;
		private function init():void {
			graphics.clear();
			graphics.lineStyle(4.0, node.mapEdge.associated_pipe.darker_accent_color);
			graphics.beginFill(node.mapEdge.associated_pipe.main_color);
			graphics.drawRect(0, 0, m_width, m_height);
			star_goal_icon = new Art_StarGoal();
			XSprite.applyColorTransform(star_goal_icon.Star, node.mapEdge.associated_pipe.main_color);
			XSprite.applyColorTransform(star_goal_icon.Circle, node.argumentEdge.associated_pipe.main_color);
			star_goal_icon.x = ARGUMENT_X;
			star_goal_icon.y = 0.5 * m_height;
			
			// Draw the "false" case (no stamps on the argument pipe match the color of the map pipe) where a null literal (LARGE_BALL) is output
			false_pipe_pane.graphics.clear();
			
			false_spline_pts = Geometry.splineToLineSegments(KEY_X, 0.5 * (m_height - 20.0), KEY_X + 0.3 * (VALUE_X - KEY_X), 0.55 * (m_height - 20.0), KEY_X + 0.6 * (VALUE_X - KEY_X), 0.55 * (m_height - 20.0), VALUE_X, (m_height - 20.0), 1.5);
			var false_pipe_drawing_pts:Array = new Array();
			for (var indx:int = 0; indx < false_spline_pts.length; indx++) {
				false_pipe_drawing_pts.push(new Array(false_spline_pts[indx].x, false_spline_pts[indx].y, 1.0));
			}
			false_pipe_drawing_pts.push(new Array(VALUE_X, m_height, 1.0)); 
			
			// Draw top, this is stolen from Pipe.finishPipe() but should probably be a static method call
			var p1:Point = false_spline_pts[0].clone();
			var p2:Point = false_spline_pts[1].clone();
			var dx:Number = (p1.x - p2.x) / XMath.getDist(p1, p2);
			var dy:Number = (p1.y - p2.y) / XMath.getDist(p1, p2);
			var top_p0:Point = new Point(	p1.x + dx * (4 + Pipe.BALL_START_HEIGHT - 0.5*Pipe.WIDE_BALL_RADIUS),
				p1.y + dy * (4 + Pipe.BALL_START_HEIGHT - 0.5*Pipe.WIDE_BALL_RADIUS) );
			var top_p1:Point = new Point(	p1.x + dx * (Pipe.BALL_START_HEIGHT - 0.5*Pipe.WIDE_BALL_RADIUS),
				p1.y + dy * (Pipe.BALL_START_HEIGHT - 0.5*Pipe.WIDE_BALL_RADIUS) );
			var top_p2:Point = new Point(	p1.x + dx * 4, p1.y + dy * 4 );
			
			large_ball_start_pt = new Point(	p1.x + dx * (4 + Pipe.BALL_START_HEIGHT + 1.0*Pipe.WIDE_BALL_RADIUS),
				p1.y + dy * (4 + Pipe.BALL_START_HEIGHT + 1.0*Pipe.WIDE_BALL_RADIUS) );
			large_ball.graphics.clear();
			large_ball.x = large_ball_start_pt.x;
			large_ball.y = large_ball_start_pt.y;
			Ball.drawBall(true, large_ball);
			false_spline_pts.unshift(large_ball_start_pt.clone()); // Add ball starting location as first point
			false_spline_pts.push(new Point(VALUE_X, m_height + 0.5*Pipe.WIDE_BALL_RADIUS));
			
			true_spline_pts = new Array(new Point(VALUE_X, -0.5*Pipe.WIDE_BALL_RADIUS), new Point(VALUE_X, m_height + 0.5*Pipe.WIDE_BALL_RADIUS));
			
			var top_outline_drawing_points:Array = new Array();
			var top_inner_drawing_points:Array = new Array();
			
			top_outline_drawing_points.push(new Array(p1.x, p1.y, 1.0));
			top_inner_drawing_points.push(new Array(p1.x, p1.y, 0.0));
			top_outline_drawing_points.push(new Array(p2.x, p2.y, 0.0));
			top_inner_drawing_points.push(new Array(p2.x, p2.y, 0.0));
			
			top_outline_drawing_points.unshift(new Array(top_p2.x, top_p2.y, 1.0));
			top_outline_drawing_points.unshift(new Array(top_p1.x, top_p1.y, 1.0));
			top_outline_drawing_points.unshift(new Array(top_p0.x, top_p0.y, 1.0));
			top_inner_drawing_points.unshift(new Array(top_p2.x, top_p2.y, 1.0));
			top_inner_drawing_points.unshift(new Array(top_p1.x, top_p1.y, 1.0));
			
			var main_color:Number = VerigameSystem.UNADJUSTABLE_PIPE_COLOR;
			var r:Number = main_color >> 16 & 0xFF;
			var g:Number = main_color >> 8 & 0xFF;
			var b:Number = main_color & 0xFF;
			var outline_color:Number = Math.round(r*0.75) << 16 ^ Math.round(g*0.75) << 8 ^ Math.round(b*0.75);
			
			Pipe.drawFromPolyline(top_outline_drawing_points, 1.5*Pipe.WIDE_PIPE_WIDTH, Pipe.WIDE_PIPE_WIDTH, 4, outline_color, outline_color, 1.0, false_pipe_pane);
			Pipe.drawFromPolyline(top_inner_drawing_points, 1.5*Pipe.WIDE_PIPE_WIDTH, Pipe.WIDE_PIPE_WIDTH, -4, main_color, main_color, 1.0, false_pipe_pane);
			
			Pipe.drawFromPolyline(false_pipe_drawing_pts, Pipe.WIDE_PIPE_WIDTH, Pipe.WIDE_PIPE_WIDTH, 4, outline_color, outline_color, 1.0, false_pipe_pane);
			Pipe.drawFromPolyline(false_pipe_drawing_pts, Pipe.WIDE_PIPE_WIDTH, Pipe.WIDE_PIPE_WIDTH, -4, main_color, main_color, 1.0, false_pipe_pane);
			
			// Masks for only showing visible parts of pipe, other parts are hidden depending on which configuration the MapGet is in (only one pipe path is shown)
			false_mask.graphics.beginFill(0x0);
			false_mask.graphics.moveTo(0, 0.5 * m_height);
			false_mask.graphics.lineTo(KEY_X, m_height);
			false_mask.graphics.lineTo(VALUE_X, 0.0);
			false_mask.graphics.lineTo(KEY_X, 0);
			false_mask.graphics.lineTo(0, 0.5 * m_height);
			
			true_mask.graphics.beginFill(0x0);
			true_mask.graphics.moveTo(KEY_X, 0.0);
			true_mask.graphics.lineTo(KEY_X, 0.4 * m_height);
			true_mask.graphics.lineTo(ARGUMENT_X, 0.4 * m_height);
			true_mask.graphics.lineTo(ARGUMENT_X, 0.0);
			true_mask.graphics.lineTo(KEY_X, 0.0);
			
		}
		
		private function draw():void {
			graphics.clear();
			graphics.lineStyle(4.0, node.mapEdge.associated_pipe.darker_accent_color);
			graphics.beginFill(node.mapEdge.associated_pipe.main_color);
			graphics.drawRect(0, 0, m_width, m_height);
			
			// Draw the "true" case (one stamps on the argument pipe matches the color of the map pipe) where the value pipe's ball(s) is output
			true_pipe_pane.graphics.clear();
			var true_pipe_drawing_pts:Array = new Array( new Array(VALUE_X, 0.0, 1.0), new Array(VALUE_X, m_height, 1.0) );
			
			var value_width:Number = Pipe.NARROW_PIPE_WIDTH;
			if (node.valueEdge.associated_pipe.is_wide) {
				value_width = Pipe.WIDE_PIPE_WIDTH;
			}
			Pipe.drawFromPolyline(true_pipe_drawing_pts, value_width, value_width, 4, node.valueEdge.associated_pipe.darker_accent_color, node.valueEdge.associated_pipe.darker_accent_color, 1.0, true_pipe_pane);
			Pipe.drawFromPolyline(true_pipe_drawing_pts, value_width, value_width, -4, node.valueEdge.associated_pipe.main_color, node.valueEdge.associated_pipe.main_color, 1.0, true_pipe_pane);
			
			// Draw the Argument pipe extension
			arg_pipe_pane.graphics.clear();
			var arg_pipe_drawing_pts:Array = new Array( new Array(ARGUMENT_X, 0.0, 1.0), new Array(ARGUMENT_X, 0.5 * m_height, 1.0) );
			
			var arg_width:Number = Pipe.NARROW_PIPE_WIDTH;
			if (node.argumentEdge.associated_pipe.is_wide) {
				arg_width = Pipe.WIDE_PIPE_WIDTH;
			}
			Pipe.drawFromPolyline(arg_pipe_drawing_pts, arg_width, arg_width, 4, node.argumentEdge.associated_pipe.darker_accent_color, node.argumentEdge.associated_pipe.darker_accent_color, 1.0, arg_pipe_pane);
			Pipe.drawFromPolyline(arg_pipe_drawing_pts, arg_width, arg_width, -4, node.argumentEdge.associated_pipe.main_color, node.argumentEdge.associated_pipe.main_color, 1.0, arg_pipe_pane);
			
			if (argumentHasMapStamp) {
				addChild(false_mask);
				false_pipe_pane.mask = false_mask;
				true_pipe_pane.mask = null;
				if (true_mask.parent) {
					true_mask.parent.removeChild(true_mask);
				}
				addChild(false_pipe_pane);
				addChild(true_pipe_pane);
			} else {
				addChild(true_mask);
				false_pipe_pane.mask = null;
				true_pipe_pane.mask = true_mask;
				if (false_mask.parent) {
					false_mask.parent.removeChild(false_mask);
				}
				addChild(true_pipe_pane);
				addChild(false_pipe_pane);
			}
			addChild(arg_pipe_pane);
			addChild(large_ball);
			addChild(star_goal_icon);
		}
		
		private function onValuePipeWidthChange(e:PipeChangeEvent):void {
			if (e.pipe.width == Pipe.WIDE_PIPE_WIDTH) {
				if (node.outgoing_ports[0].edge.associated_pipe) {
					if (!node.outgoing_ports[0].edge.associated_pipe.is_wide) {
						node.outgoing_ports[0].edge.associated_pipe.pipeClick(null);
					}
				} else {
					VerigameSystem.printWarning("WARNING! MapGet object with outgoing edge's Pipe == null, node id: " + node.node_id);
				}
			}
			draw();
		}
		
		private function onArgumentPipeWidthChange(e:PipeChangeEvent):void {
			draw();
		}
		
		private function onArgumentStampChange(e:StampChangeEvent):void {
			if (!argumentHasMapStamp && !node.outgoing_ports[0].edge.associated_pipe.is_wide) {
				node.outgoing_ports[0].edge.associated_pipe.pipeClick(null);
			}
			draw();
		}
		
		private function onOutgoingPipeWidthChange(e:PipeChangeEvent):void {
			if (e.pipe.width == Pipe.NARROW_PIPE_WIDTH) {
				if (node.valueEdge.associated_pipe) {
					if (node.valueEdge.associated_pipe.is_wide) {
						node.valueEdge.associated_pipe.pipeClick(null);
					}
				} else {
					VerigameSystem.printWarning("WARNING! MapGet object with outgoing edge's Pipe == null, node id: " + node.node_id);
				}
				if (!argumentHasMapStamp) {
					node.argumentEdge.linked_edge_set.addStamp(node.mapEdge.linked_edge_set.id, true);
					if (board.level.pipeEdgeSetDictionary[node.argumentEdge.linked_edge_set.id] != null) {
						for each (var my_pipe_to_draw:Pipe in (board.level.pipeEdgeSetDictionary[node.argumentEdge.linked_edge_set.id] as Vector.<Pipe>)) {
							my_pipe_to_draw.drawStamps();
							my_pipe_to_draw.draw();
						}
					} else {
						VerigameSystem.printWarning("WARNING! No linked pipes found for edge set id: " + node.argumentEdge.linked_edge_set.id);
					}
				}
			}
			draw();
		}
		
		private function onClick(e:MouseEvent):void {
			if (animating) {
				return;
			}
			if (argumentHasMapStamp) {
				node.argumentEdge.linked_edge_set.deactivateStamp(node.mapEdge.linked_edge_set.id);
				if (node.outgoing_ports[0].edge.associated_pipe) {
					if (!node.outgoing_ports[0].edge.associated_pipe.is_wide) {
						node.outgoing_ports[0].edge.associated_pipe.pipeClick(null);
					}
				} else {
					VerigameSystem.printWarning("WARNING! MapGet object with outgoing edge's Pipe == null, node id: " + node.node_id);
				}
			} else {
				// TODO: should this code add the stamp if not already there? Perhaps only activate it
				node.argumentEdge.linked_edge_set.addStamp(node.mapEdge.linked_edge_set.id, true);
			}
			draw();
			if (node.outgoing_ports[0].edge.associated_pipe) {
				var currentWorld:World = (PipeJamController.mainController.sceneController.currentScene as VerigameSystemGameScene).getActiveWorld();
				var boards_to_update:Vector.<BoardNodes> = currentWorld.simulateLinkedPipes(node.outgoing_ports[0].edge.associated_pipe, PipeJamController.mainController.simulator);
				currentWorld.simulatorUpdateTroublePointsFS(PipeJamController.mainController.simulator, boards_to_update);
			} else {
				VerigameSystem.printWarning("WARNING! MapGet object with outgoing edge's Pipe == null, node id: " + node.node_id);
			}
			onMouseOver(null);
		}
		
		private function onMouseOver(e:MouseEvent):void {
			if (animating) {
				return;
			}
			graphics.clear();
			graphics.lineStyle(4.0, 0xFFFFFF);
			graphics.beginFill(node.mapEdge.associated_pipe.main_color);
			graphics.drawRect(0, 0, m_width, m_height);
		}
		
		private function onMouseOut(e:MouseEvent):void {
			if (animating) {
				return;
			}
			graphics.clear();
			graphics.lineStyle(4.0, node.mapEdge.associated_pipe.darker_accent_color);
			graphics.beginFill(node.mapEdge.associated_pipe.main_color);
			graphics.drawRect(0, 0, m_width, m_height);
		}
		
		public function get argumentHasMapStamp():Boolean {
			return node.argumentEdge.linked_edge_set.hasActiveStampOfEdgeSetId(node.mapEdge.linked_edge_set.id);
		}
		
	}

}