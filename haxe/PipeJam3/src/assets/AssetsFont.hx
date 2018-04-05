package assets;


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
    
    
    public static inline var FONT_DEFAULT : String = "Vegur";
    public static inline var FONT_FRACTION : String = "Bebas";
    public static inline var FONT_NUMERIC : String = "DenkOne";
    public static inline var FONT_METAL : String = "MetalMania";
    public static inline var FONT_BANGERS : String = "Bangers";
    public static inline var FONT_SPECIAL_ELITE : String = "SpecialElite";
    public static inline var FONT_UBUNTU : String = "UbuntuTitlingBold";

    public function new()
    {
    }
}

