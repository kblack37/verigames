package verigames.optimizer.common;

import verigames.optimizer.Util;
import verigames.utilities.MultiMap;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Represents a clustering of objects. These are the primary supported operations:
 * <ul>
 *     <li>{@link #union(java.util.Collection)}</li>
 *     <li>{@link #isolate(Object)}</li>
 *     <li>{@link #getCluster(Object)}</li>
 *     <li>{@link #getNontrivialClusters()}</li>
 * </ul>
 * @param <T> the type of objects contained
 */
public class Clustering<T> {

    private int lastID;
    private final Map<T, Integer> map;
    private final MultiMap<Integer, T> reverse;

    public Clustering() {
        lastID = 0;
        map = new HashMap<>();
        reverse = new MultiMap<>();
    }

    private Integer getClusterID(T x) {
        return map.get(x);
    }

    private int getOrCreateClusterID(T x) {
        Integer i = getClusterID(x);
        if (i == null) {
            i = ++lastID;
            map.put(x, i);
            reverse.put(i, x);
        }
        return i;
    }

    /**
     * Indicate that the given element belongs in its own collection. Roughly
     * the inverse of {@link #union(java.util.Collection)}.
     *
     * <p>Performance: O(1)</p>
     * @param x the element to isolate
     */
    public void isolate(T x) {
        Integer id = map.remove(x);
        if (id != null) {
            reverse.remove(id, x);
            if (reverse.get(id).size() <= 1) {
                reverse.remove(id);
            }
        }
    }

    /**
     * Convenience method to union two elements.
     * @see #union(java.util.Collection)
     * @param a the first element
     * @param b the second element
     */
    public void union(T a, T b) {
        union(Arrays.asList(a, b));
    }

    /**
     * Indicate that all the elements belong in the same set.
     *
     * <p>Performance: O(n*m) where n is the size of {@code all} and m is the
     * size of the largest cluster in this clustering.</p>
     * @param all the elements to union
     */
    public void union(Collection<T> all) {
        if (all.isEmpty())
            return;
        int clusterID = getOrCreateClusterID(Util.first(all));
        for (T b : all) {
            Integer idb = getClusterID(b);
            if (idb != null) {
                if (idb != clusterID) {
                    Set<T> others = reverse.remove(idb);
                    for (T bb : others) {
                        map.put(bb, clusterID);
                    }
                    reverse.putAll(clusterID, others);
                }
            } else {
                map.put(b, clusterID);
                reverse.put(clusterID, b);
            }
        }
    }

    /**
     * Get the cluster that {@code x} belongs to.
     *
     * <p>Performance: O(1)</p>
     * @param x the element
     * @return the cluster that {@code x} belongs to
     */
    public Set<T> getCluster(T x) {
        Integer id = getClusterID(x);
        return id == null ? Collections.singleton(x) : reverse.get(id);
    }

    /**
     * Get all the clusters with size > 1.
     *
     * <p>Performance: O(n) where n is the number of clusters</p>
     * @return all the clusters with size > 1
     */
    public Collection<Set<T>> getNontrivialClusters() {
        Collection<Set<T>> result = new ArrayList<>();
        for (Integer i : reverse.keySet()) {
            result.add(reverse.get(i));
        }
        return result;
    }

    @Override
    public String toString() {
        return getNontrivialClusters().toString();
    }

}
