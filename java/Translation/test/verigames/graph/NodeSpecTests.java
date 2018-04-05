package verigames.graph;

import static org.junit.Assert.*;
import static verigames.utilities.Reflect.invokeMethod;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

import org.junit.Test;

import verigames.graph.Edge;
import verigames.graph.Node;

public class NodeSpecTests
{
  /**
   * Tests that Node.finishConstruction does not fail when called on a new Node
   * 
   * @throws InvocationTargetException
   */
  @Test
  public void testSimpleDeactivate() throws InvocationTargetException
  {
    Node<?> n = new ConcreteNode();
    invokeMethod(n, "finishConstruction");
  }
  
  /**
   * Tests that Node.finishConstruction does not fail when called on a Node with some
   * ports filled
   * 
   * @throws InvocationTargetException
   */
  @Test
  public void testDeactivate() throws InvocationTargetException
  {
    Node<?> n = new ConcreteNode();
    invokeMethod(n, "setInput", new ConcreteEdge(), "1");
    invokeMethod(n, "setInput", new ConcreteEdge(), "0");
    invokeMethod(n, "setOutput", new ConcreteEdge(), "0");
    invokeMethod(n, "finishConstruction");
  }
  
  /**
   * Tests that setInput and getInput behave consistently
   * 
   * @throws InvocationTargetException
   */
  @Test
  public void testInput() throws InvocationTargetException
  {
    testInOrOut(true);
  }
  
  /**
   * Tests that setOutput and getOutput behave consistently
   * 
   * @throws InvocationTargetException
   */
  @Test
  public void testOutput() throws InvocationTargetException
  {
    testInOrOut(false);
  }
  
  /**
   * Implementation for testOutput and testInput. Shared because they're
   * basically the same.
   * 
   * @throws InvocationTargetException
   */
  private void testInOrOut(boolean input) throws InvocationTargetException
  {
    String setMethodName = input ? "setInput" : "setOutput";
    
    Node<?> n = new ConcreteNode();
    
    Map<String, Edge<?>> portToChute = new LinkedHashMap<String, Edge<?>>();
    portToChute.put("5", new ConcreteEdge());
    portToChute.put("2", new ConcreteEdge());
    portToChute.put("10", new ConcreteEdge());
    
    for (Map.Entry<String, Edge<?>> entry : portToChute.entrySet())
    {
      invokeMethod(n, setMethodName, entry.getValue(), entry.getKey());
    }
    
    for (int i = 0; i <= 10; i++)
    {
      Edge<?> e = input ? n.getInput(Integer.toString(i)) : n.getOutput(Integer.toString(i));
      assertEquals(portToChute.get(Integer.toString(i)), e);
    }
  }
  
  /**
   * Tests that getInputs retur
   * 
   * @throws InvocationTargetException
   */
  @Test
  public void testGetInputs() throws InvocationTargetException
  {
    testGetXXXputs(true);
  }
  
  @Test
  public void testGetOutputs() throws InvocationTargetException
  {
    testGetXXXputs(false);
  }
  
  private void testGetXXXputs(boolean input) throws InvocationTargetException
  {
    Node<ConcreteEdge> n = new ConcreteNode();
    
    // Tests that get___s() works with empty edge set
    assertTrue((input ? n.getInputs() : n.getOutputs()).isEmpty());
    
    Map<String, ConcreteEdge> portToChute = new HashMap<String, ConcreteEdge>();
    portToChute.put("3", new ConcreteEdge());
    portToChute.put("100", new ConcreteEdge());
    portToChute.put("0", new ConcreteEdge());
    
    for (Map.Entry<String, ConcreteEdge> entry : portToChute.entrySet())
    {
      if (input)
        n.setInput(entry.getValue(), entry.getKey());
      else
        n.setOutput(entry.getValue(), entry.getKey());
    }
    
    TreeMap<String, ConcreteEdge> inputs = input ? n.getInputs() : n.getOutputs();
    
    assertEquals(portToChute, inputs);
  }
}
