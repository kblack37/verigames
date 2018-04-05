package sqltrusted.quals;

import java.lang.annotation.*;

import checkers.quals.DefaultQualifierInHierarchy;
import checkers.quals.SubtypeOf;
import checkers.quals.TypeQualifier;

/**
 * Represents data that may or may not be safe for use in SQL queries.<p/>
 *
 * For example, a String submitted by a client to a web server would be
 * considered {@code SqlUntrusted}.<p/>
 *
 * By default, types are considered to be {@code SqlUntrusted}.<p/>
 *
 * @see SqlTrusted
 * @see trusted.quals.Untrusted
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.TYPE_USE, ElementType.TYPE_PARAMETER })
@TypeQualifier
@SubtypeOf({})
@DefaultQualifierInHierarchy
public @interface SqlUntrusted {}
