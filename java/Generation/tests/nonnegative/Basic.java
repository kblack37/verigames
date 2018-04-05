import nonnegative.quals.*;

public class Basic {
    void test() {
        @NonNegative int n = 5;
        //:: error: (assignment.type.incompatible)
        n = -5;

        n = 0 + 4;
        n = 6 + 9;

        //:: error: (assignment.type.incompatible)
        n = 8 - 2;

        n += 8;

        //:: error: (assignment.type.incompatible)
        n += (-1);
    }

    void test2() {
        int n = -4;

        boolean[] arr = new boolean[10];

        //:: error: (unknown.array.index)
        boolean b = arr[n];
    }

    void test3() {
        boolean[] arr = new boolean[10];
        for (int i = 0; i < arr.length; i++) {
            System.out.println(arr[i]);
        }
    }

    void test4() {
        boolean[] arr = new boolean[10];
        for (int i = 0; i < arr.length; i--) {
            //:: error: (unknown.array.index)
            System.out.println(arr[i]);
        }
    }
}
