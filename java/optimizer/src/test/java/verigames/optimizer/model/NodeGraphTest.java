package verigames.optimizer.model;

import org.testng.annotations.Test;
import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.World;
import verigames.optimizer.Util;
import verigames.optimizer.io.WorldIO;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Test
public class NodeGraphTest {

    final WorldIO io = new WorldIO();

    @Test
    public void testBasics() {
        NodeGraph g = new NodeGraph();
        Node incoming = new Node("a", "b", Intersection.Kind.INCOMING);
        Node connect = Util.newNodeOnSameBoard(incoming, Intersection.Kind.OUTGOING);
        Node outgoing = Util.newNodeOnSameBoard(connect, Intersection.Kind.CONNECT);

        g.addNode(incoming);
        assert g.getNodes().size() == 1;
        assert g.getNodes().contains(incoming);

        EdgeData data = EdgeData.createMutable(1, "?");
        Edge e1 = g.addEdge(incoming, Port.OUTPUT, connect, Port.INPUT, data);
        Edge e2 = g.addEdge(connect, Port.OUTPUT, outgoing, Port.INPUT, data);

        assert g.getNodes().size() == 3;
        assert g.getNodes().containsAll(Arrays.asList(incoming, connect, outgoing));
        assert g.getEdges().size() == 2;
        assert g.outgoingEdges(incoming).size() == 1;
        assert g.incomingEdges(incoming).size() == 0;
        assert g.outgoingEdges(connect).size() == 1;
        assert g.incomingEdges(connect).size() == 1;
        assert g.outgoingEdges(outgoing).size() == 0;
        assert g.incomingEdges(outgoing).size() == 1;

        g.removeEdge(e1);
        assert g.getEdges().size() == 1;
        assert g.getEdges().contains(e2);
        assert !g.getEdges().contains(e1);
        assert g.getNodes().size() == 3;
        assert g.getNodes().containsAll(Arrays.asList(incoming, connect, outgoing));

        g.removeNode(connect);
        assert g.getEdges().isEmpty();
        assert g.getNodes().size() == 2;
        assert g.getNodes().containsAll(Arrays.asList(incoming, outgoing));
    }

    @Test
    public void testEdgeSets() {
        NodeGraph g = new NodeGraph();
        Node one = new Node("a", "b", Intersection.Kind.INCOMING);
        Node two = Util.newNodeOnSameBoard(one, Intersection.Kind.OUTGOING);
        Node three = Util.newNodeOnSameBoard(two, Intersection.Kind.CONNECT);

        EdgeData data = EdgeData.createMutable(1, "?");

        Edge e0 = new Edge(one, Port.OUTPUT, two, Port.INPUT, EdgeData.createMutable(0, "!"));
        Edge e1 = g.addEdge(one, Port.OUTPUT, two, Port.INPUT, data);
        g.addEdge(two, Port.OUTPUT, three, Port.INPUT, data);

        assert g.edgeSet(e0).size() == 1;
        assert g.edgeSet(e1).containsAll(g.getEdges());

        g.removeNode(three);
        assert g.edgeSet(e1).size() == 1;
        assert g.edgeSet(e1).containsAll(g.getEdges());

        g.addEdge(two, Port.OUTPUT, three, Port.INPUT, data);
        g.addEdge(two, Port.OUTPUT, three, Port.INPUT, data);
        assert g.edgeSet(e1).size() == 2;

        assert g.edgeSet(e1).containsAll(g.getEdges());
    }

    @Test
    public void testLinkedVarIDs() {
        NodeGraph g = new NodeGraph();
        Node one = new Node("a", "b", Intersection.Kind.INCOMING);
        Node two = Util.newNodeOnSameBoard(one, Intersection.Kind.OUTGOING);
        Node three = Util.newNodeOnSameBoard(two, Intersection.Kind.CONNECT);

        EdgeData d1 = EdgeData.createMutable(1, "d1");
        EdgeData d2 = EdgeData.createMutable(1, "d2");
        EdgeData d3 = EdgeData.createMutable(2, "d3");

        g.linkVarIDs(Arrays.asList(1, 2));

        Edge e1 = g.addEdge(one, Port.OUTPUT, two, Port.INPUT, d1);
        g.addEdge(two, Port.OUTPUT, three, Port.INPUT, d2);
        Edge e3 = g.addEdge(one, new Port("x"), two, new Port("y"), d3);

        assert g.edgeSet(e1).containsAll(g.getEdges());
        assert g.edgeSet(e3).containsAll(g.getEdges());
    }

    @Test
    public void testLinkedVarIDs2() {
        NodeGraph g = new NodeGraph();
        Node one = new Node("a", "b", Intersection.Kind.INCOMING);
        Node two = Util.newNodeOnSameBoard(one, Intersection.Kind.OUTGOING);
        Node three = Util.newNodeOnSameBoard(two, Intersection.Kind.CONNECT);

        EdgeData d1 = EdgeData.createMutable(1, "d1");
        EdgeData d2 = EdgeData.createMutable(1, "d2");
        EdgeData d3 = EdgeData.createMutable(2, "d3");
        EdgeData d4 = EdgeData.createMutable(3, "d4");

        g.linkVarIDs(Arrays.asList(1, 2));
        g.linkVarIDs(Arrays.asList(2, 3));

        Edge e1 = g.addEdge(one, Port.OUTPUT, two, Port.INPUT, d1);
        Edge e2 = g.addEdge(two, Port.OUTPUT, three, Port.INPUT, d2);
        Edge e3 = g.addEdge(one, new Port("x"), two, new Port("y"), d3);
        Edge e4 = g.addEdge(one, new Port("z"), two, new Port("a"), d4);

        assert g.edgeSet(e1).containsAll(g.getEdges());
        assert g.edgeSet(e2).containsAll(g.getEdges());
        assert g.edgeSet(e3).containsAll(g.getEdges());
        assert g.edgeSet(e4).containsAll(g.getEdges());
    }

    @Test
    public void testLinkedVarIDs3() {
        NodeGraph g = new NodeGraph();
        g.linkVarIDs(Arrays.asList(10, 1));
        g.linkVarIDs(Arrays.asList(20, 2));
        g.linkVarIDs(Arrays.asList(1, 3));
        g.linkVarIDs(Arrays.asList(2, 3));
        assert g.areLinked(10, 20);
    }

    @Test
    public void testNegativeEdgeSets() {
        NodeGraph g = new NodeGraph();
        Node one = new Node("a", "b", Intersection.Kind.INCOMING);
        Node two = Util.newNodeOnSameBoard(one, Intersection.Kind.OUTGOING);
        Node three = Util.newNodeOnSameBoard(two, Intersection.Kind.CONNECT);

        EdgeData d1 = EdgeData.createMutable(1, "hello");
        EdgeData d2 = EdgeData.WIDE;
        EdgeData d3 = EdgeData.WIDE;

        Edge e1 = g.addEdge(one, Port.OUTPUT, two, Port.INPUT, d1);
        Edge e2 = g.addEdge(two, Port.OUTPUT, three, Port.INPUT, d2);
        Edge e3 = g.addEdge(two, new Port("eh"), three, new Port("why"), d3);

        assert g.edgeSet(e1).size() == 1;
        assert g.edgeSet(e2).size() == 1; // negative var ID means NO edge set
        assert g.edgeSet(e3).size() == 1; // negative var ID means NO edge set
    }

    /**
     * Tests for a previously observed bug where edges would lose their width
     * information on export
     */
    @Test
    public void testEdgeDump() {

        Board board = new Board();
        Intersection start = board.addNode(Intersection.Kind.INCOMING);
        Intersection connect = board.addNode(Intersection.Kind.CONNECT);
        Intersection end = board.addNode(Intersection.Kind.OUTGOING);

        Chute wideImmutable = new Chute(-1, "wide chute");
        wideImmutable.setNarrow(false);
        wideImmutable.setEditable(false);

        Chute narrowImmutable = new Chute(-1, "narrow chute");
        narrowImmutable.setNarrow(true);
        narrowImmutable.setEditable(false);

        board.add(start, "1", connect, "2", narrowImmutable);
        board.add(connect, "3", end, "4", wideImmutable);
        Level level = new Level();
        level.addBoard("board", board);
        World world = new World();
        world.addLevel("level", level);
        world.finishConstruction();

        NodeGraph g = io.load(world).getGraph();

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 3;

        assert finalBoard.getEdges().size() == 2;
        List<Chute> chutes = new ArrayList<>(finalBoard.getEdges());
        assert chutes.get(0).isNarrow() ^ chutes.get(1).isNarrow(); // 1 narrow, 1 wide
        for (Chute chute : chutes) {
            assert !chute.isEditable();
            assert chute.getVariableID() < 0;
        }

    }

}
