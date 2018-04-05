package verigames.optimizer.common;

import edu.emory.mathcs.backport.java.util.Collections;
import org.testng.annotations.Test;
import verigames.optimizer.Util;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@Test
public class ClusteringTest {

    @Test
    public void testBasics() {
        System.out.println("testBasics");
        Clustering<Integer> c = new Clustering<>();
        c.union(1, 2);
        System.out.println(c);
        Set<Integer> cluster = new HashSet<>(Arrays.asList(1, 2));
        assert c.getNontrivialClusters().size() == 1;
        assert Util.first(c.getNontrivialClusters()).equals(cluster);
        assert c.getCluster(1).equals(cluster);
        assert c.getCluster(2).equals(cluster);
        assert c.getCluster(3).equals(Collections.singleton(3));
    }

    @Test
    public void testChaining() {
        System.out.println("testChaining");
        Clustering<Integer> c = new Clustering<>();
        c.union(1, 10);
        c.union(2, 20);
        c.union(10, 99);
        c.union(20, 99);
        System.out.println(c);
        assert c.getCluster(1).equals(c.getCluster(2));
    }

    @Test
    public void testIsolate() {
        System.out.println("testIsolate");
        Clustering<Integer> c = new Clustering<>();
        c.union(1, 2);
        c.union(2, 3);
        c.isolate(2);
        System.out.println(c);
        Set<Integer> cluster = new HashSet<>(Arrays.asList(1, 3));
        assert c.getNontrivialClusters().size() == 1;
        assert Util.first(c.getNontrivialClusters()).equals(cluster);
        assert c.getCluster(1).equals(cluster);
        assert c.getCluster(3).equals(cluster);
        assert c.getCluster(2).equals(Collections.singleton(2));
    }

    @Test
    public void testMultiple() {
        System.out.println("testMultiple");
        Clustering<Integer> c = new Clustering<>();
        c.union(1, 10);
        c.union(2, 20);
        System.out.println(c);
        assert c.getCluster(1).contains(10);
        assert c.getCluster(2).contains(20);
        assert !c.getCluster(1).contains(2);
        assert !c.getCluster(10).contains(20);
    }

}
