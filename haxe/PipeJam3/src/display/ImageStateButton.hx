package display;

import starling.display.DisplayObject;
import starling.display.Sprite;

class ImageStateButton extends SimpleButton
{
    private var m_stateCount : Int;
    private var m_ups : Array<DisplayObject>;
    private var m_overs : Array<DisplayObject>;
    private var m_downs : Array<DisplayObject>;
    
    public function new(ups : Array<DisplayObject>, overs : Array<DisplayObject>, downs : Array<DisplayObject>)
    {
        m_stateCount = ups.length;
        
        var obj : DisplayObject;
        
        m_ups = ups;
        var up : Sprite = new Sprite();
        for (obj in m_ups)
        {
            up.addChild(obj);
        }
        
        m_overs = overs;
        var over : Sprite = new Sprite();
        for (obj in m_overs)
        {
            over.addChild(obj);
        }
        
        m_downs = downs;
        var down : Sprite = new Sprite();
        for (obj in m_downs)
        {
            down.addChild(obj);
        }
        
        setState(0);
        
        super(up, over, down);
    }
    
    private function setState(st : Int) : Void
    {
        for (ii in 0...m_stateCount)
        {
            var visible : Bool = (st == ii);
            
            m_ups[ii].visible = visible;
            m_overs[ii].visible = visible;
            m_downs[ii].visible = visible;
        }
    }
}

