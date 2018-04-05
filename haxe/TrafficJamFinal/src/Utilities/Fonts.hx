package utilities;


class Fonts
{
    @:meta(Embed(source="/../lib/assets/font/Vegur-R 0.602.otf",fontFamily="Vegur",embedAsCFF="false",mimeType="application/x-font"))
private static var FontVegur : Class<Dynamic>;
    @:meta(Embed(source="/../lib/assets/font/BEBAS___.TTF",fontFamily="Bebas",embedAsCFF="false",mimeType="application/x-font"))
private static var FontBebas : Class<Dynamic>;
    
    public static inline var FONT_DEFAULT : String = "Vegur";
    public static inline var FONT_FRACTION : String = "Bebas";

    public function new()
    {
    }
}

