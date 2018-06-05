package scripts;

import engine.scripting.ScriptNode;
import engine.IGameEngine;
import networking.Achievements;
/**
 * ...
 * @author ...
 */
class WorldClashClearScript extends ScriptNode 
{

	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		
		gameEngine.addEventListener(Achievements.CLASH_CLEARED_ID, checkClashClearedEvent);
	}
	private function checkClashClearedEvent() : Void
    {
        if (active_level != null && active_level.m_targetScore != 0)
        {
            Achievements.checkAchievements(Achievements.CLASH_CLEARED_ID, 0);
        }
    }
}