package verigames.optimizer.io;

import verigames.optimizer.model.ReverseMapping;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.util.Date;
import java.util.Map;
import java.util.Scanner;

public class ReverseMappingIO {

    /**
     * Character set used for reading/writing
     */
    public static final Charset CHARSET = Charset.forName("ascii");

    public static final String TRUE_STRING = "T";
    public static final String FALSE_STRING = "F";

    public ReverseMapping load(InputStream in) throws IOException {
        Scanner scanner = new Scanner(new InputStreamReader(in, CHARSET));
        scanner.nextLine(); // drop the comment line at the top
        ReverseMapping map = new ReverseMapping();
        loadMap(scanner, map, true);
        loadMap(scanner, map, false);
        return map;
    }

    private void loadMap(Scanner scanner, ReverseMapping map, boolean widths) {
        int count = scanner.nextInt();
        for (int i = 0; i < count; ++i) {
            int src = scanner.nextInt();
            ReverseMapping.Mapping m = scanner.hasNextInt() ?
                    new ReverseMapping.EdgeMapping(scanner.nextInt()) :
                    new ReverseMapping.ForcedMapping(scanner.next().equals(TRUE_STRING));
            if (widths)
                map.putWidthMapping(src, m);
            else
                map.putBuzzsawMapping(src, m);
        }
    }

    public void export(OutputStream output, ReverseMapping mapping) throws IOException {
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(output, CHARSET));
        writer.write("# this is an automatically generated verigames optimizer mapping file, created on " + new Date() + "\n");
        export(writer, mapping.getWidthMappings());
        export(writer, mapping.getBuzzsawMappings());
        writer.flush();
    }

    private void export(Writer writer, Map<Integer, ReverseMapping.Mapping> mappings) throws IOException {
        int count = 0;
        for (ReverseMapping.Mapping m : mappings.values()) {
            if (m instanceof ReverseMapping.ForcedMapping || m instanceof ReverseMapping.EdgeMapping)
                count++;
        }
        writer.write(Integer.toString(count));
        writer.write('\n');
        for (Map.Entry<Integer, ReverseMapping.Mapping> e : mappings.entrySet()) {
            ReverseMapping.Mapping m = e.getValue();
            if (m instanceof ReverseMapping.ForcedMapping) {
                writer.write(Integer.toString(e.getKey()));
                writer.write(' ');
                writer.write(((ReverseMapping.ForcedMapping)m).getValue() ? TRUE_STRING : FALSE_STRING);
                writer.write('\n');
            } else if (m instanceof ReverseMapping.EdgeMapping) {
                writer.write(Integer.toString(e.getKey()));
                writer.write(' ');
                writer.write(Integer.toString(((ReverseMapping.EdgeMapping)m).getEdgeID()));
                writer.write('\n');
            }
        }
    }

}
