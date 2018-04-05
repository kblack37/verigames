package verigames.optimizer.passes;

import verigames.level.Intersection;
import verigames.optimizer.OptimizationPass;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.ReverseMapping;
import verigames.optimizer.model.Subgraph;

/**
 * Remove isolated, immutable components from the graph. If
 * every chute in a component is immutable, then the user
 * probably doesn't care about it.
 */
public class ImmutableComponentElimination implements OptimizationPass {
    @Override
    public void optimize(NodeGraph g, ReverseMapping mapping) {
        for (Subgraph subgraph : g.getComponents()) {
            boolean mutable = false;
            for (Edge edge : subgraph.getEdges()) {
                mutable = edge.getEdgeData().isEditable();
                if (mutable)
                    break;
            }
            boolean hasFixedNode = false;
            for (Node node : subgraph.getNodes()) {
                Intersection.Kind kind = node.getKind();
                hasFixedNode = (kind == Intersection.Kind.INCOMING || kind == Intersection.Kind.OUTGOING);
                if (hasFixedNode)
                    break;
            }
            if (!mutable && !hasFixedNode) {
                g.removeSubgraph(subgraph);
            }
        }
    }
}
