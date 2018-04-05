package verigames.level;

/**
 * A class used to run the suite of specification tests for the level objects
 * 
 * @author Nathaniel Mote
 * 
 */

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
  BallSizeTestSpecTests.class,
  BoardSpecTests.class,
  ChuteSpecTests.class,
  IntersectionSpecTests.class,
  LevelSpecTests.class,
  LevelXMLTests.class,
  WorldSpecTests.class,
  WorldXMLParserSpecTests.class,
})
public class SpecificationTests {
  // Placeholder class
}
