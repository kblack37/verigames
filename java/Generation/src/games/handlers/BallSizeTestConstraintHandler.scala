package games.handlers

import games.GameSolver
import verigames.level.{Board, Subboard, Chute, Intersection, BallSizeTest}
import checkers.inference._
import checkers.types.AnnotatedTypeMirror
import checkers.types.AnnotatedTypeMirror.{AnnotatedTypeVariable, AnnotatedDeclaredType}
import misc.util.VGJavaConversions._

/**
 * Handler for BallSizeTestConstraints
 *
 * @param constraint
 * @param gameSolver
 */

case class BallSizeTestConstraintHandler( override val constraint : BallSizeTestConstraint,
                                      gameSolver : GameSolver )
  extends ConstraintHandler[BallSizeTestConstraint] {

  //NOTE: If a variable isn't declared in this file then it likely comes from gameSolver
  val BallSizeTestConstraint(input, supertype, subtype, cycle) = constraint

  override def handle( ) {
    import gameSolver._
    val board = gameSolver.variablePosToBoard(subtype.varpos) //Input might be in multiple boards, so lookup with one of the refvars.

    // Wire up input
    // A ball size test inside of a loop can cause a cycle.
    var ballSizeTest : Intersection = null
    if (cycle) {
       // If cycle, create a new stub input and link it to the original input variable
       val start = Intersection.factory(Intersection.Kind.START_PIPE_DEPENDENT_BALL)
       board.addNode(start)
       val inputChute = new Chute(constraint.input.id, constraint.input.toString)
       val result = board.add(start, "output", Intersection.Kind.BALL_SIZE_TEST, "input", inputChute)
       ballSizeTest = result._2

    } else {
      // Split the input and connect to bstest.
      // Input is split because it might still be part of future constraints (like subtype to declared variable).

      // First make a split of the input variable.
      val inputToSplitChute = new Chute(constraint.input.id, constraint.input.toString)
      var currentInputVarIntersection = boardNVariableToIntersection((board, constraint.input))
      var splitIntersection = board.add(currentInputVarIntersection, "output", Intersection.Kind.SPLIT, "input", inputToSplitChute)._2

      // Add a continue to the split and mark as the last intersection for the input variable.
      val splitToContinueChute = new Chute(constraint.input.id, constraint.input.toString)
      val inputConnect = board.add(splitIntersection, "0", Intersection.Kind.CONNECT, "input", splitToContinueChute)._2
      boardNVariableToIntersection += ((board, constraint.input) -> inputConnect)

      // Attach the other end of the split to the BStest
      val splitToBsChute = new Chute(constraint.input.id, constraint.input.toString)
      val result = board.add(splitIntersection, "1", Intersection.Kind.BALL_SIZE_TEST, "input", splitToBsChute)
      ballSizeTest = result.getSecond()
    }

    // Wire up large side
    val largeBranchChute = new Chute()
    largeBranchChute.setEditable(false)
    largeBranchChute.setNarrow(false)
    val largeIntersection = boardNBSVariableToStart((board, constraint.supertype))
    val largeBranchStart = board.add(ballSizeTest, BallSizeTest.LARGE_PORT, largeIntersection, "input", largeBranchChute)._2

    // Wire up small side
    val smallBranchChute = new Chute()
    smallBranchChute.setEditable(false)
    smallBranchChute.setNarrow(true)
    val smallIntersection = boardNBSVariableToStart((board, constraint.subtype))
    val smallBranchStart = board.add(ballSizeTest, BallSizeTest.SMALL_PORT, smallIntersection, "input", smallBranchChute)._2
  }
}
