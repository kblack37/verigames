package nninf.handlers

import checkers.inference.EqualityConstraint
import checkers.inference.{LiteralSuper, LiteralThis, LiteralNull, Slot}
import games.handlers.EqualityConstraintHandler
import nninf.NninfConstants
import games.GameSolver

case class NninfEqualityConstraintHandler( override val constraint : EqualityConstraint,
                                          gameSolver : GameSolver )
  extends EqualityConstraintHandler( constraint, gameSolver ) {

  override val narrowSlotTypes : List[Slot] = List( NninfConstants.NONNULL,  LiteralThis, LiteralSuper )
  override val wideSlotTypes   : List[Slot] = List( LiteralNull, NninfConstants.NULLABLE )

}
