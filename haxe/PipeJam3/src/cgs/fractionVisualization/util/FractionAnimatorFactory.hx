package cgs.fractionVisualization.util;

import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.fractionAnimators.grid.GridAddAnimator;
import cgs.fractionVisualization.fractionAnimators.grid.GridCompareSizeAnimator;
import cgs.fractionVisualization.fractionAnimators.grid.GridCompareTargetAnimator;
import cgs.fractionVisualization.fractionAnimators.grid.GridMultiplyAnimator;
import cgs.fractionVisualization.fractionAnimators.grid.GridSubtractAnimator;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionAnimators.numberline.NumberlineAddAnimator;
import cgs.fractionVisualization.fractionAnimators.numberline.NumberlineAddProceduralAnimator;
import cgs.fractionVisualization.fractionAnimators.numberline.NumberlineCompareSizeAnimator;
import cgs.fractionVisualization.fractionAnimators.numberline.NumberlineCompareTargetAnimator;
import cgs.fractionVisualization.fractionAnimators.numberline.NumberlineMultiplyAnimator;
import cgs.fractionVisualization.fractionAnimators.numberline.NumberlineSubtractAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripAddAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripCompareSizeAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripCompareTargetAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripMultiplyAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripScalingMultiplyAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripSplitAnimator;
import cgs.fractionVisualization.fractionAnimators.pie.PieCompareSizeAnimator;
import cgs.fractionVisualization.fractionAnimators.pie.PieAddAnimator;
import cgs.fractionVisualization.fractionAnimators.pie.PieCompareTargetAnimator;
import cgs.fractionVisualization.fractionAnimators.pie.PieMultiplyAnimator;
import cgs.fractionVisualization.fractionAnimators.pie.PieSubtractAnimator;
import cgs.fractionVisualization.fractionAnimators.strip.StripSubtractAnimator;

/**
	 * ...
	 * @author Rich
	 */
class FractionAnimatorFactory
{
    // Instance
    private static var m_instance : FractionAnimatorFactory;
    
    public static function getInstance() : FractionAnimatorFactory
    {
        if (m_instance == null)
        {
            m_instance = new FractionAnimatorFactory();
        }
        return m_instance;
    }
    
    // State
    private var m_animatorStorage : Dynamic;
    
    public function new()
    {
        m_animatorStorage = {};
    }
    
    /**
		 * 
		 * Animator Management
		 * 
		**/
    
    /**
		 * Returns an uninitialized animator of the given type.
		 * @param	typeID
		 * @return
		 */
    public function getAnimatorInstance(typeID : String) : IFractionAnimator
    {
        var result : IFractionAnimator;
        
        // Get the animator storage for this type, creating the storage if this is a new type
        if (!Reflect.hasField(m_animatorStorage, typeID))
        {
            // create new array for this type id
            Reflect.setField(m_animatorStorage, typeID, new Array<Dynamic>());
        }
        var animatorStorage : Array<Dynamic> = Reflect.field(m_animatorStorage, typeID);
        
        // Get a animator out of storage
        if (animatorStorage.length > 0)
        {
            result = animatorStorage.pop();
        }
        else
        {
            // Generate a new animator
            {
                result = generateAnimatorInstance(typeID);
            }
        }
        
        return result;
    }
    
    /**
		 * Creates and returns a new animator instance of the given typeID.
		 * @param	typeID They type of animator to create.
		 * @return
		 */
    private function generateAnimatorInstance(typeID : String) : IFractionAnimator
    {
        var result : IFractionAnimator = null;
        
        switch (typeID)
        {
            case CgsFVConstants.STRIP_STANDARD_COMPARE_SIZE:
                result = new StripCompareSizeAnimator();
            case CgsFVConstants.STRIP_STANDARD_COMPARE_BENCHMARK:
                result = new StripCompareTargetAnimator();
            case CgsFVConstants.STRIP_STANDARD_ADD:
                result = new StripAddAnimator();
            case CgsFVConstants.STRIP_STANDARD_SUBTRACT:
                result = new StripSubtractAnimator();
            case CgsFVConstants.STRIP_STANDARD_MULTIPLY:
                result = new StripMultiplyAnimator();
            case CgsFVConstants.STRIP_SCALING_MULTIPLY:
                result = new StripScalingMultiplyAnimator();
            case CgsFVConstants.STRIP_STANDARD_SPLIT:
                result = new StripSplitAnimator();
            case CgsFVConstants.GRID_STANDARD_COMPARE_SIZE:
                result = new GridCompareSizeAnimator();
            case CgsFVConstants.GRID_STANDARD_COMPARE_BENCHMARK:
                result = new GridCompareTargetAnimator();
            case CgsFVConstants.GRID_STANDARD_ADD:
                result = new GridAddAnimator();
            case CgsFVConstants.GRID_STANDARD_SUBTRACT:
                result = new GridSubtractAnimator();
            case CgsFVConstants.GRID_STANDARD_MULTIPLY:
                result = new GridMultiplyAnimator();
            case CgsFVConstants.PIE_STANDARD_COMPARE_SIZE:
                result = new PieCompareSizeAnimator();
            case CgsFVConstants.PIE_STANDARD_COMPARE_BENCHMARK:
                result = new PieCompareTargetAnimator();
            case CgsFVConstants.PIE_STANDARD_ADD:
                result = new PieAddAnimator();
            case CgsFVConstants.PIE_STANDARD_MULTIPLY:
                result = new PieMultiplyAnimator();
            case CgsFVConstants.PIE_STANDARD_SUBTRACT:
                result = new PieSubtractAnimator();
            case CgsFVConstants.NUMBERLINE_STANDARD_COMPARE_SIZE:
                result = new NumberlineCompareSizeAnimator();
            case CgsFVConstants.NUMBERLINE_STANDARD_COMPARE_BENCHMARK:
                result = new NumberlineCompareTargetAnimator();
            case CgsFVConstants.NUMBERLINE_STANDARD_ADD:
                result = new NumberlineAddAnimator();
            case CgsFVConstants.NUMBERLINE_PROCEDURAL_ADD:
                result = new NumberlineAddProceduralAnimator();
            case CgsFVConstants.NUMBERLINE_STANDARD_SUBTRACT:
                result = new NumberlineSubtractAnimator();
            case CgsFVConstants.NUMBERLINE_STANDARD_MULTIPLY:
                result = new NumberlineMultiplyAnimator();
            default:
        }
        
        return result;
    }
    
    /**
		 * Recycle the given animator so that it may be used again at a future time.
		 * @param	animator
		 */
    public function recycleAnimatorInstance(animator : IFractionAnimator) : Void
    {
        animator.reset();
        Reflect.field(m_animatorStorage, Std.string(animator.animationIdentifier)).push(animator);
    }
}

