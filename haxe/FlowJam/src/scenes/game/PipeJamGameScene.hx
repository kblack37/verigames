package scenes.game;

import flash.errors.Error;
import flash.events.Event;
import flash.utils.Dictionary;
import starling.display.*;
import starling.events.Event;
import networking.*;
import scenes.game.display.ReplayWorld;
import scenes.game.display.World;
import scenes.Scene;
import state.ParseConstraintGraphState;

class PipeJamGameScene extends Scene
{
    private var nextParseState : ParseConstraintGraphState;
    
    //takes a partial path to the files, using the base file name. -.json, -Layout.json and -Constraints.json will be assumed
    //we could obviously change it back, but this is the standard use case
    public static var demoArray : Array<Dynamic> = ["../SampleWorlds/L21374_V102"]; //L21414_V17680  );
    
    public static inline var DEBUG_PLAY_WORLD_ZIP : String = "";  // "../lib/levels/bonus/bonus.zip";  
    
    public static var inTutorial : Bool = false;
    public static var inDemo : Bool = false;
    public static var levelContinued : Bool = false;
    
    
    private var m_worldObj : Dynamic;
    private var m_layoutObj : Dynamic;
    private var m_assignmentsObj : Dynamic;
    
    private var m_layoutLoaded : Bool = false;
    private var m_assignmentsLoaded : Bool = false;
    private var m_worldLoaded : Bool = false;
    
    /** Start button image */
    private var start_button : Button;
    private var active_world : World;
    private var m_worldGraphDict : Dynamic;
    
    public function new(game : PipeJamGame)
    {
        super(game);
    }
    
    override private function addedToStage(event : starling.events.Event) : Void
    {
        super.addedToStage(event);
        m_layoutLoaded = m_worldLoaded = m_assignmentsLoaded = false;
        GameFileHandler.loadGameFiles(onWorldLoaded, onLayoutLoaded, onConstraintsLoaded);
    }
    
    override private function removedFromStage(event : starling.events.Event) : Void
    {
        removeChildren(0, -1, true);
        active_world = null;
    }
    
    private function onLayoutLoaded(_layoutObj : Dynamic) : Void
    {
        m_layoutObj = _layoutObj;
        m_layoutLoaded = true;
        checkTasksComplete();
    }
    
    private function onConstraintsLoaded(_assignmentsObj : Dynamic) : Void
    {
        m_assignmentsObj = _assignmentsObj;
        m_assignmentsLoaded = true;
        checkTasksComplete();
    }
    
    //might be a single xml file, or maybe an array of three xml files
    private function onWorldLoaded(obj : Dynamic) : Void
    {
        if (Std.is(obj, Array))
        {
            m_worldObj = (try cast(obj, Array<Dynamic>) catch(e:Dynamic) null)[0];
            m_assignmentsObj = (try cast(obj, Array<Dynamic>) catch(e:Dynamic) null)[1];
            m_layoutObj = (try cast(obj, Array<Dynamic>) catch(e:Dynamic) null)[2];
            m_assignmentsLoaded = true;
            m_layoutLoaded = true;
        }
        else
        {
            m_worldObj = obj;
        }
        m_worldLoaded = true;
        checkTasksComplete();
    }
    
    public function parseJson() : Void
    {
        if (nextParseState != null)
        {
            nextParseState.removeFromParent();
        }
        nextParseState = new ParseConstraintGraphState(m_worldObj);
        addChild(nextParseState);  //to allow done parsing event to be caught  
        this.addEventListener(ParseConstraintGraphState.WORLD_PARSED, worldComplete);
        nextParseState.stateLoad();
    }
    
    public function worldComplete(event : starling.events.Event) : Void
    {
        m_worldGraphDict = event.data;
        m_worldLoaded = true;
        this.removeEventListener(ParseConstraintGraphState.WORLD_PARSED, worldComplete);
        onWorldParsed();
    }
    
    public function checkTasksComplete() : Void
    {
        if (m_layoutLoaded && m_worldLoaded && m_assignmentsLoaded)
        {
            trace("everything loaded");
            parseJson();
        }
    }
    
    private function onWorldParsed() : Void
    {
        if (nextParseState != null)
        {
            nextParseState.removeFromParent();
        }
        try
        {
            PipeJamGame.printDebug("Creating World...");
            if (PipeJam3.REPLAY_DQID != null)
            {
                active_world = new ReplayWorld(m_worldGraphDict, m_worldObj, m_layoutObj, m_assignmentsObj);
            }
            else
            {
                active_world = new World(m_worldGraphDict, m_worldObj, m_layoutObj, m_assignmentsObj);
            }
        }
        catch (error : Error)
        {
            throw new Error("ERROR: " + error.message + "\n" + (try cast(error, Error) catch(e:Dynamic) null).getStackTrace());
        }
        addChild(active_world);
    }
}
