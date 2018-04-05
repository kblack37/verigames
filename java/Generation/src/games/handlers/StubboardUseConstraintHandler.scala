package games.handlers

import checkers.inference.{Constant, Slot, WithinClassVP, StubBoardUseConstraint}
import games.GameSolver
import trusted.TrustedConstants
import scala.collection.mutable.ListBuffer
import verigames.level.StubBoard.StubConnection
import verigames.level.StubBoard
import checkers.inference.util.SlotUtil

abstract class StubBoardUseConstraintHandler( override val constraint : StubBoardUseConstraint,
                                              val gameSolver : GameSolver)
  extends ConstraintHandler[StubBoardUseConstraint] {

  //TODO: Add a library method to be able to just query these rather than duplicating them here
  //TODO: and in EqualityConstraintHandler
  val narrowSlotTypes : List[Slot]
  val wideSlotTypes   : List[Slot]

  def isNarrow( nonVar : Slot ) = {
    require( nonVar != null, "Narrowness of null slot is undefined!" )
    narrowSlotTypes.find( _ == nonVar ).isDefined
  }

  val StubBoardUseConstraint( fullyQualifiedClass, methodSignature, levelVp, receiver,
                              methodTypeParamLBs, classTypeParamLBs,
                              methodTypeParamUBs, classTypeParamUBs,
                              args, result ) = constraint

  //NOTE: Any methods/variables that don't seem to exist in this class are imported from GameSolver
  import gameSolver._

  val level = classToLevel( levelVp.getFQClassName )

  override def handle() {
    val methodTypeParams = SlotUtil.interlaceTypeParamBounds( methodTypeParamUBs, methodTypeParamLBs )
    val classTypeParams  = SlotUtil.interlaceTypeParamBounds( classTypeParamUBs,  classTypeParamLBs  )

    val ( inReceiverSeq, outReceiverSeq ) =
      if( receiver != null ) {
        val narrowness = isNarrow( receiver )
        ( Some( new StubConnection( ReceiverInPort + "0", narrowness ) ),
          Some( new StubConnection( ReceiverOutPort + "0", narrowness) )  )
      } else {
        ( None, None )
      }

    val inputs =
      inReceiverSeq.toList ++
      makeStubConnections( ClassTypeParamsInPort,  classTypeParams  )    ++
      makeStubConnections( MethodTypeParamsInPort, methodTypeParams )    ++
      makeStubConnections( ParamInPort, args )

    val outputs =
      outReceiverSeq.toList ++
      makeStubConnections( ClassTypeParamsOutPort,  classTypeParams  )    ++
      makeStubConnections( MethodTypeParamsOutPort, methodTypeParams )    ++
      makeStubConnections( ParamOutPort, args )                           ++
      makeStubConnections( ReturnOutPort, result )

    import scala.collection.JavaConversions._
    level.addStubBoard( cleanUpForXML(methodSignature), new StubBoard( inputs, outputs ) )
  }

  def interlaceTypeArgsAndBounds( typeArgs : List[(List[Constant], Constant)] ) : List[Constant] = {
    val slotBuffer = new ListBuffer[Constant]
    for( (typeArg, lowerBound) <- typeArgs ) {
      slotBuffer ++= typeArg
      slotBuffer +=  lowerBound
    }
    slotBuffer.toList
  }

  def makeStubConnections( portPrefix : String, constants : List[Constant] ) = {
    constants.zipWithIndex.map( {
      case ( constant, index ) => new StubConnection( portPrefix + index, isNarrow( constant ) )
    } )
  }

}
