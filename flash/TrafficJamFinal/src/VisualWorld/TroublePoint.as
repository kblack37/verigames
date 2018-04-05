package VisualWorld
{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import VisualWorld.Ball;
	
	
	import UserInterface.Components.RectangularObject;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.*;
		
	/**
	 * TroublePoint class defines either a red circle or red rectangle to indicate problems/failures on a section of pipe or subnetwork on a board
	 */
	public class TroublePoint extends Sprite
	{
		
		/** True to use glowing animations (this can be a memory hog) */
		public static const USE_ANIMATED_VERSIONS:Boolean = false;
		
		/** Thickness of lines drawn (if non-animated versions are being used) */
		public const TROUBLEPOINT_LINE_THICKNESS:uint = 12;
		
		/** Original X coordinate given by the user */
		public var original_x:int;
		
		/** Original Y coordinate given by the user */
		public var original_y:int;
		
		/** Original width given by the user */
		public var original_width:Number;
		
		/** Original height given by the user */
		public var original_height:Number;
		
		/** True if circle, false for rectangle */
		public var is_circle:Boolean = true;
		
		/** Troublepoint sprite itself (either circle or rectangle) */
		public var shape:Sprite;// RectangularObject;
				
		/** Glowing troublepoint circle animation */
		[Embed(source = '/../lib/assets/TroublePointCircle.swf', symbol = 'TroublePointCircle')]
		public var TroublePointCircle:Class;
		
		/** Glowing troublepoint rectangle animation */
		[Embed(source = '/../lib/assets/TroublePointRectangle.swf', symbol = 'TroublePointRectangle')]
		public var TroublePointRectangle:Class;
		
		/**
		 * TroublePoint class defines either a red circle or red rectangle to indicate problems/failures on a section of pipe or subnetwork on a board
		 * @param	_x Desired X coordintate of the center of the trouble point
		 * @param	_y Desired Y coordintate of the center of the trouble point
		 * @param	_w Either the width for a rectangle, or a radius for a circle
		 * @param	_h Height for a rectangle, or radius for a circle
		 * @param	_is_circle True if circle, false if rectangle
		 */
		public function TroublePoint(_x:int, _y:int, _w:Number, _h:Number, _is_circle:Boolean = true)
		{
			// x, y = center point
			if (USE_ANIMATED_VERSIONS) {
				x = - 0.5 * _w;
				y = - 0.5 * _h;
			} else {
				x = _x;
				y = _y;
			}
			width = _w;
			height = _h;
			original_x = _x;
			original_y = _y;
			original_width = _w;
			original_height = _h;
			is_circle = _is_circle;
			shape = new Sprite();// RectangularObject( -0.5 * width, -0.5 * height, width, height);
			shape.x = 0;
			shape.y = 0;
			shape.graphics.clear();
			while (shape.numChildren > 0) { shape.removeChildAt(0); }
			switch (Theme.CURRENT_THEME) {
				case Theme.PIPES_THEME:
					shape.graphics.lineStyle(TROUBLEPOINT_LINE_THICKNESS, 0xFF0000, 1.0);
					if (is_circle) {
						if (USE_ANIMATED_VERSIONS) {
							shape = new TroublePointCircle();
						} else {
							shape.graphics.drawCircle(0.0, 0.0, Math.min(_w, _h));
						}
					} else {
						if (USE_ANIMATED_VERSIONS) {
							shape = new TroublePointRectangle();
						} else {
							shape.graphics.drawRect( -0.5 * _w, -0.5 * _h, _w, _h );
						}
					}
					var glow:GlowFilter = new GlowFilter(0xFF0000, 1, 10, 10, 1);
					shape.filters = [glow];
				break;
				case Theme.TRAFFIC_THEME:
					var traffic_tp:MovieClip = new Art_SignJam();
					var scale:Number = _w / traffic_tp.width;
					traffic_tp.scaleX = scale;
					traffic_tp.scaleY = scale;
					shape.addChild(traffic_tp);
					shape.graphics.lineStyle(8.0, 0xFF0000);
					shape.graphics.drawCircle(0, 0, 30);
				break;
			}
			
			/*
			addEventListener(MouseEvent.CLICK, dispatch);
			addEventListener(MouseEvent.ROLL_OVER, dispatch);
			addEventListener(MouseEvent.ROLL_OUT, dispatch);
			*/
			
			draw();
		}
		
		/**
		 * Adds the sprite to the stage if hasn't been added already
		 */
		public function draw():void {
			/*
			graphics.clear();
			graphics.lineStyle(TROUBLEPOINT_LINE_THICKNESS, 0xFF0000, 1.0);
			graphics.drawEllipse(0.0, 0.0, original_width, original_height);
			*/
			if (shape.parent != this) {
				addChild(shape);
			}
		}
		
		/*
		// Attempts to pass a mouseEvent through the trouble point and onto the board below (can't get it to work yet, though)
		protected function dispatch(e:MouseEvent):void {
			if (parent == null)
				return;
			// TODO: this coordinate transformation is not proper, can't pass along mouse events at this point
			return;
			var pt:Point = new Point(mouseX, mouseY);
			var objs:Array = parent.getObjectsUnderPoint(pt);
			for each (var obj:Object in objs) {
				if ( (obj != parent) && (obj != this) ) {
					//(obj as DisplayObject).dispatchEvent(e);
					trace("TP mouse event dispatched to:"); trace(obj);
					break;
				}
			}
		}
		*/
		
		/**
		 * Creates an identical TroublePoint instance
		 * @return The clone of this TroublePoint
		 */
		public function createClone():TroublePoint {
			// IMPORTANT! BECAUSE THIS IS DONE BY HAND, ANY NEW/CHANGED/REMOVED PARAMETERS WITHIN TROUBLEPOINT CLASS MUST BE UPDATED HERE AS WELL
			var clone:TroublePoint = new TroublePoint(original_x, original_y, original_width, original_height, is_circle);
			return clone;
		}
		
	}
}