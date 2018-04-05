package misc.util

import verigames.utilities.Pair

object VGJavaConversions {

    implicit def pairToTuple[T1,T2](pair: Pair[T1,T2]) : (T1,T2) = (pair.getFirst -> pair.getSecond)
}
