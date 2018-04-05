package verigames.optimizer.passes;

import verigames.optimizer.OptimizationPass;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.ReverseMapping;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * Abstract class for passes that collect a number of nodes to eliminate and
 * iterate until they reach a fixed point.
 */
public abstract class AbstractIterativePass implements OptimizationPass {

    /**
     * Determine whether a particular node should be marked for removal on
     * this iteration.
     * @param g        the graph
     * @param node     the node to be considered
     * @param alreadyRemoved the set of nodes already marked for removal
     * @param mapping  the mapping to update for edges removed
     * @return      true to mark the given node for removal
     */
    public abstract boolean shouldRemove(NodeGraph g, Node node, Set<Node> alreadyRemoved, ReverseMapping mapping);

    /**
     * Called after all nodes are removed from the graph. The graph may now
     * require some fixing to make it legal again.
     * @param g           the graph to fix
     * @param brokenEdges the edges from the original graph where one node was removed but not the other
     * @param mapping     the reverse mapping to update
     */
    public void fixup(NodeGraph g, Collection<Edge> brokenEdges, ReverseMapping mapping) { }

    @Override
    public void optimize(NodeGraph g, ReverseMapping mapping) {

        Set<Node> toRemove = new HashSet<>();

        boolean shouldContinue;

        do {
            shouldContinue = false;
            Collection<Node> toRemove2 = new ArrayList<>();

            for (Node n : g.getNodes()) {

                // no need to consider nodes we are already removing
                if (toRemove.contains(n)) {
                    continue;
                }

                if (shouldRemove(g, n, toRemove, mapping)) {
                    toRemove2.add(n);

                    // if we are removing a node, we may need to do another pass
                    shouldContinue = true;
                }

            }

            toRemove.addAll(toRemove2);
        } while (shouldContinue);

        Collection<Edge> brokenEdges = new ArrayList<>();
        for (Edge e : g.getEdges()) {
            if (toRemove.contains(e.getSrc()) != toRemove.contains(e.getDst()))
                brokenEdges.add(e);
        }

        g.removeNodes(toRemove);
        fixup(g, brokenEdges, mapping);
    }
}
