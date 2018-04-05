package verigames.optimizer;

import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.ReverseMapping;
import verigames.optimizer.passes.BallDropElimination;
import verigames.optimizer.passes.ChuteEndElimination;
import verigames.optimizer.passes.ConnectorCompression;
import verigames.optimizer.passes.ImmutableComponentElimination;
import verigames.optimizer.passes.MergeElimination;
import verigames.optimizer.passes.SplitElimination;

import java.util.Arrays;
import java.util.List;

public class Optimizer {

    /**
     * The default optimization passes.
     * Their ordering is pretty arbitrary, but not entirely:
     * ConnectorCompression, MergeElimination, and SplitElimination all
     * offer great power for very little CPU time. On large boards it can
     * matter that these come first (especially that first one).
     */
    public static final List<OptimizationPass> DEFAULT_PASSES = Arrays.asList(
            new ConnectorCompression(),
            new MergeElimination(),
            new SplitElimination(),
            new BallDropElimination(),
            new ChuteEndElimination(),
            new ImmutableComponentElimination());

    /**
     * The maximum number of iterations. Defaults to 20, which has been
     * empirically determined to work pretty well. It is rare for a world
     * to require more than 5.
     */
    public static final int DEFAULT_MAX_ITERATIONS = 20;

    public void optimize(NodeGraph g) {
        optimize(g, new ReverseMapping(), DEFAULT_PASSES);
    }

    public void optimize(NodeGraph g, ReverseMapping map) {
        optimize(g, map, DEFAULT_PASSES);
    }

    public void optimize(NodeGraph g, ReverseMapping map, List<OptimizationPass> passes) {
        optimize(g, map, passes, DEFAULT_MAX_ITERATIONS);
    }

    public void optimize(NodeGraph g, ReverseMapping map, List<OptimizationPass> passes, int maxIterations) {
        int nodes = g.getNodes().size();
        int edges = g.getEdges().size();
        for (int i = 0; i < maxIterations; ++i) {
            Util.logVerbose("  iteration: " + (i + 1) + " / " + maxIterations + "...");
            for (OptimizationPass pass : passes) {
                Util.logVerbose("    pass: " + pass.getClass().getName() + "...");
                long start = System.currentTimeMillis();
                pass.optimize(g, map);
                long end = System.currentTimeMillis();
                Util.logVerbose("      finished in: " + (end - start) + "ms");
                Util.logVerbose("      remaining: " + g.getNodes().size() + " nodes, " + g.getEdges().size() + " edges");
            }
            // stop early when we stop making progress
            if (g.getNodes().size() >= nodes && g.getEdges().size() >= edges)
                break;
            nodes = g.getNodes().size();
            edges = g.getEdges().size();
        }
    }

}
