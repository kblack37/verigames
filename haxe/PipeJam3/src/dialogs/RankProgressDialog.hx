package dialogs;

import assets.AssetInterface;
import assets.AssetsFont;
import dialogs.RankProgressDialogInfo;
import display.NineSliceButton;
import events.NavigationEvent;
import scenes.game.components.TutorialText;
import scenes.game.display.Level;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class RankProgressDialog extends TutorialText
{
    private var dialogInfo : RankProgressDialogInfo;
    
    public function new(level : Level, info : RankProgressDialogInfo, numLevelsSolved : Int)
    {
        super(level, info);
        dialogInfo = info;
        
        var progressContainer : Sprite = new Sprite();
        
        var backgroundProgressColor : Quad = new Quad(numLevelsSolved * 12.2, 12, 0xedd0ac);
        progressContainer.addChild(backgroundProgressColor);
        
        backgroundProgressColor.x = 1.5;
        backgroundProgressColor.y = 1;
        
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        var progressMarkerTexture : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ProgressMarkerPrefix);
        var progressMarkerImage : Image = new Image(progressMarkerTexture);
        progressContainer.addChild(progressMarkerImage);
        
        //from the center line
        progressContainer.x = (info.size.x - progressContainer.width) / 2 - info.size.x / 2;
        progressContainer.y = 24 - info.size.y / 2;
        
        
        this.addChild(progressContainer);
        
        if (info.button1String)
        {
            var button1 : NineSliceButton = ButtonFactory.getInstance().createButton(info.button1String, 25, 15, 8, 8);
            button1.addEventListener(starling.events.Event.TRIGGERED, onNextButtonTriggered);
            
            addChild(button1);
            button1.x = info.size.x / 2 - 8 - button1.width;
            button1.y = info.size.y / 2 - 8 - button1.height;
        }
        
        touchable = true;
        
        addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function onNextButtonTriggered() : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.GET_RANDOM_LEVEL));
    }
    
    public function closeDialog() : Void
    {
        removeFromParent();
    }
    
    private function onAddedToStage(event : starling.events.Event) : Void
    {
        removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
        Starling.juggler.tween(this, 2, {
                    delay : dialogInfo.fadeTimeSeconds,
                    alpha : 0,
                    transition : Transitions.EASE_IN
                });
    }
    
    //keep this, or else dialog placement changes
    override private function onEnterFrame(evt : Event) : Void
    {
    }
}
