package test;

import checkers.inference._
import javacutils.AnnotationUtils
import scala.collection.mutable.HashMap
import com.sun.source.tree.Tree.Kind
import javax.lang.model.element.AnnotationMirror
import verigames.level._
import checkers.inference.LiteralNull
import checkers.inference.AbstractLiteral
import games.GameSolver
import java.io.FileWriter
import java.io.PrintWriter

class TestGameSolver extends GameSolver {
    override def version: String = super.version + "\nTestGameSolver version 0.1"
      
    val outputName = System.getenv("ACTUAL_PATH")
	
    override def solve(variables: List[Variable],
      combvariables: List[CombVariable],
      refinementVariables : List[RefinementVariable],
      constraints: List[Constraint],
      weights: List[WeightInfo],
      params: TTIRun): Option[Map[AbstractVariable, AnnotationMirror]] = {
      
      // Do nothing.
      println ("checking for env")
      println (System.getenv("HOME"))
      println (System.getenv("ACTUAL_PATH"))
      writeToFile(outputName, "Constraints:\n")
      
      super.solve(variables, combvariables, refinementVariables, constraints, weights, params)
    }
    
    override def createBoards(world: World) {
      // Do nothing.
      println ("checking for env")
      println (System.getenv("HOME"))
      println (System.getenv("ACTUAL_PATH"))
    }
    
	/**
     * Go through all constraints and add the corresponding piping to the boards.
     */
    override def handleConstraint(world: World, constraint: Constraint): Boolean = {
    	appendToFile(outputName, constraint.toString() + "\n")
    	true
    }

    def findIntersection(board: Board, slot: Slot): Intersection = {
      slot match {
        case _ => {
          println("findIntersection: unmatched slot: " + slot)
          null
        }
      }
    }

    def updateIntersection(board: Board, slot: Slot, inters: Intersection) {
      slot match {
        case _ => {
          println("updateIntersection: unmatched slot: " + slot)
        }
      }
    }

    def createChute(slot: Slot): Chute = {
      slot match {
        case _ => {
          println("createChute: unmatched slot: " + slot)
          null
        }
      }
    }

    override def finalizeWorld(world: World) {

    }

    def createThisChute(): Chute = {
      null
    }

    def createReceiverChute( variable : Variable ) = createChute( variable )
    
    def writeToFile(fileName:String, data:String) = 
    	using (new FileWriter(fileName)) {
    	fileWriter => fileWriter.write(data)
    }
    
    def appendToFile(fileName:String, textData:String) =
    	using (new FileWriter(fileName, true)){ 
    	fileWriter => using (new PrintWriter(fileWriter)) {
    		printWriter => printWriter.println(textData)
	    }
	 }
    
    def using[A <: {def close(): Unit}, B](param: A)(f: A => B): B =
    	try { f(param) } finally { param.close() }
}
