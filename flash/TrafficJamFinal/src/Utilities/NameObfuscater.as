package Utilities 
{
	import flash.utils.Dictionary;
	import VisualWorld.Theme;
	
	public class NameObfuscater 
	{
		
		private static const color_names:Array = [
		"Aqua", "Azure", "Blue", "Black", "Brown", "Coral", "Cyan", "Fuchsia", "Gray", "Green", "Indigo", "Ivory", "Khaki", "Lavendar", 
		"Lime", "Magenta", "Maroon", "Mint", "Navy", "Olive", "Orange", "Pink", "Plum", "Purple", "Red", "Salmon", "Silver", "Teal",
		"Turquoise", "Violet", "White", "Yellow"
		];
		
		private static const color_values:Array = [
		0x7FFFD4/*"Aqua"(-marine)*/, 0xF0FFFF/*Azure*/, 0x0000FF/*Blue*/, 0x0/*Black*/, 0xA52A2A/*Brown*/, 0xFF7F50/*Coral*/, 0x00FFFF/*Cyan*/, 0xFF00FF/*Fuchsia*/, 0x808080/*Gray*/, 0x008000/*Green*/, 0x4B0082/*Indigo*/, 0xFFFFF0/*Ivory*/, 0xF0E68C/*Khaki*/, 0xE6E6FA/*Lavendar*/, 
		0x00FF00/*Lime*/, 0xFF00FF/*Magenta*/, 0x800000/*Maroon*/, 0xBBFFCC/*Mint*/, 0x000080/*Navy*/, 0x808000/*Olive*/, 0xFFA500/*Orange*/, 0xFFC0CB/*Pink*/, 0xDDA0DD/*Plum*/, 0x800080/*Purple*/, 0xFF0000/*Red*/, 0xFA8072/*Salmon*/, 0xC0C0C0/*Silver*/, 0x008080/*Teal*/,
		0x40E0D0/*Turquoise*/, 0xEE82EE/*Violet*/, 0xFFFFFF/*White*/, 0xFFFF00/*Yellow*/
		];
		
		private static const nature_nouns:Array = [
		"Desert", "Canyon", "Clay", "Dunes", "Falls", "Forest", "Hills", "Lake", "Meadows", "Mountain", "Oak", "Peak", "Plains", "Plateau", 
		"Prairie", "River", "Shores", "Shrub", "Springs", "Stream", "Rock", "Valley", "Woods"
		];
		
		private static const adjectives:Array = [
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
		
		private static const place_suffixes:Array = [
		"boro", "City", "Corner", "Depot", "ford", "ham", "Hamlet", "Junction", "mount", "Park", "Port", "Station", "ton", "Town", "Village", "ville"
		];
		
		private var rand:PM_PRNG;
		
		private var level_prefix_array:Array;
		private var level_suffix_array:Array;
		private var board_prefix_array:Array;
		private var board_suffix_array:Array;
		
		private var current_theme:String;
		
		/** If we manage to get through more than one entire dictionary of possible names, start numbering (i.e. BlueCanyon1, etc) */
		private var level_name_iteration:uint = 0;
		
		/** If we manage to get through more than one entire dictionary of possible names, start numbering (i.e. BlueCanyon1, etc) */
		private var board_name_iteration:uint = 0;
		
		/** A list of all prefix indices with at least one available suffix pair */
		private var available_level_prefix_indices:Vector.<uint>;
		
		/** A Dictionary of Vector.<uint> representing unused suffixes for the given prefix key */
		private var level_prefix_available_suffix_indices:Dictionary;
		
		/** A list of all prefix indices with at least one available suffix pair */
		private var available_board_prefix_indices:Vector.<uint>;
		
		/** A Dictionary of Vector.<uint> representing unused suffixes for the given prefix key */
		private var board_prefix_available_suffix_indices:Dictionary;
		
		/** Dictionaries from original_names -> obfuscated_names */
		public var obfuscatedLevelNameDictionary:Dictionary = new Dictionary();
		public var obfuscatedBoardNameDictionary:Dictionary = new Dictionary();
		
		public var reverseObfuscatedLevelNameDictionary:Dictionary = new Dictionary();
		public var reverseObfuscatedBoardNameDictionary:Dictionary = new Dictionary();
		
		/** Dictionary from original_names -> colors (valid if using color_names) */
		public var namesToColorsDictionary:Dictionary = new Dictionary();
		
		public function NameObfuscater(_seed:int) {
			rand = new PM_PRNG(_seed);
			init();
		}
		
		public function init():void {
			switch (Theme.CURRENT_THEME) {
				case Theme.PIPES_THEME:
				case Theme.TRAFFIC_THEME:
					level_prefix_array = color_names;
					level_suffix_array = nature_nouns;
					board_prefix_array = adjectives;
					board_suffix_array = place_suffixes;
				break;
			}
			current_theme = Theme.CURRENT_THEME;
			setupLevelNames();
			setupBoardNames();
		}
		
		private function setupLevelNames():void {
			available_level_prefix_indices = new Vector.<uint>();
			level_prefix_available_suffix_indices = new Dictionary();
			var prefix_i:int = 0;
			for each (var my_level_prefix:String in level_prefix_array) {
				available_level_prefix_indices.push(prefix_i);
				var my_avail_indx:Vector.<uint> = new Vector.<uint>();
				for (var i:int = 0; i < level_suffix_array.length; i++) {
					my_avail_indx.push(i);
				}
				level_prefix_available_suffix_indices[my_level_prefix] = my_avail_indx;
				prefix_i++;
			}
		}
		
		private function setupBoardNames():void {
			available_board_prefix_indices = new Vector.<uint>();
			board_prefix_available_suffix_indices = new Dictionary();
			var prefix_i:int = 0;
			for each (var my_board_prefix:String in board_prefix_array) {
				available_board_prefix_indices.push(prefix_i);
				var my_avail_indx:Vector.<uint> = new Vector.<uint>();
				for (var i:int = 0; i < board_suffix_array.length; i++) {
					my_avail_indx.push(i);
				}
				board_prefix_available_suffix_indices[my_board_prefix] = my_avail_indx;
				prefix_i++;
			}
		}
		
		public function boardNameExists(_original_board_name:String):Boolean {
			return (obfuscatedBoardNameDictionary[_original_board_name] != null);
		}
		
		public function getBoardName(_original_board_name:String, _original_level_name:String):String {
			if (obfuscatedBoardNameDictionary[_original_board_name] != null) {
				return obfuscatedBoardNameDictionary[_original_board_name];
			}
			var my_board_name:String = getNextBoardName();
			var my_level_name:String = getLevelName(_original_level_name);
			var newBoardName:String = my_level_name + "." + my_board_name;
			obfuscatedBoardNameDictionary[_original_board_name] = newBoardName;
			reverseObfuscatedBoardNameDictionary[newBoardName] = _original_board_name;
			return obfuscatedBoardNameDictionary[_original_board_name];
		}
		
		public function getReverseBoardName(obfuscatedName:String):String
		{
			return reverseObfuscatedBoardNameDictionary[obfuscatedName];
		}
		
		public function getLevelName(_original_level_name:String):String {
			if (obfuscatedLevelNameDictionary[_original_level_name] != null) {
				return obfuscatedLevelNameDictionary[_original_level_name];
			}
			var newName:String = getNextLevelName();
			obfuscatedLevelNameDictionary[_original_level_name] = newName;
			reverseObfuscatedLevelNameDictionary[newName] = _original_level_name;
			return obfuscatedLevelNameDictionary[_original_level_name];
		}
		
		public function getReverseLevelName(obfuscatedName:String):String
		{
			return reverseObfuscatedLevelNameDictionary[obfuscatedName];
		}
		
		private function getNextLevelName():String {
			if ((available_level_prefix_indices == null) || (current_theme != Theme.CURRENT_THEME)) {
				// Obfuscator hasn't been initialized
				init();
			}
			if (available_level_prefix_indices.length == 0) {
				level_name_iteration++;
				setupLevelNames();
			}
			var level_prefix_indx:int = rand.nextIntRange(0, available_level_prefix_indices.length - 1);
			var level_prefix:String = level_prefix_array[available_level_prefix_indices[level_prefix_indx]];
			var available_suffix_indx:Vector.<uint> = (level_prefix_available_suffix_indices[level_prefix] as Vector.<uint>);
			if ((available_suffix_indx != null) && (available_suffix_indx.length > 0)) {
				var level_suffix_indx:int = rand.nextIntRange(0, available_suffix_indx.length - 1);
				var level_suffix:String = level_suffix_array[available_suffix_indx[level_suffix_indx]];
				var num:String = "";
				if (level_name_iteration > 0) {
					num = level_name_iteration.toString();
				}
				return level_prefix + level_suffix + num;
			} else {
				available_level_prefix_indices.splice(available_level_prefix_indices.indexOf(level_prefix_indx), 1);
				return getNextLevelName();
			}
		}
		
		private function getNextBoardName():String {
			if ((available_level_prefix_indices == null) || (current_theme != Theme.CURRENT_THEME)) {
				// Obfuscator hasn't been initialized
				init();
			}
			if (available_board_prefix_indices.length == 0) {
				board_name_iteration++;
				setupBoardNames();
			}
			var board_prefix_indx:int = rand.nextIntRange(0, available_board_prefix_indices.length - 1);
			var board_prefix:String = board_prefix_array[available_board_prefix_indices[board_prefix_indx]];
			var available_suffix_indx:Vector.<uint> = (board_prefix_available_suffix_indices[board_prefix] as Vector.<uint>);
			if ((available_suffix_indx != null) && (available_suffix_indx.length > 0)) {
				var board_suffix_indx:int = rand.nextIntRange(0, available_suffix_indx.length - 1);
				var board_suffix:String = board_suffix_array[available_suffix_indx[board_suffix_indx]];
				var num:String = "";
				if (board_name_iteration > 0) {
					num = board_name_iteration.toString();
				}
				return board_prefix + board_suffix + num;
			} else {
				available_board_prefix_indices.splice(available_board_prefix_indices.indexOf(board_prefix_indx), 1);
				return getNextBoardName();
			}
		}
	}

}