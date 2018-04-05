package hardcoded.quals;

import java.lang.annotation.*;

import com.sun.source.tree.Tree;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.ImplicitFor;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * Indicates that the contained data may have been hard-coded into the source
 * code.<p/>
 *
 * All literals except null are given this type implicitly. Unless declared
 * otherwise, types written by the programmer are assumed to be {@code
 * MaybeHardCoded}.<p/>
 *
 * @see NotHardCoded
 * @see trusted.quals.UnTrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
// TODO since this is the default qualifier, is this necessary?
@ImplicitFor(
    trees={
        Tree.Kind.BOOLEAN_LITERAL,
        Tree.Kind.CHAR_LITERAL,
        Tree.Kind.DOUBLE_LITERAL,
        Tree.Kind.FLOAT_LITERAL,
        Tree.Kind.INT_LITERAL,
        Tree.Kind.LONG_LITERAL,
        Tree.Kind.STRING_LITERAL,
    })
public @interface MaybeHardCoded {

}
