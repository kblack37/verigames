package verigames.utilities;

import static org.junit.Assert.*;

import org.junit.Test;

import verigames.utilities.MultiMap;

import java.util.*;

/**
 * Specification tests for {@link MultiMap}
 *
 * @author Nathaniel Mote
 */

public class MultiMapSpecTests
{
  // Test whether rep exposure occurs when the given key is not present
  @Test
  public void repExposureTest1()
  {
    MultiMap<Integer, Integer> m = new MultiMap<Integer, Integer>();
    Set<Integer> s = m.get(5);
    
    try
    {
      s.add(6);
    }
    // if the set can't be modified, there's no rep exposure, so it's fine.
    catch (UnsupportedOperationException e) {}
    
    assertFalse(m.get(5).contains(6));
  }
  
  // Test whether rep exposure occurs when the given key is present
  @Test
  public void repExposureTest2()
  {
    MultiMap<Integer, Integer> m = new MultiMap<Integer, Integer>();
    m.put(5,4);
    Set<Integer> s = m.get(5);
    
    try
    {
      s.add(6);
    }
    // if the set can't be modified, there's no rep exposure, so it's fine.
    catch (UnsupportedOperationException e) {}
    
    assertFalse(m.get(5).contains(6));
  }
  
  // make sure multiple values actually do work
  @Test
  public void multiValueTest()
  {
    MultiMap<Integer, Integer> m = new MultiMap<Integer, Integer>();
    m.put(5,4);
    m.put(5,6);
    Set<Integer> s = m.get(5);
    
    assertTrue(s.contains(4));
    assertTrue(s.contains(6));
  }
}
