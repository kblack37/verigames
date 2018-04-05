package games.handlers

import checkers.inference.{CalledMethodPos, VariablePosition, StaticMethodCallConstraint}
import games.GameSolver


/**
 * This class handles the creation/placement of a CALL to a static method subboard and
 * NOT the creation of the static method subboard itself (this is done incrementally through
 * placement of individuals variables/constraints on a method board).
 *
 * All behavior is implemented by MethodCallConstraintHandler.
 *
 * @param constraint The StaticMethodCallConstraint that should be translated into a subboard intersection.
 * @param gameSolver The gameSolver singleton.
 */
case class StaticMethodCallConstraintHandler( override val constraint : StaticMethodCallConstraint,
                                              override val gameSolver : GameSolver )
  extends SubboardCallConstraintHandler[CalledMethodPos, StaticMethodCallConstraint](constraint, gameSolver) {

  override val methodSignature =
    constraint.calledVp
      .map( _.getMethodSignature )
      .getOrElse( constraint.stubBoardUse.get.methodSignature )

}
