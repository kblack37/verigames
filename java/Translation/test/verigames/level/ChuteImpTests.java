package verigames.level;

import static org.junit.Assert.fail;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import org.junit.Before;
import org.junit.Test;

import verigames.level.Chute;
import verigames.level.Intersection;

public class ChuteImpTests
{
  /**
   * Tests that the getStartPort accessor throws an IllegalStateException if
   * there is no starting Intersection
   */
  @Test(expected = IllegalStateException.class) public void getStartPortTest()
  {
    (new Chute()).getStartPort();
  }
  
  /**
   * Tests that the getEndPort accessor throws an IllegalStateException if
   * there is no ending Intersection
   */
  @Test(expected = IllegalStateException.class) public void getEndPortTest()
  {
    (new Chute()).getEndPort();
  }
  
  private Chute c;
  
  public static List<Method> chuteMethods;
  static
  {
    chuteMethods = new ArrayList<Method>();
    
    // add all declared methods in Chute class and superclasses
    for (Class<?> currentClass = Chute.class; currentClass != null; currentClass = currentClass
        .getSuperclass())
      chuteMethods.addAll(Arrays.asList(currentClass.getDeclaredMethods()));
  }
  
  /**
   * Invokes a method with the given name on the given receiver, with the given
   * arguments, subverting access control
   */
  private void invokeChuteMethod(Chute receiver, String name, Object[] args)
      throws IllegalArgumentException, IllegalAccessException,
      InvocationTargetException
      {
    boolean methodInvoked = false;
    for (Method m : chuteMethods)
    {
      if (m.getName().equals(name))
      {
        m.setAccessible(true);
        m.invoke(receiver, args);
        methodInvoked = true;
      }
    }
    if (!methodInvoked)
      throw new IllegalArgumentException("method " + name
          + " does not exist");
      }
  
  @Before
  public void initC() throws IllegalArgumentException
  {
    c = new Chute();
    c.setEditable(false);
    
    c.setStart(Intersection.factory(Intersection.Kind.INCOMING), "0");
    
    c.setEnd(Intersection.factory(Intersection.Kind.OUTGOING), "0");
    
    c.finishConstruction();
  }
  
  @Test(expected = IllegalStateException.class) public void finishConstructionTest()
      throws Throwable
      {
    // c.finishConstruction() (calling it a second time should throw an
    // IllegalStateException)
    try
    {
      invokeChuteMethod(c, "finishConstruction", new Object[] {});
    }
    catch (InvocationTargetException e)
    {
      throw e.getCause();
    }
    catch (Exception e)
    {
      fail();
    }
      }
  
  @Test(expected = IllegalStateException.class) public void narrowTest()
  {
    c.setNarrow(true);
  }
  
  @Test(expected = IllegalStateException.class)
  public void setStartTest()
  {
    c.setStart(Intersection.factory(Intersection.Kind.START_SMALL_BALL), "0");
  }
  
  @Test(expected = IllegalStateException.class)
  public void setEndTest() throws Throwable
  {
    c.setEnd(Intersection.factory(Intersection.Kind.END), "0");
  }
}
