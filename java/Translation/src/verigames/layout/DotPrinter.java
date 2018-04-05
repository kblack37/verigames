package verigames.layout;

import static verigames.layout.Misc.getIntersectionHeight;
import static verigames.layout.Misc.usesPorts;

import java.io.PrintStream;
import java.util.*;

import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.level.Subboard;
import verigames.utilities.Printer;

/**
 * Prints fully constructed {@link verigames.level.Board Board} objects in
 * Graphviz's <a href="http://en.wikipedia.org/wiki/DOT_language">DOT
 * format</a>.
 * <p>
 * This {@link verigames.utilities.Printer Printer} prints DOT output for use in
 * laying out game boards.
 *
 * @author Nathaniel Mote
 *
 * @see verigames.layout
 */
class DotPrinter extends AbstractDotPrinter
{
  /**
   * A class that prints {@link verigames.level.Intersection Intersection}
   * objects to Graphviz's DOT format.
   */
  private static class NodePrinter extends Printer<Intersection, Board>
  {
    @Override
    protected void printMiddle(Intersection n, PrintStream out, Board b)
    {
      /* contains extra options, particularly the extra information needed for a
       * node with ports. */
      final String optionsString;
      {
        if (usesPorts(n.getIntersectionKind()))
        {
          final int maxPorts = AbstractDotPrinter.getMaxPorts(n);
          final int width = maxPorts;
          final double height = getIntersectionHeight(n.getIntersectionKind());

          /* in a "record" shape node, the labels have special meaning, and
           * define ports. The curly braces control the layout. */
          String label = "{{" + generatePortList(true, n) + "}|{";

          /** print the subboard's name in the middle row of the node */
          if( n.getIntersectionKind() == Intersection.Kind.SUBBOARD ) {
            Subboard subboard = (Subboard) n;
            label += subboard.getSubnetworkName() + "}|{";
          }
          label += generatePortList(false, n) + "}}";

          optionsString = String.format("[shape=record, width=%d, height=%f, label=\"%s\"]",
                                        width, height, label);
        } else {
          String label = String.format("%s#%d", n.getIntersectionKind().toString().toLowerCase(), n.getUID());
          if (n.getOutputIDs().size() > 0) {
              String variableId = "Variable: " + n.getOutput(n.getOutputIDs().get(0)).getVariableID();
              label = String.format("%s\n%s#%d", variableId, n.getIntersectionKind().toString().toLowerCase(), n.getUID());
          }
          optionsString = String.format("[label=\"%s\"]", label);
        }
      }

      final String prefix;
      final String suffix;
      /* this puts INCOMING and OUTGOING nodes in their own subgraphs.
       * rank=source/sink ensures that the subgraph is alone in its rank, and
       * makes that rank the minimum/maximum (respectively) possible. This
       * enforces the invariant that incoming nodes are at the very top, and
       * outgoing nodes are at the very bottom. */
      if (n.getIntersectionKind() == Intersection.Kind.INCOMING)
      {
        prefix = "{\ngraph [rank=source];\n";
        suffix = "}\n";
      }
      else if (n.getIntersectionKind() == Intersection.Kind.OUTGOING)
      {
        prefix = "{\ngraph [rank=sink];\n";
        suffix = "}\n";
      }
      else
      {
        prefix = "";
        suffix = "";
      }

      out.print(prefix);
      out.printf("%d %s;\n", n.getUID(),  optionsString);
      out.print(suffix);
    }

    // TODO add example of output
    /**
     * Generates a list of ports for the given {@link
     * verigames.level.Intersection Intersection}. For any given {@code
     * Intersection}, returns the same number of nodes for both the input and
     * output ports. This is so that the input and output ports have an even
     * amount of spacing even if there are different numbers of input and output
     * ports for a given node.
     *
     * @param isInput
     * A {@code boolean} indicating whether to generate a list of input ports or
     * output ports. If {@code true}, the port IDs will be taken from the list
     * of input ports, and each will be prefixed by the character 'i'.
     * Otherwise, the port IDs will be taken from the list of output ports, and
     * each will be prefixed by the character 'o'.
     *
     * @param n
     * The {@link verigames.level.Intersection Intersection} for which the ports
     * list should be generated
     *
     */
    private String generatePortList(boolean input, Intersection n)
    {
      String prefix;
      List<String> portsList;
      if (input)
      {
        prefix = "i";
        portsList = n.getInputIDs();
      }
      else
      {
        prefix = "o";
        portsList = n.getOutputIDs();
      }

      StringBuilder result = new StringBuilder();
      for (int i = 0 ; i < portsList.size(); i++)
      {
        String port = portsList.get(i);
        result.append("<" + prefix + port + ">");
        if (i != portsList.size() - 1)
          result.append("|");
      }

      // add the filler ports
      int numPorts = AbstractDotPrinter.getMaxPorts(n);
      for (int i = portsList.size(); i < numPorts; i++)
      {
        // mark the port with an x to indicate that it is just a filler
        result.append("|<x" + i + ">");
      }

      return result.toString();
    }
  }

  public static String getChuteLabel(Chute e) {
      String label = Integer.toString(e.getUID());
      label += "Var: " + e.getVariableID();
      if (e.isPinched()) {
          label += " PINCHED";
      }
      if (!e.isEditable()) {
          label += " UNEDITABLE";
      }
      if (!e.isNarrow()) {
          label += " WIDE";
      }
      return label;
  }

  /**
   * An {@code Object} that prints {@link verigames.level.Chute Chute} objects to
   * Graphviz's DOT format, with attributes tailored to the edge layout pass.
   */
  // TODO consider naming this class
  private static final Printer<Chute, Board> edgePrinter = new Printer<Chute, Board>()
  {
    @Override
    protected void printMiddle(Chute e, PrintStream out, Board b)
    {
      /* the suffix enforces the edge direction -- edges come out of the "south"
       * side and enter the "north" side of nodes. */
      String start = getNodeString(e.getStart(), "o", e.getStartPort(), ":s");
      String end = getNodeString(e.getEnd(), "i", e.getEndPort(), ":n");

      out.println(start + " -> " + end + " [label=\"" + getChuteLabel(e) + "\"];");
    }

    /**
     * Returns a {@code String} representing the given node and, if the node is
     * represented to Graphviz as having ports, the port number is included,
     * preceded by the given prefix.
     *
     * @param n
     * The {@link level.Intersection Intersection} to create a {@code String}
     * representation for.
     *
     * @param portPrefix
     * The text with which to prefix the port number, if a port number needs to
     * be used. This is to distinguish incoming ports from outgoing ports.
     *
     * @param port
     * The port number for {@code n}
     */
    /* This method should be static, but can't be because it's part of an
     * anonymous class. This should, perhaps, be changed. */
    private String getNodeString(Intersection n, String portPrefix, String port, String suffix)
    {
      String result = "";
      result += n.getUID();
      if (usesPorts(n.getIntersectionKind()))
        result += ":" + portPrefix + port + suffix;
      return result;
    }
  };

  /**
   * Constructs a new {@code EdgeLayoutPrinter}
   */
  public DotPrinter()
  {
    super(new NodePrinter(), edgePrinter);
  }

  @Override
  protected boolean isDigraph(Board b)
  {
    return true;
  }

  @Override
  protected String nodeSettings(Board b)
  {
    // shape=circle: makes the nodes circular so that edges avoid them.
    //
    // width=1: makes the nodes have a radius of 0.5 inches so that edges stay
    // that far away from them.
    return "shape=circle, width=1";
  }

  @Override
  protected String edgeSettings(Board b)
  {
    // dir=none: Remove the drawings of arrows on the edges. Doing this gives
    // more regular spline information.
    //
    // headclip,tailclip=false: draw edges to the centers of nodes, instead of
    // stopping at their edges. Important because the nodes are circles, not
    // points. For an explanation, see nodeSettings.
    return "headclip=false, tailclip=false";
  }

  @Override
  protected String graphSettings(Board b)
  {
    // splines=true: allows neato to draw curved edges, instead of the default
    // behavior where all lines are straight.
    return "splines=true";
  }
}
