package verigames.utilities;

import java.util.Set;

/**
 * A lightweight implementation of a MultiBiMap. That is, each key can map to
 * multiple values, and an inverse view of the map can be provided.
 *
 * @author Nathaniel Mote
 */

// Could be fleshed out to implement the Map interface, although remove would be
// poorly defined, and would most likely have to be unsupported. However, it's
// unclear if this is worth it.
public class MultiBiMap<K,V>
{
  private MultiMap<K, V> forward;
  private MultiMap<V, K> backward;
  
  private MultiBiMap<V, K> inverse;
  
  /**
   * Creates a new, empty, MultiBiMap
   */
  public MultiBiMap()
  {
    forward = new MultiMap<K, V>();
    backward = new MultiMap<V, K>();
    inverse = new MultiBiMap<V, K>(backward, forward, this);
  }
  
  /**
   * Creates a new MultiBiMap with the given fields. Used exclusively for
   * constructing the inverse view of a MultiBiMap created with the
   * {@linkplain #MultiBiMap() public constructor}
   * 
   * @param forward
   * @param backward
   * @param inverse
   */
  private MultiBiMap(MultiMap<K, V> forward, MultiMap<V, K> backward, MultiBiMap<V, K> inverse)
  {
    this.forward = forward;
    this.backward = backward;
    this.inverse = inverse;
  }
  
  /**
   * Returns a set of all the values to which {@code key} maps
   * 
   * @param key
   */
  public Set<V> get(K key)
  {
    return forward.get(key);
  }
  
  /**
   * Adds a mapping from {@code key} to {@code value}. Does not remove any
   * previous mappings
   * 
   * @param key
   * @param value
   */
  public void put(K key, V value)
  {
    forward.put(key, value);
    backward.put(value, key);
  }
  
  /**
   * Returns an inverse view of {@code this}. The returned map is backed by
   * {@code this}, so changes in one are reflected in the other.
   */
  public MultiBiMap<V, K> inverse()
  {
    return inverse;
  }
}
