package events;

import scenes.game.display.TutorialManagerTextInfo;
import starling.events.Event;

class TutorialEvent extends Event
{
    public static inline var SHOW_CONTINUE : String = "SHOW_CONTINUE";
    public static inline var HIGHLIGHT_BOX : String = "HIGHLIGHT_BOX";
    public static inline var HIGHLIGHT_EDGE : String = "HIGHLIGHT_EDGE";
    public static inline var HIGHLIGHT_PASSAGE : String = "HIGHLIGHT_PASSAGE";
    public static inline var HIGHLIGHT_CLASH : String = "HIGHLIGHT_CLASH";
    public static inline var HIGHLIGHT_SCOREBLOCK : String = "HIGHLIGHT_SCOREBLOCK";
    public static inline var NEW_TUTORIAL_TEXT : String = "NEW_TUTORIAL_TEXT";
    public static inline var NEW_TOOLTIP_TEXT : String = "NEW_TOOLTIP_TEXT";
    
    public var componentId : String;
    public var highlightOn : Bool;
    public var newTextInfo : Array<TutorialManagerTextInfo>;
    
    public function new(_type : String, _componentId : String = "", _highlightOn : Bool = true, _newTextInfo : Array<TutorialManagerTextInfo> = null)
    {
        super(_type, true);
        componentId = _componentId;
        highlightOn = _highlightOn;
        newTextInfo = _newTextInfo;
        if (newTextInfo == null)
        {
            newTextInfo = new Array<TutorialManagerTextInfo>();
        }
    }
}

