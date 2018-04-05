package verigames.optimizer.passes;

import org.testng.annotations.Test;
import verigames.level.Board;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.World;
import verigames.optimizer.Util;
import verigames.optimizer.io.WorldIO;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.ReverseMapping;

@Test
public class BallDropEliminationTest {

    final WorldIO io = new WorldIO();

    @Test
    public void testBasics() {

        Board board = new Board();
        board.addNode(Intersection.Kind.INCOMING);
        Intersection outgoing = board.addNode(Intersection.Kind.OUTGOING);

        // add some interesting geometry we'll work on
        Intersection drop = board.addNode(Intersection.Kind.START_SMALL_BALL);
        Intersection c1 = board.addNode(Intersection.Kind.CONNECT);
        Intersection c2 = board.addNode(Intersection.Kind.CONNECT);
        board.addEdge(drop, "out", c1, "in", Util.mutableChute());
        board.addEdge(c1, "out", c2, "in", Util.immutableChute());
        board.addEdge(c2, "out", outgoing, "in", Util.mutableChute());

        board.finishConstruction();
        Level level = new Level();
        level.addBoard("board", board);
        level.finishConstruction();
        World world = new World();
        world.addLevel("level", level);
        world.validateSubboardReferences();
        NodeGraph g = io.load(world).getGraph();

        new BallDropElimination().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        // we expect the chain (drop -> c1 -> c2 -> outgoing) will be compressed (drop -> outgoing)
        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 3; // incoming, drop, and outgoing
        for (Intersection node : finalBoard.getNodes()) {
            if (node.getIntersectionKind() == Intersection.Kind.START_SMALL_BALL) {
                assert node.getOutputIDs().size() == 1;
                assert node.getOutput(node.getOutputIDs().get(0)).getEnd().getIntersectionKind() == Intersection.Kind.OUTGOING;
            }
        }

    }

    @Test
    public void testMergeElimination() {

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
        board.addEdge(drop1, "out", merge, "in1", Util.mutableChute());
        board.addEdge(drop2, "out", merge, "in2", Util.mutableChute());
        board.addEdge(merge, "out", outgoing, "in", Util.mutableChute());

        board.finishConstruction();
        Level level = new Level();
        level.addBoard("board", board);
        level.finishConstruction();
        World world = new World();
        world.addLevel("level", level);
        world.validateSubboardReferences();
        NodeGraph g = io.load(world).getGraph();

        new BallDropElimination().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        // we expect the graph will be compressed into (drop -> outgoing)
        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 3; // incoming, drop, and outgoing
        for (Intersection node : finalBoard.getNodes()) {
            if (node.getIntersectionKind() == Intersection.Kind.START_SMALL_BALL) {
                assert node.getOutputIDs().size() == 1;
                assert node.getOutput(node.getOutputIDs().get(0)).getEnd().getIntersectionKind() == Intersection.Kind.OUTGOING;
            }
        }

    }

    /**
     * empty ball drops should become small ball drops
     */
    @Test
    public void emptyBallDropsToSmallBallDrops() {

        Board board = new Board();
        board.addNode(Intersection.Kind.INCOMING);
        Intersection outgoing = board.addNode(Intersection.Kind.OUTGOING);
        Intersection drop = board.addNode(Intersection.Kind.START_NO_BALL);
        board.addEdge(drop, "out", outgoing, "in", Util.mutableChute());

        board.finishConstruction();
        Level level = new Level();
        level.addBoard("board", board);
        level.finishConstruction();
        World world = new World();
        world.addLevel("level", level);
        world.validateSubboardReferences();
        NodeGraph g = io.load(world).getGraph();

        new BallDropElimination().optimize(g, new ReverseMapping());

        World finalWorld = io.toWorld(g).getFirst();
        assert finalWorld.getLevels().size() == 1;

        Level finalLevel = Util.first(finalWorld.getLevels().values());
        assert finalLevel.getBoards().size() == 1;

        // we expect the drop node to become a small ball drop
        Board finalBoard = Util.first(finalLevel.getBoards().values());
        assert finalBoard.getNodes().size() == 3; // incoming, drop, and outgoing
        boolean found = false;
        for (Intersection node : finalBoard.getNodes()) {
            if (node.getIntersectionKind() == Intersection.Kind.START_SMALL_BALL) {
                found = true;
                assert node.getOutputIDs().size() == 1;
                assert node.getOutput(node.getOutputIDs().get(0)).getEnd().getIntersectionKind() == Intersection.Kind.OUTGOING;
            }
        }
        assert found; // make sure we found a small ball drop

    }

}
