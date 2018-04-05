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
import verigames.level.Intersection.Kind;

public class IntersectionImpTests
{
  /**
   * Tests to make sure that the Intersection factory fails on Kind SUBNETWORK
   */
  @Test(expected = IllegalArgumentException.class) public void testConstructorFailure1()
  {
    Intersection.factory(Kind.SUBBOARD);
  }
  
  /**
   * Tests that asSubnetwork fails on Intersection instances
   */
  @Test(expected = IllegalStateException.class) public void testAsSubboardFailure()
  {
    (Intersection.factory(Kind.INCOMING)).asSubboard();
  }
  
  /**
   * Tests that asBallSizeTest fails on Intersection instances
   */
  @Test(expected = IllegalStateException.class) public void testAsBallSizeTestFailure()
  {
    (Intersection.factory(Kind.INCOMING)).asBallSizeTest();
  }
  
  private Intersection i;
  
  public static List<Method> intersectionMethods;
  static
  {
    intersectionMethods = new ArrayList<Method>();
    
    // add all declared methods in Chute class and superclasses
    for (Class<?> currentClass = Intersection.class; currentClass != null; currentClass = currentClass
        .getSuperclass())
      intersectionMethods.addAll(Arrays.asList(currentClass.getDeclaredMethods()));
  }
  
  /**
   * Invokes a method with the given name on the given receiver, with the given
   * arguments, subverting access control
   */
  private void invokeIntersectionMethod(Intersection receiver, String name,
      Object[] args) throws IllegalArgumentException,
      IllegalAccessException, InvocationTargetException
      {
    boolean methodInvoked = false;
    for (Method m : intersectionMethods)
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
  public void initIntersection() throws IllegalArgumentException,
  IllegalAccessException, InvocationTargetException
  {
    i = Intersection.factory(Kind.CONNECT);
    
    i.setInput(new Chute(), "0");
    
    i.setOutput(new Chute(), "0");
    
    i.finishConstruction();
  }
  
  @Test(expected = IllegalStateException.class) public void testDeactivate() throws Throwable
  {
    // i.finishConstruction() (second call should fail because it's already inactive)
    try
    {
      invokeIntersectionMethod(i, "finishConstruction", new Object[]{});
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
  
  @Test(expected = IllegalStateException.class)
  public void setInputTest()
  {
    i.setInput(new Chute(), "0");
  }
  
  @Test(expected = IllegalStateException.class)
  public void setOutputTest() throws Throwable
  {
    i.setOutput(new Chute(), "0");
  }
}
