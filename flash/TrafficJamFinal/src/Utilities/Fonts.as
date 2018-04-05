package Utilities
{
	public class Fonts
	{
		[Embed(source="/../lib/assets/font/Vegur-R 0.602.otf", fontFamily="Vegur", embedAsCFF="false", mimeType="application/x-font")] private static const FontVegur:Class;
		[Embed(source="/../lib/assets/font/BEBAS___.TTF", fontFamily="Bebas", embedAsCFF="false", mimeType="application/x-font")] private static const FontBebas:Class;
		
		public static const FONT_DEFAULT:String   = "Vegur";
		public static const FONT_FRACTION:String  = "Bebas";
	}
}
