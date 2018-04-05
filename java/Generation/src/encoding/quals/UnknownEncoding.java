package encoding.quals;

import java.lang.annotation.*;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * A type annotation to indicate that data cannot be proven to have the proper
 * encoding for some purpose.<p/>
 *
 * This annotation is intended to be used with {@code String}s.
 *
 * Unannotated types are given the {@code UnknownEncoding} type implicitly.<p/>
 *
 * @see AppropriateEncoding
 * @see trusted.quals.Untrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
public @interface UnknownEncoding {}
