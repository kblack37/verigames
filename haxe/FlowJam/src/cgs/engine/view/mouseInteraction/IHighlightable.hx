package cgs.engine.view.mouseInteraction;


/**
	 * ...
	 * @author Rich
	 */
interface IHighlightable
{
    
    
    /**
		 * Sets whether or not this IHighlightable is being highlighted by the mouse.
		 */
    
    /**
		 * Returns whether or not this IHighlightable is being highlighted by the mouse.
		 */
    var isMouseHighlighted(get, set) : Bool;    
    
    /**
		 * Returns whether or not this IHighlightable is presently highlighted.
		 */
    var isHighlighted(get, never) : Bool;    
    
    /**
		 * Returns whether or not this IHighlightable is presently highlightable.
		 */
    var isHighlightable(get, never) : Bool;

    
    /**
		 * Sets the glow on this CardView to have the provided properties. If NaN is provided for a
		 * given property, that property is not changed on the glow.
		 * @param	hColor The color of the glow.
		 * @param	hAlpha The alpha level of the glow.
		 * @param	hBlurX The blur in the x of the glow.
		 * @param	hBlurY The blur in the y of the glow.
		 * @param	hStrength The strength of the glow.
		 * @param	hQuality The quality of the blur.
		 */
    function setHighlight(hColor : Int, hAlpha : Null<Float> = null, hBlurX : Null<Float> = null, hBlurY : Null<Float> = null, hStrength : Null<Float> = null, hQuality : Int = 1) : Void
    ;
    
    /**
		 * Removes all glows from this CardView.
		 */
    function removeHighlight() : Void
    ;
    
    /**
		 * Computes the highlighting for this Card View
		 * @param	param -- an object containing additional information
		 */
    function updateHighlight(param : Dynamic = null) : Void
    ;
}

