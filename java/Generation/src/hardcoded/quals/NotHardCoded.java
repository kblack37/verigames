package hardcoded.quals;

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
 * Indicates that the contained data was definitely not hard-coded into the
 * source code.<p/>
 *
 * Credentials should not be hard-coded into source, and routines that perform
 * authentication (for example, connecting to a SQL server) should require that
 * the credentials given are {@code NotHardCoded}.<p/>
 *
 * The use of the + operator on any two types, at least one of which is {@code
 * NotHardCoded}, results in a {@code NotHardCoded} type. This is intended for
 * use with {@code String}s, but can technically be applied to other types. We
 * should consider restricting it to {@code Strings}.<p/>
 *
 * By default, only the null literal is {@code NotHardCoded}.
 *
 * @see MaybeHardCoded
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({MaybeHardCoded.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface NotHardCoded {

}
