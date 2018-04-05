package verigames.optimizer.model;

public class Port {

    public static final Port OUTPUT = new Port("output");
    public static final Port INPUT = new Port("input");

    private final String name;

    public Port(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Port port = (Port) o;
        return name.equals(port.name);
    }

    @Override
    public int hashCode() {
        return name.hashCode();
    }

    @Override
    public String toString() {
        return name;
    }

}
