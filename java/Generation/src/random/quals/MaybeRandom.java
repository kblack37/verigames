package random.quals;

import java.lang.annotation.*;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

import com.sun.source.tree.Tree;

/**
 * Indicates that the contained data cannot be proven to have originated from a
 * cryptographically secure random number generator.</p>
 *
 * As such, it is not suitable for use in applications such as cryptographic key
 * generation.</p>
 *
 * By default, types are considered to be {@code MaybeRandom}.
 *
 * @see Random
 * @see trusted.quals.Untrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
@ImplicitFor(
	 trees={
    Tree.Kind.STRING_LITERAL
	 })
public @interface MaybeRandom {}
