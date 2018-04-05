package visualWorld;

import events.PipeChangeEvent;
import visualWorld.Ball;
import userInterface.components.RectangularObject;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.*;

/**
	 * Graphical representation of two bricks along a pipe, and associated information
	 */
class PinchPoint extends Sprite
{
    
    /** Fixed width of a pinch point graphical object */
    public var PINCH_WIDTH(default, never) : Int = 22;
    
    /** Fixed height of a pinch point graphical object */
    public var PINCH_HEIGHT(default, never) : Int = 26;
    
    /** If false, pinch points are hidden for narrow pipes */
    private var DRAW_FOR_NARROW_PIPES(default, never) : Bool = true;
    
    /** Fixed width of each individual brick drawn within a pinch point block */
    private var brick_width(default, never) : Int = 10;
    
    /** Fixed height of each individual brick drawn within a pinch point block */
    private var brick_height(default, never) : Int = 6;
    
    /** Fixed color of the bricks drawn in the pinch point */
    private var brick_color(default, never) : Float = 0xFF6633;
    
    /** Fixed width of the lines between the bricks */
    private var mortar_width(default, never) : Int = 2;
    
    /** Fixed color of the lines between the bricks */
    private var mortar_color(default, never) : Float = 0xAAAAAA;
    
    /** Fixed width of the border around the pinch point blocks */
    private var pinch_border_width(default, never) : Int = 4;
    
    /** Starting X coordinate of the center of the pinch point blocks */
    public var begin_x : Int;
    
    /** Starting Y coordinate of center of the pinch point blocks */
    public var begin_y : Int;
    
    /** Desired graphical depth of this object (functionality not implemented) */
    private var pinch_depth : Int;
    
    /** True if a highlighted line is drawn around the pinch point */
    private var highlight : Bool = false;
    
    private var pipeIsWide : Bool;
    
    /**
		 * Graphical representation of two bricks along a pipe, and associated information
		 * @param	_begin_x Starting X coordinate
		 * @param	_begin_y Starting Y coordinate
		 * @param	_pipe Pipe that this will be drawn on top of
		 * @param	_system Parent VerigameSystem instance
		 * @param	_depth Desired graphical depth of this object (functionality not implemented)
		 */
    public function new(_begin_x : Int, _begin_y : Int, _pipe : Pipe, _depth : Int = -1)
    {
        super();
        mouseEnabled = false;
        begin_x = _begin_x;
        begin_y = _begin_y;
        pipeIsWide = _pipe.is_wide;
        // TODO: do we want highlighting on these?
        highlight = false;
        //highlight = pipe.highlight;
        pinch_depth = _depth;
        
        _pipe.addEventListener(PipeChangeEvent.PIPE_CHANGE, onPipeWidthChange);
        draw();
    }
    
    public function onPipeWidthChange(e : PipeChangeEvent) : Void
    {
        if (e.pipe.width == Pipe.NARROW_PIPE_WIDTH)
        {
            pipeIsWide = false;
        }
        else
        {
            pipeIsWide = true;
        }
    }
    
    /**
		 * Call to draw the pinch point graphics onto this object instance
		 */
    public function draw() : Void
    {
        graphics.clear();
        while (numChildren > 0)
        {
            var disp : DisplayObject = getChildAt(0);removeChild(disp);disp = null;
        }
        var _sw7_ = (Theme.CURRENT_THEME);        

        switch (_sw7_)
        {
            case Theme.PIPES_THEME:
                var pipe_width : Int;
                if (pipeIsWide || DRAW_FOR_NARROW_PIPES)
                {
                    pipe_width = Pipe.WIDE_PIPE_WIDTH;
                    drawBricks(-0.6 * pipe_width);  // 0.6 (as opposed to 0.5) puts the pinch points slightly further apart  
                    drawBricks(0.6 * pipe_width);
                }
                else
                {
                    pipe_width = Pipe.NARROW_PIPE_WIDTH;
                }
            case Theme.TRAFFIC_THEME:
                var cones : MovieClip = new ArtConstructionCones();
                var scale : Float = 2 * Pipe.WIDE_PIPE_WIDTH / cones.width;
                cones.scaleX = scale;
                cones.scaleY = scale;
                addChild(cones);
        }
    }
    
    /**
		 * Vector graphics call to draw one pinch point block (called twice, once for each side)
		 * @param	ppx X coordinate of the pinch point to be drawn (left brick wall will be negative, right brick portion will be positive)
		 */
    public function drawBricks(ppx : Int) : Void
    {
        if (highlight)
        {
            graphics.lineStyle(pinch_border_width * 2, 0xFFFFFF);
            graphics.drawRect(ppx - 0.5 * PINCH_WIDTH, 0, PINCH_WIDTH, PINCH_HEIGHT);
        }
        // draw brick background
        graphics.lineStyle(0, 0x000000, 0.0);
        graphics.beginFill(brick_color, 1.0);
        graphics.drawRect(ppx - 0.5 * PINCH_WIDTH, 0, PINCH_WIDTH, PINCH_HEIGHT);
        // draw mortar
        var dx : Int;
        var row : Int = 1;
        var col : Int = 1;
        graphics.lineStyle(mortar_width, mortar_color);
        while (row * brick_height < PINCH_HEIGHT + brick_height)
        
        // every other row is offset by 1/2 width{
            
            dx = as3hx.Compat.parseInt(-(row % 2) * 0.5 * brick_width);
            if (row * brick_height < PINCH_HEIGHT)
            {
                graphics.moveTo(ppx - 0.5 * PINCH_WIDTH, row * brick_height);
                graphics.lineTo(ppx + 0.5 * PINCH_WIDTH, row * brick_height);
            }
            col = 1;
            while (col * brick_width + dx < PINCH_WIDTH)
            {
                graphics.moveTo(ppx - 0.5 * PINCH_WIDTH + col * brick_width + dx, (row - 1) * brick_height);
                graphics.lineTo(ppx - 0.5 * PINCH_WIDTH + col * brick_width + dx, Math.min(row * brick_height, PINCH_HEIGHT - 1));
                col++;
            }
            row++;
        }
        graphics.endFill();
        // draw black border
        graphics.lineStyle(pinch_border_width, 0x000000);
        graphics.drawRect(ppx - 0.5 * PINCH_WIDTH, 0, PINCH_WIDTH, PINCH_HEIGHT);
    }
    
    /**
		 * This is used to create another identical instance of this object.
		 * @param	_pipe Associated pipe (if new)
		 * @return The clone of this pinch point
		 */
    public function createClone(_pipe : Pipe = null) : PinchPoint
    // IMPORTANT! BECAUSE THIS IS DONE BY HAND, ANY NEW/CHANGED/REMOVED PARAMETERS WITHIN PINCHPOINT CLASS MUST BE UPDATED HERE AS WELL
    {
        
        var clone : PinchPoint = new PinchPoint(begin_x, begin_y, _pipe, pinch_depth);
        clone.x = x;
        clone.y = y;
        clone.draw();
        return clone;
    }
}
