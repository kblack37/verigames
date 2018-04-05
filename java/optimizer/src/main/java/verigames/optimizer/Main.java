package verigames.optimizer;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import verigames.level.StubBoard;
import verigames.optimizer.io.ReverseMappingIO;
import verigames.optimizer.io.WorldIO;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.ReverseMapping;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Map;

public class Main {

    public static void main(String[] args) {

        Options options = new Options();
        options.addOption("h", "help", false, "print help and exit");
        options.addOption("i", "in", true, "input XML file (defaults to stdin)");
        options.addOption("o", "out", true, "output XML file (defaults to stdout)");
        options.addOption("m", "mapping", true, "output mapping file (defaults to stdout)");
        options.addOption("v", "verbose", false, "enable excessive logging to stderr");

        CommandLineParser commandLineParser = new BasicParser();
        CommandLine cmd;
        try {
            cmd = commandLineParser.parse(options, args);
        } catch (ParseException e) {
            System.err.println("Failed to parse command-line options: " + e);
            System.exit(1);
            return; // because Java's flow analysis can't tell that System.exit stops flow
        }

        String inputFile = "-";
        String outputFile = "-";
        String mappingFile = "-";

        if (cmd.hasOption("help")) {
            new HelpFormatter().printHelp(80, "optimizer", "Rewrite Verigames XML files", options, "", true);
            return;
        }

        if (cmd.hasOption("in")) {
            inputFile = cmd.getOptionValue("in");
        }

        if (cmd.hasOption("out")) {
            outputFile = cmd.getOptionValue("out");
        }

        if (cmd.hasOption("mapping")) {
            mappingFile = cmd.getOptionValue("mapping");
        }

        // Enable verbose logging if the user wanted it
        Util.setVerbose(cmd.hasOption("verbose"));

        System.err.println("Reading world...");
        WorldIO io = new WorldIO();
        NodeGraph g;
        Map<Integer, Edge> edgeIDMapping;
        Map<String, StubBoard> stubs;
        try {
            WorldIO.LoadedWorld data = io.load(Util.getInputStream(inputFile), false);
            g = data.getGraph();
            edgeIDMapping = data.getEdgeIDMapping();
            stubs = data.getStubs();
        } catch (FileNotFoundException e) {
            System.err.println("Failed to open input XML file '" + inputFile + "' for reading");
            System.exit(1);
            return;
        }

        System.err.println("Preprocessing...");
        int nodes = g.getNodes().size();
        int edges = g.getEdges().size();
        new Preprocessor().preprocess(g, stubs);
        int nodeDelta = g.getNodes().size() - nodes;
        int edgeDelta = g.getEdges().size() - edges;
        System.err.println("Finished preprocessing: " +
                (nodeDelta >= 0 ? "+" : "") + nodeDelta + " nodes, " +
                (edgeDelta >= 0 ? "+" : "") + edgeDelta + " edges");

        System.err.println("Starting optimization: " + g.getNodes().size() + " nodes, " + g.getEdges().size() + " edges");
        Optimizer optimizer = new Optimizer();
        ReverseMapping mapping = new ReverseMapping();
        mapping.initAll(edgeIDMapping);
        optimizer.optimize(g, mapping);
        System.err.println("Finished optimization: " + g.getNodes().size() + " nodes, " + g.getEdges().size() + " edges");

        System.err.println("Writing world...");
        try {
            Map<Edge, Integer> output = io.export(Util.getOutputStream(outputFile), g);
            mapping.finalizeAll(output);
        } catch (FileNotFoundException e) {
            System.err.println("Failed to open output XML file '" + outputFile + "' for writing");
            System.exit(1);
            return;
        }

        System.err.println("Writing reverse mapping...");
        try {
            new ReverseMappingIO().export(Util.getOutputStream(mappingFile), mapping);
        } catch (FileNotFoundException e) {
            System.err.println("Failed to open mapping output file '" + mappingFile + "' for writing");
            System.exit(1);
            return;
        } catch (IOException e) {
            System.err.println("Failed to write mapping file '" + mappingFile + "': " + e);
            System.exit(1);
            return;
        }

        System.err.println("Done");

    }

}
