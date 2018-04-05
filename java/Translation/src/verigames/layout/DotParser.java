package verigames.layout;

import java.math.BigDecimal;
import java.util.*;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * Parses text in DOT format and returns the results as a {@link
 * GraphInformation} object.
 * <p>
 * This class does not represent an object -- it simply encapsulates the {@link
 * #parse(String) parse(String)} method. As such, it is not instantiable.
 * <p>
 * Currently, the {@code GraphInformation} object returned by the parse method
 * includes the dimensions of the graph's bounding box, as well as the
 * dimensions and position of the nodes and the spline control points for the
 * edges. However, more information may be added at a later date.
 * <p>
 * Spline control points preceded by an 'e' or an 's' are NOT included in the
 * returned layout information. Points of that kind define the location of the
 * arrows on an edge.
 * <p>
 * This parser is very brittle, and makes little attempt to account for
 * variations in input. It attempts to match Graphviz's output, which is a
 * subset of legal DOT. Therefore, some legal DOT may be rejected simply
 * because it doesn't match the format of what Graphviz outputs.
 */

class DotParser extends AbstractDotParser
{
  /**
   * An {@code Exception} that is thrown when a bad line of DOT is encountered.
   * It should only be used internally to ensure that errors are handled and
   * expressed to clients in an appropriate way. A reference to an {@code
   * IllegalLineException} should never escape this class, except in the cause
   * field of another {@code Throwable}.
   * <p>
   * A message is required, and it should contain the bad line or the bad part
   * of the line.
   */
  private static class IllegalLineException extends Exception
  {
    private static final long serialVersionUID = 0;
    public IllegalLineException(String message)
    {
      super(message);
    }

    public IllegalLineException(String message, Throwable cause)
    {
      super(message, cause);
    }
  }

  /**
   * Parses the given {@code String} as a single graph in DOT format, and
   * returns the information as a {@code GraphInformation} object.
   *
   * @param dotOutput
   * Must be well-formed output from dot.
   */
  public GraphInformation parse(String dotOutput)
  {
    // the builder that is used to construct the returned GraphInformation
    final GraphInformation.Builder out = new GraphInformation.Builder();

    Scanner in = new Scanner(dotOutput);

    while (in.hasNextLine())
    {
      String line = getNextLogicalLine(in);

      try
      {
        parseLine(line, out);
      }
      catch (IllegalLineException e)
      {
        throw new IllegalArgumentException(e.getMessage(), e);
      }
    }

    if (out.areGraphAttributesSet())
      return out.build();
    else
      throw new IllegalArgumentException("Input lacks graph property information");
  }

  /**
   * Gets the next logical Graphviz line from the given {@code Scanner}. Joins
   * lines that are terminated by a backslash, as well as lines that have
   * unclosed square brackets ([]).
   */
  private static String getNextLogicalLine(Scanner in)
  {
    // get the next complete line. newlines can be escaped by a backslash, so
    // this gets the next line, ignoring escaped newlines.
    String line = getNextCompleteLine(in);

    // if this line doesn't have matching brackets, append the next line,
    // because the next one logically belongs with this one.
    while (!hasMatchingBrackets(line))
      line += getNextCompleteLine(in);

    return line;
  }

  /**
   * Returns {@code true} if {@code line} has matching square brackets. Usually
   * returns false otherwise (because really all it's doing is counting the
   * number of square brackets).
   */
  private static boolean hasMatchingBrackets(String line)
  {
    int open = 0;
    int close = 0;
    for (char c : line.toCharArray())
    {
      if (c == '[')
        open++;
      else if (c == ']')
        close++;
    }
    return open == close;
  }

  /**
   * Gets the next complete Graphviz line from the given {@code Scanner}. Joins
   * lines that are terminated by a backlash, because this is supposed to escape
   * the newline.
   */
  private static String getNextCompleteLine(Scanner in)
  {
    String line = in.nextLine();

    // if the line is terminated by a \, the next line is logically part of this
    // line, so stitch them together
    while (line.charAt(line.length() - 1) == '\\')
    {
      String end;
      try
      {
        end = in.nextLine();
      }
      catch (NoSuchElementException e)
      {
        throw new IllegalArgumentException(
            "Poorly formed input -- \\ found at end of last line", e);
      }

      // Join the current line with the next line, and remove the \ at the end
      // of the current line
      line = line.substring(0, line.length() - 1) + end;
    }

    return line;
  }

  /**
   * An enum used to describe the nature of a line of input. Used to direct
   * parsing.<p>
   *
   * Currently, not all of these line kinds are parsed -- some of them contain
   * information that is not needed.
   */
  private static enum LineKind
      { GRAPH_PROPERTIES, NODE_PROPERTIES, EDGE_PROPERTIES, NODE, EDGE, OTHER }

  /* The three following classes are record types used to return richer
   * information from the parsing methods than can be stored in the
   * GraphInformation record types. */

  /**
   * An immutable record type that stores the name of a node along with its
   * attributes.
   */
  private static class NodeRecord
  {
    public final String name;
    public final GraphInformation.NullableNodeAttributes attributes;

    public NodeRecord(String name, GraphInformation.NullableNodeAttributes attributes)
    {
      this.name = name;
      this.attributes = attributes;
    }
  }

  /**
   * An immutable record type that stores the start and end nodes of an edge
   * along with its attributes.
   */
  private static class EdgeRecord
  {
    public final String label;
    public final GraphInformation.EdgeAttributes attributes;

    public EdgeRecord(String label, GraphInformation.EdgeAttributes attributes)
    {
      this.label = label;
      this.attributes = attributes;
    }
  }

  /**
   * Mutates {@code builder} such that it includes the data contained in {@code
   * line}
   * <p>
   * Modifies: {@code builder}
   *
   * @param line
   * The line to parse
   * @param builder
   * The {@link GraphInformation.Builder} to which the data from the parsed
   * line will be added.
   * @param nodeDefaults
   * The current default settings for nodes.
   *
   * @return
   * The new default settings for nodes (will be {@code nodeDefaults} unless
   * {@code line} is a node properties line).
   */
  private static void parseLine(String line, GraphInformation.Builder builder)
                                        throws IllegalLineException
  {
    switch (getLineKind(line))
    {
      case GRAPH_PROPERTIES:
        GraphInformation.GraphAttributes graph = parseGraphAttributes(line);
        // graph can be null if the graph attributes on this line are not
        // relevant
        if (graph != null)
          builder.setGraphAttributes(graph);
        break;
      case NODE:
        NodeRecord node = parseNode(line);
        builder.setNodeAttributes(node.name, node.attributes);
        break;
      case EDGE:
        EdgeRecord edge = parseEdge(line);
        builder.setEdgeAttributes(edge.label, edge.attributes);
        break;
      case NODE_PROPERTIES:
        GraphInformation.NodeDefaults nodeDefaults = parseNodeDefaults(line);
        builder.setNodeDefaults(nodeDefaults);
        break;
      default:
        // Right now, the graph, node, and edge attributes are all the
        // attributes that are used
        break;
    }
  }

  /**
   * Takes a logical Graphviz line and returns what kind of information it represents.
   *
   * @param line
   * Must be a valid line of Graphviz output. Must be a logical line -- that
   * is, it must not be terminated by '\' (this would indicate that it should
   * be joined with the line after).
   *
   * @return a {@link LineKind} indicating what kind of information {@code
   * line} represents.
   */
  private static LineKind getLineKind(String line) throws IllegalLineException
  {
    String[] tokens = splitAroundWhitespace(line);

    try
    {
      if (tokens[0].equals("}") || tokens[0].equals("{"))
        return LineKind.OTHER;
      /* else, there should be at least two tokens ("}" and "{" are the only
       * 1-token lines) */
      // If the line is the start or end of a graph, return OTHER
      else if ((tokens[0].equals("digraph") || tokens[0].equals("graph")) &&
                tokens[1].equals("{"))
        return LineKind.OTHER;
      else if (tokens[0].equals("graph"))
        return LineKind.GRAPH_PROPERTIES;
      else if (tokens[0].equals("node"))
        return LineKind.NODE_PROPERTIES;
      else if (tokens[0].equals("edge"))
        return LineKind.EDGE_PROPERTIES;
      else if (tokens[1].equals("->") || tokens[1].equals("--"))
        return LineKind.EDGE;
      else
        return LineKind.NODE;
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      throw new IllegalLineException(line, e);
    }
  }

  /**
   * Takes a logical Graphviz line representing a graph attributes statement
   * and returns a GraphAttributes object containing the information from it.
   * <p>
   * Currently only parses the "bb" attribute.
   *
   * @param line
   * Must be a valid, logical line of Graphviz output describing attributes of
   * the graph itself (as oppose to particular edges or nodes).
   */
  private static GraphInformation./*@Nullable*/ GraphAttributes parseGraphAttributes(String line) throws IllegalLineException
  {
    // sample line: '  graph [bb="0,0,216.69,528"];'

    // split the string into tokens, stripping extraneous characters
    // sample line would become:
    // [graph, bb="0,0,216.69,528"]
    String[] tokens = tokenizeLine(line);

    if (tokens.length < 2 || !tokens[0].equals("graph"))
      throw new IllegalLineException("\"" + line + "\" is not a valid graph attributes line");

    Map<String, String> mappings = lineMappings(tokens);

    String bb = mappings.get("bb");

    // Graph attributes may be spread across multiple lines, so if the
    // bounding box attribute is not present in this line, just return null.
    // This may need to be changed if more graph information is desired.
    if (bb == null)
      return null;

    // Sometimes, an empty bb attribute is given. If this is the case, also
    // return null.
    if (bb.equals(""))
      return null;

    int xStart;
    int yStart;
    int xEnd;
    int yEnd;

    try
    {
      // take the coordinates string and split around commas
      String[] bbCoords = bb.split(",");

      xStart = parseToHundredths(bbCoords[0]);
      yStart = parseToHundredths(bbCoords[1]);
      xEnd = parseToHundredths(bbCoords[2]);
      yEnd = parseToHundredths(bbCoords[3]);
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      throw new IllegalLineException("bounding box attribute poorly formed: " +
                                     line);
    }
    catch (NumberFormatException e)
    {
      throw new IllegalLineException("bounding box attribute poorly formed: " +
                                     line);
    }

    if (xStart != 0 || yStart != 0)
      throw new IllegalLineException(
          "bottom-left corner of bounding box not at (0,0) -- it is (" +
          xStart + "," + yStart + ")");

    return new GraphInformation.GraphAttributes(xEnd, yEnd);
  }

  /**
   * Takes a logical Graphviz line representing a node and returns a {@link
   * NodeRecord NodeRecord} object containing the information from it.
   *
   * @param line
   * Must be a valid, logical line of Graphviz output describing attributes of
   * a node.
   */
  private static NodeRecord parseNode(String line) throws IllegalLineException
  {
    // an example of a node line:
    // '   9 [label=OUTGOING9, width=1, height=1, pos="129.64,36"];'
    //     ^
    // node name

    // split the string into tokens, stripping extraneous characters
    // sample line would become:
    // [9, label=OUTGOING9, width=1, height=1, pos="129.64,36"]
    String[] tokens = tokenizeLine(line);

    if (tokens.length == 0)
      throw new IllegalLineException("empty line: " + line);

    String name = tokens[0];
    Map<String, String> mappings = lineMappings(tokens);

    String widthStr = mappings.get("width");
    String heightStr = mappings.get("height");
    String pos = mappings.get("pos");

    // position attribute must be present
    if (pos == null)
      throw new IllegalLineException("No position information: " + line);

    /*@Nullable*/ Integer width = parseNullableDimension(widthStr);
    /*@Nullable*/ Integer height = parseNullableDimension(heightStr);

    // The pos attribute takes the form xx.xx,yy.yy
    try
    {
      // split around comma, to get [xx.xx, yy.yy]
      String[] coords = pos.split(",");

      int x = parseToHundredths(coords[0]);
      int y = parseToHundredths(coords[1]);

      return new NodeRecord(name, new GraphInformation.NullableNodeAttributes(x, y, width, height));
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      throw new IllegalLineException("Poorly formed line: " + line, e);
    }
    // parseToHundredth throws {@code NumberFormatException}s if it fails to
    // parse the numbers.
    catch (NumberFormatException e)
    {
      throw new IllegalLineException("Poorly formed line: " + line, e);
    }
  }

  /**
   * Takes a logical Graphviz line representing an edge and returns an {@link
   * EdgeRecord EdgeRecord} object containing the relevant information from it.
   *
   * @param line
   * Must be a valid, logical line of Graphviz output describing attributes of
   * an edge.
   */
  private static EdgeRecord parseEdge(String line) throws IllegalLineException
  {
    /* An example of an edge line:
     *       '   8:o2 -- 10 [pos="37,493 37,493 54,341 54,341"];'
     *           ^ ^     ^        ^      ^      ^      ^
     *  start node |     |      spline   control   points
     *             |  end node
     *      port identifier
     */

    // After example has run through tokenizeLine:
    // [8:o2, --, 10, pos="37,493 37,493 54,341 54,341"]
    String[] tokens = tokenizeLine(line);
    Map<String, String> mappings = lineMappings(tokens);

    // there need to be *at least* the 4 tokens shown above
    if (tokens.length < 4)
      throw new IllegalLineException("Edge line without needed attributes: " + line);

    String pos = mappings.get("pos");
    String labelString = mappings.get("label");

    if (pos == null)
      throw new IllegalLineException("No position information: " + line);

    if (labelString == null)
      throw new IllegalLineException("No label information: " + line);

    // The pos attribute takes the form
    // 'xx.xx,yy.yy xx.xx,yy.yy xx.xx,yy.yy xx.xx,yy.yy'
    // where the number of points is at least 4, and congruent to 1 (mod 3)
    //
    // The label attribute takes the form
    // '45'

    try
    {
      // get the label by splitting around the equals sign, removing quotes, and
      // trimming whitespace.
      String label = labelString.trim();

      // splits
      // xx.xx,yy.yy xx.xx,yy.yy xx.xx,yy.yy xx.xx,yy.yy
      // around whitespace, so each entry is
      // xx.xx,yy.yy
      String[] coords = pos.split("\\s");

      List<GraphvizPointCoordinate> points = new ArrayList<GraphvizPointCoordinate>();
      for (String XYString: coords)
      {
        if (XYString.length() != 0)
        {
          char firstChar = XYString.charAt(0);

          // if a coordinate starts with an 'e' or an 's', that coordinate
          // is not part of the edge itself, but instead controls where the
          // arrowheads are drawn. These should not be included, for our
          // purposes.
          //
          // see http://www.graphviz.org/content/attrs#ksplineType
          if (firstChar != 'e' && firstChar != 's')
          {
            // split xx.xx,yy.yy around a comma
            String XY[] = XYString.split(",");
            int x = parseToHundredths(XY[0]);
            int y = parseToHundredths(XY[1]);

            points.add(new GraphvizPointCoordinate(x, y));
          }
        }
      }

      // ensure that the number of points meets the requirement
      if (points.size() < 4 || points.size() % 3 != 1)
        throw new IllegalLineException("Illegal number of points (" +
            points.size() +
            ") -- must be greater than 1 and congruent to 1 (mod 3): " +
            line);

      return new EdgeRecord(label, new GraphInformation.EdgeAttributes(points));
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      throw new IllegalLineException("Poorly formed line: " + line, e);
    }
    catch (NumberFormatException e)
    {
      throw new IllegalLineException("Poorly formed line: " + line, e);
    }
  }

  /**
   * Takes a logical Graphviz line representing node defaults and returns a
   * {@link GraphInformation.NodeDefaults NodeDefaults} object containing the information from it
   *
   * @param line
   * Must be a valid, logical line of Graphviz output describing default
   * attributes for nodes.
   */
  private static GraphInformation.NodeDefaults parseNodeDefaults(String line)
                                                throws IllegalLineException
  {
    String[] tokens = tokenizeLine(line);
    Map<String, String> mappings = lineMappings(tokens);

    String widthStr = mappings.get("width");
    String heightStr = mappings.get("height");

    // set the width and height
    Integer width = parseNullableDimension(widthStr);
    Integer height = parseNullableDimension(heightStr);

    return new GraphInformation.NodeDefaults(width, height);
  }

  /**
   * Behaves as {@link #parseDimension(String)} except that a {@code null}
   * argument is allowed, in which case {@code null} will be returned.
   */
  private static /*@Nullable*/ Integer parseNullableDimension(
      /*@Nullable*/ String dimensionStr) throws IllegalLineException
  {
    if (dimensionStr == null)
      return null;
    else
      return parseDimension(dimensionStr);
  }

  /**
   * Used for converting height and width dimensions from inches to hundredths
   * of points.<p>
   *
   * The width and height attributes take the form ww.ww. This method takes a
   * string in this forma nd returns the number represented, multiplied by 7200
   * and rounded to the nearest integer.
   *
   * Graphviz gives dimensions in inches, and this converts them to hundredths
   * of points (1 inch = 72 points = 7200 hundredths of points)
   */
  // TODO perhaps unify with parseToHundredth()?
  private static int parseDimension(String dimensionStr) throws IllegalLineException
  {
    // a BigDecimal is used instead of a double so that there can be no loss
    // of precision
    BigDecimal dimInches;
    try
    {
      dimInches = new BigDecimal(dimensionStr);
    }
    catch (NumberFormatException e)
    {
      throw new IllegalLineException("Poorly formed attribute: " + dimensionStr, e);
    }

    BigDecimal dimension = dimInches.multiply(new BigDecimal(7200));

    // rounds by adding 0.5, then taking the floor
    return dimension.add(new BigDecimal("0.5")).intValue();
  }

  /**
   * Takes an {@code Array} of tokens for the line and return any mappings
   * indicated by tokens with an '=' character in them.<p>
   *
   * This method returns a {@code Map} where each key corresponds to the part of
   * a token before the first '=' character, and the value is the part after the
   * first '=' character. If the value is surrounded by quotes, those are
   * removed.
   */
  private static Map<String, String> lineMappings(String[] tokens)
  {
    Map<String, String> result = new HashMap<String, String>();

    for (String token : tokens)
    {
      String[] parts = token.split("=", 2);
      if (parts.length == 2)
      {
        String key = parts[0];

        String untrimmedValue = parts[1];
        String value;
        // if it starts and ends with quotes, remove the outer quotes
        if (untrimmedValue.charAt(0) == '"' &&
            untrimmedValue.charAt(untrimmedValue.length() - 1) == '"')
          // remove quotes at the beginning and end of the line
          value = untrimmedValue.replaceAll("^\"|\"$", "");
        else
          value = untrimmedValue;

        result.put(key, value);
      }
    }

    return result;
  }

  /**
   * Splits the given line into tokens separated by unquoted whitespace. That
   * is, any whitespace terminates a token, unless it is enclosed in quotes.
   * <p>
   * Removes brackets ([,]), as well as semicolons and trailing commas in
   * tokens.
   * <p>
   * Any sequence enclosed by double quotes will be contained in a single
   * token, even if the quoted sequence includes whitespace.
   */
  private static String[] tokenizeLine(String line)
  {
    // remove extraneous characters -- '[', ']', ';' -- from the line.
    line = line.replaceAll("[\\[\\];]", "");

    List<String> tokens = new ArrayList<String>();

    int startIndex = 0;
    int endIndex = 0;
    boolean inQuotedString = false;

    /* strategy:
     * increment endIndex until unquoted whitespace is encountered. When this
     * occurs, take the String from startIndex (inclusive) to endIndex
     * (exclusive), and add it to the token list. Then, set startIndex to
     * endIndex, skip any whitespace, and continue. */
    while(endIndex < line.length())
    {
      char currentChar = line.charAt(endIndex);

      if (Character.isWhitespace(currentChar) && !inQuotedString)
      {
        // search for the start of a token by moving past whitespace
        if (startIndex == endIndex)
        {
          startIndex++;
          endIndex++;
        }
        // if we're not searching for the start of a token, we've reached the
        // whitespace terminating a token
        else
        {
          tokens.add(line.substring(startIndex, endIndex));
          startIndex = endIndex;
        }

        // endIndex should not be incremented -- it's already been manually
        // manipulated.
        continue;
      }
      // if there's a quote, toggle inQuotedString
      else if (currentChar == '"')
        inQuotedString = !inQuotedString;

      endIndex++;
    }

    // if some of the string remains
    if (endIndex != startIndex)
      tokens.add(line.substring(startIndex, endIndex));

    // remove trailing commas at the end of tokens
    for(int i = 0; i < tokens.size(); i++)
    {
      tokens.set(i, tokens.get(i).replaceAll(",$", ""));
    }

    return tokens.toArray(new String[0]);
  }

  /**
   * Splits the given {@code String} into an array of tokens separated by
   * whitespace. Whitespace is defined as one or more spaces, tabs, or
   * newlines.
   */
  private static String[] splitAroundWhitespace(String in)
  {
    // Split the input around whitespace, after removing leading and trailing
    // whitespace.
    String[] result = in.trim().split("[\\s]+");

    return result;
  }

  /**
   * Parses the given decimal number, represented as a {@code String} into
   * hundredths of units. That is, given "123.45", it would return 12345.
   * Rounds to the nearest hundredth.
   *
   * @param str
   * Must be a decimal number. There may not be a leading '.' (e.g.  ".35" must
   * be written "0.35").
   *
   * @return {@code int} indicating the number of hundredths in the given
   * number
   *
   * @throws NumberFormatException if {@code str} is poorly formed
   */
  private static int parseToHundredths(String str)
  {
    // an optional minus sign, followed by 1 or more digits, optionally
    // followed by a single dot and one or more digits
    final BigDecimal original;
    try {
        original = new BigDecimal(str);
    } catch(final NumberFormatException nfe ) {
        throw new RuntimeException(str + " is not a well-formed nonnegative decimal number", nfe);
    }

    BigDecimal hundredths = original.multiply(new BigDecimal(100));

    // round by adding 0.5, then taking the floor.
    return hundredths.add(new BigDecimal("0.5")).intValue();
  }
}
