package salt.quals;

import java.lang.annotation.*;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * Represents a value that may or may not be the output of a one-way hash
 * function with a salt.<p/>
 *
 * All types are implicitly considered {@code MaybeHashes}.<p/>
 *
 * @see OneWayHashWithSalt
 * @see trusted.quals.Untrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
public @interface MaybeHash {}
