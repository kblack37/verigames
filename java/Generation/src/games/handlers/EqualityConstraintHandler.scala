package games.handlers

import games.GameSolver
import verigames.level.{Board, Subboard, Chute, Intersection}
import checkers.inference._
import checkers.types.AnnotatedTypeMirror
import checkers.types.AnnotatedTypeMirror.{AnnotatedTypeVariable, AnnotatedDeclaredType}
import verigames.level.Intersection.Kind._
import checkers.inference.EqualityConstraint
import checkers.inference.CombVariable

/**
 * Handler for an equality constraint--for equality constraints, we just need to
 * link the two pipes corresponding to the slots so that they will always have
 * the same width.
 *
 * @param constraint
 * @param gameSolver
 */

abstract class EqualityConstraintHandler( override val constraint : EqualityConstraint,
                                          gameSolver : GameSolver )
  extends ConstraintHandler[EqualityConstraint] {
  import Intersection.Kind._
  import gameSolver._

  //Put Constants and Literals in here that represent what types are implicitly narrow or wide
  //See isNarrow, isWide, these will be used in handleMixed to automatically generate the right
  //forced-narrow or forced-wide pipe
  val narrowSlotTypes : List[Slot]
  val wideSlotTypes   : List[Slot]

  def isNarrow( nonVar : Slot ) = narrowSlotTypes.find( _ == nonVar ).isDefined
  def isWide(   nonVar : Slot ) = wideSlotTypes.find(   _ == nonVar ).isDefined

  //NOTE: If a variable isn't declared in this file then it likely comes from gameSolver
  val EqualityConstraint(leftSlot : Slot, rightSlot : Slot) = constraint

  override def handle( ) {
    ( leftSlot, rightSlot ) match {
      case ( combVar1 : CombVariable, _ )  => println( "Handle combVars in equality constraints" )
      case ( _, combVar2 : CombVariable )  => println( "Handle combVars in equality constraints" )

      case ( leftVar : AbstractVariable, rightVar : AbstractVariable )  => handleVars( leftVar, rightVar )
      case ( leftVar : AbstractVariable, _ )  => handleMixed( leftVar,  rightSlot )
      case ( _, rightVar : AbstractVariable ) => handleMixed( rightVar, leftSlot  )
      case _ => handleConstants( leftSlot, rightSlot )
    }

  }

  protected def handleVars( leftVar : AbstractVariable, rightVar : AbstractVariable ) {
    if( leftVar == rightVar ) {
      return
    }

    val leftBoard  = variablePosToBoard(leftVar.varpos)
    val rightBoard = variablePosToBoard(rightVar.varpos)

    val leftCon  = Intersection.factory( CONNECT )
    val rightCon = Intersection.factory( CONNECT )

    val lastLeft  = boardNVariableToIntersection((leftBoard, leftVar))
    val lastRight = boardNVariableToIntersection((rightBoard, rightVar))

    leftBoard.addNode(leftCon)
    rightBoard.addNode(rightCon)

    val leftPipe  = new Chute(leftVar.id, leftVar.toString())
    val rightPipe = new Chute(rightVar.id, rightVar.toString())

    val level = variablePosToLevel(leftVar.varpos)
    world.linkByVarID( leftVar.id, rightVar.id )

    leftBoard.addEdge(lastLeft, "output", leftCon, "input", leftPipe)
    rightBoard.addEdge(lastRight, "output", rightCon, "input", rightPipe)

    boardNVariableToIntersection.update((leftBoard, leftVar), leftCon)
    boardNVariableToIntersection.update((rightBoard, rightVar), rightCon)
  }

  protected def handleMixed( variable : AbstractVariable, nonVariable : Slot ) {
    if( isNarrow( nonVariable ) ) {
      forceNarrow( variable )
    } else if( isWide( nonVariable ) ) {
      forceWide( variable )
    } else {
      println( "Unhandled equality constraint. ( " + variable + ", " + nonVariable + ") " )
    }
  }

  protected def handleConstants( leftSlot : Slot, rightSlot : Slot ) {
    //So this shouldn't happen because all trees that are usually annotated but have a Constant on them
    //should just have an equality constraint between the variable and the Constant
    //but lets check and throw if they don't agree
    if ( isNarrow( leftSlot ) != isNarrow(rightSlot ) || isWide(   leftSlot ) != isWide(  rightSlot ) ) {
      println("TODO: Unsatisfiable constraint: " + constraint)
    }
  }

  private def forceWidth( variable : AbstractVariable, isNarrow : Boolean ) {

    val board = variablePosToBoard( variable.varpos )
    val lastIntersection = boardNVariableToIntersection( (board, variable) )

    val pipe = new Chute( variable.id, variable.toString )
    pipe.setNarrow( isNarrow )
    pipe.setEditable(false)

    val con  = board.add( lastIntersection, "output", CONNECT, "input", pipe ).getSecond
    boardNVariableToIntersection( (board, variable) ) = con
  }

  protected def forceNarrow( variable : AbstractVariable ) = forceWidth( variable, true  )

  protected def forceWide( variable : AbstractVariable )   = forceWidth( variable, false )
}
