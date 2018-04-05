package scenes.game.components;

import display.TextBubbleFollowComponent;
import scenes.game.display.Level;
import scenes.game.display.TutorialManagerTextInfo;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;

class TutorialText extends TextBubbleFollowComponent
{
    private static inline var TUTORIAL_FONT_SIZE : Float = 10;
    private static inline var ARROW_SZ : Float = 10;
    private static inline var ARROW_BOUNCE : Float = 2;
    private static inline var ARROW_BOUNCE_SPEED : Float = 0.5;
    private static inline var INSET : Float = 3;
    
    public function new(level : Level, info : TutorialManagerTextInfo)
    {
        super(info.pointAtFn, level, info.text, TUTORIAL_FONT_SIZE, 0xEEEEEE, info.pointFrom, info.pointTo, info.size, ARROW_SZ, ARROW_BOUNCE, ARROW_BOUNCE_SPEED, INSET);
    }
}

