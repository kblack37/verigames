package userInterface.components;

import visualWorld.Pipe;
import networkGraph.StampRef;
import events.StampChangeEvent;
import utilities.XSprite;
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


import userInterface.components.StampSelector;


class StampSelector extends Sprite
{
    public static inline var PICKER_RADIUS : Float = 50.0;
    public static var MAX_PICKER_SLICE_WIDTH_RADIANS : Float = Math.PI / 4;
    public static inline var NAME : String = "StampSelector";
    private static inline var OPEN_TIME : Float = 1.0;
    public var pipe : Pipe;
    private var spinning : Bool = false;
    
    public function new(_x : Float, _y : Float, _pipe : Pipe)
    {
        super();
        x = _x;
        y = _y;
        pipe = _pipe;
        name = NAME;
    }
    
    public function openDisplay() : Void
    {
        while (numChildren > 0)
        {
            var disp : DisplayObject = getChildAt(0);removeChild(disp);disp = null;
        }
        var num_stamps : Int = pipe.associated_edge.linked_edge_set.num_stamps;
        var stamps_dict : Dictionary = pipe.associated_edge.linked_edge_set.stamp_dictionary;
        var stamps : Array<Sprite> = new Array<Sprite>();
        var i : Int = 0;
        for (edge_set_id in Reflect.fields(stamps_dict))
        {
            var next_stamp_color : Float = pipe.board.level.getColorByEdgeSetId(edge_set_id);
            var my_stamp_clip : MovieClip = new ArtStar();
            my_stamp_clip.mouseEnabled = false;
            my_stamp_clip.x = 0;
            my_stamp_clip.y = 0;
            my_stamp_clip.scaleX = 0.75;
            my_stamp_clip.scaleY = 0.75;
            var stamp_width : Float = 0.75 * my_stamp_clip.width * my_stamp_clip.scaleX;
            my_stamp_clip.rotation = i * 360 / num_stamps + 180 + 15;
            XSprite.applyColorTransform(my_stamp_clip, next_stamp_color);
            var my_stamp : Sprite = new Sprite();
            my_stamp.graphics.clear();
            my_stamp.graphics.lineStyle(2, 0x0);
            my_stamp.graphics.beginFill(0xFFFFFF);
            my_stamp.graphics.drawCircle(0, 0, stamp_width);
            my_stamp.addChild(my_stamp_clip);
            var stamp_pt : Point = new Point(PICKER_RADIUS * Math.cos(i * 2 * Math.PI / num_stamps + Math.PI / 2), PICKER_RADIUS * Math.sin(i * 2 * Math.PI / num_stamps + Math.PI / 2));
            my_stamp.mouseEnabled = false;
            addChild(my_stamp);
            stamps.push(my_stamp);
            TweenLite.to(my_stamp, 0.75 * OPEN_TIME, {
                        x : stamp_pt.x,
                        y : stamp_pt.y,
                        delay : 0.25 * OPEN_TIME * i / num_stamps,
                        ease : Bounce.easeOut
                    });
            var my_picker_slice : ColorPickerSlice = new ColorPickerSlice(Math.min(Math.PI / num_stamps, StampSelector.MAX_PICKER_SLICE_WIDTH_RADIANS), i, num_stamps, next_stamp_color, try cast(Reflect.field(stamps_dict, edge_set_id), StampRef) catch(e:Dynamic) null);
            addChildAt(my_picker_slice, 0);
            i++;
        }
        this.scaleX = 0.1;
        this.scaleY = 0.1;
        TweenLite.to(this, OPEN_TIME, {
                    scaleX : 1.0,
                    scaleY : 1.0,
                    ease : Bounce.easeOut,
                    onComplete : startSpinning
                });
    }
    
    public function startSpinning() : Void
    {
        spinning = true;
        spin();
    }
    
    public function stopSpinning() : Void
    {
        spinning = false;
    }
    
    private function spin() : Void
    {
        if (spinning)
        {
            var next_rot : Float = rotation + 45;
            TweenLite.to(this, 5.0, {
                        rotation : next_rot,
                        ease : Cubic.easeInOut,
                        onComplete : spin
                    });
        }
    }
    
    public function onClose() : Void
    {
        var e : StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_SET_CHANGE, null, pipe.associated_edge);
        dispatchEvent(e);
    }
}



class ColorPickerSlice extends Sprite
{
    
    private var radius : Float;
    private var index : Int;
    private var num_stamps : Int;
    private var stamp_color : Float;
    private var stamp_ref : StampRef;
    private var mouseOver : Bool = false;
    
    public function new(_radius : Float, _index : Int, _num_stamps : Int, _stamp_color : Float, _stamp_ref : StampRef)
    {
        super();
        radius = _radius;
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
    
    private function draw() : Void
    {
        graphics.clear();
        graphics.lineStyle(3, (mouseOver) ? 0xFFFFFF : 0x0);
        graphics.beginFill(0x0);
        graphics.moveTo(0, 0);
        graphics.lineTo((StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5 * radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5 * radius));
        graphics.curveTo((StampSelector.PICKER_RADIUS + 40.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2), (StampSelector.PICKER_RADIUS + 40.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2), (StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5 * radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5 * radius));
        graphics.lineTo(0, 0);
        graphics.endFill();
        if (stamp_ref.active)
        {
            graphics.beginFill(stamp_color, 0.9);
            graphics.moveTo(0, 0);
            graphics.lineTo((StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5 * radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 - 0.5 * radius));
            graphics.curveTo((StampSelector.PICKER_RADIUS + 40.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2), (StampSelector.PICKER_RADIUS + 40.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2), (StampSelector.PICKER_RADIUS + 20.0) * Math.cos(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5 * radius), (StampSelector.PICKER_RADIUS + 20.0) * Math.sin(index * 2 * Math.PI / num_stamps + Math.PI / 2 + 0.5 * radius));
            graphics.lineTo(0, 0);
            graphics.endFill();
        }
    }
    
    private function onClick(e : MouseEvent) : Void
    {
        stamp_ref.active = !stamp_ref.active;
        draw();
    }
    
    private function onRollOver(e : MouseEvent) : Void
    {
        mouseOver = true;
        draw();
    }
    
    private function onRollOut(e : MouseEvent) : Void
    {
        mouseOver = false;
        draw();
    }
}