package UserInterface.Components 
{
	import VisualWorld.Pipe;
	import NetworkGraph.StampRef;
	import Events.StampChangeEvent;
	import Utilities.XSprite;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class StampSelector extends Sprite 
	{
		public static const PICKER_RADIUS:Number = 50.0;
		public static const MAX_PICKER_SLICE_WIDTH_RADIANS:Number = Math.PI / 4;
		public static const NAME:String = "StampSelector";
		private static const OPEN_TIME:Number = 1.0;
		public var pipe:Pipe;
		private var spinning:Boolean = false;
		
		public function StampSelector(_x:Number, _y:Number, _pipe:Pipe) 
		{
			x = _x;
			y = _y;
			pipe = _pipe;
			name = NAME;
		}
		
		public function openDisplay():void {
			while (numChildren > 0) { var disp:DisplayObject = getChildAt(0); removeChild(disp); disp = null; }
			var num_stamps:int = pipe.associated_edge.linked_edge_set.num_stamps;
			var stamps_dict:Dictionary = pipe.associated_edge.linked_edge_set.stamp_dictionary;
			var stamps:Vector.<Sprite> = new Vector.<Sprite>();
			var i:int = 0;
			for (var edge_set_id:String in stamps_dict) {
				var next_stamp_color:Number = pipe.board.level.getColorByEdgeSetId(edge_set_id);
				var my_stamp_clip:MovieClip = new Art_Star();
				my_stamp_clip.mouseEnabled = false;
				my_stamp_clip.x = 0;
				my_stamp_clip.y = 0;
				my_stamp_clip.scaleX = 0.75;
				my_stamp_clip.scaleY = 0.75;
				var stamp_width:Number = 0.75 * my_stamp_clip.width * my_stamp_clip.scaleX;
				my_stamp_clip.rotation = i * 360 / num_stamps + 180 + 15;
				XSprite.applyColorTransform(my_stamp_clip, next_stamp_color);
				var my_stamp:Sprite = new Sprite();
				my_stamp.graphics.clear();
				my_stamp.graphics.lineStyle(2, 0x0);
				my_stamp.graphics.beginFill(0xFFFFFF);
				my_stamp.graphics.drawCircle(0, 0, stamp_width);
				my_stamp.addChild(my_stamp_clip);
				var stamp_pt:Point = new Point(PICKER_RADIUS * Math.cos(i * 2 * Math.PI / num_stamps + Math.PI / 2), PICKER_RADIUS * Math.sin(i * 2 * Math.PI / num_stamps + Math.PI / 2));
				my_stamp.mouseEnabled = false;
				addChild(my_stamp);
				stamps.push(my_stamp);
				TweenLite.to(my_stamp, 0.75 * OPEN_TIME, { x:stamp_pt.x, y:stamp_pt.y, delay:0.25 * OPEN_TIME * i / num_stamps, ease:Bounce.easeOut } );
				var my_picker_slice:ColorPickerSlice = new ColorPickerSlice(Math.min(Math.PI / num_stamps, StampSelector.MAX_PICKER_SLICE_WIDTH_RADIANS), i, num_stamps, next_stamp_color, stamps_dict[edge_set_id] as StampRef);
				addChildAt(my_picker_slice, 0);
				i++;
			}
			this.scaleX = 0.1;
			this.scaleY = 0.1;
			TweenLite.to(this, OPEN_TIME, { scaleX:1.0, scaleY:1.0, ease:Bounce.easeOut, onComplete:startSpinning } );
		}
		
		public function startSpinning():void {
			spinning = true;
			spin();
		}
		
		public function stopSpinning():void {
			spinning = false;
		}
		
		private function spin():void {
			if (spinning) {
				var next_rot:Number = rotation + 45;
				TweenLite.to(this, 5.0, { rotation:next_rot, ease:Cubic.easeInOut, onComplete:spin } );
			}
		}
		
		public function onClose():void
		{
			var e:StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_SET_CHANGE, null, pipe.associated_edge);
			dispatchEvent(e);
		}
		
	}

}

import flash.display.Sprite;
import flash.events.MouseEvent;
import UserInterface.Components.StampSelector;
import NetworkGraph.StampRef;
class ColorPickerSlice extends Sprite {
	
	private var radius:Number;
	private var index:uint;
	private var num_stamps:uint;
	private var stamp_color:Number;
	private var stamp_ref:StampRef;
	private var mouseOver:Boolean = false;
	
	public function ColorPickerSlice(_radius:Number, _index:uint, _num_stamps:uint, _stamp_color:Number, _stamp_ref:StampRef) {
		radius = _radius
		index = _index;
		num_stamps = _num_stamps;
		stamp_color = _stamp_color;
		stamp_ref = _stamp_ref;
		name = StampSelector.NAME;
		draw();
		buttonMode = true;
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, onRollOut);
	}
	
	private function draw():void {
		graphics.clear();
		graphics.lineStyle(3, mouseOver? 0xFFFFFF : 0x0);
		graphics.beginFill(0x0);
		graphics.moveTo(0, 0);
		graphics.lineTo((StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5*radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5*radius));
		graphics.curveTo((StampSelector.PICKER_RADIUS + 40.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2), (StampSelector.PICKER_RADIUS + 40.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2)
			, (StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5*radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5*radius));
		graphics.lineTo(0, 0);
		graphics.endFill();
		if (stamp_ref.active) {
			graphics.beginFill(stamp_color, 0.9);
			graphics.moveTo(0, 0);
			graphics.lineTo((StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5*radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5*radius));
			graphics.curveTo((StampSelector.PICKER_RADIUS + 40.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2), (StampSelector.PICKER_RADIUS + 40.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2)
				, (StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5*radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5*radius));
			graphics.lineTo(0, 0);
			graphics.endFill();
		}
	}
	
	private function onClick(e:MouseEvent):void {
		stamp_ref.active = !stamp_ref.active;
		draw();
	}
	
	private function onRollOver(e:MouseEvent):void {
		mouseOver = true;
		draw();
	}
	
	private function onRollOut(e:MouseEvent):void {
		mouseOver = false;
		draw();
	}
	
}