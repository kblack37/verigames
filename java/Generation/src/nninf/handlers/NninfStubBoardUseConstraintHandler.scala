package nninf.handlers

import checkers.inference._
import games.GameSolver
import nninf.NninfConstants
import checkers.inference.StubBoardUseConstraint
import games.handlers.StubBoardUseConstraintHandler

case class NninfStubBoardUseConstraintHandler( stubUse : StubBoardUseConstraint, override val gameSolver : GameSolver)
           extends StubBoardUseConstraintHandler( stubUse, gameSolver ) {

  //TODO: NEED TO ADD INTERFACE METHOD TO GameVisitor to automatically give these variables
  override val narrowSlotTypes : List[Slot] = List( NninfConstants.NONNULL,  LiteralThis, LiteralSuper )
  override val wideSlotTypes   : List[Slot] = List( LiteralNull, NninfConstants.NULLABLE )

}
