package games.handlers

import games.GameSolver
import checkers.types.AnnotatedTypeMirror
import checkers.inference.{FieldVP, FieldAccessConstraint}
import checkers.inference.util.SolverUtil

/**
 * TODO JB: Revisit this comment
 * For every member field in our game world we actually create a "synthetic" getter/setter board ( i.e. boards
 * doesn't correspond to an actual method ).  When a field is accessed it looks like a method call to the synthetic
 * getter board.  Recall that all method boards when referenced from another board are represented by a Subboard
 * intersection.
 *
 * FieldAccessConstraintHandler takes a single FieldAccessConstraint and adds to the game board located by the
 * accessContext of the constraint a call to the "synthetic" getter board for the field identified by the
 * fieldType.  One of these should be created then disposed of foreach FieldAccessConstraint
 * <<TODO: ADD TO LINK EXPLAINING THIS>>
 *
 * Note:  The getter board should have a number of outputs equal to the number of variables that appear
 * in the type of the field. Also, the receiver will have a number of inputs/outputs equal to the number
 * of variables inside its declaration
 *
 * (E.g. The method board for:
 *
 *     private @VarAnnot(0) Map< @VarAnnot(1) String, @VarAnnot(2) List< @VarAnnot(3) Integer>>;
 *
 * would have an output for each of the VarAnnot's above and they would be attached in the order [0, 1, 2, 3].
 * TODO: Should this order instead mimic the order in which we actually create the variables?
 *
 *
 * @param constraint
 * @param gameSolver
 */

case class FieldAccessConstraintHandler( override val constraint : FieldAccessConstraint,
                                         override val gameSolver : GameSolver)
  extends SubboardCallConstraintHandler[FieldVP, FieldAccessConstraint]( constraint, gameSolver ) {

  override val methodSignature =
    constraint.calledVp
      .map( SolverUtil.getFieldAccessorName _ )
      .getOrElse( constraint.stubBoardUse.get.methodSignature )
}