class CallThis {
  void m1(Object o) {}

  void m3(CallThis p) {
    m1(this);
  }
}
