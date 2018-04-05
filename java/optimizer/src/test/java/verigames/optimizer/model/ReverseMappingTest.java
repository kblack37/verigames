package verigames.optimizer.model;

import org.junit.BeforeClass;
import org.testng.annotations.Test;
import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.World;
import verigames.optimizer.SolutionTransferMain;
import verigames.optimizer.Util;
import verigames.optimizer.io.WorldIO;
import verigames.utilities.Pair;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Test
public class ReverseMappingTest {

    List<Node> nodes;
    List<Edge> edges;

    @BeforeClass
    public void setup() {
        nodes = new ArrayList<>();
        for (int i = 0; i < 100; ++i) {
            nodes.add(new Node("a", "b", Intersection.Kind.CONNECT));
        }

        edges = new ArrayList<>();
        for (int i = 0; i < 99; ++i) {
            edges.add(new Edge(
                    nodes.get(i), Port.OUTPUT,
                    nodes.get(i + 1), Port.INPUT,
                    EdgeData.createMutable(i, "x")));
        }
    }

    @Test
    public void testWidthMapping() {
        ReverseMapping m = new ReverseMapping();
        m.putWidthMapping(1, new ReverseMapping.EdgeMapping(2));
        assert m.getWidthMappings().get(1).equals(new ReverseMapping.EdgeMapping(2));
    }

    @Test
    public void testChainWidthMapping() {
        ReverseMapping m = new ReverseMapping();
        NodeGraph g = new NodeGraph();
        m.initEdge(1, edges.get(0));
        m.mapEdge(g, edges.get(0), edges.get(1));
        m.mapEdge(g, edges.get(1), edges.get(3));
        m.finalizeEdge(edges.get(3), 2);
        assert m.getWidthMappings().get(1).equals(new ReverseMapping.EdgeMapping(2));
        assert !m.getBuzzsawMappings().get(1).equals(new ReverseMapping.EdgeMapping(2));
    }

    @Test
    public void testFixedWidthMapping() {
        ReverseMapping m = new ReverseMapping();

        m.initEdge(1, edges.get(0));
        m.forceNarrow(edges.get(0));
        m.finalizeEdge(edges.get(0), 2);
        assert m.getWidthMappings().get(1).equals(ReverseMapping.TRUE);

        m.initEdge(4, edges.get(1));
        m.forceWide(edges.get(1));
        m.finalizeEdge(edges.get(1), 5);
        assert m.getWidthMappings().get(4).equals(ReverseMapping.FALSE);
    }

    @Test
    public void testBuzzsawMapping() {
        ReverseMapping m = new ReverseMapping();
        m.putBuzzsawMapping(1, new ReverseMapping.EdgeMapping(2));
        assert m.getBuzzsawMappings().get(1).equals(new ReverseMapping.EdgeMapping(2));
    }

    @Test
    public void testChainBuzzsawMapping() {
        ReverseMapping m = new ReverseMapping();
        NodeGraph g = new NodeGraph();
        m.initEdge(1, edges.get(0));
        m.mapBuzzsaw(edges.get(0), edges.get(1));
        m.mapBuzzsaw(edges.get(1), edges.get(3));
        m.finalizeEdge(edges.get(3), 2);
        assert !m.getWidthMappings().get(1).equals(new ReverseMapping.EdgeMapping(2));
        assert m.getBuzzsawMappings().get(1).equals(new ReverseMapping.EdgeMapping(2));
    }

    @Test
    public void testBuzzsawTransfer() {
        ReverseMapping m = new ReverseMapping();

        NodeGraph g = new NodeGraph();
        Edge e = g.addEdge(
                new Node("a", "b", Intersection.Kind.INCOMING),
                Port.OUTPUT,
                new Node("a", "b", Intersection.Kind.OUTGOING),
                Port.INPUT,
                EdgeData.createMutable(1, "x"));

        World w1 = new WorldIO().toWorld(g).getFirst(); // "optimized" world
        World w2 = new WorldIO().toWorld(g).getFirst(); // "unoptimized" world

        Chute c1 = Util.first(w1.getChutes());
        Chute c2 = Util.first(w2.getChutes());

        // simulate optimization
        m.initEdge(c2.getUID(), e);
        m.finalizeEdge(e, c1.getUID());

        assert m.getBuzzsawMappings().get(c2.getUID()).equals(new ReverseMapping.EdgeMapping(c1.getUID()));

        Util.first(w1.getChutes()).setBuzzsaw(true);
        SolutionTransferMain.applySolution(w1, m, w2);
        assert Util.first(w2.getChutes()).hasBuzzsaw();

        Util.first(w1.getChutes()).setBuzzsaw(false);
        SolutionTransferMain.applySolution(w1, m, w2);
        assert !Util.first(w2.getChutes()).hasBuzzsaw();
    }

    private void apply(ReverseMapping m, World unoptimized, World optimized) {
        SolutionTransferMain.applySolution(optimized, m, unoptimized);
    }

    @Test
    public void testApply() throws IOException {

        Board board = new Board();
        board.addNode(Intersection.Kind.INCOMING);
        Intersection outgoing = board.addNode(Intersection.Kind.OUTGOING);

        // add some interesting geometry we'll work on
        //   drop1 _
        //          \_________ outgoing
        //         _/ merge
        //   drop2
        Intersection drop1 = board.addNode(Intersection.Kind.START_SMALL_BALL);
        Intersection drop2 = board.addNode(Intersection.Kind.START_SMALL_BALL);
        Intersection merge = board.addNode(Intersection.Kind.MERGE);

        Chute c1 = new Chute(1, "");
        Chute c2 = new Chute(2, "");
        Chute c3 = new Chute(3, "");

        c1.setEditable(true);
        c2.setEditable(true);
        c3.setEditable(true);

        board.addEdge(drop1, "out", merge, "in1", c1);
        board.addEdge(drop2, "out", merge, "in2", c2);
        board.addEdge(merge, "out", outgoing, "in", c3);

        Level level = new Level();
        level.addBoard("board", board);
        World world = new World();
        world.addLevel("level", level);
        world.finishConstruction();

        // --------

        board = new Board();
        Intersection incoming = board.addNode(Intersection.Kind.INCOMING);
        outgoing = board.addNode(Intersection.Kind.OUTGOING);

        // add some interesting geometry we'll work on
        //   incoming -------- outgoing
        Chute optimizedChute = new Chute(4, "");
        optimizedChute.setEditable(false);
        optimizedChute.setNarrow(false);
        optimizedChute.setBuzzsaw(true);

        board.addEdge(incoming, "out", outgoing, "in1", optimizedChute);

        level = new Level();
        level.addBoard("board", board);
        World optimized = new World();
        optimized.addLevel("level", level);
        optimized.finishConstruction();

        // --------

        ReverseMapping mapping = new ReverseMapping();
        mapping.initEdge(c1.getUID(), edges.get(1));
        mapping.initEdge(c2.getUID(), edges.get(2));
        mapping.initEdge(c3.getUID(), edges.get(3));
        mapping.forceNarrow(edges.get(1), true);
        mapping.forceNarrow(edges.get(2), false);
        Edge intermediate = edges.get(50);
        mapping.mapEdge(new NodeGraph(), edges.get(3), intermediate);

        mapping.mapBuzzsaw(edges.get(3), intermediate);

        mapping.finalizeEdge(intermediate, optimizedChute.getUID());

        apply(mapping, world, optimized);
        assert c1.isNarrow();
        assert !c2.isNarrow();
        assert c3.isNarrow() == optimizedChute.isNarrow();
        assert c3.hasBuzzsaw() == optimizedChute.hasBuzzsaw();
        assert !c1.hasBuzzsaw();
        assert !c2.hasBuzzsaw();
    }

    /**
     * Tests this case:
     *
     * <pre>
     * unoptimized
     *    X ---> Y ---> Z
     *       E1     E2
     * </pre>
     *
     * The optimized world & mapping is just the result of importing a
     * NodeGraph and exporting to a world again.
     *
     * Buzzsaws should be transferred successfully.
     */
    @Test
    public void testDefaultBuzzsawTransfer() {

        Board board = new Board();
        Intersection in = board.addNode(Intersection.Kind.INCOMING);
        Intersection conn = board.addNode(Intersection.Kind.CONNECT);
        Intersection out = board.addNode(Intersection.Kind.OUTGOING);

        Chute c1 = new Chute(1, "");
        Chute c2 = new Chute(2, "");

        board.addEdge(in, "out", conn, "in1", c1);
        board.addEdge(conn, "out", out, "in2", c2);

        Level level = new Level();
        level.addBoard("board", board);
        World world = new World();
        world.addLevel("level", level);
        world.finishConstruction();

        //------------------------------

        ReverseMapping map = new ReverseMapping();
        WorldIO.LoadedWorld w = new WorldIO().load(world);
        map.initAll(w.getEdgeIDMapping());
        Pair<World, Map<Edge, Integer>> p = new WorldIO().toWorld(w.getGraph());
        World world2 = p.getFirst();
        map.finalizeAll(p.getSecond());

        //------------------------------

        List<Chute> edges = new ArrayList<>(world2.getChutes());
        assert edges.size() == 2;
        Chute c3 = edges.get(0).getVariableID() == 1 ? edges.get(0) : edges.get(1); // copy of c1
        Chute c4 = edges.get(0).getVariableID() == 1 ? edges.get(1) : edges.get(0); // copy of c2

        c3.setBuzzsaw(true);
        apply(map, world, world2);
        assert c1.hasBuzzsaw();
        assert !c2.hasBuzzsaw();

        c3.setBuzzsaw(false);
        apply(map, world, world2);
        assert !c1.hasBuzzsaw();
        assert !c2.hasBuzzsaw();

        c4.setBuzzsaw(true);
        apply(map, world, world2);
        assert !c1.hasBuzzsaw();
        assert c2.hasBuzzsaw();

        c4.setBuzzsaw(false);
        apply(map, world, world2);
        assert !c1.hasBuzzsaw();
        assert !c2.hasBuzzsaw();

    }

    /**
     * Tests this case:
     *
     * <pre>
     * unoptimized
     *    X ---> Y ---> Z
     *       1      1
     *
     * optimized
     *    X ---> Z
     *       1
     *
     * mapping
     *    (empty)
     * </pre>
     *
     * What should happen is that both edges (with var ID = 1) get the same
     * value that the single optimized edge (with var ID = 1) has.
     *
     */
    @Test
    public void testApply2() {
        for (boolean narrow : Arrays.asList(true, false)) {
            Chute c1 = new Chute(1, "a");
            Chute c2 = new Chute(1, "b");
            c1.setEditable(true);
            c2.setEditable(true);
            Board b1 = new Board();
            Intersection incoming = b1.addNode(Intersection.Kind.INCOMING);
            Intersection connection = b1.addNode(Intersection.Kind.CONNECT);
            b1.add(incoming, "1", connection, "2", c1);
            b1.add(connection, "3", Intersection.Kind.OUTGOING, "4", c2);
            Level l1 = new Level();
            l1.addBoard("b", b1);
            World unoptimized = new World();
            unoptimized.addLevel("l", l1);
            unoptimized.finishConstruction();

            Board b2 = new Board();
            Chute c3 = new Chute(1, "c");
            c3.setEditable(true);
            b2.add(Intersection.Kind.INCOMING, "1", Intersection.Kind.OUTGOING, "2", c3);
            Level l2 = new Level();
            l2.addBoard("b", b2);
            World optimized = new World();
            optimized.addLevel("l", l2);
            optimized.finishConstruction();

            c1.setNarrow(!narrow);
            c2.setNarrow(!narrow);
            c3.setNarrow(narrow);


            ReverseMapping m = new ReverseMapping();

            c3.setNarrow(false);
            apply(m, unoptimized, optimized);
            assert c1.isNarrow() == c3.isNarrow();
            assert c2.isNarrow() == c3.isNarrow();

            c3.setNarrow(true);
            apply(m, unoptimized, optimized);
            assert c1.isNarrow() == c3.isNarrow();
            assert c2.isNarrow() == c3.isNarrow();
        }
    }

}
