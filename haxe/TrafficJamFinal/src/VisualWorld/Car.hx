package visualWorld;

import flash.errors.Error;
import events.StampChangeEvent;
import networkGraph.Edge;
import networkGraph.FlowObject;
import networkGraph.StampRef;
import utilities.XSprite;
import com.greensock.TimelineMax;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Transform;
import flash.text.*;
import flash.utils.Dictionary;

class Car extends DropObjectBase
{
    public function new(_starting_edge : Edge, _timeline : TimelineMax = null, flowObject : FlowObject = null)
    {
        super(_starting_edge, _timeline, flowObject);
        initialize();
    }
    
    override public function initialize() : Void
    //use as a marker to check if we are restarting or this is the first time.
    {
        
        var currentChildCount : Int = numChildren;
        while (numChildren > 0)
        {
            var disp : DisplayObject = getChildAt(0);removeChild(disp);disp = null;
        }
        
        // Draw two layers
        var layer1 : Sprite = drawCars(2, .5, .5);
        var layer2 : Sprite = drawCars(1, .5, .5);
        
        //add stars if necessary
        if (m_flowObject.flowStartingEdge.associated_pipe.stamps.length != 0)
        {
            var stamps : Array<MovieClip> = m_flowObject.flowStartingEdge.associated_pipe.getActiveStamps();
            drawStarsOnCars(layer1, stamps);
            drawStarsOnCars(layer2, stamps);
        }
    }
    
    /**
		 *  Function that takes the number of cars to draw and the horizontal and vertical scales. 
		 *  It will then draw the corresponding number of cars spaced one right after the other. It
		 *  will automatically add the cars to the parent view object.
		 *  pre-conditions: numCars > 0 , x > 0, y > 0
		 **/
    private function drawCars(numCars : Float, x : Float, y : Float, keepPosition : Bool = false) : Sprite
    {
        if (numCars <= 0 || x <= 0 || y <= 0)
        {
            throw new Error("drawCars: numCars, x and y must all be greater than 0");
        }
        var newLayer : Sprite = new Sprite();
        
        for (numCarLengths in 0...Pipe.NUM_CAR_LENGTHS_IN_GROUP)
        {
            var newRow : Sprite = new Sprite();
            for (i in 0...numCars)
            {
                var new_car : MovieClip = new ArtCar();
                new_car.scaleX = x;
                new_car.scaleY = y;
                new_car.rotation = -90;
                if (keepPosition)
                {
                    new_car.x = this.x;
                    new_car.y = this.y;
                }
                else
                {
                    new_car.x -= numCarLengths * new_car.width;
                    if (numCars == 2)
                    {
                        new_car.y += new_car.height * (i - 0.5);
                    }
                }
                XSprite.applyColorTransform(new_car, m_flowObject.m_color);
                newRow.addChild(new_car);
                new_car.visible = true;
            }
            rowArray[numCars - 1][numCarLengths] = newRow;
            newLayer.addChild(newRow);
            newRow.visible = true;
        }
        layerArray[numCars - 1] = newLayer;
        addChild(newLayer);
        newLayer.visible = true;
        
        if (0)
        {
            var text : TextField = new TextField();
            text.text = m_flowObject._starting_ball_type + " " + m_flowObject.exit_ball_type;
            newLayer.addChild(text);
            text.x = x;
            text.y = y;
        }
        return newLayer;
    }
    
    /**
		 * Traverses the layer passed to pull out all of the rows associated with the passed layer.  It
		 * will then remove any objects in each row that is a current star and add any stars that are in
		 * the passed Vector.  This will cause all the cars in the layer passed to update to have only the
		 * stars that are in the Vector passed. 
		 * @param newLayer Sprite that represents a "layer" from the layerArray in DropObjectBase
		 * @param starsToDraw Vector of MovieClips containing all the stars that need to be drawn to the
		 * passed layer. If starsToDraw is null then all stars will be removed from the passed layer.
		 */
    private function drawStarsOnCars(newLayer : Sprite, starsToDraw : Array<MovieClip>) : Void
    //draw stars on cars if necessary
    {
        
        var numRows : Int = as3hx.Compat.parseInt(newLayer.numChildren - 1);
        var rowIndex : Int = numRows;
        while (rowIndex >= 0)
        {
            var row : Sprite = try cast(newLayer.getChildAt(rowIndex), Sprite) catch(e:Dynamic) null;
            if (row == null)
            {
                {rowIndex--;continue;
                }
            }
            
            var children : Int = as3hx.Compat.parseInt(row.numChildren - 1);
            var carIndex : Int = children;
            while (carIndex >= 0)
            {
                var new_car : MovieClip = try cast(row.getChildAt(carIndex), MovieClip) catch(e:Dynamic) null;
                if (new_car == null)
                {
                    break;
                }
                else if (Std.is(new_car, Art_Star))
                {
                    row.removeChildAt(carIndex);
                    {carIndex--;continue;
                    }
                }
                
                if (starsToDraw == null)
                {
                    break;
                }
                for (j in 0...starsToDraw.length)
                {
                    var star : MovieClip = starsToDraw[j];
                    var new_star : MovieClip = createStarStamp(.1, .1);
                    new_star.transform = star.transform;
                    
                    // adjust the drawing distance
                    new_star.x = new_car.x + j * star.width;
                    new_star.y = new_car.y;
                    row.addChild(new_star);
                }
                carIndex--;
            }
            rowIndex--;
        }
    }
    
    /**
		 * Function called when the user selects a new stamp to add to the pipe.  This will cause
		 * all the layers in DropObjectBase to update all the stamps with the newly selected or 
		 * deslected stamps.  
		 */
    public function updateStamps() : Void
    {
        var starsToDraw : Array<MovieClip> = m_flowObject.flowStartingEdge.associated_pipe.getActiveStamps();
        
        for (layerIndex in 0...layerArray.length)
        {
            var layer : Sprite = layerArray[layerIndex];
            drawStarsOnCars(layer, starsToDraw);
        }
    }
    
    /**
		 * Determines which stars need to be drawn on cars.  It will only include unique stars 
		 * and will ignore any duplicates.  It will return a Vector of MovieClips containing the
		 * stars that need to be drawn.  If there are no stars to draw it will return a null value.
		 * @return Vector of MovieClip objects containing the stars that need to be drawn. If there
		 * are no stars to draw then it will return null.
		 */
    private function getStars() : Array<MovieClip>
    {
        var allStars : Array<MovieClip> = new Array<MovieClip>();
        var starVector : Array<MovieClip> = m_flowObject.flowStartingEdge.associated_pipe.getActiveStamps();
        if (starVector.length == 0)
        {
            return null;
        }
        allStars.push(starVector[0]);
        for (i in 1...starVector.length)
        {
            var star : MovieClip = starVector[i];
            if (!isDuplicate(star, allStars))
            {
                allStars.push(star);
            }
            else
            {
                break;
            }
        }
        return allStars;
    }
    
    /**
		 * Checks to see if the passed MovieClip is in the Vector of MovieClips passed.  It is only concerend with the color 
		 * of the MovieClip so it will check the individual colorTransform values onctained in the MovieClip. If all three of
		 * the blue, green and red multipliers are the same then it is considered a duplicate.  It will return true if the
		 * MovieClip is a duplicate, falseotherwise. 
		 * @param needle MovieClip to search for in the haystack
		 * @param haystack Vector of MovieClips in which to search for the needle
		 * @return true if the needle is a duplicate in the haystack, false otherwise
		 */
    private function isDuplicate(needle : MovieClip, haystack : Array<MovieClip>) : Bool
    {
        for (i in 0...haystack.length)
        
        //check colors, there has to be a better way{
            
            var otherStarTransform : Transform = haystack[i].transform;
            var compareTransform : Transform = needle.transform;
            if (compareTransform.colorTransform.blueMultiplier == otherStarTransform.colorTransform.blueMultiplier &&
                compareTransform.colorTransform.greenMultiplier == otherStarTransform.colorTransform.greenMultiplier &&
                compareTransform.colorTransform.redMultiplier == otherStarTransform.colorTransform.redMultiplier)
            {
                return true;
            }
        }
        return false;
    }
    
    /**
		 * Convenience method to create new star stamps.  It will return a new star stamp
		 * without any transforms applied to it.  It will be scaled according to the x and
		 * y scale values passed.  The visibility will be set to true and will not be mouse
		 * enabled. Otherwise, all settings are the default values. 
		 * @param xScale the Number representing the x scale of the new star
		 * @param yScale the Number representing the y scale of the new star
		 * @return MovieClip  Art_Star MovieClip with the passed scale value, visibility set to true,
		 * mouse enabled set to false and no transforms applied. 
		 */
    private function createStarStamp(xScale : Float, yScale : Float) : MovieClip
    {
        var new_star : MovieClip = new ArtStar();
        new_star.mouseEnabled = false;
        new_star.scaleX = xScale;
        new_star.scaleY = yScale;
        new_star.visible = true;
        return new_star;
    }
}
