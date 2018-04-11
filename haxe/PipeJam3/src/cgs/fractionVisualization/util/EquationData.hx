package cgs.fractionVisualization.util;

import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import openfl.geom.Point;
import flash.text.TextField;

/**
	 * ...
	 * @author Rich
	 */
class EquationData
{
    public var equationCenter(get, set) : Point;
    public var firstValueNR(get, set) : NumberRenderer;
    public var opSymbolText(get, set) : TextField;
    public var secondValueNR(get, set) : NumberRenderer;
    public var equalsSymbolText(get, set) : TextField;
    public var resultValueNR(get, set) : NumberRenderer;
    public var firstValueNR_equationPosition(get, never) : Point;
    public var opSymbolText_equationPosition(get, never) : Point;
    public var secondValueNR_equationPosition(get, never) : Point;
    public var equalsSymbolText_equationPosition(get, never) : Point;
    public var resultValueNR_equationPosition(get, never) : Point;

    // Core state
    private var m_equationCenter : Point;
    private var m_firstValueNR : NumberRenderer;
    private var m_opSymbolText : TextField;
    private var m_secondValueNR : NumberRenderer;
    private var m_equalsSymbolText : TextField;
    private var m_resultValueNR : NumberRenderer;
    
    // Positioning state
    private var m_firstValueNREquationPosition : Point = new Point(0, 0);
    private var m_opSymbolTextEquationPosition : Point = new Point(0, 0);
    private var m_secondValueNREquationPosition : Point = new Point(0, 0);
    private var m_equalsSymbolTextEquationPosition : Point = new Point(0, 0);
    private var m_resultValueNREquationPosition : Point = new Point(0, 0);
    
    public function reset() : Void
    {
        m_equationCenter = null;
        m_firstValueNR = null;
        m_opSymbolText = null;
        m_secondValueNR = null;
        m_equalsSymbolText = null;
        m_resultValueNR = null;
        m_firstValueNREquationPosition = null;
        m_opSymbolTextEquationPosition = null;
        m_secondValueNREquationPosition = null;
        m_equalsSymbolTextEquationPosition = null;
        m_resultValueNREquationPosition = null;
    }
    
    /**
		 * 
		 * Core State
		 * 
		**/
    
    /**
		 * Returns the center position of the equation.
		 */
    private function get_equationCenter() : Point
    {
        return m_equationCenter;
    }
    
    /**
		 * Sets the center position of the equation to be the given value.
		 */
    private function set_equationCenter(value : Point) : Point
    {
        m_equationCenter = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns NR of the first value.
		 */
    private function get_firstValueNR() : NumberRenderer
    {
        return m_firstValueNR;
    }
    
    /**
		 * Sets NR of the first value to be the given value.
		 */
    private function set_firstValueNR(value : NumberRenderer) : NumberRenderer
    {
        m_firstValueNR = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns Text Field of the operation.
		 */
    private function get_opSymbolText() : TextField
    {
        return m_opSymbolText;
    }
    
    /**
		 * Sets Text Field of the operation to be the given value.
		 */
    private function set_opSymbolText(value : TextField) : TextField
    {
        m_opSymbolText = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns NR of the second value.
		 */
    private function get_secondValueNR() : NumberRenderer
    {
        return m_secondValueNR;
    }
    
    /**
		 * Sets NR of the second value to be the given value.
		 */
    private function set_secondValueNR(value : NumberRenderer) : NumberRenderer
    {
        m_secondValueNR = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns Text Field of the equals.
		 */
    private function get_equalsSymbolText() : TextField
    {
        return m_equalsSymbolText;
    }
    
    /**
		 * Sets Text Field of the equals to be the given value.
		 */
    private function set_equalsSymbolText(value : TextField) : TextField
    {
        m_equalsSymbolText = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns NR of the result value.
		 */
    private function get_resultValueNR() : NumberRenderer
    {
        return m_resultValueNR;
    }
    
    /**
		 * Sets NR of the result value to be the given value.
		 */
    private function set_resultValueNR(value : NumberRenderer) : NumberRenderer
    {
        m_resultValueNR = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * 
		 * Positioning State
		 * 
		**/
    
    /**
		 * Returns the equation position of the first NR.
		 */
    private function get_firstValueNR_equationPosition() : Point
    {
        return m_firstValueNREquationPosition;
    }
    
    /**
		 * Returns the equation position of the operation text.
		 */
    private function get_opSymbolText_equationPosition() : Point
    {
        return m_opSymbolTextEquationPosition;
    }
    
    /**
		 * Returns the equation position of the second NR.
		 */
    private function get_secondValueNR_equationPosition() : Point
    {
        return m_secondValueNREquationPosition;
    }
    
    /**
		 * Returns the equation position of the equals text.
		 */
    private function get_equalsSymbolText_equationPosition() : Point
    {
        return m_equalsSymbolTextEquationPosition;
    }
    
    /**
		 * Returns the equation position of the result NR.
		 */
    private function get_resultValueNR_equationPosition() : Point
    {
        return m_resultValueNREquationPosition;
    }
    
    /**
		 * 
		 * Reposition
		 * 
		**/
    
    /**
		 * Computes new positions of all equation parts.
		 */
    private function recomputePositions() : Void
    {
        if (equationCenter != null && firstValueNR != null && opSymbolText != null && secondValueNR != null && equalsSymbolText != null && resultValueNR != null)
        {
            m_firstValueNREquationPosition = new Point(equationCenter.x - secondValueNR.width / 2 - opSymbolText.width - firstValueNR.width / 2, equationCenter.y);
            m_opSymbolTextEquationPosition = new Point(equationCenter.x - secondValueNR.width / 2 - opSymbolText.width, equationCenter.y - opSymbolText.height / 2);
            m_secondValueNREquationPosition = new Point(equationCenter.x, equationCenter.y);
            m_equalsSymbolTextEquationPosition = new Point(equationCenter.x + secondValueNR.width / 2, equationCenter.y - equalsSymbolText.height / 2);
            m_resultValueNREquationPosition = new Point(equationCenter.x + secondValueNR.width / 2 + equalsSymbolText.width + resultValueNR.width / 2, equationCenter.y);
        }
    }
    
    /**
		 * 
		 * Animations
		 * 
		**/
    
    /**
		 * Reveals the Op text and Second NR. Also pulses the Second NR.
		 * @param	eqData
		 * @param	duration
		 * @return
		 */
    public static function animationEquationInline_phaseOne(eqData : EquationData, duration : Float) : TweenSet
    {
        // Start with object for pulse, then add to it
        var result : TweenSet = new TweenSet();
        
        // Pulse Second
        result.addTweensFromOtherSet(FVEmphasis.computeNRPulseTweens(eqData.secondValueNR, duration, 1, 1.5));
        
        // Create tweens
        result.addTween(0, new GTween(eqData.opSymbolText, duration / 2, {
                    alpha : 1
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(0, new GTween(eqData.secondValueNR, duration / 2, {
                    alpha : 1
                }, {
                    ease : Sine.easeInOut
                }));
        
        return result;
    }
    
    /**
		 * Reveals the Equals text and Result NR. Also pulses the Result NR.
		 * @param	eqData
		 * @param	duration
		 * @return
		 */
    public static function animationEquationInline_phaseTwo(eqData : EquationData, duration : Float) : TweenSet
    {
        // Start with object for pulse, then add to it
        var result : TweenSet = new TweenSet();
        
        // Pulse Result
        result.addTweensFromOtherSet(FVEmphasis.computeNRPulseTweens(eqData.resultValueNR, duration, 1, 1.5));
        
        // Create tweens
        result.addTween(0, new GTween(eqData.equalsSymbolText, duration / 2, {
                    alpha : 1
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(0, new GTween(eqData.resultValueNR, duration / 2, {
                    alpha : 1
                }, {
                    ease : Sine.easeInOut
                }));
        
        return result;
    }
    
    /**
		 * Hides the non-result parts of the equation and moves the result to its final location over the given duration.
		 * @param	eqData
		 * @param	duration
		 * @param	finalResultPosition
		 * @return
		 */
    public static function consolidateEquation(eqData : EquationData, duration : Float, finalResultPosition : Point) : TweenSet
    {
        var result : TweenSet = new TweenSet();
        
        // Create tweens
        result.addTween(0, new GTween(eqData.firstValueNR, duration, {
                    alpha : 0
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(0, new GTween(eqData.opSymbolText, duration, {
                    alpha : 0
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(0, new GTween(eqData.secondValueNR, duration, {
                    alpha : 0
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(0, new GTween(eqData.equalsSymbolText, duration, {
                    alpha : 0
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(0, new GTween(eqData.resultValueNR, duration, {
                    x : finalResultPosition.x,
                    y : finalResultPosition.y
                }, {
                    ease : Sine.easeInOut
                }));
        
        return result;
    }

    public function new()
    {
    }
}

