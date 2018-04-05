package verigames.optimizer.passes;

import org.testng.annotations.Test;
import verigames.level.Intersection;
import verigames.optimizer.Util;
import verigames.optimizer.model.EdgeData;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;
import verigames.optimizer.model.ReverseMapping;

@Test
public class ImmutableComponentEliminationTest {

    /**
     * In ordinary cases, isolated immutable components
     * should be removed.
     */
    @Test
    public void testIsolatedComponentRemoval() {
        NodeGraph g = new NodeGraph();
        Node n1 = new Node("board", "level", Intersection.Kind.INCOMING);
        Node n2 = Util.newNodeOnSameBoard(n1, Intersection.Kind.OUTGOING);
        Node n3 = Util.newNodeOnSameBoard(n1, Intersection.Kind.START_LARGE_BALL);
        Node n4 = Util.newNodeOnSameBoard(n1, Intersection.Kind.END);
        g.addNode(n1);
        g.addNode(n2);
        g.addEdge(n3, Port.OUTPUT, n4, Port.INPUT, EdgeData.WIDE);

        new ImmutableComponentElimination().optimize(g, new ReverseMapping());

        assert g.getNodes().size() == 2;
        for (Node node : g.getNodes()) {
            assert node.getKind() != Intersection.Kind.START_LARGE_BALL;
            assert node.getKind() != Intersection.Kind.END;
        }

        assert g.getEdges().size() == 0;
    }

    /**
     * Components containing an INCOMING node should NOT
     * be removed.
     */
    @Test
    public void inputNodesArePreserved() {
        NodeGraph g = new NodeGraph();
        Node n1 = new Node("board", "level", Intersection.Kind.INCOMING);
        Node n2 = Util.newNodeOnSameBoard(n1, Intersection.Kind.OUTGOING);
        g.addEdge(n1, Port.OUTPUT, n2, Port.INPUT, EdgeData.WIDE);
        new ImmutableComponentElimination().optimize(g, new ReverseMapping());
        assert g.getNodes().size() == 2;
        assert g.getEdges().size() == 1;
    }

}
