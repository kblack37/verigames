package verigames.optimizer.common;

import verigames.utilities.MultiMap;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class ManyToOne<K,V> {

    private final Map<K,V> forward;
    private final MultiMap<V,K> backward;
    private final OneToMany<V,K> inverse;

    public ManyToOne() {
        forward = new HashMap<>();
        backward = new MultiMap<>();
        inverse = new OneToMany<>(backward, forward, this);
    }

    ManyToOne(Map<K, V> forward, MultiMap<V, K> backward, OneToMany<V, K> inverse) {
        this.forward = forward;
        this.backward = backward;
        this.inverse = inverse;
    }

    public void put(K key, V value) {
        V oldvalue = forward.put(key, value);
        if (oldvalue != null)
            backward.remove(oldvalue, key);
        backward.put(value, key);
    }

    public V get(K key) {
        return forward.get(key);
    }

    public OneToMany<V,K> inverse() {
        return inverse;
    }

    public Map<K,V> asMap() {
        return Collections.unmodifiableMap(forward);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ManyToOne manyToOne = (ManyToOne) o;
        if (!backward.equals(manyToOne.backward)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        return forward.hashCode();
    }

    @Override
    public String toString() {
        return forward.toString();
    }

}
