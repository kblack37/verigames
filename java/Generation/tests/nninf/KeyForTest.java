import java.util.*;
import nninf.quals.*;

class KeyForTest {
    void get() {
        Map<Object, Object> map = new @NonNull HashMap<Object, Object>();
        @KeyFor("map") Object key = new @KeyFor("map") Object();
        map.toString();
        Object notKey = new Object();

        Object c = map.get(notKey);

        //:: error: (dereference.of.nullable)
        c.hashCode();

        Object d = map.get(key);
        d.hashCode();
    }
}