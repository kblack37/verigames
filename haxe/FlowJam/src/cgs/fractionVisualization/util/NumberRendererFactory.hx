package cgs.fractionVisualization.util;


/**
	 * ...
	 * @author Rich
	 */
class NumberRendererFactory
{
    public var doShowNumberGlow(never, set) : Bool;

    // Instance
    private static var m_instance : NumberRendererFactory;
    
    public static function getInstance() : NumberRendererFactory
    {
        if (m_instance == null)
        {
            m_instance = new NumberRendererFactory();
        }
        return m_instance;
    }
    
    // State
    private var m_numberRendererStorage : Array<NumberRenderer>;
    
    public function new()
    {
        m_numberRendererStorage = new Array<NumberRenderer>();
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    private var m_doShowNumberGlow : Bool = true;
    
    private function set_doShowNumberGlow(value : Bool) : Bool
    {
        m_doShowNumberGlow = value;
        return value;
    }
    
    /**
		 * 
		 * Number Renderer Management
		 * 
		**/
    
    /**
		 * Returns an uninitialized number renderer.
		 * @return
		 */
    public function getNumberRendererInstance() : NumberRenderer
    {
        var result : NumberRenderer;
        
        // Get a number renderer from storage
        if (m_numberRendererStorage.length > 0)
        {
            result = m_numberRendererStorage.pop();
        }
        else
        {
            // Create a new number renderer
            {
                result = generateNumberRendererInstance();
            }
        }
        
        result.doShowGlow = m_doShowNumberGlow;
        return result;
    }
    
    /**
		 * Creates and returns a new number renderer instance.
		 * @return
		 */
    private function generateNumberRendererInstance() : NumberRenderer
    {
        var result : NumberRenderer = new NumberRenderer();
        
        return (result);
    }
    
    /**
		 * Recycle the given number renderer so that it may be used again at a future time.
		 * @param	numberRenderer
		 */
    public function recycleNumberRendererInstance(numberRenderer : NumberRenderer) : Void
    {
        numberRenderer.reset();
        m_numberRendererStorage.push(numberRenderer);
    }
}

