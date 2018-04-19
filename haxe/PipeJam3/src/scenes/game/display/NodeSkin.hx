package scenes.game.display;

import constraints.INodeProps;
import flash.utils.Dictionary;
import utils.XMath;
import assets.AssetInterface;
import constraints.ConstraintValue;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.filters.BlurFilter;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class NodeSkin extends Sprite implements INodeProps
{
    private static var availableGameNodeSkins : Array<NodeSkin>;
    private static var activeGameNodeSkins : Map<Int, NodeSkin>;
    
    private static var mAtlas : TextureAtlas;
    private static var DarkBlueCircle : Texture;
    private static var LightBlueCircle : Texture;
    private static var LightBlueSelectedCircle : Texture;
    private static var DarkBlueSelectedCircle : Texture;
    private static var SatisfiedConstraintTexture : Texture;
    private static var UnsatisfiedConstraintTexture : Texture;
    private static var UnsatisfiedConstraintBackgroundTexture : Texture;
    
    public var isBackground : Bool = false;
    public var isDirty : Bool = true;
    private var textureImage : Image;
    private var constraintImage : Image;
    
    public static inline var WIDE_COLOR : Int = 0x0B80FF;
    public static inline var NARROW_COLOR : Int = 0xABFFF2;
    
    public static inline var WIDE_COLOR_COMPLEMENT : Int = 0x0B90FF;
    public static inline var NARROW_COLOR_COMPLEMENT : Int = 0x89DDD0;
    
    public var id : Int;
    public static var numSkins : Int = 2000;
    // TODO: Move to factory
    public static function InitializeSkins() : Void
    //generate skins
    {
        
        availableGameNodeSkins = new Array<NodeSkin>();
        activeGameNodeSkins = new Map<Int, NodeSkin>();
        
        for (numSkin in 0...numSkins)
        {
            availableGameNodeSkins.push(new NodeSkin(numSkin));
        }
    }
    
    private static var nextId : Int = 0;
    public static function getNextSkin() : NodeSkin
    {
        var nextSkin : NodeSkin;
        if (availableGameNodeSkins.length > 0)
        {
            nextSkin = availableGameNodeSkins.pop();
        }
        else if (false)
        {
        // attempt limiting the number of skins
            
            {
                var attempts : Int = 0;
                while (activeGameNodeSkins[nextId] == null)
                {
                    if (nextId > numSkins)
                    {
                        nextId = 0;
                    }
                    nextId++;
                    attempts++;
                    if (attempts > numSkins)
                    {
                        break;
                    }
                }
                nextSkin = activeGameNodeSkins[nextId];
                nextId++;
                if (nextSkin != null)
                {
                    nextSkin.removeFromParent(true);
                    nextSkin.disableSkin();
                }
            }
        }
        else
        {
            nextSkin = new NodeSkin(numSkins);
            numSkins++;
        }
        
        if (nextSkin != null)
        {
            activeGameNodeSkins[nextSkin.id] = nextSkin;
        }
        nextSkin.isDirty = true;
        return nextSkin;
    }
    
    public static function getColor(node : Node, edge : Edge = null) : Int
    //ask the node if it's a clause, and if it is, figure out if the end is wide or not
    {
        
        if (edge != null)
        {
            if (edge.graphConstraint.lhs.id.indexOf("c") == 0)
            {
                return WIDE_COLOR;
            }
            else
            {
                return NARROW_COLOR;
            }
        }
        if (!node.isNarrow)
        {
            return WIDE_COLOR;
        }
        else
        {
            return NARROW_COLOR;
        }
    }
    
    public static function getComplementColor(node : Dynamic) : Int
    {
        if (!node.isNarrow)
        {
            return WIDE_COLOR_COMPLEMENT;
        }
        else
        {
            return NARROW_COLOR_COMPLEMENT;
        }
    }
    
    public static function countKeys(myDictionary : Dynamic) : Int
    {
        var n : Int = 0;
        for (key in Reflect.fields(myDictionary))
        {
            n++;
        }
        return n;
    }
    
    public function new(numSkin : Int)
    {
        super();
        id = numSkin;
        
        if (mAtlas == null)
        {
            mAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
            DarkBlueCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableWide);
            LightBlueCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableNarrow);
            LightBlueSelectedCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableNarrowSelected);
            DarkBlueSelectedCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableWideSelected);
            UnsatisfiedConstraintTexture = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_ConstraintConflict);
            SatisfiedConstraintTexture = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_ConstraintCorrected);
            UnsatisfiedConstraintBackgroundTexture = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_Conflict);
        }
    }
    
    public function draw() : Void
    {
        if (!isDirty)
        {
            return;
        }
        isDirty = false;
        Starling.current.juggler.removeTweens(this);
        
        if (textureImage != null)
        {
            textureImage.removeFromParent(true);
        }
        if (constraintImage != null)
        {
            constraintImage.removeFromParent(true);
        }
        
        if (!isClause())
        {
            if (isNarrow() && isSelected())
            {
                textureImage = new Image(LightBlueSelectedCircle);
            }
            else if (!isNarrow() && isSelected())
            {
                textureImage = new Image(DarkBlueSelectedCircle);
            }
            else if (!isNarrow())
            {
                textureImage = new Image(DarkBlueCircle);
            }
            // narrow, unselected
            else
            {
                
                {
                    textureImage = new Image(LightBlueCircle);
                }
            }
            
            //if(isSolved() && isSelected())
            //{
            //textureImage.setVertexColor(0, 0x00ff00);
            //textureImage.setVertexColor(1, 0x00ff00);
            //textureImage.setVertexColor(2, 0x00ff00);
            //textureImage.setVertexColor(3, 0x00ff00);
            //}
            //else
            //{
            //textureImage.setVertexColor(0, 0xffffff);
            //textureImage.setVertexColor(1, 0xffffff);
            //textureImage.setVertexColor(2, 0xffffff);
            //textureImage.setVertexColor(3, 0xffffff);
            //}
            
            textureImage.width = textureImage.height = 14;
            textureImage.x = -textureImage.width / 2;
            textureImage.y = -textureImage.width / 2;
            addChild(textureImage);
        }
        // Is clause
        else
        {
            
            if (hasError())
            {
                if (isBackground)
                {
                    constraintImage = new Image(UnsatisfiedConstraintBackgroundTexture);
                    constraintImage.width = constraintImage.height = 40;
                }
                else
                {
                    constraintImage = new Image(UnsatisfiedConstraintTexture);
                    constraintImage.width = constraintImage.height = 10;
                }
            }
            else
            {
                if (isBackground)
                {
                    return;
                }  // no background image for satisfied conflicts  
                constraintImage = new Image(SatisfiedConstraintTexture);
                constraintImage.width = constraintImage.height = 10;
            }
            constraintImage.x = -constraintImage.width / 2;
            constraintImage.y = -constraintImage.width / 2;
            addChild(constraintImage);
        }
    }
    
    override public function dispose() : Void
    {
        Starling.current.juggler.removeTweens(this);
        if (textureImage != null)
        {
            textureImage.removeFromParent(true);
        }
        if (constraintImage != null)
        {
            constraintImage.removeFromParent(true);
        }
        alpha = scaleX = scaleY = 1;
        removeChildren(0, -1, true);
        super.dispose();
    }
    
    public function disableSkin() : Void
    {
        availableGameNodeSkins.push(this);
		activeGameNodeSkins.remove(id);
    }
    
    override public function removeChild(_child : DisplayObject, dispose : Bool = false) : DisplayObject
    {
        return super.removeChild(_child, dispose);
    }
    
    public function setNodeProps(_isClause : Bool = false,
            _isNarrow : Bool = false,
            _isSelected : Bool = false,
            _isSolved : Bool = false,
            _hasError : Bool = false,
            _isBackground : Bool = false) : Void
    {
        m_isClause = _isClause;
        m_isNarrow = _isNarrow;
        m_isSelected = _isSelected;
        m_isSolved = _isSolved;
        m_hasError = _hasError;
        isBackground = _isBackground;
        isDirty = true;
    }
    
    public function customScale(newScale : Float) : Void
    {
        var currentWidth : Float;
        var newWidth : Float;
        if (textureImage != null)
        {
            textureImage.scaleX = textureImage.scaleY = newScale;
            newWidth = XMath.clamp(textureImage.width, 5, 50);
            textureImage.width = textureImage.height = newWidth;
            textureImage.x = -newWidth / 2;
            textureImage.y = -newWidth / 2;
        }
        if (constraintImage != null)
        {
            constraintImage.scaleX = constraintImage.scaleY = newScale;
            newWidth = XMath.clamp(constraintImage.width, (isBackground) ? 10 : 5, (isBackground) ? 500 : 50);
            constraintImage.width = constraintImage.height = newWidth;
            constraintImage.x = -newWidth / 2;
            constraintImage.y = -newWidth / 2;
        }
    }
    
    // --- INodeProps --->
    private var m_isClause : Bool = false;
    private var m_isNarrow : Bool = false;
    private var m_isSelected : Bool = false;
    private var m_isSolved : Bool = false;
    private var m_hasError : Bool = false;
    public function isClause() : Bool
    {
        return m_isClause;
    }
    public function isNarrow() : Bool
    {
        return m_isNarrow;
    }
    public function isSelected() : Bool
    {
        return m_isSelected;
    }
    public function isSolved() : Bool
    {
        return m_isSolved;
    }
    public function hasError() : Bool
    {
        return m_hasError;
    }
}
