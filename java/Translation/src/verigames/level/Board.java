package verigames.level;

import verigames.graph.Graph;
import verigames.layout.LayoutDebugger;
import verigames.level.Intersection.Kind;
import verigames.utilities.Pair;

import java.io.File;
import java.util.Set;

import static verigames.utilities.Misc.ensure;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * A board for Pipe Jam. It is a {@link verigames.graph.Graph Graph} with {@link
 * Intersection}s as nodes and {@link Chute}s as edges. It stores data in both
 * the nodes and the edges.<p>
 *
 * It must be a Directed Acyclic Graph (DAG).<p>
 *
 * The first node added must be an {@code Intersection} of {@link
 * Intersection.Kind Kind} {@link Intersection.Kind#INCOMING INCOMING}.<p>
 *
 * Specification Field: {@code incomingNode} -- {@link Intersection}
 * // the node representing the top of the board, where all the incoming chutes
 * enter. {@code Intersections} of {@code Kind} can be the starting point for an
 * arbitrary number of chutes.<p>
 *
 * Specification Field: {@code outgoingNode} -- {@link Intersection}
 * // the node representing the bottom of the board, where all the outgoing
 * chutes exit. {@code Intersections} of {@code Kind} can be the starting point
 * for an arbitrary number of chutes.
 *
 * @author Nathaniel Mote
 */

public class Board extends Graph<Intersection, Chute>
{
  private static final boolean CHECK_REP_ENABLED = verigames.utilities.Misc.CHECK_REP_ENABLED;

  private /*@LazyNonNull*/ Intersection incomingNode;
  private /*@LazyNonNull*/ Intersection outgoingNode;

  /**
   * This field has been added only to identify a board while debugging
   */
  private /*@Nullable*/ String name;

  /**
   * Ensures that the representation invariant holds
   */
  @Override
  protected void checkRep()
  {
    super.checkRep();

    if (!CHECK_REP_ENABLED)
      return;

    Set<Intersection> nodes = getNodes();

    // Representation Invariant:

    // if incomingNode is not null, its Kind must be INCOMING
    if (incomingNode != null)
      ensure(incomingNode.getIntersectionKind() == Kind.INCOMING,
          "Incoming node is not of kind INCOMING");

    // if outgoingNode is not null, its Kind must be OUTGOING
    if (outgoingNode != null)
      ensure(outgoingNode.getIntersectionKind() == Kind.OUTGOING,
          "Outgoing node is not of kind OUTGOING");

    // if nodes is non-empty, incomingNode must be non-null, because the
    // incoming node must be added first.
    ensure(nodes.isEmpty() || incomingNode != null,
        "Incoming node was not the first node added");

    for (Intersection i : nodes)
    {
      if (i.getIntersectionKind() == Kind.INCOMING)
      {
        // nodes may contain no more than one Node of Kind INCOMING
        ensure(incomingNode == i, "More than one incoming node present");
      }
      else if (i.getIntersectionKind() == Kind.OUTGOING)
      {
        // nodes may contain no more than one Node of Kind OUTGOING
        ensure(outgoingNode == i, "More than one outgoing node present");
      }
    }

    // incomingNode != null <--> nodes contains incomingNode
    ensure((incomingNode != null) == nodes.contains(incomingNode),
        "(internal error) incomingNode not present in nodes");
    // outgoingNode != null <--> nodes contains outgoingNode
    ensure((outgoingNode != null) == nodes.contains(outgoingNode),
        "(internal error) outgoingNode not present in nodes");

    // if this is constructed
    if (!this.underConstruction())
    {
      // incomingNode and outgoingNode must be non-null
      ensure(incomingNode != null,
          "No incoming node present even though construction is finished");
      ensure(outgoingNode != null,
          "No outgoing node present even though construction is finished");
    }
  }

  /**
   * Creates a new, empty {@code Board}
   */
  public Board()
  {
    this.name = "NotInited";
    checkRep();
  }

  /**
    *
    */
  public Board(final String name) {
    this();
    this.name = name;
  }

  /**
   * Jonathan added this temporarily for debug purposes.  Though, he advises we keep this in.
   * @return
   */
  public String getName() {
      return name;
  }

  /**
   * Returns {@code this}'s {@code incomingNode}, or {@code null} if it does not
   * have one
   */
  public /*@Nullable*/ Intersection getIncomingNode()
  {
    return incomingNode;
  }

  /**
   * Returns {@code this}'s {@code outgoingNode}, or {@code null} if it does not
   * have one
   */
  public /*@Nullable*/ Intersection getOutgoingNode()
  {
    return outgoingNode;
  }

  /**
   * Adds {@code node} to {@code this}.<br/>
   * <br/>
   * Requires:<br/>
   * - if {@link #getNodes() getNodes()}{@code .isEmpty()}, {@code node} must have
   * {@link Intersection.Kind Kind} {@link Intersection.Kind#INCOMING INCOMING}<br/>
   * - if {@link #getIncomingNode()} {@code != null} then {@code node} must not
   * have {@link Intersection.Kind Kind} {@link Intersection.Kind#INCOMING
   * INCOMING}<br/>
   * - if {@link #getOutgoingNode()} {@code != null} then {@code node} must not
   * have {@link Intersection.Kind Kind} {@link Intersection.Kind#OUTGOING
   * OUTGOING}<br/>
   *
   * @param node
   * The {@link Intersection} to add.
   */
  @Override
  public void addNode(Intersection node)
  {
    if (incomingNode == null && node.getIntersectionKind() != Kind.INCOMING)
      throw new IllegalArgumentException(
          "First node in Board is not of kind INCOMING: " + node);

    if (node.getIntersectionKind() == Kind.INCOMING)
    {
      if (incomingNode != null)
        throw new IllegalArgumentException(
            "Second INCOMING node added (no more than one is legal): " +
                node);

      incomingNode = node;
    }

    else if (node.getIntersectionKind() == Kind.OUTGOING)
    {
      if (outgoingNode != null)
        throw new IllegalArgumentException(
            "Second OUTGOING node added (no more than one is legal): " +
                node);

      outgoingNode = node;
    }

    if (node.getBoard() != null)
    {
      throw new IllegalArgumentException(
          "Node is already assigned to a board: " + node);
    }
    else
    {
      node.setBoard(this);
    }

    super.addNode(node);
  }


  //The methods below here are all just sugar for commonly used sequences of instructions
  //in GameSolver and it's subclasses

  /**
   * Creates an intersection of the given kind.  Adds it to the board and then returns it.
   * @param kind The Intersection kind of the node to be created
   * @return A new node that has already been added to the board and has type kind
   */
  public Intersection addNode(final Intersection.Kind kind) {
      final Intersection node = Intersection.factory(kind);
      addNode(node);
      return node;
  }

 /**
  * Create the intersection nodes for start and end and add them to the board.  Then add
  * an edge to the board from start to end using the given ports and chute.
  * @param start Kind of start node to be created
  * @param startPort Port of start node
  * @param end Kind of end node to be created
  * @param endPort Port of end node
  * @param chute
  * @return A pair of newly created nodes which have been added to the board with an edge between them: Pair(startNode, endNode)
  */
  public Pair<Intersection, Intersection> add(final Intersection.Kind start, final String startPort,
                                              final Intersection.Kind end,   final String endPort,
                                              final Chute chute) {
    final Intersection startInt = addNode(start);
    return add(startInt, startPort, end, endPort, chute);
  }

  /**
   * Create an intersection node for the given end kind and add it to the board.
   * Then add an edge to the board from start to end using the given ports and chute.
   * @param startInt Start node that has already been created, will be added to the board if it hasn't been already
   * @param startPort Port of start node
   * @param end Kind of end node to be created
   * @param endPort Port of end node
   * @param chute
   * @return The pair of nodes which have been added to the board with an edge between them: Pair(startNode, endNode)
   */
  public Pair<Intersection, Intersection> add(final Intersection startInt, final String startPort,
                                               final Intersection.Kind end, final String endPort,
                                               final Chute chute) {
    final Intersection endInt = addNode(end);
    return add(startInt, startPort, endInt, endPort, chute);
  }

    /**
     * Create an intersection node for the given start kind and add it to the board.  Then add
     * an edge to the board from start to end using the given ports and chute.
     * @param start Kind of start node to be created
     * @param startPort Port of start node
     * @param endInt End node that has already been created, will be added to the board if it hasn't been already
     * @param endPort Port of end node
     * @param chute
     * @return The pair of nodes which have been added to the board with an edge between them: Pair(startNode, endNode)
     */
  public Pair<Intersection, Intersection> add(final Intersection.Kind start, final String startPort,
                                               final Intersection endInt,     final String endPort,
                                               final Chute chute) {
    final Intersection startInt = addNode(start);
    return add(startInt, startPort, endInt, endPort, chute);
  }

    /**
     * Then add an edge from startInt to endInt to the board
     * @param startInt Start node that has already been created, will be added to the board if it hasn't been already
     * @param startPort Port of start node
     * @param endInt End node that has already been created, will be added to the board if it hasn't been already
     * @param endPort Port of end node
     * @param chute
     * @return The pair of nodes which have been added to the board with an edge between them: Pair(startNode, endNode)
     */
  public Pair<Intersection, Intersection> add(final Intersection startInt, final String startPort,
                                               final Intersection endInt,   final String endPort,
                                               final Chute chute) {
      addEdge(startInt, startPort, endInt, endPort, chute);
      return Pair.of(startInt, endInt);
  }

  /**
   * @inheritDoc
   *
   * @throws {@link CycleException} if the graph contains a cycle.
   */
  @Override
  public void finishConstruction()
  {
    super.finishConstruction();
    if (!this.isAcyclic()) {
      try {
          System.out.println("Printing cyclic board: " + this.getName());
          System.out.flush();
          final String outDir = System.getProperty("user.dir");
          final String boardName = LayoutDebugger.layout("cyclicBoard", this, outDir);
          System.out.println("Printed to: " + (new File(outDir, boardName)));
      } catch(Exception exc) {
          throw new RuntimeException("Exception trying to print cyclic board.  Board=" + getName(), exc);
      }

      throw new CycleException("Board=" + getName());
    }
  }

  @Override
  public String toString() {
      return getName() + ": " + super.toString();
  }
}
