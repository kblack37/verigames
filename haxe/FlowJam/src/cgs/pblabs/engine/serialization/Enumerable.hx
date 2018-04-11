/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
//Package name revised to avoid conflict with application using PBE.
package cgs.pblabs.engine.serialization;

import openfl.utils.Dictionary;
import cgs.pblabs.engine.debug.Logger;
import cgs.utils.Error;

@:meta(EditorData(ignore="true"))

/**
* Base class that implements common functionality for enumeration classes. An
* enumeration class is essentially a class that is just a list of constant
* values. They can be used to add type safety to properties that need to be
* limited to a specific subset of values.
* 
* <p>Serialization is also provided by this class so the names of the constants
* can be used in XML rather than their values.</p>
*/
class Enumerable implements ISerializable
{
    public var typeMap(get, never) : Dictionary;
    public var defaultType(get, never) : Enumerable;

    /**
       * This must be implemented by subclasses. It is a dictionary that maps the names
       * of enumerable values to the instance of the enumerable they represent.
       */
    private function get_typeMap() : Dictionary<String, Dynamic>
    {
        throw new Error("Derived classes must implement this!");
    }
    
    /**
       * This must be implemented by subclasses. It is the type to use when a string
       * isn't found in the TypeMap.
       */
    private function get_defaultType() : Enumerable
    {
        throw new Error("Derived classes must implement this!");
    }
    
    /**
       * @inheritDoc
       */
    public function serialize(xml : FastXML) : Void
    {
        for (typeName in Reflect.fields(typeMap))
        {
            if (typeMap[typeName] == this)
            {
                xml.node.appendChild.innerData(typeName);
                break;
            }
        }
    }
    
    /**
       * @inheritDoc
       */
    public function deserialize(xml : FastXML) : Dynamic
    {
        var stringValue : String = Std.string(xml);
        if (typeMap[stringValue] == null)
        {
            Logger.error(this, "deserialize", stringValue + " is not a valid value for this enumeration.");
            return defaultType;
        }
        
        return typeMap[stringValue];
    }

    public function new()
    {
    }
}
