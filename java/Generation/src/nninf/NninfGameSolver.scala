package nninf

import checkers.inference._
import javacutils.AnnotationUtils
import scala.collection.mutable.HashMap
import com.sun.source.tree.Tree.Kind
import javax.lang.model.element.AnnotationMirror
import verigames.level._
import checkers.inference.LiteralNull
import checkers.inference.AbstractLiteral
import games.GameSolver
import misc.util.VGJavaConversions._
import Intersection.Kind._
import nninf.handlers.{NninfStubBoardUseConstraintHandler, NninfEqualityConstraintHandler}

class NninfGameSolver extends GameSolver {

    // TODO: ensure that no CombVariables were created
    // assert combvariables.length == 0

    override def version: String = super.version + "\nNninfGameSolver version 0.1"

    /**
     * Go through all constraints and add the corresponding piping to the boards.
     * Returns true if the constraint was successfully handled. Does not mutate and returns
     * false if the constraint was not successfully handled. 
     */
    override def handleConstraint(world: World, constraint: Constraint): Boolean = {
        constraint match {
          case SubtypeConstraint(sub, sup) => {
            // TODO: CombVariables should be handled by flow sensitivity. Should revisit this when flow
            // sensitivity is integrated.
            if (sup.isInstanceOf[CombVariable] || unsupportedVariables.contains(sub) || unsupportedVariables.contains(sup) ) //TODO JB: REMOVE UNHANDLEDS
              return true;
            // No need to generate something for trivial super/sub-types.
            if (sup != NninfConstants.NULLABLE &&
                sub != NninfConstants.NONNULL) {
              var merge : Intersection = null
              var board : Board = null
              if (sub == LiteralNull) {
                // For "null <: sup" create a black ball falling into sup.
                // println("null <: " + sup)
                // Assume sup is a variable. Alternatives?

                //Possible Explanation: We have a binary method that gets defaulted to NonNull
                //which is then passed a null literal, need to change defaulting
                if( sup.isInstanceOf[Constant]) {  //TODO JB: Ask Werner
                  return true
                }

                val supvar = sup.asInstanceOf[AbstractVariable]
                board = variablePosToBoard(supvar.varpos)

                val lastIntersection = boardNVariableToIntersection((board, supvar))
                val merge = board.add(lastIntersection, "output", MERGE, "left", toChute(supvar))._2

                //TODO JB: Is there a reason we weren't using createChute here?
                val blackballchute = createChute(sub)
                val blackball  = board.add(Intersection.Kind.START_LARGE_BALL, "output", merge, "right", blackballchute)._1

                boardNVariableToIntersection.update((board, supvar), merge)
              } else {
                // Subtypes between arbitrary variables only happens for local variables.
                // TODO: what happens for "x = o.f"? Do I always create ASSIGNMENT constraints?
                // What about m(o.f)?
                board = findBoard(sub, sup)

                if (board!=null) {
                  // println(sub + " <: " + sup)

                  val sublast = findIntersection(board, sub)
                  val suplast = findIntersection(board, sup)

                  merge = Intersection.factory(Intersection.Kind.MERGE)
                  board.addNode(merge)


                  if (isUniqueSlot(sub)) {
                    board.addEdge(sublast, "output", merge, "left",  createChute(sub))
                    board.addEdge(suplast, "output", merge, "right", createChute(sup))

                    updateIntersection(board, sup, merge)
                  } else if (isUniqueSlot(sup)) {
                    board.addEdge(sublast, "output", merge, "left",  createChute(sub))
                    board.addEdge(suplast, "output", merge, "right", createChute(sup))

                    updateIntersection(board, sub, merge)
                  } else {
                    val split = Intersection.factory(Intersection.Kind.SPLIT)
                    board.addNode(split)

                    board.addEdge(sublast, "output", split, "input", createChute(sub))
                    board.addEdge(suplast, "output", merge, "left",  createChute(sup))
                    board.addEdge(split,   "split",  merge, "right", createChute(sub))

                    updateIntersection(board, sub, split)
                    updateIntersection(board, sup, merge)
                  }
                } else {
                  println ("TODO: unhandled subtype relationship: " + sub + " :> " + sup)
                }
              }
            }
          }
          case eqConstraint : EqualityConstraint => NninfEqualityConstraintHandler( eqConstraint, this ).handle()
          case InequalityConstraint(ctx, ell, elr) => {

            // println(ell + " != " + elr)
            // TODO: support var!=NULLABLE for now
            if (elr == NninfConstants.NULLABLE) {
              if (ell == LiteralThis) {
                // Nothing to do if the LHS is "this", always non-null.
              } else if (ell.isInstanceOf[Constant] || ell.isInstanceOf[AbstractLiteral] ){
                // TODO
              } else if (ell.isInstanceOf[Literal] ) {
                // TODO
                val lit = ell.asInstanceOf[Literal]
                println("TODO: Uncovered case" + lit)
              } else {
                val ellvar = ell.asInstanceOf[AbstractVariable]
                val board = variablePosToBoard(ctx);


                val elllast = findIntersection(board, ellvar)

                val chute = toChute(ellvar)
                chute.setPinched(true)

                val con = board.add(elllast, "output", CONNECT, "input", chute)._2
                updateIntersection(board, ellvar, con)

              }
            } else {
              println("TODO: uncovered inequality case!")
            }
          }

          case stubUseConstraint : StubBoardUseConstraint =>
            NninfStubBoardUseConstraintHandler( stubUseConstraint, this ).handle()

          case _ => {
            return super.handleConstraint(world, constraint)
          }
        }
        return true
    }

    /**
     * Find the latest intersection for a given slot.  Constants/Literals always have
     * a new Intersection for the latest use since their values never depend on past state
     * @param board Board we are searching on
     * @param slot  A slot that appears on board
     * @return The last intersection placed on board for slot
     */
    def findIntersection(board: Board, slot: Slot): Intersection = {
      slot match {
        //If we have a variable or LiteralThis, we have already created the previous Intersection
        case v: Variable           =>
          val iEmpty = boardNVariableToIntersection.get((board, v)).isEmpty //TODO: Temporary
          boardNVariableToIntersection((board, v))
        case v: RefinementVariable =>  boardNVariableToIntersection((board, v))
        case LiteralThis =>
          val iEmpty1 = boardToSelfVariable.get(board)
          val iEmpty2 = boardNVariableToIntersection.get( ( board, boardToSelfVariable(board) ) ).isEmpty //TODO: Temporary
          boardNVariableToIntersection( ( board, boardToSelfVariable(board) ) )

        //For assignments (and uses?) of literals/constants they result in a ball intersection
        //being generated as everywhere they are used is a NEW type use
        case LiteralNull             => board.addNode( START_LARGE_BALL )
        case NninfConstants.NULLABLE => board.addNode( START_LARGE_BALL )

        case lit: AbstractLiteral    => board.addNode( START_SMALL_BALL )  // TODO: Are all other literals non-null?
        case NninfConstants.NONNULL  => board.addNode( START_SMALL_BALL )
        case cv: CombVariable        => board.addNode( START_SMALL_BALL )  // TODO: Combvariables appear for BinaryTrees.

        case _ => {
          println( "findIntersection: unmatched slot: " + slot )
          null
        }
      }
    }

    def updateIntersection(board: Board, slot: Slot, inters: Intersection) {
      slot match {
        case v: Variable           =>  boardNVariableToIntersection.update((board, v), inters)
        case v: RefinementVariable =>  boardNVariableToIntersection.update((board, v), inters)
        case LiteralThis =>
          boardNVariableToIntersection.update( (board, boardToSelfVariable( board )), inters )

        //TODO: Is this right?
        case cv: CombVariable        =>  boardNVariableToIntersection.update((board, cv), inters)

        case LiteralNull             => // Nothing to do, we're always creating a new black ball
        case lit: AbstractLiteral    => // Also nothing to do for other literals
        case NninfConstants.NULLABLE => // Nothing to do, we're always creating a new black ball
        case NninfConstants.NONNULL  => // Nothing to do, we're always creating a new white ball

        case _ =>  println("updateIntersection: unmatched slot: " + slot)

      }
    }

    def createChute(slot: Slot): Chute = {
      slot match {
        case v: Variable => {
          new Chute(v.id, v.toString())
        }
        case v: RefinementVariable => {
          new Chute(v.id, v.toString())
        }
        case LiteralThis => {
          createThisChute()
        }
        case LiteralNull => {
          val res = new Chute(-2, "null")
          res.setEditable(false)
          res.setNarrow(false)
          res
        }
        case lit: AbstractLiteral => {
          val res = new Chute(-3, lit.lit.toString())
          res.setEditable(false)
          res.setNarrow(true)
          res
        }
        case NninfConstants.NULLABLE => {
          val res = new Chute(-4, "nullable")
          res.setEditable(false)
          res.setNarrow(false)
          res
        }
        case NninfConstants.NONNULL => {
          val res = new Chute(-5, "nonnull")
          res.setEditable(false)
          res.setNarrow(true)
          res
        }
        case cv: CombVariable => {
          // TODO: Combvariables appear for BinaryTrees.
          val res = new Chute(-6, "combvar")
          res.setEditable(false)
          res.setNarrow(true)
          res
        }
        case _ => {
          println("createChute: unmatched slot: " + slot)
          null
        }
      }
    }

    def createThisChute(): Chute = {
      val inthis = new Chute(-1, "this")
      inthis.setEditable(false)
      inthis.setNarrow(true)
      inthis
    }

    def createReceiverChute( variable : Variable ) = createChute( variable )


    override def optimizeWorld(world: World) {
      // TODO: Any optimizations specific to the nullness system?
      super.optimizeWorld(world)
    }
}