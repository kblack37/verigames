package scenes.game.display;

import assets.AssetInterface;
import constraints.ConstraintVar;
import starling.textures.Texture;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.filters.BlurFilter;
import starling.textures.TextureAtlas;
import utils.PropDictionary;

class EdgeSkin extends Sprite
{
    private static var mAtlas : TextureAtlas;
    private static var EdgeNarrowSatisfiedSelected : Texture;
    private static var EdgeNarrowSatisfiedUnselected : Texture;
    private static var EdgeNarrowUnsatisfiedSelected : Texture;
    private static var EdgeNarrowUnsatisfiedUnselected : Texture;
    private static var EdgeWideSatisfiedSelected : Texture;
    private static var EdgeWideSatisfiedUnselected : Texture;
    private static var EdgeWideUnsatisfiedSelected : Texture;
    private static var EdgeWideUnsatisfiedUnselected : Texture;
    
    public var parentEdge : Edge;
    
    private var skinHeight : Float;
    private var skinWidth : Float;
    
    private var textureImage : Image;
    
    public function new(_width : Float, _height : Float, _parentEdge : Edge)
    {
        super();
        skinHeight = _height;
        skinWidth = _width;
        
        parentEdge = _parentEdge;
        
        if (mAtlas == null)
        {
            mAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
            EdgeNarrowSatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowSatisfiedSelected);
            EdgeNarrowSatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowSatisfiedUnselected);
            EdgeNarrowUnsatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowUnsatisfiedSelected);
            EdgeNarrowUnsatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowUnsatisfiedUnselected);
            EdgeWideSatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideSatisfiedSelected);
            EdgeWideSatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideSatisfiedUnselected);
            EdgeWideUnsatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideUnsatisfiedSelected);
            EdgeWideUnsatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideUnsatisfiedUnselected);
        }
    }
    
    private function getText(edgeIsNarrow : Bool, edgeIsSatisfied : Bool, edgeIsSelected : Bool) : Texture
    {
        if (edgeIsNarrow)
        {
            if (edgeIsSatisfied)
            {
                return (edgeIsSelected) ? EdgeNarrowSatisfiedSelected : EdgeNarrowSatisfiedUnselected;
            }
            else
            {
                return (edgeIsSelected) ? EdgeNarrowUnsatisfiedSelected : EdgeNarrowUnsatisfiedUnselected;
            }
        }
        else if (edgeIsSatisfied)
        {
            return (edgeIsSelected) ? EdgeWideSatisfiedSelected : EdgeWideSatisfiedUnselected;
        }
        else
        {
            return (edgeIsSelected) ? EdgeWideUnsatisfiedSelected : EdgeWideUnsatisfiedUnselected;
        }
    }
    
    public function draw() : Void
    {
        if (textureImage != null)
        {
            textureImage.removeFromParent(true);
        }
        
        var edgeIsNarrow : Bool = (Std.is(parentEdge.graphConstraint.lhs, ConstraintVar));
        var edgeIsSatisfied : Bool = false;
        var edgeIsSelected : Bool = ((Std.is(parentEdge.toNode, VariableNode))) ? parentEdge.toNode.isSelected : parentEdge.fromNode.isSelected;
        if (Std.is(parentEdge.graphConstraint.lhs, ConstraintVar))
        {
            edgeIsSatisfied = (try cast(parentEdge.graphConstraint.lhs, ConstraintVar) catch(e:Dynamic) null).getProps().hasProp(PropDictionary.PROP_NARROW);
        }
        else if (Std.is(parentEdge.graphConstraint.rhs, ConstraintVar))
        {
            edgeIsSatisfied = !(try cast(parentEdge.graphConstraint.rhs, ConstraintVar) catch(e:Dynamic) null).getProps().hasProp(PropDictionary.PROP_NARROW);
        }
        var text : Texture = getText(edgeIsNarrow, edgeIsSatisfied, edgeIsSelected);
        textureImage = new Image(text);
        textureImage.width = skinWidth;
        textureImage.height = skinHeight;
        addChild(textureImage);
    }
}
