package particle;

import assets.AssetInterface;
import graph.PropDictionary;
import openfl.Assets;
import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.extensions.ColorArgb;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

class ErrorParticleSystem extends Sprite
{
    private static var errorInited : Bool = false;
    private static var errorConfig : Xml;
    public static var errorTexture : Texture;
    private var mParticleSystem : PDParticleSystem;
    private var mHitQuad : Quad;
    
    private static var nextID : Int = 0;
    public var id : Int;
    
    public function new(errorProps : PropDictionary = null)
    {
        super();
        
        if (!errorInited)
        {
            errorInited = true;
            errorConfig = AssetInterface.getXml("img/particle", "error.pex");
            errorTexture = AssetInterface.getTexture("img/particle", "error_particle.png");
        }
        
        id = nextID++;
        mParticleSystem = new PDParticleSystem(errorConfig.toString(), errorTexture);
        if (errorProps != null && !errorProps.hasProp(PropDictionary.PROP_NARROW))
        {
            for (prop in Reflect.fields(errorProps.iterProps()))
            {
                if (prop.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) == 0)
                {
                // If there's a MapGet error but no narrow error, change color
                    
                    // Original values:
                    //<startColor  red="1.00" green="0.18" blue="0.08" alpha="1.00"/>
                    //<finishColor red="0.90" green="0.16" blue="0.07" alpha="0.80"/>
                    mParticleSystem.startColor = new ColorArgb(1.0, 0.0, 1.0, 1.0);
                    mParticleSystem.endColor = new ColorArgb(1.0, 0.2, 0.2, 0.8);
                    break;
                }
            }
        }
        mHitQuad = new Quad(20, 10, 0xFFFFFF);
        mHitQuad.x = mHitQuad.y = -mHitQuad.width / 2.0;
        mHitQuad.alpha = 0;
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    
    private function onAddedToStage(evt : Event) : Void
    {
        addChild(mHitQuad);
        
        mParticleSystem.emitterX = 0;
        mParticleSystem.emitterY = 0;
        mParticleSystem.start();
        
        addChild(mParticleSystem);
        Starling.current.juggler.add(mParticleSystem);
    }
    
    private function onRemovedFromStage(evt : Event) : Void
    {
        mParticleSystem.stop();
        mParticleSystem.removeFromParent();
        Starling.current.juggler.remove(mParticleSystem);
    }
}

