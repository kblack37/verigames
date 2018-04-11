package cgs.internationalization;

import openfl.Assets;
import haxe.xml.Fast;
import flash.utils.ByteArray;


@:final class XXML
{
    public static function xmlFromEmbeddedFile(embedPath : String) : Fast
    {
        var txt:String = Assets.getText(embedPath);
        var compacted:String = new EReg(">\\s*<", "g").replace(txt, "><");
        compacted = new EReg("\r\n", "g").replace(compacted, "");
        var xml = Xml.parse(compacted);
		var fast = new Fast(xml);
        return fast;
    }

    public function new()
    {
    }
}

