package cgs.utils;

import openfl.errors.Error;
import openfl.display.Stage;

class FlashContext
{
    public var containsUserId(get, never) : Bool;
    public var containsGradeLevel(get, never) : Bool;
    public var userId(get, never) : String;
    public var gradeLevel(get, never) : Int;
    public var containsEdmodoData(get, never) : Bool;
    public var edmodoData(get, never) : Dynamic;
    public var containsTeacherCode(get, never) : Bool;
    public var teacherCode(get, never) : String;

    public static inline var USERID_KEY : String = "uid";
    public static inline var TEACHER_CODE_KEY : String = "tc";
    public static inline var EDMODO_DATA_KEY : String = "data";
    public static inline var EDMODO_EXT_DATA_KEY : String = "ext_data";
    public static inline var GRADE_LEVEL_KEY : String = "grade";
    
    private var _flashVars : Dynamic;
    private var _domain : String;
    private var _url : String;
    
    private var _stage : Stage;
    
    public function new(stage : Stage)
    {
        if (stage == null)
        {
            throw new Error("Stage can not be null");
        }
        
        _stage = stage;
        _flashVars = _stage.root.loaderInfo.parameters;
        setDomain();
    }
    
    //Sets the url and the domain.
    private function setDomain() : Void
    {
        _url = _stage.root.loaderInfo.url;
        var domain : String = _url.split("/")[2];
        domain = (domain == null) ? "" : domain;
        if (domain.length == 0)
        {
            domain = "local";
        }
    }
    
    /**
		 * Indicates if the flash var with the given key name exists.
		 * 
		 * @param key the name for the flash var.
		 */
    public function containsFlashVar(key : String) : Bool
    {
        return Reflect.hasField(_flashVars, key);
    }
    
    /**
		 * Get the flash var with the given name. Will return null
		 * if there is no value for the given var name.
		 * 
		 * @param key the name of the flash var.
		 * @return * will be an Object or primitive type.
		 */
    public function getFlashVar(key : String) : Dynamic
    {
        return Reflect.field(_flashVars, key);
    }
    
    /**
		 * Indicates if there is a user id that should be used for the
		 * game in lieu of getting one from the server. This is used
		 * to handle K12 user ids.
		 */
    private function get_containsUserId() : Bool
    {
        return Reflect.hasField(_flashVars, USERID_KEY);
    }
    
    private function get_containsGradeLevel() : Bool
    {
        return Reflect.hasField(_flashVars, GRADE_LEVEL_KEY);
    }
    
    /**
		 * Get the user id that is contained within the flash vars.
		 * Will return null if no user id exists.
		 */
    private function get_userId() : String
    {
        return Reflect.field(_flashVars, USERID_KEY);
    }
    
    private function get_gradeLevel() : Int
    {
        var gradeLevel : Dynamic = Reflect.field(_flashVars, GRADE_LEVEL_KEY);
        if (Std.is(gradeLevel, String))
        {
            try
            {
                gradeLevel = Std.parseInt(gradeLevel);
            }
            catch (e : Error)
            {
            }
        }
        return gradeLevel;
    }
    
    private function get_containsEdmodoData() : Bool
    {
        return Reflect.hasField(_flashVars, EDMODO_EXT_DATA_KEY) && Reflect.hasField(_flashVars, EDMODO_DATA_KEY);
    }
    
    /**
		 * Get the both pieces of edmodo data in an object with the keys, 'data' and 'ext_data'.
		 */
    private function get_edmodoData() : Dynamic
    {
        return {
            EDMODO_DATA_KEY : Reflect.field(_flashVars, EDMODO_DATA_KEY),
            EDMODO_EXT_DATA_KEY : Reflect.field(_flashVars, EDMODO_EXT_DATA_KEY)
        };
    }
    
    /**
		 * Indicates if the flashvars contains a teacher code that should be used for login
		 * and registration.
		 */
    private function get_containsTeacherCode() : Bool
    {
        return Reflect.hasField(_flashVars, TEACHER_CODE_KEY);
    }
    
    /**
		 * Get the teacher code that is embedded in the flash vars.
		 * Will return null if no teacher code exists.
		 */
    private function get_teacherCode() : String
    {
        return Reflect.field(_flashVars, TEACHER_CODE_KEY);
    }
}
