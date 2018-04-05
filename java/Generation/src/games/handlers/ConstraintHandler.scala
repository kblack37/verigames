package games.handlers

import checkers.inference.Constraint
import games.GameSolver

/**
 *
 * @tparam CONSTRAINT_TYPE
 */
trait ConstraintHandler[CONSTRAINT_TYPE <: Constraint] {
  val constraint : CONSTRAINT_TYPE

   def handle( ) {
     throw new RuntimeException("Unhandled constraint: " + constraint )
   }
}
