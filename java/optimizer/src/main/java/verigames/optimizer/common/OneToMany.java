package verigames.optimizer.common;

import verigames.utilities.MultiMap;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class OneToMany<K,V> {

    private final MultiMap<K,V> forward;
    private final Map<V,K> backward;
    private final ManyToOne<V,K> inverse;

    public OneToMany() {
        forward = new MultiMap<>();
        backward = new HashMap<>();
        inverse = new ManyToOne<>(backward, forward, this);
    }

    OneToMany(MultiMap<K, V> forward, Map<V, K> backward, ManyToOne<V,K> inverse) {
        this.forward = forward;
        this.backward = backward;
        this.inverse = inverse;
    }

    public void put(K key, V value) {
        inverse.put(value, key);
    }

    public Set<V> get(K key) {
        return forward.get(key);
    }

    public ManyToOne<V,K> inverse() {
        return inverse;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OneToMany oneToMany = (OneToMany) o;
        if (!forward.equals(oneToMany.forward)) return false;
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
