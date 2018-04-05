/**
 * Contains classes that add layout information to a board using Graphviz.
 * <p>
 * The layout tools all require that Graphviz be installed on the system. In
 * particular, the "dot" tool (one of Graphviz's layout tools) must be invokable
 * from the command line.
 * <p>
 * On a modern machine, the layout tool should be able to lay out a moderately
 * sized world (~50 boards) in no more than a second. This time should increase
 * linearly with the number of boards, because laying out each board is a
 * discrete task.
 * <p>
 * If the layout tool hangs, it most likely means that dot is not exiting
 * properly.
 * <hr/>
 * <h2>Implementation notes:</h2>
 * <p>
 * <h3>Units:</h3>
 * <p>
 * There are three different units used to represent coordinates and distances
 * in this package. The first unit is the "game unit." This is the unit used in
 * the game, and the origin is at the top-left of the board, with y coordinates
 * growing downward.
 * <p>
 * The second is the inch. Graphviz uses inches for some measurements, and for
 * convenience, this package equates a game unit with an inch. However, a
 * measurement expressed in inches typically has the origin at the bottom-left
 * of the board, with y coordinates growing upward, reflecting the style of
 * Graphviz.
 * <p>
 * The third is the typographical point, which is equal to 1/72nd of an inch.
 * For some reason, Graphviz uses points in some places and inches in others.
 * For example, dimensions are expressed in inches, while positions are
 * expressed in points. Typically, positions in points also have the origin at
 * the bottom-left, with y coordinates growing upward.
 * <p>
 * <h3>Layout algorithm:</h3>
 * <p>
 * Layout is performed in a single pass using the dot tool, which lays out
 * directed graphs hierarchically. Subboard and Get nodes, which have non-zero
 * dimensions, are represented to Graphviz as "record" nodes, and are given
 * ports. Other nodes, which are not visually represented in the game (they are
 * just points where edges connect), are represented as circles. This makes dot
 * route the edges away from the nodes to reduce confusion.
 * <p>
 * <h3>Making changes:</h3>
 * <p>
 * If it is necessary to tweak the way the layout algorithm performs, there are
 * two ways to do so.
 * <p>
 * <ol>
 * <li>
 * The first is through the input that Graphviz is given. This is controlled by
 * {@link verigames.layout.AbstractDotPrinter}, and its subclass {@link
 * verigames.layout.DotPrinter}. What it prints can drastically change the
 * layout, as this determines the behavior of Graphviz itself.
 * <p>
 * The attributes that can be included are described <a
 * href="http://www.graphviz.org/content/attrs">here</a>.
 * </li>
 * <p>
 * <li>
 * The second is to change what is done with Graphviz's output. This is done in
 * {@link verigames.layout.BoardLayout}.
 * <p>
 * If more information is needed from the Graphviz output, three things must be
 * done. First, {@link verigames.layout.GraphInformation} must be updated to
 * store the required data. Second, {@link verigames.layout.DotParser} must be
 * updated to parse the required information and store it to {@code
 * GraphInformation}. Then, {@link verigames.layout.BoardLayout} must be updated
 * to use the new information.
 * </li>
 * </ol>
 */

package verigames.layout;
