//Package name revised to avoid conflict with application using PBE.
package cgs.pblabs.engine.core;

import openfl.utils.Dictionary;
import cgs.pblabs.engine.debug.Logger;
import cgs.pblabs.engine.serialization.Enumerable;

/**
 * Enumeration class that maps friendly key names to their key code equivalent. This class
 * should not be instantiated directly, rather, one of the constants should be used.
 */
class InputKey extends Enumerable
{
    public static var staticTypeMap(get, never) : Dictionary<String, Dynamic>;
    public var keyCode(get, never) : Int;

    public static var INVALID : InputKey = new InputKey(0);
    
    public static var BACKSPACE : InputKey = new InputKey(8);
    public static var TAB : InputKey = new InputKey(9);
    public static var ENTER : InputKey = new InputKey(13);
    public static var COMMAND : InputKey = new InputKey(15);
    public static var SHIFT : InputKey = new InputKey(16);
    public static var CONTROL : InputKey = new InputKey(17);
    public static var ALT : InputKey = new InputKey(18);
    public static var PAUSE : InputKey = new InputKey(19);
    public static var CAPS_LOCK : InputKey = new InputKey(20);
    public static var ESCAPE : InputKey = new InputKey(27);
    
    public static var SPACE : InputKey = new InputKey(32);
    public static var PAGE_UP : InputKey = new InputKey(33);
    public static var PAGE_DOWN : InputKey = new InputKey(34);
    public static var END : InputKey = new InputKey(35);
    public static var HOME : InputKey = new InputKey(36);
    public static var LEFT : InputKey = new InputKey(37);
    public static var UP : InputKey = new InputKey(38);
    public static var RIGHT : InputKey = new InputKey(39);
    public static var DOWN : InputKey = new InputKey(40);
    
    public static var INSERT : InputKey = new InputKey(45);
    public static var DELETE : InputKey = new InputKey(46);
    
    public static var ZERO : InputKey = new InputKey(48);
    public static var ONE : InputKey = new InputKey(49);
    public static var TWO : InputKey = new InputKey(50);
    public static var THREE : InputKey = new InputKey(51);
    public static var FOUR : InputKey = new InputKey(52);
    public static var FIVE : InputKey = new InputKey(53);
    public static var SIX : InputKey = new InputKey(54);
    public static var SEVEN : InputKey = new InputKey(55);
    public static var EIGHT : InputKey = new InputKey(56);
    public static var NINE : InputKey = new InputKey(57);
    
    public static var A : InputKey = new InputKey(65);
    public static var B : InputKey = new InputKey(66);
    public static var C : InputKey = new InputKey(67);
    public static var D : InputKey = new InputKey(68);
    public static var E : InputKey = new InputKey(69);
    public static var F : InputKey = new InputKey(70);
    public static var G : InputKey = new InputKey(71);
    public static var H : InputKey = new InputKey(72);
    public static var I : InputKey = new InputKey(73);
    public static var J : InputKey = new InputKey(74);
    public static var K : InputKey = new InputKey(75);
    public static var L : InputKey = new InputKey(76);
    public static var M : InputKey = new InputKey(77);
    public static var N : InputKey = new InputKey(78);
    public static var O : InputKey = new InputKey(79);
    public static var P : InputKey = new InputKey(80);
    public static var Q : InputKey = new InputKey(81);
    public static var R : InputKey = new InputKey(82);
    public static var S : InputKey = new InputKey(83);
    public static var T : InputKey = new InputKey(84);
    public static var U : InputKey = new InputKey(85);
    public static var V : InputKey = new InputKey(86);
    public static var W : InputKey = new InputKey(87);
    public static var X : InputKey = new InputKey(88);
    public static var Y : InputKey = new InputKey(89);
    public static var Z : InputKey = new InputKey(90);
    
    public static var NUM0 : InputKey = new InputKey(96);
    public static var NUM1 : InputKey = new InputKey(97);
    public static var NUM2 : InputKey = new InputKey(98);
    public static var NUM3 : InputKey = new InputKey(99);
    public static var NUM4 : InputKey = new InputKey(100);
    public static var NUM5 : InputKey = new InputKey(101);
    public static var NUM6 : InputKey = new InputKey(102);
    public static var NUM7 : InputKey = new InputKey(103);
    public static var NUM8 : InputKey = new InputKey(104);
    public static var NUM9 : InputKey = new InputKey(105);
    
    public static var MULTIPLY : InputKey = new InputKey(106);
    public static var ADD : InputKey = new InputKey(107);
    public static var NUMENTER : InputKey = new InputKey(108);
    public static var SUBTRACT : InputKey = new InputKey(109);
    public static var DECIMAL : InputKey = new InputKey(110);
    public static var DIVIDE : InputKey = new InputKey(111);
    
    public static var F1 : InputKey = new InputKey(112);
    public static var F2 : InputKey = new InputKey(113);
    public static var F3 : InputKey = new InputKey(114);
    public static var F4 : InputKey = new InputKey(115);
    public static var F5 : InputKey = new InputKey(116);
    public static var F6 : InputKey = new InputKey(117);
    public static var F7 : InputKey = new InputKey(118);
    public static var F8 : InputKey = new InputKey(119);
    public static var F9 : InputKey = new InputKey(120);
    // F10 is considered 'reserved' by Flash
    public static var F11 : InputKey = new InputKey(122);
    public static var F12 : InputKey = new InputKey(123);
    
    public static var NUM_LOCK : InputKey = new InputKey(144);
    public static var SCROLL_LOCK : InputKey = new InputKey(145);
    
    public static var COLON : InputKey = new InputKey(186);
    public static var PLUS : InputKey = new InputKey(187);
    public static var COMMA : InputKey = new InputKey(188);
    public static var MINUS : InputKey = new InputKey(189);
    public static var PERIOD : InputKey = new InputKey(190);
    public static var BACKSLASH : InputKey = new InputKey(191);
    public static var TILDE : InputKey = new InputKey(192);
    
    public static var LEFT_BRACKET : InputKey = new InputKey(219);
    public static var SLASH : InputKey = new InputKey(220);
    public static var RIGHT_BRACKET : InputKey = new InputKey(221);
    public static var QUOTE : InputKey = new InputKey(222);
    
    public static var MOUSE_BUTTON : InputKey = new InputKey(253);
    public static var MOUSE_X : InputKey = new InputKey(254);
    public static var MOUSE_Y : InputKey = new InputKey(255);
    public static var MOUSE_WHEEL : InputKey = new InputKey(256);
    public static var MOUSE_HOVER : InputKey = new InputKey(257);
    
    /**
     * A dictionary mapping the string names of all the keys to the InputKey they represent.
     */
    private static function get_staticTypeMap() : Dictionary<String, Dynamic>
    {
        if (!_typeMap)
        {
            _typeMap = new Dictionary<String, Dynamic>();
            _typeMap["BACKSPACE"] = BACKSPACE;
            _typeMap["TAB"] = TAB;
            _typeMap["ENTER"] = ENTER;
            _typeMap["RETURN"] = ENTER;
            _typeMap["SHIFT"] = SHIFT;
            _typeMap["COMMAND"] = COMMAND;
            _typeMap["CONTROL"] = CONTROL;
            _typeMap["ALT"] = ALT;
            _typeMap["OPTION"] = ALT;
            _typeMap["ALTERNATE"] = ALT;
            _typeMap["PAUSE"] = PAUSE;
            _typeMap["CAPS_LOCK"] = CAPS_LOCK;
            _typeMap["ESCAPE"] = ESCAPE;
            _typeMap["SPACE"] = SPACE;
            _typeMap["SPACE_BAR"] = SPACE;
            _typeMap["PAGE_UP"] = PAGE_UP;
            _typeMap["PAGE_DOWN"] = PAGE_DOWN;
            _typeMap["END"] = END;
            _typeMap["HOME"] = HOME;
            _typeMap["LEFT"] = LEFT;
            _typeMap["UP"] = UP;
            _typeMap["RIGHT"] = RIGHT;
            _typeMap["DOWN"] = DOWN;
            _typeMap["LEFT_ARROW"] = LEFT;
            _typeMap["UP_ARROW"] = UP;
            _typeMap["RIGHT_ARROW"] = RIGHT;
            _typeMap["DOWN_ARROW"] = DOWN;
            _typeMap["INSERT"] = INSERT;
            _typeMap["DELETE"] = DELETE;
            _typeMap["ZERO"] = ZERO;
            _typeMap["ONE"] = ONE;
            _typeMap["TWO"] = TWO;
            _typeMap["THREE"] = THREE;
            _typeMap["FOUR"] = FOUR;
            _typeMap["FIVE"] = FIVE;
            _typeMap["SIX"] = SIX;
            _typeMap["SEVEN"] = SEVEN;
            _typeMap["EIGHT"] = EIGHT;
            _typeMap["NINE"] = NINE;
            _typeMap["0"] = ZERO;
            _typeMap["1"] = ONE;
            _typeMap["2"] = TWO;
            _typeMap["3"] = THREE;
            _typeMap["4"] = FOUR;
            _typeMap["5"] = FIVE;
            _typeMap["6"] = SIX;
            _typeMap["7"] = SEVEN;
            _typeMap["8"] = EIGHT;
            _typeMap["9"] = NINE;
            _typeMap["NUMBER_0"] = ZERO;
            _typeMap["NUMBER_1"] = ONE;
            _typeMap["NUMBER_2"] = TWO;
            _typeMap["NUMBER_3"] = THREE;
            _typeMap["NUMBER_4"] = FOUR;
            _typeMap["NUMBER_5"] = FIVE;
            _typeMap["NUMBER_6"] = SIX;
            _typeMap["NUMBER_7"] = SEVEN;
            _typeMap["NUMBER_8"] = EIGHT;
            _typeMap["NUMBER_9"] = NINE;
            _typeMap["A"] = A;
            _typeMap["B"] = B;
            _typeMap["C"] = C;
            _typeMap["D"] = D;
            _typeMap["E"] = E;
            _typeMap["F"] = F;
            _typeMap["G"] = G;
            _typeMap["H"] = H;
            _typeMap["I"] = I;
            _typeMap["J"] = J;
            _typeMap["K"] = K;
            _typeMap["L"] = L;
            _typeMap["M"] = M;
            _typeMap["N"] = N;
            _typeMap["O"] = O;
            _typeMap["P"] = P;
            _typeMap["Q"] = Q;
            _typeMap["R"] = R;
            _typeMap["S"] = S;
            _typeMap["T"] = T;
            _typeMap["U"] = U;
            _typeMap["V"] = V;
            _typeMap["W"] = W;
            _typeMap["X"] = X;
            _typeMap["Y"] = Y;
            _typeMap["Z"] = Z;
            _typeMap["NUM0"] = NUM0;
            _typeMap["NUM1"] = NUM1;
            _typeMap["NUM2"] = NUM2;
            _typeMap["NUM3"] = NUM3;
            _typeMap["NUM4"] = NUM4;
            _typeMap["NUM5"] = NUM5;
            _typeMap["NUM6"] = NUM6;
            _typeMap["NUM7"] = NUM7;
            _typeMap["NUM8"] = NUM8;
            _typeMap["NUM9"] = NUM9;
            _typeMap["NUMPAD_0"] = NUM0;
            _typeMap["NUMPAD_1"] = NUM1;
            _typeMap["NUMPAD_2"] = NUM2;
            _typeMap["NUMPAD_3"] = NUM3;
            _typeMap["NUMPAD_4"] = NUM4;
            _typeMap["NUMPAD_5"] = NUM5;
            _typeMap["NUMPAD_6"] = NUM6;
            _typeMap["NUMPAD_7"] = NUM7;
            _typeMap["NUMPAD_8"] = NUM8;
            _typeMap["NUMPAD_9"] = NUM9;
            _typeMap["MULTIPLY"] = MULTIPLY;
            _typeMap["ASTERISK"] = MULTIPLY;
            _typeMap["NUMMULTIPLY"] = MULTIPLY;
            _typeMap["NUMPAD_MULTIPLY"] = MULTIPLY;
            _typeMap["ADD"] = ADD;
            _typeMap["NUMADD"] = ADD;
            _typeMap["NUMPAD_ADD"] = ADD;
            _typeMap["SUBTRACT"] = SUBTRACT;
            _typeMap["NUMSUBTRACT"] = SUBTRACT;
            _typeMap["NUMPAD_SUBTRACT"] = SUBTRACT;
            _typeMap["DECIMAL"] = DECIMAL;
            _typeMap["NUMDECIMAL"] = DECIMAL;
            _typeMap["NUMPAD_DECIMAL"] = DECIMAL;
            _typeMap["DIVIDE"] = DIVIDE;
            _typeMap["NUMDIVIDE"] = DIVIDE;
            _typeMap["NUMPAD_DIVIDE"] = DIVIDE;
            _typeMap["NUMENTER"] = NUMENTER;
            _typeMap["NUMPAD_ENTER"] = NUMENTER;
            _typeMap["F1"] = F1;
            _typeMap["F2"] = F2;
            _typeMap["F3"] = F3;
            _typeMap["F4"] = F4;
            _typeMap["F5"] = F5;
            _typeMap["F6"] = F6;
            _typeMap["F7"] = F7;
            _typeMap["F8"] = F8;
            _typeMap["F9"] = F9;
            _typeMap["F11"] = F11;
            _typeMap["F12"] = F12;
            _typeMap["NUM_LOCK"] = NUM_LOCK;
            _typeMap["SCROLL_LOCK"] = SCROLL_LOCK;
            _typeMap["COLON"] = COLON;
            _typeMap["SEMICOLON"] = COLON;
            _typeMap["PLUS"] = PLUS;
            _typeMap["EQUAL"] = PLUS;
            _typeMap["COMMA"] = COMMA;
            _typeMap["LESS_THAN"] = COMMA;
            _typeMap["MINUS"] = MINUS;
            _typeMap["UNDERSCORE"] = MINUS;
            _typeMap["PERIOD"] = PERIOD;
            _typeMap["GREATER_THAN"] = PERIOD;
            _typeMap["BACKSLASH"] = BACKSLASH;
            _typeMap["QUESTION_MARK"] = BACKSLASH;
            _typeMap["TILDE"] = TILDE;
            _typeMap["BACK_QUOTE"] = TILDE;
            _typeMap["LEFT_BRACKET"] = LEFT_BRACKET;
            _typeMap["LEFT_BRACE"] = LEFT_BRACKET;
            _typeMap["SLASH"] = SLASH;
            _typeMap["FORWARD_SLASH"] = SLASH;
            _typeMap["PIPE"] = SLASH;
            _typeMap["RIGHT_BRACKET"] = RIGHT_BRACKET;
            _typeMap["RIGHT_BRACE"] = RIGHT_BRACKET;
            _typeMap["QUOTE"] = QUOTE;
            _typeMap["MOUSE_BUTTON"] = MOUSE_BUTTON;
            _typeMap["MOUSE_X"] = MOUSE_X;
            _typeMap["MOUSE_Y"] = MOUSE_Y;
            _typeMap["MOUSE_WHEEL"] = MOUSE_WHEEL;
            _typeMap["MOUSE_HOVER"] = MOUSE_HOVER;
        }
        
        return _typeMap;
    }
    
    /**
     * Converts a key code to the string that represents it.
     */
    public static function codeToString(value : Int) : String
    {
        var tm : Dictionary<String, Dynamic> = staticTypeMap;
        for (name in Reflect.fields(tm))
        {
            if (staticTypeMap[name.toUpperCase()].keyCode == value)
            {
                return name.toUpperCase();
            }
        }
        
        return null;
    }
    
    /**
     * Converts the name of a key to the keycode it represents.
     */
    public static function stringToCode(value : String) : Int
    {
        if (staticTypeMap[value.toUpperCase()] == null)
        {
            return 0;
        }
        
        return staticTypeMap[value.toUpperCase()].keyCode;
    }
    
    /**
     * Converts the name of a key to the InputKey it represents.
     */
    public static function stringToKey(value : String) : InputKey
    {
        return staticTypeMap[value.toUpperCase()];
    }
    
    private static var _typeMap : Dictionary<String, Dynamic> = null;
    
    /**
     * The key code that this wraps.
     */
    private function get_keyCode() : Int
    {
        return _keyCode;
    }
    
    public function new(keyCode : Int = 0)
    {
        super();
        _keyCode = keyCode;
    }
    
    override private function get_typeMap() : Dictionary<String, Dynamic>
    {
        return staticTypeMap;
    }
    
    override private function get_defaultType() : Enumerable
    {
        return INVALID;
    }
    
    private var _keyCode : Int = 0;
}


