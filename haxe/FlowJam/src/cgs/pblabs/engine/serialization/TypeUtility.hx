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

import cgs.utils.Error;
import haxe.Constraints.Function;
import cgs.pblabs.engine.debug.Logger;
import flash.utils.Dictionary;

/**
 * TypeUtility is a static class containing methods that aid in type
 * introspection and reflection.
 */
class TypeUtility
{
    /**
     * Registers a function that will be called when the specified type needs to be
     * instantiated. The function should return an instance of the specified type.
     * 
     * @param typeName The name of the type the specified function should handle.
     * @param instantiator The function that instantiates the specified type.
     */
    public static function registerInstantiator(typeName : String, instantiator : Function) : Void
    {
        if (_instantiators[typeName] != null)
        {
            Logger.warn("TypeUtility", "RegisterInstantiator", "An instantiator for " + typeName + " has already been registered. It will be replaced.");
        }
        
        _instantiators[typeName] = instantiator;
    }
    
    /**
     * Returns the fully qualified name of the type
     * of the passed in object.
     * 
     * @param object The object whose type is being retrieved.
     * 
     * @return The name of the specified object's type.
     */
    public static function getObjectClassName(object : Dynamic) : String
    {
        return flash.utils.getQualifiedClassName(object);
    }
    
    /**
     * Returns the Class object for the given class.
     * 
     * @param className The fully qualified name of the class being looked up.
     * 
     * @return The Class object of the specified class, or null if wasn't found.
     */
    public static function getClassFromName(className : String) : Class<Dynamic>
    {
        return Type.getClass(Type.resolveClass(className));
    }
    
    public static function getClass(item : Dynamic) : Class<Dynamic>
    {
        if (Std.is(item, Class) || item == null)
        {
            return item;
        }
        
        return item;
    }
    
    /**
     * Creates an instance of a type based on its name.
     * 
     * @param className The name of the class to instantiate.
     * 
     * @return An instance of the class, or null if instantiation failed.
     */
    public static function instantiate(className : String, suppressError : Bool = false) : Dynamic
    {
        // Deal with strings explicitly as they are a primitive.
        if (className == "String")
        {
            return "";
        }
        
        // Class is also a primitive type.
        if (className == "Class")
        {
            return Class;
        }
        
        // Check for overrides.
        if (_instantiators[className] != null)
        {
            return _instantiators[className]();
        }
        
        // Give it a shot!
        try
        {
            var t = Type.getClass(className);
            return Type.createInstance(t);
        }
        catch (e : Error)
        {
            if (!suppressError)
            {
                Logger.warn(null, "Instantiate", "Failed to instantiate " + className + " due to " + e.message());
                Logger.warn(null, "Instantiate", "Is " + className + " included in your SWF? Make sure you call PBE.registerType(" + className + "); somewhere in your project.");
            }
        }  // If we get here, couldn't new it.  
        
        
        
        return null;
    }
    
    /**
     * Gets the type of a field as a string for a specific field on an object.
     * 
     * @param object The object on which the field exists.
     * @param field The name of the field whose type is being looked up.
     * 
     * @return The fully qualified name of the type of the specified field, or
     * null if the field wasn't found.
     *
    public static function getFieldType(object:*, field:String):String
    {
    var descriptor:ClassDescriptor = getClassDescritor(object);
    
    return descriptor.getPropertyType(field);
    /*var typeXML:XML = getTypeDescription(object);
    
    // Look for a matching accessor.
    for each(var property:XML in typeXML.child("accessor"))
    {
    if (property.attribute("name") == field)
    return property.attribute("type");
    }
    
    // Look for a matching variable.
    for each(var variable:XML in typeXML.child("variable"))
    {
    if (variable.attribute("name") == field)
    return variable.attribute("type");
    }
    
    return null;*/
    //}
    
    /**
     * Determines if an object is an instance of a dynamic class.
     * 
     * @param object The object to check.
     * 
     * @return True if the object is dynamic, false otherwise.
     */
    public static function isDynamic(object : Dynamic) : Bool
    {
        if (Std.is(object, Class))
        {
            Logger.error(object, "isDynamic", "The object is a Class type, which is always dynamic");
            return true;
        }
        
        var typeXml : FastXML = getTypeDescription(object);
        return typeXml.att.isDynamic == "true";
    }
    
    /**
     * Determine the type, specified by metadata, for a container class like an Array.
     *
    public static function getTypeHint(object:*, field:String):String
    {
    var classDescriptor:ClassDescriptor = getClassDescritor(object);
    if(classDescriptor == null) return null;
    
    return classDescriptor.getTypeHint(field);
    
    /*var description:XML = getTypeDescription(object);
    if (!description)
    return null;
    
    for each (var variable:XML in description.*)
    {
    // Skip if it's not the field we want.
    if (variable.@name != field)
    continue;
    
    // Only check variables/accessors.
    if (variable.name() != "variable" && variable.name() != "accessor")
    continue;
    
    // Scan for TypeHint metadata.
    for each (var metadataXML:XML in variable.*)
    {
    if (metadataXML.@name == "TypeHint")
    return metadataXML.arg.@value.toString();
    }
    }*/
    
    //return null;
    //}
    
    /**
     * Gets the xml description of an object's type through a call to the
     * flash.utils.describeType method. Results are cached, so only the first
     * call will impact performance.
     * 
     * @param object The object to describe.
     * 
     * @return The xml description of the object.
     */
    public static function getTypeDescription(object : Dynamic) : FastXML
    {
        var className : String = getObjectClassName(object);
        if (_typeDescriptions[className] == null)
        {
            _typeDescriptions[className] = describeType(object);
        }
        
        return _typeDescriptions[className];
    }
    
    /*protected static function getClassDescritor(object:*):ClassDescriptor
    {
    var className:String = getQualifiedClassName(object);
    var descriptor:ClassDescriptor = _classDescriptors[className];
    if(descriptor == null)
    {
    try
    {
    descriptor = new ClassDescriptor(object);
    _classDescriptors[className] = descriptor;
    }
    catch(ex:Error)
    {
    return null;
    }
    }
    
    return descriptor;
    }
    
    protected static function getClassNameDescriptor(name:String):ClassDescriptor
    {
    var descriptor:ClassDescriptor = _classDescriptors[name];
    if(descriptor == null)
    {
    try
    {
    var classObject:* = getDefinitionByName(name);
    descriptor = new ClassDescriptor(classObject);
    _classDescriptors[name] = descriptor;
    }
    catch(ex:Error)
    {
    return null;
    }
    }
    
    return descriptor;
    }*/
    
    /**
     * Gets the xml description of a class through a call to the
     * flash.utils.describeType method. Results are cached, so only the first
     * call will impact performance.
     * 
     * @param className The name of the class to describe.
     * 
     * @return The xml description of the class.
     */
    private static function getClassDescription(className : String) : FastXML
    {
        if (_typeDescriptions[className] == null)
        {
            try
            {
                _typeDescriptions[className] = describeType(Type.resolveClass(className));
            }
            catch (error : Error)
            {
                return null;
            }
        }
        
        return _typeDescriptions[className];
    }
    
    private static var _classDescriptors : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
    
    private static var _typeDescriptions : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
    private static var _instantiators : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();

    public function new()
    {
    }
}
