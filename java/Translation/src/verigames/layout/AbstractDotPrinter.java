package verigames.layout;


import java.io.PrintStream;

import verigames.graph.Node;
import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.utilities.Printer;

/**
 * Prints fully constructed {@link verigames.level.Board Board} objects in Graphviz's <a
 * href="http://en.wikipedia.org/wiki/DOT_language">DOT format</a>.
 * <p>
 * Other than that, the specifics of how a graph is represented are determined
 * by the implementation.
 * <p>
 * To provide an implementation of an {@code AbstractDotPrinter}, subclasses
 * must do the following:
 * <ul>
 * <li>
 * Implement {@link #isDigraph(Board)}, {@link #nodeSettings(Board)}, {@link
 * #edgeSettings(Board)}, {@link #graphSettings(Board)}.
 * </li>
 * <li>
 * Call the constructor with a {@link verigames.utilities.Printer Printer} for
 * {@link Intersection}s and a {@code Printer} for {@link Chute}s.
 * </li>
 * </ul>
 *
 * @author Nathaniel Mote
 */
abstract class AbstractDotPrinter extends Printer<Board, Void>
{

  /**
   * Returns max(number of input ports, number of output ports) for {@code n}.
   * <p>
   * Included for use in subclasses
   *
   *
   * @param n
   */
  protected static int getMaxPorts(Node<?> n)
  {
    return Math.max(n.getInputIDs().size(), n.getOutputIDs().size());
  }

  /**
   * The {@link Printer} used for printing {@link Intersection}s.
   */
  private final Printer<Intersection, Board> nodePrinter;
  /**
   * The {@link Printer} used for printing {@link Chute}s.
   */
  private final Printer<Chute, Board> edgePrinter;

  /**
   * Stores whether the graph currently being printed is a directed graph.
   *
   * Used essentially as a cache for {@link #isDigraph()}, so that the method is
   * called only once per print. This shields from inconsistent implementations,
   * and ensures that each call to print has a consistent edgeop, for example.
   */
  private boolean isDigraph;

  /**
   * Constructs a new GraphvizPrinter.
   *
   * @param nodePrinter
   * The {@link verigames.utilities.Printer} used to output nodes. Must use an {@link
   * verigames.level.Intersection}'s {@code UID} as the node identifier for Graphviz.
   *
   * @param edgePrinter
   * The {@link verigames.utilities.Printer} used to output edges
   */
  protected AbstractDotPrinter(Printer<Intersection, Board> nodePrinter, Printer<Chute, Board> edgePrinter)
  {
    this.nodePrinter = nodePrinter;
    this.edgePrinter = edgePrinter;
  }

  /**
   * {@inheritDoc}
   *
   * @param b
   * {@link verigames.level.Board#underConstruction() b.underConstruction()} must be false.
   */
  @Override
  public void print(Board b, PrintStream out, Void data)
  {
    if (b.underConstruction())
      throw new IllegalArgumentException("b.underConstruction()");

    // set the field isDigraph so that the method does not need to be called
    // again during printing
    this.isDigraph = isDigraph(b);

    super.print(b, out, data);
  }

  /**
   * {@inheritDoc}
   *
   * @param b
   * {@link verigames.level.Board#underConstruction() b.underConstruction()} must be false.
   */
  @Override
  protected void printIntro(Board b, PrintStream out, Void data)
  {
    if (b.underConstruction())
      throw new IllegalArgumentException("b.underConstruction()");

    String graphKind;
    if (this.isDigraph)
      graphKind = "digraph";
    else
      graphKind = "graph";

    out.println(graphKind + " {");

    out.println("node [" + nodeSettings(b) + "];");

    out.println("edge [" + edgeSettings(b) + "];");

    out.println("graph [" + graphSettings(b) + "];");
  }

  /**
   * Returns {@code true} iff the {@link verigames.level.Board Board} should be printed
   * as a directed graph.
   */
  // Note -- this should not be called directly. Instead, the field isDigraph
  // should be used. It is updated every time print is called. Using the field
  // ensures consistent results, even if the subclass's implementation of
  // isDigraph is inconsistent (i.e. returns different values for the same
  // {@code Board}).
  protected abstract boolean isDigraph(Board b);

  /**
   * Returns the {@code String} listing the default settings for a node in the
   * printed graph, or an empty {@code String} if no settings are to be defined.
   */
  protected abstract String nodeSettings(Board b);

  /**
   * Returns the {@code String} listing the default settings for a edge in the
   * printed graph, or an empty {@code String} if no settings are to be defined.
   */
  protected abstract String edgeSettings(Board b);

  /**
   * Returns the {@code String} listing the settings for the printed graph, or
   * an empty {@code String} if no settings are to be defined.
   */
  protected abstract String graphSettings(Board b);

  /**
   * {@inheritDoc}
   *
   * @param b
   * {@link verigames.level.Board#underConstruction() b.underConstruction()} must be false.
   */
  @Override
  protected void printMiddle(Board b, PrintStream out, Void data)
  {
    printNodes(b, out);

    printEdges(b, out);
  }

  /**
   * Prints {@code b}'s nodes to {@code out} in the DOT language
   *
   * @param b
   * @param out
   */
  private void printNodes(Board b, PrintStream out)
  {
    for (Intersection n : b.getNodes())
    {
      nodePrinter.print(n, out, b);
    }
  }

  /**
   * Prints {@code b}'s edges to {@code out} in the DOT language
   *
   * @param b
   * {@link verigames.level.Board#underConstruction() b.underConstruction()} must be false.
   * @param out
   */
  private void printEdges(Board b, PrintStream out)
  {
    for (Chute e : b.getEdges())
    {
      edgePrinter.print(e, out, b);
    }
  }

  /**
   * {@inheritDoc}
   *
   * @param b
   * {@link verigames.level.Board#underConstruction() b.underConstruction()} must be false.
   */
  @Override
  protected void printOutro(Board b, PrintStream out, Void data)
  {
    out.println("}");
  }
}
