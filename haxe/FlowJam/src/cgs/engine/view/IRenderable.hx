package cgs.engine.view;


/**
	 * Interface defining the functions of an Renderable Object.
	 * @author Rich
	 */
interface IRenderable
{

    /**
		 * Destorys this IRenderable so that it will be garbage collected.
		 */
    function destroy() : Void
    ;
    
    /**
		 * Registers this IRenderable with the given IRenderer.
		 * @param	updater The IRenderer to be registered with.
		 */
    function registerForRenderer(renderer : IRenderer) : Void
    ;
    
    /**
		 * Render function. Use this function to redraw your sprites.
		 * @param	deltaT Time since the last render loop.
		 * @param	data Data this IRenderable may need.
		 */
    function render(deltaT : Float, data : Dynamic = null) : Void
    ;
}

