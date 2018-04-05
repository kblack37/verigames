package verigames.level;

import org.junit.BeforeClass;
import org.junit.Test;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

/**
 * Contains a bunch of tests specific to the {@link World} described by {@code
 * hadoop-distcp.xml} in this directory.
 */
public class WorldXMLParserSpecTests
{
  public static World hadoopWorld;
  public static Map<String, Level> levels;

  @BeforeClass
  public static void parseHadoop() throws FileNotFoundException, IOException
  {
    System.out.println(new File(".").getCanonicalPath());
    System.out.println(System.getProperty("user.dir"));
    InputStream in = new FileInputStream("hadoop-distcp.xml");
    WorldXMLParser parser = new WorldXMLParser();

    hadoopWorld = parser.parse(in);
    levels = hadoopWorld.getLevels();
  }

  @Test
  public void testUnderConstruction()
  {
    assertFalse(hadoopWorld.underConstruction());
  }

  @Test
  public void testVarIDLinking1()
  {
    assertTrue(hadoopWorld.areVarIDsLinked(171, 120));
  }

  @Test
  public void testVarIDLinking2()
  {
    assertFalse(hadoopWorld.areVarIDsLinked(171, 440));
  }

  @Test
  public void testLevelParsing()
  {
    Level l = levels.get("org.apache.hadoop.tools.OptionsParser$CustomParser");
    assertNotNull(l);
    // test that it contains a stub board
    assertTrue(l.contains("org.apache.commons.cli.GnuParser--init----void"));
    // test that it contains a board
    assertTrue(l.contains("org.apache.hadoop.tools.OptionsParser-CustomParser"));
  }

  private World load(String file, boolean preserveIDs) throws FileNotFoundException
  {
    return new WorldXMLParser(preserveIDs).parse(new FileInputStream(file));
  }

  private Set<Integer> getChuteIDs(World world)
  {
    Set<Integer> chuteIDs = new HashSet<>();
    for (Chute c : world.getChutes())
    {
      chuteIDs.add(c.getUID());
    }
    return chuteIDs;
  }

  private Set<Integer> getIntersectionIDs(World world)
  {
    Set<Integer> iIDs = new HashSet<>();
    for (Level level : world.getLevels().values())
    {
      for (Board board : level.getBoards().values())
      {
        for (Intersection i : board.getNodes())
        {
          iIDs.add(i.getUID());
        }
      }
    }
    return iIDs;
  }

  @Test
  public void preserveChuteIDs() throws FileNotFoundException
  {
    World w1 = load("hadoop-distcp.xml", true);
    World w2 = load("hadoop-distcp.xml", true);
    assert getChuteIDs(w1).equals(getChuteIDs(w2));
    assert getIntersectionIDs(w1).equals(getIntersectionIDs(w2));
  }

}
