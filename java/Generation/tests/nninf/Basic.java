import nninf.quals.*;

public class Basic {
  @Nullable Basic b;

  void m() {
      //:: error: (dereference.of.nullable)
      b.m();

      b = new Basic();
      b.m();

      //:: error: (dereference.of.nullable)
      b.m();

      //:: error: (dereference.of.nullable)
      b.b = null;
  }

  void bar() {
      //:: error: (assignment.type.incompatible)
      @NonNull Basic local = null;

      if (4 != 9) {
          local = new Basic();
          local.m();
      }

      // OK, b is declared NonNull
      local.m();

      if (local!=null) {
          local.m();
      }
  }

}
