package verigames.level;

import java.util.*;

/**
 * A record type containing information about stub boards. These represent
 * methods for which we do not have the source code (such as library calls where
 * all we have is the compiled library).
 */
public class StubBoard
{
  public static class StubConnection
  {
    private final String portName;
    private final boolean narrow;
    public StubConnection(String portName, boolean narrow)
    {
      this.portName = portName;
      this.narrow = narrow;
    }
    public String getPortName()
    {
      return this.portName;
    }
    public boolean isNarrow()
    {
      return this.narrow;
    }
  }

  private final List<StubConnection> inputs;
  private final List<StubConnection> outputs;

  public StubBoard(List<StubConnection> inputs, List<StubConnection> outputs)
  {
    this.inputs = new ArrayList<>(inputs);
    this.outputs = new ArrayList<>(outputs);
  }

  public List<StubConnection> getInputs()
  {
    return Collections.unmodifiableList(this.inputs);
  }

  public List<StubConnection> getOutputs()
  {
    return Collections.unmodifiableList(this.outputs);
  }

  public List<String> getInputIDs() {
    final List<String> ports = new ArrayList<String>();
    for(final StubConnection input : inputs ) {
      ports.add( input.getPortName() );
    }
    return ports;
  }

  public List<String> getOutputIDs() {
    final List<String> ports = new ArrayList<String>();
    for(final StubConnection input : outputs ) {
      ports.add( input.getPortName() );
    }
    return ports;
  }
}
