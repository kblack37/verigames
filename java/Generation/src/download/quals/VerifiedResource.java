package download.quals;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import com.sun.source.tree.Tree;

import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * Represents data that is known to be valid.<p/>
 *
 * It could have either been downloaded and verified, or it could have
 * originated from within the program.<p/>
 *
 * The concatenation via the + operator of any two {@code VerifiedResources} is a
 * {@code VerifiedResource}.<p/>
 *
 * All literals are given type {@code VerifiedResource} by default.
 *
 * @see ExternalResource
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({ExternalResource.class})
@ImplicitFor(
    trees={
        Tree.Kind.BOOLEAN_LITERAL,
        Tree.Kind.CHAR_LITERAL,
        Tree.Kind.DOUBLE_LITERAL,
        Tree.Kind.FLOAT_LITERAL,
        Tree.Kind.INT_LITERAL,
        Tree.Kind.LONG_LITERAL,
        Tree.Kind.NULL_LITERAL,
        Tree.Kind.STRING_LITERAL,
    })
public @interface VerifiedResource {}
