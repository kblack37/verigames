package trusted

import checkers.inference._

/**
 * Make access to Constants for the qualifiers simple.
 */
object TrustedConstants {
  // call getRealChecker to ensure that it is initialized
  val rc = InferenceMain.getRealChecker.asInstanceOf[TrustedChecker]
  val UNTRUSTED = Constant(rc.UNTRUSTED)
  val TRUSTED = Constant(rc.TRUSTED)
}
