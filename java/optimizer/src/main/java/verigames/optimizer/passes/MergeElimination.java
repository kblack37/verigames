package verigames.optimizer.passes;

import verigames.level.Intersection;
import verigames.optimizer.OptimizationPass;
import verigames.optimizer.Util;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;
import verigames.optimizer.model.ReverseMapping;

import java.util.ArrayList;
import java.util.List;

/**
 * Eliminates merge nodes in a few different forms.
 *
 * <p>FORM 1:
 *
 * <pre>
 * \  SMALL_DROP     |
 *  \ /              |
 *   Y      ----->   O
 *   |               |
 *   |               |
 * </pre>
 *
 * Where "Y" is a merge node and "O" is a connector.
 *
 * While not particularly common in real worlds, this is a <i>very</i> common
 * output from the {@link BallDropElimination} optimization pass. Note that
 * the connect nodes we generate are likely to be eliminated by the
 * {@link ConnectorCompression} pass.
 *
 * <p>FORM 2:
 *
 * <pre>
 * \   /             |     |
 *  \ /              |     |
 *   Y      ----->   |     |
 *   |               |     |
 *  END             END   END
 * </pre>
 *
 * Where the edge connecting to the END node is conflict free.
 *
 * This is very common in real worlds, and this transformation assists the
 * {@link ChuteEndElimination} step immensely.
 *
 * Note that the form 1 transformation will always be taken in preference to
 * form 2. This is just an artifact of this implementation.
 */
public class MergeElimination implements OptimizationPass {

    @Override
    public void optimize(NodeGraph g, ReverseMapping mapping) {

        // wrap the nodes in a new array list to avoid concurrent modification
        // of a list we are iterating over
        for (Node n : new ArrayList<>(g.getNodes())) {

            if (n.getKind() == Intersection.Kind.MERGE) {

                List<Edge> incoming = new ArrayList<>(g.incomingEdges(n));

                // expect 2 inputs and 1 output
                Edge e1 = incoming.get(0);
                Edge e2 = incoming.get(1);
                Edge dst = Util.first(g.outgoingEdges(n));

                Node connector = Util.newNodeOnSameBoard(n, Intersection.Kind.CONNECT);

                // If either node was a small ball drop, we can remove this
                // merge and the drop and place a connector instead. No mapping
                // needs to take place.
                if (e1.getSrc().getKind() == Intersection.Kind.START_SMALL_BALL) {
                    g.removeNode(e1.getSrc());
                    g.removeNode(n);
                    g.addNode(connector);
                    Edge e2Replacement = g.addEdge(e2.getSrc(), e2.getSrcPort(), connector, Port.INPUT, e2.getEdgeData());
                    Edge dstReplacement = g.addEdge(connector, Port.OUTPUT, dst.getDst(), dst.getDstPort(), dst.getEdgeData());
                    mapping.mapEdge(g, e2, e2Replacement);
                    mapping.mapEdge(g, dst, dstReplacement);
                    mapping.mapBuzzsaw(e2, e2Replacement);
                    mapping.mapBuzzsaw(dst, dstReplacement);
                } else if (e2.getSrc().getKind() == Intersection.Kind.START_SMALL_BALL) {
                    g.removeNode(e2.getSrc());
                    g.removeNode(n);
                    g.addNode(connector);
                    Edge e1Replacement = g.addEdge(e1.getSrc(), e1.getSrcPort(), connector, Port.INPUT, e1.getEdgeData());
                    Edge dstReplacement = g.addEdge(connector, Port.OUTPUT, dst.getDst(), dst.getDstPort(), dst.getEdgeData());
                    mapping.mapEdge(g, e1, e1Replacement);
                    mapping.mapEdge(g, dst, dstReplacement);
                    mapping.mapBuzzsaw(e1, e1Replacement);
                    mapping.mapBuzzsaw(dst, dstReplacement);
                // If this merge drops to an END node we can split it up (described above).
                // The deleted outgoing edge should be made wide to avoid conflicts.
                } else if (dst.getDst().getKind() == Intersection.Kind.END && Util.conflictFree(g, dst)) {
                    g.removeNode(n);
                    Node end2 = Util.newNodeOnSameBoard(n, Intersection.Kind.END);
                    g.addNode(end2);
                    Edge e1Replacement = g.addEdge(e1.getSrc(), e1.getSrcPort(), dst.getDst(), dst.getDstPort(), e1.getEdgeData());
                    Edge e2Replacement = g.addEdge(e2.getSrc(), e2.getSrcPort(), end2, Port.INPUT, e2.getEdgeData());
                    mapping.forceWide(dst);
                    mapping.mapEdge(g, e1, e1Replacement);
                    mapping.mapEdge(g, e2, e2Replacement);
                    mapping.mapBuzzsaw(e1, e1Replacement);
                    mapping.mapBuzzsaw(e2, e2Replacement);
                }

            }

        }

    }

}
