package cgs.assets.fonts;

import flash.text.Font;

//Force compilier to use specific class for embed otherwise mx.core.FontAsset is used.
@:meta(Embed(source="../../../../assets/font/ROBOTO-REGULAR.TTF",fontFamily="Roboto",embedAsCFF="false",mimeType="application/x-font"))

@:final class FontRoboto extends Font
{
    public function new()
    {
        super();
    }
}
