package cgs.engine.view.layering;

import flash.display.DisplayObject;

/**
	 * A CGS Layer holds all the Sprites that need to render on that layer.
	 * Layering allows you to easily differentiate between the Background, Foreground, 
	 * and HUD, or other layers of your choice.
	 * @author Rich
	 */
interface ICGSLayer
{
    
    /**
		 * Returns the display object for this layer. This must be the layer itself, not
		 * a proxy later. That means your ICGSLayer must be a Sprite.
		 */
    var displayObject(get, never) : DisplayObject;    
    
    /**
		 * Returns the layer index for this layer. All ICGSLayers of a lower index are
		 * guaranteed to render underneath this layer. All ICGSLayers of a higher index
		 * are guaranteed to render above this layer. all ICGSLayers of the same index
		 * may and up above or below this layer.
		 */
    var layerIndex(get, never) : Int;

}

