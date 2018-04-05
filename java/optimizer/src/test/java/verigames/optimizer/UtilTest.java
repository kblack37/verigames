package verigames.optimizer;

import org.testng.annotations.Test;
import verigames.level.Intersection;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.EdgeData;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;

import java.util.Arrays;

@Test
public class UtilTest {

    /**
     * Immutable wide edges are conflict-free.
     */
    @Test
    void testImmutableWideConflictFree() {
        NodeGraph g = new NodeGraph();
        Node start = new Node("l", "b", Intersection.Kind.INCOMING);
        Node end = new Node("l", "b", Intersection.Kind.OUTGOING);
        Edge e1 = g.addEdge(start, new Port("1"), end, new Port("2"), EdgeData.WIDE);
        assert Util.conflictFree(g, e1);
    }

    /**
     * Isolated edges are conflict-free.
     */
    @Test
    void testIsolatedConflictFree() {
        NodeGraph g = new NodeGraph();
        Node start = new Node("l", "b", Intersection.Kind.INCOMING);
        Node end = new Node("l", "b", Intersection.Kind.OUTGOING);
        Edge e1 = g.addEdge(start, new Port("1"), end, new Port("2"), EdgeData.createMutable(1, "hello"));
        assert Util.conflictFree(g, e1);
    }

    /**
     * Edges that share a var ID with another edge are not conflict-free.
     */
    @Test
    void testSameVarIDNotConflictFree() {
        NodeGraph g = new NodeGraph();
        Node start = new Node("l", "b", Intersection.Kind.INCOMING);
        Node end = new Node("l", "b", Intersection.Kind.OUTGOING);
        EdgeData data1 = EdgeData.createMutable(1, "hello");
        EdgeData data2 = EdgeData.createMutable(1, "hello");
        Edge e1 = g.addEdge(start, new Port("1"), end, new Port("2"), data1);
        Edge e2 = g.addEdge(start, new Port("3"), end, new Port("4"), data2);
        assert !Util.conflictFree(g, e1);
        assert !Util.conflictFree(g, e2);
    }

    /**
     * Edges with linked var IDs are not conflict-free.
     */
    @Test
    void testLinkedEdgesNotConflictFree() {
        NodeGraph g = new NodeGraph();
        Node start = new Node("l", "b", Intersection.Kind.INCOMING);
        Node end = new Node("l", "b", Intersection.Kind.OUTGOING);
        EdgeData data1 = EdgeData.createMutable(1, "hello");
        EdgeData data2 = EdgeData.createMutable(2, "hello");
        Edge e1 = g.addEdge(start, new Port("1"), end, new Port("2"), data1);
        Edge e2 = g.addEdge(start, new Port("3"), end, new Port("4"), data2);
        g.linkVarIDs(Arrays.asList(data1.getVariableID(), data2.getVariableID()));
        assert !Util.conflictFree(g, e1);
        assert !Util.conflictFree(g, e2);
    }

    /**
     * Edges originating at pipe-dependent balls are not conflict-free.
     */
    @Test
    void testPipeDependentBallNotConflictFree() {
        NodeGraph g = new NodeGraph();
        Node start = new Node("l", "b", Intersection.Kind.START_PIPE_DEPENDENT_BALL);
        Node end = new Node("l", "b", Intersection.Kind.END);
        EdgeData data = EdgeData.createMutable(1, "hello");
        Edge e = g.addEdge(start, Port.INPUT, end, Port.OUTPUT, data);
        assert !Util.conflictFree(g, e);
        e = g.addEdge(start, Port.INPUT, end, Port.OUTPUT, EdgeData.WIDE);
        assert !Util.conflictFree(g, e);
        e = g.addEdge(start, Port.INPUT, end, Port.OUTPUT, EdgeData.NARROW);
        assert !Util.conflictFree(g, e);
    }

}
