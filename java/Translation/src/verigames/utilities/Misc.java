package verigames.utilities;

/**
 * A class containing miscellaneous utilities used in implementation of the
 * packages. Not for use by clients.
 */
public class Misc
{
  /**
   * Intended to be a substitute for assert, except I don't want to have to
   * make sure the -ea flag is turned on in order to get these checks.
   */
  public static void ensure(boolean value, String msg)
  {
    if (!value)
      throw new AssertionError( msg );
  }

  /**
   * Search the Java properties then environment variables for the given propertyName.
   * If it exists
   *   return true if it equals true, other wise return false
   * else
   *   return defaultValue
   * @param propertyName The property to read
   * @param defaultValue The default value if it's not found
   * @return whether the given boolean property is true
   */
  public static boolean booleanPropOrEnv( String propertyName, boolean defaultValue ) {
    String value = System.getProperty( propertyName );
    if( value == null ) {
        value = System.getenv( propertyName );
    }

    if( value == null ) {
        return defaultValue;
    }

    return value.equals("true");
  }

  /**
   * Controls whether checkRep is run in various classes in various packages.
   * However, some classes may ignore this value in favor of their own, for
   * greater granularity.
   */
  public static final boolean CHECK_REP_STRICT    = booleanPropOrEnv("STRICT",    true);
  public static final boolean CHECK_REP_ENABLED   = booleanPropOrEnv("STRICT",    true);
  public static final boolean CHECK_REP_FAIL_FAST = booleanPropOrEnv("FAIL_FAST", false);
}
