package verigames.level;

import java.io.IOException;
import java.io.PrintStream;

import java.util.*;

import verigames.layout.GameCoordinate;
import verigames.level.Intersection.Kind;
import verigames.level.StubBoard.*;
import verigames.utilities.Printer;

import nu.xom.*;

// TODO add lots of documentation
public class WorldXMLPrinter extends Printer<World, Void>
{
  public static final int version = 3;
  private final boolean useDescription;

  public WorldXMLPrinter() {
      final String noDesc = System.getProperty("NO_DESC");

      useDescription = noDesc != null && !noDesc.equalsIgnoreCase("true");
  }

  public WorldXMLPrinter(boolean useDescription)
  {
    this.useDescription = useDescription;
  }

  /**
   * Prints the XML representation for {@code toPrint}<br/>
   *
   * @param toPrint
   * The {@link World} to print
   *
   * @param out
   * The {@code PrintStream} to which the XML will be printed. Must be open.
   */
  @Override
  public void print(World toPrint, PrintStream out, Void data)
  {
    toPrint.validateSubboardReferences();
    super.print(toPrint, out, data);
  }

  @Override
  protected void printMiddle(World toPrint, PrintStream out, Void data)
  {
    Element worldElt = new Element("world");
    Attribute versionAttr = new Attribute("version", Integer.toString(version));
    worldElt.addAttribute(versionAttr);

    // TODO add stamping

    worldElt.appendChild(constructLinkedVarIDs(toPrint.getLinkedVarIDs()));

    for (Map.Entry<String, Level> entry : toPrint.getLevels().entrySet())
    {
      String name = entry.getKey();
      Level level = entry.getValue();
      worldElt.appendChild(constructLevel(level, name));
    }

    Document doc = new Document(worldElt);
    DocType docType = new DocType("world", "http://types.cs.washington.edu/verigames/world.dtd");
    doc.insertChild(docType, 0);

    try
    {
      Serializer s = new Serializer(out);
      s.setLineSeparator("\n");
      s.setIndent(1);
      s.write(doc);
    }
    catch (IOException e)
    {
      // if this happens, it's fatal.
      throw new RuntimeException(e);
    }
  }

  private Element constructLinkedVarIDs(Set<Set<Integer>> linkedVarIDSets)
  {
    Element linkedVarIDsElt = new Element("linked-varIDs");

    // we need to uniquely identify each varIDSet, to allow stamping.
    int varIDSetID = 0;
    for (Set<Integer> linkedVarIDs : linkedVarIDSets)
    {
      linkedVarIDsElt.appendChild(constructVarIDSet(varIDSetID, linkedVarIDs));
      varIDSetID++;
    }

    return linkedVarIDsElt;
  }

  private Element constructVarIDSet(int setID, Set<Integer> varIDs)
  {
    Element varIDSetElt = new Element("varID-set");
    Attribute idAttr = new Attribute("id", "v" + setID);
    varIDSetElt.addAttribute(idAttr);

    for (int varID : varIDs)
    {
      Element varIDElt = new Element("varID");
      Attribute varIDAttr = new Attribute("id", Integer.toString(varID));
      varIDElt.addAttribute(varIDAttr);

      varIDSetElt.appendChild(varIDElt);
    }

    return varIDSetElt;
  }

  private Element constructLevel(Level l, String name)
  {
    Element levelElt = new Element("level");

    Attribute nameAttr = new Attribute("name", name);
    levelElt.addAttribute(nameAttr);

    levelElt.appendChild(constructBoardsMap(l));

    return levelElt;
  }

  private void addStubConnections(Collection<StubConnection> connections, Element elt)
  {
    for (StubConnection c : connections)
    {
      Element connectionElt = new Element("stub-connection");
      connectionElt.addAttribute(new Attribute("num", c.getPortName()));
      connectionElt.addAttribute(new Attribute("width", c.isNarrow() ? "narrow" : "wide"));
      elt.appendChild(connectionElt);
    }
  }

  private Element constructBoardsMap(Level l)
  {
    Map<String, Board> boardNames = l.getBoards();
    Map<String, StubBoard> stubBoardNames = l.getStubBoards();

    Element boardsElt = new Element("boards");

    for (Map.Entry<String, StubBoard> entry : stubBoardNames.entrySet())
    {
      String name = entry.getKey();
      StubBoard stub = entry.getValue();

      Element stubElt = new Element("board-stub");
      stubElt.addAttribute(new Attribute("name", name));

      Element inputElt = new Element("stub-input");
      addStubConnections(stub.getInputs(), inputElt);
      stubElt.appendChild(inputElt);

      Element outputElt = new Element("stub-output");
      addStubConnections(stub.getOutputs(), outputElt);
      stubElt.appendChild(outputElt);

      boardsElt.appendChild(stubElt);
    }

    for (Map.Entry<String, Board> entry : boardNames.entrySet())
    {
      String name = cleanNameForXML(entry.getKey());
      Board board = entry.getValue();

      Element boardElt = new Element("board");
      boardElt.addAttribute(new Attribute("name", name));

      for (Intersection node : board.getNodes())
      {
        if (node.underConstruction())
          throw new IllegalStateException("underConstruction Intersection in Level while printing XML");

        Element nodeElt = new Element("node");
        nodeElt.addAttribute(new Attribute("kind", node.getIntersectionKind().toString()));

        if (node.getIntersectionKind() == Kind.SUBBOARD)
        {
          if (node.isSubboard())
            nodeElt.addAttribute(new Attribute("name", cleanNameForXML(node.asSubboard().getSubnetworkName())));
          else
            throw new RuntimeException("node " + node + " has kind subnetwork but isSubnetwork returns false");
        }
        nodeElt.addAttribute(new Attribute("id", "n" + node.getUID()));

        {
          Element inputElt = new Element("input");

          for (String ID : node.getInputIDs())
          {
            Chute input = node.getInput(ID);
            Element portElt = new Element("port");
            portElt.addAttribute(new Attribute("num", ID));
            portElt.addAttribute(new Attribute("edge", "e" + input.getUID()));
            inputElt.appendChild(portElt);
          }

          nodeElt.appendChild(inputElt);
        }

        {
          Element outputElt = new Element("output");

          for (String ID : node.getOutputIDs())
          {
            Chute output = node.getOutput(ID);
            Element portElt = new Element("port");
            portElt.addAttribute(new Attribute("num", ID));
            portElt.addAttribute(new Attribute("edge", "e" + Integer.toString(output.getUID())));
            outputElt.appendChild(portElt);
          }

          nodeElt.appendChild(outputElt);
        }

        double x = node.getX();
        double y = node.getY();
        if (x >= 0 && y >= 0)
        {
          Element layoutElt = new Element("layout");

          Element xElt = new Element("x");
          xElt.appendChild(formatDouble(x));
          layoutElt.appendChild(xElt);

          Element yElt = new Element("y");
          yElt.appendChild(formatDouble(y));
          layoutElt.appendChild(yElt);

          nodeElt.appendChild(layoutElt);
        }

        boardElt.appendChild(nodeElt);

      }

      for (Chute edge : board.getEdges())
      {
        if (edge.underConstruction())
          throw new IllegalStateException("underConstruction Chute in Level while printing XML");

        Element edgeElt = new Element("edge");
        {
          edgeElt.addAttribute(new Attribute("description", useDescription ? edge.getDescription() : "desc"));
          edgeElt.addAttribute(new Attribute("variableID", Integer.toString(edge.getVariableID())));
          edgeElt.addAttribute(new Attribute("pinch", Boolean.toString(edge.isPinched())));
          edgeElt.addAttribute(new Attribute("width", edge.isNarrow() ? "narrow" : "wide"));
          edgeElt.addAttribute(new Attribute("editable", Boolean.toString(edge.isEditable())));
          edgeElt.addAttribute(new Attribute("id", "e" + edge.getUID()));
          edgeElt.addAttribute(new Attribute("buzzsaw", Boolean.toString(edge.hasBuzzsaw())));
        }

        {
          Element fromElt = new Element("from");

          Element noderefElt = new Element("noderef");
          // TODO do something about this nullness warning
          noderefElt.addAttribute(new Attribute("id", "n" + edge.getStart().getUID()));
          noderefElt.addAttribute(new Attribute("port", edge.getStartPort()));
          fromElt.appendChild(noderefElt);

          edgeElt.appendChild(fromElt);
        }

        {
          Element toElt = new Element("to");

          Element noderefElt = new Element("noderef");
          // TODO do something about this nullness warning
          noderefElt.addAttribute(new Attribute("id", "n" + edge.getEnd().getUID()));
          noderefElt.addAttribute(new Attribute("port", edge.getEndPort()));
          toElt.appendChild(noderefElt);

          edgeElt.appendChild(toElt);
        }

        // output layout information, if it exists:
        List<GameCoordinate> layout = edge.getLayout();
        if (layout != null)
        {
          Element edgeLayoutElt = new Element("edge-layout");

          for (GameCoordinate point : layout)
          {
            Element pointElt = new Element("point");

              //TODO JB: Is there a reason for this level of precision?  Bumped it to ten
            Element xElt = new Element("x");
            xElt.appendChild(formatDouble(point.getX()));
            pointElt.appendChild(xElt);

            Element yElt = new Element("y");
            yElt.appendChild(formatDouble(point.getY()));
            pointElt.appendChild(yElt);

            edgeLayoutElt.appendChild(pointElt);
          }

          edgeElt.appendChild(edgeLayoutElt);
        }

        boardElt.appendChild(edgeElt);
      }

      boardsElt.appendChild(boardElt);
    }

    return boardsElt;
  }

  //TODO JB: Make more extensive and systematic
  //Note: In DTD's $ is forbidden and id's follow the "NAME" production so
  //this method equally applies to ids
  public String cleanNameForXML(final String id) {
    return id.replace("$", "-d-");
  }

  //TODO JB: Generalize
  //Takes only non-negative doubles
  public int determinePrecision(double d) {
    if(d > Math.pow(10, -4)) {
        return 5;
    } else {
        return 10;
    }
  }

  public String formatDouble(double d) {
      return String.format("%." + String.valueOf(determinePrecision(d)) + "f", d );
  }

}
