package visualWorld;

import haxe.Constraints.Function;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.events.MouseEvent;

/**
	 * This class defines the pair of buzzsaws that appear at the top of pipe segments to change large balls into small balls. Note: the animated versions
	 * displayed while placing the buzzsaws that follow the user's mouse are not defined here, they are left_buzzsaw and right_buzzsaw in VerigameSystem.
	 * @author Tim Pavlik
	 */
class BuzzsawPair extends Sprite
{
    private var click_callback : Function;
    private var rollover_glow_filter : GlowFilter;
    private var rollout_glow_filter : GlowFilter;
    private var m_rolling_over : Bool = false;
    
    /** The embedded animated buzzsaw object created by Marianne (this one has a slower framerate, less distracting) */
    @:meta(Embed(source="/../lib/assets/buzz_saw_slow.swf",symbol="BuzzSawSlowMo"))

    private var BuzzSaw : Class<Dynamic>;
    
    public function new(_x : Float, _y : Float, _click_callback : Function)
    {
        super();
        x = _x;
        y = _y;
        click_callback = _click_callback;
        
        var _sw4_ = (Theme.CURRENT_THEME);        

        switch (_sw4_)
        {
            case Theme.PIPES_THEME:
                var left_buzzsaw : Sprite = Type.createInstance(BuzzSaw, []);
                left_buzzsaw.scaleX = -1.0;
                left_buzzsaw.x = -Pipe.WIDE_PIPE_WIDTH;
                left_buzzsaw.y = 0;
                addChild(left_buzzsaw);
                var right_buzzsaw : Sprite = Type.createInstance(BuzzSaw, []);
                right_buzzsaw.x = Pipe.WIDE_PIPE_WIDTH;
                right_buzzsaw.y = 0;
                addChild(right_buzzsaw);
                rollover_glow_filter = new GlowFilter(0xFFFFFF, 1.0, 15, 15, 2, BitmapFilterQuality.MEDIUM);
                rollout_glow_filter = new GlowFilter(0x0, 1, 10, 10, 2);
            case Theme.TRAFFIC_THEME:
                var merge_sign : MovieClip = new ArtSignConstructionMerge();
                merge_sign.scaleX = 0.5;
                merge_sign.scaleY = 0.5;
                addChild(merge_sign);
                rollover_glow_filter = new GlowFilter(0xFFFFFF, 1.0, 15, 15, 2, BitmapFilterQuality.MEDIUM);
                rollout_glow_filter = new GlowFilter(0x0, 0);
        }
        
        addEventListener(MouseEvent.ROLL_OVER, onRollover);
        addEventListener(MouseEvent.ROLL_OUT, onRollout);
        addEventListener(MouseEvent.CLICK, onClick);
        draw();
    }
    
    private function draw() : Void
    {
        if (m_rolling_over)
        {
            this.filters = [rollover_glow_filter];
        }
        else
        {
            this.filters = [rollout_glow_filter];
        }
    }
    
    private function onRollover(e : MouseEvent) : Void
    {
        m_rolling_over = true;
        draw();
    }
    
    private function onRollout(e : MouseEvent) : Void
    {
        m_rolling_over = false;
        draw();
    }
    
    private function onClick(e : MouseEvent) : Void
    {
        m_rolling_over = false;
        draw();
        click_callback();
    }
}

