package verigames.level;

import nu.xom.Attribute;
import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Elements;
import nu.xom.ParsingException;
import nu.xom.ValidityException;
import verigames.layout.GameCoordinate;
import verigames.level.StubBoard.StubConnection;
import verigames.utilities.Pair;

import java.io.*;
import java.util.*;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * An object that parses verigames XML documents and returns a corresponding
 * object representation in the form of a {@link World}.
 *
 * @author Nathaniel Mote
 */
// TODO document internal methods more thoroughly.
public class WorldXMLParser
{
  public static final int version = 3;

  private final boolean preserveIDs;
  private final boolean validate;

  public WorldXMLParser()
  {
    this(false, true);
  }

  public WorldXMLParser(boolean preserveIDs)
  {
    this(preserveIDs, true);
  }

  /**
   * @param preserveIDs true to preserve IDs on chutes and intersections
   *                    (NOTE: enabling this option is dangerous, as it allows
   *                    the possibility of ID clashes with newly created chutes
   *                    and intersections.)
   * @param validate    true to perform validation on the imported world (see
   *                    {@link verigames.level.XMLValidator#validate(World)}).
   */
  public WorldXMLParser(boolean preserveIDs, boolean validate)
  {
    this.preserveIDs = preserveIDs;
    this.validate = validate;
  }

  /**
   * Parses the text from {@code in} as XML, and returns a {@link World} object
   * representing the same information.
   * <p>
   * The returned {@code World} is not under construction (meaning that no
   * structural mutation is allowed). This is because the {@link Board} graphs
   * cannot currently have nodes or edges removed, and it is unlikely that any
   * other structural modification would be useful. There is the possibility
   * that {@link Level}s may benefit from having {@code Board}s added to them,
   * but currently, there is no reason to do so.
   */
  public World parse(final InputStream in)
  {
    // creates a Builder that does not validate the input;
    // TODO we should probably validate the XML, but it has trouble finding a
    // local DTD, and a hosted copy won't work very well in development. The
    // parser should catch any syntax errors, as well as other errors, but it
    // would be nice to have another layer of validation.
    final Builder parser = new Builder(false);

    final Document doc;

    try
    {
      doc = parser.build(in);
    }
    catch (ValidityException e)
    {
      throw new RuntimeException("Document does not validate", e);
    }
    catch (ParsingException e)
    {
      throw new RuntimeException("Document poorly formed", e);
    }
    catch (IOException e)
    {
      throw new RuntimeException("Could not read document", e);
    }

    final Element root = doc.getRootElement();

    World w = processWorld(root);

    if (validate)
    {
      XMLValidator.validate(w);
    }

    return w;
  }

  private World processWorld(final Element worldElt)
  {
    checkName(worldElt, "world");

    // check version
    {
      Attribute versionAttr = worldElt.getAttribute("version");
      int XMLVersion = Integer.parseInt(versionAttr.getValue());

      if (XMLVersion != version)
        throw new IllegalArgumentException("Parser expected version " + version
            +" but XML is version " + XMLVersion);
    }

    final World w = new World();

    final Element linkedVarIDsElt = worldElt.getFirstChildElement("linked-varIDs");

    final List<List<Integer>> linkedVarIDs = processLinkedVarIDs(linkedVarIDsElt);

    for (final List<Integer> linkedIDList : linkedVarIDs)
    {
      for (int i = 1; i < linkedIDList.size(); i++)
      {
        final int firstID = linkedIDList.get(i - 1);
        final int secondID = linkedIDList.get(i);
        w.linkByVarID(firstID, secondID);
      }
    }

    final Elements levelsElts = worldElt.getChildElements("level");

    for (int i = 0; i < levelsElts.size(); i++)
    {
      final Element levelElt = levelsElts.get(i);
      final Pair<String, Level> p = processLevel(levelElt);
      final String name = p.getFirst();
      final Level level = p.getSecond();
      w.addLevel(name, level);
    }

    w.finishConstruction(true, null);
    return w;
  }

  private List<List<Integer>> processLinkedVarIDs(final Element linkedVarIDsElt)
  {
    checkName(linkedVarIDsElt, "linked-varIDs");

    // TODO add support for stamping

    final List<List<Integer>> linkedVarIDs = new ArrayList<>();

    final Elements varIDSetElts = linkedVarIDsElt.getChildElements();

    for (int i = 0; i < varIDSetElts.size(); i++)
    {
      final Element varIDSetElt = varIDSetElts.get(i);
      final List<Integer> varIDSet = processVarIDSet(varIDSetElt);
      linkedVarIDs.add(varIDSet);
    }

    return linkedVarIDs;
  }

  private List<Integer> processVarIDSet(final Element varIDSetElt)
  {
    List<Integer> varIDs = new ArrayList<>();

    final Elements varIDElts = varIDSetElt.getChildElements();

    for (int i = 0; i < varIDElts.size(); i++)
    {
      final Element varIDElt = varIDElts.get(i);
      final int varID = Integer.parseInt(varIDElt.getAttribute("id").getValue());
      varIDs.add(varID);
    }

    return varIDs;
  }

  private Pair<String, Level> processLevel(final Element levelElt)
  {
    checkName(levelElt, "level");

    final Level level = new Level();

    final String name;
    {
      Attribute nameAttr = levelElt.getAttribute("name");
      name = nameAttr.getValue();
    }

    /* the boards must be processed first because Level requires that edges
     * already be present before makeLinked is called with them as arguments.*/
    final Map<String, StubBoard> stubBoards = processStubBoards(levelElt.getFirstChildElement("boards"));
    for (Map.Entry<String, StubBoard> entry : stubBoards.entrySet()) {
      final String stubBoardName = entry.getKey();
      final StubBoard stubBoard = entry.getValue();

      level.addStubBoard(stubBoardName, stubBoard);
    }

    final Pair<Map<String, Board>, Map<String, Chute>> p = processBoards(levelElt.getFirstChildElement("boards"));
    final Map<String, Board> boards = p.getFirst();
    final Map<String, Chute> chuteUIDs = p.getSecond();

    for (Map.Entry<String, Board> entry : boards.entrySet())
    {
      final String boardName = entry.getKey();
      final Board board = entry.getValue();

      level.addBoard(boardName, board);
    }

    return Pair.of(name, level);
  }

  /**
   * Takes XML Element boards as a parameter and reads all the stub boards from the XML, returning
   * a Map from their names to {@code StubBoard}s
   * @param boards The XML Element countaining the level's boards
   * @return Map from String names to the corresponding StubBoards
   */
  private Map<String, StubBoard> processStubBoards(final Element boards)
  {
    checkName(boards, "boards");

    final Map<String, StubBoard> stubBoards = new LinkedHashMap<String, StubBoard>();

    final Elements stubBoardElts = boards.getChildElements("board-stub");

    for (int i = 0; i < stubBoardElts.size(); i++)
    {
      final Element stubBoardElt = stubBoardElts.get(i);
      final Elements inputConnectionElts =
          stubBoardElt.getFirstChildElement("stub-input").getChildElements("stub-connection");
      final Elements outputConnectionElts =
          stubBoardElt.getFirstChildElement("stub-output").getChildElements("stub-connection");

      final List<StubConnection> inputs = getStubConnections(inputConnectionElts);
      final List<StubConnection> outputs = getStubConnections(outputConnectionElts);

      final String name = stubBoardElt.getAttribute("name").getValue();

      stubBoards.put(name, new StubBoard(inputs, outputs));
    }

    return stubBoards;
  }

  /**
   * Reads the connections from a {@code StubBoard}'s inputs or outputs and returns the StubConnections as a List
   */
  private List<StubConnection> getStubConnections(final Elements connectionElts)
  {
    final List<StubConnection> connections = new ArrayList<StubConnection>();
    for (int i = 0; i < connectionElts.size(); i++) {
      final Element connectionElt = connectionElts.get(i);
      connections.add(new StubConnection(connectionElt.getAttribute("num").getValue(),
          connectionElt.getAttribute("width").getValue().equals("narrow")));
    }
    return connections;
  }

  /**
   * Returns a map from {@link Board} names to {@code Board}s and a map from
   * {@link Chute} UIDs to {@code Chute}s.
   */
  private Pair<Map<String, Board>, Map<String, Chute>> processBoards(final Element boards)
  {
    checkName(boards, "boards");

    final Map<String, Board> boardsMap = new LinkedHashMap<String, Board>();
    final Map<String, Chute> chuteUIDs = new LinkedHashMap<String, Chute>();

    final Elements children = boards.getChildElements("board");

    for (int i = 0; i < children.size(); i++)
    {
      final Element child = children.get(i);
      final Pair<Pair<String, Board>, Map<String, Chute>> p = processBoard(child);
      final Pair<String, Board> boardInfo = p.getFirst();
      final Map<String, Chute> boardChuteUIDs = p.getSecond();

      boardsMap.put(boardInfo.getFirst(), boardInfo.getSecond());
      chuteUIDs.putAll(boardChuteUIDs);
    }

    return Pair.of(
            Collections.unmodifiableMap(boardsMap),
            Collections.unmodifiableMap(chuteUIDs));
  }

  /**
   * Processes a board XML element.<p>
   *
   * Returns a pair. The first item is itself a pair containing the name of the
   * board along with the {@link verigames.level.Board Board} itself. The second
   * element is a map from XML UIDs to the {@link verigames.level.Chute Chute}s
   * they identify
   */
  private Pair<Pair<String, Board>, Map<String, Chute>> processBoard(final Element boardElt)
  {
    checkName(boardElt, "board");

    final String name;
    {
      final Attribute nameAttr = boardElt.getAttribute("name");
      name = nameAttr.getValue();
    }

    final Board b = new Board(name);

    final Elements nodesElts = boardElt.getChildElements("node");
    final Elements edgesElts = boardElt.getChildElements("edge");

    /* map the XML UIDs of the nodes to Intersection objects. Object UIDs are
     * almost certainly going to be different from those in the XML, so we need
     * to keep track of which Intersections the XML is referring to in order to
     * attach edges (which refer to XML UIDs) later. */
    final Map<String, Intersection> UIDMap = processNodes(nodesElts);

    for (Intersection n : UIDMap.values())
    {
      if (n.getIntersectionKind() == Intersection.Kind.INCOMING)
        b.addNode(n);
    }

    if (b.getIncomingNode() == null)
      throw new RuntimeException("No INCOMING node found");

    for (Intersection n : UIDMap.values())
    {
      if (n != b.getIncomingNode())
        b.addNode(n);
    }

    if (b.getOutgoingNode() == null)
      throw new RuntimeException("No OUTGOING node found");

    Map<String, Chute> ChuteUIDMap = processEdges(edgesElts, b, UIDMap);

    return Pair.of(
            Pair.of(name, b),
            Collections.unmodifiableMap(ChuteUIDMap));
  }

  /**
   *
   */
  private Map<String, Intersection> processNodes(final Elements nodeElts)
  {
    final Map<String, Intersection> UIDMap = new LinkedHashMap<String, Intersection>();

    for (int i = 0; i < nodeElts.size(); i++)
    {
      final Element nodeElt = nodeElts.get(i);
      final Pair<String, Intersection> result = processNode(nodeElt);
      final String name = result.getFirst();
      final Intersection intersection = result.getSecond();

      UIDMap.put(name, intersection);
    }

    return Collections.unmodifiableMap(UIDMap);
  }

  private Pair<String, Intersection> processNode(final Element nodeElt)
  {
    checkName(nodeElt, "node");

    final Intersection.Kind kind;
    try
    {
      final Attribute kindAttr = nodeElt.getAttribute("kind");
      kind = Enum.valueOf(Intersection.Kind.class, kindAttr.getValue());
    }
    catch (IllegalArgumentException e)
    {
      throw new RuntimeException("Illegal Intersection Kind used", e);
    }

    final String UID;
    {
      final Attribute UIDAttr = nodeElt.getAttribute("id");
      UID = UIDAttr.getValue();
    }

    final /*@Nullable*/ Double x;
    final /*@Nullable*/ Double y;
    {
      final Element layoutElt = nodeElt.getFirstChildElement("layout");
      if (layoutElt == null)
      {
        x = null;
        y = null;
      }
      else
      {
        final GameCoordinate result = processLayoutPoint(layoutElt);
        x = result.getX();
        y = result.getY();
      }
    }

    /* Edge connections are intentionally not processed -- the data is
     * redundant, and it's simpler to get it when we're processing the edges. */

    final Intersection intersection;
    switch (kind)
    {
      case SUBBOARD:
        final Attribute nameAttr = nodeElt.getAttribute("name");
        if (nameAttr == null)
          throw new RuntimeException("Subboard node does not have a name attribute");
        final String name = nameAttr.getValue();
        intersection = preserveIDs ?
                Intersection.subboardFactory(Integer.parseInt(UID.substring(1)), name) :
                Intersection.subboardFactory(name);
        break;
      default:
        intersection = preserveIDs ?
                Intersection.factory(Integer.parseInt(UID.substring(1)), kind) :
                Intersection.factory(kind);
    }

    if (x != null)
    {
      /* These errors really should not happen -- validation should catch it,
       * and if it doesn't, an error would probably occur earlier. These are
       * just in case there's a serious problem with this code. */
      if (y == null)
        throw new RuntimeException("x coordinate encountered with no corresponding y coordinate");
      intersection.setX(x);
      intersection.setY(y);
    }
    else if (y != null)
      throw new RuntimeException("y coordinate encountered with no corresponding x coordinate");

    return Pair.of(UID, intersection);
  }

  private GameCoordinate processLayoutPoint(Element layoutElt)
  {
    {
      final String eltName = layoutElt.getLocalName();
      if (!(eltName.equals("layout") || eltName.equals("point")))
        throw new RuntimeException("Encountered " + eltName + " when point or layout was expected");
    }

    final double x;
    {
      final Element xElt = layoutElt.getFirstChildElement("x");
      x = processCoordinate(xElt);
    }

    final double y;
    {
      final Element yElt = layoutElt.getFirstChildElement("y");
      y = processCoordinate(yElt);
    }

    return new GameCoordinate(x, y);
  }

  private double processCoordinate(Element coordElt)
  {
    {
      final String eltName = coordElt.getLocalName();
      if (!(eltName.equals("x") || eltName.equals("y")))
        throw new RuntimeException("Encountered " + eltName + " when x or y was expected");
    }

    try
    {
      return Double.parseDouble(coordElt.getValue());
    }
    catch (NumberFormatException e)
    {
      throw new RuntimeException("malformed coordinate", e);
    }
  }

  /**
   * Modifies {@code b}
   */
  private Map<String, Chute> processEdges(final Elements edgeElts, final Board b, final Map<String, Intersection> IntersectionUIDMap)
  {
    final Map<String, Chute> ChuteUIDMap = new LinkedHashMap<String, Chute>();

    for (int i = 0; i < edgeElts.size(); i++)
    {
      final Element edgeElt = edgeElts.get(i);
      final Pair<String, Chute> p = processEdge(edgeElt, b, IntersectionUIDMap);
      final String UID = p.getFirst();
      final Chute c = p.getSecond();
      ChuteUIDMap.put(UID, c);
    }

    return Collections.unmodifiableMap(ChuteUIDMap);
  }

  /**
   * Modifies {@code b}
   */
  private Pair<String, Chute> processEdge(final Element edgeElt, final Board b, final Map<String, Intersection> UIDMap)
  {
    checkName(edgeElt, "edge");

    final String description;
    {
      final Attribute descriptionAttr = edgeElt.getAttribute("description");
      description = descriptionAttr.getValue();
    }

    final int variableID;
    try
    {
      final Attribute variableIDAttr = edgeElt.getAttribute("variableID");
      variableID = Integer.parseInt(variableIDAttr.getValue());
    }
    catch (NumberFormatException e)
    {
      throw new RuntimeException("edge variableID attribute contains noninteger data", e);
    }

    final boolean pinch;
    {
      final Attribute pinchAttr = edgeElt.getAttribute("pinch");
      pinch = Boolean.parseBoolean(pinchAttr.getValue());
    }

    final boolean narrow;
    {
      final Attribute widthAttr = edgeElt.getAttribute("width");
      narrow = widthAttr.getValue().equals("narrow");
    }

    final boolean editable;
    {
      final Attribute editableAttr = edgeElt.getAttribute("editable");
      editable = Boolean.parseBoolean(editableAttr.getValue());
    }

    final boolean buzzsaw;
    {
      final Attribute buzzsawAttr = edgeElt.getAttribute("buzzsaw");
      buzzsaw = Boolean.parseBoolean(buzzsawAttr.getValue());
    }

    final String UID;
    {
      final Attribute UIDAttr = edgeElt.getAttribute("id");
      UID = UIDAttr.getValue();
    }

    final List<GameCoordinate> layout;
    {
      final Element layoutElt = edgeElt.getFirstChildElement("edge-layout");
      if (layoutElt == null)
        layout = null;
      else
        layout = processEdgeLayout(layoutElt);
    }

    // pair of XML UID for an Intersection and port
    final Pair<String, String> startID;
    {
      final Element fromElt = edgeElt.getFirstChildElement("from");
      final Element noderefElt = fromElt.getFirstChildElement("noderef");
      startID = processNodeRef(noderefElt);
    }

    final Pair<String, String> endID;
    {
      final Element toElt = edgeElt.getFirstChildElement("to");
      final Element noderefElt = toElt.getFirstChildElement("noderef");
      endID = processNodeRef(noderefElt);
    }

    final Intersection start = UIDMap.get(startID.getFirst());
    final String startPort = startID.getSecond();

    final Intersection end = UIDMap.get(endID.getFirst());
    final String endPort = endID.getSecond();

    final Chute c = preserveIDs ?
            new Chute(Integer.parseInt(UID.substring(1)), variableID, description) :
            new Chute(variableID, description);
    c.setPinched(pinch);
    c.setNarrow(narrow);
    c.setEditable(editable);
    c.setBuzzsaw(buzzsaw);
    if (layout != null)
      c.setLayout(layout);

    b.addEdge(start, startPort, end, endPort, c);

    return Pair.of(UID, c);
  }

  private Pair<String, String> processNodeRef(Element nodeRef)
  {
    checkName(nodeRef, "noderef");

    final String ID;
    {
      final Attribute IDAttr = nodeRef.getAttribute("id");
      ID = IDAttr.getValue();
    }

    final String port;
    {
      final Attribute portAttr = nodeRef.getAttribute("port");
      port = portAttr.getValue();
    }

    return Pair.of(ID, port);
  }

  private List<GameCoordinate> processEdgeLayout(Element layoutElt)
  {
    checkName(layoutElt, "edge-layout");

    final List<GameCoordinate> result = new ArrayList<GameCoordinate>();

    final Elements pointElts = layoutElt.getChildElements();

    for (int i = 0; i < pointElts.size(); i++)
    {
      Element pointElt = pointElts.get(i);
      GameCoordinate point = processLayoutPoint(pointElt);
      result.add(point);
    }

    return result;
  }

  /**
   * @throws RuntimeException
   * if elt.getLocalName() does not equal the expected name.<br/>
   * Else has no effect.
   */
  private void checkName(Element elt, String expectedName)
  {
    if (!elt.getLocalName().equals(expectedName))
      throw new RuntimeException("Encountered " + elt.getLocalName() + " when " + expectedName + " was expected");
  }
}
