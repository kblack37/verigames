package verigames.utilities;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Reflect
{
  /**
   * Invokes a method with the given name on the receiver, using reflection to
   * subvert access control. Attempts to resolve method overloading, but uses
   * the runtime types of the arguments, rather than the static types.
   * 
   * @throws InvocationTargetException
   */
  public static void invokeMethod(Object receiver, String methodName,
      Object... args) throws InvocationTargetException
      {
    Class<?>[] argTypes = new Class<?>[args.length];
    for (int i = 0; i < args.length; i++)
      argTypes[i] = args[i].getClass();
    
    List<Method> methods = new ArrayList<Method>();
    for (Class<?> currentClass = receiver.getClass(); currentClass != null; currentClass = currentClass
        .getSuperclass())
    {
      Method[] allMethods = currentClass.getDeclaredMethods();
      for (Method m : allMethods)
        if (m.getName().equals(methodName))
          methods.add(m);
    } 
    Method method = null;
    
    for (Method m : methods)
    {
      if (compareArgs(m.getParameterTypes(), argTypes))
      {
        method = m;
        break;
      }
    }
    
    if (method == null)
      throw new IllegalArgumentException("method does not exist");
    
    invoke(receiver, method, args);
      }
  
  private static boolean compareArgs(Class<?>[] required, Class<?>[] given)
  {
    if (required.length != given.length)
    {
      return false;
    }
    else
    {
      boolean equivalent = true;
      for (int i = 0; i < required.length; i++)
        equivalent &= compareArg(required[i], given[i]);
      return equivalent;
    }
  }
  
  private static Map<Class<?>, Class<?>> toPrimitiveClass;
  static
  {
    toPrimitiveClass = new HashMap<Class<?>, Class<?>>();
    toPrimitiveClass.put(Boolean.class, boolean.class);
    toPrimitiveClass.put(Byte.class, byte.class);
    toPrimitiveClass.put(Character.class, char.class);
    toPrimitiveClass.put(Short.class, short.class);
    toPrimitiveClass.put(Integer.class, int.class);
    toPrimitiveClass.put(Long.class, long.class);
    toPrimitiveClass.put(Float.class, float.class);
    toPrimitiveClass.put(Double.class, double.class);
  }
  
  private static boolean compareArg(Class<?> required, Class<?> given)
  {
    if (required.isAssignableFrom(given))
      return true;
    else if (required.equals(toPrimitiveClass.get(given)))
      return true;
    else
      return false;
  }
  
  public static void invokeStaticMethod(Class<?> clazz, String methodName,
      Object... args)
  {
    // TODO implement
  }
  
  private static void invoke(Object receiver, Method m, Object... args)
      throws InvocationTargetException
      {
    try
    {
      m.setAccessible(true);
      m.invoke(receiver, args);
    }
    catch (IllegalAccessException e)
    {
      throw new RuntimeException(e);
    }
      }
}
