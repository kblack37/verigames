package trusted.handlers

import trusted.{TrustedConstants}
import checkers.inference.{Slot, EqualityConstraint}
import games.GameSolver
import games.handlers.EqualityConstraintHandler

case class TrustedEqualityConstraintHandler(  override val constraint : EqualityConstraint,
                                        gameSolver : GameSolver )
  extends EqualityConstraintHandler( constraint, gameSolver ) {

  override val narrowSlotTypes : List[Slot] = List( TrustedConstants.TRUSTED   )
  override val wideSlotTypes   : List[Slot] = List( TrustedConstants.UNTRUSTED )

}
