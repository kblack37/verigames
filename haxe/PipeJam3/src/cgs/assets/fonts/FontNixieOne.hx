package cgs.assets.fonts;

import flash.text.Font;

//Force compilier to use specific class for embed otherwise mx.core.FontAsset is used.
@:meta(Embed(source="../../../../assets/font/NixieOne-Regular.otf",fontFamily="NixieOne",embedAsCFF="false",mimeType="application/x-font"))

@:final class FontNixieOne extends Font
{
    public function new()
    {
        super();
    }
}
