package games.handlers

import games.GameSolver
import checkers.inference.{CalledMethodPos, InstanceMethodCallConstraint}
import checkers.types.AnnotatedTypeMirror

/**
 * This class handles the creation/placement of a CALL to an instance method subboard and
 * NOT the creation of the instance method subboard itself (this is done incrementally through
 * placement of individuals variables/constraints on a method board).
 *
 * All behavior is implemented by MethodCallConstraintHandler.
 *
 * @param constraint The InstanceMethodCallConstraint that should be translated into a subboard intersection.
 * @param gameSolver The gameSolver singleton.
 */
case class InstanceMethodCallConstraintHandler( override val constraint : InstanceMethodCallConstraint,
                                                override val gameSolver : GameSolver )
  extends SubboardCallConstraintHandler[CalledMethodPos, InstanceMethodCallConstraint](constraint, gameSolver) {

  override val methodSignature =
    constraint.calledVp
      .map( _.getMethodSignature )
      .getOrElse( constraint.stubBoardUse.get.methodSignature )
}
