package cgs.fractionVisualization.util;

import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.fractionModules.GridFractionModule;
import cgs.fractionVisualization.fractionModules.IFractionModule;
import cgs.fractionVisualization.fractionModules.LineFractionModule;
import cgs.fractionVisualization.fractionModules.PieFractionModule;
import cgs.fractionVisualization.fractionModules.StripFractionModule;

/**
	 * ...
	 * @author Rich
	 */
class FractionModuleFactory
{
    // Instance
    private static var m_instance : FractionModuleFactory;
    
    public static function getInstance() : FractionModuleFactory
    {
        if (m_instance == null)
        {
            m_instance = new FractionModuleFactory();
        }
        return m_instance;
    }
    
    // State
    private var m_moduleStorage : Dynamic;
    
    public function new()
    {
        m_moduleStorage = {};
    }
    
    /**
		 * 
		 * Module Management
		 * 
		**/
    
    /**
		 * Returns an uninitialized module of the given type.
		 * @param	typeID
		 * @return
		 */
    public function getModuleInstance(typeID : String) : IFractionModule
    {
        var result : IFractionModule;
        
        // Get the module storage for this type, creating the storage if this is a new type
        if (!Reflect.hasField(m_moduleStorage, typeID))
        {
            // create new array for this type id
            Reflect.setField(m_moduleStorage, typeID, new Array<Dynamic>());
        }
        var moduleStorage : Array<Dynamic> = Reflect.field(m_moduleStorage, typeID);
        
        // Get a module out of storage
        if (moduleStorage.length > 0)
        {
            result = moduleStorage.pop();
        }
        else
        {
            // Generate a new module
            {
                result = generateModuleInstance(typeID);
            }
        }
        
        return result;
    }
    
    /**
		 * Creates and returns a new module instance of the given typeID.
		 * @param	typeID They type of module to create.
		 * @return
		 */
    private function generateModuleInstance(typeID : String) : IFractionModule
    {
        var result : IFractionModule;
        
        switch (typeID)
        {
            case CgsFVConstants.STRIP_REPRESENTATION:
                result = new StripFractionModule();
            case CgsFVConstants.GRID_REPRESENTATION:
                result = new GridFractionModule();
            case CgsFVConstants.NUMBERLINE_REPRESENTATION:
                result = new LineFractionModule();
            case CgsFVConstants.PIE_REPRESENTATION:
                result = new PieFractionModule();
            default:
                result = new StripFractionModule();
        }
        
        return (result);
    }
    
    /**
		 * Recycle the given module so that it may be used again at a future time.
		 * @param	module
		 */
    public function recycleModuleInstance(module : IFractionModule) : Void
    {
        module.reset();
        Reflect.field(m_moduleStorage, Std.string(module.representationType)).push(module);
    }
}

