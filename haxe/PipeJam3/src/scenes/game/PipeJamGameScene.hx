package scenes.game;

import flash.errors.Error;
import flash.utils.Dictionary;
import deng.fzip.FZipFile;
import networking.GameFileHandler;
import scenes.Scene;
import scenes.game.display.ReplayWorld;
import scenes.game.display.World;
import starling.display.Button;
import starling.events.Event;
import state.LoadingState;
import state.ParseConstraintGraphState;

class PipeJamGameScene extends Scene
{
    private var nextParseState : LoadingState;
    
    //takes a partial path to the files, using the base file name. -.json, -Layout.json and -Constraints.json will be assumed
    //we could obviously change it back, but this is the standard use case
    public static var demoArray : Array<Dynamic> = new Array<Dynamic>("../SampleWorlds/p_000108_v246839");
    //p_000267_00011256" //L1_V4"//p_002186_00001014");
    
    public static inline var DEBUG_PLAY_WORLD_ZIP : String = "";
    // "../lib/levels/bonus/bonus.zip"
    
    public static var inTutorial : Bool = false;
    public static var inDemo : Bool = false;
    public static var levelContinued : Bool = false;
    
    
    private var m_worldObj : Dynamic;
    private var m_layoutObj : Dynamic;
    private var m_assignmentsObj : Dynamic;
    
    private var m_layoutLoaded : Bool = false;
    private var m_assignmentsLoaded : Bool = false;
    private var m_worldLoaded : Bool = false;
    
    private var m_currentFileName : String;
    
    /** Start button image */
    private var start_button : Button;
    private var active_world : World;
    private var m_worldGraphDict : Dictionary;
    
    public static var startLoadTime : Float;
    
    public function new(game : PipeJamGame)
    {
        super(game);
    }
    
    override private function addedToStage(event : starling.events.Event) : Void
    {
        super.addedToStage(event);
        m_layoutLoaded = m_worldLoaded = m_assignmentsLoaded = false;
        startLoadTime = Date.now().getTime();
        GameFileHandler.loadGameFiles(onWorldLoaded, onLayoutLoaded, onConstraintsLoaded);
    }
    
    override private function removedFromStage(event : starling.events.Event) : Void
    {
        removeChildren(0, -1, true);
        active_world = null;
    }
    
    private function onLayoutLoaded(_layoutObj : Dynamic) : Void
    {
        if (Std.is(_layoutObj, FZipFile))
        {
            m_layoutObj = Std.string((try cast(_layoutObj, FZipFile) catch(e:Dynamic) null).content);
        }
        else
        {
            m_layoutObj = _layoutObj;
        }
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
        
        if (Std.is(obj, FZipFile))
        {
            m_assignmentsLoaded = true;
            m_currentFileName = (try cast(obj, FZipFile) catch(e:Dynamic) null).filename;
            m_worldObj = Std.string((try cast(obj, FZipFile) catch(e:Dynamic) null).content);
        }
        m_worldLoaded = true;
        checkTasksComplete();
    }
    
    
    public function parseCNF() : Void
    {
        parseWorldFile();
        parseLayoutFile();
    }
    
    private function parseWorldFile() : Void
    {
        var lineArray : Array<Dynamic> = m_worldObj.split("\n");
        var currentLine : Int = 0;
        while ((Std.string(lineArray[currentLine])).charAt(0) == "c")
        {
            currentLine++;
        }
        var countArray : Array<Dynamic> = lineArray[currentLine].split(" ");
        var numVars : Int = as3hx.Compat.parseInt(countArray[2]);
        var clauseCount : Int = as3hx.Compat.parseInt(countArray[3]);
        var weighted : Bool = false;
        if (countArray[1].charAt[0] == "w")
        {
            weighted = true;
        }
        
        m_worldObj = {
                    id : "L10823_V16",
                    version : 1,
                    scoring : {
                        variables : {
                            type0 : 0,
                            type1 : 1
                        },
                        constraints : 100
                    },
                    variables : { },
                    constraints : []
                };
        
        var constraintsArray : Array<Dynamic> = m_worldObj.constraints;
        for (index in currentLine + 1...lineArray.length)
        {
            var clauseArray : Array<Dynamic> = lineArray[index].split(" ");
            var lineIndex : Int = 0;
            var weight : Int = 100;
            if (weighted)
            {
                weight = as3hx.Compat.parseInt(clauseArray[lineIndex]);
            }
        }
    }
    
    private function parseLayoutFile() : Void
    {
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
        m_worldGraphDict = try cast(event.data, Dictionary) catch(e:Dynamic) null;
        m_worldLoaded = true;
        this.removeEventListener(ParseConstraintGraphState.WORLD_PARSED, worldComplete);
        onWorldParsed();
    }
    
    public function checkTasksComplete() : Void
    {
        if (m_layoutLoaded && m_worldLoaded && m_assignmentsLoaded)
        {
            if (Std.is(m_worldObj, String))
            {
                parseCNF();
            }
            else
            {
                parseJson();
            }
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
            if (PipeJam3.REPLAY_DQID)
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
        trace("Load Time", Date.now().getTime() - startLoadTime);
    }
}
