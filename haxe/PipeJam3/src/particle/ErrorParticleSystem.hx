package particle;

import flash.utils.Dictionary;
import starling.display.Quad;
import starling.extensions.ColorArgb;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;
import utils.PropDictionary;

class ErrorParticleSystem extends Sprite
{
    @:meta(Embed(source="../../lib/assets/particle/error.pex",mimeType="application/octet-stream"))

    private static var ErrorConfig : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/particle/error_particle.png"))

    private static var ErrorParticle : Class<Dynamic>;
    
    private static var errorInited : Bool = false;
    private static var errorConfig : FastXML;
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
            errorConfig = FastXML.parse(Type.createInstance(ErrorConfig, []));
            errorTexture = Texture.fromBitmap(Type.createInstance(ErrorParticle, []));
        }
        
        id = nextID++;
        mParticleSystem = new PDParticleSystem(errorConfig, errorTexture);
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
        Starling.juggler.add(mParticleSystem);
    }
    
    private function onRemovedFromStage(evt : Event) : Void
    {
        mParticleSystem.stop();
        mParticleSystem.removeFromParent();
        Starling.juggler.remove(mParticleSystem);
    }
}

