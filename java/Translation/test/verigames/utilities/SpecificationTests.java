package verigames.utilities;

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
@SuiteClasses({ MultiMapSpecTests.class, MultiBiMapSpecTests.class })
public class SpecificationTests {
  // Placeholder class
}
