package cgs.assets.fonts;

import flash.text.Font;

//Force compilier to use specific class for embed otherwise mx.core.FontAsset is used.
@:meta(Embed(source="../../../../assets/font/Vegur-R 0.602.otf",fontFamily="Vegur",embedAsCFF="false",mimeType="application/x-font"))

@:final class FontVegur extends Font
{
    public function new()
    {
        super();
    }
}
