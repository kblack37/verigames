package verigames.optimizer.model;

import verigames.level.Chute;

/**
 * Represents all the data that can be associated with an {@link Edge}. This
 * class is abstract; to get instances of it you will want to call one of
 * these:
 * <ul>
 *     <li>{@link #createImmutable(boolean)}</li>
 *     <li>{@link #createMutable(int, String)}</li>
 * </ul>
 */
public abstract class EdgeData {

    /**
     * A narrow, immutable chute
     */
    public static final EdgeData NARROW = new EdgeData() {
        @Override public int getVariableID() { return -1; }
        @Override public String getDescription() { return "pinched"; }
        @Override public boolean isNarrow() { return true; }
        @Override public boolean isEditable() { return false; }
    };

    /**
     * A wide, immutable chute
     */
    public static final EdgeData WIDE = new EdgeData() {
        @Override public int getVariableID() { return -1; }
        @Override public String getDescription() { return "wide"; }
        @Override public boolean isNarrow() { return false; }
        @Override public boolean isEditable() { return false; }
    };

    /**
     * Get an appropriate EdgeData for the given chute.
     * @param c        the chute
     * @return a matching EdgeData object
     */
    public static EdgeData fromChute(Chute c) {
        if (c.isPinched())
            return createImmutable(true);
        if (!c.isEditable())
            return createImmutable(c.isNarrow());
        return createMutable(c.getVariableID(), c.getDescription());
    }

    /**
     * Get EdgeData for an immutable edge.
     * @param narrow  whether the chute is narrow
     * @return a matching EdgeData object
     */
    public static EdgeData createImmutable(boolean narrow) {
        return narrow ? NARROW : WIDE;
    }

    /**
     * Get EdgeData for a mutable edge.
     * @param varID        the variable ID
     * @param description  the description
     * @return a matching EdgeData object
     */
    public static EdgeData createMutable(final int varID, final String description) {
        return new EdgeData() {
            @Override public int getVariableID() { return varID; }
            @Override public String getDescription() { return description; }
            @Override public boolean isNarrow() { return false; }
            @Override public boolean isEditable() { return true; }
        };
    }

    public abstract int getVariableID();
    public abstract String getDescription();
    public abstract boolean isNarrow();
    public abstract boolean isEditable();

    public Chute toChute() {
        Chute c = new Chute(getVariableID(), getDescription());
        c.setEditable(isEditable());
        c.setPinched(false);
        c.setBuzzsaw(false);
        c.setNarrow(isNarrow());
        return c;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || !(o instanceof EdgeData)) return false;
        EdgeData edgeData = (EdgeData) o;
        return edgeData.getVariableID() == getVariableID() &&
                edgeData.getDescription().equals(getDescription()) &&
                edgeData.isNarrow() == isNarrow() &&
                edgeData.isEditable() == isEditable();
    }

    @Override
    public int hashCode() {
        int result = getVariableID();
        result = 31 * result + getDescription().hashCode();
        result = 31 * result + (isNarrow() ? 1 : 0);
        result = 31 * result + (isEditable() ? 1 : 0);
        return result;
    }

    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        s.append(getVariableID());
        if (getDescription() == null) {
            s.append(" (no description)");
        } else {
            s.append(" (");
            s.append(getDescription());
            s.append(")");
        }
        s.append(isNarrow() ? ", narrow" : ", wide");
        if (isEditable())
            s.append(", editable");
        return s.toString();
    }

}
