package particle;

import assets.AssetInterface;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

class FanfareParticleSystem extends Sprite
{
    public var particleX(get, set) : Float;
    public var particleY(get, set) : Float;

    private static var fanfareInited : Bool = false;
    private static var fanfareXML : Xml;
    private static var fanfareTexture : Texture;
    private var mParticleSystem : PDParticleSystem;
    
    public function new()
    {
        super();
        
        if (!fanfareInited)
        {
            fanfareXML = AssetInterface.getXml("img/particle", "fanfare.xml");
            fanfareTexture = AssetInterface.getTexture("img/particle", "fanfare_particle.png");
        }
        
        mParticleSystem = new PDParticleSystem(fanfareXML.toString(), fanfareTexture);
    }
    
    public function start() : Void
    {
        mParticleSystem.emitterX = 0;
        mParticleSystem.emitterY = 0;
        mParticleSystem.start();
        addChild(mParticleSystem);
        Starling.current.juggler.add(mParticleSystem);
    }
    
    private function get_particleX() : Float
    {
        return mParticleSystem.emitterX;
    }
    
    private function get_particleY() : Float
    {
        return mParticleSystem.emitterY;
    }
    
    private function set_particleX(value : Float) : Float
    {
        mParticleSystem.emitterX = value;
        return value;
    }
    
    private function set_particleY(value : Float) : Float
    {
        mParticleSystem.emitterY = value;
        return value;
    }
    
    public function stop() : Void
    {
        mParticleSystem.stop();
    }
    
    override public function dispose() : Void
    {
        mParticleSystem.removeFromParent(true);
        Starling.current.juggler.remove(mParticleSystem);
        super.dispose();
    }
}

