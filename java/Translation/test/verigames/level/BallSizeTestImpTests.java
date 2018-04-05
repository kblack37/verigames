package verigames.level;

import static org.junit.Assert.assertTrue;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


import org.junit.Before;
import org.junit.Test;

import verigames.level.*;
import verigames.level.Intersection.Kind;

public class BallSizeTestImpTests
{  
  public BallSizeTest n;
  
  public static Method[] nullTestMethods = BallSizeTest.class.getDeclaredMethods();
  
  @Before public void init()
  {
    n = Intersection.factory(Kind.BALL_SIZE_TEST).asBallSizeTest();
  }
  
  /**
   * Tests that when an editable chute is passed into the setWideChute setter,
   * it throws an IllegalArgumentException.
   */
  @Test public void testUneditableNull()
  {
    Chute uneditable = new Chute();
    uneditable.setNarrow(false);
    
    boolean exceptionThrown = false;
    
    try
    {
      n.setWideChute(uneditable);
    }
    catch (IllegalArgumentException e)
    {
      exceptionThrown = true;
    }
    assertTrue("IllegalArgumentException not thrown when expected",
        exceptionThrown);
  }
  
  /**
   * Tests that when an editable chute is passed into the setNarrowChute
   * setter, it throws an IllegalArgumentException
   */
  @Test public void testUneditableNonNull()
  {
    Chute uneditable = new Chute();
    uneditable.setNarrow(true);
    
    boolean exceptionThrown = false;
    
    try
    {
      n.setNarrowChute(uneditable);
    }
    catch (IllegalArgumentException e)
    {
      exceptionThrown = true;
    }
    assertTrue("IllegalArgumentException not thrown when expected",
        exceptionThrown);
  }
  
  /**
   * Tests that when a narrow chute is passed into the setWideChute setter, it
   * throws an IllegalArgumentException
   */
  @Test public void testNarrowNull()
  {
    Chute narrow = new Chute();
    narrow.setNarrow(true);
    narrow.setEditable(false);
    
    boolean exceptionThrown = false;
    
    try
    {
      n.setWideChute(narrow);
    }
    catch (IllegalArgumentException e)
    {
      exceptionThrown = true;
    }
    assertTrue("IllegalArgumentException not thrown when expected",
        exceptionThrown);
  }
  
  /**
   * Tests that when a wide chute is passed into the setNarrowChute setter, it
   * throws an IllegalArgumentException
   */
  @Test public void testWideNonNull()
  {
    Chute wide = new Chute();
    wide.setNarrow(false);
    wide.setEditable(false);
    
    boolean exceptionThrown = false;
    
    try
    {
       n.setNarrowChute(wide);
    }
    catch (IllegalArgumentException e)
    {
      exceptionThrown = true;
    }
    assertTrue("IllegalArgumentException not thrown when expected",
        exceptionThrown);
  }
  
  /**
   * Tests that when a chute is mutated after adding that checkRep()
   * catches it later
   */
  @Test
  public void testCheckRep() throws IllegalAccessException
  {
    boolean checkRepEnabled = true;
    
    // checkRepEnabled = BallSizeTest.CHECK_REP_ENABLED
    Field[] fields = BallSizeTest.class.getDeclaredFields();
    for (Field f : fields)
    {
      if (f.getName().equals("CHECK_REP_ENABLED"))
      {
        f.setAccessible(true);
        checkRepEnabled = (Boolean) f.get(BallSizeTest.class);
      }
    }
    
    if (checkRepEnabled)
    {
      BallSizeTest n = Intersection.factory(Kind.BALL_SIZE_TEST).asBallSizeTest();
      
      Chute wide = new Chute();
      wide.setNarrow(false);
      wide.setEditable(false);
      
      // n.setWideChute(wide)
      n.setWideChute(wide);
      
      wide.setNarrow(true);
      
      Chute narrow = new Chute();
      narrow.setNarrow(true);
      narrow.setEditable(false);
      
      // n.setNarrowChute(narrow)
      // should throw RuntimeException when checkRep catches the mutation to
      // wide
      boolean expectedExceptionThrown = false;
      try
      {
        n.setNarrowChute(narrow);
      }
      catch (RuntimeException e)
      {
        expectedExceptionThrown = true;
      }
      assertTrue(expectedExceptionThrown);
    }
  }
  
  /**
   * runs the given method on the given receiver with the given arguments
   * 
   * I know this is not awesome style, but subverting access control is
   * necessarily a little bit hackish, and it's just a test
   */
  private static void runMethod(BallSizeTest receiver, String methodName,
      Object[] args) throws Throwable
      {
    boolean methodRun = false;
    for (Method m : nullTestMethods)
    {
      if (m.getName().equals(methodName))
      {
        m.setAccessible(true);
        try
        {
          m.invoke(receiver, args);
        } catch (InvocationTargetException e)
        {
          throw e.getCause();
        }
        methodRun = true;
      }
    }
    if (!methodRun)
      throw new Exception("Given method not found");
      }
}
