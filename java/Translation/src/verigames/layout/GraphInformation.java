package verigames.layout;

import static verigames.utilities.Misc.ensure;

import org.checkerframework.checker.nullness.qual.EnsuresNonNullIf;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * An immutable class that stores information about a Graphviz graph.
 * <p>
 * All coordinates and dimensions are stored in hundredths of typographical
 * points. Points are Graphviz's default units.
 * <p>
 * Positions are given using the bottom left as the origin, with X increasing to
 * the right, and Y increasing upwards. They give the location of the center of
 * the node.
 * <p>
 * In an undirected graph, the directionality of an edge is meaningless --
 * however, even in undirected graphs, Graphviz picks one node to be the start
 * of an edge, and this structure reflects this decision. Therefore, when
 * accessing the edges of an undirected graph, it is prudent to check both
 * directions.
 *
 * @author Nathaniel Mote
 */
class GraphInformation
{
  private final GraphAttributes graphAttributes;
  /** Map from the name of a node to its attributes */
  private final Map<String, NodeAttributes> nodeAttributes;
  /** Map from an edge's label to its attributes */
  private final Map<String, EdgeAttributes> edgeAttributes;

  /**
   * Creates a new GraphInformation object with the given mappings from Node
   * UID to Intersection.
   * <p>
   * Private because it can only be created by a {@code Builder}
   */
  private GraphInformation(GraphAttributes graphAttributes,
                           Map<String, NodeAttributes> nodeAttributes,
                           Map<String, EdgeAttributes> edgeAttributes)
  {
    this.graphAttributes = graphAttributes;

    this.nodeAttributes = Collections
        .unmodifiableMap(new HashMap<String, NodeAttributes>(nodeAttributes));

    this.edgeAttributes = Collections.unmodifiableMap(
        new HashMap<String, EdgeAttributes>(edgeAttributes));
  }

  /**
   * Returns the attributes of the node with the given name.
   *
   * @param name
   * {@link #containsNode(String) containsNode(name)} must be true.
   *
   * @throws IllegalArgumentException if this does not contain a node with the
   * given name.
   */
  public NodeAttributes getNodeAttributes(String name)
  {
    if (!this.containsNode(name))
      throw new IllegalArgumentException("!this.containsNode(" + name + ")");

    return nodeAttributes.get(name);
  }

  /**
   * Returns the attributes of the graph itself.
   */
  public GraphAttributes getGraphAttributes()
  {
    return graphAttributes;
  }

  /**
   * Returns the attributes of the given edge.
   * <p>
   * {@code this} must contain an edge labeled {@code label}.
   *
   * @param label
   */
  public EdgeAttributes getEdgeAttributes(String label)
  {
    if (!this.containsEdge(label))
      throw new IllegalArgumentException("No edge with label \"" + label +
          "\"");

    return edgeAttributes.get(label);
  }

  /**
   * Returns a {@code Set<String>} containing all of the nodes in {@code this}.
   */
  public Set<String> getNodes()
  {
    // wrap it as unmodifiable once more in case the implementation changes,
    // even though nodeAttributes is also unmodifiable.
    return Collections.unmodifiableSet(nodeAttributes.keySet());
  }

  /**
   * Returns a {@code Set<Pair<String, String>>} containing all of the edges in
   * {@code this}.
   */
  public Set<String> getEdges()
  {
    // wrap it as unmodifiable once more in case the implementation changes,
    // even though edgeAttributes is also unmodifiable.
    return Collections.unmodifiableSet(edgeAttributes.keySet());
  }

  /**
   * Returns {@code true} iff {@code this} contains attributes for a node of
   * the given name
   *
   * @param name
   */
  public boolean containsNode(String name)
  {
    return nodeAttributes.containsKey(name);
  }

  /**
   * Returns {@code true} iff {@code this} contains an edge labeled {@code
   * label}
   *
   * @param label
   */
  public boolean containsEdge(String label)
  {
    return edgeAttributes.containsKey(label);
  }

  /**
   * Returns {@code true} iff {@code this} and {@code other} are equal in
   * value.
   */
  @Override
  public boolean equals(/*@Nullable*/ Object other)
  {
    if (other instanceof GraphInformation)
    {
      GraphInformation g = (GraphInformation) other;

      return this.getGraphAttributes().equals(g.getGraphAttributes())
          && this.nodeAttributes.equals(g.nodeAttributes)
          && this.edgeAttributes.equals(g.edgeAttributes);
    }
    else
    {
      return false;
    }
  }

  @Override
  public int hashCode()
  {
    return graphAttributes.hashCode() * 71 +
        nodeAttributes.hashCode() * 31 +
        edgeAttributes.hashCode();
  }

  @Override
  public String toString()
  {
    return "graph:" + graphAttributes.toString() + ";nodes:" +
        nodeAttributes.toString();
  }

  /**
   * A {@code Builder} for a {@code GraphInformation} object.
   *
   * @author Nathaniel Mote
   */
  public static class Builder
  {
    /* these first three fields are the same as those of GraphInformation
     * itself, except that these are intended to be mutated. */
    private /*@LazyNonNull*/ GraphAttributes graphAttributes = null;
    private final Map<String, NodeAttributes> nodeAttributes;
    private final Map<String, EdgeAttributes> edgeAttributes;

    private NodeDefaults nodeDefaults;

    public Builder()
    {
      nodeAttributes = new HashMap<String, NodeAttributes>();
      edgeAttributes = new HashMap<String, EdgeAttributes>();
      // no node defaults
      nodeDefaults = new NodeDefaults(null, null);
    }

    /**
     * Sets the properties of this graph to those defined by
     * {@code attributes}.
     * <p>
     *
     * @return the previous GraphAttributes object, or null if none existed
     */
    // This may need to be changed somehow because graph attributes can be
    // split across multiple lines in DOT. Maybe a way to merge them or
    // something? This will have to be solved if it is necessary to include
    // more than just the "bb" attribute
    public /*@Nullable*/ GraphAttributes setGraphAttributes(GraphAttributes attributes)
    {
      GraphAttributes oldAttrs = this.graphAttributes;

      this.graphAttributes = attributes;

      return oldAttrs;
    }

    /**
     * Returns true iff the graph attributes have been set
     */
    @EnsuresNonNullIf(expression="this.graphAttributes", result=true)
    public boolean areGraphAttributesSet()
    {
      return graphAttributes != null;
    }

    /**
     * Sets the node defaults. These defaults will be used whenever an {@link
     * AbstractNodeAttributes} object does not have a necessary field.
     *
     * If a default is not given, the previous default for that setting is used.
     */
    public void setNodeDefaults(NodeDefaults newDefaults)
    {
      this.nodeDefaults = this.nodeDefaults.mergeWith(newDefaults);
    }

    /**
     * Sets the attributes associated with the node with the given name.
     */
    public void setNodeAttributes(String name, AbstractNodeAttributes<?> attributes)
    {
      NodeAttributes mergedAttributes = mergeAttributes(attributes, nodeDefaults);
      nodeAttributes.put(name, mergedAttributes);
    }

    private static NodeAttributes mergeAttributes(AbstractNodeAttributes<?> attributes, NodeDefaults defaults)
    {
      Integer x = attributes.getX();
      Integer y = attributes.getY();
      Integer width = attributes.getWidth();
      Integer height = attributes.getHeight();

      if (width == null)
        width = defaults.getWidth();
      if (height == null)
        height = defaults.getHeight();

      if (x == null)
        throw new IllegalArgumentException("x is unset and not provided by default attributes " + defaults);
      if (y == null)
        throw new IllegalArgumentException("y is unset and not provided by default attributes " + defaults);
      if (width == null)
        throw new IllegalArgumentException("width is unset and not provided by default attributes " + defaults);
      if (height == null)
        throw new IllegalArgumentException("height is unset and not provided by default attributes " + defaults);

      return new NodeAttributes(x, y, width, height);
    }

    /**
     * Sets the attributes associated with the edge labeled {@code label}.
     *
     * @param label
     * The label for this edge
     */
    public void setEdgeAttributes(String label, EdgeAttributes attributes)
    {
      edgeAttributes.put(label, attributes);
    }

    /**
     * Returns a GraphInformation object with the attributes that have been added to
     * this {@code Builder}.
     * <p>
     * Requires {@link Builder#areGraphAttributesSet()}
     */
    public GraphInformation build()
    {
      if (!areGraphAttributesSet())
        throw new IllegalStateException("graph attributes not yet set");

      return new GraphInformation(graphAttributes, nodeAttributes, edgeAttributes);
    }
  }

  /**
   * Defines an immutable object that stores the default attributes for a node.
   * <p>
   * A null reference indicates that there is no default value for a given
   * attribute.
   */
  public static class NodeDefaults
  {
    private final /*@Nullable*/ Integer width;
    private final /*@Nullable*/ Integer height;

    public NodeDefaults(/*@Nullable*/ Integer width, /*@Nullable*/ Integer height)
    {
      this.width = width;
      this.height = height;
    }

    public /*@Nullable*/ Integer getWidth()
    {
      return this.width;
    }

    public /*@Nullable*/ Integer getHeight()
    {
      return this.height;
    }

    /**
     * Returns a new {@code NodeDefaults} object equivalent to {@code
     * newDefaults}, but with any {@code null} field replaced with its value in
     * this object
     */
    public NodeDefaults mergeWith(NodeDefaults newDefaults)
    {
      /*@Nullable*/ Integer width = newDefaults.getWidth();
      /*@Nullable*/ Integer height = newDefaults.getHeight();
      if (width == null)
        width = this.getWidth();
      if (height == null)
        height = this.getHeight();

      return new NodeDefaults(width, height);
    }

    @Override
    public String toString()
    {
      return "NodeDefaults<width=" + getWidth() + ", height=" + getHeight() + ">";
    }
  }

  /**
   * An immutable record type that stores the width and the height of a
   * Graphviz graph in hundredths of points
   */
  public static class GraphAttributes
  {
    private final int width;
    private final int height;

    public GraphAttributes(int width, int height)
    {
      this.width = width;
      this.height = height;
    }

    /**
     * Returns the width of the graph.
     */
    public int getWidth()
    {
      return width;
    }

    /**
     * Returns the height of the graph.
     */
    public int getHeight()
    {
      return height;
    }

    @Override
    public boolean equals(/*@Nullable*/ Object other)
    {
      if (!(other instanceof GraphAttributes))
        return false;

      GraphAttributes g = (GraphAttributes) other;

      return this.getHeight() == g.getHeight()
          && this.getWidth() == g.getWidth();
    }

    @Override
    public int hashCode()
    {
      return width * 97 + height;
    }

    @Override
    public String toString()
    {
      return "width=" + getWidth() + ";height=" + getHeight();
    }
  }

  /**
   * An immutable record type containing attributes of a particular node
   */
  protected static abstract class AbstractNodeAttributes<E extends /*@Nullable*/ Integer>
  {
    private final E x;
    private final E y;
    private final E width;
    private final E height;

    public AbstractNodeAttributes(E x, E y, E width, E height)
    {
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
    }

    /**
     * Returns the x coordinate of the center of this node, in hundredths of points.
     */
    public E getX()
    {
      return x;
    }

    /**
     * Returns the y coordinate of the center of this node, in hundredths of points.
     */
    public E getY()
    {
      return y;
    }

    /**
     * Returns the width of this node, in hundredths of points.
     */
    public E getWidth()
    {
      return width;
    }

    /**
     * Returns the height of this node, in hundredths of points.
     */
    public E getHeight()
    {
      return height;
    }

    @Override
    public boolean equals(/*@Nullable*/ Object other)
    {
      if (other instanceof AbstractNodeAttributes)
      {
        AbstractNodeAttributes<?> g = (AbstractNodeAttributes<?>) other;

        return this.getX().equals(g.getX())
            && this.getY().equals(g.getY())
            && this.getHeight().equals(g.getHeight())
            && this.getWidth().equals(g.getWidth());
      }
      else
      {
        return false;
      }
    }

    @Override
    public int hashCode()
    {
      int hashCode = getX();
      hashCode *= 31;
      hashCode += getY();
      hashCode *= 31;
      hashCode += getWidth();
      hashCode *= 31;
      hashCode += getHeight();
      return hashCode;
    }

    @Override
    public String toString()
    {
      return "pos=(" + getX() + "," + getY() + ");width=" + getWidth() +
          ";height=" + getHeight();
    }
  }

  public static class NodeAttributes extends AbstractNodeAttributes<Integer>
  {
    public NodeAttributes(Integer x, Integer y, Integer width, Integer height)
    {
      super(x, y, width, height);
    }
  }

  public static class NullableNodeAttributes extends AbstractNodeAttributes</*@Nullable*/ Integer>
  {
    public NullableNodeAttributes(/*Nullable*/ Integer x, /*Nullable*/ Integer y, /*Nullable*/ Integer width, /*Nullable*/ Integer height)
    {
      super(x, y, width, height);
    }
  }

  /**
   * An immutable record type containing attributes of a particular edge
   */
  public static class EdgeAttributes
  {
    /**
     * Stores the control points for the spline. Should be instantiated as an
     * immutable list.
     * <p>
     * Must have length congruent to 1 (mod 3), as enforced by Graphviz.
     */
    private final List<GraphvizPointCoordinate> controlPoints;

    private void checkRep()
    {
      ensure(controlPoints.size() % 3 == 1,
          "Graphviz requires that the number of layout control points (" +
          controlPoints.size() + ") be congruent to 1 (mod 3)");
    }

    /**
     * Constructs a new {@code EdgeAttributes} object.
     * <p>
     * @param points
     * The control points for this edge's b-spline. {@code points.size() % 3}
     * must equal {@code 1}.
     */
    public EdgeAttributes(List<GraphvizPointCoordinate> points)
    {
      if (points.size() % 3 != 1)
        throw new IllegalArgumentException("Size of argument is " +
            points.size() + ". " + points.size() + " % 3 = " +
            (points.size() % 3) + " != 1");

      // Creates a new list containing the elements in points, where the only
      // view on it is an unmodifiable view. In effect, make it immutable.
      this.controlPoints = Collections.unmodifiableList(new ArrayList<GraphvizPointCoordinate>(points));

      checkRep();
    }

    public GraphvizPointCoordinate getCoordinates(int index)
    {
      checkBounds(index);
      return controlPoints.get(index);
    }

    private void checkBounds(int index)
    {
      if (index >= controlPoints.size())
        throw new IndexOutOfBoundsException("index " + index + " >= size ("
            + controlPoints.size() + ")");
    }

    public int controlPointCount()
    {
      return controlPoints.size();
    }

    @Override
    public boolean equals(/*@Nullable*/ Object o)
    {
      if (o instanceof EdgeAttributes)
      {
        EdgeAttributes e = (EdgeAttributes) o;

        return this.controlPoints.equals(e.controlPoints);
      }
      else
      {
        return false;
      }
    }

    @Override
    public int hashCode()
    {
      return controlPoints.hashCode();
    }
  }
}
