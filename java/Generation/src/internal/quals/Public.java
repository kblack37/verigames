package internal.quals;

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
 * Indicates that the contained data is acceptable to display to the end-user.<p/>
 *
 * Code that prints data or sends it over the network can require that the data
 * it's passed be {@code Public}. Particularly, error handling code that
 * displays the message can require the information it displays to be {@code
 * Public}.<p/>
 *
 * As described in the JDK stub file for this type system, the printing methods
 * of {@code PrintStream} require their arguments to be {@code Public}.<p/>
 *
 * The concatentation of the + operator of any two {@code Public String}s is a
 * {@code Public String}. In fact, any use of the + operator on two {@code
 * Public} types results in a {@code Public} type, though this behavior is
 * intended to be primarily used with {@code String}s.<p/>
 *
 * Null literals are given this annotation by default.<p/>
 *
 * @see Internal
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({Internal.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface Public {}
