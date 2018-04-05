package verigames.graph;

import static org.junit.Assert.*;
import static verigames.utilities.Reflect.invokeMethod;

import java.lang.reflect.InvocationTargetException;

import org.junit.Test;

import verigames.graph.Node;

public class NodeImpTests
{
  /**
   * Tests that Node.getInput returns null on an unused port.
   */
  @Test
  public void testGetNegativeInput()
  {
    assertNull(new ConcreteNode().getInput("-1"));
  }
}
