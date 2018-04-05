package verigames.level;

import static org.junit.Assert.*;

import java.util.*;

import org.junit.Before;
import org.junit.Test;

import verigames.level.*;
import verigames.level.StubBoard.*;

// TODO add tests for other features of level

public class LevelSpecTests
{
  @Test
  public void stubBoardSanityCheck()
  {
    Level l = new Level();

    List<StubConnection> inputs = new ArrayList<>();
    inputs.add(new StubConnection("input1", true));
    List<StubConnection> outputs = new ArrayList<>();
    outputs.add(new StubConnection("output1", false));

    StubBoard b = new StubBoard(inputs, outputs);

    l.addStubBoard("stub", b);

    assertEquals(b, l.getStubBoard("stub"));
    assertTrue(l.contains("stub"));
    assertEquals(inputs, b.getInputs());
    assertEquals(outputs, b.getOutputs());
  }
}
