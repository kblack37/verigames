package scripts;

import engine.scripting.ScriptNode;
import engine.IGameEngine;
import networking.Achievements;
import scenes.game.display.Level;
import state.FlowJamGameState;
/**
 * ...
 * @author ...
 */
class WorldClashClearScript extends ScriptNode 
{
	var active_level : Level
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		active_level = cast (gameEngine.getStateMachine().getCurrentState(),FlowJamGameState).getWorld().getActiveLevel();
		gameEngine.addEventListener(Achievements.CLASH_CLEARED_ID, checkClashClearedEvent);
	}
	
	private function checkClashClearedEvent() : Void
    {
        if (active_level != null && active_level.m_targetScore != 0)
        {
            Achievements.checkAchievements(Achievements.CLASH_CLEARED_ID, 0);
        }
    }
	
	public function override dispose(){
		super.dispose();
		gameEngine.removeEventListener(Achievements.CLASH_CLEARED_ID, checkClashClearedEvent);
	}
}