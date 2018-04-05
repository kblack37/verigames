package salt.quals;

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
 * Represents a value that is provably the output of a one-way hash function
 * with a salt.<p/>
 *
 *
 * For example, authentication routines should only store passwords that have
 * been verifiably subjected to a one-way hashing algorithm with a salt.<p/>
 *
 * Null literals are considered to be {@code OneWayHashWithSalt}s by
 * default.<p/>
 *
 * The concatenation of two {@code OneWayHashWithSalt} types with the + operator
 * results in a {@code OneWayHashWithSalt} type. This is inherited from the
 * trusted type system on which this type system is based, but its applicability
 * to this type system should be reconsidered.<p/>
 *
 * @see MaybeHash
 * @see trusted.quals.Trusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@TypeQualifier
@SubtypeOf({MaybeHash.class})
@ImplicitFor(trees={Tree.Kind.NULL_LITERAL})
public @interface OneWayHashWithSalt {}
