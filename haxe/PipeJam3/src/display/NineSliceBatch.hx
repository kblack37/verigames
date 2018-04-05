package display;

import starling.display.Image;
import starling.textures.TextureAtlas;
import starling.display.Sprite;

class NineSliceBatch extends Sprite
{
    public var color(never, set) : Int;

    private var mWidth : Float;
    private var mHeight : Float;
    private var mCx : Float;
    private var mCy : Float;
    
    private var mAtlas : TextureAtlas;
    
    private var mTopLeft : Image;
    private var mTop : Image;
    private var mTopRight : Image;
    private var mLeft : Image;
    private var mCenter : Image;
    private var mRight : Image;
    private var mBottomLeft : Image;
    private var mBottom : Image;
    private var mBottomRight : Image;
    
    private var mUseTopLeft : Bool = true;private var mUseTop : Bool = true;private var mUseTopRight : Bool = true;
    private var mUseLeft : Bool = true;private var mUseCenter : Bool = true;private var mUseRight : Bool = true;
    private var mUseBottomLeft : Bool = true;private var mUseBottom : Bool = true;private var mUseBottomRight : Bool = true;
    
    /* created by World and set before first nineslice created. */
    public static var gameObjectBatch : GameObjectBatch;
    
    public function new(_width : Float, _height : Float, _cX : Float, _cY : Float,
            _atlas : TextureAtlas, _atlasXMLTexturePrefix : String)
    {
        super();
        mWidth = _width;
        mHeight = _height;
        mCx = Math.min(_cX, mWidth / 2.0);  // can't be > half the width  
        mCy = Math.min(_cY, mHeight / 2.0);  // can't be > half the height  
        
        mAtlas = _atlas;
        
        mTopLeft = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.TOP_LEFT));
        mTop = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.TOP));
        mTopRight = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.TOP_RIGHT));
        mLeft = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.LEFT));
        mCenter = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.CENTER));
        mRight = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.RIGHT));
        mBottomLeft = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.BOTTOM_LEFT));
        mBottom = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.BOTTOM));
        mBottomRight = new Image(mAtlas.getTexture(_atlasXMLTexturePrefix + Constants.BOTTOM_RIGHT));
        
        updateX();
        updateY();
        updateWidth();
        updateHeight();
        
        addImages();
    }
    
    private function updateX() : Void
    {
        mTopLeft.x = mLeft.x = mBottomLeft.x = 0;
        mTop.x = mCenter.x = mBottom.x = mCx;
        mTopRight.x = mRight.x = mBottomRight.x = mWidth - mCx;
    }
    
    private function updateY() : Void
    {
        mTop.y = mTopLeft.y = mTopRight.y = 0;
        mLeft.y = mCenter.y = mRight.y = mCy;
        mBottomLeft.y = mBottom.y = mBottomRight.y = mHeight - mCy;
    }
    
    private function updateWidth() : Void
    {
        mTopLeft.width = mLeft.width = mBottomLeft.width = mCx;
        mTop.width = mCenter.width = mBottom.width = mWidth - 2 * mCx;
        mTopRight.width = mRight.width = mBottomRight.width = mCx;
    }
    
    private function updateHeight() : Void
    {
        mTop.height = mTopLeft.height = mTopRight.height = mCy;
        mLeft.height = mCenter.height = mRight.height = mHeight - 2 * mCy;
        mBottomLeft.height = mBottom.height = mBottomRight.height = mCy;
    }
    
    public function adjustSizes(newWidth : Float, newHeight : Float, newCx : Float, newCy : Float) : Void
    {
        mWidth = newWidth;
        mHeight = newHeight;
        mCx = newCx;
        mCy = newCy;
        
        updateX();
        updateY();
        updateWidth();
        updateHeight();
    }
    
    private function set_color(col : Int) : Int
    {
        if (mTopLeft != null)
        {
            mTopLeft.color = col;
        }
        if (mTop != null)
        {
            mTop.color = col;
        }
        if (mTopRight != null)
        {
            mTopRight.color = col;
        }
        if (mLeft != null)
        {
            mLeft.color = col;
        }
        if (mCenter != null)
        {
            mCenter.color = col;
        }
        if (mRight != null)
        {
            mRight.color = col;
        }
        if (mBottomLeft != null)
        {
            mBottomLeft.color = col;
        }
        if (mBottom != null)
        {
            mBottom.color = col;
        }
        if (mBottomRight != null)
        {
            mBottomRight.color = col;
        }
        addImages();
        return col;
    }
    
    public function adjustUsedSlices(useTopLeft : Bool = true, useTop : Bool = true, useTopRight : Bool = true,
            useLeft : Bool = true, useCenter : Bool = true, useRight : Bool = true,
            useBottomLeft : Bool = true, useBottom : Bool = true, useBottomRight : Bool = true) : Void
    {
        mUseTopLeft = useTopLeft;
        mUseTop = useTop;
        mUseTopRight = useTopRight;
        mUseLeft = useLeft;
        mUseCenter = useCenter;
        mUseRight = useRight;
        mUseBottomLeft = useBottomLeft;
        mUseBottom = useBottom;
        mUseBottomRight = useBottomRight;
        addImages();
    }
    
    private function addImages() : Void
    {
        if (mUseTopLeft)
        {
            addImage(mTopLeft);
        }
        if (mUseTop)
        {
            addImage(mTop);
        }
        if (mUseTopRight)
        {
            addImage(mTopRight);
        }
        if (mUseLeft)
        {
            addImage(mLeft);
        }
        if (mUseCenter)
        {
            addImage(mCenter);
        }
        if (mUseRight)
        {
            addImage(mRight);
        }
        if (mUseBottomLeft)
        {
            addImage(mBottomLeft);
        }
        if (mUseBottom)
        {
            addImage(mBottom);
        }
        if (mUseRight)
        {
            addImage(mBottomRight);
        }
    }
    
    private function addImage(image : Image) : Void
    {
        this.addChild(image);
        gameObjectBatch.addImage(image);
    }
}

