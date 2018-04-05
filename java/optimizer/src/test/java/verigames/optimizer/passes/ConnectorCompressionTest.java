package verigames.optimizer.passes;

import org.testng.annotations.Test;
import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.World;
import verigames.optimizer.SolutionTransferMain;
import verigames.optimizer.Util;
import verigames.optimizer.io.WorldIO;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.EdgeData;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;
import verigames.optimizer.model.ReverseMapping;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@Test
public class ConnectorCompressionTest {

    final boolean[] bools = { true, false };
    final WorldIO io = new WorldIO();

    /**
     * Connectors should be compressed in the expected way
     */
    @Test
    public void testConnectorCompression1() {
        Board board = new Board();
        Intersection start = board.addNode(Intersection.Kind.INCOMING);
        Intersection connect = board.addNode(Intersection.Kind.CONNECT);
        board.add(start, "1", connect, "1", Util.mutableChute());
        board.add(connect, "2", Intersection.Kind.OUTGOING, "1", Util.mutableChute());
        board.finishConstruction();
        Level level = new Level();
        level.addBoard("board", board);
        level.finishConstruction();
        World world = new World();
        world.addLevel("level", level);
        world.validateSubboardReferences();
        NodeGraph g = io.load(world).getGraph();

        new ConnectorCompression().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 2;
        for (Intersection node : finalBoard.getNodes()) {
            assert node.getIntersectionKind() != Intersection.Kind.CONNECT;
        }

        assert finalBoard.getEdges().size() == 1;
        for (Chute chute : finalBoard.getEdges()) {
            assert !chute.isEditable(); // everything is conflict-free
        }
    }

    /**
     * Connector compression should NOT remove edges that belong to
     * an edge set.
     */
    @Test
    public void testConnectorCompression2() {
        Board board = new Board();
        Intersection start = board.addNode(Intersection.Kind.INCOMING);
        Intersection merge = board.addNode(Intersection.Kind.MERGE);
        Intersection connect = board.addNode(Intersection.Kind.CONNECT);

        // 2 chutes in the same edge set
        Chute c1 = new Chute(3, "?");
        Chute c2 = new Chute(3, "?");

        // 2 more chutes in the same edge set
        Chute c3 = new Chute(4, "?");
        Chute c4 = new Chute(4, "?");

        board.add(start, "1", connect, "2", c1);
        board.add(start, "3", merge, "4", c2);
        board.add(connect, "5", merge, "6", c3);
        board.add(merge, "7", Intersection.Kind.OUTGOING, "8", c4);
        board.finishConstruction();
        Level level = new Level();
        level.addBoard("board", board);
        level.finishConstruction();
        World world = new World();
        world.addLevel("level", level);
        world.validateSubboardReferences();
        NodeGraph g = io.load(world).getGraph();

        new ConnectorCompression().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 4;
        assert finalBoard.getEdges().size() == 4;
    }

    /**
     * Connector compression SHOULD compress edges that belong to the
     * same edge set.
     */
    @Test
    public void testConnectorCompression3() {
        Board board = new Board();
        Intersection start = board.addNode(Intersection.Kind.INCOMING);
        Intersection merge = board.addNode(Intersection.Kind.MERGE);
        Intersection connect = board.addNode(Intersection.Kind.CONNECT);

        // 3 chutes in the same edge set
        Chute c1 = new Chute(3, "?");
        Chute c2 = new Chute(3, "?");
        Chute c3 = new Chute(3, "?");

        board.add(start, "1", connect, "2", c1);
        board.add(start, "3", merge, "4", c2);
        board.add(connect, "5", merge, "6", c3);
        board.add(merge, "7", Intersection.Kind.OUTGOING, "8", Util.mutableChute());
        board.finishConstruction();
        Level level = new Level();
        level.addBoard("board", board);
        level.finishConstruction();
        World world = new World();
        world.addLevel("level", level);
        world.validateSubboardReferences();
        NodeGraph g = io.load(world).getGraph();

        new ConnectorCompression().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        Board finalBoard = Util.first(finalLevel.getBoards().values());
        System.out.println(finalBoard.getNodes());
        assert finalBoard.getNodes().size() == 3;
        for (Intersection node : finalBoard.getNodes()) {
            assert node.getIntersectionKind() != Intersection.Kind.CONNECT;
        }

        assert finalBoard.getEdges().size() == 3;
    }


    /**
     * Regression test for an odd bug
     */
    @Test
    public void testConnectorCompression4() {

        // Input:
        //                   1
        //    Start  ---------------->  End
        //         \                    /
        //          ----> connector ----
        //           2               3
        //     where:
        //        1 is immutable wide
        //        2 is immutable narrow
        //        3 is mutable wide
        //
        // Expected output:
        //                   1
        //    Start  ---------------->  End
        //         \                    /
        //          -------------------
        //                   2
        //     where:
        //        1 is immutable wide
        //        2 is immutable narrow

        Board board = new Board();
        Intersection start = board.addNode(Intersection.Kind.INCOMING);
        Intersection connect = board.addNode(Intersection.Kind.CONNECT);
        Intersection end = board.addNode(Intersection.Kind.OUTGOING);

        Chute narrowImmutable = Util.immutableChute();
        narrowImmutable.setNarrow(true);

        Chute wideEditable = Util.mutableChute();
        wideEditable.setNarrow(false);
        wideEditable = wideEditable.copy(17, "hello");

        Chute wideImmutable = Util.immutableChute();
        wideImmutable.setNarrow(false);

        board.add(start, "1", connect, "2", narrowImmutable);
        board.add(connect, "3", end, "4", wideEditable);
        board.add(start, "5", end, "6", wideImmutable);
        Level level = new Level();
        level.addBoard("board", board);
        World world = new World();
        world.addLevel("level", level);
        world.finishConstruction();

        NodeGraph g = io.load(world).getGraph();

        new ConnectorCompression().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 2;
        for (Intersection node : finalBoard.getNodes()) {
            assert node.getIntersectionKind() != Intersection.Kind.CONNECT;
        }

        assert finalBoard.getEdges().size() == 2;
        List<Chute> chutes = new ArrayList<>(finalBoard.getEdges());
        assert chutes.get(0).isNarrow() ^ chutes.get(1).isNarrow(); // 1 narrow, 1 wide
        for (Chute chute : chutes) {
            assert !chute.isEditable();
            assert chute.getVariableID() < 0;
        }
    }

    private int varID = 0;
    private Collection<EdgeData> allChuteCombos() {
        Collection<EdgeData> result = new ArrayList<>();
        result.add(EdgeData.WIDE);
        result.add(EdgeData.NARROW);
        for (boolean narrow : bools) {
            result.add(EdgeData.createMutable(varID++, "no desc"));
        }
        return result;
    }

    /**
     * Make a graph that looks like
     * <pre>
     *     incoming -------> connector --------> outgoing
     *                 1                   2
     * </pre>
     * Where (1) is the given incoming chute and (2) is the
     * given outgoing chute.
     * @param incoming the incoming chute
     * @param outgoing the outgoing chute
     * @return a complete graph
     */
    private NodeGraph mkGraph(EdgeData incoming, EdgeData outgoing) {
        NodeGraph g = new NodeGraph();
        String level = "level";
        String board = "board";
        Node in = new Node(level, board, Intersection.Kind.INCOMING);
        Node cn = new Node(level, board, Intersection.Kind.CONNECT);
        Node on = new Node(level, board, Intersection.Kind.OUTGOING);
        g.addEdge(in, Port.OUTPUT, cn, Port.INPUT, incoming);
        g.addEdge(cn, Port.OUTPUT, on, Port.INPUT, outgoing);
        return g;
    }

    /**
     * Test merging for wide & immutable edges
     */
    @Test
    public void mergeWithWideImmutable() {
        System.out.println("mergeWithWideImmutable");
        ConnectorCompression compress = new ConnectorCompression();
        boolean[] bools = { true, false };
        for (EdgeData data : allChuteCombos()) {
            for (boolean swapped : bools) {
                NodeGraph g = swapped ? mkGraph(data, EdgeData.WIDE) : mkGraph(EdgeData.WIDE, data);
                Edge wide = null;
                Edge chute = null;
                for (Edge e : g.getEdges()) {
                    if (e.getEdgeData() == EdgeData.WIDE && wide == null)
                        wide = e;
                    else
                        chute = e;
                }
                EdgeData merged = swapped ?
                        compress.compressChutes(chute, wide, g):
                        compress.compressChutes(wide, chute, g);

                // for debugging
                System.out.println(chute + " ---> " + merged);

                assert merged != null;
                assert chute.isEditable() || merged.isNarrow() == chute.isNarrow();
                assert Util.conflictFree(g, chute) ? !merged.isEditable() : merged.isEditable() == chute.isEditable();
            }
        }

    }

    /**
     * Test merging for narrow & immutable edges
     */
    @Test
    public void mergeWithNarrowImmutable() {
        System.out.println("mergeWithNarrowImmutable");
        ConnectorCompression compress = new ConnectorCompression();
        for (EdgeData data : allChuteCombos()) {
            for (boolean swapped : bools) {
                NodeGraph g = swapped ? mkGraph(data, EdgeData.NARROW) : mkGraph(EdgeData.NARROW, data);
                Edge narrow = null;
                Edge chute = null;
                for (Edge e : g.getEdges()) {
                    if (e.getEdgeData() == EdgeData.NARROW && narrow == null)
                        narrow = e;
                    else
                        chute = e;
                }
                EdgeData merged = swapped ?
                        compress.compressChutes(chute, narrow, g):
                        compress.compressChutes(narrow, chute, g);

                // for debugging
                System.out.println(chute + " ---> " + merged);

                assert merged != null;
                assert !merged.isEditable();
                assert merged.isNarrow();
            }
        }
    }

    private boolean fitsLargeBall(Chute chute) {
        return chute.hasBuzzsaw() || (!chute.isNarrow() && !chute.isPinched());
    }

    /**
     * Test the key invariant of connector compression: if a wide ball can
     * flow down the compressed pipe, then it can flow down the two real
     * chutes.
     */
    @Test
    public void testFullCompression() {
        ConnectorCompression compression = new ConnectorCompression();
        for (EdgeData e1 : allChuteCombos()) {
            for (EdgeData e2 : allChuteCombos()) {

                // Assemble a world
                Board board = new Board();
                Intersection start = board.addNode(Intersection.Kind.INCOMING);
                Intersection connect = board.addNode(Intersection.Kind.CONNECT);
                Intersection outgoing = board.addNode(Intersection.Kind.OUTGOING);
                board.add(start, "1", connect, "2", e1.toChute());
                board.add(connect, "3", outgoing, "4", e2.toChute());
                Level level = new Level();
                level.addBoard("board", board);
                World world = new World();
                world.addLevel("level", level);
                world.finishConstruction();

                // Optimize the world
                NodeGraph g = io.load(world).getGraph();
                ReverseMapping mapping = new ReverseMapping();
                compression.optimize(g, mapping);
                World optimizedWorld = io.toWorld(g).getFirst();

                // find all the chutes in the optimized world
                Collection<Chute> optimizedChutes = optimizedWorld.getChutes();
                Collection<Chute> unoptimizedChutes = world.getChutes();

                // player makes all the mutable edges in the optimized
                // world narrow
                for (Chute c : optimizedChutes) {
                    if (c.isEditable())
                        c.setNarrow(true);
                }

                // translate this back to the original world
                System.out.println("------------");
                SolutionTransferMain.applySolution(optimizedWorld, mapping, world);

                // figure out if there are "conflicts" in the optimized world
                // (we'll just assume that our incoming node drops large balls)
                boolean noConflict = true;
                for (Chute c : optimizedChutes) {
                    noConflict = noConflict && fitsLargeBall(c);
                }

                // figure out if there are "conflicts" in the unoptimized world
                boolean noConflictU = true;
                for (Chute c : unoptimizedChutes) {
                    noConflictU = noConflictU && fitsLargeBall(c);
                }

                if (noConflict) {
                    // verify that if there are NO conflicts in the optimized
                    // world, then there are NO conflicts in the unoptimized one
                    assert noConflictU;
                } else {
                    // verify that if there ARE conflicts in the optimized
                    // world, then there ARE conflicts in the unoptimized one
                    assert !noConflictU;
                }

                // player makes all the mutable edges in the optimized
                // world wide
                for (Chute c : optimizedChutes) {
                    if (c.isEditable())
                        c.setNarrow(false);
                }

                // translate this back to the original world
                SolutionTransferMain.applySolution(optimizedWorld, mapping, world);

                // figure out if there are "conflicts" (we'll just assume
                // that our incoming node drops large balls)
                noConflict = true;
                for (Chute c : optimizedChutes) {
                    noConflict = noConflict && fitsLargeBall(c);
                }

                // figure out if there are "conflicts" in the unoptimized world
                noConflictU = true;
                for (Chute c : unoptimizedChutes) {
                    noConflictU = noConflictU && fitsLargeBall(c);
                }

                if (noConflict) {
                    // verify that if there are NO conflicts in the optimized
                    // world, then there are NO conflicts in the unoptimized one
                    assert noConflictU;
                } else {
                    // verify that if there ARE conflicts in the optimized
                    // world, then there ARE conflicts in the unoptimized one
                    assert !noConflictU;
                }

            }
        }
    }

}
