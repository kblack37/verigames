package assets;
import openfl.Assets;
import openfl.text.Font;


class AssetsFont
{
    @:meta(Embed(source="../../lib/assets/font/Vegur-R 0.602.otf",fontFamily="Vegur",embedAsCFF="false",mimeType="application/x-font"))
private static var FontVegur : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/font/BEBAS___.TTF",fontFamily="Bebas",embedAsCFF="false",mimeType="application/x-font"))
private static var FontBebas : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/font/Denk_One/DenkOne-Regular.ttf",fontFamily="DenkOne",embedAsCFF="false",mimeType="application/x-font"))
private static var FontDenkOne : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/font/Metal_Mania/MetalMania-Regular.ttf",fontFamily="MetalMania",embedAsCFF="false",mimeType="application/x-font"))
private static var FontMetalMania : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/font/Bangers/Bangers.ttf",fontFamily="Bangers",embedAsCFF="false",mimeType="application/x-font"))
private static var FontBangers : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/font/Special_Elite/SpecialElite.ttf",fontFamily="SpecialElite",embedAsCFF="false",mimeType="application/x-font"))
private static var FontSpecialElite : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/font/UbuntuTitling-Bold.ttf",fontFamily="UbuntuTitlingBold",embedAsCFF="false",mimeType="application/x-font"))
private static var FontUbuntuTitlingBold : Class<Dynamic>;
    
    public static function getFont(filePath : String, name : String) : Font
    {
        var font : Font = Assets.getFont(filePath + "/" + name);
        return font;
    }
    public static  var FONT_DEFAULT : Font = getFont("fonts","Vegur-R 0.602.otf");
    public static  var FONT_FRACTION : Font = getFont("fonts","BEBAS_.ttf");
    public static  var FONT_NUMERIC : Font = getFont("fonts/Denk_One","DenkOne-Regular.otf");
    public static  var FONT_METAL : Font = getFont("fonts/Metal_Mania","MetalMania-Regular.ttf");
    public static  var FONT_BANGERS : Font = getFont("fonts/Banger","Bangers.otf");
    public static  var FONT_SPECIAL_ELITE : Font = getFont("fonts/Special_Elite","SpecialElite");
    public static  var FONT_UBUNTU : Font = getFont("fonts","UbuntuTitling-Bold.otf");

    public function new()
    {
    }
}

