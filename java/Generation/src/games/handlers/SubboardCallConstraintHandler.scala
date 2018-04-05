package games.handlers

import checkers.inference._
import checkers.types.AnnotatedTypeMirror
import games.GameSolver
import scala.collection.mutable.{LinkedHashMap, ListBuffer}
import verigames.level.{Board, Chute, Subboard, Intersection}
import checkers.inference.InferenceMain._
import checkers.types.AnnotatedTypeMirror.AnnotatedTypeVariable
import verigames.level.Intersection.Kind._
import misc.util.VGJavaConversions._
import checkers.inference.util.SlotUtil

/**
 *
 * This trait handles the creation/placement of a CALL to a method subboard and
 * NOT the creation of the a method subboard itself (this is done incrementally through
 * placement of individuals variables/constraints on a method board).
 *
 * For the most part, we just pipe through the relevant arguments and type arguments through the method
 * subboard.  We first split all variables before connecting them to the method call intersection
 * (i.e. the subboard intersection).  This also allows us to handle the case in which the same variable
 * is the argument to two different parameters.
 *
 *  For the most part users of this trait should be able to just declare the required variables to
 *  implement this trait.  This class should appropriately handle static/instance method calls including constructors.
 */
abstract class SubboardCallConstraintHandler[CALLED_VP           <: VariablePosition,
                                             SUBBOARD_CONSTRAINT <: SubboardCallConstraint[CALLED_VP]](

  val constraint : SUBBOARD_CONSTRAINT,

  /** The GameSolver that contains the world/level/boards we are editing */
  val gameSolver : GameSolver ) extends ConstraintHandler[SUBBOARD_CONSTRAINT]  {

  import gameSolver._

  protected val methodSignature : String

  //The board representing the method IN which the call was made
  protected val callerBoard = variablePosToBoard( constraint.contextVp )

  // Variables that will be connected both as input/output of the subboard rather than just input or just output
  protected val throughVars = new ListBuffer[AbstractVariable]()

  // to avoid problems with arguments passed to two different params (i.e. aliased arguments),
  // we split before connecting each argument, and the next time the aliased argument
  // is used, we grab the split at the top, instead of pulling it up
  // from the output
  protected val localIntersectionMap = new LinkedHashMap[Slot, Intersection]

  // stores all of the outputs from this subboard. Because aliased
  // arguments result in multiple outputs, we need to store a list of
  // those outputs so that we can later merge them.
  protected val outputMap = new LinkedHashMap[Slot, List[Intersection]]
/**
   * Essentially treats outputMap as a ListMap.
   * If outputMap doesn't already contain slot as a key
   *  then Add a new entry slot -> List(intersction)
   *  else Add intersction to the list for existing entry corresponding to the key slot
   *
   * See outputMap for more details
   *
   * @param slot An existing or new key to outputMap
   * @param intersection An intersection to add to the list of entries representing the given slot
   */
  protected def addToOutputMap(slot: Slot, intersection: Intersection) {
    outputMap.get(slot) match {
      case Some(list) => outputMap.update(slot, intersection::list)
      case None       => outputMap.update(slot, List(intersection))
    }
  }

  /**
   * If the given slot already has an intersection in localIntersectionMap then return that intersection otherwise
   * find the intersection on the callerBoard using the gameSolver.  See localIntersectionMap for more details
   * @param slot The slot for which we are finding an intersection
   * @return An intersection for the given slot
   */
  protected def localFindIntersection(slot: Slot): Intersection = {
    localIntersectionMap.get(slot) match {
      case Some(intersection) => intersection
      case None => findIntersection(callerBoard, slot)
    }
  }

  /**
   * Create the subboard intersection that represents the method call.  Connect all variables for the receiver,
   * class type parameters, and method type parameters through the intersection and link any that have an
   * equality relation ship.  Connect any variables for the method's arguments and link any generic type arguments
   * to their corresponding pipes in the method board.  At the moment we split the arguments rather than
   * routing them through but it should be enough to just route them through.  Connect the return type
   * through the subboard.
   */
  override def handle() {
    println( "HANDLING " + constraint )

    val subboardISect =
      if( constraint.isLibraryCall ) {
        val stubUse = constraint.stubBoardUse.get
        addStubboardIntersection( callerBoard, variablePosToLevel(stubUse.levelVp), methodSignature )
      } else {
        addSubboardIntersection(callerBoard, constraint.calledVp.get, methodSignature)
      }

    // Add equality and bounding (lowerBound <: slot) above the board before we split, so that we only
    // have one instance of the same bound
    addEqualityConstraints()
    addBoundingConstraints()

    connectReceiverParamsThrough( subboardISect )

    connectClassTypeArgsThrough( subboardISect )
    connectMethodTypeArgsThrough( subboardISect )

    connectArgumentsThrough( subboardISect )

    connectResultAsOutput( subboardISect )

    capSplits()
    mergeOutputs()

  }

  def addEqualityConstraints() {
    constraint.equivalentSlots.foreach({
      case ( slot1, slot2 ) => gameSolver.handleConstraint( gameSolver.world, EqualityConstraint( slot1, slot2 ) )
    })
  }

  def addBoundingConstraints() {
    constraint.slotToBounds.foreach({
      case ( slot : AbstractVariable, lowerBound : AbstractVariable ) =>
       gameSolver.addVariableSubtypeConstraint( callerBoard, slot, lowerBound )

      case ( slot, lowerBound ) =>
        gameSolver.handleConstraint( gameSolver.world, SubtypeConstraint( lowerBound, slot ) )
    })
  }

  /**
   * Connect the receivers main slot through the board
   * Connect the class type arguments of the receiver through the corresponding type parameter ports of
   * the class in which the called method is defined.
   * @param subboardISect The subboard representing the method call.
   */
  def connectReceiverParamsThrough( subboardISect : Subboard ) = {

    val receiver = constraint.receiver
    if( receiver != null ) {
      connectThrough( subboardISect, List( receiver ), ReceiverInPort, ReceiverOutPort )
    }
  }

  def connectClassTypeArgsThrough( subboardISect : Subboard) = {
    connectTypeArgsThrough( subboardISect, constraint.classTypeArgs, constraint.classTypeParamLBs,
                            ClassTypeParamsInPort, ClassTypeParamsOutPort)
  }

  def connectMethodTypeArgsThrough( subboardISect : Subboard ) = {
    connectTypeArgsThrough( subboardISect, constraint.methodTypeArgs, constraint.methodTypeParamLBs,
      MethodTypeParamsInPort, MethodTypeParamsOutPort)
  }

  def connectArgumentsThrough( subboardISect : Subboard ) = {
    connectThrough( subboardISect, constraint.args, ParamInPort, ParamOutPort )
  }

  def connectTypeArgsThrough( subboardISect : Subboard, typeArgs : List[List[Slot]], lowerBounds : List[Slot],
                              inPortPrefix : String, outPortPrefix : String ) = {
    val slots = SlotUtil.interlaceTypeParamBounds( typeArgs, lowerBounds )
    connectThrough( subboardISect, slots, inPortPrefix, outPortPrefix )
  }

  def connectThrough( subboardISect : Subboard, slots : List[Slot],
                      inputPortPrefix : String, outputPortPrefix : String ) {
    connectAsInput(  subboardISect, slots, inputPortPrefix )
    connectAsOutput( subboardISect, slots, outputPortPrefix )
  }

  /**
   * Connect each variable chute on the caller board to the correct input of the subboard intersection
   * for this method call.  If the variable is not a unique slot (e.g. LiteralString("blahhhh")) then
   * it is a variable of some sort.  Split it, and add it's split into the local intersection map.
   *
   * @param subboardISect The subboard intersection being wired
   * @param slots   (slots -> link), the slots to wire and whether or not we wish to link them to
   *                      the corresponding pipe in the method subboard
   * @param portPrefix    A prefix to add to all input ports
   * @return A mapping of slots to the intersections that are created in this step.  For variables this is
   *         a mapping to the split created in this step.
   */
  def connectAsInput( subboardISect : Subboard, slots : List[Slot], portPrefix : String ) : List[(Slot,Intersection)] = {

    slots.map( slot => {

      //If a slot is unique (e.g. "someLiteral") then it doesn't need to be split because it can't be accessed again

      val slotIsect = localFindIntersection( slot )
      val port = nextInputId( subboardISect, portPrefix )

      if ( isUniqueSlot( slot ) ) {
        callerBoard.addEdge( slotIsect, "output", subboardISect, port, createChute( slot ) )
        slot -> slotIsect

      } else {
        val split = callerBoard.add( slotIsect, "output", SPLIT, "input", createChute( slot ) )._2
        callerBoard.addEdge(split, "split", subboardISect, port, createChute(slot ) )

        // it's a bit of a hack to update both the local and the
        // global intersection maps, but it won't be necessary once
        // all arguments are piped through
        localIntersectionMap.update( slot, split )
        slot -> split

      }
    })
  }


  /**
   * Connect each variable chute on the caller board to the correct input of the subboard intersection
   * for this method call.  If the variable is not a unique slot (e.g. LiteralString("blahhhh")) then
   * it is a variable of some sort.  Split it, and add it's split into the local intersection map.
   *
   * @param subboardISect The subboard intersection being wired
   * @param slots
   * @param portPrefix    A prefix to add to all input ports
   * @return A mapping of slots to the intersections that are created in this step.  For variables this is
   *         a mapping to the split created in this step.
   */
  def connectAsOutput( subboardISect : Subboard, slots : List[Slot], portPrefix : String ) : List[(Slot,Intersection)] = {
    slots.map( slot => {

      //If a slot is unique (e.g. "someLiteral") then it doesn't need to be split because it can't be accessed again
      val port = nextOutputId( subboardISect, portPrefix )
      val connect = callerBoard.add( subboardISect, port, CONNECT, "input", createChute( slot ) )._2

      if ( isUniqueSlot( slot ) ) {
        cap( slot, connect )
      } else {
        addToOutputMap(slot, connect)
      }

      slot -> connect
    })
  }

  def connectResultAsOutput( subboardISect : Subboard ) {
    //Results are unique in the sense that they are not necessarily passed as input to the subboard call
    //the only way they can be passed as inputs is if the result of a previous call is fed into the next call.
    //If the result variables are on the board (but not fed into this call) then merge the previous output
    //with the current output
    val nonArgumentResults  =
      constraint.result
        .filterNot( outputMap.contains _ ) //If it's fed in as input, the caller board connection will be capped
        .filterNot( isUniqueSlot _ )
        .map( _.asInstanceOf[AbstractVariable] )
        .filter( v => boardNVariableToIntersection.contains( (callerBoard, v) ) )

    connectAsOutput( subboardISect, constraint.result, ReturnOutPort )

    //This will cause the merge step to also merge the latest intersection on the board with those already
    //in the output map
    nonArgumentResults.foreach( resSlot =>
      addToOutputMap( resSlot, boardNVariableToIntersection( (callerBoard, resSlot) ) )
    )
  }

  def cap( slot : Slot, isect : Intersection ) {
    callerBoard.add( isect, "toEnd", END, "input", createChute( slot ) )
  }

  def cap( slotToIsect : (Slot, Intersection)) {
    cap( slotToIsect._1, slotToIsect._2 )
  }

  /**
   * Any variable in the throughVars list has been piped through the board.  However, we also split this
   * variable at the top to handle aliased arguments (see localIntersectionMap).  End the extra split
   * as we will use the pipes coming out of the subboard as the latest intersection for these variables.
   */
  def capSplits() {
    localIntersectionMap.toList.foreach( slotToIsect=> cap( slotToIsect ) )
  }

  /**
   * The same variable may be split above the board multiple times (for instance when
   * a call f.foo(bar, bar) would cause bar to be split twice).  These values will then be piped through
   * the method board and lead to potentially multiple output intersection for the same value.  Merge
   * these
   */
  def mergeOutputs() {
    for ((slot, subboardOutputs) <- outputMap) {
      val mergedIntersection = merge(subboardOutputs, () => createChute(slot) )
      updateIntersection(callerBoard, slot, mergedIntersection)
    }
  }

  // Arguments:
  // - list of intersections
  // - a factory with which new chutes can be created
  //
  // Effects:
  // adds enough merges to merge the intersections into a single
  // pipe
  //
  // Returns: the single node resulting from this process (which may
  // be a merge node, or may be another node, if no merges were
  // needed)
  //
  // Mutates: callerBoard
  def merge(intersections: List[Intersection], chuteFactory: () => Chute): Intersection = {
    if(intersections.isEmpty) {
      throw new IllegalArgumentException("empty list passed to merge")
    }

    if( intersections.size == 1 ) {
      intersections.head
    } else {
      intersections.tail.foldLeft(intersections.head)( (prev : Intersection, current : Intersection) => {
        val mergeIntersection = callerBoard.add( prev, "toMerge", MERGE, "first", chuteFactory() )._2
        callerBoard.addEdge(current, "toMerge", mergeIntersection, "second", chuteFactory())
        mergeIntersection
      })
    }
  }


  /**
   * Create a port identifier for the given slot
   * The port is structured as follows:
   *
   * portPrefix + index + genericOffset
   *
   * index and generic offset are both option depending on whether addIndex and !unique respectively.
   * e.g.
   * if !addIndex and !unique then return
   *   portPrefix + genericOffset
   *
   * if addIndex and unique then return
   *   portPrefix + index
   *
   * @param portPrefix The start of the port identifier
   * @param addIndex   Whether or not index should be added to the identifier
   * @param index      The index to add to the identifier
   * @param slot       The slot for which we are creating a port (used to create the genericOffset string)
   * @param unique     Whether or not slot is a unique variable or a constant/literal value
   * @return           A string that identifies a port
   */
  def makePort(portPrefix : String, addIndex : Boolean, index : Int, slot : Slot, unique : Boolean) : String = {
    val port = new scala.collection.mutable.StringBuilder()
    port ++= portPrefix

    if( addIndex ) {
      port ++= index.toString
    }

    if( !unique ) {
      port ++= genericsOffset( slot.asInstanceOf[AbstractVariable] ).toString
    }

    port.toString
  }



}