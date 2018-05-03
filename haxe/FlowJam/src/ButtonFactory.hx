import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceButton;
import display.NineSliceToggleButton;
import openfl.Assets;

class ButtonFactory
{
    private static var m_instance : ButtonFactory;
    
    public static inline var BUTTON_TEXT_COLOR : Int = 0x4F2C12;
    public static inline var BUTTON_BACKGROUND_COLOR : Int = 0xF3D18D;
    
    public static function getInstance() : ButtonFactory
    {
        if (m_instance == null)
        {
            m_instance = new ButtonFactory();
        }
        return m_instance;
    }
    
    public function new()
    {
    }
    
    public function createDefaultButton(text : String, width : Float, height : Float) : NineSliceButton
    {
        return createButton(text, width, height, height / 3.0, height / 3.0);
    }
    
    public function createButton(text : String, width : Float, height : Float, cX : Float, cY : Float, toolTipText : String = "") : NineSliceButton
    {
        return new NineSliceButton(text, width, height, cX, cY, "atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml", 
        AssetInterface.PipeJamSubTexture_MenuButtonPrefix, Assets.getFont("fonts/UbuntuTitling-Bold.otf"), BUTTON_TEXT_COLOR, 
        AssetInterface.PipeJamSubTexture_MenuButtonOverPrefix, AssetInterface.PipeJamSubTexture_MenuButtonSelectedPrefix, 
        0xFFFFFF, 0xFFFFFF, toolTipText);
    }
    
    public function createDefaultToggleButton(text : String, width : Float, height : Float) : NineSliceToggleButton
    {
        return createToggleButton(text, width, height, height / 3.0, height / 3.0);
    }
    
    public function createToggleButton(text : String, width : Float, height : Float, cX : Float, cY : Float) : NineSliceToggleButton
    {
        return new NineSliceToggleButton(text, width, height, cX, cY, "atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml", 
        AssetInterface.PipeJamSubTexture_MenuButtonPrefix, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR, 
        AssetInterface.PipeJamSubTexture_MenuButtonOverPrefix, AssetInterface.PipeJamSubTexture_MenuButtonSelectedPrefix);
    }
    
    public function createTabButton(text : String, width : Float, height : Float, cX : Float, cY : Float) : NineSliceToggleButton
    {
        return new NineSliceToggleButton(text, width, height, cX, cY, "Game", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml", 
        "TabInactive", AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR, 
        "TabInactiveMouseover", "TabActive");
    }
}