package verigames.optimizer.passes;

import verigames.level.Intersection;
import verigames.optimizer.Util;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.EdgeData;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;
import verigames.optimizer.model.ReverseMapping;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Set;

/**
 * Optimization pass that removes as many {@link Intersection.Kind#END}
 * nodes as possible.
 */
public class ChuteEndElimination extends AbstractIterativePass {

    public boolean shouldRemove(NodeGraph g, Node node, Set<Node> alreadyRemoved) {
        Intersection.Kind kind = node.getKind();

        // Remove end nodes when the incoming edge is conflict-free.
        if (kind == Intersection.Kind.END && Util.conflictFree(g, Util.first(g.incomingEdges(node)))) {
            return true;
        }

        // Remove a node if all of its incoming/outgoing chutes are conflict
        // free and all outgoing nodes are eliminated.
        // Intuition: if all outgoing chutes are wide and eliminated, then all
        // balls dropped out of this node will flow successfully to an END.
        Collection<Edge> edges = new ArrayList<>(g.outgoingEdges(node));
        edges.addAll(g.incomingEdges(node));
        if (edges.size() > 0 && kind != Intersection.Kind.INCOMING) {
            boolean canEliminate = true;
            for (Edge e : edges) {
                if (!alreadyRemoved.contains(e.getDst()) || !Util.conflictFree(g, e)) {
                    canEliminate = false;
                    break;
                }
            }
            if (canEliminate) {
                return true;
            }
        }

        return false;
    }

    @Override
    public boolean shouldRemove(NodeGraph g, Node node, Set<Node> alreadyRemoved, ReverseMapping mapping) {
        boolean canEliminate = shouldRemove(g, node, alreadyRemoved);
        if (canEliminate) {
            for (Edge e : g.outgoingEdges(node)) {
                mapping.forceWide(e);
            }
            for (Edge e : g.incomingEdges(node)) {
                mapping.forceWide(e);
            }
        }
        return canEliminate;
    }

    @Override
    public void fixup(NodeGraph g, Collection<Edge> brokenEdges, ReverseMapping mapping) {
        for (Edge e : brokenEdges) {
            Node src = e.getSrc();

            // we should only have edges with missing targets, or something has gone very wrong
            assert g.getNodes().contains(src);
            assert !g.getNodes().contains(e.getDst());

            // Arbitrarily, create an immutable wide chute to drop into. We could just as easily
            // create a mutable narrow one or something, but immutable wide chutes are easier to
            // reason about.
            Node n = Util.newNodeOnSameBoard(src, Intersection.Kind.END);
            g.addNode(n);
            g.addEdge(e.getSrc(), e.getSrcPort(), n, Port.INPUT, EdgeData.WIDE);
        }
    }

}
