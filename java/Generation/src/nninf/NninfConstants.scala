package nninf

import checkers.inference._

/**
 * Make access to Constants for the qualifiers simple.
 */
object NninfConstants {
  // call getRealChecker to ensure that it is initialized
  val rc = InferenceMain.getRealChecker.asInstanceOf[NninfChecker]
  val NULLABLE = Constant(rc.NULLABLE)
  val NONNULL = Constant(rc.NONNULL)
  //val KEYFOR = Constant(rc.KEYFOR)
  //val UNKNOWNKEYFOR = Constant(rc.UNKNOWNKEYFOR)
}
