package cgs.levelProgression.util;


/**
	 * The ICgsLevelSelectResource is a place to store all level and level pack definitions in json.
	 * Having a common storage mechanism for levels/level packs allows levels/level packs to be determined 
	 * at compile time, at runtime, or during execution.
	 * 
	 * For example, new levels can be loaded from a database into the ICgsLevelSelectResource during execution
	 * then a level pack that uses these levels can be loaded into the ICgsLevelSelectResource and ILevelManager
	 * to allow them to be played by the utilizing game.
	 * @author Rich
	 */
interface ICgsLevelResourceManager
{

    
    /**
		 * Adds the given resource as the value with the given resourceName as the key to the ICgsLevelSelectResource.
		 * This will add the given resource, or replace the resource, at the resourceName.
		 * @param	resourceName - The name (key) of the resource being added.
		 * @param	resource - The resource (value) to be stored.
		 */
    function addResource(resourceName : String, resource : String) : Void
    ;
    
    /**
		 * Returns the json resource (value) stored under the given resourceName(key). If none is found, null will be returned.
		 * @param	resourceName - The name (key) of the resource being retrieved.
		 * @return
		 */
    function getResource(resourceName : String) : String
    ;
    
    /**
		 * Returns whether or not this ICgsLevelSelectResource has any data stored at the given resourceName(key).
		 * @param	resourceName - The name (key) of the resource being checked.
		 * @return
		 */
    function resourceExists(resourceName : String) : Bool
    ;
}

