import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceButton;
import display.NineSliceToggleButton;

class ButtonFactory
{
    private static var m_instance : ButtonFactory;
    
    private static var BUTTON_TEXT_COLOR : Int = (PipeJam3.ASSET_SUFFIX) ? 0xFFFFFF : 0x4F2C12;
    private static var BUTTON_BACKGROUND_COLOR : Int = (PipeJam3.ASSET_SUFFIX) ? 0x0 : 0xF3D18D;
    
    public static function getInstance() : ButtonFactory
    {
        if (m_instance == null)
        {
            m_instance = new ButtonFactory(new SingletonLock());
        }
        return m_instance;
    }
    
    public function new(lock : SingletonLock)
    {
    }
    
    public function createDefaultButton(text : String, width : Float, height : Float) : NineSliceButton
    {
        return createButton(text, width, height, height / 3.0, height / 3.0);
    }
    
    public function createButton(text : String, width : Float, height : Float, cX : Float, cY : Float, toolTipText : String = "") : NineSliceButton
    {
        return new NineSliceButton(text, width, height, cX, cY, AssetInterface.PipeJamSpriteSheetAtlas, 
        AssetInterface.PipeJamSubTexture_MenuButtonPrefix, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR, 
        AssetInterface.PipeJamSubTexture_MenuButtonOverPrefix, AssetInterface.PipeJamSubTexture_MenuButtonSelectedPrefix, 
        0xFFFFFF, 0xFFFFFF, toolTipText);
    }
    
    public function createDefaultToggleButton(text : String, width : Float, height : Float, _toolTipText : String = "") : NineSliceToggleButton
    {
        return createToggleButton(text, width, height, width / 3.0, height / 3.0, _toolTipText);
    }
    
    public function createToggleButton(text : String, width : Float, height : Float, cX : Float, cY : Float, _toolTipText : String = "") : NineSliceToggleButton
    {
        return new NineSliceToggleButton(text, width, height, cX, cY, _toolTipText, AssetInterface.PipeJamSpriteSheetAtlas, 
        AssetInterface.PipeJamSubTexture_MenuButtonPrefix, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR, 
        AssetInterface.PipeJamSubTexture_MenuButtonOverPrefix, AssetInterface.PipeJamSubTexture_MenuButtonSelectedPrefix);
    }
    
    public function createTabButton(text : String, width : Float, height : Float, cX : Float, cY : Float, _toolTipText : String = "") : NineSliceToggleButton
    {
        return new NineSliceToggleButton(text, width, height, cX, cY, _toolTipText, AssetInterface.PipeJamLevelSelectAtlas, 
        "TabInactive", AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR, 
        "TabInactiveMouseover", "TabActive");
    }
    
    public function createImageButton(imageName : String, width : Float, height : Float, cX : Float, cY : Float) : NineSliceButton
    {
        return new NineSliceButton("", width, height, cX, cY, AssetInterface.ParadoxSpriteSheetAtlas, 
        "Button" + imageName, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR, 
        "Button" + imageName + "Over", "Button" + imageName + "Click");
    }
}


class SingletonLock
{

    @:allow()
    private function new()
    {
    }
}  // to prevent outside construction of singleton  
