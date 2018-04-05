package verigames.optimizer.model;

import verigames.level.Board;
import verigames.level.StubBoard;

/**
 * The board held by a {@link verigames.level.Intersection.Kind#SUBBOARD SUBBOARD}
 * {@link verigames.level.Intersection Intersection}. It may be either a
 * full-fledged {@link Board} (which stores only a name) or a {@link StubBoard}
 * (which stores both a name and some implementation details).
 */
public class BoardRef {

    private final String name;
    private final StubBoard stubBoard;

    public BoardRef(String name) {
        this.name = name;
        this.stubBoard = null;
    }

    public BoardRef(String name, StubBoard stubBoard) {
        this.name = name;
        this.stubBoard = stubBoard;
    }

    public boolean isStub() {
        return stubBoard != null;
    }

    public StubBoard asStubBoard() {
        return stubBoard;
    }

    public String getName() {
        return name;
    }

}
