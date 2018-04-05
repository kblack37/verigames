package download.quals;

import java.lang.annotation.*;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * A type annotation for variables that may contain data that has been
 * downloaded, and not yet verified.<p/>
 *
 * An unannotated type is assumed to be an {@code ExternalResource}.<p/>
 *
 * @see VerifiedResource
 * @see trusted.quals.Untrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
public @interface ExternalResource {}
