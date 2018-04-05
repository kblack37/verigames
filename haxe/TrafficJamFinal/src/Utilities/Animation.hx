package utilities;

import haxe.Constraints.Function;
import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.utils.Timer;
import mx.collections.ArrayCollection;

/**
	 * Class to perform animations on a display object.
	 * NOTE: to use this class, create a new Animation() object for each independent animation.
	 * Performing multiple animations with the same objects will result in timing conflicts.
	 */
class Animation
{
    
    /** Adjust this to > 1.0 for faster animations or < 1 for slower */
    public static inline var ANIMATION_SPEED_FACTOR : Float = 0.75;
    
    /** Object to animate */
    public var animated_obj : DisplayObject = null;
    
    /** Starting x coord */
    public var orig_x : Float;
    
    /** Starting y coord */
    public var orig_y : Float;
    
    /** Starting scaleX */
    public var orig_scaleX : Float;
    
    /** Starting scaleY */
    public var orig_scaleY : Float;
    
    /** Starting alpha */
    public var orig_alpha : Float;
    
    /** Target alpha */
    public var dest_alpha : Float;
    
    /** Starting rotations per second */
    public var orig_rps : Float;
    
    /** Starting transformation matrix */
    public var orig_matrix : Matrix;
    
    /** Most recent rotation angle (degrees) to use to calculate next rotation angle */
    public var prev_rotation : Float;
    
    /** Current x coord */
    //public var curr_x:Number;
    
    /** Current y coord */
    //public var curr_y:Number;
    
    /** Target x coord */
    public var dest_x : Float;
    
    /** Target y coord */
    public var dest_y : Float;
    
    /** Target scaleX */
    public var dest_scaleX : Float;
    
    /** Target scaleY */
    public var dest_scaleY : Float;
    
    /** Number of milliseconds over which to perform the animation (input at the beginning by the caller) */
    public var msec_allotted : Float;
    
    /** Time the animation was begun */
    public var start_time : Float;
    
    /** Most recent animation time */
    public var prev_time : Float;
    
    /** Timer used to control animation wakeups */
    public var myTimer : Timer;
    
    /** Function to call when animation is complete */
    public var callback : Function;
    
    /** Object to zoom animate */
    public var zoom_obj : DisplayObject = null;
    
    /** Zoom animation starting x coord */
    public var zoom_orig_x : Float;
    
    /** Zoom animation starting y coord */
    public var zoom_orig_y : Float;
    
    /** Zoom animation starting scaleX */
    public var zoom_orig_scaleX : Float;
    
    /** Zoom animation starting scaleY */
    public var zoom_orig_scaleY : Float;
    
    /** Zoom animation starting width */
    public var zoom_orig_w : Float;
    
    /** Zoom animation starting height */
    public var zoom_orig_h : Float;
    
    /** Zoom animation seconds to zoom in */
    public var zoom_in_t : Float;
    
    /** Zoom animation number of seconds to stay zoomed */
    public var zoomed_t : Float;
    
    /** Zoom animation Number of seconds to zoom out */
    public var zoom_out_t : Float;
    
    /** Zoom animation destination scale */
    public var zoom_scale : Float;
    
    /** Zoom animation function to call when object is first all zoomed in (and begins holding for zoomed_t seconds) */
    public var zoomed_func : Function;
    
    /** Zoom animation function to call when object has been zoomed out */
    public var zoom_end_func : Function;
    
    /** Zoom animation start time */
    public var zoom_start_time : Float;
    
    /** Zoom animation timer */
    public var zoomTimer : Timer;
    
    /** Zoom animation true if the objects center of rotation is at (0, 0) */
    public var zoom_centered_obj : Bool;
    
    /**
		 * Class to perform animations on a display object.
		 * NOTE: to use this class, create a new Animation() object for each independent animation.
		 * Performing multiple animations with the same objects will result in timing conflicts.
		 */
    public function new()
    {
    }
    
    /**
		 * Moves an object and slows animation at the end.
		 * @param	_obj Object to move
		 * @param	_dest_x Target x coord
		 * @param	_dest_y Target y coord
		 * @param	_sec Number of seconds animation should take
		 * @param	_callback Function to call when complete
		 */
    public function translateAndDecelerate(_obj : DisplayObject, _dest_x : Float, _dest_y : Float, _sec : Float, _callback : Function) : Void
    {
        animated_obj = _obj;
        myTimer = new Timer(40, 0);  // 25 frames / second  
        orig_x = animated_obj.x;
        orig_y = animated_obj.y;
        //curr_x = orig_x;
        //curr_y = orig_y;
        dest_x = _dest_x;
        dest_y = _dest_y;
        msec_allotted = _sec * 1000 / ANIMATION_SPEED_FACTOR;
        callback = _callback;
        myTimer.addEventListener(TimerEvent.TIMER, performTranslateAndDecelerate);
        start_time = Date.now().time;
        myTimer.start();
    }
    
    /**
		 * Function that performs animation when timer wakes up every x milliseconds
		 * @param	e Associated Timer event
		 */
    private function performTranslateAndDecelerate(e : Event) : Void
    // Spend 75% of the allotted time going 90% of the distance, then slow down and stop
    {
        
        // Lesson learned: you can expect Flash to miss/skip some timer event calls,
        // so deal in absolute time differences to compensate (time since start,
        // not number of updates)
        var dx : Float = dest_x - orig_x;
        var dy : Float = dest_y - orig_y;
        var msec : Float = Date.now().time - start_time;
        var pct : Float = msec / msec_allotted;
        if (msec >= msec_allotted)
        {
            animated_obj.x = dest_x;
            animated_obj.y = dest_y;
            myTimer.stop();
            myTimer.removeEventListener(TimerEvent.TIMER, performTranslateAndDecelerate);
            callback();
        }
        // slowdown region - follow quadratic path:
        else
        {
            
            animated_obj.x = orig_x + ((1 - pct) * pct + pct * Math.sqrt(pct)) * dx;
            animated_obj.y = orig_y + ((1 - pct) * pct + pct * Math.sqrt(pct)) * dy;
        }
    }
    
    /**
		 * Function to zoom in on an object, hold zoom, and then zoom out
		 * @param	_obj Object to zoom
		 * @param	_scale New scale for the object
		 * @param	_zoom_in_t Number of seconds to take to zoom in
		 * @param	_zoomed_func Function to call after zooming in has completed
		 * @param	_zoomed_t Number of seconds to stay zoomed in
		 * @param	_zoom_out_t Number of seconds to take to zoom out
		 * @param	_end_func Function to call after all zooming is completed
		 * @param	_centered_obj True if the center of rotation of the object is at (0, 0), false if at (width/2, height/2)
		 */
    public function zoomInAndOut(_obj : DisplayObject, _scale : Float, _zoom_in_t : Float, _zoomed_func : Function, _zoomed_t : Float, _zoom_out_t : Float, _end_func : Function, _centered_obj : Bool = false) : Void
    /* 
			 * For adjust_parent_scaling:
			 *   All x,y changes will be performed using the parent scale, so instead of x = x + 5 it would be x = x + 5/parent.scaleX
			 * For centered_obj = false:
				THIS ASSUMES OBJECTS ARE DRAWN FROM 0,0 TO WIDTH, HEIGHT (CENTER = 0.5*W, 0.5*H) AND PERFORMS TRANSLATION IN X,Y TO KEEP OBJECT "IN PLACE"
			*/
    {
        
        zoom_obj = _obj;
        zoom_in_t = _zoom_in_t * 1000 / ANIMATION_SPEED_FACTOR;
        zoomed_t = zoom_in_t + _zoomed_t * 1000 / ANIMATION_SPEED_FACTOR;
        zoom_out_t = zoomed_t + _zoom_out_t * 1000 / ANIMATION_SPEED_FACTOR;
        zoom_scale = _scale;
        zoom_orig_x = zoom_obj.x;
        zoom_orig_y = zoom_obj.y;
        zoom_orig_scaleX = zoom_obj.scaleX;  //1.0  
        zoom_orig_scaleY = zoom_obj.scaleY;  //1.0  
        zoom_orig_w = zoom_obj.width;
        zoom_orig_h = zoom_obj.height;
        zoomed_func = _zoomed_func;
        zoom_end_func = _end_func;
        zoom_centered_obj = _centered_obj;
        zoomTimer = new Timer(40, 0);  // 25 frames / second  
        zoomTimer.addEventListener(TimerEvent.TIMER, performZoomIn);
        zoom_start_time = Date.now().time;
        zoomTimer.start();
    }
    
    /**
		 * Function to actually perform zooming in
		 * @param	e Associated Timer Event
		 */
    private function performZoomIn(e : Event) : Void
    {
        var dsx : Float = (zoom_scale - 1.0) * zoom_orig_scaleX;
        var dsy : Float = (zoom_scale - 1.0) * zoom_orig_scaleY;
        var msec : Float = Date.now().time - zoom_start_time;
        var pct : Float = msec / zoom_in_t;
        if (msec >= zoom_in_t)
        {
            zoom_obj.scaleX = zoom_scale * zoom_orig_scaleX;
            zoom_obj.scaleY = zoom_scale * zoom_orig_scaleY;
            if (!zoom_centered_obj)
            {
                zoom_obj.x = zoom_orig_x - 0.5 * (zoom_obj.scaleX * zoom_orig_w - zoom_orig_w);
                zoom_obj.y = zoom_orig_y - 0.5 * (zoom_obj.scaleY * zoom_orig_h - zoom_orig_h);
            }
            zoomTimer.stop();
            zoomTimer.removeEventListener(TimerEvent.TIMER, performZoomIn);
            zoomed_func();
            msec = zoom_in_t;
            zoomTimer = new Timer(zoomed_t - zoom_in_t, 1);  // just one timer event after pause  
            zoomTimer.addEventListener(TimerEvent.TIMER, performZoomPause);
            zoomTimer.start();
        }
        else
        {
            zoom_obj.scaleX = zoom_orig_scaleX + ((1 - pct) * pct + pct * Math.sqrt(pct)) * dsx;
            zoom_obj.scaleY = zoom_orig_scaleY + ((1 - pct) * pct + pct * Math.sqrt(pct)) * dsy;
            if (!zoom_centered_obj)
            {
                zoom_obj.x = zoom_orig_x - 0.5 * (zoom_obj.scaleX * zoom_orig_w - zoom_orig_w);
                zoom_obj.y = zoom_orig_y - 0.5 * (zoom_obj.scaleY * zoom_orig_h - zoom_orig_h);
            }
        }
    }
    
    /**
		 * Function to actually perform holding the zoom
		 * @param	e Associated Timer Event
		 */
    public function performZoomPause(e : Event) : Void
    // should only be called once
    {
        
        zoomTimer.stop();
        zoomTimer.removeEventListener(TimerEvent.TIMER, performZoomPause);
        
        zoomTimer = new Timer(40, 0);  // 25 fps  
        zoomTimer.addEventListener(TimerEvent.TIMER, performZoomOut);
        zoomTimer.start();
    }
    
    /**
		 * Function to actually perform zooming out
		 * @param	e Associated Timer Event
		 */
    private function performZoomOut(e : Event) : Void
    {
        var dsx : Float = zoom_orig_scaleX - zoom_scale;
        var dsy : Float = zoom_orig_scaleY - zoom_scale;
        var msec : Float = Date.now().time - (zoom_start_time + zoomed_t);
        var pct : Float = msec / (zoom_out_t - zoomed_t);
        if (msec >= zoom_out_t - zoomed_t)
        {
            zoom_obj.scaleX = zoom_orig_scaleX;
            zoom_obj.scaleY = zoom_orig_scaleY;
            if (!zoom_centered_obj)
            {
                zoom_obj.x = zoom_orig_x;
                zoom_obj.y = zoom_orig_y;
            }
            zoomTimer.stop();
            zoomTimer.removeEventListener(TimerEvent.TIMER, performZoomOut);
            zoom_end_func();
        }
        else
        {
            zoom_obj.scaleX = zoom_scale + ((1 - pct) * pct + pct * Math.sqrt(pct)) * dsx;
            zoom_obj.scaleY = zoom_scale + ((1 - pct) * pct + pct * Math.sqrt(pct)) * dsy;
            if (!zoom_centered_obj)
            {
                zoom_obj.x = zoom_orig_x - 0.5 * (zoom_obj.scaleX * zoom_orig_w - zoom_orig_w);
                zoom_obj.y = zoom_orig_y - 0.5 * (zoom_obj.scaleY * zoom_orig_h - zoom_orig_h);
            }
        }
    }
    
    /**
		 * Function to perform both a linear translation and zoom, no deceleration and simultaneous zooming
		 * @param	_obj Obect to translate and zoom
		 * @param	_dest_x Target x coord
		 * @param	_dest_y Target y coord
		 * @param	_dest_scaleX Target scaleX
		 * @param	_dest_scaleY Target scaleY 
		 * @param	_sec Number of seconds to perform animation
		 * @param	_callback Function to call when animation is complete
		 */
    public function translateAndZoom(_obj : DisplayObject, _dest_x : Float, _dest_y : Float, _dest_scaleX : Float, _dest_scaleY : Float, _sec : Float, _callback : Function) : Void
    {
        animated_obj = _obj;
        myTimer = new Timer(40, 0);  // 25 frames / second  
        orig_x = animated_obj.x;
        orig_y = animated_obj.y;
        orig_scaleX = animated_obj.scaleX;
        orig_scaleY = animated_obj.scaleY;
        dest_x = _dest_x;
        dest_y = _dest_y;
        dest_scaleX = _dest_scaleX;
        dest_scaleY = _dest_scaleY;
        
        msec_allotted = _sec * 1000 / ANIMATION_SPEED_FACTOR;
        callback = _callback;
        myTimer.addEventListener(TimerEvent.TIMER, performTranslateAndZoom);
        start_time = Date.now().time;
        myTimer.start();
    }
    
    /**
		 * Actually performs translation and zooming on timer wakeup
		 * @param	e Associated Timer Event
		 */
    private function performTranslateAndZoom(e : Event) : Void
    // Lesson learned: you can expect Flash to miss/skip some timer event calls,
    {
        
        // so deal in absolute time differences to compensate (time since start,
        // not number of updates)
        var dx : Float = dest_x - orig_x;
        var dy : Float = dest_y - orig_y;
        var dsx : Float = dest_scaleX - orig_scaleX;
        var dsy : Float = dest_scaleY - orig_scaleY;
        var msec : Float = Date.now().time - start_time;
        var pct : Float = msec / msec_allotted;
        if (msec >= msec_allotted)
        {
            animated_obj.x = dest_x;
            animated_obj.y = dest_y;
            animated_obj.scaleX = dest_scaleX;
            animated_obj.scaleY = dest_scaleY;
            myTimer.stop();
            myTimer.removeEventListener(TimerEvent.TIMER, performTranslateAndDecelerate);
            callback();
        }
        else
        {
            animated_obj.x = orig_x + pct * dx;
            animated_obj.y = orig_y + pct * dy;
            animated_obj.scaleX = orig_scaleX + pct * dsx;
            animated_obj.scaleY = orig_scaleY + pct * dsy;
        }
    }
    
    /**
		 * Function to perfrom straight linear translation and change in alpha (_dest_alpha = 0.0 for dissolve), no deceleration
		 * @param	_obj Object to animate
		 * @param	_dest_x Target x coord
		 * @param	_dest_y Target y coord
		 * @param	_dest_alpha Target alpha
		 * @param	_sec Number of seconds to perform animation
		 * @param	_callback Function to call when animation is complete
		 */
    public function translateAndDissolve(_obj : DisplayObject, _dest_x : Float, _dest_y : Float, _dest_alpha : Float, _sec : Float, _callback : Function) : Void
    {
        animated_obj = _obj;
        myTimer = new Timer(40, 0);  // 25 frames / second  
        orig_x = animated_obj.x;
        orig_y = animated_obj.y;
        orig_alpha = animated_obj.alpha;
        dest_x = _dest_x;
        dest_y = _dest_y;
        dest_alpha = _dest_alpha;
        
        msec_allotted = _sec * 1000;
        callback = _callback;
        myTimer.addEventListener(TimerEvent.TIMER, performTranslateAndDissolve);
        start_time = Date.now().time;
        myTimer.start();
    }
    
    /**
		 * Function to actually perfrom animation on timer wakeup
		 * @param	e Associated Timer Event
		 */
    private function performTranslateAndDissolve(e : Event) : Void
    // Lesson learned: you can expect Flash to miss/skip some timer event calls,
    {
        
        // so deal in absolute time differences to compensate (time since start,
        // not number of updates)
        var dx : Float = dest_x - orig_x;
        var dy : Float = dest_y - orig_y;
        var da : Float = dest_alpha - orig_alpha;
        var msec : Float = Date.now().time - start_time;
        var pct : Float = msec / msec_allotted;
        if (msec >= msec_allotted)
        {
            animated_obj.x = dest_x;
            animated_obj.y = dest_y;
            animated_obj.alpha = dest_alpha;
            myTimer.stop();
            myTimer.removeEventListener(TimerEvent.TIMER, performTranslateAndDissolve);
            callback();
        }
        else
        {
            animated_obj.x = orig_x + pct * dx;
            animated_obj.y = orig_y + pct * dy;
            animated_obj.alpha = orig_alpha + pct * da;
        }
    }
    
    /**
		 * Start spinning fast at given rps (rotations per second), then slow to a stop
		 * NOTE: this will rotate about 0,0 so for objects with 0,0 in the top left portion this will not spin around the center
		 * @param	_obj Object to animate
		 * @param	_start_rps Starting rotations per second (to be decreased to zero at end of animation)
		 * @param	_sec Seconds to perform animation
		 * @param	_callback Function to call when animation is complete
		 */
    public function spinToAStop(_obj : DisplayObject, _start_rps : Float, _sec : Float, _callback : Function) : Void
    {
        animated_obj = _obj;
        orig_matrix = animated_obj.transform.matrix;
        prev_rotation = 0.0;
        myTimer = new Timer(40, 0);  // 25 frames / second  
        orig_rps = _start_rps;  // rotations per second  
        msec_allotted = _sec * 1000 / ANIMATION_SPEED_FACTOR;
        callback = _callback;
        myTimer.addEventListener(TimerEvent.TIMER, performSpinToAStop);
        start_time = Date.now().time;
        prev_time = start_time;
        myTimer.start();
    }
    
    /**
		 * Function to actually perform animation
		 * @param	e Associated Timer Event
		 */
    private function performSpinToAStop(e : Event) : Void
    // For this animation, we actually only care about changes from last frame to this frame, the absolute position (rotation)
    {
        
        // isn't important
        var now : Float = Date.now().time;
        var msec : Float = now - prev_time;
        prev_time = now;
        var msec_since_start : Float = now - start_time;
        var pct : Float = msec_since_start / msec_allotted;
        var dphi : Float = 2.0 * Math.PI * (1.0 - pct) * orig_rps;  // (in degress), angular velocity = linear decline from orig_rps -> 0.0  
        if (msec_since_start >= msec_allotted)
        {
            animated_obj.transform.matrix = orig_matrix;
            myTimer.stop();
            myTimer.removeEventListener(TimerEvent.TIMER, performSpinToAStop);
            callback();
        }
        else
        {
            var rot : Float = prev_rotation + dphi * msec / 1000;
            var m : Matrix = orig_matrix;
            var dx : Float = animated_obj.x + animated_obj.width / 2.0;
            var dy : Float = animated_obj.y + animated_obj.height / 2.0;
            m.tx -= dx;
            m.ty -= dy;
            m.rotate(rot);
            m.tx += dx;
            m.ty += dy;
            animated_obj.transform.matrix = m;
            prev_rotation = rot;
        }
    }
    
    /**
		 * Function to wait x seconds before calling a given function
		 * @param	_sec Seconds to wait
		 * @param	_callback Function to call after delay
		 */
    public function delayedCall(_sec : Float, _callback : Function) : Void
    {
        callback = _callback;
        myTimer = new Timer(_sec * 1000, 1);  // 25 frames / second  
        myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, performDelayedCall);
        myTimer.start();
    }
    
    /**
		 * Actually call the callback when the time is up
		 * @param	e Associated Timer Event
		 */
    private function performDelayedCall(e : Event) : Void
    {
        callback();
    }
}
