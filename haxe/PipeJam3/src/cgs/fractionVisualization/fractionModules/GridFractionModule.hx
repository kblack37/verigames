package cgs.fractionVisualization.fractionModules;

import Std;
import Std;
import Std;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.FractionSprite;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.constants.GridConstants;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import cgs.utils.CgsTuple;
import flash.display.CapsStyle;
import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.geom.Matrix;
import openfl.geom.Point;

/**
	 * ...
	 * @author Jack
	 */
class GridFractionModule implements IFractionModule
{
    public var doShowBorder(get, set) : Bool;
    public var doShowSegment(get, set) : Bool;
    public var doShowTicks(get, set) : Bool;
    public var rotationRadians(get, set) : Float;
    public var gridSeparation(get, set) : Float;
    public var representationType(get, never) : String;
    public var numBaseUnits(get, never) : Int;
    public var numExtensionUnits(get, set) : Int;
    public var numTotalUnits(get, never) : Int;
    public var baseWidth(get, never) : Float;
    public var totalWidth(get, never) : Float;
    public var unitWidth(get, never) : Float;
    public var unitHeight(get, never) : Float;
    public var numGrids(get, never) : Int;
    public var valueNumDisplayAlpha(get, set) : Float;
    public var valueIsAbove(get, set) : Bool;
    public var isElongatedStrip(get, set) : Bool;
    public var fillColumnBeforeRow(get, set) : Bool;
    public var splitColumnBeforeRow(get, set) : Bool;
    public var maxRowsToFill(get, set) : Int;
    public var maxColumnsToFill(get, set) : Int;
    public var valueNRPosition(get, never) : Point;
    public var numCompleteColumns(get, never) : Int;
    public var blockWidth(get, never) : Float;
    public var blockHeight(get, never) : Float;
    public var numGridRows(get, never) : Int;
    public var numGridColumns(get, never) : Int;
    public var numSpacesInPartialColumn(get, never) : Int;
    public var fillStartFraction(get, set) : CgsFraction;
    public var fillAlpha(get, set) : Float;
    public var fillPercent(get, set) : Float;

    // State
    private var m_fractionSprite : FractionSprite;
    private var m_gridSeparation : Float = GridConstants.BASE_UNIT_SEPARATION;
    private var m_scaleX : Float = GridConstants.BASE_SCALE;
    private var m_scaleY : Float = GridConstants.BASE_SCALE;
    private var m_unitWidth : Float = GridConstants.BASE_UNIT_WIDTH;
    private var m_unitHeight : Float = GridConstants.BASE_UNIT_HEIGHT;
    private var m_doShowBorder : Bool = true;
    private var m_doShowTicks : Bool = true;
    
    public function new()
    {
    }
    
    
    /**
		 * @inheritDoc
		 */
    public function init(fractionSprite : FractionSprite) : Void
    {
        m_fractionSprite = fractionSprite;
        m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY] = false;
        m_fractionSprite.representationState[GridConstants.IS_ELONGATED_STRIP] = false;
        m_fractionSprite.representationState[GridConstants.SPLIT_COLUMN_BEFORE_ROW_KEY] = true;
        m_fractionSprite.representationState[GridConstants.FILL_COLUMN_BEFORE_ROW_KEY] = true;
        m_fractionSprite.representationState[GridConstants.MAX_ROWS_TO_FILL] = -1;  // negative or 0 means no limit  
        m_fractionSprite.representationState[GridConstants.MAX_COLUMNS_TO_FILL] = -1;  // negative or 0 means no limit  
        //m_fractionSprite.representationState[GridConstants.FILL_IN_REVERSE] = false;
        
        m_gridSeparation = GridConstants.BASE_UNIT_SEPARATION;
        m_scaleX = GridConstants.BASE_SCALE;
        m_scaleY = GridConstants.BASE_SCALE;
        m_unitWidth = GridConstants.BASE_UNIT_WIDTH;
        m_unitHeight = GridConstants.BASE_UNIT_HEIGHT;
        m_doShowBorder = true;
        m_doShowTicks = true;
        
        // Initialize the logic grid
        setNumRowsAndColumns();  // So that it computes the optimal dimensions  
        resetLogicGrid();
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        m_fractionSprite = null;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    private function get_doShowBorder() : Bool
    {
        return m_doShowBorder;
    }
    
    private function set_doShowBorder(value : Bool) : Bool
    {
        m_doShowBorder = value;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    private function get_doShowSegment() : Bool
    {
        return m_fractionSprite.segment.visible;
    }
    
    private function set_doShowSegment(value : Bool) : Bool
    {
        m_fractionSprite.segment.visible = value;
        return value;
    }
    
    private function get_doShowTicks() : Bool
    {
        return m_doShowTicks;
    }
    
    private function set_doShowTicks(value : Bool) : Bool
    {
        m_doShowTicks = value;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns the rotation value
		 */
    private function get_rotationRadians() : Float
    {
        return m_fractionSprite.rotationRadians;
    }
    
    /**
		 * Sets the rotation value to be the given value
		 */
    private function set_rotationRadians(value : Float) : Float
    {
        m_fractionSprite.rotationRadians = value;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Return the separation between grids in this module
		 */
    private function get_gridSeparation() : Float
    {
        return m_gridSeparation;
    }
    
    /**
		 * Set the separation between grids
		 */
    private function set_gridSeparation(val : Float) : Float
    {
        m_gridSeparation = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_representationType() : String
    {
        return CgsFVConstants.GRID_REPRESENTATION;
    }
    
    /**
		 * Gets the numBaseUnits on the fractionSprite
		 */
    private function get_numBaseUnits() : Int
    {
        return m_fractionSprite.numBaseUnits;
    }
    
    /**
		 * Gets the fillStartFraction on the fractionSprite
		 */
    private function get_numExtensionUnits() : Int
    {
        return m_fractionSprite.numExtensionUnits;
    }
    
    /**
		 * Sets the fillStartFraction on the fractionSprite
		 */
    private function set_numExtensionUnits(val : Int) : Int
    {
        m_fractionSprite.numExtensionUnits = val;
        var gridRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var gridColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var oldLogicGrid : Array<Bool> = m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY];
        
        var newLogicGrid : Array<Bool> = new Array<Bool>();
        
        for (i in 0...oldLogicGrid.length)
        {
            newLogicGrid[i] = oldLogicGrid[i];
        }
        for (i in oldLogicGrid.length...newLogicGrid.length)
        {
            newLogicGrid[i] = false;
        }
        
        m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY] = newLogicGrid;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Returns the number of total units (base units + extension units). 
		 */
    private function get_numTotalUnits() : Int
    {
        return m_fractionSprite.numTotalUnits;
    }
    
    /**
		 * Returns the base width (ie. not including extensions) of this module.
		 */
    private function get_baseWidth() : Float
    {
        return as3hx.Compat.parseFloat(m_fractionSprite.numBaseUnits) * GridConstants.BASE_UNIT_WIDTH;
    }
    
    /**
		 * Returns the total width (including extensions) of this module.
		 */
    private function get_totalWidth() : Float
    {
        return (as3hx.Compat.parseFloat(m_fractionSprite.numTotalUnits) * unitWidth) + (as3hx.Compat.parseFloat(m_fractionSprite.numTotalUnits - 1) * m_gridSeparation);
    }
    
    /**
		 * Returns the unit width (the width of a value of 1) of this module.
		 */
    private function get_unitWidth() : Float
    {
        return m_unitWidth;
    }
    
    /**
		 * Returns the unit height (the height of a value of 1) of this module.
		 */
    private function get_unitHeight() : Float
    {
        return m_unitHeight;
    }
    
    /**
		 * Returns the number of grids in this representation
		 */
    private function get_numGrids() : Int
    {
        return Std.int(Math.max(Math.ceil((as3hx.Compat.parseFloat(m_fractionSprite.parentView.fraction.numerator)) / (as3hx.Compat.parseFloat(m_fractionSprite.parentView.fraction.denominator))), 1));
    }
    
    /**
		 * Gets the valueNumDisplayAlpha on the fractionSprite
		 */
    private function get_valueNumDisplayAlpha() : Float
    {
        return m_fractionSprite.valueNumDisplayAlpha;
    }
    
    /**
		 * Sets the valueNumDisplayAlpha on the fractionSprite
		 */
    private function set_valueNumDisplayAlpha(val : Float) : Float
    {
        m_fractionSprite.valueNumDisplayAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Returns whether the fraction value is displayed above (or below) the strip.
		 */
    private function get_valueIsAbove() : Bool
    {
        return m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY];
    }
    
    /**
		 * Sets whether the fraction value is displayed above (or below) the strip to be the given value.
		 */
    private function set_valueIsAbove(value : Bool) : Bool
    {
        m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY] = value;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns whether the fraction value is displayed above (or below) the strip.
		 */
    private function get_isElongatedStrip() : Bool
    {
        return m_fractionSprite.representationState[GridConstants.IS_ELONGATED_STRIP];
    }
    
    /**
		 * Sets whether the fraction value is displayed above (or below) the strip to be the given value.
		 */
    private function set_isElongatedStrip(value : Bool) : Bool
    {
        m_fractionSprite.representationState[GridConstants.IS_ELONGATED_STRIP] = value;
        setNumRowsAndColumns();  // So that it computes the optimal dimensions  
        resetLogicGrid();
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns whether the Grid should be filled by column before row.
		 */
    private function get_fillColumnBeforeRow() : Bool
    {
        return m_fractionSprite.representationState[GridConstants.FILL_COLUMN_BEFORE_ROW_KEY];
    }
    
    /**
		 * Sets whether the Grid should be filled by column before row to be the given value.
		 */
    private function set_fillColumnBeforeRow(value : Bool) : Bool
    {
        m_fractionSprite.representationState[GridConstants.FILL_COLUMN_BEFORE_ROW_KEY] = value;
        setNumRowsAndColumns();  // So that it computes the optimal dimensions  
        resetLogicGrid();
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns whether the Grid should be split by column before row.
		 */
    private function get_splitColumnBeforeRow() : Bool
    {
        return m_fractionSprite.representationState[GridConstants.SPLIT_COLUMN_BEFORE_ROW_KEY];
    }
    
    /**
		 * Sets whether the Grid should be split by column before row to be the given value.
		 */
    private function set_splitColumnBeforeRow(value : Bool) : Bool
    {
        m_fractionSprite.representationState[GridConstants.SPLIT_COLUMN_BEFORE_ROW_KEY] = value;
        resetLogicGrid();
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns the limit on number of filled rows.
		 * A negative value means no limit on rows to be filled.
		 */
    private function get_maxRowsToFill() : Int
    {
        return m_fractionSprite.representationState[GridConstants.MAX_ROWS_TO_FILL];
    }
    
    /**
		 * Sets the limit on number of filled rows to be the given value.
		 * A negative or 0 value means no limit on rows to be filled.
		 */
    private function set_maxRowsToFill(value : Int) : Int
    {
        m_fractionSprite.representationState[GridConstants.MAX_ROWS_TO_FILL] = value;
        setNumRowsAndColumns();  // So that it computes the optimal dimensions  
        resetLogicGrid();
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns the limit on number of filled columns.
		 * A negative or 0 value means no limit on rows to be filled.
		 */
    private function get_maxColumnsToFill() : Int
    {
        return m_fractionSprite.representationState[GridConstants.MAX_COLUMNS_TO_FILL];
    }
    
    /**
		 * Sets the limit on number of filled columns to be the given value.
		 * A negative value means no limit on rows to be filled.
		 */
    private function set_maxColumnsToFill(value : Int) : Int
    {
        m_fractionSprite.representationState[GridConstants.MAX_COLUMNS_TO_FILL] = value;
        setNumRowsAndColumns();  // So that it computes the optimal dimensions  
        resetLogicGrid();
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Sets the number of rows and columns to be the given values. If the product of the two does not
		 * equal the denominator of this Grid, then the most square solution will be used instead.
		 * Note: If this Grid is in Elongated Strip form, that supersedes any manual setting of the rows/columns. 
		 * @param	numRows
		 * @param	numColumns
		 */
    public function setNumRowsAndColumns(numRows : Int = -1, numColumns : Int = -1) : Void
    {
        var frac : CgsFraction = m_fractionSprite.parentView.fraction;
        var gridDims : CgsTuple = getGridDimensions(frac, numRows, numColumns);
        m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY] = gridDims.first;
        m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY] = gridDims.second;
    }
    
    /**
		 * Returns whether the Grid should fill in reverse.
		 */
    //public function get fillInReverse():Boolean
    //{
    //return m_fractionSprite.representationState[GridConstants.FILL_IN_REVERSE];
    //}
    
    /**
		 * Sets whether the Grid should fill in reverse to be the given value.
		 */
    //public function set fillInReverse(value:Boolean):void
    //{
    //m_fractionSprite.representationState[GridConstants.FILL_IN_REVERSE] = value;
    //setNumRowsAndColumns();	// So that it computes the optimal dimensions
    //resetLogicGrid();
    //m_fractionSprite.parentView.redraw();
    //}
    
    /**
		 * Returns the position of the value Number Render (relative to the center of the fraction view) of this module.
		 */
    private function get_valueNRPosition() : Point
    {
        var showIntegerAsFraction : Bool = false;  // TODO: standardize showIntegerAsFraction  
        var fracIsInteger : Bool = m_fractionSprite.parentView.fraction.denominator == 1 && !showIntegerAsFraction;
        var result : Point = getValueNRPosition(valueIsAbove, fracIsInteger);
        return result;
    }
    
    public function getValueNRPosition(isAbove : Bool, isInteger : Bool) : Point
    {
        var result : Point = new Point(0, 0);
        var marginDist : Float = ((isInteger) ? GridConstants.NUMBER_DISPLAY_MARGIN_INTEGER : GridConstants.NUMBER_DISPLAY_MARGIN_FRACTION);
        if (isAbove)
        {
            result.y = -unitHeight / 2 - marginDist;
        }
        else
        {
            result.y = unitHeight / 2 + marginDist;
        }
        var newX : Float = result.x * Math.cos(rotationRadians) - result.y * Math.sin(rotationRadians);
        var newY : Float = result.y * Math.cos(rotationRadians) + result.x * Math.sin(rotationRadians);
        result.x = newX;
        result.y = newY;
        return result;
    }
    
    /**
		 * Returns the number of complete columns
		 */
    private function get_numCompleteColumns() : Int
    {
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        return Math.floor(m_fractionSprite.parentView.fraction.numerator / numRows);
    }
    
    /**
		 * Returns the width of a block on this grid
		 */
    private function get_blockWidth() : Float
    {
        var totalWidth : Float = GridConstants.BASE_UNIT_WIDTH;
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        return totalWidth / numColumns;
    }
    
    /**
		 * Returns the height of a block on this grid
		 */
    private function get_blockHeight() : Float
    {
        var totalHeight : Float = GridConstants.BASE_UNIT_HEIGHT;
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        return totalHeight / numRows;
    }
    
    /**
		 * Returns the number of rows in a single grid
		 */
    private function get_numGridRows() : Int
    {
        return m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
    }
    
    /**
		 * Returns the number of columns in a single grid
		 */
    private function get_numGridColumns() : Int
    {
        return m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
    }
    
    private function get_numSpacesInPartialColumn() : Int
    {
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        return as3hx.Compat.parseInt(m_fractionSprite.parentView.fraction.numerator - Math.floor(m_fractionSprite.parentView.fraction.numerator / numRows) * numRows);
    }
    
    /**
		 * Returns the fillStartFraction
		 */
    private function get_fillStartFraction() : CgsFraction
    {
        return m_fractionSprite.fillStartFraction;
    }
    
    /**
		 * Sets the fillStartFraction on the fractionSprite
		 */
    private function set_fillStartFraction(val : CgsFraction) : CgsFraction
    {
        m_fractionSprite.fillStartFraction = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    private function get_fillAlpha() : Float
    {
        return m_fractionSprite.fillAlpha;
    }
    
    /**
		 * Sets the fillAlpha on the fractionSprite
		 */
    private function set_fillAlpha(val : Float) : Float
    {
        m_fractionSprite.fillAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the fillPercent on the fractionSprite
		 */
    private function get_fillPercent() : Float
    {
        return m_fractionSprite.fillPercent;
    }
    
    /**
		 * Sets the fillPercent on the fractionSprite
		 */
    private function set_fillPercent(val : Float) : Float
    {
        m_fractionSprite.fillPercent = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    public function displayNumber(val : Bool) : Void
    {
        m_fractionSprite.numberDisplay.visible = val;
        m_fractionSprite.parentView.redraw();
    }
    
    /**
		 * 
		 * Clone
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function cloneToFractionSprite(cloneFS : FractionSprite) : Void
    {
        // Clone logicGrid
        var frac : CgsFraction = cloneFS.parentView.fraction;
        var numGrids : Int = Std.int(Math.max(Math.ceil((as3hx.Compat.parseFloat(frac.numerator)) / (as3hx.Compat.parseFloat(frac.denominator))), 1));
        var logicGrid : Array<Bool> = new Array<Bool>();
        var dimentions : CgsTuple = VisualizationUtilities.determineSquareGrid(frac.denominator);
        var gridRows : Int = dimentions.first;
        var gridColumns : Int = dimentions.second;
        
        for (i in 0...frac.numerator)
        {
            logicGrid[i] = true;
        }
        cloneFS.representationState[GridConstants.LOGIC_GRID_KEY] = logicGrid;
        cloneFS.representationState[GridConstants.NUM_ROWS_KEY] = gridRows;
        cloneFS.representationState[GridConstants.NUM_COLUMNS_KEY] = gridColumns;
    }
    
    /**
		 * 
		 * Logic Grid
		 * 
		**/
    
    /**
		 * Resets the LogicGrid to how it would show up if freshly created
		 */
    public function resetLogicGrid() : Void
    {
        // Get fraction
        var frac : CgsFraction = m_fractionSprite.parentView.fraction;
        
        // Compute logic grid
        var logicGrid : Array<Bool> = recomputeLogicGrid(frac);
        
        m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY] = logicGrid;
    }
    
    /**
		 * Returns a logic grid for this module as if it had the given fraction.
		 * @param	frac
		 * @param	numRows
		 * @param	numColumns
		 */
    public function getLogicGridOfFraction(frac : CgsFraction = null) : Array<Bool>
    {
        if (frac == null)
        {
            frac = m_fractionSprite.parentView.fraction;
        }
        return recomputeLogicGrid(frac);
    }
    
    /**
		 * Computes the logic grid for the given inputs and returns it.
		 * @param	frac
		 * @param	numRows
		 * @param	numColumns
		 * @return
		 */
    private function recomputeLogicGrid(frac : CgsFraction) : Array<Bool>
    {
        // Compute size of logic grid, and create it
        var logicGrid : Array<Bool> = new Array<Bool>();
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        
        // Fill in the logic grid
        fillLogicGrid(logicGrid, 0, frac.denominator, frac.numerator, numRows, numColumns);
        
        return logicGrid;
    }
    
    /**
		 * Returns a tuple of the rows/columns of the Logic Grid of this Grid Module.
		 * @param	numRows
		 * @param	numColumns
		 * @return
		 */
    private function getGridDimensions(frac : CgsFraction, numRows : Int = 0, numColumns : Int = 0) : CgsTuple
    {
        // Determine the rows and columns
        var tRows : Int = 0;
        var tColumns : Int = 0;
        if (isElongatedStrip)
        {
            tRows = 1;
            tColumns = frac.denominator;
        }
        else
        {
            if (numRows > 0 && numColumns > 0 && numRows * numColumns == frac.denominator)
            {
                tRows = numRows;
                tColumns = numColumns;
            }
            else
            {
                var dimensions : CgsTuple = VisualizationUtilities.determineSquareGrid(frac.denominator);
                tRows = dimensions.first;
                tColumns = dimensions.second;
            }
        }
        var gridRows : Int = (splitColumnBeforeRow) ? tRows : tColumns;
        var gridColumns : Int = (splitColumnBeforeRow) ? tColumns : tRows;
        
        return new CgsTuple(gridRows, gridColumns);
    }
    
    /**
		 * Recursively fills the given logic grid staring at the given index with the number of blocksToFill.
		 * @param	logicGrid
		 * @param	startIndex
		 * @param	blocksPerSquare
		 * @param	blocksToFill
		 */
    private function fillLogicGrid(logicGrid : Array<Bool>, startIndex : Int, blocksPerSquare : Int, blocksToFill : Int, rowSize : Int, columnSize : Int) : Void
    {
        var i : Int;
        
        // Base case - down to the last grid
        if (blocksToFill < blocksPerSquare)
        {
            // Compute number of rows/columns to fill
            var workingMaxFilledRows : Int = rowSize;
            var workingMaxFilledColumns : Int = columnSize;
            if (fillColumnBeforeRow)
            {
                workingMaxFilledRows = Std.int(Math.min(((maxRowsToFill > 0)) ? maxRowsToFill : rowSize, rowSize));
                workingMaxFilledColumns = Std.int(Math.min(Math.min(((maxColumnsToFill > 0))
                ? maxColumnsToFill : columnSize, Math.ceil(blocksToFill / workingMaxFilledRows)), columnSize));
            }
            else
            {
                workingMaxFilledColumns = Std.int(Math.min(((maxColumnsToFill > 0)) ? maxColumnsToFill : columnSize, columnSize));
                workingMaxFilledRows = Std.int(Math.min(Math.min(((maxRowsToFill > 0))
                ? maxRowsToFill : rowSize, Math.ceil(blocksToFill / workingMaxFilledColumns)), rowSize));
            }
            
            // If the limitations set on rows/columns are not enough, then fall back to normal drawing
            if (workingMaxFilledRows * workingMaxFilledColumns < blocksToFill)
            {
                workingMaxFilledRows = rowSize;
                workingMaxFilledColumns = columnSize;
            }
            
            // Fill blocks
            var numFilledBlocks : Int = 0;


            function fillBlock(blockIndex : Int) : Bool
            {
                var fillResult : Bool = false;
                var rowIndex : Int = as3hx.Compat.parseInt(blockIndex % rowSize);
                var columnIndex : Int = Math.floor(blockIndex / rowSize);
                if (rowIndex <= (workingMaxFilledRows - 1) && columnIndex <= (workingMaxFilledColumns - 1))
                {
                    // The -1's turn the number of filled rows/columns into the corresponding indices
                    {
                        logicGrid[startIndex + blockIndex] = true;
                        fillResult = true;
                    }
                }
                return fillResult;
            };


            if (fillColumnBeforeRow)
            {
                // Filling normally - column then row
                for (i in 0...blocksPerSquare)
                {
                    if (fillBlock(i))
                    {
                        numFilledBlocks++;
                        if (numFilledBlocks >= blocksToFill)
                        {
                            break;
                        }
                    }
                }
            }
            else
            {
                // Filling opposite - row then column
                for (rIndex in 0...rowSize)
                {
                    for (cIndex in 0...columnSize)
                    {
                        var aBlockIndex : Int = as3hx.Compat.parseInt(rIndex + (cIndex * rowSize));
                        if (fillBlock(aBlockIndex))
                        {
                            numFilledBlocks++;
                            if (numFilledBlocks >= blocksToFill)
                            {
                                break;
                            }
                        }
                    }
                    if (numFilledBlocks >= blocksToFill)
                    {
                        break;
                    }
                }
            }
            

        }
        else
        {
            // Recursive case - full grid
            {
                // Fill in blocksPerSquare number of blocks
                for (i in startIndex...startIndex + blocksPerSquare)
                {
                    logicGrid[i] = true;
                }
                
                // Recurse
                fillLogicGrid(logicGrid, startIndex + blocksPerSquare, blocksPerSquare, blocksToFill - blocksPerSquare, rowSize, columnSize);
            }
        }
    }
    
    /**
		 * 
		 * Sprite Peeling
		 * 
		**/
    
    /**
		 * To "peel" means to draw a component of the grid to a sprite, fix it so that part is no longer displayed, and return that sprite.
		 */
    
    /**
		 * Draws the contents of each Grid square (and their ticks) to the given list of sprites.
		 * Expects one target sprite for each square being displayed (that is, numTotalUnits).
		 * @param	targetSprites
		 */
    public function peelSquaresToSprites(targetSprites : Array<Sprite>, targetBackbones : Array<Sprite> = null) : Void
    {
        // Get the total width/height
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        // Get data from the representation state
        var logicGrid : Array<Bool> = m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY];
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var tickColor : Int = m_fractionSprite.parentView.tickColor;
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(m_fractionSprite.parentView.foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Draw each square to a sprite
        var index : Int = 0;
        var rotationDegrees : Float = rotationRadians * 180 / Math.PI;
        for (squareIndex in 0...numTotalUnits)
        {
            // Only draw to an existing sprite
            if (targetSprites.length > squareIndex && targetSprites[squareIndex] != null)
            {
                // Get and prep sprite
                var aSprite : Sprite = targetSprites[squareIndex];
                var aBackbone : Sprite = ((targetBackbones != null)) ? targetBackbones[squareIndex] : null;
                aSprite.graphics.clear();
                
                // Draw the segment for this square
                drawSquareSegment(aSprite, numColumns, numRows, logicGrid, index, 0, 0, colors, alphas, ratios, aBackbone);
                
                // Draw the ticks for this square
                drawSquareTicks(aSprite, numColumns, numRows, 0, 0, borderColor, tickColor);  // Do the rotation, if any  ;
                
                
                
                aSprite.rotation = rotationDegrees;
                if (aBackbone != null)
                {
                    aBackbone.rotation = rotationDegrees;
                }
            }
            
            // Update index
            index += (numColumns * numRows);
        }
    }
    
    /**
		 * Returns a tuple containing list of peeled blocks (Vector of Sprite) and their relative locations to the center of this Grid (Vector of Point).
		 * @return
		 */
    public function peelBlocks(peeledBlocks : Array<Sprite> = null, exclusionList : Array<Int> = null) : CgsTuple
    {
        //var peeledBlocks:Vector.<Sprite> = new Vector.<Sprite>();
        if (exclusionList == null)
        {
            exclusionList = new Array<Int>();
        }
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(m_fractionSprite.parentView.foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Draw all the blocks
        var blockCenterPoints : Array<Point> = getBlockCenterPoints(exclusionList);
        var aBlock : Sprite;
        if (peeledBlocks == null)
        {
            peeledBlocks = new Array<Sprite>();
            for (i in 0...blockCenterPoints.length)
            {
                aBlock = new Sprite();
                peeledBlocks.push(aBlock);
            }
        }
        //for each (var aCenterPoint:Point in blockCenterPoints)
        for (i in 0...blockCenterPoints.length)
        {
            //var aBlock:Sprite = new Sprite();
            aBlock = peeledBlocks[i];
            drawSegmentBlock(aBlock, 0, 0, colors, alphas, ratios);
            drawTickBlock(aBlock, 0, 0);
        }
        
        return new CgsTuple(peeledBlocks, blockCenterPoints);
    }
    
    /**
		 * Returns a tuple containing list of peeled blocks (Vector of Sprite) and their relative locations to the center of this Grid (Vector of Point).
		 * @return
		 */
    public function peelPlainBlocks(peeledBlocks : Array<Sprite> = null, exclusionList : Array<Int> = null) : CgsTuple
    {
        //var peeledBlocks:Vector.<Sprite> = new Vector.<Sprite>();
        if (exclusionList == null)
        {
            exclusionList = new Array<Int>();
        }
        
        // Prepping variables for gradient
        var color : Int = m_fractionSprite.parentView.foregroundColor;
        
        // Draw all the blocks
        var blockCenterPoints : Array<Point> = getBlockCenterPoints(exclusionList);
        var aBlock : Sprite;
        if (peeledBlocks == null)
        {
            peeledBlocks = new Array<Sprite>();
            for (i in 0...blockCenterPoints.length)
            {
                aBlock  = new Sprite();
                peeledBlocks.push(aBlock);
            }
        }
        //for each (var aCenterPoint:Point in blockCenterPoints)
        for (i in 0...blockCenterPoints.length)
        {
            aBlock = peeledBlocks[i];
            drawPlainBlock(aBlock, 0, 0, color);
        }
        
        return new CgsTuple(peeledBlocks, blockCenterPoints);
    }
    
    /**
		 * Peels the blocks of this grid onto the given segment, excluding the blocks in the given exclusion list. Offsets all blocks by the given offsetX value.
		 * @return
		 */
    public function peelPlainBlocksAsOne(segment : Sprite, exclusionList : Array<Int> = null, offsetX : Float = 0) : Void
    {
        if (exclusionList == null)
        {
            exclusionList = new Array<Int>();
        }
        
        // Prepping variables for gradient
        var color : Int = m_fractionSprite.parentView.foregroundColor;
        
        // Draw all the blocks
        var blockCenterPoints : Array<Point> = getBlockCenterPoints(exclusionList);
        segment.graphics.clear();
        for (i in 0...blockCenterPoints.length)
        {
            var aBlockCenterPoint : Point = blockCenterPoints[i];
            drawPlainBlock(segment, aBlockCenterPoint.x + offsetX, aBlockCenterPoint.y, color);
        }
    }
    
    public function peelBlocksAsOne(segment : Sprite) : Void
    {
        // Get the total width/height
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        // Get Logic Grid parameters
        var logicGrid : Array<Bool> = m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numUnits : Int = m_fractionSprite.numTotalUnits;
        
        // Computing block parameters
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        var startingBlockX : Float = -workingTotalWidth / 2 + blockWidth / 2;
        var blockX : Float = startingBlockX;
        var startingBlockY : Float = -workingUnitHeight / 2 + blockHeight / 2;
        var blockY : Float = startingBlockY;
        var cornerX : Float = 0;
        var cornerY : Float = 0;
        
        // Draw a rectangle for each block to the segment
        segment.graphics.clear();
        var currIndex : Int = 0;
        for (gridNum in 0...numUnits)
        {
            for (i in 0...numColumns)
            {
                for (j in 0...numRows)
                {
                    if (logicGrid[currIndex])
                    {
                        // Compute corner of this block - used to compute the location of this gradient
                        cornerX = blockX - blockWidth / 2;
                        cornerY = blockY - blockHeight / 2;
                        
                        // Draw this block
                        segment.graphics.beginFill(foregroundColor);
                        segment.graphics.drawRect(cornerX, cornerY, blockWidth, blockHeight);
                        segment.graphics.endFill();
                    }
                    
                    // Compute next block center point
                    blockY += blockHeight;
                    currIndex++;
                }
                blockX += blockWidth;
                blockY = startingBlockY;
            }
            blockX += workingGridSeparation;
        }
    }
    
    /**
		 * Draw just the ticks and border to sprite s
		 * @param	s
		 */
    public function drawTicksToSprite(s : Sprite) : Void
    {
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var tickColor : Int = m_fractionSprite.parentView.tickColor;
        drawSquareTicks(s, numColumns, numRows, 0, 0, borderColor, tickColor);
        
        // Do the rotation, if any
        var rotationDegrees : Float = rotationRadians * 180 / Math.PI;
        s.rotation = rotationDegrees;
    }
    
    /**
		 * 
		 * Block Center Points
		 * 
		**/
    
    //public function computeBlockIndicesFromLogicGrid(logicGrid:Vector.<Boolean>):Vector.<int>
    public function computeBlockIndices() : Array<Int>
    {
        var logicGrid : Array<Bool> = m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY];
        
        // Get data from the representation state
        var result : Array<Int> = new Array<Int>();
        for (i in 0...logicGrid.length)
        {
            if (logicGrid[i])
            {
                result.push(i);
            }
        }
        return result;
    }
    
    /**
		 * Returns a list of the center points of all the blocks, in logic grid order.
		 * @return
		 */
    public function getBlockCenterPoints(indexExclusionList : Array<Int> = null) : Array<Point>
    {
        // Get data from the representation state
        var logicGrid : Array<Bool> = m_fractionSprite.representationState[GridConstants.LOGIC_GRID_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        return computeBlockCenterPoints(logicGrid, numRows, numColumns, indexExclusionList);
    }
    
    /**
		 * Returns a list of the center points of all the blocks, in logic grid order.
		 * @return
		 */
    public function getBlockCenterPointsForFraction(frac : CgsFraction, indexExclusionList : Array<Int> = null) : Array<Point>
    {
        // Get data from the representation state
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        return computeBlockCenterPoints(recomputeLogicGrid(frac), numRows, numColumns, indexExclusionList);
    }
    
    /**
		 * Returns a list of the center points of all the blocks, in logic grid order.
		 * @return
		 */
    private function computeBlockCenterPoints(logicGrid : Array<Bool>, numRows : Int, numColumns : Int, indexExclusionList : Array<Int> = null) : Array<Point>
    {
        if (indexExclusionList == null)
        {
            indexExclusionList = new Array<Int>();
        }
        var result : Array<Point> = new Array<Point>();
        
        // Get the total width/height
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        // Find all the blocks
        var index : Float = 0;
        var workingUnitOffsetX : Float = 0;
        for (gridNum in 0...numTotalUnits)
        {
            // Compute the offset of the centerpoint of this square
            var squareOffsetX : Float = -workingTotalWidth / 2 + workingUnitOffsetX + workingUnitWidth / 2;
            var squareOffsetY : Float = 0;
            
            // Compute location of first block
            var blockX : Float = squareOffsetX - workingUnitWidth / 2 + blockWidth / 2;
            var startBlockY : Float = squareOffsetY - workingUnitHeight / 2 + blockHeight / 2;
            var blockY : Float = startBlockY;
            
            // Draw all the blocks with a gradient
            var currIndex : Int = as3hx.Compat.parseInt(index);
            for (i in 0...numColumns)
            {
                for (j in 0...numRows)
                {
                    // Is in the logic grid but not in the exclusion list
                    if (logicGrid[currIndex] && Lambda.indexOf(indexExclusionList, currIndex) < 0)
                    {
                        result.push(new Point(blockX, blockY));
                    }
                    
                    // Compute next block center point
                    blockY += blockHeight;
                    currIndex++;
                }
                blockX += blockWidth;
                blockY = startBlockY;
            }
            
            index += (numColumns * numRows);
            workingUnitOffsetX += (workingUnitWidth + workingGridSeparation);
        }
        
        return result;
    }
    
    /**
		 * 
		 * Display
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function draw() : Void
    {
        // Get sprites of CFV
        var backbone : Sprite = m_fractionSprite.backbone;
        var segment : Sprite = m_fractionSprite.segment;
        var fill : Sprite = m_fractionSprite.fill;
        var ticks : Sprite = m_fractionSprite.ticks;
        var number : Sprite = m_fractionSprite.numberDisplay;
        
        // Colors
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var backgroundColor : Int = m_fractionSprite.parentView.backgroundColor;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var tickColor : Int = m_fractionSprite.parentView.tickColor;
        var fillColor : Int = m_fractionSprite.parentView.fillColor;
        var textColor : Int = m_fractionSprite.parentView.textColor;
        var textGlowColor : Int = m_fractionSprite.parentView.textGlowColor;
        
        // Get number of units
        var numUnits : Int = m_fractionSprite.numTotalUnits;
        
        // Fill Data
        var fillAlpha : Float = m_fractionSprite.fillAlpha;
        var fillPercent : Float = m_fractionSprite.fillPercent;
        var fillStartFraction : CgsFraction = m_fractionSprite.fillStartFraction;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        var rotationDegrees : Float = rotationRadians * 180 / Math.PI;
        
        // Draw Backbone
        drawBackbone(backbone, numUnits, backgroundColor);
        backbone.rotation = rotationDegrees;
        
        // Draw Segment
        drawSegment(segment, numUnits, foregroundColor);
        segment.rotation = rotationDegrees;
        
        // Draw Fill
        drawFill(fill, m_fractionSprite.parentView.fraction, numTotalUnits, fillColor, fillAlpha, fillStartFraction, fillPercent);
        fill.rotation = rotationDegrees;
        
        // Draw Ticks
        drawTicks(ticks, m_fractionSprite.parentView.fraction, numUnits, borderColor, tickColor, doShowBorder, doShowTicks);
        ticks.rotation = rotationDegrees;
        
        // Draw Number
        drawNumberDisplay(number, m_fractionSprite.parentView.fraction, numUnits, textColor, textGlowColor);
    }
    
    /**
		 * 
		 * Draw Parts
		 * 
		**/
    
    /**
		 * Draws a backbone 
		 */
    private function drawBackbone(backbone : Sprite, numUnits : Int, backgroundColor : Int) : Void
    {
        // Get the total width/height
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        var g : Graphics = backbone.graphics;
        
        // Draw a rectangle for each grid
        g.clear();
        g.beginFill(backgroundColor);
        var workingUnitOffsetX : Float = 0;
        for (i in 0...numUnits)
        {
            g.drawRect(-workingTotalWidth / 2 + workingUnitOffsetX, -workingUnitHeight / 2, workingUnitWidth, workingUnitHeight);
            workingUnitOffsetX += (workingUnitWidth + workingGridSeparation);
        }
        g.endFill();
    }
    
    /**
		 * Draws a segment 
		 */
    private function drawSegment(segment : Sprite, numUnits : Int, foregroundColor : Int) : Void
    {
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Draw all the blocks
        segment.graphics.clear();
        var blockCenterPoints : Array<Point> = getBlockCenterPoints();
        for (aCenterPoint in blockCenterPoints)
        {
            drawSegmentBlock(segment, aCenterPoint.x, aCenterPoint.y, colors, alphas, ratios);
        }
    }
    
    /**
		 * Draws a segment 
		 */
    private function drawSegmentForPeel(segment : Sprite, numUnits : Int, foregroundColor : Int) : Void
    {
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Draw all the blocks
        segment.graphics.clear();
        var blockCenterPoints : Array<Point> = getBlockCenterPoints();
        for (aCenterPoint in blockCenterPoints)
        {
            drawSegmentBlock(segment, aCenterPoint.x, aCenterPoint.y, colors, alphas, ratios);
            drawTickBlock(segment, aCenterPoint.x, aCenterPoint.y);
        }
    }
    
    /**
		 * Draws a single Grid Square (set of columns and rows) segment to the given segment sprite.
		 * @param	segment
		 * @param	numColumns
		 * @param	numRows
		 * @param	logicGrid
		 * @param	startIndex
		 * @param	offsetX
		 * @param	offsetY
		 * @param	colors
		 * @param	alphas
		 * @param	ratios
		 */
    private function drawSquareSegment(segment : Sprite, numColumns : Int, numRows : Int, logicGrid : Array<Bool>, startIndex : Int,
                                       offsetX : Float, offsetY : Float, colors : Array<UInt>, alphas : Array<Float>,
                                       ratios : Array<Int>, aBackbone : Sprite = null) : Void
    {
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        var g : Graphics = segment.graphics;
        
        // Compute location of first block
        var blockX : Float = offsetX - workingUnitWidth / 2 + blockWidth / 2;
        var startBlockY : Float = offsetY - workingUnitHeight / 2 + blockHeight / 2;
        var blockY : Float = startBlockY;
        
        // Draw all the blocks with a gradient
        var currIndex : Int = startIndex;
        for (i in 0...numColumns)
        {
            for (j in 0...numRows)
            {
                if (logicGrid[currIndex])
                {
                    drawSegmentBlock(segment, blockX, blockY, colors, alphas, ratios);
                }
                else
                {
                    if (aBackbone != null)
                    {
                        drawBackboneBlock(aBackbone, blockX, blockY);
                    }
                }
                
                // Compute next block center point
                blockY += blockHeight;
                currIndex++;
            }
            blockX += blockWidth;
            blockY = startBlockY;
        }
    }
    
    /**
		 * Draws a single segment block to the given segment at the given X and Y with the given gradient values.
		 * @param	segment
		 * @param	blockX
		 * @param	blockY
		 * @param	colors
		 * @param	alphas
		 * @param	ratios
		 */
    private function drawSegmentBlock(segment : Sprite, blockX : Float, blockY : Float, colors : Array<UInt>, alphas : Array<Float>, ratios : Array<Int>) : Void
    {
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        
        // Compute corner of this block - used to compute the location of this gradient
        var cornerX : Float = blockX - blockWidth / 2;
        var cornerY : Float = blockY - blockHeight / 2;
        
        // Create the gradient matrix
        var mtx : Matrix = new Matrix();
        mtx.createGradientBox(blockWidth, blockHeight, Math.PI / 4, cornerX, cornerY);
        segment.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mtx);
        
        // Draw this block
        segment.graphics.drawRect(cornerX, cornerY, blockWidth, blockHeight);
        segment.graphics.endFill();
    }
    
    /**
		 * Draws a single segment block to the given segment at the given X and Y, without a gradient.
		 * @param	segment
		 * @param	blockX
		 * @param	blockY
		 * @param	colors
		 * @param	alphas
		 * @param	ratios
		 */
    private function drawPlainBlock(segment : Sprite, blockX : Float, blockY : Float, color : Int) : Void
    {
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        
        // Compute corner of this block - used to compute the location of this gradient
        var cornerX : Float = blockX - blockWidth / 2;
        var cornerY : Float = blockY - blockHeight / 2;
        
        // Use color, no gradient
        segment.graphics.beginFill(color);
        
        // Draw this block
        segment.graphics.drawRect(cornerX, cornerY, blockWidth, blockHeight);
        segment.graphics.endFill();
    }
    
    private function drawBackboneBlock(segment : Sprite, blockX : Float, blockY : Float) : Void
    {
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        var backgroundColor : Int = m_fractionSprite.parentView.backgroundColor;
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        
        // Compute corner of this block - used to compute the location of this gradient
        var cornerX : Float = blockX - blockWidth / 2;
        var cornerY : Float = blockY - blockHeight / 2;
        
        // Use background color
        segment.graphics.beginFill(backgroundColor);
        
        // Draw this block
        segment.graphics.drawRect(cornerX, cornerY, blockWidth, blockHeight);
        segment.graphics.endFill();
    }
    
    /**
		 * Draws a fill 
		 */
    private function drawFill(fill : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, fillAlpha : Float, fillStartFraction : CgsFraction, fillPercent : Float) : Void
    {
        // Get the total width/height
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        // Computing fill parameters
        var startValue : Float = (fillStartFraction != null) ? fillStartFraction.value : 0;
        var fillWidth : Float = workingUnitWidth * (fraction.value - startValue);
        var startValueOffsetX : Float = workingUnitWidth * startValue;
        var startX : Float = -workingTotalWidth / 2 + startValueOffsetX;
        var startY : Float = -workingUnitHeight / 2;
        var endX : Float = startX + (fillWidth * fillPercent);
        var distanceX : Float = endX - startX;
        
        // Draw the fill
        var g : Graphics = fill.graphics;
        g.clear();
        g.beginFill(fillColor, fillAlpha);
        g.drawRect(startX, startY, distanceX, workingUnitHeight);
        g.endFill();
    }
    
    /**
		 * Draws a ticks 
		 */
    private function drawTicks(ticks : Sprite, frac : CgsFraction, numUnits : Int, borderColor : Int, tickColor : Int, showBorder : Bool, showTicks : Bool) : Void
    {
        // Get the total width/height of one unit
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        // Gets data from the representation state
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        
        // Draw ticks
        ticks.graphics.clear();
        var workingUnitOffsetX : Float = -workingTotalWidth / 2 + workingUnitWidth / 2;
        for (gridNum in 0...numUnits)
        {
            drawSquareTicks(ticks, numColumns, numRows, workingUnitOffsetX, 0, borderColor, tickColor, showBorder, showTicks);
            workingUnitOffsetX += (workingUnitWidth + workingGridSeparation);
        }
    }
    
    /**
		 * Draws a single Grid Square (set of columns and rows) ticks to the given segment sprite.
		 * @param	segment
		 * @param	numColumns
		 * @param	numRows
		 * @param	offsetX
		 * @param	offsetY
		 */
    private function drawSquareTicks(ticks : Sprite, numColumns : Int, numRows : Int, offsetX : Float, offsetY : Float, borderColor : Int, tickColor : Int, showBorder : Bool = true, showTicks : Bool = true) : Void
    {
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        
        var g : Graphics = ticks.graphics;
        
        if (showTicks)
        {
            g.lineStyle(GridConstants.TICK_THICKNESS, tickColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            
            // Draw column ticks
            var tickX : Float = offsetX - workingUnitWidth / 2 + blockWidth;
            var tickY : Float = offsetY;
            for (i in 1...numColumns)
            {
                g.moveTo(tickX, tickY - workingUnitHeight / 2);
                g.lineTo(tickX, tickY + workingUnitHeight / 2);
                
                // Compute next tick location
                tickX += blockWidth;
            }
            
            // Draw row ticks
            tickX = offsetX;
            tickY = offsetY - workingUnitHeight / 2 + blockHeight;
            for (i in 1...numRows)
            {
                g.moveTo(tickX - workingUnitWidth / 2, tickY);
                g.lineTo(tickX + workingUnitWidth / 2, tickY);
                
                // Compute next tick location
                tickY += blockHeight;
            }
            g.endFill();
        }
        
        if (showBorder)
        {
            // Draw border (4 lines) - Start in top left, go around clockwise
            g.lineStyle(GridConstants.BACKBONE_BORDER_THICKNESS, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            g.moveTo(offsetX - workingUnitWidth / 2, -workingUnitHeight / 2);
            g.lineTo(offsetX + workingUnitWidth / 2, -workingUnitHeight / 2);
            g.lineTo(offsetX + workingUnitWidth / 2, workingUnitHeight / 2);
            g.lineTo(offsetX - workingUnitWidth / 2, workingUnitHeight / 2);
            g.lineTo(offsetX - workingUnitWidth / 2, -workingUnitHeight / 2);
            g.endFill();
        }
    }
    
    private function drawTickBlock(ticks : Sprite, blockX : Float, blockY : Float) : Void
    {
        var workingTotalWidth : Float = totalWidth;
        var workingUnitWidth : Float = unitWidth;
        var workingUnitHeight : Float = unitHeight;
        var workingGridSeparation : Float = gridSeparation;
        
        var numColumns : Int = m_fractionSprite.representationState[GridConstants.NUM_COLUMNS_KEY];
        var numRows : Int = m_fractionSprite.representationState[GridConstants.NUM_ROWS_KEY];
        var tickColor : Int = m_fractionSprite.parentView.tickColor;
        var blockWidth : Float = workingUnitWidth / numColumns;
        var blockHeight : Float = workingUnitHeight / numRows;
        
        var g : Graphics = ticks.graphics;
        g.lineStyle(GridConstants.TICK_THICKNESS, tickColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        
        // Draw ticks around block
        g.moveTo(blockX - blockWidth / 2, blockY - blockHeight / 2);
        g.lineTo(blockX + blockWidth / 2, blockY - blockHeight / 2);
        g.lineTo(blockX + blockWidth / 2, blockY + blockHeight / 2);
        g.lineTo(blockX - blockWidth / 2, blockY + blockHeight / 2);
        g.lineTo(blockX - blockWidth / 2, blockY - blockHeight / 2);
        g.endFill();
    }
    
    /**
		 * Draws a number display 
		 */
    private function drawNumberDisplay(numberDisplay : Sprite, frac : CgsFraction, numUnits : Int, textColor : Int, textGlowColor : Int) : Void
    {
        // Get the total width/height
        //var workingTotalWidth:Number = totalWidth;
        //var workingUnitWidth:Number = unitWidth;
        //var workingUnitHeight:Number = unitHeight;
        //var workingGridSeparation:Number = gridSeparation;
        
        // Computing parameters
        //var blockWidth:Number = workingUnitWidth / frac.denominator;
        
        // Prepare in-use number renderers for re-use
        m_fractionSprite.prepareNumberRendererForReuse();
        
        // Add number display for the fraction value of the strip
        if (m_fractionSprite.doShowNumberRenderers)
        {
            var fracDisplay : NumberRenderer = m_fractionSprite.getNumberRenderer();
            fracDisplay.showIntegerAsFraction = false;
            fracDisplay.init(frac);
            fracDisplay.setTextColor(textColor);
            fracDisplay.lineColor = textColor;
            fracDisplay.glowColor = textGlowColor;
            var fracDisplayPos : Point = valueNRPosition;
            fracDisplay.x = fracDisplayPos.x;
            fracDisplay.y = fracDisplayPos.y;
            fracDisplay.alpha = valueNumDisplayAlpha;
            numberDisplay.addChild(fracDisplay);
            fracDisplay.render();
        }
        
        // Recycle any extra number renders
        m_fractionSprite.recycleExtraNumberRenderers();
    }
    
    /**
		 * 
		 * Peeling value
		 * 
		**/
    
    public function paintValue(secondSegment : Sprite) : Void
    {
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        secondSegment.graphics.clear();
        
        // Draw Segment
        drawSegmentForPeel(secondSegment, numTotalUnits, foregroundColor);
    }
    
    public function peelValue(secondSegment : Sprite) : Void
    {
        paintValue(secondSegment);
        doShowSegment = false;
    }
    
    public function unpeelValue() : Void
    {
        doShowSegment = true;
    }
    
    /**
		 * 
		 * Extension Mask
		 * 
		**/
    
    public function createExtensionMask(maskWidth : Float) : Sprite
    {
        var result : Sprite = new Sprite();
        
        // Get the total width/height
        var totalHeight : Float = GridConstants.BASE_UNIT_HEIGHT;
        var g : Graphics = result.graphics;
        
        // Draw a rectangle
        g.clear();
        g.beginFill(0xffaaff);
        var borderThickness : Float = GridConstants.BACKBONE_BORDER_THICKNESS;
        g.drawRect(-maskWidth / 2 - borderThickness / 2, -totalHeight / 2 - borderThickness, maskWidth + borderThickness, totalHeight + (borderThickness * 2));
        g.endFill();
        
        //m_fractionSprite.addChild(result);
        //m_fractionSprite.mask = result;
        
        return result;
    }
}

