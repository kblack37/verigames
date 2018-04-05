package verigames.graph;

import static verigames.utilities.Misc.ensure;

import java.util.*;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * An immutable record type representing a node for a {@link verigames.graph.Graph
 * Graph}.
 * <p>
 * Specification Field: {@code inputs} : map from nonnegative integer to edge //
 * mapping from input port number to the edge attached at that port.
 * <p>
 * Specification Field: {@code outputs} : map from nonnegative integer to edge
 * // mapping from output port number to the edge attached at that port.
 * <p>
 * Specification Field: {@code underConstruction} : {@code boolean} // {@code true} iff
 * {@code this} can be part of a {@link verigames.graph.Graph Graph} that is still under
 * construction. Once {@code underConstruction} is set to {@code false}, {@code this}
 * becomes immutable.
 * <p>
 * Subclasses may enforce restrictions on the connections made to {@link Edge}s.
 * In particular, there may be restrictions on the number of ports particular
 * {@code Node}s have available.
 *
 * @param <EdgeType>
 * @author Nathaniel Mote
 */
// TODO add documentation about new String node identifiers (such as that they
// are stored in sorted order).
public abstract class Node<EdgeType extends Edge<? extends Node<EdgeType>>>
{
  /**
   * Stores the input ports.<p>
   *
   * Use of a {@code TreeMap} is enforced because it stores its entries in
   * sorted order.
   */
  private final TreeMap<String, EdgeType> inputs;

  /**
   * Stores the output ports.<p>
   *
   * Use of a {@code TreeMap} is enforced because it stores its entries in
   * sorted order.
   */
  private final TreeMap<String, EdgeType> outputs;

  private boolean underConstruction = true;

  // TODO update rep invariant
  /*
   * Representation Invariant:
   *
   * - if !inputs.isEmpty(), then inputs.get(inputs.size()-1) != null
   *
   * - if !outputs.isEmpty(), then outputs.get(outputs.size()-1) != null
   *
   * In other words, the last element in inputs and outputs must not be null
   *
   * - If !underConstruction:
   *    - no edge in inputs or outputs may be null
   *
   */

  private static final boolean CHECK_REP_ENABLED = verigames.utilities.Misc.CHECK_REP_ENABLED;

  /**
   * Ensures that the representation invariant holds
   */
  protected void checkRep()
  {
    if (!CHECK_REP_ENABLED)
      return;

    if (!underConstruction)
    {
      for (EdgeType e : inputs.values())
        ensure(e != null, "node input list has a null edge");
      for (EdgeType e : outputs.values())
        ensure(e != null, "node output list has a null edge");
    }

    // Note: Graph is responsible for ensuring that a particular node's
    // connections match that of the edges it is connected to (that is, the
    // edges that this is connected to must also be connected to this at the
    // appropriate ports).
    //
    // This is because there must be a point in time when the edge is
    // connected to the node, but the node is not connected to the edge, or
    // vice versa, simply because one operation must be done before the other,
    // and checkRep is called from the methods that perform those operations.
  }

  public Node()
  {
    inputs = new TreeMap<String, EdgeType>();
    outputs = new TreeMap<String, EdgeType>();
  }

  /**
   * Adds the given edge to {@code inputs} with the given port number.<br/>
   * <br/>
   * Requires:<br/>
   * - {@code this.underConstruction()}<br/>
   * <br/>
   * Modifies: {@code this}
   * <p>
   * Requires: There must not already be an {@link Edge} at the given input
   * port.
   *
   * @param input
   * The edge to attach to {@code this} as an input. This implementation does
   * not restrict what edges may be attached, but subclasses may.
   * @param port
   * The input port to which {@code input} will be attached. Must be
   * nonnegative. Must be a valid port number for {@code this}. This
   * implementation enforces no restrictions on what ports are valid (other
   * than that they must be nonnegative), but subclasses may.<br/>
   */
  protected void setInput(EdgeType input, String port)
  {
    if (!underConstruction)
      throw new IllegalStateException(
          "Mutation attempted on constructed Node");

    // TODO check that port is nonnegative
    if (getInput(port) != null)
      throw new IllegalArgumentException("Input port at port " + port + " already used");

    inputs.put(port, input);
    checkRep();
  }

  /**
   * Adds the given edge to {@code outputs} with the given port number.<br/>
   * <br/>
   * Requires:<br/>
   * - {@code this.underConstruction()}<br/>
   * <br/>
   * Modifies: {@code this}
   * <p>
   * Requires: There must not already be an {@link Edge} at the given output
   * port.
   *
   * @param output
   * The edge to attach to {@code this} as an output. This implementation does
   * not restrict what edges may be attached, but subclasses may.
   * @param port
   * The output port to which {@code output} will be attached. Must be
   * nonnegative. Must be a valid port number for {@code this}. This
   * implementation enforces no restrictions on what ports are valid (other
   * than that they must be nonnegative), but subclasses may.<br/>
   */
  protected void setOutput(EdgeType output, String port)
  {
    if (!underConstruction)
      throw new IllegalStateException(
          "Mutation attempted on constructed Node");

    // TODO check that port is nonnegative
    if (getOutput(port) != null)
      throw new IllegalArgumentException("Output port at port " + port + " already used");

    outputs.put(port, output);
    checkRep();
  }

  /**
   * Returns the edge at the given port, or {@code null} if none exists.
   * <p>
   * @param port
   * {@code port >= 0}
   */
  public /*@Nullable*/ EdgeType getInput(String port)
  {
    return inputs.get(port);
  }

  /**
   * Returns the edge at the given port, or {@code null} if none exists.
   * <p>
   * @param port
   * {@code port >= 0}
   */
  public /*@Nullable*/ EdgeType getOutput(String port)
  {
    return outputs.get(port);
  }

  /**
   * Deprecated. {@link #getInputIDs()} is preferred because the node ordering
   * is more flexible.<p>
   *
   * Returns a {@code TreeMap<Integer, EdgeType> m} from port number to input
   * edge. All keys are nonnegative. {@code m} and {@code this} will not be
   * affected by future changes to each other.
   */
  @Deprecated
  public TreeMap<String, /*@NonNull*/ EdgeType> getInputs()
  {
    return new TreeMap<String, /*@NonNull*/ EdgeType>(inputs);
  }

  /**
   * Deprecated. {@link #getOutputIDs()} is preferred because the node ordering
   * is more flexible.<p>
   *
   * Returns a {@code TreeMap<Integer, EdgeType> m} from port number to output
   * edge. All keys are nonnegative. {@code m} and {@code this} will not be
   * affected by future changes to each other.
   */
  @Deprecated
  public TreeMap<String, /*@NonNull*/ EdgeType> getOutputs()
  {
    return new TreeMap<String, /*@NonNull*/ EdgeType>(outputs);
  }

  /**
   * Returns a {@code List<String>} containing all of the input port IDs for
   * this {@code Node}.<p>
   *
   * It is guaranteed that a call to {@link #getInput(String)} will succeed when
   * passed any element in the returned {@code List} as an argument.<p>
   *
   * The order in which they appear will be consistent (that is, if no input
   * ports have been added between two calls, the order will be the same).
   * Beyond this, there is no guarantee of order, though implementations may
   * provide a stronger guarantee.
   */
  public List<String> getInputIDs()
  {
    List<String> portsList = new ArrayList<String>();
    for (String port : inputs.keySet())
      portsList.add(port);
    return Collections.unmodifiableList(portsList);
  }

  /**
   * Returns a {@code List<String>} containing all of the output port IDs for
   * this {@code Node}.<p>
   *
   * It is guaranteed that a call to {@link #getInput(String)} will succeed when
   * passed any element in the returned {@code List} as an argument.<p>
   *
   * The order in which they appear will be consistent (that is, if no output
   * ports have been added between two calls, the order will be the same).
   * Beyond this, there is no guarantee of order, though implementations may
   * provide a stronger guarantee.
   */
  public List<String> getOutputIDs()
  {
    List<String> portsList = new ArrayList<String>();
    for (String port : outputs.keySet())
      portsList.add(port);
    return Collections.unmodifiableList(portsList);
  }

  /**
   * Returns {@code underConstruction}
   */
  public boolean underConstruction()
  {
    return underConstruction;
  }

  /**
   * Sets {@code underConstruction} to {@code false}<br/>
   * <br/>
   * Requires:<br/>
   * - {@code this.underConstruction()}<br/>
   * - There are no empty ports. That is, for the highest filled port (for both
   * inputs and outputs), there are no empty ports below it.<br/>
   * - Other implementations may enforce additional restrictions on the number
   *   of input or output ports that must be filled when construction is
   *   finished.
   */
  protected void finishConstruction()
  {
    if (!underConstruction)
      throw new IllegalStateException("Attempt to finish construction made Node that has already been finished: " + this);

    underConstruction = false;
    checkRep();
  }

  /**
   * Returns a {@code String} representation of {@code this} that does not
   * include its connections to {@link Edge Edges}.
   */
  protected String shallowToString()
  {
    // by default, just return the ugly Object.toString(), because this
    // implementation doesn't have much identifying information.
    return super.toString();
  }

  @Override
  public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append(shallowToString() + " -- inputs: ");
    builder.append(portMapToString(getInputs()));
    builder.append(" outputs: ");
    builder.append(portMapToString(getOutputs()));
    return builder.toString();
  }

  /**
   * no null keys or values
   */
  private static <EdgeType extends Edge<?>> String portMapToString(Map<String, EdgeType> map)
  {
    StringBuilder builder = new StringBuilder();

    for (Map.Entry<String, EdgeType> entry : map.entrySet())
    {
      String port = entry.getKey();
      EdgeType edge = entry.getValue();

      builder.append("port " + port + ": " + edge.shallowToString() + ", ");
    }

    if (builder.length() >= 2)
      builder.delete(builder.length() - 2, builder.length());

    return "[" + builder.toString() + "]";
  }
}
