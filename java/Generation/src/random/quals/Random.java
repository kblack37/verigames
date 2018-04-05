package random.quals;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

import com.sun.source.tree.Tree;

/**
 * Indicates that the contained data originated from a cryptographically secure
 * random number generator such as the java.security.SecureRandom class.<p/>
 *
 * Code such as cryptographic key generation routines should require that their
 * sources of randomness be {@code Random}.
 *
 * Two pieces of random data concatenated or added with the + operator are still
 * considered to be random. We should consider extending this to other
 * arithmetic operators and the ^ (XOR) operator.<p/>
 *
 * The null literal is considered random.
 *
 * @see MaybeRandom
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({MaybeRandom.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface Random {}
