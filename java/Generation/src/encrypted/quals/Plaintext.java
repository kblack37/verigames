package encrypted.quals;

import java.lang.annotation.*;

import com.sun.source.tree.Tree;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * A type annotation representing {@code String} data that cannot be proven to
 * be encrypted.<p/>
 *
 * String literals are, by default, given a {@code Plaintext} type.<p/>
 *
 * Unannotated types are considered to be {@code Plaintext}.<p/>
 *
 * @see Encrypted
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
public @interface Plaintext {}
