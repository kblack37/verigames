package verigames.utilities;

import java.util.*;

/**
 * A lightweight implementation of a {@code MultiMap}. That is, each key can map
 * to multiple values.
 * <p>
 * This implementation is backed by a {@code HashMap} and {@code HashSet}s so
 * that operations can be done in constant time.
 *
 * @param <K>
 * The type of they keys
 * @param <V>
 * The type of the values
 *
 * @author Nathaniel Mote
 */
public class MultiMap<K,V>
{
  private Map<K, Set<V>> delegate;

  /**
   * Creates a new, empty {@code MultiMap}
   */
  public MultiMap()
  {
    delegate = new LinkedHashMap<K, Set<V>>();
  }

  protected Set<V> getOrCreateSet(K key)
  {
    Set<V> result = delegate.get(key);
    if (result == null)
    {
      result = new LinkedHashSet<>();
      delegate.put(key, result);
    }
    return result;
  }

  /**
   * Adds a mapping from {@code key} to {@code value}. Does not remove any
   * previous mappings.
   *
   * @param key
   * @param value
   */
  public void put(K key, V value)
  {
    getOrCreateSet(key).add(value);
  }

  /**
   * Add a mapping from {@code key} to each one of {@code values}. Does not
   * remove any previous mappings.
   *
   * @param key
   * @param values
   */
  public void putAll(K key, Collection<V> values)
  {
    getOrCreateSet(key).addAll(values);
  }

  /**
   * Returns an unmodifiable view on a set containing all values to which
   * {@code key} maps. Returns an empty set if {@code key} maps to no values.
   *
   * @param key
   */
  // TODO make results consistent -- right now, if the key exists, the returned
  // set will change as values are added, but if the key does not exist, the
  // returned map will not change.
  public Set<V> get(K key)
  {
    Set<V> ret = delegate.get(key);
    if (ret != null)
      return Collections.unmodifiableSet(ret);
    else
      return Collections.emptySet();
  }

  /**
   * Get a view of all the keys stored in this map
   * @return all the keys stored in this map
   */
  public Set<K> keySet()
  {
    return delegate.keySet();
  }

  /**
   * Remove all associated mappings for a key
   * @param key the key
   * @return all things the key was mapped to
   */
  public Set<V> remove(K key)
  {
    return delegate.remove(key);
  }

  /**
   * Remove a specific mapping
   * @param key the key
   * @param value the value
   * @return true if the mapping was present (or equivalently, if the
   *         multimap changed as a result of this call)
   */
  public boolean remove(K key, V value)
  {
    Set<V> vals = delegate.get(key);
    if (vals == null)
      return false;
    boolean removed = vals.remove(value);
    if (vals.size() == 0)
      delegate.remove(key);
    return removed;
  }

}
