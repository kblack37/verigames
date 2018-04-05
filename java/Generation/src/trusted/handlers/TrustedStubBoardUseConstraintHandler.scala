package trusted.handlers


import checkers.inference._
import games.GameSolver
import checkers.inference.StubBoardUseConstraint
import trusted.TrustedConstants
import games.handlers.StubBoardUseConstraintHandler

case class TrustedStubBoardUseConstraintHandler( stubUse : StubBoardUseConstraint, override val gameSolver : GameSolver)
  extends StubBoardUseConstraintHandler( stubUse, gameSolver ) {

  //TODO: NEED TO ADD INTERFACE METHOD TO GameVisitor to automatically give these variables
  override val narrowSlotTypes : List[Slot] = List( TrustedConstants.TRUSTED   )
  override val wideSlotTypes   : List[Slot] = List( TrustedConstants.UNTRUSTED )

}

