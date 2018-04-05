package verigames.graph;

import static verigames.utilities.Misc.ensure;

import java.util.*;

import verigames.utilities.Misc;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * A mutable graph structure capable of storing data in both the edges and the
 * nodes. It keeps track of the specific node ports to which edges attach.
 * <p>
 * Once {@code finishConstruction()} is called, its structure becomes immutable, though
 * the data that the nodes and edges contain may still mutate in such a way that
 * they do not change the structure of the {@code Graph}.
 * <p>
 * Specification Field: {@code nodes} : {@code Set<NodeType>}
 * // the set of nodes contained in {@code this}<br/>
 * Specification Field: {@code edges} : {@code Set<EdgeType>}
 * // the set of edges contained in {@code this}
 * <p>
 * Specification Field: {@code underConstruction} : {@code boolean} // {@code true} iff
 * {@code this} can still be modified. Once {@code underConstruction} is set to
 * {@code false}, {@code this} becomes immutable.
 *
 * @param <NodeType>
 * The type of the nodes in {@code this}. Its edge type must be {@code EdgeType}
 * @param <EdgeType>
 * The type of the edges in {@code this}. Its node type must be {@code NodeType}
 *
 * @author Nathaniel Mote
 */

public class Graph<NodeType extends Node<EdgeType>, EdgeType extends Edge<NodeType>>
{
  private final Set<NodeType> nodes;
  private final Set<EdgeType> edges;
  private boolean underConstruction = true;

  /**
   * Constructs a new, underConstruction {@code Graph} with no nodes or edges.
   */
  public Graph()
  {
    nodes = new LinkedHashSet<NodeType>();
    edges = new LinkedHashSet<EdgeType>();
  }

  private static final boolean CHECK_REP_ENABLED = verigames.utilities.Misc.CHECK_REP_ENABLED;

  /**
   * Ensures that the representation invariant holds.
   */
  protected void checkRep()
  {
    if (!CHECK_REP_ENABLED)
      return;

    // Representation Invariant:

    // nodes != null:
    ensure(nodes != null, "Graph node set must not be null");
    // edges != null
    ensure(edges != null, "Graph edge set must not be null");

    // for all n in nodes; e in edges:
    // e.getStart() == n <--> n.getOutput(e.getStartPort()) == e
    // e.getEnd() == n <--> n.getInput(e.getEndPort()) == e
    // this.underConstruction() == e.underConstruction()
    // this.underConstruction() == n.underConstruction()
    for (EdgeType e : edges)
    {
      NodeType n = e.getStart();
      // e.getStart() != null
      ensure(n != null, "Edge <" + e + "> in Graph has a null start node");
      // e.getStart() == n --> n.getOutput(e.getStartPort()) == e
      ensure(n.getOutput(e.getStartPort()) == e,
          "Edge e <" + e + ">' start Node <" + n +
          "> does not list e as an output");

      n = e.getEnd();
      // e.getEnd() != null
      ensure(n != null, "Edge <" + e + "> in Graph has a null end node");
      // e.getEnd() == n --> n.getInput(e.getEndPort()) == e
      ensure(n.getInput(e.getEndPort()) == e,
          "Edge e <" + e + ">'s end Node <" + n +
          "> does not list e as an input");

      // this.underConstruction() == e.underConstruction()
      ensure(this.underConstruction() == e.underConstruction(),
          "Graph and Edge do not agree about whether they are under " +
          "construction: Graph: " + this.underConstruction() + " Edge: " +
          e.underConstruction());
    }

    for (NodeType n : nodes)
    {
      for (String nodePort : n.getOutputIDs())
      {
        EdgeType e = n.getOutput(nodePort);

        // e.getStart() == n <-- n.getOutput(e.getStartPort()) == e
        ensure(nodePort.equals(e.getStartPort()),
            "Port ID recorded in node <" + nodePort +
            "> does not match port ID recorded in edge <" + e.getStartPort()
            + ">");

        ensure(e.getStart() == n, "node <" + n +
            "> should be equal to its output edge's start node <" +
            e.getStart() + ">");
      }

      for (String nodePort : n.getInputIDs())
      {
        EdgeType e = n.getInput(nodePort);

        // e.getEnd() == n <-- n.getInput(e.getEndPort()) == e
        ensure(nodePort.equals(e.getEndPort()),
            "Port ID recorded in node <" + nodePort +
            "> does not match port ID recorded in edge <" + e.getEndPort()
            + ">");
        ensure(e.getEnd() == n, "node <" + n +
            "> should be equal to its input edge's end node <" +
            e.getEnd() + ">");
      }

      // this.underConstruction() == n.underConstruction()
      ensure(this.underConstruction() == n.underConstruction(),
          "Graph and Node do not agree about whether they are under " +
          "construction: Graph: " + this.underConstruction() + " Node: " +
          n.underConstruction());
    }
  }

  /**
   * Adds {@code node} to {@code this}.<br/>
   * <br/>
   * Requires:<br/>
   * - {@link #underConstruction()}<br/>
   * - {@code node} can be added to {@code this}. This implementation allows
   * any node to be added, but subclasses are free to enforce arbitrary
   * restrictions on nodes to be added.<br/>
   * <br/>
   * Modifies: {@code this}
   *
   * @param node
   * The node to add. Must be underConstruction, must not be contained in {@code this},
   * and must implement eternal equality.
   */
  public void addNode(NodeType node)
  {
    if (!underConstruction)
      throw new IllegalStateException("Mutation attempted on an constructed Graph");
    if (!node.underConstruction())
      throw new IllegalStateException("Fully constructed node added to Graph");

    if (this.contains(node))
      throw new IllegalArgumentException(
          "this already contains given node");

    nodes.add(node);
    if (Misc.CHECK_REP_FAIL_FAST) {
        checkRep();
    }
  }

  /**
   * Adds an edge from {@code startPort} on {@code start} to {@code endPort} on
   * {@code end}.<br/>
   * <br/>
   * Modifies: {@code start}, {@code end}, and {@code edge} to reflect their
   * new connections.<br/>
   * <br/>
   * Requires:<br/>
   * - {@link #underConstruction()}<br/>
   *
   * @param start
   * The node at which the edge will start. Must be underConstruction, and must be
   * contained in {@code this}.
   * @param startPort
   * The port at which the added edge will start. The output port of this
   * number on {@code start} must be empty. The standard implementation of
   * {@link Node} enforces no further restrictions on what ports are valid, but
   * subclasses may.
   * @param end
   * The node at which the edge will end. Must be underConstruction, and must be contained
   * in {@code this}.
   * @param endPort
   * The port at which the added edge will end. The input port of this number
   * on {@code end} must be empty. The standard implementation of {@link Node}
   * enforces no further restrictions on what ports are valid, but subclasses
   * may.
   * @param edge
   * The edge to add. Must be underConstruction, have no start or end nodes, and must not
   * be contained in {@code this}. This implementation enforces no further
   * restrictions on what edges can be added or what nodes they can be
   * connected to, but subclasses may.
   */
  public void addEdge(NodeType start, String startPort, NodeType end, String endPort,
      EdgeType edge)
  {
    // begin precondition checks
    if (!underConstruction)
      throw new IllegalStateException("Mutation attempted on an constructed Graph");
    if (!start.underConstruction())
      throw new IllegalArgumentException("Fully constructed start node " + start);
    if (!end.underConstruction())
      throw new IllegalArgumentException("Fully constructed end node " + end);
    if (!edge.underConstruction())
      throw new IllegalArgumentException("Fully constructed edge " + edge);

    if (!this.contains(start))
      throw new IllegalArgumentException(
          "Start node not in this Graph " + start);
    if (!this.contains(end))
      throw new IllegalArgumentException(
          "End node not in this Graph " + end);
    if (this.contains(edge))
      throw new IllegalArgumentException(
          "Edge already in this Graph " + edge);
    if (edge.getStart() != null || edge.getEnd() != null)
    {
      /*@Nullable*/ NodeType oldStart = edge.getStart();
      /*@Nullable*/ NodeType oldEnd = edge.getEnd();

      String message = "Given Edge already connected to Node";
      if (oldStart != null && oldEnd != null)
        message += "s"; // pluralize "Node"
      message += ":";

      if (oldStart != null)
        message += " start " + oldStart;
      if (oldEnd != null)
        message += " end " + oldEnd;

      throw new IllegalArgumentException(message);
    }

    if (start.getOutput(startPort) != null)
      throw new IllegalArgumentException(
          "Start Node already connected to Edge on port " + startPort + ": " + start.getOutput(startPort) + " Graph=" + toString());
    if (end.getInput(endPort) != null)
      throw new IllegalArgumentException(
          "End Node already connected to Edge on port " + endPort + ": " + end.getInput(endPort) + " Graph=" + toString());
    // end precondition checks

    edges.add(edge);

    start.setOutput(edge, startPort);
    end.setInput(edge, endPort);

    edge.setStart(start, startPort);
    edge.setEnd(end, endPort);

    if (Misc.CHECK_REP_FAIL_FAST) {
        checkRep();
    }
  }

  /**
   * Returns the cardinality of {@code nodes}.<br/>
   * <br/>
   * May be more efficient than {@code getNodes().size()}
   */
  public int nodesSize()
  {
    return nodes.size();
  }

  /**
   * Returns the cardinality of {@code edges}<br/>
   * <br/>
   * May be more efficient than {@code getEdges().size()}
   */
  public int edgesSize()
  {
    return edges.size();
  }

  /**
   * Returns a {@code Set<NodeType>} with all nodes in {@code this}. The
   * returned set will not be affected by future changes to {@code this}, and
   * changes to the returned set will not affect {@code this}.
   */
  public Set<NodeType> getNodes()
  {
    return new LinkedHashSet<NodeType>(nodes);
  }

  /**
   * Returns a {@code Set<EdgeType>} with all edge objects in {@code this}. The returned set
   * will not be affected by future changes to {@code this}, and changes to the
   * returned set will not affect {@code this}.
   */
  public Set<EdgeType> getEdges()
  {
    return new LinkedHashSet<EdgeType>(edges);
  }

  /**
   * Returns {@code true} iff {@code nodes} contains {@code elt} or
   * {@code edges} contains {@code elt}<br/>
   * <br/>
   * May be more efficient than
   * {@code getNodes().contains(elt) || getEdges.contains(elt)}
   */
  public boolean contains(Object elt)
  {
    return nodes.contains(elt) || edges.contains(elt);
  }

  /**
   * Returns true if and only if this graph is acyclic.<p>
   */
  public boolean isAcyclic()
  {
    /* Strategy: Attempt a topological sort. If it succeeds, there are no
     * cycles. If it fails, there are cycles. Runs in O(n+e) time, where n is
     * the number of nodes, and e is the number of edges */

    /* Adapted from Data Structures and Algorithm Analysis in Java 2E (Weiss) */
    // maps from node to its indegree
    Map<NodeType, Integer> indegreeMap = getIndegrees();

    Queue<NodeType> indegreeZero = new LinkedList<NodeType>();

    for (Map.Entry<NodeType, Integer> entry : indegreeMap.entrySet())
    {
      NodeType n = entry.getKey();
      int indegree = entry.getValue();

      if (indegree == 0)
        indegreeZero.add(n);
    }

    int removedNodeCount = 0;

    // while nodes with indegree 0 remain
    while (!indegreeZero.isEmpty())
    {
      NodeType n = indegreeZero.remove();
      removedNodeCount++;

      for (String portID : n.getOutputIDs())
      {
        EdgeType e = n.getOutput(portID);
        NodeType nextNode = e.getEnd();

        // decrement the next node's indegree
        int nextNodeIndegree = indegreeMap.get(nextNode) - 1;
        indegreeMap.put(nextNode, nextNodeIndegree);

        if (nextNodeIndegree < 0)
          throw new RuntimeException(
              "internal error: negative indegree calculated");

        if (nextNodeIndegree == 0)
          indegreeZero.add(nextNode);
      }
    }

    return removedNodeCount == nodesSize();
  }

  /**
   * Returns a mutable map from indegree to a set of nodes that have that
   * indegree.
   */
  private Map<NodeType, Integer> getIndegrees()
  {
    Map<NodeType, Integer> m = new HashMap<NodeType, Integer>();

    for (NodeType n : getNodes())
    {
      int indegree = n.getInputIDs().size();
      m.put(n, indegree);
    }

    return m;
  }

  /**
   * Returns {@code underConstruction}
   */
  public boolean underConstruction()
  {
    return underConstruction;
  }

  /**
   * Sets underConstruction to {@code false}<br/>
   * <br/>
   * Requires:<br/>
   * For all nodes, there are no empty ports. That is, for the highest filled
   * port (for both inputs and outputs), there are no empty ports below it.<br/>
   */
  public void finishConstruction()
  {
    if (underConstruction)
    {
      underConstruction = false;
      for (NodeType i : nodes)
        i.finishConstruction();
      for (EdgeType c : edges)
        c.finishConstruction();
    }
    checkRep();
  }

}
