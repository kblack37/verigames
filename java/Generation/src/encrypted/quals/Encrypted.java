package encrypted.quals;

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
 * A type annotation representing encrypted String data.<p/>
 *
 * The concatenation via the + operator of any two {@code Encrypted String}s is
 * also an {@code Encrypted String}.<p/>
 *
 * Null literals are, by default, given an {@code Encrypted} type.<p/>
 *
 * @see Plaintext
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({Plaintext.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface Encrypted {}
