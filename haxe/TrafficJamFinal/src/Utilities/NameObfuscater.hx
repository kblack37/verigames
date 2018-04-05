package utilities;

import flash.utils.Dictionary;
import visualWorld.Theme;

class NameObfuscater
{
    
    private static var color_names : Array<Dynamic> = [
        "Aqua", "Azure", "Blue", "Black", "Brown", "Coral", "Cyan", "Fuchsia", "Gray", "Green", "Indigo", "Ivory", "Khaki", "Lavendar", 
        "Lime", "Magenta", "Maroon", "Mint", "Navy", "Olive", "Orange", "Pink", "Plum", "Purple", "Red", "Salmon", "Silver", "Teal", 
        "Turquoise", "Violet", "White", "Yellow"
    ];
    
    private static var color_values : Array<Dynamic> = [
        0x7FFFD4  /*"Aqua"(-marine)*/  , 0xF0FFFF  /*Azure*/  , 0x0000FF  /*Blue*/  , 0x0  /*Black*/  , 0xA52A2A  /*Brown*/  , 0xFF7F50  /*Coral*/  , 0x00FFFF  /*Cyan*/  , 0xFF00FF  /*Fuchsia*/  , 0x808080  /*Gray*/  , 0x008000  /*Green*/  , 0x4B0082  /*Indigo*/  , 0xFFFFF0  /*Ivory*/  , 0xF0E68C  /*Khaki*/  , 0xE6E6FA  /*Lavendar*/  , 
        0x00FF00  /*Lime*/  , 0xFF00FF  /*Magenta*/  , 0x800000  /*Maroon*/  , 0xBBFFCC  /*Mint*/  , 0x000080  /*Navy*/  , 0x808000  /*Olive*/  , 0xFFA500  /*Orange*/  , 0xFFC0CB  /*Pink*/  , 0xDDA0DD  /*Plum*/  , 0x800080  /*Purple*/  , 0xFF0000  /*Red*/  , 0xFA8072  /*Salmon*/  , 0xC0C0C0  /*Silver*/  , 0x008080  /*Teal*/  , 
        0x40E0D0  /*Turquoise*/  , 0xEE82EE  /*Violet*/  , 0xFFFFFF  /*White*/  , 0xFFFF00  /*Yellow*/  
    ];
    
    private static var nature_nouns : Array<Dynamic> = [
        "Desert", "Canyon", "Clay", "Dunes", "Falls", "Forest", "Hills", "Lake", "Meadows", "Mountain", "Oak", "Peak", "Plains", "Plateau", 
        "Prairie", "River", "Shores", "Shrub", "Springs", "Stream", "Rock", "Valley", "Woods"
    ];
    
    private static var adjectives : Array<Dynamic> = [
        "Abandoned", "Bright", "Busy", "Calm", "Clear", "Cool", "Curious", "Cynical", "Dark", "Dashing", "Dazzling", "Dead", "Deep", "Defiant", 
        "Dizzy", "Dry", "Dusty", "Dynamic", "Early", "Electric", "Elite", "Empty", "False", "Famous", "Feeble", "Flat", "Frantic", "Friendly", 
        "Gentle", "Giant", "Gleaming", "Handsome", "Happy", "Harsh", "Heavy", "Hollow", "Hot", "Husky", "Immense", "Jagged", "Jolly", "Keen", 
        "Kindly", "Large", "Little", "Long", "Loud", "Lovely", "Lucky", "Macho", "Mad", "Marvelous", "Mellow", "Misty", "Murky", "New", "Nifty", 
        "Noisy", "Normal", "Odd", "Old", "Optimal", "Pale", "Perfect", "Placid", "Polite", "Precious", "Pretty", "Prickly", "Proud", "Quick", 
        "Quiet", "Rainy", "Rapid", "Regular", "Rich", "Rough", "Rural", "Rustic", "Salty", "Secret", "Shaggy", "Sharp", "Shiny", "Shy", "Silent", 
        "Simple", "Slim", "Slow", "Small", "Smooth", "Soft", "Sore", "Spiffy", "Stale", "Steady", "Steep", "Stormy", "Sturdy", "Super", "Sweet", 
        "Swift", "Tall", "Teeny", "Tense", "Terrific", "Thirsty", "Tidy", "Tiny", "Tough", "Tricky", "Ultra", "Unique", "Useful", "Vague", "Vast", 
        "Verdant", "Wacky", "Warm", "Weary", "Wide", "Witty", "Young"
    ];
    
    private static var place_suffixes : Array<Dynamic> = [
        "boro", "City", "Corner", "Depot", "ford", "ham", "Hamlet", "Junction", "mount", "Park", "Port", "Station", "ton", "Town", "Village", "ville"
    ];
    
    private var rand : PMPRNG;
    
    private var level_prefix_array : Array<Dynamic>;
    private var level_suffix_array : Array<Dynamic>;
    private var board_prefix_array : Array<Dynamic>;
    private var board_suffix_array : Array<Dynamic>;
    
    private var current_theme : String;
    
    /** If we manage to get through more than one entire dictionary of possible names, start numbering (i.e. BlueCanyon1, etc) */
    private var level_name_iteration : Int = 0;
    
    /** If we manage to get through more than one entire dictionary of possible names, start numbering (i.e. BlueCanyon1, etc) */
    private var board_name_iteration : Int = 0;
    
    /** A list of all prefix indices with at least one available suffix pair */
    private var available_level_prefix_indices : Array<Int>;
    
    /** A Dictionary of Vector.<uint> representing unused suffixes for the given prefix key */
    private var level_prefix_available_suffix_indices : Dictionary;
    
    /** A list of all prefix indices with at least one available suffix pair */
    private var available_board_prefix_indices : Array<Int>;
    
    /** A Dictionary of Vector.<uint> representing unused suffixes for the given prefix key */
    private var board_prefix_available_suffix_indices : Dictionary;
    
    /** Dictionaries from original_names -> obfuscated_names */
    public var obfuscatedLevelNameDictionary : Dictionary = new Dictionary();
    public var obfuscatedBoardNameDictionary : Dictionary = new Dictionary();
    
    public var reverseObfuscatedLevelNameDictionary : Dictionary = new Dictionary();
    public var reverseObfuscatedBoardNameDictionary : Dictionary = new Dictionary();
    
    /** Dictionary from original_names -> colors (valid if using color_names) */
    public var namesToColorsDictionary : Dictionary = new Dictionary();
    
    public function new(_seed : Int)
    {
        rand = new PMPRNG(_seed);
        init();
    }
    
    public function init() : Void
    {
        var _sw0_ = (Theme.CURRENT_THEME);        

        switch (_sw0_)
        {
            case Theme.PIPES_THEME, Theme.TRAFFIC_THEME:
                level_prefix_array = color_names;
                level_suffix_array = nature_nouns;
                board_prefix_array = adjectives;
                board_suffix_array = place_suffixes;
        }
        current_theme = Theme.CURRENT_THEME;
        setupLevelNames();
        setupBoardNames();
    }
    
    private function setupLevelNames() : Void
    {
        available_level_prefix_indices = new Array<Int>();
        level_prefix_available_suffix_indices = new Dictionary();
        var prefix_i : Int = 0;
        for (my_level_prefix in level_prefix_array)
        {
            available_level_prefix_indices.push(prefix_i);
            var my_avail_indx : Array<Int> = new Array<Int>();
            for (i in 0...level_suffix_array.length)
            {
                my_avail_indx.push(i);
            }
            Reflect.setField(level_prefix_available_suffix_indices, Std.string(my_level_prefix), my_avail_indx);
            prefix_i++;
        }
    }
    
    private function setupBoardNames() : Void
    {
        available_board_prefix_indices = new Array<Int>();
        board_prefix_available_suffix_indices = new Dictionary();
        var prefix_i : Int = 0;
        for (my_board_prefix in board_prefix_array)
        {
            available_board_prefix_indices.push(prefix_i);
            var my_avail_indx : Array<Int> = new Array<Int>();
            for (i in 0...board_suffix_array.length)
            {
                my_avail_indx.push(i);
            }
            Reflect.setField(board_prefix_available_suffix_indices, Std.string(my_board_prefix), my_avail_indx);
            prefix_i++;
        }
    }
    
    public function boardNameExists(_original_board_name : String) : Bool
    {
        return (Reflect.field(obfuscatedBoardNameDictionary, _original_board_name) != null);
    }
    
    public function getBoardName(_original_board_name : String, _original_level_name : String) : String
    {
        if (Reflect.field(obfuscatedBoardNameDictionary, _original_board_name) != null)
        {
            return Reflect.field(obfuscatedBoardNameDictionary, _original_board_name);
        }
        var my_board_name : String = getNextBoardName();
        var my_level_name : String = getLevelName(_original_level_name);
        var newBoardName : String = my_level_name + "." + my_board_name;
        Reflect.setField(obfuscatedBoardNameDictionary, _original_board_name, newBoardName);
        Reflect.setField(reverseObfuscatedBoardNameDictionary, newBoardName, _original_board_name);
        return Reflect.field(obfuscatedBoardNameDictionary, _original_board_name);
    }
    
    public function getReverseBoardName(obfuscatedName : String) : String
    {
        return Reflect.field(reverseObfuscatedBoardNameDictionary, obfuscatedName);
    }
    
    public function getLevelName(_original_level_name : String) : String
    {
        if (Reflect.field(obfuscatedLevelNameDictionary, _original_level_name) != null)
        {
            return Reflect.field(obfuscatedLevelNameDictionary, _original_level_name);
        }
        var newName : String = getNextLevelName();
        Reflect.setField(obfuscatedLevelNameDictionary, _original_level_name, newName);
        Reflect.setField(reverseObfuscatedLevelNameDictionary, newName, _original_level_name);
        return Reflect.field(obfuscatedLevelNameDictionary, _original_level_name);
    }
    
    public function getReverseLevelName(obfuscatedName : String) : String
    {
        return Reflect.field(reverseObfuscatedLevelNameDictionary, obfuscatedName);
    }
    
    private function getNextLevelName() : String
    {
        if ((available_level_prefix_indices == null) || (current_theme != Theme.CURRENT_THEME))
        
        // Obfuscator hasn't been initialized{
            
            init();
        }
        if (available_level_prefix_indices.length == 0)
        {
            level_name_iteration++;
            setupLevelNames();
        }
        var level_prefix_indx : Int = rand.nextIntRange(0, available_level_prefix_indices.length - 1);
        var level_prefix : String = Reflect.field(level_prefix_array, Std.string(available_level_prefix_indices[level_prefix_indx]));
        var available_suffix_indx : Array<Int> = (try cast(Reflect.field(level_prefix_available_suffix_indices, level_prefix), Array/*Vector.<T> call?*/) catch(e:Dynamic) null);
        if ((available_suffix_indx != null) && (available_suffix_indx.length > 0))
        {
            var level_suffix_indx : Int = rand.nextIntRange(0, available_suffix_indx.length - 1);
            var level_suffix : String = Reflect.field(level_suffix_array, Std.string(available_suffix_indx[level_suffix_indx]));
            var num : String = "";
            if (level_name_iteration > 0)
            {
                num = Std.string(level_name_iteration);
            }
            return level_prefix + level_suffix + num;
        }
        else
        {
            available_level_prefix_indices.splice(Lambda.indexOf(available_level_prefix_indices, level_prefix_indx), 1);
            return getNextLevelName();
        }
    }
    
    private function getNextBoardName() : String
    {
        if ((available_level_prefix_indices == null) || (current_theme != Theme.CURRENT_THEME))
        
        // Obfuscator hasn't been initialized{
            
            init();
        }
        if (available_board_prefix_indices.length == 0)
        {
            board_name_iteration++;
            setupBoardNames();
        }
        var board_prefix_indx : Int = rand.nextIntRange(0, available_board_prefix_indices.length - 1);
        var board_prefix : String = Reflect.field(board_prefix_array, Std.string(available_board_prefix_indices[board_prefix_indx]));
        var available_suffix_indx : Array<Int> = (try cast(Reflect.field(board_prefix_available_suffix_indices, board_prefix), Array/*Vector.<T> call?*/) catch(e:Dynamic) null);
        if ((available_suffix_indx != null) && (available_suffix_indx.length > 0))
        {
            var board_suffix_indx : Int = rand.nextIntRange(0, available_suffix_indx.length - 1);
            var board_suffix : String = Reflect.field(board_suffix_array, Std.string(available_suffix_indx[board_suffix_indx]));
            var num : String = "";
            if (board_name_iteration > 0)
            {
                num = Std.string(board_name_iteration);
            }
            return board_prefix + board_suffix + num;
        }
        else
        {
            available_board_prefix_indices.splice(Lambda.indexOf(available_board_prefix_indices, board_prefix_indx), 1);
            return getNextBoardName();
        }
    }
}

