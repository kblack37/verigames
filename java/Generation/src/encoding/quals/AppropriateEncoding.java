package encoding.quals;

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
 * A type annotation to indicate that data has the proper encoding for some
 * purpose.<p/>
 *
 * It is the responsibility of the user to determine what, exactly, that
 * encoding is.<p/>
 *
 * Concatenating any two appropriately encoded {@code String}s with the +
 * operator results in an appropriately encoded {@code String}.<p/>
 *
 * The null literal is, by default, considered to be appropriately encoded.<p/>
 *
 * This annotation is intended to be used with {@code String}s.
 *
 * @see UnknownEncoding
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({UnknownEncoding.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface AppropriateEncoding {}
