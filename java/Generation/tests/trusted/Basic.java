import trusted.quals.*;

public class Basic {

  void bar(@Untrusted String s) {
      @Untrusted String b = s;
      @Trusted String c = "trusted";

      //:: error: (assignment.type.incompatible)
      c = s;

      //:: error: (argument.type.incompatible)      
      foo(s);

      //:: error: (argument.type.incompatible)
      foo(b);

      concat(s);

      b = c;

      // flow refines b -> ok
      foo(b);      
      
      TestInterface interf = new TestClass();

      //:: error: (argument.type.incompatible)      
      interf.myMethod(s);
      
      interf.myMethod(b);
  }

  void concat(String s) {
      String a = "trusted";
      String b = "trusted";

      @Trusted String safe = a + b;

      //:: error: (assignment.type.incompatible)
      @Trusted String unsafe = a + s;
  }

  String foo(@Trusted String s2) {
      return s2;
  }
  

  interface TestInterface {
	  public void myMethod(@Trusted String s);
  }

  class TestClass implements TestInterface {
	  public void myMethod(String s) {
		  return;
	  }
  }
}
