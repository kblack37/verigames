package verigames.level;

/**
 * An exception that is used by the {@link Board} class to indicate that a cycle
 * has been found ({@code Board}s are supposed to be DAGs)
 */
public class CycleException extends IllegalStateException
{
  private static final long serialVersionUID = 0L;

  public CycleException()
  {
    super();
  }

  public CycleException(String msg)
  {
    super(msg);
  }

  public CycleException(String msg, Throwable cause)
  {
    super(msg, cause);
  }
}
