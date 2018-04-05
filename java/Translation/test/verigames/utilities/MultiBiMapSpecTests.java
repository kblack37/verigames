package verigames.utilities;

import static org.junit.Assert.*;

import org.junit.*;

import verigames.utilities.MultiBiMap;
import verigames.utilities.MultiMap;

import java.util.*;

/**
 * Specification tests for {@link MultiMap}
 *
 * @author Nathaniel Mote
 */

public class MultiBiMapSpecTests
{
  private MultiBiMap<String, Integer> m;
  
  @Before
  public void init()
  {
    m = new MultiBiMap<String, Integer>();
  }
  
  @Test
  public void basicPutTest()
  {
    m.put("5", 5);
    
    assertTrue(m.get("5").size() == 1);
    assertTrue(m.get("5").contains(5));
    
    assertTrue(m.inverse().get(5).size() == 1);
    assertTrue(m.inverse().get(5).contains("5"));
  }
  
  @Test
  public void inversePutTest()
  {
    m.inverse().put(5, "5");
    
    assertTrue(m.get("5").size() == 1);
    assertTrue(m.get("5").contains(5));
    
    assertTrue(m.inverse().get(5).size() == 1);
    assertTrue(m.inverse().get(5).contains("5"));
  }
  
  @Test
  public void multiTest()
  {
    m.put("a", 6);
    m.put("a", 4);
    m.put("t", 4);
    
    assertTrue(m.get("a").contains(6));
    assertTrue(m.get("a").contains(4));
    assertTrue(m.get("t").contains(4));
    
    assertTrue(m.inverse().get(6).contains("a"));
    assertTrue(m.inverse().get(4).contains("a"));
    assertTrue(m.inverse().get(4).contains("t"));
  }
}
