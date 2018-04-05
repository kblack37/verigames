package verigames.graph;

import static verigames.utilities.Reflect.*;

import java.lang.reflect.InvocationTargetException;


import org.junit.Test;

import verigames.graph.Edge;

public class EdgeSpecTests
{
  @Test
  public void testDeactivate() throws InvocationTargetException
  {
    Edge<?> e = new ConcreteEdge();
    
    invokeMethod(e, "setStart", new ConcreteNode(), "0");
    invokeMethod(e, "setEnd", new ConcreteNode(), "0");
    invokeMethod(e, "finishConstruction");
  }
}
